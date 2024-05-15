using Base.Threads
using DelimitedFiles
using Statistics
using LatinHypercubeSampling
using CSV
using JLD
using DataFrames
using Distributions
using XGBoost

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

function run_surrogate_model()
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

    # num_initial_runs = 1000
    num_initial_runs = 10
    num_additional_runs = 0
    num_runs = num_initial_runs + num_additional_runs

    num_years = 1
    num_parameters = 26
    num_viruses = 7

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_runs)
    duration_parameter = Array{Float64, 1}(undef, num_runs)
    susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_runs)
    temperature_parameters = Array{Vector{Float64}, 1}(undef, num_runs)
    random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_runs)
    mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_runs)

    # initial / 10
    lhs_subfolder_name = "10"

    for i = 1:num_initial_runs
        incidence_arr[i] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "$(lhs_subfolder_name)", "results_$(i).jld"))["observed_cases"]
        duration_parameter[i] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "$(lhs_subfolder_name)", "results_$(i).jld"))["duration_parameter"]
        susceptibility_parameters[i] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "$(lhs_subfolder_name)", "results_$(i).jld"))["susceptibility_parameters"]
        temperature_parameters[i] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "$(lhs_subfolder_name)", "results_$(i).jld"))["temperature_parameters"]
        mean_immunity_durations[i] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "$(lhs_subfolder_name)", "results_$(i).jld"))["mean_immunity_durations"]
        random_infection_probabilities[i] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "$(lhs_subfolder_name)", "results_$(i).jld"))["random_infection_probabilities"]
    end

    for i = 1:num_additional_runs
        incidence_arr[i + num_initial_runs] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate", "results_$(i).jld"))["observed_cases"]
        duration_parameter[i + num_initial_runs] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate", "results_$(i).jld"))["duration_parameter"]
        susceptibility_parameters[i + num_initial_runs] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate", "results_$(i).jld"))["susceptibility_parameters"]
        temperature_parameters[i + num_initial_runs] = -load(joinpath(@__DIR__, "..", "output", "tables", "surrogate", "results_$(i).jld"))["temperature_parameters"]
        mean_immunity_durations[i + num_initial_runs] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate", "results_$(i).jld"))["mean_immunity_durations"]
        random_infection_probabilities[i + num_initial_runs] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate", "results_$(i).jld"))["random_infection_probabilities"]
    end

    etiology = get_etiology()
    num_infected_age_groups_viruses = get_incidence(etiology, true, flu_starting_index, true)

    min_i = 0
    min_error = 9.9e12
    y = zeros(Float64, num_runs)
    for i = eachindex(y)
        # y[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        y[i] = sum((incidence_arr[i] - num_infected_age_groups_viruses).^2)
        if y[i] < min_error
            min_error = y[i]
            min_i = i
        end
    end
    # y = zeros(Float64, num_runs, 52)
    # for i = 1:num_runs
    #     # y[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    #     for w = 1:52
    #         y[i, w] = sum((incidence_arr[i][w, :, :] - num_infected_age_groups_viruses[w, :, :]).^2)
    #     end
    #     if sum((incidence_arr[i] - num_infected_age_groups_viruses).^2) < min_error
    #         min_error = sum((incidence_arr[i] - num_infected_age_groups_viruses).^2)
    #         min_i = i
    #     end
    # end

    X = zeros(Float64, num_runs, num_parameters)
    for i = 1:num_runs
        X[i, 1] = duration_parameter[i]
        for k = 1:num_viruses
            X[i, 1 + k] = susceptibility_parameters[i][k]
        end
        for k = 1:num_viruses
            X[i, 1 + num_viruses + k] = temperature_parameters[i][k]
        end
        for k = 1:num_viruses
            X[i, 1 + 2 * num_viruses + k] = mean_immunity_durations[i][k]
        end
        for k = 1:4
            X[i, 1 + 3 * num_viruses + k] = random_infection_probabilities[i][k]
        end
    end

    forest_num_rounds = 150
    forest_max_depth = 10
    η = 0.1

    min_error = 99999.0

    par_vec = zeros(Float64, 26)
    error = 0.0

    duration_parameter_default = 0.0
    duration_parameter_min = 0.0

    susceptibility_parameters_default = zeros(Float64, num_viruses)
    susceptibility_parameters_min = zeros(Float64, num_viruses)

    temperature_parameters_default = zeros(Float64, num_viruses)
    temperature_parameters_min = zeros(Float64, num_viruses)

    mean_immunity_durations_default = zeros(Float64, num_viruses)
    mean_immunity_durations_min = zeros(Float64, num_viruses)

    random_infection_probabilities_default = zeros(Float64, 4)
    random_infection_probabilities_min = zeros(Float64, 4)

    # XGBoost
    # bst = xgboost((X, y), num_round=forest_num_rounds, max_depth=forest_max_depth, objective="reg:squarederror", η = η, watchlist=[])

    # for particle_number = 1:20
    #     for i = 1:42
    #         for k = 1:26
    #             par_vec[k] = 0.0
    #         end

    #         swarm_incidence = load(joinpath(@__DIR__, "..", "output", "tables", "swarm", "$(particle_number)", "results_$(i).jld"))["observed_cases"]
    #         swarm_nMAE = zeros(Float64, 52)
    #         for j = 1:52
    #             swarm_nMAE[j] = sum(abs.(swarm_incidence[j, :, :] - num_infected_age_groups_viruses[j, :, :])) / sum(num_infected_age_groups_viruses[j, :, :])
    #         end

    #         par_vec[1] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm", "$(particle_number)", "results_$(i).jld"))["duration_parameter"]
    #         par_vec[2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm", "$(particle_number)", "results_$(i).jld"))["susceptibility_parameters"]
    #         par_vec[9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm", "$(particle_number)", "results_$(i).jld"))["temperature_parameters"]
    #         par_vec[16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm", "$(particle_number)", "results_$(i).jld"))["mean_immunity_durations"]
    #         par_vec[23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm", "$(particle_number)", "results_$(i).jld"))["random_infection_probabilities"]
    #         r = reshape(par_vec, 1, :)

    #         # real_nMAE = sum(abs.(load(joinpath(@__DIR__, "..", "output", "tables", "swarm", "$(particle_number)", "results_$(i).jld"))["observed_cases"] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    #         # error += abs(real_nMAE - nMAE[:][1])

    #         nMAE_predicted, _ = Lux.apply(lux_model, r, params, lux_state)
    #         error += 0.5 * mean((nMAE_predicted .- swarm_nMAE).^2)
    #     end
    # end
    # error /= 840.0

    # println("Error: $(error)")
    # return

    println("Simulation")

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

    duration_parameter_delta = 0.1
    susceptibility_parameter_deltas = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    temperature_parameter_deltas = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    mean_immunity_duration_deltas = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    random_infection_probability_deltas = [0.1, 0.1, 0.1, 0.1]

    num_surrogate_runs = 300

    for curr_run = (1 + num_additional_runs):num_surrogate_runs
        # XGBoost
        bst = xgboost((X, y), num_round=forest_num_rounds, max_depth=forest_max_depth, objective="reg:squarederror", η = η, watchlist=[])

        error = 0.0
        error_min = 9.0e12
        error_prev = 9.0e12
        # error = sum(abs.(incidence_arr[min_i]  - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        # error_prev = error
        # error_min = error

        duration_parameter_default = duration_parameter[min_i]
        duration_parameter_min = duration_parameter[min_i]

        for v = 1:7
            susceptibility_parameters_default[v] = susceptibility_parameters[min_i][v]
            susceptibility_parameters_min[v] = susceptibility_parameters[min_i][v]

            temperature_parameters_default[v] = -temperature_parameters[min_i][v]
            temperature_parameters_min[v] = -temperature_parameters[min_i][v]

            mean_immunity_durations_default[v] = mean_immunity_durations[min_i][v]
            mean_immunity_durations_min[v] = mean_immunity_durations[min_i][v]
        end

        for a = 1:4
            random_infection_probabilities_default[a] = random_infection_probabilities[min_i][a]
            random_infection_probabilities_min[a] = random_infection_probabilities[min_i][a]
        end
        
        local_rejected_num = 0

        for n = 1:1000
            # Кандидат для параметра продолжительности контакта в диапазоне (0.1, 1)
            x_cand = duration_parameter_default
            if abs(x_cand - 0.1) < 0.00001
                x_cand += 0.001
            elseif abs(x_cand - 1) < 0.00001
                x_cand -= 0.001
            end
            y_cand = rand(Normal(log((x_cand - 0.1) / (1 - x_cand)), duration_parameter_delta))
            duration_parameter_candidate = (exp(y_cand) + 0.1) / (1 + exp(y_cand))

            # Кандидаты для параметров неспецифической восприимчивости к вирусам в диапазоне (1, 7)
            x_cand = susceptibility_parameters_default[1]
            if abs(x_cand - 1) < 0.00001
                x_cand += 0.001
            elseif abs(x_cand - 7) < 0.00001
                x_cand -= 0.001
            end
            y_cand = rand(Normal(log((x_cand - 1) / (7 - x_cand)), susceptibility_parameter_deltas[1]))
            susceptibility_parameter_1_candidate = (7 * exp(y_cand) + 1) / (1 + exp(y_cand))

            x_cand = susceptibility_parameters_default[2]
            if abs(x_cand - 1) < 0.00001
                x_cand += 0.001
            elseif abs(x_cand - 7) < 0.00001
                x_cand -= 0.001
            end
            y_cand = rand(Normal(log((x_cand - 1) / (7 - x_cand)), susceptibility_parameter_deltas[2]))
            susceptibility_parameter_2_candidate = (7 * exp(y_cand) + 1) / (1 + exp(y_cand))

            x_cand = susceptibility_parameters_default[3]
            if abs(x_cand - 1) < 0.00001
                x_cand += 0.001
            elseif abs(x_cand - 7) < 0.00001
                x_cand -= 0.001
            end
            y_cand = rand(Normal(log((x_cand - 1) / (7 - x_cand)), susceptibility_parameter_deltas[3]))
            susceptibility_parameter_3_candidate = (7 * exp(y_cand) + 1) / (1 + exp(y_cand))

            x_cand = susceptibility_parameters_default[4]
            if abs(x_cand - 1) < 0.00001
                x_cand += 0.001
            elseif abs(x_cand - 7) < 0.00001
                x_cand -= 0.001
            end
            y_cand = rand(Normal(log((x_cand - 1) / (7 - x_cand)), susceptibility_parameter_deltas[4]))
            susceptibility_parameter_4_candidate = (7 * exp(y_cand) + 1) / (1 + exp(y_cand))

            x_cand = susceptibility_parameters_default[5]
            if abs(x_cand - 1) < 0.00001
                x_cand += 0.001
            elseif abs(x_cand - 7) < 0.00001
                x_cand -= 0.001
            end
            y_cand = rand(Normal(log((x_cand - 1) / (7 - x_cand)), susceptibility_parameter_deltas[5]))
            susceptibility_parameter_5_candidate = (7 * exp(y_cand) + 1) / (1 + exp(y_cand))

            x_cand = susceptibility_parameters_default[6]
            if abs(x_cand - 1) < 0.00001
                x_cand += 0.001
            elseif abs(x_cand - 7) < 0.00001
                x_cand -= 0.001
            end
            y_cand = rand(Normal(log((x_cand - 1) / (7 - x_cand)), susceptibility_parameter_deltas[6]))
            susceptibility_parameter_6_candidate = (7 * exp(y_cand) + 1) / (1 + exp(y_cand))

            x_cand = susceptibility_parameters_default[7]
            if abs(x_cand - 1) < 0.00001
                x_cand += 0.001
            elseif abs(x_cand - 7) < 0.00001
                x_cand -= 0.001
            end
            y_cand = rand(Normal(log((x_cand - 1) / (7 - x_cand)), susceptibility_parameter_deltas[7]))
            susceptibility_parameter_7_candidate = (7 * exp(y_cand) + 1) / (1 + exp(y_cand))

            # Кандидаты для параметров температуры воздуха в диапазоне (0.01, 1)
            x_cand = temperature_parameters_default[1]
            if abs(x_cand - 0.01) < 0.00001
                x_cand += 0.0001
            elseif abs(x_cand - 0.01) < 0.00001
                x_cand -= 0.0001
            end
            y_cand = rand(Normal(log((x_cand - 0.01) / (1 - x_cand)), temperature_parameter_deltas[1]))
            temperature_parameter_1_candidate = (exp(y_cand) + 0.01) / (1 + exp(y_cand))

            x_cand = temperature_parameters_default[2]
            if abs(x_cand - 0.01) < 0.00001
                x_cand += 0.0001
            elseif abs(x_cand - 0.01) < 0.00001
                x_cand -= 0.0001
            end
            y_cand = rand(Normal(log((x_cand - 0.01) / (1 - x_cand)), temperature_parameter_deltas[2]))
            temperature_parameter_2_candidate = (exp(y_cand) + 0.01) / (1 + exp(y_cand))

            x_cand = temperature_parameters_default[3]
            if abs(x_cand - 0.01) < 0.00001
                x_cand += 0.0001
            elseif abs(x_cand - 0.01) < 0.00001
                x_cand -= 0.0001
            end
            y_cand = rand(Normal(log((x_cand - 0.01) / (1 - x_cand)), temperature_parameter_deltas[3]))
            temperature_parameter_3_candidate = (exp(y_cand) + 0.01) / (1 + exp(y_cand))

            x_cand = temperature_parameters_default[4]
            if abs(x_cand - 0.01) < 0.00001
                x_cand += 0.0001
            elseif abs(x_cand - 0.01) < 0.00001
                x_cand -= 0.0001
            end
            y_cand = rand(Normal(log((x_cand - 0.01) / (1 - x_cand)), temperature_parameter_deltas[4]))
            temperature_parameter_4_candidate = (exp(y_cand) + 0.01) / (1 + exp(y_cand))

            x_cand = temperature_parameters_default[5]
            if abs(x_cand - 0.01) < 0.00001
                x_cand += 0.0001
            elseif abs(x_cand - 0.01) < 0.00001
                x_cand -= 0.0001
            end
            y_cand = rand(Normal(log((x_cand - 0.01) / (1 - x_cand)), temperature_parameter_deltas[5]))
            temperature_parameter_5_candidate = (exp(y_cand) + 0.01) / (1 + exp(y_cand))

            x_cand = temperature_parameters_default[6]
            if abs(x_cand - 0.01) < 0.00001
                x_cand += 0.0001
            elseif abs(x_cand - 0.01) < 0.00001
                x_cand -= 0.0001
            end
            y_cand = rand(Normal(log((x_cand - 0.01) / (1 - x_cand)), temperature_parameter_deltas[6]))
            temperature_parameter_6_candidate = (exp(y_cand) + 0.01) / (1 + exp(y_cand))

            x_cand = temperature_parameters_default[7]
            if abs(x_cand - 0.01) < 0.00001
                x_cand += 0.0001
            elseif abs(x_cand - 0.01) < 0.00001
                x_cand -= 0.0001
            end
            y_cand = rand(Normal(log((x_cand - 0.01) / (1 - x_cand)), temperature_parameter_deltas[7]))
            temperature_parameter_7_candidate = (exp(y_cand) + 0.01) / (1 + exp(y_cand))

            # Кандидаты для параметров температуры воздуха в диапазоне (30, 365)
            x_cand = mean_immunity_durations_default[1]
            if abs(x_cand - 30) < 0.00001
                x_cand += 0.1
            elseif abs(x_cand - 365) < 0.00001
                x_cand -= 0.1
            end
            y_cand = rand(Normal(log((x_cand - 30) / (365 - x_cand)), mean_immunity_duration_deltas[1]))
            mean_immunity_duration_1_candidate = (365 * exp(y_cand) + 30) / (1 + exp(y_cand))

            x_cand = mean_immunity_durations_default[2]
            if abs(x_cand - 30) < 0.00001
                x_cand += 0.1
            elseif abs(x_cand - 365) < 0.00001
                x_cand -= 0.1
            end
            y_cand = rand(Normal(log((x_cand - 30) / (365 - x_cand)), mean_immunity_duration_deltas[2]))
            mean_immunity_duration_2_candidate = (365 * exp(y_cand) + 30) / (1 + exp(y_cand))

            x_cand = mean_immunity_durations_default[3]
            if abs(x_cand - 30) < 0.00001
                x_cand += 0.1
            elseif abs(x_cand - 365) < 0.00001
                x_cand -= 0.1
            end
            y_cand = rand(Normal(log((x_cand - 30) / (365 - x_cand)), mean_immunity_duration_deltas[3]))
            mean_immunity_duration_3_candidate = (365 * exp(y_cand) + 30) / (1 + exp(y_cand))

            x_cand = mean_immunity_durations_default[4]
            if abs(x_cand - 30) < 0.00001
                x_cand += 0.1
            elseif abs(x_cand - 365) < 0.00001
                x_cand -= 0.1
            end
            y_cand = rand(Normal(log((x_cand - 30) / (365 - x_cand)), mean_immunity_duration_deltas[4]))
            mean_immunity_duration_4_candidate = (365 * exp(y_cand) + 30) / (1 + exp(y_cand))

            x_cand = mean_immunity_durations_default[5]
            if abs(x_cand - 30) < 0.00001
                x_cand += 0.1
            elseif abs(x_cand - 365) < 0.00001
                x_cand -= 0.1
            end
            y_cand = rand(Normal(log((x_cand - 30) / (365 - x_cand)), mean_immunity_duration_deltas[5]))
            mean_immunity_duration_5_candidate = (365 * exp(y_cand) + 30) / (1 + exp(y_cand))

            x_cand = mean_immunity_durations_default[6]
            if abs(x_cand - 30) < 0.00001
                x_cand += 0.1
            elseif abs(x_cand - 365) < 0.00001
                x_cand -= 0.1
            end
            y_cand = rand(Normal(log((x_cand - 30) / (365 - x_cand)), mean_immunity_duration_deltas[6]))
            mean_immunity_duration_6_candidate = (365 * exp(y_cand) + 30) / (1 + exp(y_cand))

            x_cand = mean_immunity_durations_default[7]
            if abs(x_cand - 30) < 0.00001
                x_cand += 0.1
            elseif abs(x_cand - 365) < 0.00001
                x_cand -= 0.1
            end
            y_cand = rand(Normal(log((x_cand - 30) / (365 - x_cand)), mean_immunity_duration_deltas[7]))
            mean_immunity_duration_7_candidate = (365 * exp(y_cand) + 30) / (1 + exp(y_cand))
            
            # Кандидаты для параметра вероятности случайного инфицирования для возрастной группы 0-2 лет в диапазоне (0.0009, 0.0015)
            x_cand = random_infection_probabilities_default[1]
            if abs(x_cand - 0.000005) < 0.0000001
                x_cand += 0.000001
            elseif abs(x_cand - 0.00001) < 0.0000001
                x_cand -= 0.000001
            end
            y_cand = rand(Normal(log((x_cand - 0.0009) / (0.0015 - x_cand)), random_infection_probability_deltas[1]))
            random_infection_probability_1_candidate = (0.0015 * exp(y_cand) + 0.0009) / (1 + exp(y_cand))

            # Кандидаты для параметра вероятности случайного инфицирования для возрастной группы 3-6 лет в диапазоне (0.0005, 0.001)
            x_cand = random_infection_probabilities_default[2]
            if abs(x_cand - 0.0005) < 0.0000001
                x_cand += 0.000001
            elseif abs(x_cand - 0.001) < 0.0000001
                x_cand -= 0.000001
            end
            y_cand = rand(Normal(log((x_cand - 0.0005) / (0.001 - x_cand)), random_infection_probability_deltas[2]))
            random_infection_probability_2_candidate = (0.001 * exp(y_cand) + 0.0005) / (1 + exp(y_cand))

            # Кандидаты для параметра вероятности случайного инфицирования для возрастной группы 7-14 лет в диапазоне (0.0002, 0.0005)
            x_cand = random_infection_probabilities_default[3]
            if abs(x_cand - 0.0002) < 0.0000001
                x_cand += 0.000001
            elseif abs(x_cand - 0.0005) < 0.0000001
                x_cand -= 0.000001
            end
            y_cand = rand(Normal(log((x_cand - 0.0002) / (0.0005 - x_cand)), random_infection_probability_deltas[3]))
            random_infection_probability_3_candidate = (0.0005 * exp(y_cand) + 0.0002) / (1 + exp(y_cand))

            # Кандидаты для параметра вероятности случайного инфицирования для возрастной группы 15+ лет в диапазоне (0.000005, 0.00001)
            x_cand = random_infection_probabilities_default[4]
            if abs(x_cand - 0.000005) < 0.0000001
                x_cand += 0.000001
            elseif abs(x_cand - 0.00001) < 0.0000001
                x_cand -= 0.000001
            end
            y_cand = rand(Normal(log((x_cand - 0.000005) / (0.00001 - x_cand)), random_infection_probability_deltas[4]))
            random_infection_probability_4_candidate = (0.00001 * exp(y_cand) + 0.000005) / (1 + exp(y_cand))

            par_vec[1] = duration_parameter_candidate

            par_vec[2] = susceptibility_parameter_1_candidate
            par_vec[3] = susceptibility_parameter_2_candidate
            par_vec[4] = susceptibility_parameter_3_candidate
            par_vec[5] = susceptibility_parameter_4_candidate
            par_vec[6] = susceptibility_parameter_5_candidate
            par_vec[7] = susceptibility_parameter_6_candidate
            par_vec[8] = susceptibility_parameter_7_candidate

            par_vec[9] = -temperature_parameter_1_candidate
            par_vec[10] = -temperature_parameter_2_candidate
            par_vec[11] = -temperature_parameter_3_candidate
            par_vec[12] = -temperature_parameter_4_candidate
            par_vec[13] = -temperature_parameter_5_candidate
            par_vec[14] = -temperature_parameter_6_candidate
            par_vec[15] = -temperature_parameter_7_candidate

            par_vec[16] = mean_immunity_duration_1_candidate
            par_vec[17] = mean_immunity_duration_2_candidate
            par_vec[18] = mean_immunity_duration_3_candidate
            par_vec[19] = mean_immunity_duration_4_candidate
            par_vec[20] = mean_immunity_duration_5_candidate
            par_vec[21] = mean_immunity_duration_6_candidate
            par_vec[22] = mean_immunity_duration_7_candidate

            par_vec[23] = random_infection_probability_1_candidate
            par_vec[24] = random_infection_probability_2_candidate
            par_vec[25] = random_infection_probability_3_candidate
            par_vec[26] = random_infection_probability_4_candidate

            r = reshape(par_vec, 1, :)
    
            error = predict(bst, r)[1]

            # Если ошибка меньше ошибки на предыдущем шаге или число последовательных отказов больше 10
            if error < error_prev || local_rejected_num >= 10
                if error < error_min
                    error_min = error

                    duration_parameter_min = duration_parameter_candidate

                    susceptibility_parameters_min[1] = susceptibility_parameter_1_candidate
                    susceptibility_parameters_min[2] = susceptibility_parameter_2_candidate
                    susceptibility_parameters_min[3] = susceptibility_parameter_3_candidate
                    susceptibility_parameters_min[4] = susceptibility_parameter_4_candidate
                    susceptibility_parameters_min[5] = susceptibility_parameter_5_candidate
                    susceptibility_parameters_min[6] = susceptibility_parameter_6_candidate
                    susceptibility_parameters_min[7] = susceptibility_parameter_7_candidate

                    temperature_parameters_min[1] = temperature_parameter_1_candidate
                    temperature_parameters_min[2] = temperature_parameter_2_candidate
                    temperature_parameters_min[3] = temperature_parameter_3_candidate
                    temperature_parameters_min[4] = temperature_parameter_4_candidate
                    temperature_parameters_min[5] = temperature_parameter_5_candidate
                    temperature_parameters_min[6] = temperature_parameter_6_candidate
                    temperature_parameters_min[7] = temperature_parameter_7_candidate

                    mean_immunity_durations_min[1] = mean_immunity_duration_1_candidate
                    mean_immunity_durations_min[2] = mean_immunity_duration_2_candidate
                    mean_immunity_durations_min[3] = mean_immunity_duration_3_candidate
                    mean_immunity_durations_min[4] = mean_immunity_duration_4_candidate
                    mean_immunity_durations_min[5] = mean_immunity_duration_5_candidate
                    mean_immunity_durations_min[6] = mean_immunity_duration_6_candidate
                    mean_immunity_durations_min[7] = mean_immunity_duration_7_candidate

                    random_infection_probabilities_min[1] = random_infection_probability_1_candidate
                    random_infection_probabilities_min[2] = random_infection_probability_2_candidate
                    random_infection_probabilities_min[3] = random_infection_probability_3_candidate
                    random_infection_probabilities_min[4] = random_infection_probability_4_candidate
                end
                duration_parameter_default = duration_parameter_candidate

                susceptibility_parameters_default[1] = susceptibility_parameter_1_candidate
                susceptibility_parameters_default[2] = susceptibility_parameter_2_candidate
                susceptibility_parameters_default[3] = susceptibility_parameter_3_candidate
                susceptibility_parameters_default[4] = susceptibility_parameter_4_candidate
                susceptibility_parameters_default[5] = susceptibility_parameter_5_candidate
                susceptibility_parameters_default[6] = susceptibility_parameter_6_candidate
                susceptibility_parameters_default[7] = susceptibility_parameter_7_candidate

                temperature_parameters_default[1] = temperature_parameter_1_candidate
                temperature_parameters_default[2] = temperature_parameter_2_candidate
                temperature_parameters_default[3] = temperature_parameter_3_candidate
                temperature_parameters_default[4] = temperature_parameter_4_candidate
                temperature_parameters_default[5] = temperature_parameter_5_candidate
                temperature_parameters_default[6] = temperature_parameter_6_candidate
                temperature_parameters_default[7] = temperature_parameter_7_candidate

                mean_immunity_durations_default[1] = mean_immunity_duration_1_candidate
                mean_immunity_durations_default[2] = mean_immunity_duration_2_candidate
                mean_immunity_durations_default[3] = mean_immunity_duration_3_candidate
                mean_immunity_durations_default[4] = mean_immunity_duration_4_candidate
                mean_immunity_durations_default[5] = mean_immunity_duration_5_candidate
                mean_immunity_durations_default[6] = mean_immunity_duration_6_candidate
                mean_immunity_durations_default[7] = mean_immunity_duration_7_candidate

                random_infection_probabilities_default[1] = random_infection_probability_1_candidate
                random_infection_probabilities_default[2] = random_infection_probability_2_candidate
                random_infection_probabilities_default[3] = random_infection_probability_3_candidate
                random_infection_probabilities_default[4] = random_infection_probability_4_candidate

                error_prev = error

                # Число последовательных отказов приравниваем нулю
                local_rejected_num = 0
            else
                local_rejected_num += 1
            end
        end

        for j = 1:num_viruses
            viruses[j].mean_immunity_duration = mean_immunity_durations_min[j]
            viruses[j].immunity_duration_sd = mean_immunity_durations_min[j] * 0.33
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
            num_threads, thread_rng, agents, viruses, households, schools, duration_parameter_min,
            susceptibility_parameters_min, -temperature_parameters_min, temperature,
            mean_household_contact_durations, household_contact_duration_sds,
            other_contact_duration_shapes, other_contact_duration_scales,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probabilities_min,
            recovered_duration_mean, recovered_duration_sd, num_years, false)

        # Функция потерь
        error = 0.0
        # Если рассматривается 1 год
        if is_one_mean_year_modeled
            observed_num_infected_age_groups_viruses_mean = observed_num_infected_age_groups_viruses[1:52, :, :]
            for i = 2:num_years
                for j = 1:52
                    observed_num_infected_age_groups_viruses_mean[j, :, :] += observed_num_infected_age_groups_viruses[(i - 1) * 52 + j, :, :]
                end
            end
            observed_num_infected_age_groups_viruses_mean ./= num_years
            # error = sum(abs.(observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
            error = sum((observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses).^2)
        else
            # error = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
            error = sum((observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses).^2)
        end

        save(joinpath(@__DIR__, "..", "output", "tables", "surrogate", "results_$(curr_run).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "duration_parameter", duration_parameter_min,
            "susceptibility_parameters", susceptibility_parameters_min,
            "temperature_parameters", temperature_parameters_min,
            "mean_immunity_durations", mean_immunity_durations_min,
            "random_infection_probabilities", random_infection_probabilities_min)

        println("Real error: $(error)")

        # nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        error = sum((observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses).^2)

        push!(y, error)
        X = vcat(X, [duration_parameter_min, susceptibility_parameters_min[1], susceptibility_parameters_min[2], susceptibility_parameters_min[3], susceptibility_parameters_min[4], susceptibility_parameters_min[5], susceptibility_parameters_min[6], susceptibility_parameters_min[7], temperature_parameters_min[1], temperature_parameters_min[2], temperature_parameters_min[3], temperature_parameters_min[4], temperature_parameters_min[5], temperature_parameters_min[6], temperature_parameters_min[7], mean_immunity_durations_min[1], mean_immunity_durations_min[2], mean_immunity_durations_min[3], mean_immunity_durations_min[4], mean_immunity_durations_min[5], mean_immunity_durations_min[6], mean_immunity_durations_min[7], random_infection_probabilities_min[1], random_infection_probabilities_min[2], random_infection_probabilities_min[3], random_infection_probabilities_min[4]]')
    end
end

run_surrogate_model()
