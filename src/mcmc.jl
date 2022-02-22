# using Base.Threads
# using Distributions
# using Random
# using DelimitedFiles
# using DataFrames
# using CSV

# include("global/variables.jl")

# include("model/virus.jl")
# include("model/agent.jl")
# include("model/group.jl")
# include("model/household.jl")
# include("model/workplace.jl")
# include("model/school.jl")
# include("model/public_space.jl")
# include("model/initialization.jl")
# include("model/simulation.jl")
# include("model/connections.jl")

# include("data/district_households.jl")
# include("data/district_people.jl")
# include("data/district_people_households.jl")
# include("data/district_nums.jl")
# include("data/temperature.jl")
# include("data/etiology.jl")

# include("util/moving_avg.jl")
# include("util/reset.jl")

# function f(x, mu, sigma)
#     dist = Normal(mu, sigma)
#     return cdf(dist, x + 0.5) - cdf(dist, x - 0.5)
# end

# function log_g(x, mu, sigma)
#     return -log(sqrt(2 * pi) * sigma) - 0.5 * ((x - mu) / sigma)^2
# end

# # Not used
# function main()
#     println("Initialization...")

#     num_threads = nthreads()

#     # Вероятности изолироваться при болезни на 1-й, 2-й и 3-й дни
#     isolation_probabilities_day_1 = [0.406, 0.305, 0.204, 0.101]
#     isolation_probabilities_day_2 = [0.669, 0.576, 0.499, 0.334]
#     isolation_probabilities_day_3 = [0.45, 0.325, 0.376, 0.168]
#     # Продолжительность резистентного состояния
#     recovered_duration_mean = 12.0
#     recovered_duration_sd = 4.0
#     # Продолжительности контактов в домохозяйствах
#     # Укороченные для различных коллективов и полная: Kinder, School, College, Work, Full
#     mean_household_contact_durations = [6.5, 5.8, 9.0, 4.5, 12.0]
#     household_contact_duration_sds = [2.2, 2.0, 3.0, 1.5, 4.0]
#     # Продолжительности контактов в прочих коллективах
#     other_contact_duration_shapes = [2.5, 1.78, 2.0, 1.81, 1.2]
#     other_contact_duration_scales = [1.6, 1.95, 1.07, 1.7, 1.07]
#     # Параметры, отвечающие за связи на рабочих местах
#     firm_min_size = 0
#     firm_max_size = 1000
#     num_barabasi_albert_attachments = 5

#     duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
#     duration_parameter = duration_parameter_array[end]
    
#     susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
#     susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
#     susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
#     susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
#     susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
#     susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
#     susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))
#     susceptibility_parameters = [
#         susceptibility_parameter_1_array[end],
#         susceptibility_parameter_2_array[end],
#         susceptibility_parameter_3_array[end],
#         susceptibility_parameter_4_array[end],
#         susceptibility_parameter_5_array[end],
#         susceptibility_parameter_6_array[end],
#         susceptibility_parameter_7_array[end]
#     ]

#     temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
#     temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
#     temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
#     temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
#     temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
#     temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
#     temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))
#     temperature_parameters = -[
#         temperature_parameter_1_array[end],
#         temperature_parameter_2_array[end],
#         temperature_parameter_3_array[end],
#         temperature_parameter_4_array[end],
#         temperature_parameter_5_array[end],
#         temperature_parameter_6_array[end],
#         temperature_parameter_7_array[end]
#     ]
#     # mean_immunity_durations = [
#     #     mean_immunity_duration_1_array[end],
#     #     mean_immunity_duration_2_array[end],
#     #     mean_immunity_duration_3_array[end],
#     #     mean_immunity_duration_4_array[end],
#     #     mean_immunity_duration_5_array[end],
#     #     mean_immunity_duration_6_array[end],
#     #     mean_immunity_duration_7_array[end],
#     # ]
#     mean_immunity_durations = [253.96825396825392, 314.95031952174816, 97.14759843331271, 22.70171098742527, 80.84188827045969, 114.48526077097503, 85.45660688517833]

#     random_infection_probabilities = [0.00011537414965986393, 6.832319109461966e-5, 4.910216450216453e-5, 6.985549371263659e-7]

#     viruses = Virus[
#         # FluA
#         Virus(1.4, 0.09, 1, 7,  4.8, 1.12, 3, 21,  8.8, 3.748, 3, 21,  4.6, 3.5, 2.3,  0.38, 0.47, 0.57,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
#         # FluB
#         Virus(1.0, 0.0484, 1, 7,  3.7, 0.66, 3, 21,  7.8, 2.94, 3, 21,  4.7, 3.5, 2.4,  0.38, 0.47, 0.57,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
#         # RV
#         Virus(1.9, 0.175, 1, 7,  10.1, 4.93, 3, 21,  11.4, 6.25, 3, 21,  3.5, 2.6, 1.8,  0.19, 0.24, 0.29,  mean_immunity_durations[3], mean_immunity_durations[3] * 0.33),
#         # RSV
#         Virus(4.4, 0.937, 1, 7,  7.4, 2.66, 3, 21,  9.3, 4.0, 3, 21,  6.0, 4.5, 3.0,  0.24, 0.3, 0.36,  mean_immunity_durations[4], mean_immunity_durations[4] * 0.33),
#         # AdV
#         Virus(5.6, 1.51, 1, 7,  8.0, 3.1, 3, 21,  9.0, 3.92, 3, 21,  4.1, 3.1, 2.1,  0.15, 0.19, 0.23,  mean_immunity_durations[5], mean_immunity_durations[5] * 0.33),
#         # PIV
#         Virus(2.6, 0.327, 1, 7,  7.0, 2.37, 3, 21,  8.0, 3.1, 3, 21,  4.8, 3.6, 2.4,  0.16, 0.2, 0.24,  mean_immunity_durations[6], mean_immunity_durations[6] * 0.33),
#         # CoV
#         Virus(3.2, 0.496, 1, 7,  6.5, 2.15, 3, 21,  7.5, 2.9, 3, 21,  4.9, 3.7, 2.5,  0.21, 0.26, 0.32,  mean_immunity_durations[7], mean_immunity_durations[7] * 0.33)]

#     # Число домохозяйств каждого типа по районам
#     district_households = get_district_households()
#     # Число людей в каждой группе по районам
#     district_people = get_district_people()
#     # Число людей в домохозяйствах по районам
#     district_people_households = get_district_people_households()
#     # Распределение вирусов в течение года
#     etiology = get_etiology()
#     # Номера районов для MPI процессов
#     district_nums = get_district_nums()
#     # Температура воздуха, начиная с 1 января
#     temperature = get_air_temperature()

#     agents = Array{Agent, 1}(undef, num_agents)

#     # With seed
#     thread_rng = [MersenneTwister(i) for i = 1:num_threads]

#     homes_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "homes.csv")))
#     # Массив для хранения домохозяйств
#     households = Array{Household, 1}(undef, num_households)

#     kindergarten_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "kindergartens.csv")))
#     # Массив для хранения детских садов
#     kindergartens = Array{School, 1}(undef, num_kindergartens)
#     for i in 1:size(kindergarten_coords_df, 1)
#         kindergartens[i] = School(
#             1,
#             kindergarten_coords_df[i, :dist],
#             kindergarten_coords_df[i, :x],
#             kindergarten_coords_df[i, :y],
#         )
#     end

#     school_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "schools.csv")))
#     # Массив для хранения школ
#     schools = Array{School, 1}(undef, num_schools)
#     for i in 1:size(school_coords_df, 1)
#         schools[i] = School(
#             2,
#             school_coords_df[i, :dist],
#             school_coords_df[i, :x],
#             school_coords_df[i, :y],
#         )
#     end

#     college_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "colleges.csv")))
#     # Массив для хранения институтов
#     colleges = Array{School, 1}(undef, num_colleges)
#     for i in 1:size(college_coords_df, 1)
#         colleges[i] = School(
#             3,
#             college_coords_df[i, :dist],
#             college_coords_df[i, :x],
#             college_coords_df[i, :y],
#         )
#     end

#     # Массив для хранения фирм
#     workplaces = Workplace[]

#     infected_data_0 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
#     infected_data_3 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
#     infected_data_7 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
#     infected_data_15 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

#     infected_data_0 = infected_data_0[2:53, 21:27]
#     infected_data_0_1 = etiology[:, 1] .* infected_data_0
#     infected_data_0_2 = etiology[:, 2] .* infected_data_0
#     infected_data_0_3 = etiology[:, 3] .* infected_data_0
#     infected_data_0_4 = etiology[:, 4] .* infected_data_0
#     infected_data_0_5 = etiology[:, 5] .* infected_data_0
#     infected_data_0_6 = etiology[:, 6] .* infected_data_0
#     infected_data_0_7 = etiology[:, 7] .* infected_data_0
#     infected_data_0_viruses = cat(
#         infected_data_0_1,
#         infected_data_0_2,
#         infected_data_0_3,
#         infected_data_0_4,
#         infected_data_0_5,
#         infected_data_0_6,
#         infected_data_0_7,
#         dims = 3)

#     infected_data_3 = infected_data_3[2:53, 21:27]
#     infected_data_3_1 = etiology[:, 1] .* infected_data_3
#     infected_data_3_2 = etiology[:, 2] .* infected_data_3
#     infected_data_3_3 = etiology[:, 3] .* infected_data_3
#     infected_data_3_4 = etiology[:, 4] .* infected_data_3
#     infected_data_3_5 = etiology[:, 5] .* infected_data_3
#     infected_data_3_6 = etiology[:, 6] .* infected_data_3
#     infected_data_3_7 = etiology[:, 7] .* infected_data_3
#     infected_data_3_viruses = cat(
#         infected_data_3_1,
#         infected_data_3_2,
#         infected_data_3_3,
#         infected_data_3_4,
#         infected_data_3_5,
#         infected_data_3_6,
#         infected_data_3_7,
#         dims = 3)

#     infected_data_7 = infected_data_7[2:53, 21:27]
#     infected_data_7_1 = etiology[:, 1] .* infected_data_7
#     infected_data_7_2 = etiology[:, 2] .* infected_data_7
#     infected_data_7_3 = etiology[:, 3] .* infected_data_7
#     infected_data_7_4 = etiology[:, 4] .* infected_data_7
#     infected_data_7_5 = etiology[:, 5] .* infected_data_7
#     infected_data_7_6 = etiology[:, 6] .* infected_data_7
#     infected_data_7_7 = etiology[:, 7] .* infected_data_7
#     infected_data_7_viruses = cat(
#         infected_data_7_1,
#         infected_data_7_2,
#         infected_data_7_3,
#         infected_data_7_4,
#         infected_data_7_5,
#         infected_data_7_6,
#         infected_data_7_7,
#         dims = 3)

#     infected_data_15 = infected_data_15[2:53, 21:27]
#     infected_data_15_1 = etiology[:, 1] .* infected_data_15
#     infected_data_15_2 = etiology[:, 2] .* infected_data_15
#     infected_data_15_3 = etiology[:, 3] .* infected_data_15
#     infected_data_15_4 = etiology[:, 4] .* infected_data_15
#     infected_data_15_5 = etiology[:, 5] .* infected_data_15
#     infected_data_15_6 = etiology[:, 6] .* infected_data_15
#     infected_data_15_7 = etiology[:, 7] .* infected_data_15
#     infected_data_15_viruses = cat(
#         infected_data_15_1,
#         infected_data_15_2,
#         infected_data_15_3,
#         infected_data_15_4,
#         infected_data_15_5,
#         infected_data_15_6,
#         infected_data_15_7,
#         dims = 3)

#     infected_data_0_viruses_mean = mean(infected_data_0_viruses, dims = 2)[:, 1, :]
#     infected_data_3_viruses_mean = mean(infected_data_3_viruses, dims = 2)[:, 1, :]
#     infected_data_7_viruses_mean = mean(infected_data_7_viruses, dims = 2)[:, 1, :]
#     infected_data_15_viruses_mean = mean(infected_data_15_viruses, dims = 2)[:, 1, :]

#     num_infected_age_groups_viruses_mean = cat(
#         infected_data_0_viruses_mean,
#         infected_data_3_viruses_mean,
#         infected_data_7_viruses_mean,
#         infected_data_15_viruses_mean,
#         dims = 3,
#     )

#     num_all_infected_age_groups_viruses_mean = copy(num_infected_age_groups_viruses_mean)
#     for virus_id = 1:length(viruses)
#         num_all_infected_age_groups_viruses_mean[:, virus_id, 1] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[1]) * (1 - isolation_probabilities_day_2[1]) * (1 - isolation_probabilities_day_3[1]))
#         num_all_infected_age_groups_viruses_mean[:, virus_id, 2] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[2]) * (1 - isolation_probabilities_day_2[2]) * (1 - isolation_probabilities_day_3[2]))
#         num_all_infected_age_groups_viruses_mean[:, virus_id, 3] ./= viruses[virus_id].symptomatic_probability_teenager * (1 - (1 - isolation_probabilities_day_1[3]) * (1 - isolation_probabilities_day_2[3]) * (1 - isolation_probabilities_day_3[3]))
#         num_all_infected_age_groups_viruses_mean[:, virus_id, 4] ./= viruses[virus_id].symptomatic_probability_adult * (1 - (1 - isolation_probabilities_day_1[4]) * (1 - isolation_probabilities_day_2[4]) * (1 - isolation_probabilities_day_3[4]))
#     end

#     @time @threads for thread_id in 1:num_threads
#         create_population(
#             thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
#             agents, households, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
#             isolation_probabilities_day_2, isolation_probabilities_day_3, start_household_ids[thread_id],
#             homes_coords_df, district_households, district_people, district_people_households, district_nums)
#     end

#     @time set_connections(
#         agents, households, kindergartens, schools, colleges,
#         workplaces, thread_rng, num_threads, homes_coords_df,
#         firm_min_size, firm_max_size, num_barabasi_albert_attachments)

#     # get_stats(agents, workplaces)
#     # return

#     println("Simulation...")

#     @time num_infected_age_groups_viruses, rt = run_simulation(
#         num_threads, thread_rng, agents, viruses, households, duration_parameter,
#         susceptibility_parameters, temperature_parameters, temperature,
#         mean_household_contact_durations, household_contact_duration_sds,
#         other_contact_duration_shapes, other_contact_duration_scales,
#         isolation_probabilities_day_1, isolation_probabilities_day_2,
#         isolation_probabilities_day_3, random_infection_probabilities,
#         recovered_duration_mean, recovered_duration_sd, false)

#     MAE = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean)) / (size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3])
#     RMSE = sqrt(sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)) / sqrt((size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3]))
#     nMAE = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean)) / sum(num_infected_age_groups_viruses_mean)
#     S_square = sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)
    
#     accept_num = 0
#     local_rejected_num = 0

#     deltas = [
#         0.1,
#         0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1,
#         0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3,
#     ]

#     FluA_arr = [1.0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 25, 50, 60, 75, 310, 1675, 1850, 1500, 1250, 900, 375, 350, 290, 220, 175, 165, 100, 50, 40, 25, 15, 9, 4, 2, 1, 1, 1, 1, 1, 1, 1, 1]
#     FluA_arr2 = [1.0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 15, 44, 72, 50, 10, 80, 266, 333, 480, 588, 625, 575, 622, 423, 450, 269, 190, 138, 89, 60, 30, 20, 12, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1]

#     RV_arr = [50.0, 50, 86, 90, 70, 74, 97, 115, 158, 130, 131, 103, 112, 112, 136, 90, 111, 128, 130, 140, 118, 152, 49, 22, 51, 80, 82, 100, 78, 57, 70, 73, 102, 101, 80, 62, 68, 60, 66, 52, 42, 69, 74, 38, 50, 42, 36, 38, 24, 44, 45, 40]
#     RV_arr2 = [11.0, 10, 20, 24, 10, 20, 41, 42, 43, 54, 42, 52, 39, 37, 20, 15, 20, 38, 41, 28, 30, 21, 9, 1, 10, 50, 62, 52, 31, 40, 36, 41, 42, 32, 84, 71, 78, 72, 32, 28, 39, 37, 72, 67, 41, 52, 40, 24, 40, 39, 36, 30]
    
#     RSV_arr = [8.0, 8, 8, 8, 8, 5, 7, 8, 11, 11, 18, 14, 15, 18, 35, 55, 53, 70, 90, 130, 45, 30, 80, 140, 100, 120, 145, 180, 150, 68, 72, 60, 80, 75, 55, 60, 65, 62, 50, 45, 50, 20, 24, 19, 15, 10, 10, 9, 11, 10, 9, 8]
#     RSV_arr2 = [8.0, 9, 9, 4, 4, 10, 9, 10, 3, 12, 8, 10, 12, 7, 10, 13, 9, 15, 21, 25, 30, 10, 2, 22, 18, 30, 77, 72, 48, 61, 90, 120, 150, 145, 92, 119, 78, 69, 49, 57, 49, 43, 46, 24, 40, 24, 24, 10, 10, 9, 7, 11]

#     AdV_arr = [20.0, 30, 40, 20, 30, 25, 15, 19, 17, 18, 20, 25, 30, 21, 38, 40, 42, 30, 40, 50, 51, 41, 10, 8, 30, 40, 38, 70, 67, 20, 28, 20, 29, 20, 28, 16, 10, 20, 18, 27, 19, 19, 32, 31, 20, 20, 15, 8, 20, 35, 35, 35]
#     AdV_arr2 = [9.0, 11, 13, 5, 7, 12, 12, 18, 16, 22, 18, 22, 31, 32, 33, 17, 28, 39, 29, 40, 30, 56, 11, 1, 38, 30, 39, 28, 59, 19, 46, 20, 22, 47, 38, 40, 25, 17, 18, 10, 6, 6, 21, 11, 19, 12, 27, 18, 10, 27, 10, 10]

#     PIV_arr = [15.0, 18, 20, 33, 15, 36, 33, 38, 38, 50, 40, 43, 46, 75, 55, 35, 85, 53, 65, 40, 70, 20, 10, 45, 32, 33, 51, 34, 22, 12, 12, 14, 16, 18, 20, 8, 24, 20, 15, 5, 20, 15, 15, 20, 19, 18, 31, 18, 18, 17, 15, 14]
#     PIV_arr2 = [10.0, 11, 6, 8, 12, 19, 22, 20, 20, 22, 28, 32, 47, 29, 31, 38, 17, 40, 31, 36, 32, 48, 11, 6, 30, 38, 12, 30, 22, 12, 20, 17, 30, 45, 11, 14, 17, 15, 15, 10, 15, 20, 17, 18, 23, 10, 10, 18, 17, 16, 17, 14]

#     CoV_arr = [1.0, 2, 1, 2, 1, 1, 2, 1, 2, 1, 1, 2, 8, 10, 5, 7, 7, 14, 8, 25, 35, 30, 1, 5, 16, 14, 25, 35, 32, 50, 10, 18, 12, 30, 36, 25, 14, 16, 5, 3, 1, 3, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
#     CoV_arr2 = [5.0, 1, 1, 2, 1, 1, 6, 1, 3, 1, 1, 5, 9, 1, 5, 1, 1, 5, 1, 3, 2, 1, 5, 1, 3, 1, 1, 9, 5, 5, 9, 3, 4, 3, 12, 18, 16, 15, 7, 1, 13, 3, 3, 10, 2, 1, 1, 1, 1, 1, 1, 1]

#     FluA_arr = moving_average(FluA_arr, 3)
#     RV_arr = moving_average(RV_arr, 3)
#     RSV_arr = moving_average(RSV_arr, 3)
#     AdV_arr = moving_average(AdV_arr, 3)
#     PIV_arr = moving_average(PIV_arr, 3)
#     CoV_arr = moving_average(CoV_arr, 3)

#     FluA_arr2 = moving_average(FluA_arr2, 3)
#     RV_arr2 = moving_average(RV_arr2, 3)
#     RSV_arr2 = moving_average(RSV_arr2, 3)
#     AdV_arr2 = moving_average(AdV_arr2, 3)
#     PIV_arr2 = moving_average(PIV_arr2, 3)
#     CoV_arr2 = moving_average(CoV_arr2, 3)

#     FluB_arr = FluA_arr .* 1/3
#     FluB_arr2 = FluA_arr2 .* 1/3

#     sum_arr = FluA_arr + FluB_arr + RV_arr + RSV_arr + AdV_arr + PIV_arr + CoV_arr
#     sum_arr2 = FluA_arr2 + FluB_arr2 + RV_arr2 + RSV_arr2 + AdV_arr2 + PIV_arr2 + CoV_arr2

#     FluA_ratio = FluA_arr ./ sum_arr
#     FluB_ratio = FluB_arr ./ sum_arr
#     RV_ratio = RV_arr ./ sum_arr
#     RSV_ratio = RSV_arr ./ sum_arr
#     AdV_ratio = AdV_arr ./ sum_arr
#     PIV_ratio = PIV_arr ./ sum_arr
#     CoV_ratio = CoV_arr ./ sum_arr

#     FluA_ratio2 = FluA_arr2 ./ sum_arr2
#     FluB_ratio2 = FluB_arr2 ./ sum_arr2
#     RV_ratio2 = RV_arr2 ./ sum_arr2
#     RSV_ratio2 = RSV_arr2 ./ sum_arr2
#     AdV_ratio2 = AdV_arr2 ./ sum_arr2
#     PIV_ratio2 = PIV_arr2 ./ sum_arr2
#     CoV_ratio2 = CoV_arr2 ./ sum_arr2

#     FluA_ratio = moving_average(FluA_ratio, 3)
#     FluB_ratio = moving_average(FluB_ratio, 3)
#     RV_ratio = moving_average(RV_ratio, 3)
#     RSV_ratio = moving_average(RSV_ratio, 3)
#     AdV_ratio = moving_average(AdV_ratio, 3)
#     PIV_ratio = moving_average(PIV_ratio, 3)
#     CoV_ratio = moving_average(CoV_ratio, 3)

#     FluA_ratio2 = moving_average(FluA_ratio2, 3)
#     FluB_ratio2 = moving_average(FluB_ratio2, 3)
#     RV_ratio2 = moving_average(RV_ratio2, 3)
#     RSV_ratio2 = moving_average(RSV_ratio2, 3)
#     AdV_ratio2 = moving_average(AdV_ratio2, 3)
#     PIV_ratio2 = moving_average(PIV_ratio2, 3)
#     CoV_ratio2 = moving_average(CoV_ratio2, 3)

#     etiology = hcat(FluA_ratio, FluB_ratio, RV_ratio, RSV_ratio, AdV_ratio, PIV_ratio, CoV_ratio)
#     etiology2 = hcat(FluA_ratio2, FluB_ratio2, RV_ratio2, RSV_ratio2, AdV_ratio2, PIV_ratio2, CoV_ratio2)

#     infected_data_0 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
#     infected_data_3 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
#     infected_data_7 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
#     infected_data_15 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

#     infected_data_0 = infected_data_0[2:53, 21:27]
#     infected_data_0_1 = etiology[:, 1] .* infected_data_0
#     infected_data_0_2 = etiology[:, 2] .* infected_data_0
#     infected_data_0_3 = etiology[:, 3] .* infected_data_0
#     infected_data_0_4 = etiology[:, 4] .* infected_data_0
#     infected_data_0_5 = etiology[:, 5] .* infected_data_0
#     infected_data_0_6 = etiology[:, 6] .* infected_data_0
#     infected_data_0_7 = etiology[:, 7] .* infected_data_0

#     infected_data_0_viruses_1 = cat(
#         infected_data_0_1,
#         infected_data_0_2,
#         infected_data_0_3,
#         infected_data_0_4,
#         infected_data_0_5,
#         infected_data_0_6,
#         infected_data_0_7,
#         dims = 3)
#     infected_data_0_1_2 = etiology2[:, 1] .* infected_data_0
#     infected_data_0_2_2 = etiology2[:, 2] .* infected_data_0
#     infected_data_0_3_2 = etiology2[:, 3] .* infected_data_0
#     infected_data_0_4_2 = etiology2[:, 4] .* infected_data_0
#     infected_data_0_5_2 = etiology2[:, 5] .* infected_data_0
#     infected_data_0_6_2 = etiology2[:, 6] .* infected_data_0
#     infected_data_0_7_2 = etiology2[:, 7] .* infected_data_0
#     infected_data_0_viruses_2 = cat(
#         infected_data_0_1_2,
#         infected_data_0_2_2,
#         infected_data_0_3_2,
#         infected_data_0_4_2,
#         infected_data_0_5_2,
#         infected_data_0_6_2,
#         infected_data_0_7_2,
#         dims = 3)

#     infected_data_3 = infected_data_3[2:53, 21:27]
#     infected_data_3_1 = etiology[:, 1] .* infected_data_3
#     infected_data_3_2 = etiology[:, 2] .* infected_data_3
#     infected_data_3_3 = etiology[:, 3] .* infected_data_3
#     infected_data_3_4 = etiology[:, 4] .* infected_data_3
#     infected_data_3_5 = etiology[:, 5] .* infected_data_3
#     infected_data_3_6 = etiology[:, 6] .* infected_data_3
#     infected_data_3_7 = etiology[:, 7] .* infected_data_3
#     infected_data_3_viruses_1 = cat(
#         infected_data_3_1,
#         infected_data_3_2,
#         infected_data_3_3,
#         infected_data_3_4,
#         infected_data_3_5,
#         infected_data_3_6,
#         infected_data_3_7,
#         dims = 3)
#     infected_data_3_1_2 = etiology2[:, 1] .* infected_data_3
#     infected_data_3_2_2 = etiology2[:, 2] .* infected_data_3
#     infected_data_3_3_2 = etiology2[:, 3] .* infected_data_3
#     infected_data_3_4_2 = etiology2[:, 4] .* infected_data_3
#     infected_data_3_5_2 = etiology2[:, 5] .* infected_data_3
#     infected_data_3_6_2 = etiology2[:, 6] .* infected_data_3
#     infected_data_3_7_2 = etiology2[:, 7] .* infected_data_3
#     infected_data_3_viruses_2 = cat(
#         infected_data_3_1_2,
#         infected_data_3_2_2,
#         infected_data_3_3_2,
#         infected_data_3_4_2,
#         infected_data_3_5_2,
#         infected_data_3_6_2,
#         infected_data_3_7_2,
#         dims = 3)

#     infected_data_7 = infected_data_7[2:53, 21:27]
#     infected_data_7_1 = etiology[:, 1] .* infected_data_7
#     infected_data_7_2 = etiology[:, 2] .* infected_data_7
#     infected_data_7_3 = etiology[:, 3] .* infected_data_7
#     infected_data_7_4 = etiology[:, 4] .* infected_data_7
#     infected_data_7_5 = etiology[:, 5] .* infected_data_7
#     infected_data_7_6 = etiology[:, 6] .* infected_data_7
#     infected_data_7_7 = etiology[:, 7] .* infected_data_7
#     infected_data_7_viruses_1 = cat(
#         infected_data_7_1,
#         infected_data_7_2,
#         infected_data_7_3,
#         infected_data_7_4,
#         infected_data_7_5,
#         infected_data_7_6,
#         infected_data_7_7,
#         dims = 3)
#     infected_data_7_1_2 = etiology2[:, 1] .* infected_data_7
#     infected_data_7_2_2 = etiology2[:, 2] .* infected_data_7
#     infected_data_7_3_2 = etiology2[:, 3] .* infected_data_7
#     infected_data_7_4_2 = etiology2[:, 4] .* infected_data_7
#     infected_data_7_5_2 = etiology2[:, 5] .* infected_data_7
#     infected_data_7_6_2 = etiology2[:, 6] .* infected_data_7
#     infected_data_7_7_2 = etiology2[:, 7] .* infected_data_7
#     infected_data_7_viruses_2 = cat(
#         infected_data_7_1_2,
#         infected_data_7_2_2,
#         infected_data_7_3_2,
#         infected_data_7_4_2,
#         infected_data_7_5_2,
#         infected_data_7_6_2,
#         infected_data_7_7_2,
#         dims = 3)

#     infected_data_15 = infected_data_15[2:53, 21:27]
#     infected_data_15_1 = etiology[:, 1] .* infected_data_15
#     infected_data_15_2 = etiology[:, 2] .* infected_data_15
#     infected_data_15_3 = etiology[:, 3] .* infected_data_15
#     infected_data_15_4 = etiology[:, 4] .* infected_data_15
#     infected_data_15_5 = etiology[:, 5] .* infected_data_15
#     infected_data_15_6 = etiology[:, 6] .* infected_data_15
#     infected_data_15_7 = etiology[:, 7] .* infected_data_15
#     infected_data_15_viruses_1 = cat(
#         infected_data_15_1,
#         infected_data_15_2,
#         infected_data_15_3,
#         infected_data_15_4,
#         infected_data_15_5,
#         infected_data_15_6,
#         infected_data_15_7,
#         dims = 3)
#     infected_data_15_1_2 = etiology2[:, 1] .* infected_data_15
#     infected_data_15_2_2 = etiology2[:, 2] .* infected_data_15
#     infected_data_15_3_2 = etiology2[:, 3] .* infected_data_15
#     infected_data_15_4_2 = etiology2[:, 4] .* infected_data_15
#     infected_data_15_5_2 = etiology2[:, 5] .* infected_data_15
#     infected_data_15_6_2 = etiology2[:, 6] .* infected_data_15
#     infected_data_15_7_2 = etiology2[:, 7] .* infected_data_15
#     infected_data_15_viruses_2 = cat(
#         infected_data_15_1_2,
#         infected_data_15_2_2,
#         infected_data_15_3_2,
#         infected_data_15_4_2,
#         infected_data_15_5_2,
#         infected_data_15_6_2,
#         infected_data_15_7_2,
#         dims = 3)

#     infected_data_0_viruses = (infected_data_0_viruses_1 + infected_data_0_viruses_2) ./ 2
#     infected_data_3_viruses = (infected_data_3_viruses_1 + infected_data_3_viruses_2) ./ 2
#     infected_data_7_viruses = (infected_data_7_viruses_1 + infected_data_7_viruses_2) ./ 2
#     infected_data_15_viruses = (infected_data_15_viruses_1 + infected_data_15_viruses_2) ./ 2

#     infected_data_0_viruses = cat(infected_data_0_viruses_1, infected_data_0_viruses_2, dims = 2)
#     infected_data_3_viruses = cat(infected_data_3_viruses_1, infected_data_3_viruses_2, dims = 2)
#     infected_data_7_viruses = cat(infected_data_7_viruses_1, infected_data_7_viruses_2, dims = 2)
#     infected_data_15_viruses = cat(infected_data_15_viruses_1, infected_data_15_viruses_2, dims = 2)

#     infected_data_0_viruses_sd = std(infected_data_0_viruses, dims = 2)[:, 1, :]
#     infected_data_3_viruses_sd = std(infected_data_3_viruses, dims = 2)[:, 1, :]
#     infected_data_7_viruses_sd = std(infected_data_7_viruses, dims = 2)[:, 1, :]
#     infected_data_15_viruses_sd = std(infected_data_15_viruses, dims = 2)[:, 1, :]

#     num_infected_age_groups_viruses_sd = cat(
#         infected_data_0_viruses_sd,
#         infected_data_3_viruses_sd,
#         infected_data_7_viruses_sd,
#         infected_data_15_viruses_sd,
#         dims = 3,
#     )

#     prob_prev_age_groups = zeros(Float64, 7, 4, 52)
#     for i in 1:52
#         for j in 1:4
#             for k in 1:7
#                 prob_prev_age_groups[k, j, i] = log_g(num_infected_age_groups_viruses[i, k, j], num_infected_age_groups_viruses_mean[i, k, j], num_infected_age_groups_viruses_sd[i, k, j])
#             end
#         end
#     end
#     # prob_prev_age_groups = zeros(Float64, 7, 4, 52)
#     # for i in 1:52
#     #     for j in 1:4
#     #         for k in 1:7
#     #             prob_prev_age_groups[k, j, i] = f(num_infected_age_groups_viruses[i, k, j], num_infected_age_groups_viruses_mean[i, k, j], num_infected_age_groups_viruses_sd[i, k, j])
#     #         end
#     #     end
#     # end

#     open("parameters/output.txt", "a") do io
#         println(io, "n = ", 0)
#         println(io, "MAE = ", MAE)
#         println(io, "RMSE = ", RMSE)
#         println(io, "nMAE = ", nMAE)
#         println(io, "S_square = ", S_square)
#         println(io)
#     end

#     n = 1
#     N = 1000
#     while n <= N
#         duration_parameter_candidate = exp(rand(Normal(log(duration_parameter_array[end]), deltas[1])))

#         susceptibility_parameter_1_candidate = exp(rand(Normal(log(susceptibility_parameter_1_array[end]), deltas[2])))
#         susceptibility_parameter_2_candidate = exp(rand(Normal(log(susceptibility_parameter_2_array[end]), deltas[3])))
#         susceptibility_parameter_3_candidate = exp(rand(Normal(log(susceptibility_parameter_3_array[end]), deltas[4])))
#         susceptibility_parameter_4_candidate = exp(rand(Normal(log(susceptibility_parameter_4_array[end]), deltas[5])))
#         susceptibility_parameter_5_candidate = exp(rand(Normal(log(susceptibility_parameter_5_array[end]), deltas[6])))
#         susceptibility_parameter_6_candidate = exp(rand(Normal(log(susceptibility_parameter_6_array[end]), deltas[7])))
#         susceptibility_parameter_7_candidate = exp(rand(Normal(log(susceptibility_parameter_7_array[end]), deltas[8])))

#         x = temperature_parameter_1_array[end]
#         y = rand(Normal(log(x / (1 - x)), deltas[9]))
#         temperature_parameter_1_candidate = exp(y) / (1 + exp(y))

#         x = temperature_parameter_2_array[end]
#         y = rand(Normal(log(x / (1 - x)), deltas[10]))
#         temperature_parameter_2_candidate = exp(y) / (1 + exp(y))

#         x = temperature_parameter_3_array[end]
#         y = rand(Normal(log(x / (1 - x)), deltas[11]))
#         temperature_parameter_3_candidate = exp(y) / (1 + exp(y))

#         x = temperature_parameter_4_array[end]
#         y = rand(Normal(log(x / (1 - x)), deltas[12]))
#         temperature_parameter_4_candidate = exp(y) / (1 + exp(y))

#         x = temperature_parameter_5_array[end]
#         y = rand(Normal(log(x / (1 - x)), deltas[13]))
#         temperature_parameter_5_candidate = exp(y) / (1 + exp(y))

#         x = temperature_parameter_6_array[end]
#         y = rand(Normal(log(x / (1 - x)), deltas[14]))
#         temperature_parameter_6_candidate = exp(y) / (1 + exp(y))

#         x = temperature_parameter_7_array[end]
#         y = rand(Normal(log(x / (1 - x)), deltas[15]))
#         temperature_parameter_7_candidate = exp(y) / (1 + exp(y))


#         # x = mean_immunity_duration_1_array[end]
#         # y = rand(Normal(log((x - 15) / (365 - x)), deltas[16]))
#         # mean_immunity_duration_1_candidate = (365 * exp(y) + 15) / (1 + exp(y))

#         # x = mean_immunity_duration_2_array[end]
#         # y = rand(Normal(log((x - 15) / (365 - x)), deltas[17]))
#         # mean_immunity_duration_2_candidate = (365 * exp(y) + 15) / (1 + exp(y))

#         # x = mean_immunity_duration_3_array[end]
#         # y = rand(Normal(log((x - 15) / (365 - x)), deltas[18]))
#         # mean_immunity_duration_3_candidate = (365 * exp(y) + 15) / (1 + exp(y))

#         # x = mean_immunity_duration_4_array[end]
#         # y = rand(Normal(log((x - 15) / (365 - x)), deltas[19]))
#         # mean_immunity_duration_4_candidate = (365 * exp(y) + 15) / (1 + exp(y))

#         # x = mean_immunity_duration_5_array[end]
#         # y = rand(Normal(log((x - 15) / (365 - x)), deltas[20]))
#         # mean_immunity_duration_5_candidate = (365 * exp(y) + 15) / (1 + exp(y))

#         # x = mean_immunity_duration_6_array[end]
#         # y = rand(Normal(log((x - 15) / (365 - x)), deltas[21]))
#         # mean_immunity_duration_6_candidate = (365 * exp(y) + 15) / (1 + exp(y))

#         # x = mean_immunity_duration_7_array[end]
#         # y = rand(Normal(log((x - 15) / (365 - x)), deltas[22]))
#         # mean_immunity_duration_7_candidate = (365 * exp(y) + 15) / (1 + exp(y))
        
#         duration_parameter = duration_parameter_candidate
#         susceptibility_parameters = [
#             susceptibility_parameter_1_candidate,
#             susceptibility_parameter_2_candidate,
#             susceptibility_parameter_3_candidate,
#             susceptibility_parameter_4_candidate,
#             susceptibility_parameter_5_candidate,
#             susceptibility_parameter_6_candidate,
#             susceptibility_parameter_7_candidate,
#         ]
#         temperature_parameters = -[
#             temperature_parameter_1_candidate,
#             temperature_parameter_2_candidate,
#             temperature_parameter_3_candidate,
#             temperature_parameter_4_candidate,
#             temperature_parameter_5_candidate,
#             temperature_parameter_6_candidate,
#             temperature_parameter_7_candidate,
#         ]
#         # mean_immunity_durations = [
#         #     mean_immunity_duration_1_candidate,
#         #     mean_immunity_duration_2_candidate,
#         #     mean_immunity_duration_3_candidate,
#         #     mean_immunity_duration_4_candidate,
#         #     mean_immunity_duration_5_candidate,
#         #     mean_immunity_duration_6_candidate,
#         #     mean_immunity_duration_7_candidate,
#         # ]
#         # for k = 1:length(viruses)
#         #     viruses[k].mean_immunity_duration = mean_immunity_durations[k]
#         #     viruses[k].immunity_duration_sd = mean_immunity_durations[k] * 0.33
#         # end

#         @threads for thread_id in 1:num_threads
#             reset_agent_states(
#                 agents,
#                 start_agent_ids[thread_id],
#                 end_agent_ids[thread_id],
#                 viruses,
#                 num_all_infected_age_groups_viruses_mean,
#                 isolation_probabilities_day_1,
#                 isolation_probabilities_day_2,
#                 isolation_probabilities_day_3,
#                 thread_rng[thread_id],
#             )
#         end

#         @time num_infected_age_groups_viruses, rt = run_simulation(
#             num_threads, thread_rng, agents, viruses, households, duration_parameter,
#             susceptibility_parameters, temperature_parameters, temperature,
#             mean_household_contact_durations, household_contact_duration_sds,
#             other_contact_duration_shapes, other_contact_duration_scales,
#             isolation_probabilities_day_1, isolation_probabilities_day_2,
#             isolation_probabilities_day_3, random_infection_probabilities,
#             recovered_duration_mean, recovered_duration_sd, false)

#         MAE = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean)) / (size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3])
#         RMSE = sqrt(sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)) / sqrt((size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3]))
#         nMAE = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean)) / sum(num_infected_age_groups_viruses_mean)
#         S_square = sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)

#         prob = zeros(Float64, 7, 4, 52)
#         for i in 1:52
#             for j in 1:4
#                 for k in 1:7
#                     prob[k, j, i] = log_g(num_infected_age_groups_viruses[i, k, j], num_infected_age_groups_viruses_mean[i, k, j], num_infected_age_groups_viruses_sd[i, k, j])
#                 end
#             end
#         end

#         accept_prob = 0.0
#         for i in 1:52
#             for j in 1:4
#                 for k in 1:7
#                     accept_prob += prob[k, j, i] - prob_prev_age_groups[k, j, i]
#                 end
#             end
#         end
#         accept_prob_final = min(1.0, exp(accept_prob))

#         open("parameters/output.txt", "a") do io
#             println(io, "n = ", n)
#             println(io, "Accept prob exp: ", accept_prob)
#             println(io, "Accept prob: ", accept_prob_final)
#             println(io, "MAE = ", MAE)
#             println(io, "RMSE = ", RMSE)
#             println(io, "nMAE = ", nMAE)
#             println(io, "S_square = ", S_square)
#             println(io, "Dur: ", duration_parameter_candidate)
#             println(io, "Suscept: ", [
#                 susceptibility_parameter_1_candidate,
#                 susceptibility_parameter_2_candidate,
#                 susceptibility_parameter_3_candidate,
#                 susceptibility_parameter_4_candidate,
#                 susceptibility_parameter_5_candidate,
#                 susceptibility_parameter_6_candidate,
#                 susceptibility_parameter_7_candidate])
#             println(io, "Temp: ", [
#                 temperature_parameter_1_candidate,
#                 temperature_parameter_2_candidate,
#                 temperature_parameter_3_candidate,
#                 temperature_parameter_4_candidate,
#                 temperature_parameter_5_candidate,
#                 temperature_parameter_6_candidate,
#                 temperature_parameter_7_candidate])
#             # println(io, "Immunity: ", [
#             #     mean_immunity_duration_1_candidate,
#             #     mean_immunity_duration_2_candidate,
#             #     mean_immunity_duration_3_candidate,
#             #     mean_immunity_duration_4_candidate,
#             #     mean_immunity_duration_5_candidate,
#             #     mean_immunity_duration_6_candidate,
#             #     mean_immunity_duration_7_candidate,
#             # ])
#             println(io)
#         end

#         if rand(Float64) < accept_prob_final || local_rejected_num > 29
#             push!(duration_parameter_array, duration_parameter_candidate)

#             push!(susceptibility_parameter_1_array, susceptibility_parameter_1_candidate)
#             push!(susceptibility_parameter_2_array, susceptibility_parameter_2_candidate)
#             push!(susceptibility_parameter_3_array, susceptibility_parameter_3_candidate)
#             push!(susceptibility_parameter_4_array, susceptibility_parameter_4_candidate)
#             push!(susceptibility_parameter_5_array, susceptibility_parameter_5_candidate)
#             push!(susceptibility_parameter_6_array, susceptibility_parameter_6_candidate)
#             push!(susceptibility_parameter_7_array, susceptibility_parameter_7_candidate)

#             push!(temperature_parameter_1_array, temperature_parameter_1_candidate)
#             push!(temperature_parameter_2_array, temperature_parameter_2_candidate)
#             push!(temperature_parameter_3_array, temperature_parameter_3_candidate)
#             push!(temperature_parameter_4_array, temperature_parameter_4_candidate)
#             push!(temperature_parameter_5_array, temperature_parameter_5_candidate)
#             push!(temperature_parameter_6_array, temperature_parameter_6_candidate)
#             push!(temperature_parameter_7_array, temperature_parameter_7_candidate)

#             # push!(mean_immunity_duration_1_array, mean_immunity_duration_1_candidate)
#             # push!(mean_immunity_duration_2_array, mean_immunity_duration_2_candidate)
#             # push!(mean_immunity_duration_3_array, mean_immunity_duration_3_candidate)
#             # push!(mean_immunity_duration_4_array, mean_immunity_duration_4_candidate)
#             # push!(mean_immunity_duration_5_array, mean_immunity_duration_5_candidate)
#             # push!(mean_immunity_duration_6_array, mean_immunity_duration_6_candidate)
#             # push!(mean_immunity_duration_7_array, mean_immunity_duration_7_candidate)

#             prob_prev_age_groups = copy(prob)

#             accept_num += 1
#             local_rejected_num = 0
#         else
#             push!(duration_parameter_array, duration_parameter_array[end])

#             push!(susceptibility_parameter_1_array, susceptibility_parameter_1_array[end])
#             push!(susceptibility_parameter_2_array, susceptibility_parameter_2_array[end])
#             push!(susceptibility_parameter_3_array, susceptibility_parameter_3_array[end])
#             push!(susceptibility_parameter_4_array, susceptibility_parameter_4_array[end])
#             push!(susceptibility_parameter_5_array, susceptibility_parameter_5_array[end])
#             push!(susceptibility_parameter_6_array, susceptibility_parameter_6_array[end])
#             push!(susceptibility_parameter_7_array, susceptibility_parameter_7_array[end])

#             push!(temperature_parameter_1_array, temperature_parameter_1_array[end])
#             push!(temperature_parameter_2_array, temperature_parameter_2_array[end])
#             push!(temperature_parameter_3_array, temperature_parameter_3_array[end])
#             push!(temperature_parameter_4_array, temperature_parameter_4_array[end])
#             push!(temperature_parameter_5_array, temperature_parameter_5_array[end])
#             push!(temperature_parameter_6_array, temperature_parameter_6_array[end])
#             push!(temperature_parameter_7_array, temperature_parameter_7_array[end])

#             # push!(mean_immunity_duration_1_array, mean_immunity_duration_1_array[end])
#             # push!(mean_immunity_duration_2_array, mean_immunity_duration_2_array[end])
#             # push!(mean_immunity_duration_3_array, mean_immunity_duration_3_array[end])
#             # push!(mean_immunity_duration_4_array, mean_immunity_duration_4_array[end])
#             # push!(mean_immunity_duration_5_array, mean_immunity_duration_5_array[end])
#             # push!(mean_immunity_duration_6_array, mean_immunity_duration_6_array[end])
#             # push!(mean_immunity_duration_7_array, mean_immunity_duration_7_array[end])
            
#             local_rejected_num += 1
#         end

#         if n % 2 == 0
#             writedlm(joinpath(@__DIR__, "..", "parameters", "tables", "duration_parameter_array.csv"), duration_parameter_array, ',')

#             writedlm(joinpath(
#                 @__DIR__, "..", "parameters", "tables", "susceptibility_parameter_1_array.csv"), susceptibility_parameter_1_array, ',')
#             writedlm(joinpath(
#                 @__DIR__, "..", "parameters", "tables", "susceptibility_parameter_2_array.csv"), susceptibility_parameter_2_array, ',')
#             writedlm(joinpath(
#                 @__DIR__, "..", "parameters", "tables", "susceptibility_parameter_3_array.csv"), susceptibility_parameter_3_array, ',')
#             writedlm(joinpath(
#                 @__DIR__, "..", "parameters", "tables", "susceptibility_parameter_4_array.csv"), susceptibility_parameter_4_array, ',')
#             writedlm(joinpath(
#                 @__DIR__, "..", "parameters", "tables", "susceptibility_parameter_5_array.csv"), susceptibility_parameter_5_array, ',')
#             writedlm(joinpath(
#                 @__DIR__, "..", "parameters", "tables", "susceptibility_parameter_6_array.csv"), susceptibility_parameter_6_array, ',')
#             writedlm(joinpath(
#                 @__DIR__, "..", "parameters", "tables", "susceptibility_parameter_7_array.csv"), susceptibility_parameter_7_array, ',')

#             writedlm(joinpath(
#                 @__DIR__, "..", "parameters", "tables", "temperature_parameter_1_array.csv"), temperature_parameter_1_array, ',')
#             writedlm(joinpath(
#                 @__DIR__, "..", "parameters", "tables", "temperature_parameter_2_array.csv"), temperature_parameter_2_array, ',')
#             writedlm(joinpath(
#                 @__DIR__, "..", "parameters", "tables", "temperature_parameter_3_array.csv"), temperature_parameter_3_array, ',')
#             writedlm(joinpath(
#                 @__DIR__, "..", "parameters", "tables", "temperature_parameter_4_array.csv"), temperature_parameter_4_array, ',')
#             writedlm(joinpath(
#                 @__DIR__, "..", "parameters", "tables", "temperature_parameter_5_array.csv"), temperature_parameter_5_array, ',')
#             writedlm(joinpath(
#                 @__DIR__, "..", "parameters", "tables", "temperature_parameter_6_array.csv"), temperature_parameter_6_array, ',')
#             writedlm(joinpath(
#                 @__DIR__, "..", "parameters", "tables", "temperature_parameter_7_array.csv"), temperature_parameter_7_array, ',')

#             # writedlm(joinpath(
#             #     @__DIR__, "..", "parameters", "tables", "mean_immunity_duration_1_array.csv"), mean_immunity_duration_1_array, ',')
#             # writedlm(joinpath(
#             #     @__DIR__, "..", "parameters", "tables", "mean_immunity_duration_2_array.csv"), mean_immunity_duration_2_array, ',')
#             # writedlm(joinpath(
#             #     @__DIR__, "..", "parameters", "tables", "mean_immunity_duration_3_array.csv"), mean_immunity_duration_3_array, ',')
#             # writedlm(joinpath(
#             #     @__DIR__, "..", "parameters", "tables", "mean_immunity_duration_4_array.csv"), mean_immunity_duration_4_array, ',')
#             # writedlm(joinpath(
#             #     @__DIR__, "..", "parameters", "tables", "mean_immunity_duration_5_array.csv"), mean_immunity_duration_5_array, ',')
#             # writedlm(joinpath(
#             #     @__DIR__, "..", "parameters", "tables", "mean_immunity_duration_6_array.csv"), mean_immunity_duration_6_array, ',')
#             # writedlm(joinpath(
#             #     @__DIR__, "..", "parameters", "tables", "mean_immunity_duration_7_array.csv"), mean_immunity_duration_7_array, ',')
#         end
        
#         println("Accept rate: ", accept_num / n)
#         n += 1
#     end
# end

# main()
