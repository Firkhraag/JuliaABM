using Base.Threads
using Distributions
using Random
using DelimitedFiles
using DataFrames
using LatinHypercubeSampling
using CSV

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
include("model/contacts.jl")
include("model/connections.jl")

include("data/district_households.jl")
include("data/district_people.jl")
include("data/district_people_households.jl")
include("data/district_nums.jl")
include("data/temperature.jl")
include("data/etiology.jl")

include("util/reset.jl")

function multiple_simulations(
    agents::Vector{Agent},
    households::Vector{Household},
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    num_runs::Int,
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    etiology::Matrix{Float64},
    temperature::Vector{Float64},
    viruses::Vector{Virus},
    initially_infected::Vector{Float64},
    mean_household_contact_durations::Vector{Float64},
    household_contact_duration_sds::Vector{Float64},
    other_contact_duration_shapes::Vector{Float64},
    other_contact_duration_scales::Vector{Float64},
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    random_infection_probabilities::Vector{Float64},
    duration_parameter_default::Float64,
    susceptibility_parameters_default::Vector{Float64},
    temperature_parameters_default::Vector{Float64},
    num_infected_age_groups_viruses_mean::Array{Float64, 3},
    recovered_duration_mean::Float64,
    recovered_duration_sd::Float64,
    random_infection_probabilities_default::Vector{Float64},
    mean_immunity_durations::Vector{Float64},
)
    # num_parameters = 15
    num_parameters = 30
    latin_hypercube_plan, _ = LHCoptim(num_runs, num_parameters, 1000)

    for i = 1:7
        if temperature_parameters_default[i] < -0.95
            temperature_parameters_default[i] = -0.95
        elseif temperature_parameters_default[i] > -0.05
            temperature_parameters_default[i] = -0.05
        end
    end

    points = scaleLHC(latin_hypercube_plan, [
        (duration_parameter_default - 0.1, duration_parameter_default + 0.1),
        (susceptibility_parameters_default[1] - 0.1, susceptibility_parameters_default[1] + 0.1),
        (susceptibility_parameters_default[2] - 0.1, susceptibility_parameters_default[2] + 0.1),
        (susceptibility_parameters_default[3] - 0.1, susceptibility_parameters_default[3] + 0.1),
        (susceptibility_parameters_default[4] - 0.1, susceptibility_parameters_default[4] + 0.1),
        (susceptibility_parameters_default[5] - 0.1, susceptibility_parameters_default[5] + 0.1),
        (susceptibility_parameters_default[6] - 0.1, susceptibility_parameters_default[6] + 0.1),
        (susceptibility_parameters_default[7] - 0.1, susceptibility_parameters_default[7] + 0.1),
        (temperature_parameters_default[1] - 0.05, temperature_parameters_default[1] + 0.05),
        (temperature_parameters_default[2] - 0.05, temperature_parameters_default[2] + 0.05),
        (temperature_parameters_default[3] - 0.05, temperature_parameters_default[3] + 0.05),
        (temperature_parameters_default[4] - 0.05, temperature_parameters_default[4] + 0.05),
        (temperature_parameters_default[5] - 0.05, temperature_parameters_default[5] + 0.05),
        (temperature_parameters_default[6] - 0.05, temperature_parameters_default[6] + 0.05),
        (temperature_parameters_default[7] - 0.05, temperature_parameters_default[7] + 0.05),
        (initially_infected[1] - 0.001, initially_infected[1] + 0.001),
        (initially_infected[2] - 0.001, initially_infected[2] + 0.001),
        (initially_infected[3] - 0.0005, initially_infected[3] + 0.0005),
        (initially_infected[4] - 0.0002, initially_infected[4] + 0.0002),
        (random_infection_probabilities_default[1] - 0.000001, random_infection_probabilities_default[1] + 0.000001),
        (random_infection_probabilities_default[2] - 0.0000001, random_infection_probabilities_default[2] + 0.0000001),
        (random_infection_probabilities_default[3] - 0.0000001, random_infection_probabilities_default[3] + 0.0000001),
        (random_infection_probabilities_default[4] - 0.00000001, random_infection_probabilities_default[4] + 0.00000001),
        (mean_immunity_durations[1] - 3.0, mean_immunity_durations[1] + 3.0),
        (mean_immunity_durations[2] - 3.0, mean_immunity_durations[2] + 3.0),
        (mean_immunity_durations[3] - 3.0, mean_immunity_durations[3] + 3.0),
        (mean_immunity_durations[4] - 3.0, mean_immunity_durations[4] + 3.0),
        (mean_immunity_durations[5] - 3.0, mean_immunity_durations[5] + 3.0),
        (mean_immunity_durations[6] - 3.0, mean_immunity_durations[6] + 3.0),
        (mean_immunity_durations[7] - 3.0, mean_immunity_durations[7] + 3.0),
    ])

    MAE_min = 1.0e10
    MAPE_min = 1.0e10
    RMSE_min = 1.0e10
    nMAE_min = 1.0e10
    S_abs_min = 1.0e10
    S_square_min = 1.0e10

    for i = 1:num_runs
        println(i)

        duration_parameter = points[i, 1]
        susceptibility_parameters = points[i, 2:8]
        temperature_parameters = points[i, 9:15]
        initially_infected = points[i, 16:19]
        random_infection_probabilities = points[i, 20:23]

        viruses = Virus[
            # FluA
            Virus(1.4, 0.09, 1, 7,  4.8, 1.12, 3, 12,  8.8, 3.748, 4, 14,  4.6, 3.5, 2.3,  0.3, 0.45, 0.6,  points[i, 24], points[i, 24] * 0.33),
            # FluB
            Virus(1.0, 0.0484, 1, 7,  3.7, 0.66, 3, 12,  7.8, 2.94, 4, 14,  4.7, 3.5, 2.4,  0.3, 0.45, 0.6,  points[i, 25], points[i, 25] * 0.33),
            # RV
            Virus(1.9, 0.175, 1, 7,  10.1, 4.93, 3, 12,  11.4, 6.25, 4, 14,  3.5, 2.6, 1.8,  0.19, 0.24, 0.28,  points[i, 26], points[i, 26] * 0.33),
            # RSV
            Virus(4.4, 0.937, 1, 7,  7.4, 2.66, 3, 12,  9.3, 4.0, 4, 14,  6.0, 4.5, 3.0,  0.26, 0.33, 0.39,  points[i, 27], points[i, 27] * 0.33),
            # AdV
            Virus(5.6, 1.51, 1, 7,  8.0, 3.1, 3, 12,  9.0, 3.92, 4, 14,  4.1, 3.1, 2.1,  0.15, 0.19, 0.22,  points[i, 28], points[i, 28] * 0.33),
            # PIV
            Virus(2.6, 0.327, 1, 7,  7.0, 2.37, 3, 12,  8.0, 3.1, 4, 14,  4.8, 3.6, 2.4,  0.16, 0.2, 0.24,  points[i, 29], points[i, 29] * 0.33),
            # CoV
            Virus(3.2, 0.496, 1, 7,  6.5, 2.15, 3, 12,  7.5, 2.9, 4, 14,  4.9, 3.7, 2.5,  0.22, 0.28, 0.33,  points[i, 30], points[i, 30] * 0.33)]

        @threads for thread_id in 1:num_threads
            reset_agent_states(
                agents,
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                viruses,
                initially_infected,
                isolation_probabilities_day_1,
                isolation_probabilities_day_2,
                isolation_probabilities_day_3,
                thread_rng[thread_id],
            )
        end

        @time num_infected_age_groups_viruses = run_simulation(
            num_threads, thread_rng, agents, viruses, households, duration_parameter,
            susceptibility_parameters, temperature_parameters, temperature,
            mean_household_contact_durations, household_contact_duration_sds,
            other_contact_duration_shapes, other_contact_duration_scales,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probabilities, etiology,
            recovered_duration_mean, recovered_duration_sd, false)

        MAE = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean)) / (size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3])
        MAPE = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean) ./ num_infected_age_groups_viruses_mean) / (size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3])
        RMSE = sqrt(sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)) / sqrt((size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3]))
        nMAE = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean)) / sum(num_infected_age_groups_viruses_mean)
        S_abs = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean))
        S_square = sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)

        if MAE < MAE_min
            MAE_min = MAE
        end
        if MAPE < MAPE_min
            MAPE_min = MAPE
        end
        if RMSE < RMSE_min
            RMSE_min = RMSE
        end
        if nMAE < nMAE_min
            nMAE_min = nMAE
        end
        if S_abs < S_abs_min
            S_abs_min = S_abs
        end
        if S_square < S_square_min
            S_square_min = S_square
        end

        println("Cur")
        println("MAE = ", MAE)
        println("MAPE = ", MAPE)
        println("RMSE = ", RMSE)
        println("nMAE = ", nMAE)
        println("S_abs = ", S_abs)
        println("S_square = ", S_square)
        println("Min")
        println("MAE_min = ", MAE_min)
        println("MAPE_min = ", MAPE_min)
        println("RMSE_min = ", RMSE_min)
        println("nMAE_min = ", nMAE_min)
        println("S_abs_min = ", S_abs_min)
        println("S_square_min = ", S_square_min)

        open("output/output.txt", "a") do io
            println(io, "MAE = ", MAE)
            println(io, "MAPE = ", MAPE)
            println(io, "RMSE = ", RMSE)
            println(io, "nMAE = ", nMAE)
            println(io, "S_abs = ", S_abs)
            println(io, "S_square = ", S_square)
            println(io, "duration_parameter = ", duration_parameter)
            println(io, "susceptibility_parameters = ", susceptibility_parameters)
            println(io, "temperature_parameters = ", temperature_parameters)
            println(io, "random_infection_probabilities = ", random_infection_probabilities)
            println(io, "initially_infected = ", initially_infected)
            println(io, "mean_immunity_durations = ", [points[i, 24], points[i, 25], points[i, 26], points[i, 27], points[i, 28], points[i, 29], points[i, 30]])
            println(io)
        end
    end
end

function main()
    println("Initialization...")

    num_threads = nthreads()

    viruses = Virus[
        # FluA
        Virus(1.4, 0.09, 1, 7,  4.8, 1.12, 3, 12,  8.8, 3.748, 4, 14,  4.6, 3.5, 2.3,  0.3, 0.45, 0.6,  270.0, 90.0),
        # FluB
        Virus(1.0, 0.0484, 1, 7,  3.7, 0.66, 3, 12,  7.8, 2.94, 4, 14,  4.7, 3.5, 2.4,  0.3, 0.45, 0.6,  270.0, 90.0),
        # RV
        Virus(1.9, 0.175, 1, 7,  10.1, 4.93, 3, 12,  11.4, 6.25, 4, 14,  3.5, 2.6, 1.8,  0.19, 0.24, 0.28,  60.0, 20.0),
        # RSV
        Virus(4.4, 0.937, 1, 7,  7.4, 2.66, 3, 12,  9.3, 4.0, 4, 14,  6.0, 4.5, 3.0,  0.26, 0.33, 0.39,  60.0, 20.0),
        # AdV
        Virus(5.6, 1.51, 1, 7,  8.0, 3.1, 3, 12,  9.0, 3.92, 4, 14,  4.1, 3.1, 2.1,  0.15, 0.19, 0.22,  90.0, 30.0),
        # PIV
        Virus(2.6, 0.327, 1, 7,  7.0, 2.37, 3, 12,  8.0, 3.1, 4, 14,  4.8, 3.6, 2.4,  0.16, 0.2, 0.24,  90.0, 30.0),
        # CoV
        Virus(3.2, 0.496, 1, 7,  6.5, 2.15, 3, 12,  7.5, 2.9, 4, 14,  4.9, 3.7, 2.5,  0.22, 0.28, 0.33,  120.0, 40.0)]

    # Начальные доли инфицированных
    initially_infected = [4896 / 272834, 3615 / 319868, 2906 / 559565, 14928 / 8920401]
    # Вероятности случайного инфицирования
    random_infection_probabilities = [0.0015, 0.0012, 0.00045, 0.000001]
    # Вероятности изолироваться при болезни на 1-й, 2-й и 3-й дни
    isolation_probabilities_day_1 = [0.406, 0.305, 0.204, 0.101]
    isolation_probabilities_day_2 = [0.669, 0.576, 0.499, 0.334]
    isolation_probabilities_day_3 = [0.45, 0.325, 0.376, 0.168]
    # Продолжительность резистентного состояния
    recovered_duration_mean = 12.0
    recovered_duration_sd = 4.0
    # Продолжительности контактов в домохозяйствах
    # Укороченные для различных коллективов и полная: Kinder, School, College, Work, Full
    mean_household_contact_durations = [6.5, 5.8, 9.0, 4.5, 12.0]
    household_contact_duration_sds = [2.2, 2.0, 3.0, 1.5, 4.0]
    # Продолжительности контактов в прочих коллективах
    other_contact_duration_shapes = [2.5, 1.78, 2.0, 1.81, 1.2]
    other_contact_duration_scales = [1.6, 1.95, 1.07, 1.7, 1.07]
    # Параметры, отвечающие за связи на рабочих местах
    zipf_max_size = 994
    num_barabasi_albert_attachments = 6

    # Число домохозяйств каждого типа по районам
    district_households = get_district_households()
    # Число людей в каждой группе по районам
    district_people = get_district_people()
    # Число людей в домохозяйствах по районам
    district_people_households = get_district_people_households()
    # Вероятность случайного инфицирования
    etiology = get_random_infection_probabilities()
    # Номера районов для MPI процессов
    district_nums = get_district_nums()
    # Температура воздуха, начиная с 1 января
    temperature = get_air_temperature()

    agents = Array{Agent, 1}(undef, num_agents)

    # With set seed
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

    # --------------------------TBD ZONE-----------------------------------

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

    # -------------------------------------------------------------

    duration_parameter = 3.9010101010101
    susceptibility_parameters = [3.8606060606060617, 3.8828282828282816, 4.398989898989902, 5.903030303030302, 4.550808080808084, 4.357777777777779, 4.8609090909090895]
    temperature_parameters = [-0.8181818181818181, -0.8611111111111109, -0.15050505050505047, -0.03434343434343433, -0.058585858585858575, -0.23080808080808082, -0.6464646464646465]
    random_infection_probabilities = [0.00011584848484848481, 6.827373737373738e-5, 4.8813131313131337e-5, 7.13939393939394e-7]
    initially_infected = [0.017702553289701516, 0.010958102540530295, 0.0039104915280962745, 0.0011078108042520292]
    mean_immunity_durations = [270.42424242424244, 269.03030303030306, 55.57575757575758, 61.27272727272727, 81.75757575757576, 100.78787878787877, 117.93939393939394]

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, households, viruses, initially_infected, isolation_probabilities_day_1,
            isolation_probabilities_day_2, isolation_probabilities_day_3, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people, district_people_households, district_nums)
    end

    # --------------------------TBD ZONE-----------------------------------

    # @time set_connections(
    #     agents, households, kindergartens, schools, college,
    #     workplaces, shops, restaurants, thread_rng,
    #     num_threads, homes_coords_df)

    # -------------------------------------------------------------

    @time set_connections(
        agents, households, kindergartens, schools, colleges,
        workplaces, thread_rng, num_threads, homes_coords_df,
        zipf_max_size, num_barabasi_albert_attachments)

    println("Simulation...")

    # Runs
    etiology_data = readdlm(joinpath(@__DIR__, "..", "input", "tables", "etiology_ratio.csv"), ',', Float64, '\n')
    
    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_0 = infected_data_0[2:53, 21:27]
    infected_data_0_1 = etiology_data[1, :]' .* infected_data_0'
    infected_data_0_2 = etiology_data[2, :]' .* infected_data_0'
    infected_data_0_3 = etiology_data[3, :]' .* infected_data_0'
    infected_data_0_4 = etiology_data[4, :]' .* infected_data_0'
    infected_data_0_5 = etiology_data[5, :]' .* infected_data_0'
    infected_data_0_6 = etiology_data[6, :]' .* infected_data_0'
    infected_data_0_7 = etiology_data[7, :]' .* infected_data_0'
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
    infected_data_3_1 = etiology_data[1, :]' .* infected_data_3'
    infected_data_3_2 = etiology_data[2, :]' .* infected_data_3'
    infected_data_3_3 = etiology_data[3, :]' .* infected_data_3'
    infected_data_3_4 = etiology_data[4, :]' .* infected_data_3'
    infected_data_3_5 = etiology_data[5, :]' .* infected_data_3'
    infected_data_3_6 = etiology_data[6, :]' .* infected_data_3'
    infected_data_3_7 = etiology_data[7, :]' .* infected_data_3'
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
    infected_data_7_1 = etiology_data[1, :]' .* infected_data_7'
    infected_data_7_2 = etiology_data[2, :]' .* infected_data_7'
    infected_data_7_3 = etiology_data[3, :]' .* infected_data_7'
    infected_data_7_4 = etiology_data[4, :]' .* infected_data_7'
    infected_data_7_5 = etiology_data[5, :]' .* infected_data_7'
    infected_data_7_6 = etiology_data[6, :]' .* infected_data_7'
    infected_data_7_7 = etiology_data[7, :]' .* infected_data_7'
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
    infected_data_15_1 = etiology_data[1, :]' .* infected_data_15'
    infected_data_15_2 = etiology_data[2, :]' .* infected_data_15'
    infected_data_15_3 = etiology_data[3, :]' .* infected_data_15'
    infected_data_15_4 = etiology_data[4, :]' .* infected_data_15'
    infected_data_15_5 = etiology_data[5, :]' .* infected_data_15'
    infected_data_15_6 = etiology_data[6, :]' .* infected_data_15'
    infected_data_15_7 = etiology_data[7, :]' .* infected_data_15'
    infected_data_15_viruses = cat(
        infected_data_15_1,
        infected_data_15_2,
        infected_data_15_3,
        infected_data_15_4,
        infected_data_15_5,
        infected_data_15_6,
        infected_data_15_7,
        dims = 3)

    infected_data_0_viruses_mean = mean(infected_data_0_viruses, dims = 1)[1, :, :]
    infected_data_3_viruses_mean = mean(infected_data_3_viruses, dims = 1)[1, :, :]
    infected_data_7_viruses_mean = mean(infected_data_7_viruses, dims = 1)[1, :, :]
    infected_data_15_viruses_mean = mean(infected_data_15_viruses, dims = 1)[1, :, :]

    num_infected_age_groups_viruses_mean = cat(
        infected_data_0_viruses_mean,
        infected_data_3_viruses_mean,
        infected_data_7_viruses_mean,
        infected_data_15_viruses_mean,
        dims = 3,
    )

    num_runs = 100

    multiple_simulations(
        agents,
        households,
        num_threads,
        thread_rng,
        num_runs,
        start_agent_ids,
        end_agent_ids,
        etiology,
        temperature,
        viruses,
        initially_infected,
        mean_household_contact_durations,
        household_contact_duration_sds,
        other_contact_duration_shapes,
        other_contact_duration_scales,
        isolation_probabilities_day_1,
        isolation_probabilities_day_2,
        isolation_probabilities_day_3,
        random_infection_probabilities,
        duration_parameter,
        susceptibility_parameters,
        temperature_parameters,
        num_infected_age_groups_viruses_mean,
        recovered_duration_mean,
        recovered_duration_sd,
        random_infection_probabilities,
        mean_immunity_durations,
    )
end

main()
