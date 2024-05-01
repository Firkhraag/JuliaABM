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

function selection(
    pop_size::Int,
    errors::Vector{Float64},
    num_parents::Int,
    k::Int = 2
)::Vector{Int}
    mating_pool_indicies = Int[]
    # Tournament selection
    for i = 1:num_parents
        tournament_indicies = rand(setdiff(vec(1:pop_size), mating_pool_indicies), k)
        pop_el_selected_num = tournament_indicies[1]
        for pop_el_num in tournament_indicies[2:end]
            if errors[pop_el_num] < errors[pop_el_selected_num]
                pop_el_selected_num = pop_el_num
            end
        end
        push!(mating_pool_indicies, pop_el_selected_num)
    end
    # Other - Proportional Roulette Wheel Selection
    return mating_pool_indicies
end

function crossover(
    p1_parameters,
    p2_parameters,
    cross_rate::Float64 = 0.8
)
    # One-point crossover
    if rand(Float64) < cross_rate
        split_pos = rand(1:(length(p1_parameters) - 1))
        c1_parameters = vcat(p1_parameters[1:split_pos], p2_parameters[(split_pos + 1):end])
        c2_parameters = vcat(p2_parameters[1:split_pos], p1_parameters[(split_pos + 1):end])
        return c1_parameters, c2_parameters
    end
    return p1_parameters, p2_parameters
end

function mutation(
    parameters,
    mut_rate::Float64 = 0.1,
    disturbance::Float64 = 0.1,
)
    if rand(Float64) < mut_rate
        parameters[1] += rand(Normal(0, disturbance * 0.9))
    end
    for j = 1:num_viruses
        if rand(Float64) < mut_rate
            parameters[1 + j] += rand(Normal(0, disturbance * 6.0))
        end
        if rand(Float64) < mut_rate
            parameters[8 + j] += -rand(Normal(0, disturbance * (-parameters[8 + j])))
        end
        if rand(Float64) < mut_rate
            parameters[15 + j] += rand(Normal(0, disturbance * (parameters[15 + j])))
        end
    end
    for j = 1:4
        if rand(Float64) < mut_rate
            parameters[22 + j] += rand(Normal(0, disturbance * (parameters[22 + j])))
        end
    end
    # Ограничения на область значений параметров
    if parameters[1] < 0.1 || parameters[1] > 1
        parameters[1] = rand(Uniform(0.1, 1.0))
    end
    for j = 1:num_viruses
        if parameters[1 + j] < 1 || parameters[1 + j] > 7
            parameters[1 + j] = rand(Uniform(1.0, 7.0))
        end
        if parameters[8 + j] < -1 || parameters[8 + j] > -0.01
            parameters[8 + j] = rand(Uniform(-1.0, -0.01))
        end
        if parameters[15 + j] < 30 || parameters[15 + j] > 365
            parameters[15 + j] = rand(Uniform(30.0, 365.0))
        end
    end
    if parameters[23] < 0.0008 || parameters[23] > 0.0012
        parameters[23] = rand(Uniform(0.0008, 0.0012))
    end
    if parameters[24] < 0.0005 || parameters[24] > 0.001
        parameters[24] = rand(Uniform(0.0005, 0.001))
    end
    if parameters[25] < 0.0002 || parameters[25] > 0.0005
        parameters[25] = rand(Uniform(0.0002, 0.0005))
    end
    if parameters[26] < 0.000005 || parameters[26] > 0.00001
        parameters[26] = rand(Uniform(0.000005, 0.00001))
    end
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

    num_parameters = 26

    population_size = 10
    num_parents = 5
    num_ga_runs = 25

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, population_size)
    best_error = 9.0e12
    error_population = zeros(Float64, population_size) .+ 9.0e12
    error_population_children = zeros(Float64, population_size) .+ 9.0e12

    duration_parameter_array = Array{Float64, 1}(undef, population_size)
    susceptibility_parameters_array = Array{Vector{Float64}, 1}(undef, population_size)
    temperature_parameters_array = Array{Vector{Float64}, 1}(undef, population_size)
    mean_immunity_durations_array = Array{Vector{Float64}, 1}(undef, population_size)
    random_infection_probabilities_array = Array{Vector{Float64}, 1}(undef, population_size)

    # В случае, если значения загружаются из таблицы
    # points = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "output", "tables", "ga", "parameters_ga.csv"), header = false)))

    # # Латинский гиперкуб
    # latin_hypercube_plan, _ = LHCoptim(population_size, num_parameters, 500)

    # # Интервалы значений параметров
    # points = scaleLHC(latin_hypercube_plan, [
    #     (0.1, 1.0), # duration_parameter
    #     (1.0, 7.0), # susceptibility_parameters
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (-1.0, -0.01), # temperature_parameters
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (30, 365), # mean_immunity_durations
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (0.0008, 0.0012), # random_infection_probabilities
    #     (0.0005, 0.001),
    #     (0.0002, 0.0005),
    #     (0.000005, 0.00001),
    # ])
    # writedlm(joinpath(@__DIR__, "..", "output", "tables", "ga", "parameters_ga.csv"), points, ',')

    # for i = 1:population_size
    #     duration_parameter_array[i] = points[i, 1]
    #     susceptibility_parameters_array[i] = copy(points[i, 2:8])
    #     temperature_parameters_array[i] = copy(points[i, 9:15])
    #     mean_immunity_durations_array[i] = copy(points[i, 16:22])
    #     random_infection_probabilities_array[i] = copy(points[i, 23:26])
    #     for v = 1:length(viruses)
    #         viruses[v].mean_immunity_duration = points[i, 15 + v]
    #         viruses[v].immunity_duration_sd = points[i, 15 + v] * 0.33
    #     end

    #     # Если уже посчитано
    #     for p = 1:population_size
    #         incidence_arr[p] = load(joinpath(@__DIR__, "..", "output", "tables", "ga", "0", "results_$(p).jld"))["observed_cases"]
    #     end

    #     # Сбрасываем состояние синтетической популяции до начального
    #     # @threads for thread_id in 1:num_threads
    #     #     reset_agent_states(
    #     #         agents,
    #     #         start_agent_ids[thread_id],
    #     #         end_agent_ids[thread_id],
    #     #         viruses,
    #     #         num_infected_age_groups_viruses_prev,
    #     #         isolation_probabilities_day_1,
    #     #         isolation_probabilities_day_2,
    #     #         isolation_probabilities_day_3,
    #     #         thread_rng[thread_id],
    #     #     )
    #     # end

    #     # Если не посчитано
    #     # @time incidence_arr[i], activities_infections, rt, num_schools_closed = run_simulation(
    #     #     num_threads, thread_rng, agents, viruses, households, schools, duration_parameter_array[i],
    #     #     susceptibility_parameters_array[i], temperature_parameters_array[i], temperature,
    #     #     mean_household_contact_durations, household_contact_duration_sds,
    #     #     other_contact_duration_shapes, other_contact_duration_scales,
    #     #     isolation_probabilities_day_1, isolation_probabilities_day_2,
    #     #     isolation_probabilities_day_3, random_infection_probabilities_array[i],
    #     #     recovered_duration_mean, recovered_duration_sd, num_years, false)

    #     error_population[i] = sum((incidence_arr[i] - num_infected_age_groups_viruses).^2)

    #     # Если не посчитано
    #     # save(joinpath(@__DIR__, "..", "output", "tables", "ga", "0", "results_$(i).jld"),
    #     #     "observed_cases", incidence_arr[i],
    #     #     "duration_parameter", duration_parameter_array[i],
    #     #     "susceptibility_parameters", susceptibility_parameters_array[i],
    #     #     "temperature_parameters", temperature_parameters_array[i],
    #     #     "mean_immunity_durations", mean_immunity_durations_array[i],
    #     #     "random_infection_probabilities", random_infection_probabilities_array[i])
    # end

    for j = 1:population_size
        temp = load(joinpath(@__DIR__, "..", "output", "tables", "ga", "4", "results_$(j).jld"))["observed_cases"]
        error_population[j] = sum((temp - num_infected_age_groups_viruses).^2)
        duration_parameter_array[j] = load(joinpath(@__DIR__, "..", "output", "tables", "ga", "4", "results_$(j).jld"))["duration_parameter"]
        susceptibility_parameters_array[j] = load(joinpath(@__DIR__, "..", "output", "tables", "ga", "4", "results_$(j).jld"))["susceptibility_parameters"]
        temperature_parameters_array[j] = load(joinpath(@__DIR__, "..", "output", "tables", "ga", "4", "results_$(j).jld"))["temperature_parameters"]
        mean_immunity_durations_array[j] = load(joinpath(@__DIR__, "..", "output", "tables", "ga", "4", "results_$(j).jld"))["mean_immunity_durations"]
        random_infection_probabilities_array[j] = load(joinpath(@__DIR__, "..", "output", "tables", "ga", "4", "results_$(j).jld"))["random_infection_probabilities"]
    end

    # println(error_population)
    # println(duration_parameter_array)
    # # println(mean_immunity_durations_array)
    # return

    for curr_run = 5:num_ga_runs
    # for curr_run = 1:num_ga_runs
        println("Error pop = $(error_population)")
        mating_pool_indicies = selection(population_size, error_population, num_parents)
        println("mating pool = $(mating_pool_indicies)")
        # create the next generation
        duration_parameter_children = Float64[]
        susceptibility_parameters_children = Vector{Float64}[]
        temperature_parameters_children = Vector{Float64}[]
        mean_immunity_durations_children = Vector{Float64}[]
        random_infection_probabilities_children = Vector{Float64}[]
        for i = 1:(population_size / 2)
            p1_mating_index = rand(mating_pool_indicies)
            p2_mating_index = rand(mating_pool_indicies)
            while p1_mating_index == p2_mating_index
                p2_mating_index = rand(mating_pool_indicies)
            end

            for c in crossover(
                [duration_parameter_array[p1_mating_index], susceptibility_parameters_array[p1_mating_index][1], susceptibility_parameters_array[p1_mating_index][2], susceptibility_parameters_array[p1_mating_index][3], susceptibility_parameters_array[p1_mating_index][4], susceptibility_parameters_array[p1_mating_index][5], susceptibility_parameters_array[p1_mating_index][6], susceptibility_parameters_array[p1_mating_index][7], temperature_parameters_array[p1_mating_index][1], temperature_parameters_array[p1_mating_index][2], temperature_parameters_array[p1_mating_index][3], temperature_parameters_array[p1_mating_index][4], temperature_parameters_array[p1_mating_index][5], temperature_parameters_array[p1_mating_index][6], temperature_parameters_array[p1_mating_index][7], mean_immunity_durations_array[p1_mating_index][1], mean_immunity_durations_array[p1_mating_index][2], mean_immunity_durations_array[p1_mating_index][3], mean_immunity_durations_array[p1_mating_index][4], mean_immunity_durations_array[p1_mating_index][5], mean_immunity_durations_array[p1_mating_index][6], mean_immunity_durations_array[p1_mating_index][7], random_infection_probabilities_array[p1_mating_index][1], random_infection_probabilities_array[p1_mating_index][2], random_infection_probabilities_array[p1_mating_index][3], random_infection_probabilities_array[p1_mating_index][4]],
                [duration_parameter_array[p2_mating_index], susceptibility_parameters_array[p2_mating_index][1], susceptibility_parameters_array[p2_mating_index][2], susceptibility_parameters_array[p2_mating_index][3], susceptibility_parameters_array[p2_mating_index][4], susceptibility_parameters_array[p2_mating_index][5], susceptibility_parameters_array[p2_mating_index][6], susceptibility_parameters_array[p2_mating_index][7], temperature_parameters_array[p2_mating_index][1], temperature_parameters_array[p2_mating_index][2], temperature_parameters_array[p2_mating_index][3], temperature_parameters_array[p2_mating_index][4], temperature_parameters_array[p2_mating_index][5], temperature_parameters_array[p2_mating_index][6], temperature_parameters_array[p2_mating_index][7], mean_immunity_durations_array[p2_mating_index][1], mean_immunity_durations_array[p2_mating_index][2], mean_immunity_durations_array[p2_mating_index][3], mean_immunity_durations_array[p2_mating_index][4], mean_immunity_durations_array[p2_mating_index][5], mean_immunity_durations_array[p2_mating_index][6], mean_immunity_durations_array[p2_mating_index][7], random_infection_probabilities_array[p2_mating_index][1], random_infection_probabilities_array[p2_mating_index][2], random_infection_probabilities_array[p2_mating_index][3], random_infection_probabilities_array[p2_mating_index][4]],
            )
                mutation(c)

                # for k = 1:length(duration_parameter_children)
                #     if abs(c[1] - duration_parameter_children[k]) < 0.09 && abs(c[2] - susceptibility_parameters_children[k][1]) < 0.6 && abs(c[3] - susceptibility_parameters_children[k][2]) < 0.6 && abs(c[4] - susceptibility_parameters_children[k][3]) < 0.6 && abs(c[5] - susceptibility_parameters_children[k][4]) < 0.6 && abs(c[6] - susceptibility_parameters_children[k][5]) < 0.6 && abs(c[7] - susceptibility_parameters_children[k][6]) < 0.6 && abs(c[8] - susceptibility_parameters_children[k][7]) < 0.6 && abs(c[9] - temperature_parameters_children[k][1]) < 0.09 && abs(c[10] - temperature_parameters_children[k][2]) < 0.09 && abs(c[11] - temperature_parameters_children[k][3]) < 0.09 && abs(c[12] - temperature_parameters_children[k][4]) < 0.09 && abs(c[13] - temperature_parameters_children[k][5]) < 0.09 && abs(c[14] - temperature_parameters_children[k][6]) < 0.09 && abs(c[15] - temperature_parameters_children[k][7]) < 0.09 && abs(c[16] - mean_immunity_durations_children[k][1]) < 33 && abs(c[17] - mean_immunity_durations_children[k][2]) < 33 && abs(c[18] - mean_immunity_durations_children[k][3]) < 33 && abs(c[19] - mean_immunity_durations_children[k][4]) < 33 && abs(c[20] - mean_immunity_durations_children[k][5]) < 33 && abs(c[21] - mean_immunity_durations_children[k][6]) < 33 && abs(c[22] - mean_immunity_durations_children[k][7]) < 33 && abs(c[23] - random_infection_probabilities_children[k][1]) < 0.00004 && abs(c[24] - random_infection_probabilities_children[k][2]) < 0.00005 && abs(c[25] - random_infection_probabilities_children[k][3]) < 0.00003 && abs(c[26] - random_infection_probabilities_children[k][4]) < 5e-7
                #         println("Close children")
                #         mutation(c, 1.0)
                #         break
                #     end
                # end

                push!(duration_parameter_children, c[1])
                push!(susceptibility_parameters_children, copy(c[2:8]))
                push!(temperature_parameters_children, copy(c[9:15]))
                push!(mean_immunity_durations_children, copy(c[16:22]))
                push!(random_infection_probabilities_children, copy(c[23:26]))
            end
        end

        for i = 1:population_size
            for j = 1:num_viruses
                viruses[j].mean_immunity_duration = mean_immunity_durations_children[i][j]
                viruses[j].immunity_duration_sd = mean_immunity_durations_children[i][j] * 0.33
            end

            # Сбрасываем состояние синтетической популяции до начального
            @threads for thread_id in 1:num_threads
                reset_agent_states(
                    agents,
                    start_agent_ids[thread_id],
                    end_agent_ids[thread_id],
                    viruses,
                    num_infected_age_groups_viruses_prev,
                    isolation_probabilities_day_1,
                    isolation_probabilities_day_2,
                    isolation_probabilities_day_3,
                    thread_rng[thread_id],
                )
            end

            # Моделируем заболеваемость
            @time observed_num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
                num_threads, thread_rng, agents, viruses, households, schools, duration_parameter_children[i],
                susceptibility_parameters_children[i], temperature_parameters_children[i], temperature,
                mean_household_contact_durations, household_contact_duration_sds,
                other_contact_duration_shapes, other_contact_duration_scales,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, random_infection_probabilities_children[i],
                recovered_duration_mean, recovered_duration_sd, num_years, false)

            # Если рассматривается 1 год
            if is_one_mean_year_modeled
                observed_num_infected_age_groups_viruses_mean = observed_num_infected_age_groups_viruses[1:52, :, :]
                for i = 2:num_years
                    for j = 1:52
                        observed_num_infected_age_groups_viruses_mean[j, :, :] += observed_num_infected_age_groups_viruses[(i - 1) * 52 + j, :, :]
                    end
                end
                observed_num_infected_age_groups_viruses_mean ./= num_years
                error_population_children[i] = sum((observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses).^2)
            else
                error_population_children[i] = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses).^2)
            end

            save(joinpath(@__DIR__, "..", "output", "tables", "ga", "$(curr_run)", "results_$(i).jld"),
                "observed_cases", observed_num_infected_age_groups_viruses,
                "duration_parameter", duration_parameter_children[i],
                "susceptibility_parameters", susceptibility_parameters_children[i],
                "temperature_parameters", temperature_parameters_children[i],
                "mean_immunity_durations", mean_immunity_durations_children[i],
                "random_infection_probabilities", random_infection_probabilities_children[i])
        end

        # error_population_concatenated = vcat(error_population, error_population_children)
        # if argmin(error_population_concatenated) < 11
        #     max_error_arg = argmax(error_population_children)
        #     min_error_arg = argmax(error_population)
        #     duration_parameter_children[max_error_arg] = duration_parameter_array[min_error_arg]
        #     susceptibility_parameters_children[max_error_arg] = copy(susceptibility_parameters_array[min_error_arg])
        #     temperature_parameters_children[max_error_arg] = copy(temperature_parameters_array[min_error_arg])
        #     mean_immunity_durations_children[max_error_arg] = copy(mean_immunity_durations_array[min_error_arg])
        #     random_infection_probabilities_children[max_error_arg] = copy(random_infection_probabilities_array[min_error_arg])
        #     error_population_children[max_error_arg] = error_population[min_error_arg]
        # end

        duration_parameter_array = copy(duration_parameter_children)
        susceptibility_parameters_array = deepcopy(susceptibility_parameters_children)
        temperature_parameters_array = deepcopy(temperature_parameters_children)
        mean_immunity_durations_array = deepcopy(mean_immunity_durations_children)
        random_infection_probabilities_array = deepcopy(random_infection_probabilities_children)
        error_population = copy(error_population_children)

        # args = [a[1] for a in arg_n_smallest_values(vcat(error_population, error_population_children), population_size)]

        # duration_parameter_concatenated = vcat(duration_parameter_array, duration_parameter_children)
        # susceptibility_parameters_concatenated = vcat(susceptibility_parameters_array, susceptibility_parameters_children)
        # temperature_parameters_concatenated = vcat(temperature_parameters_array, temperature_parameters_children)
        # mean_immunity_durations_concatenated = vcat(mean_immunity_durations_array, mean_immunity_durations_children)
        # random_infection_probabilities_concatenated = vcat(random_infection_probabilities_array, random_infection_probabilities_children)
        # error_population_concatenated = vcat(error_population, error_population_children)

        # for i = 1:population_size
        #     duration_parameter_array[i] = duration_parameter_concatenated[args[i]]
        #     susceptibility_parameters_array[i] = copy(susceptibility_parameters_concatenated[args[i]])
        #     temperature_parameters_array[i] = copy(temperature_parameters_concatenated[args[i]])
        #     mean_immunity_durations_array[i] = copy(mean_immunity_durations_concatenated[args[i]])
        #     random_infection_probabilities_array[i] = copy(random_infection_probabilities_concatenated[args[i]])
        #     error_population[i] = error_population_concatenated[args[i]]
        # end
    end
end

run_ga_model()
