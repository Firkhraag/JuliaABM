using Base.Threads
using Random
using DelimitedFiles
using Distributions
using DataFrames
using CSV
using JLD

include("global/variables.jl")

include("model/virus.jl")
include("model/agent.jl")
include("model/group.jl")
include("model/household.jl")
include("model/workplace.jl")
include("model/school.jl")
include("model/public_space.jl")
include("model/initialization.jl")
include("model/simulation.jl")
include("model/connections.jl")

include("data/district_households.jl")
include("data/district_people.jl")
include("data/district_people_households.jl")
include("data/district_nums.jl")
include("data/temperature.jl")
include("data/etiology.jl")

include("util/moving_avg.jl")
include("util/reset.jl")
include("util/stats.jl")

function main()
    println("Initialization...")

    num_threads = nthreads()

    starting_bias = 48
    n = 300
    disturbance = 0.05

    num_years = 3

    isolation_probabilities_day_1_default = [0.406, 0.305, 0.204, 0.101]
    isolation_probabilities_day_2_default = [0.669, 0.576, 0.499, 0.334]
    isolation_probabilities_day_3_default = [0.45, 0.325, 0.376, 0.168]
    recovered_duration_mean_default = 6.0
    recovered_duration_sd_default = 2.0
    mean_household_contact_durations_default = [6.5, 5.8, 9.0, 4.5, 12.0]
    household_contact_duration_sds_default = [2.2, 2.0, 3.0, 1.5, 4.0]
    other_contact_duration_shapes_default = [2.5, 1.78, 2.0, 1.81, 1.2]
    other_contact_duration_scales_default = [1.6, 1.95, 1.07, 1.7, 1.07]

    # Parameters add _default
    duration_parameter_default = 3.4981229101810194
    susceptibility_parameters_default = [2.991060937985877, 3.2468795530538848, 3.401898437854858, 4.649676110814129, 3.7163523159649126, 3.8596161196887557, 4.856247287821134]
    temperature_parameters_default = [-0.9306122448979591, -0.9078000691802144, -0.01428571428571429, -0.12176102079249784, -0.16673883420856778, -0.19917639906501897, -0.33896680397891044]
    random_infection_probabilities_default = [0.0014812661428353913, 0.0008664926507337254, 0.0003871328065857679, 9.304102575238382e-6]
    immune_memory_susceptibility_levels_default = [0.8659281154680671, 0.9648299319727879, 0.9616326530612245, 0.9726530612244898, 0.9628571428571429, 0.9738775510204082, 0.8885714285714285]
    mean_immunity_durations_default = [336.32831252685975, 308.6526629141642, 132.1112562498035, 92.83376833013635, 100.85806526000232, 141.48287440297122, 160.4937231184206]
    
    incubation_period_durations_default = [1.4, 1.0, 1.9, 4.4, 5.6, 2.6, 3.2]
    incubation_period_duration_variances_default = [0.09, 0.0484, 0.175, 0.937, 1.51, 0.327, 0.496]
    infection_period_durations_child_default = [4.8, 3.7, 10.1, 7.4, 8.0, 7.0, 6.5]
    infection_period_duration_variances_child_default = [1.12, 0.66, 4.93, 2.66, 3.1, 2.37, 2.15]
    infection_period_durations_adult_default = [8.8, 7.8, 11.4, 9.3, 9.0, 8.0, 7.5]
    infection_period_duration_variances_adult_default = [3.748, 2.94, 6.25, 4.0, 3.92, 3.1, 2.9]
    symptomatic_probabilities_child_default = [0.38, 0.38, 0.19, 0.24, 0.15, 0.16, 0.21]
    symptomatic_probabilities_teenager_default = [0.47, 0.47, 0.24, 0.3, 0.19, 0.2, 0.26]
    symptomatic_probabilities_adult_default = [0.57, 0.57, 0.29, 0.36, 0.23, 0.24, 0.32]
    mean_viral_loads_infant_default = [4.6, 4.7, 3.5, 6.0, 4.1, 4.8, 4.9]
    mean_viral_loads_child_default = [3.5, 3.5, 2.6, 4.5, 3.1, 3.6, 3.7]
    mean_viral_loads_adult_default = [2.3, 2.4, 1.8, 3.0, 2.1, 2.4, 2.5]

    isolation_probabilities_day_1 = copy(isolation_probabilities_day_1_default)
    isolation_probabilities_day_2 = copy(isolation_probabilities_day_2_default)
    isolation_probabilities_day_3 = copy(isolation_probabilities_day_3_default)
    recovered_duration_mean = recovered_duration_mean_default
    recovered_duration_sd = recovered_duration_sd_default
    mean_household_contact_durations = copy(mean_household_contact_durations_default)
    household_contact_duration_sds = copy(household_contact_duration_sds_default)
    other_contact_duration_shapes = copy(other_contact_duration_shapes_default)
    other_contact_duration_scales = copy(other_contact_duration_scales_default)

    duration_parameter = duration_parameter_default
    susceptibility_parameters = copy(susceptibility_parameters_default)
    temperature_parameters = copy(temperature_parameters_default)
    random_infection_probabilities = copy(random_infection_probabilities_default)
    immune_memory_susceptibility_levels = copy(immune_memory_susceptibility_levels_default)
    mean_immunity_durations = copy(mean_immunity_durations_default)

    incubation_period_durations = copy(incubation_period_durations_default)
    incubation_period_duration_variances = copy(incubation_period_duration_variances_default)
    infection_period_durations_child = copy(infection_period_durations_child_default)
    infection_period_duration_variances_child = copy(infection_period_duration_variances_child_default)
    infection_period_durations_adult = copy(infection_period_durations_adult_default)
    infection_period_duration_variances_adult = copy(infection_period_duration_variances_adult_default)
    symptomatic_probabilities_child = copy(symptomatic_probabilities_child_default)
    symptomatic_probabilities_teenager = copy(symptomatic_probabilities_teenager_default)
    symptomatic_probabilities_adult = copy(symptomatic_probabilities_adult_default)
    mean_viral_loads_infant = copy(mean_viral_loads_infant_default)
    mean_viral_loads_child = copy(mean_viral_loads_child_default)
    mean_viral_loads_adult = copy(mean_viral_loads_adult_default)

    firm_min_size = 1
    firm_max_size = 1000
    num_barabasi_albert_attachments = 5

    viruses = Virus[
        # FluA
        Virus(1.4, 0.67, 1, 7,  4.8, 2.04, 1, 28,  8.0, 3.4, 1, 28,  4.6, 3.5, 2.3,  0.38, 0.47, 0.57,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
        # FluB
        Virus(0.6, 0.19, 1, 7,  3.7, 3.0, 1, 28,  6.1, 4.8, 1, 28,  4.7, 3.5, 2.4,  0.38, 0.47, 0.57,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
        # RV
        Virus(1.9, 1.11, 1, 7,  10.1, 7.0, 1, 28,  11.4, 7.7, 1, 28,  3.5, 2.6, 1.8,  0.19, 0.24, 0.29,  mean_immunity_durations[3], mean_immunity_durations[3] * 0.33),
        # RSV
        Virus(4.4, 1.0, 1, 7,  6.5, 2.7, 1, 28,  6.7, 2.8, 1, 28,  6.0, 4.5, 3.0,  0.24, 0.3, 0.36,  mean_immunity_durations[4], mean_immunity_durations[4] * 0.33),
        # AdV
        Virus(5.6, 1.3, 1, 7,  8.0, 5.6, 1, 28,  9.0, 6.3, 1, 28,  4.1, 3.1, 2.1,  0.15, 0.19, 0.23,  mean_immunity_durations[5], mean_immunity_durations[5] * 0.33),
        # PIV
        Virus(2.6, 0.85, 1, 7,  7.0, 2.9, 1, 28,  8.0, 3.4, 1, 28,  4.8, 3.6, 2.4,  0.16, 0.2, 0.24,  mean_immunity_durations[6], mean_immunity_durations[6] * 0.33),
        # CoV
        Virus(3.2, 0.44, 1, 7,  6.5, 4.5, 1, 28,  7.5, 5.2, 1, 28,  4.9, 3.7, 2.5,  0.21, 0.26, 0.32,  mean_immunity_durations[7], mean_immunity_durations[7] * 0.33)]

    # Число домохозяйств каждого типа по районам
    district_households = get_district_households()
    # Число людей в каждой группе по районам
    district_people = get_district_people()
    # Число людей в домохозяйствах по районам
    district_people_households = get_district_people_households()
    # Распределение вирусов в течение года
    etiology = get_etiology()
    # Номера районов для MPI процессов
    district_nums = get_district_nums()
    # Температура воздуха, начиная с 1 января
    temperature = get_air_temperature()

    agents = Array{Agent, 1}(undef, num_agents)

    # With seed
    thread_rng = [MersenneTwister(i) for i = 1:num_threads]

    homes_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "homes.csv")))
    # Массив для хранения домохозяйств
    households = Array{Household, 1}(undef, num_households)

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

    infected_data_0_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_0 = infected_data_0_all[2:53, 24:26]
    infected_data_0_1 = etiology[:, 1] .* infected_data_0
    infected_data_0_2 = etiology[:, 2] .* infected_data_0
    infected_data_0_3 = etiology[:, 3] .* infected_data_0
    infected_data_0_4 = etiology[:, 4] .* infected_data_0
    infected_data_0_5 = etiology[:, 5] .* infected_data_0
    infected_data_0_6 = etiology[:, 6] .* infected_data_0
    infected_data_0_7 = etiology[:, 7] .* infected_data_0
    infected_data_0_viruses = cat(
        vec(infected_data_0_1),
        vec(infected_data_0_2),
        vec(infected_data_0_3),
        vec(infected_data_0_4),
        vec(infected_data_0_5),
        vec(infected_data_0_6),
        vec(infected_data_0_7),
        dims = 2)

    # infected_data_3 = infected_data_3[2:53, 21:27]
    infected_data_3 = infected_data_3_all[2:53, 24:26]
    infected_data_3_1 = etiology[:, 1] .* infected_data_3
    infected_data_3_2 = etiology[:, 2] .* infected_data_3
    infected_data_3_3 = etiology[:, 3] .* infected_data_3
    infected_data_3_4 = etiology[:, 4] .* infected_data_3
    infected_data_3_5 = etiology[:, 5] .* infected_data_3
    infected_data_3_6 = etiology[:, 6] .* infected_data_3
    infected_data_3_7 = etiology[:, 7] .* infected_data_3
    infected_data_3_viruses = cat(
        vec(infected_data_3_1),
        vec(infected_data_3_2),
        vec(infected_data_3_3),
        vec(infected_data_3_4),
        vec(infected_data_3_5),
        vec(infected_data_3_6),
        vec(infected_data_3_7),
        dims = 2)

    # infected_data_7 = infected_data_7[2:53, 21:27]
    infected_data_7 = infected_data_7_all[2:53, 24:26]
    infected_data_7_1 = etiology[:, 1] .* infected_data_7
    infected_data_7_2 = etiology[:, 2] .* infected_data_7
    infected_data_7_3 = etiology[:, 3] .* infected_data_7
    infected_data_7_4 = etiology[:, 4] .* infected_data_7
    infected_data_7_5 = etiology[:, 5] .* infected_data_7
    infected_data_7_6 = etiology[:, 6] .* infected_data_7
    infected_data_7_7 = etiology[:, 7] .* infected_data_7
    infected_data_7_viruses = cat(
        vec(infected_data_7_1),
        vec(infected_data_7_2),
        vec(infected_data_7_3),
        vec(infected_data_7_4),
        vec(infected_data_7_5),
        vec(infected_data_7_6),
        vec(infected_data_7_7),
        dims = 2)

    # infected_data_15 = infected_data_15[2:53, 21:27]
    infected_data_15 = infected_data_15_all[2:53, 24:26]
    infected_data_15_1 = etiology[:, 1] .* infected_data_15
    infected_data_15_2 = etiology[:, 2] .* infected_data_15
    infected_data_15_3 = etiology[:, 3] .* infected_data_15
    infected_data_15_4 = etiology[:, 4] .* infected_data_15
    infected_data_15_5 = etiology[:, 5] .* infected_data_15
    infected_data_15_6 = etiology[:, 6] .* infected_data_15
    infected_data_15_7 = etiology[:, 7] .* infected_data_15
    infected_data_15_viruses = cat(
        vec(infected_data_15_1),
        vec(infected_data_15_2),
        vec(infected_data_15_3),
        vec(infected_data_15_4),
        vec(infected_data_15_5),
        vec(infected_data_15_6),
        vec(infected_data_15_7),
        dims = 2)

    num_infected_age_groups_viruses = cat(
        infected_data_0_viruses,
        infected_data_3_viruses,
        infected_data_7_viruses,
        infected_data_15_viruses,
        dims = 3,
    )


    infected_data_0_prev = infected_data_0_all[2:53, 23]
    infected_data_0_1_prev = etiology[:, 1] .* infected_data_0_prev
    infected_data_0_2_prev = etiology[:, 2] .* infected_data_0_prev
    infected_data_0_3_prev = etiology[:, 3] .* infected_data_0_prev
    infected_data_0_4_prev = etiology[:, 4] .* infected_data_0_prev
    infected_data_0_5_prev = etiology[:, 5] .* infected_data_0_prev
    infected_data_0_6_prev = etiology[:, 6] .* infected_data_0_prev
    infected_data_0_7_prev = etiology[:, 7] .* infected_data_0_prev
    infected_data_0_viruses_prev = cat(
        vec(infected_data_0_1_prev),
        vec(infected_data_0_2_prev),
        vec(infected_data_0_3_prev),
        vec(infected_data_0_4_prev),
        vec(infected_data_0_5_prev),
        vec(infected_data_0_6_prev),
        vec(infected_data_0_7_prev),
        dims = 2)

    # infected_data_3 = infected_data_3[2:53, 21:27]
    infected_data_3_prev = infected_data_3_all[2:53, 23]
    infected_data_3_1_prev = etiology[:, 1] .* infected_data_3_prev
    infected_data_3_2_prev = etiology[:, 2] .* infected_data_3_prev
    infected_data_3_3_prev = etiology[:, 3] .* infected_data_3_prev
    infected_data_3_4_prev = etiology[:, 4] .* infected_data_3_prev
    infected_data_3_5_prev = etiology[:, 5] .* infected_data_3_prev
    infected_data_3_6_prev = etiology[:, 6] .* infected_data_3_prev
    infected_data_3_7_prev = etiology[:, 7] .* infected_data_3_prev
    infected_data_3_viruses_prev = cat(
        vec(infected_data_3_1_prev),
        vec(infected_data_3_2_prev),
        vec(infected_data_3_3_prev),
        vec(infected_data_3_4_prev),
        vec(infected_data_3_5_prev),
        vec(infected_data_3_6_prev),
        vec(infected_data_3_7_prev),
        dims = 2)

    # infected_data_7 = infected_data_7[2:53, 21:27]
    infected_data_7_prev = infected_data_7_all[2:53, 23]
    infected_data_7_1_prev = etiology[:, 1] .* infected_data_7_prev
    infected_data_7_2_prev = etiology[:, 2] .* infected_data_7_prev
    infected_data_7_3_prev = etiology[:, 3] .* infected_data_7_prev
    infected_data_7_4_prev = etiology[:, 4] .* infected_data_7_prev
    infected_data_7_5_prev = etiology[:, 5] .* infected_data_7_prev
    infected_data_7_6_prev = etiology[:, 6] .* infected_data_7_prev
    infected_data_7_7_prev = etiology[:, 7] .* infected_data_7_prev
    infected_data_7_viruses_prev = cat(
        vec(infected_data_7_1_prev),
        vec(infected_data_7_2_prev),
        vec(infected_data_7_3_prev),
        vec(infected_data_7_4_prev),
        vec(infected_data_7_5_prev),
        vec(infected_data_7_6_prev),
        vec(infected_data_7_7_prev),
        dims = 2)

    # infected_data_15 = infected_data_15[2:53, 21:27]
    infected_data_15_prev = infected_data_15_all[2:53, 23]
    infected_data_15_1_prev = etiology[:, 1] .* infected_data_15_prev
    infected_data_15_2_prev = etiology[:, 2] .* infected_data_15_prev
    infected_data_15_3_prev = etiology[:, 3] .* infected_data_15_prev
    infected_data_15_4_prev = etiology[:, 4] .* infected_data_15_prev
    infected_data_15_5_prev = etiology[:, 5] .* infected_data_15_prev
    infected_data_15_6_prev = etiology[:, 6] .* infected_data_15_prev
    infected_data_15_7_prev = etiology[:, 7] .* infected_data_15_prev
    infected_data_15_viruses_prev = cat(
        vec(infected_data_15_1_prev),
        vec(infected_data_15_2_prev),
        vec(infected_data_15_3_prev),
        vec(infected_data_15_4_prev),
        vec(infected_data_15_5_prev),
        vec(infected_data_15_6_prev),
        vec(infected_data_15_7_prev),
        dims = 2)

    num_all_infected_age_groups_viruses = cat(
        infected_data_0_viruses_prev,
        infected_data_3_viruses_prev,
        infected_data_7_viruses_prev,
        infected_data_15_viruses_prev,
        dims = 3,
    )

    for virus_id = 1:length(viruses)
        num_all_infected_age_groups_viruses[:, virus_id, 1] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[1]) * (1 - isolation_probabilities_day_2[1]) * (1 - isolation_probabilities_day_3[1]))
        num_all_infected_age_groups_viruses[:, virus_id, 2] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[2]) * (1 - isolation_probabilities_day_2[2]) * (1 - isolation_probabilities_day_3[2]))
        num_all_infected_age_groups_viruses[:, virus_id, 3] ./= viruses[virus_id].symptomatic_probability_teenager * (1 - (1 - isolation_probabilities_day_1[3]) * (1 - isolation_probabilities_day_2[3]) * (1 - isolation_probabilities_day_3[3]))
        num_all_infected_age_groups_viruses[:, virus_id, 4] ./= viruses[virus_id].symptomatic_probability_adult * (1 - (1 - isolation_probabilities_day_1[4]) * (1 - isolation_probabilities_day_2[4]) * (1 - isolation_probabilities_day_3[4]))
    end

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, households, viruses, num_all_infected_age_groups_viruses, isolation_probabilities_day_1,
            isolation_probabilities_day_2, isolation_probabilities_day_3, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people, district_people_households, district_nums,
            immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
            immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
            immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
            immune_memory_susceptibility_levels[7])
    end

    @time set_connections(
        agents, households, kindergartens, schools, colleges,
        workplaces, thread_rng, num_threads, homes_coords_df,
        firm_min_size, firm_max_size, num_barabasi_albert_attachments)

    println("Simulation...")

    for run_num = 1:n
        for k = 1:length(isolation_probabilities_day_1_default)
            isolation_probabilities_day_1[k] = isolation_probabilities_day_1_default[k]
            isolation_probabilities_day_2[k] = isolation_probabilities_day_2_default[k]
            isolation_probabilities_day_3[k] = isolation_probabilities_day_3_default[k]
        end
        recovered_duration_mean = recovered_duration_mean_default
        recovered_duration_sd = recovered_duration_sd_default
        for k = 1:length(mean_household_contact_durations_default)
            mean_household_contact_durations[k] = mean_household_contact_durations_default[k]
            household_contact_duration_sds[k] = household_contact_duration_sds_default[k]
        end
        for k = 1:length(other_contact_duration_scales_default)
            other_contact_duration_shapes[k] = other_contact_duration_shapes_default[k]
            other_contact_duration_scales[k] = other_contact_duration_scales_default[k]
        end

        duration_parameter = duration_parameter_default
        for k = 1:length(susceptibility_parameters_default)
            susceptibility_parameters[k] = susceptibility_parameters_default[k]
            temperature_parameters[k] = temperature_parameters_default[k]
        end

        for k = 1:length(random_infection_probabilities_default)
            random_infection_probabilities[k] = random_infection_probabilities_default[k]
        end

        for k = 1:length(incubation_period_durations_default)
            incubation_period_durations[k] = incubation_period_durations_default[k]
            incubation_period_duration_variances[k] = incubation_period_duration_variances_default[k]
            infection_period_durations_child[k] = infection_period_durations_child_default[k]
            infection_period_duration_variances_child[k] = infection_period_duration_variances_child_default[k]
            infection_period_durations_adult[k] = infection_period_durations_adult_default[k]
            infection_period_duration_variances_adult[k] = infection_period_duration_variances_adult_default[k]
            symptomatic_probabilities_child[k] = symptomatic_probabilities_child_default[k]
            symptomatic_probabilities_teenager[k] = symptomatic_probabilities_teenager_default[k]
            symptomatic_probabilities_adult[k] = symptomatic_probabilities_adult_default[k]
            mean_viral_loads_infant[k] = mean_viral_loads_infant_default[k]
            mean_viral_loads_child[k] = mean_viral_loads_child_default[k]
            mean_viral_loads_adult[k] = mean_viral_loads_adult_default[k]
            immune_memory_susceptibility_levels[k] = immune_memory_susceptibility_levels_default[k]
            mean_immunity_durations[k] = mean_immunity_durations_default[k]
        end

        # Disturbance
        for k = 1:length(isolation_probabilities_day_1)
            isolation_probabilities_day_1[k] += rand(Normal(0.0, disturbance * isolation_probabilities_day_1[k]))
            isolation_probabilities_day_2[k] += rand(Normal(0.0, disturbance * isolation_probabilities_day_2[k]))
            isolation_probabilities_day_3[k] += rand(Normal(0.0, disturbance * isolation_probabilities_day_3[k]))
        end
        recovered_duration_mean += rand(Normal(0.0, disturbance * recovered_duration_mean))
        recovered_duration_sd += rand(Normal(0.0, disturbance * recovered_duration_sd))

        for k = 1:length(mean_household_contact_durations)
            mean_household_contact_durations[k] += rand(Normal(0.0, disturbance * mean_household_contact_durations[k]))
            household_contact_duration_sds[k] += rand(Normal(0.0, disturbance * household_contact_duration_sds[k]))
        end
        for k = 1:length(other_contact_duration_scales)
            other_contact_duration_shapes[k] += rand(Normal(0.0, disturbance * other_contact_duration_shapes[k]))
            other_contact_duration_scales[k] += rand(Normal(0.0, disturbance * other_contact_duration_scales[k]))
        end

        duration_parameter += rand(Normal(0.0, disturbance * duration_parameter))
        for k = 1:length(susceptibility_parameters)
            susceptibility_parameters[k] += rand(Normal(0.0, disturbance * susceptibility_parameters[k]))
            temperature_parameters[k] += rand(Normal(0.0, -disturbance * temperature_parameters[k]))
        end

        for k = 1:length(random_infection_probabilities)
            random_infection_probabilities[k] += rand(Normal(0.0, disturbance * random_infection_probabilities[k]))
        end

        for k = 1:length(incubation_period_durations)
            incubation_period_durations[k] += rand(Normal(0.0, disturbance * incubation_period_durations[k]))
            infection_period_durations_child[k] += rand(Normal(0.0, disturbance * infection_period_durations_child[k]))
            infection_period_duration_variances_child[k] += rand(Normal(0.0, disturbance * infection_period_duration_variances_child[k]))
            infection_period_durations_adult[k] += rand(Normal(0.0, disturbance * infection_period_durations_adult[k]))
            infection_period_duration_variances_adult[k] += rand(Normal(0.0, disturbance * infection_period_duration_variances_adult[k]))
            symptomatic_probabilities_child[k] += rand(Normal(0.0, disturbance * symptomatic_probabilities_child[k]))
            symptomatic_probabilities_teenager[k] += rand(Normal(0.0, disturbance * symptomatic_probabilities_teenager[k]))
            symptomatic_probabilities_adult[k] += rand(Normal(0.0, disturbance * symptomatic_probabilities_adult[k]))
            mean_viral_loads_infant[k] += rand(Normal(0.0, disturbance * mean_viral_loads_infant[k]))
            mean_viral_loads_child[k] += rand(Normal(0.0, disturbance * mean_viral_loads_child[k]))
            mean_viral_loads_adult[k] += rand(Normal(0.0, disturbance * mean_viral_loads_adult[k]))
            immune_memory_susceptibility_levels[k] += rand(Normal(0.0, disturbance * immune_memory_susceptibility_levels[k]))
            mean_immunity_durations[k] += rand(Normal(0.0, disturbance * mean_immunity_durations[k]))
        end

        for k = 1:length(viruses)
            viruses[k].mean_incubation_period = incubation_period_durations[k]
            viruses[k].incubation_period_variance = incubation_period_duration_variances[k]
            viruses[k].mean_infection_period_child = infection_period_durations_child[k]
            viruses[k].infection_period_variance_child = infection_period_duration_variances_child[k]
            viruses[k].mean_infection_period_adult = infection_period_durations_adult[k]
            viruses[k].infection_period_variance_adult = infection_period_duration_variances_adult[k]
            viruses[k].symptomatic_probability_child = symptomatic_probabilities_child[k]
            viruses[k].symptomatic_probability_teenager = symptomatic_probabilities_teenager[k]
            viruses[k].symptomatic_probability_adult = symptomatic_probabilities_adult[k]
            viruses[k].mean_viral_load_toddler = mean_viral_loads_infant[k]
            viruses[k].mean_viral_load_child = mean_viral_loads_child[k]
            viruses[k].mean_viral_load_adult = mean_viral_loads_adult[k]
        end

        @threads for thread_id in 1:num_threads
            reset_agent_states(
                agents,
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                viruses,
                num_all_infected_age_groups_viruses,
                isolation_probabilities_day_1,
                isolation_probabilities_day_2,
                isolation_probabilities_day_3,
                thread_rng[thread_id],
                immune_memory_susceptibility_levels[1],
                immune_memory_susceptibility_levels[2],
                immune_memory_susceptibility_levels[3],
                immune_memory_susceptibility_levels[4],
                immune_memory_susceptibility_levels[5],
                immune_memory_susceptibility_levels[6],
                immune_memory_susceptibility_levels[7],
            )
        end

        @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
            num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
            susceptibility_parameters, temperature_parameters, temperature,
            mean_household_contact_durations, household_contact_duration_sds,
            other_contact_duration_shapes, other_contact_duration_scales,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probabilities,
            recovered_duration_mean, recovered_duration_sd, num_years, true,
            immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
            immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
            immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
            immune_memory_susceptibility_levels[7])

        save(joinpath(@__DIR__, "..", "sensitivity", "tables", "results_$(run_num + starting_bias).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses,
            "activities_cases", activities_infections,
            "rt", rt,
            "isolation_probabilities_day_1", isolation_probabilities_day_1,
            "isolation_probabilities_day_2", isolation_probabilities_day_2,
            "isolation_probabilities_day_3", isolation_probabilities_day_3,
            "recovered_duration_mean", recovered_duration_mean,
            "recovered_duration_sd", recovered_duration_sd,
            "mean_household_contact_durations", mean_household_contact_durations,
            "household_contact_duration_sds", household_contact_duration_sds,
            "other_contact_duration_shapes", other_contact_duration_shapes,
            "other_contact_duration_scales", other_contact_duration_scales,
            "duration_parameter", duration_parameter,
            "susceptibility_parameters", susceptibility_parameters,
            "temperature_parameters", temperature_parameters,
            "random_infection_probabilities", random_infection_probabilities,
            "immune_memory_susceptibility_levels", immune_memory_susceptibility_levels,
            "mean_immunity_durations", mean_immunity_durations,
            "incubation_period_durations", incubation_period_durations,
            "incubation_period_duration_variances", incubation_period_duration_variances,
            "infection_period_durations_child", infection_period_durations_child,
            "infection_period_duration_variances_child", infection_period_duration_variances_child,
            "infection_period_durations_adult", infection_period_durations_adult,
            "infection_period_duration_variances_adult", infection_period_duration_variances_adult,
            "symptomatic_probabilities_child", symptomatic_probabilities_child,
            "symptomatic_probabilities_teenager", symptomatic_probabilities_teenager,
            "symptomatic_probabilities_adult", symptomatic_probabilities_adult,
            "mean_viral_loads_infant", mean_viral_loads_infant,
            "mean_viral_loads_child", mean_viral_loads_child,
            "mean_viral_loads_adult", mean_viral_loads_adult)
    end
end

main()
