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
include("util/stats.jl")

function main()
    println("Initialization...")

    # Random seed number
    run_num = 0
    is_rt_run = true
    try
        run_num = parse(Int64, ARGS[1])
    catch
        run_num = 0
    end

    num_years = 3

    # school_class_closure_period = 0
    school_class_closure_period = 7
    school_class_closure_threshold = 0.2

    with_global_warming = false
    # with_global_warming = true

    num_threads = nthreads()

    # Вероятности изолироваться при болезни на 1-й, 2-й и 3-й дни
    isolation_probabilities_day_1 = [0.406, 0.305, 0.204, 0.101]
    isolation_probabilities_day_2 = [0.669, 0.576, 0.499, 0.334]
    isolation_probabilities_day_3 = [0.45, 0.325, 0.376, 0.168]
    # Продолжительность резистентного состояния
    recovered_duration_mean = 6.0
    recovered_duration_sd = 2.0
    # recovered_duration_mean = 5.0
    # recovered_duration_sd = 1.5
    # Продолжительности контактов в домохозяйствах
    # Укороченные для различных коллективов и полная: Kinder, School, College, Work, Full
    mean_household_contact_durations = [6.5, 5.8, 9.0, 4.5, 12.0]
    household_contact_duration_sds = [2.2, 2.0, 3.0, 1.5, 4.0]
    # Продолжительности контактов в прочих коллективах
    other_contact_duration_shapes = [2.5, 1.78, 2.0, 1.81, 1.2]
    other_contact_duration_scales = [1.6, 1.95, 1.07, 1.7, 1.07]
    # Параметры, отвечающие за связи на рабочих местах
    firm_min_size = 0
    firm_max_size = 1000
    num_barabasi_albert_attachments = 5

    # MAE = 791.2851837526694
    # RMSE = 1401.6711714189296
    # nMAE = 0.45569276710726686
    # S_square = 2.860577097977747e9

    # MAE: 809.2305860710134
    # RMSE: 1470.0885164358938
    # nMAE: 0.4660273344759078
    # S_square: 3.146649318404136e9

    # MAE: 800.9246053563899
    # RMSE: 1472.1031804717197
    # nMAE: 0.46124400804303295
    # S_square: 3.1552797988784103e9
    
    duration_parameter = 3.970325706039992
    susceptibility_parameters = [3.201473922902495, 3.708895073180786, 3.817058338486913, 5.601783137497422, 4.082564419707281, 4.03612244897959, 4.4968913626056475]
    temperature_parameters = [-0.7745701917130488, -0.769160997732426, -0.09444444444444446, -0.11111111111111113, -0.12291280148423, -0.11346114203257066, -0.24710368996083393]
    random_infection_probabilities = [0.00011583879612451038, 6.800197897340754e-5, 4.915064935064938e-5, 6.634034219748507e-7]
    mean_immunity_durations = [252.02886002886, 312.16244073386935, 98.2385075242218, 34.277468563182836, 83.02370645227786, 116.12162440733866, 101.6384250669965]

    # MAE = 787.1627168160165
    # RMSE = 1455.6593867241222
    # nMAE = 0.45331868200591013
    # S_square = 3.0851828282301173e9

    # MAE: 811.9450280258973
    # RMSE: 1517.7184328206163
    # nMAE: 0.46759055288435425
    # S_square: 3.353851215366968e9

    # duration_parameter = 4.124871160585446
    # susceptibility_parameters = [3.190362811791384, 3.705864770150483, 3.650391671820246, 5.598752834467119, 3.9825644197072805, 4.000768913626054, 4.530224695938981]
    # temperature_parameters = [-0.749822716965574, -0.7413832199546482, -0.12222222222222223, -0.032828282828282845, -0.10725623582766433, -0.13820861678004542, -0.2819521748093188]
    # random_infection_probabilities = [0.0001146569779426922, 6.802925170068026e-5, 4.9165800865800896e-5, 6.699690785405074e-7]
    # mean_immunity_durations = [247.6349206349206, 308.9200164914451, 96.39002267573696, 40.428983714697985, 86.2661306947021, 115.12162440733866, 104.51721294578438]

    viruses = Virus[
        # FluA
        Virus(1.4, 0.09, 1, 7,  4.8, 1.12, 3, 21,  8.8, 3.748, 3, 21,  4.6, 3.5, 2.3,  0.38, 0.47, 0.57,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
        # FluB
        Virus(1.0, 0.0484, 1, 7,  3.7, 0.66, 3, 21,  7.8, 2.94, 3, 21,  4.7, 3.5, 2.4,  0.38, 0.47, 0.57,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
        # RV
        Virus(1.9, 0.175, 1, 7,  10.1, 4.93, 3, 21,  11.4, 6.25, 3, 21,  3.5, 2.6, 1.8,  0.19, 0.24, 0.29,  mean_immunity_durations[3], mean_immunity_durations[3] * 0.33),
        # RSV
        Virus(4.4, 0.937, 1, 7,  7.4, 2.66, 3, 21,  9.3, 4.0, 3, 21,  6.0, 4.5, 3.0,  0.24, 0.3, 0.36,  mean_immunity_durations[4], mean_immunity_durations[4] * 0.33),
        # AdV
        Virus(5.6, 1.51, 1, 7,  8.0, 3.1, 3, 21,  9.0, 3.92, 3, 21,  4.1, 3.1, 2.1,  0.15, 0.19, 0.23,  mean_immunity_durations[5], mean_immunity_durations[5] * 0.33),
        # PIV
        Virus(2.6, 0.327, 1, 7,  7.0, 2.37, 3, 21,  8.0, 3.1, 3, 21,  4.8, 3.6, 2.4,  0.16, 0.2, 0.24,  mean_immunity_durations[6], mean_immunity_durations[6] * 0.33),
        # CoV
        Virus(3.2, 0.496, 1, 7,  6.5, 2.15, 3, 21,  7.5, 2.9, 3, 21,  4.9, 3.7, 2.5,  0.21, 0.26, 0.32,  mean_immunity_durations[7], mean_immunity_durations[7] * 0.33)]

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
    temperature = get_air_temperature(with_global_warming)

    agents = Array{Agent, 1}(undef, num_agents)

    # With seed
    thread_rng = [MersenneTwister(i + run_num * num_threads) for i = 1:num_threads]

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

    # shop_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "shops.csv")))
    # # Массив для хранения продовольственных магазинов
    # shops = Array{PublicSpace, 1}(undef, num_shops)
    # for i in 1:size(shop_coords_df, 1)
    #     shops[i] = PublicSpace(
    #         shop_coords_df[i, :dist],
    #         shop_coords_df[i, :x],
    #         shop_coords_df[i, :y],
    #         ceil(Int, rand(Gamma(shop_capacity_shape, shop_capacity_scale))),
    #         shop_num_groups,
    #     )
    # end

    # restaurant_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "restaurants.csv")))
    # # Массив для хранения ресторанов/кафе/столовых
    # restaurants = Array{PublicSpace, 1}(undef, num_restaurants)
    # for i in 1:size(restaurant_coords_df, 1)
    #     restaurants[i] = PublicSpace(
    #         restaurant_coords_df[i, :dist],
    #         restaurant_coords_df[i, :x],
    #         restaurant_coords_df[i, :y],
    #         restaurant_coords_df[i, :seats],
    #         restaurant_num_groups,
    #     )
    # end

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_0 = infected_data_0[2:53, 21:27]
    infected_data_0_1 = etiology[:, 1] .* infected_data_0
    infected_data_0_2 = etiology[:, 2] .* infected_data_0
    infected_data_0_3 = etiology[:, 3] .* infected_data_0
    infected_data_0_4 = etiology[:, 4] .* infected_data_0
    infected_data_0_5 = etiology[:, 5] .* infected_data_0
    infected_data_0_6 = etiology[:, 6] .* infected_data_0
    infected_data_0_7 = etiology[:, 7] .* infected_data_0
    infected_data_0_viruses = cat(
        infected_data_0_1,
        infected_data_0_2,
        infected_data_0_3,
        infected_data_0_4,
        infected_data_0_5,
        infected_data_0_6,
        infected_data_0_7,
        dims = 3)

    infected_data_3 = infected_data_3[2:53, 21:27]
    infected_data_3_1 = etiology[:, 1] .* infected_data_3
    infected_data_3_2 = etiology[:, 2] .* infected_data_3
    infected_data_3_3 = etiology[:, 3] .* infected_data_3
    infected_data_3_4 = etiology[:, 4] .* infected_data_3
    infected_data_3_5 = etiology[:, 5] .* infected_data_3
    infected_data_3_6 = etiology[:, 6] .* infected_data_3
    infected_data_3_7 = etiology[:, 7] .* infected_data_3
    infected_data_3_viruses = cat(
        infected_data_3_1,
        infected_data_3_2,
        infected_data_3_3,
        infected_data_3_4,
        infected_data_3_5,
        infected_data_3_6,
        infected_data_3_7,
        dims = 3)

    infected_data_7 = infected_data_7[2:53, 21:27]
    infected_data_7_1 = etiology[:, 1] .* infected_data_7
    infected_data_7_2 = etiology[:, 2] .* infected_data_7
    infected_data_7_3 = etiology[:, 3] .* infected_data_7
    infected_data_7_4 = etiology[:, 4] .* infected_data_7
    infected_data_7_5 = etiology[:, 5] .* infected_data_7
    infected_data_7_6 = etiology[:, 6] .* infected_data_7
    infected_data_7_7 = etiology[:, 7] .* infected_data_7
    infected_data_7_viruses = cat(
        infected_data_7_1,
        infected_data_7_2,
        infected_data_7_3,
        infected_data_7_4,
        infected_data_7_5,
        infected_data_7_6,
        infected_data_7_7,
        dims = 3)

    infected_data_15 = infected_data_15[2:53, 21:27]
    infected_data_15_1 = etiology[:, 1] .* infected_data_15
    infected_data_15_2 = etiology[:, 2] .* infected_data_15
    infected_data_15_3 = etiology[:, 3] .* infected_data_15
    infected_data_15_4 = etiology[:, 4] .* infected_data_15
    infected_data_15_5 = etiology[:, 5] .* infected_data_15
    infected_data_15_6 = etiology[:, 6] .* infected_data_15
    infected_data_15_7 = etiology[:, 7] .* infected_data_15
    infected_data_15_viruses = cat(
        infected_data_15_1,
        infected_data_15_2,
        infected_data_15_3,
        infected_data_15_4,
        infected_data_15_5,
        infected_data_15_6,
        infected_data_15_7,
        dims = 3)

    infected_data_0_viruses_mean = mean(infected_data_0_viruses, dims = 2)[:, 1, :]
    infected_data_3_viruses_mean = mean(infected_data_3_viruses, dims = 2)[:, 1, :]
    infected_data_7_viruses_mean = mean(infected_data_7_viruses, dims = 2)[:, 1, :]
    infected_data_15_viruses_mean = mean(infected_data_15_viruses, dims = 2)[:, 1, :]

    num_infected_age_groups_viruses_mean = cat(
        infected_data_0_viruses_mean,
        infected_data_3_viruses_mean,
        infected_data_7_viruses_mean,
        infected_data_15_viruses_mean,
        dims = 3,
    )

    num_all_infected_age_groups_viruses_mean = copy(num_infected_age_groups_viruses_mean)
    for virus_id = 1:length(viruses)
        num_all_infected_age_groups_viruses_mean[:, virus_id, 1] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[1]) * (1 - isolation_probabilities_day_2[1]) * (1 - isolation_probabilities_day_3[1]))
        num_all_infected_age_groups_viruses_mean[:, virus_id, 2] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[2]) * (1 - isolation_probabilities_day_2[2]) * (1 - isolation_probabilities_day_3[2]))
        num_all_infected_age_groups_viruses_mean[:, virus_id, 3] ./= viruses[virus_id].symptomatic_probability_teenager * (1 - (1 - isolation_probabilities_day_1[3]) * (1 - isolation_probabilities_day_2[3]) * (1 - isolation_probabilities_day_3[3]))
        num_all_infected_age_groups_viruses_mean[:, virus_id, 4] ./= viruses[virus_id].symptomatic_probability_adult * (1 - (1 - isolation_probabilities_day_1[4]) * (1 - isolation_probabilities_day_2[4]) * (1 - isolation_probabilities_day_3[4]))
    end

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, households, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
            isolation_probabilities_day_2, isolation_probabilities_day_3, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people, district_people_households, district_nums)
    end

    @time set_connections(
        agents, households, kindergartens, schools, colleges,
        workplaces, thread_rng, num_threads, homes_coords_df,
        firm_min_size, firm_max_size, num_barabasi_albert_attachments)

    # get_stats(agents, schools, workplaces)
    # return

    println("Simulation...")

    # duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    # duration_parameter = mean(duration_parameter_array[burnin:step:end])
    
    # susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    # susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    # susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    # susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    # susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    # susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    # susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))
    # susceptibility_parameters = [
    #     mean(susceptibility_parameter_1_array[burnin:step:end]),
    #     mean(susceptibility_parameter_2_array[burnin:step:end]),
    #     mean(susceptibility_parameter_3_array[burnin:step:end]),
    #     mean(susceptibility_parameter_4_array[burnin:step:end]),
    #     mean(susceptibility_parameter_5_array[burnin:step:end]),
    #     mean(susceptibility_parameter_6_array[burnin:step:end]),
    #     mean(susceptibility_parameter_7_array[burnin:step:end])
    # ]

    # temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    # temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    # temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    # temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    # temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    # temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    # temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))
    # temperature_parameters = -[
    #     mean(temperature_parameter_1_array[burnin:step:end]),
    #     mean(temperature_parameter_2_array[burnin:step:end]),
    #     mean(temperature_parameter_3_array[burnin:step:end]),
    #     mean(temperature_parameter_4_array[burnin:step:end]),
    #     mean(temperature_parameter_5_array[burnin:step:end]),
    #     mean(temperature_parameter_6_array[burnin:step:end]),
    #     mean(temperature_parameter_7_array[burnin:step:end])
    # ]

    # duration_parameter = rand(duration_parameter_array[burnin:step:end])

    # susceptibility_parameters = [
    #     rand(susceptibility_parameter_1_array[burnin:step:end]),
    #     rand(susceptibility_parameter_2_array[burnin:step:end]),
    #     rand(susceptibility_parameter_3_array[burnin:step:end]),
    #     rand(susceptibility_parameter_4_array[burnin:step:end]),
    #     rand(susceptibility_parameter_5_array[burnin:step:end]),
    #     rand(susceptibility_parameter_6_array[burnin:step:end]),
    #     rand(susceptibility_parameter_7_array[burnin:step:end])
    # ]

    # temperature_parameters = -[
    #     rand(temperature_parameter_1_array[burnin:step:end]),
    #     rand(temperature_parameter_2_array[burnin:step:end]),
    #     rand(temperature_parameter_3_array[burnin:step:end]),
    #     rand(temperature_parameter_4_array[burnin:step:end]),
    #     rand(temperature_parameter_5_array[burnin:step:end]),
    #     rand(temperature_parameter_6_array[burnin:step:end]),
    #     rand(temperature_parameter_7_array[burnin:step:end])
    # ]

    @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
        num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
        susceptibility_parameters, temperature_parameters, temperature,
        mean_household_contact_durations, household_contact_duration_sds,
        other_contact_duration_shapes, other_contact_duration_scales,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, random_infection_probabilities,
        recovered_duration_mean, recovered_duration_sd, num_years, is_rt_run,
        school_class_closure_period, school_class_closure_threshold)

    # for k = 1:7
    #     println("Virus: $(k)")
    #     age_dist = sum(num_infected_age_groups_viruses[:, k, :], dims = 1)[1, :]
    #     println(age_dist ./ sum(age_dist))
    # end

    if with_global_warming
        save(joinpath(@__DIR__, "..", "output", "tables", "results_warming_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses,
            "activities_cases", activities_infections,
            "rt", rt)
    elseif school_class_closure_period == 0
        save(joinpath(@__DIR__, "..", "output", "tables", "results_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses,
            "activities_cases", activities_infections,
            "rt", rt)
    else
        save(joinpath(@__DIR__, "..", "output", "tables", "results_quarantine_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses,
            "activities_cases", activities_infections,
            "rt", rt,
            "num_schools_closed", num_schools_closed)
        # save(joinpath(@__DIR__, "..", "output", "tables", "results_quarantine_classes_$(run_num + 1).jld"),
        #     "observed_cases", observed_num_infected_age_groups_viruses,
        #     "all_cases", num_infected_age_groups_viruses,
        #     "activities_cases", activities_infections,
        #     "rt", rt)
    end

    observed_num_infected_age_groups_viruses_mean = zeros(Float64, 52, 7, 4)
    for i = 1:num_years
        for j = 1:52
            for k = 1:7
                for z = 1:4
                    observed_num_infected_age_groups_viruses_mean[j, k, z] += observed_num_infected_age_groups_viruses[52 * (i - 1) + j, k, z]
                end
            end
        end
    end
    for j = 1:52
        for k = 1:7
            for z = 1:4
                observed_num_infected_age_groups_viruses_mean[j, k, z] /= num_years
            end
        end
    end

    MAE = sum(abs.(observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses_mean)) / (size(observed_num_infected_age_groups_viruses_mean)[1] * size(observed_num_infected_age_groups_viruses_mean)[2] * size(observed_num_infected_age_groups_viruses_mean)[3])
    RMSE = sqrt(sum((observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses_mean).^2)) / sqrt((size(observed_num_infected_age_groups_viruses_mean)[1] * size(observed_num_infected_age_groups_viruses_mean)[2] * size(observed_num_infected_age_groups_viruses_mean)[3]))
    nMAE = sum(abs.(observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses_mean)) / sum(num_infected_age_groups_viruses_mean)
    S_square = sum((observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses_mean).^2)

    println("MAE: ", MAE)
    println("RMSE: ", RMSE)
    println("nMAE: ", nMAE)
    println("S_square: ", S_square)
end

main()
