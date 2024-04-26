using Base.Threads
using DelimitedFiles
using Statistics
using LatinHypercubeSampling
using CSV
using JLD
using DataFrames
using Distributions

# Модель на сервере
include("../server/lib/data/etiology.jl")
include("../server/lib/data/incidence.jl")

include("../server/lib/global/variables.jl")

include("../server/lib/model/virus.jl")
include("../server/lib/model/agent.jl")
include("../server/lib/model/household.jl")
include("../server/lib/model/workplace.jl")
include("../server/lib/model/school.jl")
include("../server/lib/model/initialization.jl")
include("../server/lib/model/connections.jl")
include("../server/lib/model/contacts.jl")

include("../server/lib/util/moving_avg.jl")
include("../server/lib/util/stats.jl")
include("../server/lib/util/reset.jl")

# Локальная модель
include("model/simulation.jl")

function arg_n_smallest_values(A::AbstractArray{T,N}, n::Integer) where {T,N}
    perm = sortperm(vec(A))
    ci = CartesianIndices(A)
    return ci[perm[1:n]]
end

function run_ga_model()
    println("Initialization...")

    # Номер запуска модели
    run_num = 0
    is_rt_run = true
    try
        run_num = parse(Int64, ARGS[1])
    catch
        run_num = 0
    end

    # Число моделируемых лет
    num_years = 1
    # Среднее по num_years
    is_one_mean_year_modeled = true

    # Число потоков
    num_threads = nthreads()

    # Вероятности изолироваться при болезни на 1-й, 2-й и 3-й дни
    isolation_probabilities_day_1 = [0.406, 0.305, 0.204, 0.101]
    isolation_probabilities_day_2 = [0.669, 0.576, 0.499, 0.334]
    isolation_probabilities_day_3 = [0.45, 0.325, 0.376, 0.168]
    # Продолжительность резистентного состояния
    recovered_duration_mean = 6.0
    recovered_duration_sd = 2.0
    # Продолжительности контактов в домохозяйствах
    # Укороченные для различных коллективов и полная: детсад, школа, вуз, работа, полный контакт
    mean_household_contact_durations = [6.5, 5.8, 9.0, 4.5, 12.0]
    household_contact_duration_sds = [2.2, 2.0, 3.0, 1.5, 4.0]
    # Продолжительности контактов в прочих коллективах: детсад, школа, вуз, работа, вуз (между группами)
    other_contact_duration_shapes = [2.5, 1.78, 2.0, 1.81, 1.2]
    other_contact_duration_scales = [1.6, 1.95, 1.07, 1.7, 1.07]
    # Минимальный размер рабочего коллектива
    firm_min_size = 1
    # Максимальный размер рабочего коллектива
    firm_max_size = 1000
    # Параметр предпочтительного присоединения графа Барабаши-Альберт для рабочих коллективов
    work_num_barabasi_albert_attachments = 5
    # Параметр предпочтительного присоединения графа Барабаши-Альберт для школ
    school_num_barabasi_albert_attachments = 10

    # Набор вирусов
    # shape = mean * mean / variance
    # scale = variance / mean
    viruses = Virus[
        # Flu A
        Virus(round(Int, 1.4 * 1.4 / 0.67), 0.67 / 1.4,   round(Int, 4.8 * 4.8 / 2.04), 2.04 / 4.8,    round(Int, 8.0 * 8.0 / 3.4), 3.4 / 8.0,      3.53, 2.63, 1.8,    0.38, 0.47, 0.57,   1.0, 0.33),
        # Flu B
        Virus(round(Int, 0.6 * 0.6 / 0.19), 0.19 / 0.6,   round(Int, 3.7 * 3.7 / 3.0), 3.0 / 3.7,      round(Int, 6.1 * 6.1 / 4.8), 4.8 / 6.1,      3.53, 2.63, 1.8,    0.38, 0.47, 0.57,   1.0, 0.33),
        # RV
        Virus(round(Int, 1.9 * 1.9 / 1.11), 1.11 / 1.9,   round(Int, 10.1 * 10.1 / 7.0), 7.0 / 10.1,   round(Int, 11.4 * 11.4 / 7.7), 7.7 / 11.4,   3.5, 2.6, 1.8,      0.19, 0.24, 0.29,   1.0, 0.33),
        # RSV
        Virus(round(Int, 4.4 * 4.4 / 1.0), 1.0 / 4.4,     round(Int, 6.5 * 6.5 / 2.7), 2.7 / 6.5,      round(Int, 6.7 * 6.7 / 2.8), 2.8 / 6.7,      6.0, 4.5, 3.0,      0.24, 0.3, 0.36,    1.0, 0.33),
        # AdV
        Virus(round(Int, 5.6 * 5.6 / 1.3), 1.3 / 5.6,     round(Int, 8.0 * 8.0 / 5.6), 5.6 / 8.0,      round(Int, 9.0 * 9.0 / 6.3), 6.3 / 9.0,      4.1, 3.1, 2.1,      0.15, 0.19, 0.23,   1.0, 0.33),
        # PIV
        Virus(round(Int, 2.6 * 2.6 / 0.85), 0.85 / 2.6,   round(Int, 7.0 * 7.0 / 2.9), 2.9 / 7.0,      round(Int, 8.0 * 8.0 / 3.4), 3.4 / 8.0,      4.8, 3.6, 2.4,      0.16, 0.2, 0.24,    1.0, 0.33),
        # CoV
        Virus(round(Int, 3.2 * 3.2 / 0.44), 0.44 / 3.2,   round(Int, 6.5 * 6.5 / 4.5), 4.5 / 6.5,      round(Int, 7.5 * 7.5 / 5.2), 5.2 / 7.5,      4.9, 3.7, 2.5,      0.21, 0.26, 0.32,   1.0, 0.33)]

    # Число домохозяйств каждого типа по муниципалитетам
    district_households = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "district_households.csv"))))
    # Число людей в каждой возрастной группе по муниципалитетам
    district_people = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "district_people.csv"))))
    # Число людей в домохозяйствах по муниципалитетам
    district_people_households = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "district_people_households.csv"))))
    # Распределение вирусов в течение года
    etiology = get_etiology()
    # Температура воздуха, начиная с 1 января
    temperature = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "temperature.csv"))))[1, :]

    # Набор агентов
    agents = Array{Agent, 1}(undef, num_agents)

    # Генератор случайных чисел для потоков
    thread_rng = [MersenneTwister(i + run_num * num_threads) for i = 1:num_threads]

    # Координаты домов
    homes_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "homes.csv")))
    # Массив для хранения домохозяйств
    households = Array{Household, 1}(undef, num_households)

    # Координаты детских садов
    kindergarten_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "kindergartens.csv")))
    # Массив для хранения детских садов
    kindergartens = Array{School, 1}(undef, num_kindergartens)
    for i in 1:size(kindergarten_coords_df, 1)
        kindergartens[i] = School(
            1,
            kindergarten_coords_df[i, :dist],
            kindergarten_coords_df[i, :x],
            kindergarten_coords_df[i, :y],
        )
    end

    # Координаты школ
    school_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "schools.csv")))
    # Массив для хранения школ
    schools = Array{School, 1}(undef, num_schools)
    for i in 1:size(school_coords_df, 1)
        schools[i] = School(
            2,
            school_coords_df[i, :dist],
            school_coords_df[i, :x],
            school_coords_df[i, :y],
        )
    end

    # Координаты вузов
    college_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "colleges.csv")))
    # Массив для хранения институтов
    colleges = Array{School, 1}(undef, num_colleges)
    for i in 1:size(college_coords_df, 1)
        colleges[i] = School(
            3,
            college_coords_df[i, :dist],
            college_coords_df[i, :x],
            college_coords_df[i, :y],
        )
    end

    # Массив для хранения фирм
    workplaces = Workplace[]

    # Заболеваемость различными вирусами в разных возрастных группах за рассматриваемые года
    num_infected_age_groups_viruses = get_incidence(etiology, is_one_mean_year_modeled, flu_starting_index, true)
    # Заболеваемость различными вирусами в разных возрастных группах за предыдущий год
    num_infected_age_groups_viruses_prev = get_incidence(etiology, false, 1, false)

    for virus_id in eachindex(viruses)
        num_infected_age_groups_viruses_prev[:, virus_id, 1] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[1]) * (1 - isolation_probabilities_day_2[1]) * (1 - isolation_probabilities_day_3[1]))
        num_infected_age_groups_viruses_prev[:, virus_id, 2] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[2]) * (1 - isolation_probabilities_day_2[2]) * (1 - isolation_probabilities_day_3[2]))
        num_infected_age_groups_viruses_prev[:, virus_id, 3] ./= viruses[virus_id].symptomatic_probability_teenager * (1 - (1 - isolation_probabilities_day_1[3]) * (1 - isolation_probabilities_day_2[3]) * (1 - isolation_probabilities_day_3[3]))
        num_infected_age_groups_viruses_prev[:, virus_id, 4] ./= viruses[virus_id].symptomatic_probability_adult * (1 - (1 - isolation_probabilities_day_1[4]) * (1 - isolation_probabilities_day_2[4]) * (1 - isolation_probabilities_day_3[4]))
    end

    # Создание популяции
    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id],
            agents, households, viruses, num_infected_age_groups_viruses_prev, isolation_probabilities_day_1,
            isolation_probabilities_day_2, isolation_probabilities_day_3, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people, district_people_households)
    end

    # Установление связей между агентами
    @time set_connections(
        agents, households, kindergartens, schools, colleges,
        workplaces, thread_rng, num_threads, homes_coords_df,
        firm_min_size, firm_max_size, work_num_barabasi_albert_attachments,
        school_num_barabasi_albert_attachments)

    println("Simulation")

    population_size = 10
    num_parents = 5

    # points = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "output", "tables", "swarm", "parameters_swarm.csv"), header = false)))
    # Латинский гиперкуб
    latin_hypercube_plan, _ = LHCoptim(population_size, 4, 200)

    # Интервалы значений параметров
    points = scaleLHC(latin_hypercube_plan, [
        (0.02, 0.2), # β
        (5, 25), # c
        (0.01, 0.05), # γ
        (1, 50), # I0
    ])

    run_num = 1

    β_parameter_array = points[:, 1]
    c_parameter_array = points[:, 2]
    γ_parameter_array = points[:, 3]
    I0_parameter_array = points[:, 4]

    for k = 1:population_size
        # Reset
        for j in 1:length(agents)
            if j <= I0_parameter_array[k] # I0
                agents[j] = Infected
            else
                agents[j] = Susceptible
            end
        end
        nMAE = run_model(agents, nsteps, δt, β_parameter_array[k], c_parameter_array[k], γ_parameter_array[k])

        save(joinpath(@__DIR__, "ga", "results_$(run_num).jld"),
            "nMAE", nMAE,
            "β_parameter", β_parameter_array[k],
            "c_parameter", c_parameter_array[k],
            "γ_parameter", γ_parameter_array[k],
            "I0_parameter", I0_parameter_array[k],
        )
        run_num += 1
    end

    errors = zeros(Float64, population_size)

    for curr_run = 1:num_ga_runs
        println("curr_num = $(curr_run)")
        for p = 1:population_size
            # Reset
            for i in 1:length(agents)
                if i <= I0_parameter_array[p] # I0
                    agents[i] = Infected
                else
                    agents[i] = Susceptible
                end
            end
            errors[p] = run_model(agents, nsteps, δt, β_parameter_array[p], c_parameter_array[p], γ_parameter_array[p])
        end
        # println(errors)
        # println(errors)
        # return
        # β_parameter_selected = [selection(β_parameter_array, errors) for _ in 1:population_size]
        mating_pool_indecies = selection(population_size, errors, num_parents)
        sum_of_errors = 0.0
        for mating_index in mating_pool_indecies
            sum_of_errors += errors[mating_index]
        end
        # create the next generation
        β_parameter_children = []
        c_parameter_children = []
        γ_parameter_children = []
        I0_parameter_children = []
        for k = 1:population_size
            rand_num = rand(Float64)
            errors_cumulative = errors[mating_pool_indecies[1]]
            p1_mating_index = 1
            for mating_index in mating_pool_indecies[2:end]
                if rand_num < errors_cumulative / sum_of_errors
                    break
                end
                p1_mating_index += 1
                errors_cumulative += errors[mating_index]
            end
            
            rand_num = rand(Float64)
            errors_cumulative = errors[mating_pool_indecies[1]]
            p2_mating_index = 1
            for mating_index in mating_pool_indecies[2:end]
                if p2_mating_index != p1_mating_index && rand_num < errors_cumulative / sum_of_errors
                    break
                end
                p2_mating_index += 1
                errors_cumulative += errors[mating_index]
            end
            
            for c in crossover(
                [β_parameter_array[mating_pool_indecies[p1_mating_index]], c_parameter_array[mating_pool_indecies[p1_mating_index]], γ_parameter_array[mating_pool_indecies[p1_mating_index]], I0_parameter_array[mating_pool_indecies[p1_mating_index]]],
                [β_parameter_array[mating_pool_indecies[p2_mating_index]], c_parameter_array[mating_pool_indecies[p2_mating_index]], γ_parameter_array[mating_pool_indecies[p2_mating_index]], I0_parameter_array[mating_pool_indecies[p2_mating_index]]],
            )
                mutation(c)
                push!(β_parameter_children, c[1])
                push!(c_parameter_children, c[2])
                push!(γ_parameter_children, c[3])
                push!(I0_parameter_children, c[4])
            end
        end
        β_parameter_array = copy(β_parameter_children)
        c_parameter_array = copy(c_parameter_children)
        γ_parameter_array = copy(γ_parameter_children)
        I0_parameter_array = copy(I0_parameter_children)
        for k = 1:population_size
            # Reset
            for j in 1:length(agents)
                if j <= I0_parameter_array[k] # I0
                    agents[j] = Infected
                else
                    agents[j] = Susceptible
                end
            end
            nMAE = run_model(agents, nsteps, δt, β_parameter_array[k], c_parameter_array[k], γ_parameter_array[k])

            save(joinpath(@__DIR__, "ga", "results_$(run_num).jld"),
                "nMAE", nMAE,
                "β_parameter", β_parameter_array[k],
                "c_parameter", c_parameter_array[k],
                "γ_parameter", γ_parameter_array[k],
                "I0_parameter", I0_parameter_array[k],
            )
            run_num += 1
        end
    end
end

run_ga_model()
