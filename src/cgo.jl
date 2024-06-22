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

function check_bounds(
    parameters::Vector{Float64},
)
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

function run_cgo_model()
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

    seeds_size = 10
    num_cgo_runs = 5

    best_error = 9.0e12

    incidence_seeds_arr = Array{Array{Float64, 3}, 1}(undef, seeds_size)
    error_seeds = Array{Float64, 1}(undef, seeds_size)
    duration_parameter_seeds_array = Array{Float64, 1}(undef, seeds_size)
    susceptibility_parameters_seeds_array = Array{Vector{Float64}, 1}(undef, seeds_size)
    temperature_parameters_seeds_array = Array{Vector{Float64}, 1}(undef, seeds_size)
    mean_immunity_durations_seeds_array = Array{Vector{Float64}, 1}(undef, seeds_size)
    random_infection_probabilities_seeds_array = Array{Vector{Float64}, 1}(undef, seeds_size)

    incidence_offsprings_arr = Array{Array{Float64, 3}, 2}(undef, seeds_size, 4)
    error_offsprings = Array{Float64, 2}(undef, seeds_size, 4)
    duration_parameter_offsprings_array = Array{Float64, 2}(undef, seeds_size, 4)
    susceptibility_parameters_offsprings_array = Array{Vector{Float64}, 2}(undef, seeds_size, 4)
    temperature_parameters_offsprings_array = Array{Vector{Float64}, 2}(undef, seeds_size, 4)
    mean_immunity_durations_offsprings_array = Array{Vector{Float64}, 2}(undef, seeds_size, 4)
    random_infection_probabilities_offsprings_array = Array{Vector{Float64}, 2}(undef, seeds_size, 4)

    duration_parameter_best = 0.0
    susceptibility_parameters_best = zeros(Float64, num_viruses)
    temperature_parameters_best = zeros(Float64, num_viruses)
    mean_immunity_durations_best = zeros(Float64, num_viruses)
    random_infection_probabilities_best = zeros(Float64, 4)

    duration_parameter_mean_group = 0.0
    susceptibility_parameters_mean_group = zeros(Float64, num_viruses)
    temperature_parameters_mean_group = zeros(Float64, num_viruses)
    mean_immunity_durations_mean_group = zeros(Float64, num_viruses)
    random_infection_probabilities_mean_group = zeros(Float64, 4)

    for p = 1:seeds_size
        incidence_seeds_arr[p] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "10", "results_$(p).jld"))["observed_cases"]
        error_seeds[p] = sum((incidence_seeds_arr[p] - num_infected_age_groups_viruses).^2)

        duration_parameter_seeds_array[p] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "10", "results_$(p).jld"))["duration_parameter"]
        susceptibility_parameters_seeds_array[p] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "10", "results_$(p).jld"))["susceptibility_parameters"]
        temperature_parameters_seeds_array[p] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "10", "results_$(p).jld"))["temperature_parameters"]
        mean_immunity_durations_seeds_array[p] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "10", "results_$(p).jld"))["mean_immunity_durations"]
        random_infection_probabilities_seeds_array[p] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "10", "results_$(p).jld"))["random_infection_probabilities"]

        if error_seeds[p] < best_error
            best_error = error_seeds[p]

            duration_parameter_best = duration_parameter_seeds_array[p]
            susceptibility_parameters_best = susceptibility_parameters_seeds_array[p]
            temperature_parameters_best = mean_immunity_durations_seeds_array[p]
            mean_immunity_durations_best = mean_immunity_durations_seeds_array[p]
            random_infection_probabilities_best = random_infection_probabilities_seeds_array[p]
        end
    end

    for curr_run = 1:num_cgo_runs
        for seed = 1:seeds_size
            group_num = rand(1:seeds_size)
            el_nums = zeros(Int, group_num)
            for i = 1:group_num
                rand_num = rand(1:seeds_size)
                while rand_num in el_nums
                    rand_num = rand(1:seeds_size)
                end
                el_nums[i] = rand_num
            end

            duration_parameter_mean_group = mean(duration_parameter_seeds_array[el_nums])
            for i = 1:num_viruses
                susceptibility_parameters_mean_group[i] = 0.0
                for el in el_nums
                    susceptibility_parameters_mean_group[i] += susceptibility_parameters_seeds_array[el][i]
                end
                susceptibility_parameters_mean_group[i] /= length(el_nums)

                temperature_parameters_mean_group[i] = 0.0
                for el in el_nums
                    temperature_parameters_mean_group[i] += temperature_parameters_seeds_array[el][i]
                end
                temperature_parameters_mean_group[i] /= length(el_nums)

                mean_immunity_durations_mean_group[i] = 0.0
                for el in el_nums
                    mean_immunity_durations_mean_group[i] += mean_immunity_durations_seeds_array[el][i]
                end
                mean_immunity_durations_mean_group[i] /= length(el_nums)
            end
            for i = 1:4
                random_infection_probabilities_mean_group[i] = 0.0
                for el in el_nums
                    random_infection_probabilities_mean_group[i] += random_infection_probabilities_seeds_array[el][i]
                end
                random_infection_probabilities_mean_group[i] /= length(el_nums)
            end

            # I = rand([1, 2], 1, 12)
            # Ir = rand([0, 1], 1, 5)

            # IrB = Bool.(Ir)
            # Ir2 = Int.(.!IrB)

            I = rand(0:1, 6) 
            Ir = rand(0:1, 2)

            alpha = Array{Vector{Float64}, 1}(undef, 4)
            alpha[1] = rand(num_parameters)
            alpha[2] = 2 * rand(num_parameters)
            alpha[3] = Ir[1] .* rand(num_parameters) .+ 1
            alpha[4] = (Ir[2] .* rand(num_parameters) .+ (1 - Ir[2]))

            # alpha = Array{Vector{Float64}, 1}(undef, 4)
            # alpha[1] = rand(num_parameters)
            # alpha[2] = 2 * rand(num_parameters) - 1

            # I_delta = rand([0, 1], num_parameters)
            # alpha[3] = I_delta .* rand(num_parameters) .+ 1

            # I_e = rand([0, 1], num_parameters)
            # I_e_B = Bool.(I_e)
            # I_e2 = Int.(.!I_e_B)
            # alpha[4] = I_e .* rand(num_parameters) + I_e2

            ii = rand(1:4, 1, 3)
            selected_alpha = alpha[ii]

            duration_parameter_offsprings_array[seed, 1] = duration_parameter_seeds_array[seed] + selected_alpha[1][1] * (I[1] * duration_parameter_best - I[2] * duration_parameter_mean_group)
            susceptibility_parameters_offsprings_array[seed, 1] = susceptibility_parameters_seeds_array[seed] + selected_alpha[1][2:8] .* (I[1] * susceptibility_parameters_best - I[2] * susceptibility_parameters_mean_group)
            temperature_parameters_offsprings_array[seed, 1] = temperature_parameters_seeds_array[seed] + selected_alpha[1][9:15] .* (I[1] * temperature_parameters_best - I[2] * temperature_parameters_mean_group)
            mean_immunity_durations_offsprings_array[seed, 1] = mean_immunity_durations_seeds_array[seed] + selected_alpha[1][16:22] .* (I[1] * mean_immunity_durations_best - I[2] * mean_immunity_durations_mean_group)
            random_infection_probabilities_offsprings_array[seed, 1] = random_infection_probabilities_seeds_array[seed] + selected_alpha[1][23:26] .* (I[1] * random_infection_probabilities_best - I[2] * random_infection_probabilities_mean_group)

            c1 = [duration_parameter_offsprings_array[seed, 1], susceptibility_parameters_offsprings_array[seed, 1][1], susceptibility_parameters_offsprings_array[seed, 1][2], susceptibility_parameters_offsprings_array[seed, 1][3], susceptibility_parameters_offsprings_array[seed, 1][4], susceptibility_parameters_offsprings_array[seed, 1][5], susceptibility_parameters_offsprings_array[seed, 1][6], susceptibility_parameters_offsprings_array[seed, 1][7], temperature_parameters_offsprings_array[seed, 1][1], temperature_parameters_offsprings_array[seed, 1][2], temperature_parameters_offsprings_array[seed, 1][3], temperature_parameters_offsprings_array[seed, 1][4], temperature_parameters_offsprings_array[seed, 1][5], temperature_parameters_offsprings_array[seed, 1][6], temperature_parameters_offsprings_array[seed, 1][7], mean_immunity_durations_offsprings_array[seed, 1][1], mean_immunity_durations_offsprings_array[seed, 1][2], mean_immunity_durations_offsprings_array[seed, 1][3], mean_immunity_durations_offsprings_array[seed, 1][4], mean_immunity_durations_offsprings_array[seed, 1][5], mean_immunity_durations_offsprings_array[seed, 1][6], mean_immunity_durations_offsprings_array[seed, 1][7], random_infection_probabilities_offsprings_array[seed, 1][1], random_infection_probabilities_offsprings_array[seed, 1][2], random_infection_probabilities_offsprings_array[seed, 1][3], random_infection_probabilities_offsprings_array[seed, 1][4]]
            check_bounds(c1)

            for j = 1:num_viruses
                viruses[j].mean_immunity_duration = c1[15 + j]
                viruses[j].immunity_duration_sd = c1[15 + j] * 0.33
            end
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
            @time incidence_offsprings_arr[seed, 1], _, __, ___ = run_simulation(
                num_threads, thread_rng, agents, viruses, households, schools, c1[1],
                c1[2:8], c1[9:15], temperature, mean_household_contact_durations, household_contact_duration_sds,
                other_contact_duration_shapes, other_contact_duration_scales,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, c1[23:26], recovered_duration_mean, recovered_duration_sd, num_years, false)

            # Если рассматривается 1 год
            if is_one_mean_year_modeled
                observed_num_infected_age_groups_viruses_mean = incidence_offsprings_arr[seed, 1][1:52, :, :]
                for i = 2:num_years
                    for j = 1:52
                        observed_num_infected_age_groups_viruses_mean[j, :, :] += incidence_offsprings_arr[seed, 1][(i - 1) * 52 + j, :, :]
                    end
                end
                observed_num_infected_age_groups_viruses_mean ./= num_years
                error_offsprings[seed, 1] = sum((observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses).^2)
            else
                error_offsprings[seed, 1] = sum(abs.(incidence_offsprings_arr[seed, 1] - num_infected_age_groups_viruses).^2)
            end

            duration_parameter_offsprings_array[seed, 2] = duration_parameter_best + selected_alpha[2][1] .* (I[3] * duration_parameter_mean_group - I[4] * duration_parameter_seeds_array[seed])
            susceptibility_parameters_offsprings_array[seed, 2] = susceptibility_parameters_best + selected_alpha[2][2:8] .* (I[3] * susceptibility_parameters_mean_group - I[4] * susceptibility_parameters_seeds_array[seed])
            temperature_parameters_offsprings_array[seed, 2] = temperature_parameters_best + selected_alpha[2][9:15] .* (I[3] * temperature_parameters_mean_group - I[4] * temperature_parameters_seeds_array[seed])
            mean_immunity_durations_offsprings_array[seed, 2] = mean_immunity_durations_best + selected_alpha[2][16:22] .* (I[3] * mean_immunity_durations_mean_group - I[4] * mean_immunity_durations_seeds_array[seed])
            random_infection_probabilities_offsprings_array[seed, 2] = random_infection_probabilities_best + selected_alpha[2][23:26] .* (I[3] * random_infection_probabilities_mean_group - I[4] * random_infection_probabilities_seeds_array[seed])

            c2 = [duration_parameter_offsprings_array[seed, 2], susceptibility_parameters_offsprings_array[seed, 2][1], susceptibility_parameters_offsprings_array[seed, 2][2], susceptibility_parameters_offsprings_array[seed, 2][3], susceptibility_parameters_offsprings_array[seed, 2][4], susceptibility_parameters_offsprings_array[seed, 2][5], susceptibility_parameters_offsprings_array[seed, 2][6], susceptibility_parameters_offsprings_array[seed, 2][7], temperature_parameters_offsprings_array[seed, 2][1], temperature_parameters_offsprings_array[seed, 2][2], temperature_parameters_offsprings_array[seed, 2][3], temperature_parameters_offsprings_array[seed, 2][4], temperature_parameters_offsprings_array[seed, 2][5], temperature_parameters_offsprings_array[seed, 2][6], temperature_parameters_offsprings_array[seed, 2][7], mean_immunity_durations_offsprings_array[seed, 2][1], mean_immunity_durations_offsprings_array[seed, 2][2], mean_immunity_durations_offsprings_array[seed, 2][3], mean_immunity_durations_offsprings_array[seed, 2][4], mean_immunity_durations_offsprings_array[seed, 2][5], mean_immunity_durations_offsprings_array[seed, 2][6], mean_immunity_durations_offsprings_array[seed, 2][7], random_infection_probabilities_offsprings_array[seed, 2][1], random_infection_probabilities_offsprings_array[seed, 2][2], random_infection_probabilities_offsprings_array[seed, 2][3], random_infection_probabilities_offsprings_array[seed, 2][4]]
            check_bounds(c2)

            for j = 1:num_viruses
                viruses[j].mean_immunity_duration = c2[15 + j]
                viruses[j].immunity_duration_sd = c2[15 + j] * 0.33
            end
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
            @time incidence_offsprings_arr[seed, 2], _, __, ___ = run_simulation(
                num_threads, thread_rng, agents, viruses, households, schools, c2[1],
                c2[2:8], c2[9:15], temperature, mean_household_contact_durations, household_contact_duration_sds,
                other_contact_duration_shapes, other_contact_duration_scales,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, c2[23:26], recovered_duration_mean, recovered_duration_sd, num_years, false)

            # Если рассматривается 1 год
            if is_one_mean_year_modeled
                observed_num_infected_age_groups_viruses_mean = incidence_offsprings_arr[seed, 2][1:52, :, :]
                for i = 2:num_years
                    for j = 1:52
                        observed_num_infected_age_groups_viruses_mean[j, :, :] += incidence_offsprings_arr[seed, 2][(i - 1) * 52 + j, :, :]
                    end
                end
                observed_num_infected_age_groups_viruses_mean ./= num_years
                error_offsprings[seed, 2] = sum((observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses).^2)
            else
                error_offsprings[seed, 2] = sum(abs.(incidence_offsprings_arr[seed, 2] - num_infected_age_groups_viruses).^2)
            end

            duration_parameter_offsprings_array[seed, 3] = duration_parameter_mean_group + selected_alpha[3][1] .* (I[5] * duration_parameter_best - I[6] * duration_parameter_seeds_array[seed])
            susceptibility_parameters_offsprings_array[seed, 3] = susceptibility_parameters_mean_group + selected_alpha[3][2:8] .* (I[5] * susceptibility_parameters_best - I[6] * susceptibility_parameters_seeds_array[seed])
            temperature_parameters_offsprings_array[seed, 3] = temperature_parameters_mean_group + selected_alpha[3][9:15] .* (I[5] * temperature_parameters_best - I[6] * temperature_parameters_seeds_array[seed])
            mean_immunity_durations_offsprings_array[seed, 3] = mean_immunity_durations_mean_group + selected_alpha[3][16:22] .* (I[5] * mean_immunity_durations_best - I[6] * mean_immunity_durations_seeds_array[seed])
            random_infection_probabilities_offsprings_array[seed, 3] = random_infection_probabilities_mean_group + selected_alpha[3][23:26] .* (I[5] * random_infection_probabilities_best - I[6] * random_infection_probabilities_seeds_array[seed])

            c3 = [duration_parameter_offsprings_array[seed, 3], susceptibility_parameters_offsprings_array[seed, 3][1], susceptibility_parameters_offsprings_array[seed, 3][2], susceptibility_parameters_offsprings_array[seed, 3][3], susceptibility_parameters_offsprings_array[seed, 3][4], susceptibility_parameters_offsprings_array[seed, 3][5], susceptibility_parameters_offsprings_array[seed, 3][6], susceptibility_parameters_offsprings_array[seed, 3][7], temperature_parameters_offsprings_array[seed, 3][1], temperature_parameters_offsprings_array[seed, 3][2], temperature_parameters_offsprings_array[seed, 3][3], temperature_parameters_offsprings_array[seed, 3][4], temperature_parameters_offsprings_array[seed, 3][5], temperature_parameters_offsprings_array[seed, 3][6], temperature_parameters_offsprings_array[seed, 3][7], mean_immunity_durations_offsprings_array[seed, 3][1], mean_immunity_durations_offsprings_array[seed, 3][2], mean_immunity_durations_offsprings_array[seed, 3][3], mean_immunity_durations_offsprings_array[seed, 3][4], mean_immunity_durations_offsprings_array[seed, 3][5], mean_immunity_durations_offsprings_array[seed, 3][6], mean_immunity_durations_offsprings_array[seed, 3][7], random_infection_probabilities_offsprings_array[seed, 3][1], random_infection_probabilities_offsprings_array[seed, 3][2], random_infection_probabilities_offsprings_array[seed, 3][3], random_infection_probabilities_offsprings_array[seed, 3][4]]
            check_bounds(c3)

            for j = 1:num_viruses
                viruses[j].mean_immunity_duration = c3[15 + j]
                viruses[j].immunity_duration_sd = c3[15 + j] * 0.33
            end
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
            @time incidence_offsprings_arr[seed, 3], _, __, ___ = run_simulation(
                num_threads, thread_rng, agents, viruses, households, schools, c3[1],
                c3[2:8], c3[9:15], temperature, mean_household_contact_durations, household_contact_duration_sds,
                other_contact_duration_shapes, other_contact_duration_scales,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, c3[23:26], recovered_duration_mean, recovered_duration_sd, num_years, false)

            # Если рассматривается 1 год
            if is_one_mean_year_modeled
                observed_num_infected_age_groups_viruses_mean = incidence_offsprings_arr[seed, 3][1:52, :, :]
                for i = 2:num_years
                    for j = 1:52
                        observed_num_infected_age_groups_viruses_mean[j, :, :] += incidence_offsprings_arr[seed, 3][(i - 1) * 52 + j, :, :]
                    end
                end
                observed_num_infected_age_groups_viruses_mean ./= num_years
                error_offsprings[seed, 3] = sum((observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses).^2)
            else
                error_offsprings[seed, 3] = sum(abs.(incidence_offsprings_arr[seed, 3] - num_infected_age_groups_viruses).^2)
            end

            duration_parameter_offsprings_array[seed, 4] = rand(Uniform(0.1, 1.0))
            susceptibility_parameters_offsprings_array[seed, 4] = [rand(Uniform(1.0, 7.0)) for _ = 1:num_viruses]
            temperature_parameters_offsprings_array[seed, 4] = [rand(Uniform(-1.0, -0.01)) for _ = 1:num_viruses]
            mean_immunity_durations_offsprings_array[seed, 4] = [rand(Uniform(30.0, 365.0)) for _ = 1:num_viruses]

            random_infection_probabilities_offsprings_array[seed, 4] = [rand(Uniform(0.0008, 0.0012)), rand(Uniform(0.0005, 0.001)), rand(Uniform(0.0002, 0.0005)), rand(Uniform(0.000005, 0.00001))]

            c4 = [duration_parameter_offsprings_array[seed, 4], susceptibility_parameters_offsprings_array[seed, 4][1], susceptibility_parameters_offsprings_array[seed, 4][2], susceptibility_parameters_offsprings_array[seed, 4][3], susceptibility_parameters_offsprings_array[seed, 4][4], susceptibility_parameters_offsprings_array[seed, 4][5], susceptibility_parameters_offsprings_array[seed, 4][6], susceptibility_parameters_offsprings_array[seed, 4][7], temperature_parameters_offsprings_array[seed, 4][1], temperature_parameters_offsprings_array[seed, 4][2], temperature_parameters_offsprings_array[seed, 4][3], temperature_parameters_offsprings_array[seed, 4][4], temperature_parameters_offsprings_array[seed, 4][5], temperature_parameters_offsprings_array[seed, 4][6], temperature_parameters_offsprings_array[seed, 4][7], mean_immunity_durations_offsprings_array[seed, 4][1], mean_immunity_durations_offsprings_array[seed, 4][2], mean_immunity_durations_offsprings_array[seed, 4][3], mean_immunity_durations_offsprings_array[seed, 4][4], mean_immunity_durations_offsprings_array[seed, 4][5], mean_immunity_durations_offsprings_array[seed, 4][6], mean_immunity_durations_offsprings_array[seed, 4][7], random_infection_probabilities_offsprings_array[seed, 4][1], random_infection_probabilities_offsprings_array[seed, 4][2], random_infection_probabilities_offsprings_array[seed, 4][3], random_infection_probabilities_offsprings_array[seed, 4][4]]
            check_bounds(c4)

            for j = 1:num_viruses
                viruses[j].mean_immunity_duration = c4[15 + j]
                viruses[j].immunity_duration_sd = c4[15 + j] * 0.33
            end
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
            @time incidence_offsprings_arr[seed, 4], _, __, ___ = run_simulation(
                num_threads, thread_rng, agents, viruses, households, schools, c4[1],
                c4[2:8], c4[9:15], temperature, mean_household_contact_durations, household_contact_duration_sds,
                other_contact_duration_shapes, other_contact_duration_scales,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, c4[23:26], recovered_duration_mean, recovered_duration_sd, num_years, false)

            # Если рассматривается 1 год
            if is_one_mean_year_modeled
                observed_num_infected_age_groups_viruses_mean = incidence_offsprings_arr[seed, 4][1:52, :, :]
                for i = 2:num_years
                    for j = 1:52
                        observed_num_infected_age_groups_viruses_mean[j, :, :] += incidence_offsprings_arr[seed, 4][(i - 1) * 52 + j, :, :]
                    end
                end
                observed_num_infected_age_groups_viruses_mean ./= num_years
                error_offsprings[seed, 4] = sum((observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses).^2)
            else
                error_offsprings[seed, 4] = sum(abs.(incidence_offsprings_arr[seed, 4] - num_infected_age_groups_viruses).^2)
            end
        end

        args = [a[1] for a in arg_n_smallest_values(vcat(error_seeds, error_offsprings[:, 1], error_offsprings[:, 2], error_offsprings[:, 3], error_offsprings[:, 4]), seeds_size)]

        incidence_arr_concatenated = vcat(incidence_seeds_arr, incidence_offsprings_arr[:, 1], incidence_offsprings_arr[:, 2], incidence_offsprings_arr[:, 3], incidence_offsprings_arr[:, 4])
        duration_parameter_concatenated = vcat(duration_parameter_seeds_array, duration_parameter_offsprings_array[:, 1], duration_parameter_offsprings_array[:, 2], duration_parameter_offsprings_array[:, 3], duration_parameter_offsprings_array[:, 4])
        susceptibility_parameters_concatenated = vcat(susceptibility_parameters_seeds_array, susceptibility_parameters_offsprings_array[:, 1], susceptibility_parameters_offsprings_array[:, 2], susceptibility_parameters_offsprings_array[:, 3], susceptibility_parameters_offsprings_array[:, 4])
        temperature_parameters_concatenated = vcat(temperature_parameters_seeds_array, temperature_parameters_offsprings_array[:, 1], temperature_parameters_offsprings_array[:, 2], temperature_parameters_offsprings_array[:, 3], temperature_parameters_offsprings_array[:, 4])
        mean_immunity_durations_concatenated = vcat(mean_immunity_durations_seeds_array, mean_immunity_durations_offsprings_array[:, 1], mean_immunity_durations_offsprings_array[:, 2], mean_immunity_durations_offsprings_array[:, 3], mean_immunity_durations_offsprings_array[:, 4])
        random_infection_probabilities_concatenated = vcat(random_infection_probabilities_seeds_array, random_infection_probabilities_offsprings_array[:, 1], random_infection_probabilities_offsprings_array[:, 2], random_infection_probabilities_offsprings_array[:, 3], random_infection_probabilities_offsprings_array[:, 4])
        error_concatenated = vcat(error_seeds, error_offsprings[:, 1], error_offsprings[:, 2], error_offsprings[:, 3], error_offsprings[:, 4])

        for i = 1:seeds_size
            incidence_seeds_arr[i] = incidence_arr_concatenated[args[i]]
            duration_parameter_seeds_array[i] = duration_parameter_concatenated[args[i]]
            susceptibility_parameters_seeds_array[i] = copy(susceptibility_parameters_concatenated[args[i]])
            temperature_parameters_seeds_array[i] = copy(temperature_parameters_concatenated[args[i]])
            mean_immunity_durations_seeds_array[i] = copy(mean_immunity_durations_concatenated[args[i]])
            random_infection_probabilities_seeds_array[i] = copy(random_infection_probabilities_concatenated[args[i]])
            error_seeds[i] = error_concatenated[args[i]]

            save(joinpath(@__DIR__, "..", "output", "tables", "cgo", "$(curr_run)", "results_$(i).jld"),
                "observed_cases", incidence_seeds_arr[i],
                "duration_parameter", duration_parameter_seeds_array[i],
                "susceptibility_parameters", susceptibility_parameters_seeds_array[i],
                "temperature_parameters", temperature_parameters_seeds_array[i],
                "mean_immunity_durations", mean_immunity_durations_seeds_array[i],
                "random_infection_probabilities", random_infection_probabilities_seeds_array[i])
        end
    end
end

run_cgo_model()
