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

function log_g(x, mu, sigma)
    return -log(sqrt(2 * pi) * sigma) - 0.5 * ((x - mu) / sigma)^2
end

function run_metropolis_model()
    println("Initialization...")

    nMAE_output_table_name = "tables_metropolis_hypercube"
    nMAE_output_file_location = joinpath(@__DIR__, "..", "parameters", "output_metropolis_hypercube.txt")

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

    for i in 1:(52 * num_years)
        for j in 1:4
            for k in 1:7
                if num_infected_age_groups_viruses[i, k, j] < 1
                    num_infected_age_groups_viruses[i, k, j] = 1.0
                end
            end
        end
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

    # Получаем значения параметров
    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "duration_parameter_array.csv"), ',', Float64, '\n'))
    duration_parameter = duration_parameter_array[end]

    susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))
    susceptibility_parameters = [
        susceptibility_parameter_1_array[end],
        susceptibility_parameter_2_array[end],
        susceptibility_parameter_3_array[end],
        susceptibility_parameter_4_array[end],
        susceptibility_parameter_5_array[end],
        susceptibility_parameter_6_array[end],
        susceptibility_parameter_7_array[end]
    ]

    temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_7_array.csv"), ',', Float64, '\n'))
    temperature_parameters = -[
        temperature_parameter_1_array[end],
        temperature_parameter_2_array[end],
        temperature_parameter_3_array[end],
        temperature_parameter_4_array[end],
        temperature_parameter_5_array[end],
        temperature_parameter_6_array[end],
        temperature_parameter_7_array[end]
    ]

    mean_immunity_duration_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_1_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_2_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_3_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_4_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_5_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_6_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_7_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration = [
        mean_immunity_duration_1_array[end],
        mean_immunity_duration_2_array[end],
        mean_immunity_duration_3_array[end],
        mean_immunity_duration_4_array[end],
        mean_immunity_duration_5_array[end],
        mean_immunity_duration_6_array[end],
        mean_immunity_duration_7_array[end]
    ]

    random_infection_probability_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_1_array.csv"), ',', Float64, '\n'))
    random_infection_probability_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_2_array.csv"), ',', Float64, '\n'))
    random_infection_probability_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_3_array.csv"), ',', Float64, '\n'))
    random_infection_probability_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_4_array.csv"), ',', Float64, '\n'))
    random_infection_probabilities = [
        random_infection_probability_1_array[end],
        random_infection_probability_2_array[end],
        random_infection_probability_3_array[end],
        random_infection_probability_4_array[end],
    ]

    # Получаем результаты моделирования для начального набора значений параметров
    @time observed_num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
        num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
        susceptibility_parameters, temperature_parameters, temperature,
        mean_household_contact_durations, household_contact_duration_sds,
        other_contact_duration_shapes, other_contact_duration_scales,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, random_infection_probabilities,
        recovered_duration_mean, recovered_duration_sd, num_years, false)

    for i in 1:(52 * num_years)
        for j in 1:4
            for k in 1:7
                if observed_num_infected_age_groups_viruses[i, k, j] < 1
                    observed_num_infected_age_groups_viruses[i, k, j] = 1.0
                end
            end
        end
    end

    # Число принятий новых значений параметров
    accept_num = 0
    # Число последовательных отказов
    local_rejected_num = 0

    # Разброс для значений параметров-кандидатов
    # duration_parameter_delta = 0.05
    # susceptibility_parameter_deltas = [0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]
    # temperature_parameter_deltas = [0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]
    # mean_immunity_duration_deltas = [0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]
    # random_infection_probability_deltas = [0.05, 0.05, 0.05, 0.05]

    duration_parameter_delta = 0.1
    susceptibility_parameter_deltas = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    temperature_parameter_deltas = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    mean_immunity_duration_deltas = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    random_infection_probability_deltas = [0.1, 0.1, 0.1, 0.1]

    # duration_parameter_delta = 0.2
    # susceptibility_parameter_deltas = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]
    # temperature_parameter_deltas = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]
    # mean_immunity_duration_deltas = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]
    # random_infection_probability_deltas = [0.2, 0.2, 0.2, 0.2]

    prob_prev = zeros(Float64, 52 * num_years, 4, 7)
    prob = zeros(Float64, 52 * num_years, 4, 7)

    for i in 1:(52 * num_years)
        for j in 1:4
            for k in 1:7
                prob_prev[i, j, k] = log_g(observed_num_infected_age_groups_viruses[i, k, j], num_infected_age_groups_viruses[i, k, j], sqrt(num_infected_age_groups_viruses[i, k, j]))
            end
        end
    end

    nMAE = 0.0
    nMAE_min = 99999.0
    # Если рассматривается 1 год
    if is_one_mean_year_modeled
        observed_num_infected_age_groups_viruses_mean = observed_num_infected_age_groups_viruses[1:52, :, :]
        for i = 2:num_years
            for j = 1:52
                observed_num_infected_age_groups_viruses_mean[j, :, :] += observed_num_infected_age_groups_viruses[(i - 1) * 52 + j, :, :]
            end
        end
        observed_num_infected_age_groups_viruses_mean ./= num_years

        nMAE = sum(abs.(observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    else
        nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    end
    nMAE_prev = nMAE
    nMAE_min = nMAE

    if countlines(nMAE_output_file_location) == 0
        open(nMAE_output_file_location, "a") do io
            println(io, nMAE)
        end
    end

    n = 1
    N = 1000
    while n <= N
        duration_parameter_candidate = rand(Normal(duration_parameter_array[end], 0.1 * (1 - 0.1)))
        if duration_parameter_candidate < 0.1
            duration_parameter_candidate = 0.1
        end
        if duration_parameter_candidate > 1
            duration_parameter_candidate = 1
        end


        susceptibility_parameter_1_candidate = rand(Normal(susceptibility_parameter_1_array[end], 0.1 * (7 - 1)))
        if susceptibility_parameter_1_candidate < 1
            susceptibility_parameter_1_candidate = 1
        end
        if susceptibility_parameter_1_candidate > 7
            susceptibility_parameter_1_candidate = 7
        end

        susceptibility_parameter_2_candidate = rand(Normal(susceptibility_parameter_2_array[end], 0.1 * (7 - 1)))
        if susceptibility_parameter_2_candidate < 1
            susceptibility_parameter_2_candidate = 1
        end
        if susceptibility_parameter_2_candidate > 7
            susceptibility_parameter_2_candidate = 7
        end

        susceptibility_parameter_3_candidate = rand(Normal(susceptibility_parameter_3_array[end], 0.1 * (7 - 1)))
        if susceptibility_parameter_3_candidate < 1
            susceptibility_parameter_3_candidate = 1
        end
        if susceptibility_parameter_3_candidate > 7
            susceptibility_parameter_3_candidate = 7
        end

        susceptibility_parameter_4_candidate = rand(Normal(susceptibility_parameter_4_array[end], 0.1 * (7 - 1)))
        if susceptibility_parameter_4_candidate < 1
            susceptibility_parameter_4_candidate = 1
        end
        if susceptibility_parameter_4_candidate > 7
            susceptibility_parameter_4_candidate = 7
        end

        susceptibility_parameter_5_candidate = rand(Normal(susceptibility_parameter_5_array[end], 0.1 * (7 - 1)))
        if susceptibility_parameter_5_candidate < 1
            susceptibility_parameter_5_candidate = 1
        end
        if susceptibility_parameter_5_candidate > 7
            susceptibility_parameter_5_candidate = 7
        end

        susceptibility_parameter_6_candidate = rand(Normal(susceptibility_parameter_6_array[end], 0.1 * (7 - 1)))
        if susceptibility_parameter_6_candidate < 1
            susceptibility_parameter_6_candidate = 1
        end
        if susceptibility_parameter_6_candidate > 7
            susceptibility_parameter_6_candidate = 7
        end

        susceptibility_parameter_7_candidate = rand(Normal(susceptibility_parameter_7_array[end], 0.1 * (7 - 1)))
        if susceptibility_parameter_7_candidate < 1
            susceptibility_parameter_7_candidate = 1
        end
        if susceptibility_parameter_7_candidate > 7
            susceptibility_parameter_7_candidate = 7
        end


        temperature_parameter_1_candidate = rand(Normal(temperature_parameter_1_array[end], 0.1 * (1 - 0.01)))
        if temperature_parameter_1_candidate < 0.01
            temperature_parameter_1_candidate = 0.01
        end
        if temperature_parameter_1_candidate > 1
            temperature_parameter_1_candidate = 1
        end

        temperature_parameter_2_candidate = rand(Normal(temperature_parameter_2_array[end], 0.1 * (1 - 0.01)))
        if temperature_parameter_2_candidate < 0.01
            temperature_parameter_2_candidate = 0.01
        end
        if temperature_parameter_2_candidate > 1
            temperature_parameter_2_candidate = 1
        end

        temperature_parameter_3_candidate = rand(Normal(temperature_parameter_3_array[end], 0.1 * (1 - 0.01)))
        if temperature_parameter_3_candidate < 0.01
            temperature_parameter_3_candidate = 0.01
        end
        if temperature_parameter_3_candidate > 1
            temperature_parameter_3_candidate = 1
        end

        temperature_parameter_4_candidate = rand(Normal(temperature_parameter_4_array[end], 0.1 * (1 - 0.01)))
        if temperature_parameter_4_candidate < 0.01
            temperature_parameter_4_candidate = 0.01
        end
        if temperature_parameter_4_candidate > 1
            temperature_parameter_4_candidate = 1
        end

        temperature_parameter_5_candidate = rand(Normal(temperature_parameter_5_array[end], 0.1 * (1 - 0.01)))
        if temperature_parameter_5_candidate < 0.01
            temperature_parameter_5_candidate = 0.01
        end
        if temperature_parameter_5_candidate > 1
            temperature_parameter_5_candidate = 1
        end

        temperature_parameter_6_candidate = rand(Normal(temperature_parameter_6_array[end], 0.1 * (1 - 0.01)))
        if temperature_parameter_6_candidate < 0.01
            temperature_parameter_6_candidate = 0.01
        end
        if temperature_parameter_6_candidate > 1
            temperature_parameter_6_candidate = 1
        end

        temperature_parameter_7_candidate = rand(Normal(temperature_parameter_7_array[end], 0.1 * (1 - 0.01)))
        if temperature_parameter_7_candidate < 0.01
            temperature_parameter_7_candidate = 0.01
        end
        if temperature_parameter_7_candidate > 1
            temperature_parameter_7_candidate = 1
        end


        mean_immunity_duration_1_candidate = rand(Normal(mean_immunity_duration_1_array[end], 0.1 * (365 - 30)))
        if mean_immunity_duration_1_candidate < 30
            mean_immunity_duration_1_candidate = 30
        end
        if mean_immunity_duration_1_candidate > 365
            mean_immunity_duration_1_candidate = 365
        end

        mean_immunity_duration_2_candidate = rand(Normal(mean_immunity_duration_2_array[end], 0.1 * (365 - 30)))
        if mean_immunity_duration_2_candidate < 30
            mean_immunity_duration_2_candidate = 30
        end
        if mean_immunity_duration_2_candidate > 365
            mean_immunity_duration_2_candidate = 365
        end

        mean_immunity_duration_3_candidate = rand(Normal(mean_immunity_duration_3_array[end], 0.1 * (365 - 30)))
        if mean_immunity_duration_3_candidate < 30
            mean_immunity_duration_3_candidate = 30
        end
        if mean_immunity_duration_3_candidate > 365
            mean_immunity_duration_3_candidate = 365
        end

        mean_immunity_duration_4_candidate = rand(Normal(mean_immunity_duration_4_array[end], 0.1 * (365 - 30)))
        if mean_immunity_duration_4_candidate < 30
            mean_immunity_duration_4_candidate = 30
        end
        if mean_immunity_duration_4_candidate > 365
            mean_immunity_duration_4_candidate = 365
        end

        mean_immunity_duration_5_candidate = rand(Normal(mean_immunity_duration_5_array[end], 0.1 * (365 - 30)))
        if mean_immunity_duration_5_candidate < 30
            mean_immunity_duration_5_candidate = 30
        end
        if mean_immunity_duration_5_candidate > 365
            mean_immunity_duration_5_candidate = 365
        end

        mean_immunity_duration_6_candidate = rand(Normal(mean_immunity_duration_6_array[end], 0.1 * (365 - 30)))
        if mean_immunity_duration_6_candidate < 30
            mean_immunity_duration_6_candidate = 30
        end
        if mean_immunity_duration_6_candidate > 365
            mean_immunity_duration_6_candidate = 365
        end

        mean_immunity_duration_7_candidate = rand(Normal(mean_immunity_duration_7_array[end], 0.1 * (365 - 30)))
        if mean_immunity_duration_7_candidate < 30
            mean_immunity_duration_7_candidate = 30
        end
        if mean_immunity_duration_7_candidate > 365
            mean_immunity_duration_7_candidate = 365
        end


        random_infection_probability_1_candidate = rand(Normal(random_infection_probability_1_array[end], 0.1 * (0.0012 - 0.0008)))
        if random_infection_probability_1_candidate < 0.0008
            random_infection_probability_1_candidate = 0.0008
        end
        if random_infection_probability_1_candidate > 0.0012
            random_infection_probability_1_candidate = 0.0012
        end

        random_infection_probability_2_candidate = rand(Normal(random_infection_probability_2_array[end], 0.1 * (0.001 - 0.0005)))
        if random_infection_probability_2_candidate < 0.0005
            random_infection_probability_2_candidate = 0.0005
        end
        if random_infection_probability_2_candidate > 0.001
            random_infection_probability_2_candidate = 0.001
        end

        random_infection_probability_3_candidate = rand(Normal(random_infection_probability_3_array[end], 0.1 * (0.0005 - 0.0002)))
        if random_infection_probability_3_candidate < 0.0002
            random_infection_probability_3_candidate = 0.0002
        end
        if random_infection_probability_3_candidate > 0.0005
            random_infection_probability_3_candidate = 0.0005
        end

        random_infection_probability_4_candidate = rand(Normal(random_infection_probability_4_array[end], 0.1 * (0.00001 - 0.000005)))
        if random_infection_probability_4_candidate < 0.000005
            random_infection_probability_4_candidate = 0.000005
        end
        if random_infection_probability_4_candidate > 0.00001
            random_infection_probability_4_candidate = 0.00001
        end

        duration_parameter = duration_parameter_candidate
        susceptibility_parameters = [
            susceptibility_parameter_1_candidate,
            susceptibility_parameter_2_candidate,
            susceptibility_parameter_3_candidate,
            susceptibility_parameter_4_candidate,
            susceptibility_parameter_5_candidate,
            susceptibility_parameter_6_candidate,
            susceptibility_parameter_7_candidate,
        ]
        temperature_parameters = -[
            temperature_parameter_1_candidate,
            temperature_parameter_2_candidate,
            temperature_parameter_3_candidate,
            temperature_parameter_4_candidate,
            temperature_parameter_5_candidate,
            temperature_parameter_6_candidate,
            temperature_parameter_7_candidate,
        ]
        mean_immunity_durations = [
            mean_immunity_duration_1_candidate,
            mean_immunity_duration_2_candidate,
            mean_immunity_duration_3_candidate,
            mean_immunity_duration_4_candidate,
            mean_immunity_duration_5_candidate,
            mean_immunity_duration_6_candidate,
            mean_immunity_duration_7_candidate,
        ]
        random_infection_probabilities = [
            random_infection_probability_1_candidate,
            random_infection_probability_2_candidate,
            random_infection_probability_3_candidate,
            random_infection_probability_4_candidate,
        ]

        for k = eachindex(viruses)
            viruses[k].mean_immunity_duration = mean_immunity_durations[k]
            viruses[k].immunity_duration_sd = mean_immunity_durations[k] * 0.33
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
            num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
            susceptibility_parameters, temperature_parameters, temperature,
            mean_household_contact_durations, household_contact_duration_sds,
            other_contact_duration_shapes, other_contact_duration_scales,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probabilities,
            recovered_duration_mean, recovered_duration_sd, num_years, false)

        for i in 1:(52 * num_years)
            for j in 1:4
                for k in 1:7
                    if observed_num_infected_age_groups_viruses[i, k, j] < 1
                        observed_num_infected_age_groups_viruses[i, k, j] = 1.0
                    end
                end
            end
        end

        nMAE = 0.0
        # Если рассматривается 1 год
        if is_one_mean_year_modeled
            observed_num_infected_age_groups_viruses_mean = observed_num_infected_age_groups_viruses[1:52, :, :]
            for i = 2:num_years
                for j = 1:52
                    observed_num_infected_age_groups_viruses_mean[j, :, :] += observed_num_infected_age_groups_viruses[(i - 1) * 52 + j, :, :]
                end
            end
            observed_num_infected_age_groups_viruses_mean ./= num_years

            nMAE = sum(abs.(observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        else
            nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        end

        open(nMAE_output_file_location, "a") do io
            println(io, nMAE)
        end

        for i in 1:(52 * num_years)
            for j in 1:4
                for k in 1:7
                    prob[i, j, k] = log_g(observed_num_infected_age_groups_viruses[i, k, j], num_infected_age_groups_viruses[i, k, j], sqrt(num_infected_age_groups_viruses[i, k, j]))
                end
            end
        end

        accept_prob = 0.0
        for i in 1:(52 * num_years)
            for j in 1:4
                for k in 1:7
                    accept_prob += prob[i, j, k] - prob_prev[i, j, k]
                end
            end
        end
        accept_prob_final = min(1.0, exp(accept_prob))

        if rand(Float64) < accept_prob_final || local_rejected_num >= 10
            push!(duration_parameter_array, duration_parameter_candidate)

            push!(susceptibility_parameter_1_array, susceptibility_parameter_1_candidate)
            push!(susceptibility_parameter_2_array, susceptibility_parameter_2_candidate)
            push!(susceptibility_parameter_3_array, susceptibility_parameter_3_candidate)
            push!(susceptibility_parameter_4_array, susceptibility_parameter_4_candidate)
            push!(susceptibility_parameter_5_array, susceptibility_parameter_5_candidate)
            push!(susceptibility_parameter_6_array, susceptibility_parameter_6_candidate)
            push!(susceptibility_parameter_7_array, susceptibility_parameter_7_candidate)

            push!(temperature_parameter_1_array, temperature_parameter_1_candidate)
            push!(temperature_parameter_2_array, temperature_parameter_2_candidate)
            push!(temperature_parameter_3_array, temperature_parameter_3_candidate)
            push!(temperature_parameter_4_array, temperature_parameter_4_candidate)
            push!(temperature_parameter_5_array, temperature_parameter_5_candidate)
            push!(temperature_parameter_6_array, temperature_parameter_6_candidate)
            push!(temperature_parameter_7_array, temperature_parameter_7_candidate)

            push!(mean_immunity_duration_1_array, mean_immunity_duration_1_candidate)
            push!(mean_immunity_duration_2_array, mean_immunity_duration_2_candidate)
            push!(mean_immunity_duration_3_array, mean_immunity_duration_3_candidate)
            push!(mean_immunity_duration_4_array, mean_immunity_duration_4_candidate)
            push!(mean_immunity_duration_5_array, mean_immunity_duration_5_candidate)
            push!(mean_immunity_duration_6_array, mean_immunity_duration_6_candidate)
            push!(mean_immunity_duration_7_array, mean_immunity_duration_7_candidate)

            push!(random_infection_probability_1_array, random_infection_probability_1_candidate)
            push!(random_infection_probability_2_array, random_infection_probability_2_candidate)
            push!(random_infection_probability_3_array, random_infection_probability_3_candidate)
            push!(random_infection_probability_4_array, random_infection_probability_4_candidate)

            prob_prev = copy(prob)

            # Увеличиваем число принятий новых параметров
            accept_num += 1
            # Число последовательных отказов приравниваем нулю
            local_rejected_num = 0
        else
            # Добавляем предыдущие значения параметров
            push!(duration_parameter_array, duration_parameter_array[end])

            push!(susceptibility_parameter_1_array, susceptibility_parameter_1_array[end])
            push!(susceptibility_parameter_2_array, susceptibility_parameter_2_array[end])
            push!(susceptibility_parameter_3_array, susceptibility_parameter_3_array[end])
            push!(susceptibility_parameter_4_array, susceptibility_parameter_4_array[end])
            push!(susceptibility_parameter_5_array, susceptibility_parameter_5_array[end])
            push!(susceptibility_parameter_6_array, susceptibility_parameter_6_array[end])
            push!(susceptibility_parameter_7_array, susceptibility_parameter_7_array[end])

            push!(temperature_parameter_1_array, temperature_parameter_1_array[end])
            push!(temperature_parameter_2_array, temperature_parameter_2_array[end])
            push!(temperature_parameter_3_array, temperature_parameter_3_array[end])
            push!(temperature_parameter_4_array, temperature_parameter_4_array[end])
            push!(temperature_parameter_5_array, temperature_parameter_5_array[end])
            push!(temperature_parameter_6_array, temperature_parameter_6_array[end])
            push!(temperature_parameter_7_array, temperature_parameter_7_array[end])

            push!(mean_immunity_duration_1_array, mean_immunity_duration_1_array[end])
            push!(mean_immunity_duration_2_array, mean_immunity_duration_2_array[end])
            push!(mean_immunity_duration_3_array, mean_immunity_duration_3_array[end])
            push!(mean_immunity_duration_4_array, mean_immunity_duration_4_array[end])
            push!(mean_immunity_duration_5_array, mean_immunity_duration_5_array[end])
            push!(mean_immunity_duration_6_array, mean_immunity_duration_6_array[end])
            push!(mean_immunity_duration_7_array, mean_immunity_duration_7_array[end])

            push!(random_infection_probability_1_array, random_infection_probability_1_array[end])
            push!(random_infection_probability_2_array, random_infection_probability_2_array[end])
            push!(random_infection_probability_3_array, random_infection_probability_3_array[end])
            push!(random_infection_probability_4_array, random_infection_probability_4_array[end])
            
            local_rejected_num += 1
        end

        # Раз в 2 шага
        if n % 2 == 0
            # Сохраняем значения параметров
            writedlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "duration_parameter_array.csv"), duration_parameter_array, ',')

            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_1_array.csv"), susceptibility_parameter_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_2_array.csv"), susceptibility_parameter_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_3_array.csv"), susceptibility_parameter_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_4_array.csv"), susceptibility_parameter_4_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_5_array.csv"), susceptibility_parameter_5_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_6_array.csv"), susceptibility_parameter_6_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_7_array.csv"), susceptibility_parameter_7_array, ',')

            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_1_array.csv"), temperature_parameter_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_2_array.csv"), temperature_parameter_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_3_array.csv"), temperature_parameter_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_4_array.csv"), temperature_parameter_4_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_5_array.csv"), temperature_parameter_5_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_6_array.csv"), temperature_parameter_6_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_7_array.csv"), temperature_parameter_7_array, ',')

            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_1_array.csv"), mean_immunity_duration_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_2_array.csv"), mean_immunity_duration_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_3_array.csv"), mean_immunity_duration_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_4_array.csv"), mean_immunity_duration_4_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_5_array.csv"), mean_immunity_duration_5_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_6_array.csv"), mean_immunity_duration_6_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_7_array.csv"), mean_immunity_duration_7_array, ',')

            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_1_array.csv"), random_infection_probability_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_2_array.csv"), random_infection_probability_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_3_array.csv"), random_infection_probability_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_4_array.csv"), random_infection_probability_4_array, ',')
        end
        println("Accept rate: ", accept_num / n)
        n += 1
    end
end

run_metropolis_model()
