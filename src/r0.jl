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
# include("model/r0.jl")
# include("model/connections.jl")

# include("data/district_households.jl")
# include("data/district_people.jl")
# include("data/district_people_households.jl")
# include("data/district_nums.jl")
# include("data/temperature.jl")
# include("data/etiology.jl")

# function find_R0(
#     agents::Vector{Agent},
#     households::Vector{Household},
#     shops::Vector{PublicSpace},
#     restaurants::Vector{PublicSpace},
#     num_threads::Int,
#     thread_rng::Vector{MersenneTwister},
#     start_agent_ids::Vector{Int},
#     end_agent_ids::Vector{Int},
#     num_runs::Int,
#     infectivities::Array{Float64, 4},
#     viruses::Vector{Virus},
#     duration_parameter::Float64,
#     susceptibility_parameters::Vector{Float64},
#     temperature_parameters::Array{Float64},
#     months_threads::Vector{Vector{Int}}
# )
#     R0 = zeros(Float64, 7, 12)
#     @time @threads for thread_id in 1:num_threads
#         r = months_threads[thread_id]
#         for month_num in r
#             for virus_num = 1:7
#                 for _ = 1:num_runs
#                     infected_agent_id = rand(start_agent_ids[thread_id]:end_agent_ids[thread_id])
#                     agent = agents[infected_agent_id]

#                     agent.virus_id = virus_num
#                     # Инкубационный период
#                     agent.incubation_period = get_period_from_erlang(
#                         viruses[agent.virus_id].mean_incubation_period,
#                         viruses[agent.virus_id].incubation_period_variance,
#                         viruses[agent.virus_id].min_incubation_period,
#                         viruses[agent.virus_id].max_incubation_period,
#                         thread_rng[thread_id])
#                     # Период болезни
#                     if agent.age < 16
#                         agent.infection_period = get_period_from_erlang(
#                             viruses[agent.virus_id].mean_infection_period_child,
#                             viruses[agent.virus_id].infection_period_variance_child,
#                             viruses[agent.virus_id].min_infection_period_child,
#                             viruses[agent.virus_id].max_infection_period_child,
#                             thread_rng[thread_id])
#                     else
#                         agent.infection_period = get_period_from_erlang(
#                             viruses[agent.virus_id].mean_infection_period_adult,
#                             viruses[agent.virus_id].infection_period_variance_adult,
#                             viruses[agent.virus_id].min_infection_period_adult,
#                             viruses[agent.virus_id].max_infection_period_adult,
#                             thread_rng[thread_id])
#                     end

#                     # Дней с момента инфицирования
#                     agent.days_infected =  1 - agent.incubation_period

#                     asymp_prob = 0.0
#                     if agent.age < 16
#                         asymp_prob = viruses[agent.virus_id].asymptomatic_probab_child
#                     else
#                         asymp_prob = viruses[agent.virus_id].asymptomatic_probab_adult
#                     end

#                     if rand(thread_rng[thread_id], Float64) < asymp_prob
#                         agent.is_asymptomatic = true
#                     end

#                     # Вирусная нагрузкаx
#                     agent.infectivity = find_agent_infectivity(
#                         agent.age, infectivities[agent.virus_id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
#                         agent.is_asymptomatic && agent.days_infected > 0)

#                     R0[virus_num, month_num] += run_simulation_r0(
#                         month_num, infected_agent_id, agents, households, shops, restaurants,
#                         infectivities, temp_influences, duration_parameter,
#                         susceptibility_parameters, thread_rng[thread_id])
#                 end
#                 R0[virus_num, month_num] /= num_runs
#             end
#         end
#     end
#     writedlm(joinpath(@__DIR__, "..", "output", "tables", "r0.csv"), R0, ',')
# end

# function main()
#     println("Initialization...")

#     # Random seed number
#     run_num = 0
#     is_rt_run = false
#     try
#         run_num = parse(Int64, ARGS[1])
#     catch
#         run_num = 0
#     end

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

#     # MAE: 810.3140467382551
#     # RMSE: 1413.6401436969034
#     # nMAE: 0.4666512880133237
#     # S_square: 2.90963903174876e9

#     duration_parameter = 3.764265099979386
#     susceptibility_parameters = [3.2580395794681514, 3.884652648938362, 3.817058338486913, 5.678550814265098, 4.145190682333544, 3.8139002267573696, 4.5655782312925155]
#     temperature_parameters = [-0.9220449391877963, -0.7772418058132341, -0.1949804164089878, -0.0393939393939394, -0.08250876108018959, -0.15083487940630802, -0.159224902082046]
#     random_infection_probabilities = [0.00011537414965986393, 6.832319109461966e-5, 4.910216450216453e-5, 6.985549371263659e-7]
#     mean_immunity_durations = [253.96825396825392, 314.95031952174816, 97.14759843331271, 22.70171098742527, 80.84188827045969, 114.48526077097503, 95.45660688517833]

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
#     thread_rng = [MersenneTwister(i + run_num * num_threads) for i = 1:num_threads]

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

#     # shop_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "shops.csv")))
#     # # Массив для хранения продовольственных магазинов
#     # shops = Array{PublicSpace, 1}(undef, num_shops)
#     # for i in 1:size(shop_coords_df, 1)
#     #     shops[i] = PublicSpace(
#     #         shop_coords_df[i, :dist],
#     #         shop_coords_df[i, :x],
#     #         shop_coords_df[i, :y],
#     #         ceil(Int, rand(Gamma(shop_capacity_shape, shop_capacity_scale))),
#     #         shop_num_groups,
#     #     )
#     # end

#     # restaurant_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "restaurants.csv")))
#     # # Массив для хранения ресторанов/кафе/столовых
#     # restaurants = Array{PublicSpace, 1}(undef, num_restaurants)
#     # for i in 1:size(restaurant_coords_df, 1)
#     #     restaurants[i] = PublicSpace(
#     #         restaurant_coords_df[i, :dist],
#     #         restaurant_coords_df[i, :x],
#     #         restaurant_coords_df[i, :y],
#     #         restaurant_coords_df[i, :seats],
#     #         restaurant_num_groups,
#     #     )
#     # end

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

#     # duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
#     # duration_parameter = mean(duration_parameter_array[burnin:step:end])
    
#     # susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
#     # susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
#     # susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
#     # susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
#     # susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
#     # susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
#     # susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))
#     # susceptibility_parameters = [
#     #     mean(susceptibility_parameter_1_array[burnin:step:end]),
#     #     mean(susceptibility_parameter_2_array[burnin:step:end]),
#     #     mean(susceptibility_parameter_3_array[burnin:step:end]),
#     #     mean(susceptibility_parameter_4_array[burnin:step:end]),
#     #     mean(susceptibility_parameter_5_array[burnin:step:end]),
#     #     mean(susceptibility_parameter_6_array[burnin:step:end]),
#     #     mean(susceptibility_parameter_7_array[burnin:step:end])
#     # ]

#     # temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
#     # temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
#     # temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
#     # temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
#     # temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
#     # temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
#     # temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))
#     # temperature_parameters = -[
#     #     mean(temperature_parameter_1_array[burnin:step:end]),
#     #     mean(temperature_parameter_2_array[burnin:step:end]),
#     #     mean(temperature_parameter_3_array[burnin:step:end]),
#     #     mean(temperature_parameter_4_array[burnin:step:end]),
#     #     mean(temperature_parameter_5_array[burnin:step:end]),
#     #     mean(temperature_parameter_6_array[burnin:step:end]),
#     #     mean(temperature_parameter_7_array[burnin:step:end])
#     # ]

#     # duration_parameter = rand(duration_parameter_array[burnin:step:end])

#     # susceptibility_parameters = [
#     #     rand(susceptibility_parameter_1_array[burnin:step:end]),
#     #     rand(susceptibility_parameter_2_array[burnin:step:end]),
#     #     rand(susceptibility_parameter_3_array[burnin:step:end]),
#     #     rand(susceptibility_parameter_4_array[burnin:step:end]),
#     #     rand(susceptibility_parameter_5_array[burnin:step:end]),
#     #     rand(susceptibility_parameter_6_array[burnin:step:end]),
#     #     rand(susceptibility_parameter_7_array[burnin:step:end])
#     # ]

#     # temperature_parameters = -[
#     #     rand(temperature_parameter_1_array[burnin:step:end]),
#     #     rand(temperature_parameter_2_array[burnin:step:end]),
#     #     rand(temperature_parameter_3_array[burnin:step:end]),
#     #     rand(temperature_parameter_4_array[burnin:step:end]),
#     #     rand(temperature_parameter_5_array[burnin:step:end]),
#     #     rand(temperature_parameter_6_array[burnin:step:end]),
#     #     rand(temperature_parameter_7_array[burnin:step:end])
#     # ]

#     # num_runs = 500000
#     num_runs = 100000
#     months_threads = [[1, 5, 9], [2, 6, 10], [3, 7, 11], [4, 8, 12]]

#     find_R0(agents, households, shops, restaurants,
#         num_threads, thread_rng, start_agent_ids,
#         end_agent_ids, num_runs, infectivities, viruses,
#         duration_parameter, susceptibility_parameters,
#         temperature_parameters, months_threads)
# end

# main()
