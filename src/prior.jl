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
include("util/stats.jl")

function multiple_simulations(
    agents::Vector{Agent},
    households::Vector{Household},
    # shops::Vector{PublicSpace},
    # restaurants::Vector{PublicSpace},
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    num_runs::Int,
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    etiology::Matrix{Float64},
    temperature::Vector{Float64},
    viruses::Vector{Virus},
    immunity_duration_sds::Vector{Float64},
    symptomatic_probabilities_children::Vector{Float64},
    symptomatic_probabilities_teenagers::Vector{Float64},
    symptomatic_probabilities_adults::Vector{Float64},
    random_infection_probabilities::Vector{Float64},
    duration_parameter_default::Float64,
    susceptibility_parameters_default::Vector{Float64},
    temperature_parameters_default::Vector{Float64},
    num_infected_age_groups_viruses_mean::Array{Float64, 3}
)
    num_parameters = 15
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

        reset_population(
            agents,
            num_threads,
            thread_rng,
            start_agent_ids,
            end_agent_ids,
            viruses,
            immunity_duration_sds,
            symptomatic_probabilities_children,
            symptomatic_probabilities_teenagers,
            symptomatic_probabilities_adults,
        )

        # --------------------------TBD ZONE-----------------------------------

        # @time num_infected_age_groups_viruses = run_simulation(
        #     num_threads, thread_rng, agents, households,
        #     shops, restaurants, infectivities,  temp_influences, duration_parameter,
        #     susceptibility_parameters, a1_symptomatic_parameters,
        #     a2_symptomatic_parameters, a3_symptomatic_parameters,
        #     random_infection_probabilities, etiology, false)

        # -------------------------------------------------------------

        @time num_infected_age_groups_viruses = run_simulation(
            num_threads, thread_rng, agents, viruses, households, duration_parameter,
            susceptibility_parameters, temperature_parameters, temperature,
            symptomatic_probabilities_children, symptomatic_probabilities_teenagers,
            symptomatic_probabilities_adults, random_infection_probabilities,
            immunity_duration_sds, etiology, false)

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
            println(io)
        end
    end
end

function main()
    println("Initialization...")

    num_threads = nthreads()

    viruses = Virus[
        Virus(1, 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 3.5, 2.3, 0.32, 0.16, 270),
        Virus(2, 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 3.5, 2.4, 0.32, 0.16, 270),
        Virus(3, 1.9, 0.175, 1, 7, 10.1, 4.93, 3, 12, 11.4, 6.25, 4, 14, 3.5, 2.6, 1.8, 0.5, 0.3, 60),
        Virus(4, 4.4, 0.937, 1, 7, 7.4, 2.66, 3, 12, 9.3, 4.0, 4, 14, 6.0, 4.5, 3.0, 0.5, 0.3, 60),
        Virus(5, 5.6, 1.51, 1, 7, 8.0, 3.1, 3, 12, 9.0, 3.92, 4, 14, 4.1, 3.1, 2.1, 0.5, 0.3, 90),
        Virus(6, 2.6, 0.327, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.8, 3.6, 2.4, 0.5, 0.3, 90),
        Virus(7, 3.2, 0.496, 1, 7, 6.5, 2.15, 3, 12, 7.5, 2.9, 4, 14, 4.9, 3.7, 2.5, 0.5, 0.3, 120)]

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

    university_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "universities.csv")))
    # Массив для хранения школ
    universities = Array{School, 1}(undef, num_universities)
    for i in 1:size(university_coords_df, 1)
        universities[i] = School(
            3,
            university_coords_df[i, :dist],
            university_coords_df[i, :x],
            university_coords_df[i, :y],
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

    # duration_parameter = 3.5
    # susceptibility_parameters = [5.5, 5.5, 6.0, 7.5, 7.0, 7.0, 7.0]
    # temperature_parameters = [-0.9, -0.8, -0.1, -0.35, -0.1, -0.1, -0.75]

    # 9.33003323134884e9
    # duration_parameter = 3.422222222222222
    # susceptibility_parameters = [5.444444444444445, 5.488888888888889, 5.912121212121212, 7.47070707070707, 6.998989898989899, 6.984848484848485, 7.071717171717172]
    # temperature_parameters = [-0.9318181818181819, -0.8156565656565657, -0.07222222222222223, -0.3101010101010101, -0.14292929292929296, -0.14191919191919194, -0.7565656565656566]

    # 8.958942054805984e9
    # duration_parameter = 3.3545454545454545
    # susceptibility_parameters = [5.451515151515152, 5.483838383838384, 5.820202020202021, 7.390909090909091, 6.931313131313132, 6.957575757575758, 7.028282828282828]
    # temperature_parameters = [-0.9444444444444445, -0.8121212121212122, -0.022222222222222227, -0.27323232323232327, -0.16464646464646468, -0.11515151515151517, -0.7651515151515151]

    # 8.583310049099577e9
    # duration_parameter = 3.278787878787879
    # susceptibility_parameters = [5.367676767676769, 5.559595959595959, 5.811111111111112, 7.343434343434343, 6.946464646464647, 6.9, 6.954545454545454]
    # temperature_parameters = [-0.9883838383838385, -0.8196969696969698, -0.051515151515151514, -0.22525252525252532, -0.1540404040404041, -0.16111111111111112, -0.7777777777777778]

    # 8.381776313794
    duration_parameter = 3.201010101010101
    susceptibility_parameters = [5.42929292929293, 5.629292929292928, 5.765656565656567, 7.257575757575758, 6.901010101010102, 6.828282828282829, 6.969696969696969]
    temperature_parameters = [-0.9787878787878788, -0.7808080808080808, -0.06616161616161617, -0.17929292929292936, -0.1858585858585859, -0.15050505050505053, -0.7671717171717172]

    # 8.110599655023092e9
    duration_parameter = 3.149494949494949
    susceptibility_parameters = [5.466666666666667, 5.551515151515151, 5.693939393939395, 7.16969696969697, 6.875757575757577, 6.851515151515152, 6.966666666666666]
    temperature_parameters = [-0.9292929292929293, -0.8217171717171717, -0.07979797979797981, -0.15656565656565663, -0.22373737373737376, -0.1904040404040404, -0.7626262626262627]

    symptomatic_probabilities_children = [0.41, 0.41, 0.19, 0.26, 0.15, 0.16, 0.22]
    symptomatic_probabilities_teenagers = [0.52, 0.52, 0.24, 0.33, 0.19, 0.2, 0.28]
    symptomatic_probabilities_adults = [0.61, 0.61, 0.28, 0.39, 0.22, 0.24, 0.33]
    random_infection_probabilities = [0.0015, 0.0012, 0.00045, 0.000001]
    immunity_duration_sds = [90.0, 90.0, 20.0, 20.0, 30.0, 30.0, 40.0]

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, households, viruses, immunity_duration_sds, symptomatic_probabilities_children,
            symptomatic_probabilities_teenagers, symptomatic_probabilities_adults, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people,
            district_people_households, district_nums)
    end

    # --------------------------TBD ZONE-----------------------------------

    # @time set_connections(
    #     agents, households, kindergartens, schools, universities,
    #     workplaces, shops, restaurants, thread_rng,
    #     num_threads, homes_coords_df)

    # -------------------------------------------------------------

    @time set_connections(
        agents, households, kindergartens, schools, universities,
        workplaces, thread_rng, num_threads, homes_coords_df)

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

    # --------------------------TBD ZONE-----------------------------------

    # multiple_simulations(
    #     agents,
    #     households,
    #     shops,
    #     restaurants,
    #     num_threads,
    #     thread_rng,
    #     num_runs,
    #     start_agent_ids,
    #     end_agent_ids,
    #     etiology,
    #     temperature,
    #     viruses,
    #     duration_parameter,
    #     susceptibility_parameters,
    #     temperature_parameters,
    #     a1_symptomatic_parameters,
    #     a2_symptomatic_parameters,
    #     a3_symptomatic_parameters,
    #     random_infection_probabilities,
    #     num_infected_age_groups_viruses_mean
    # )

    # -------------------------------------------------------------

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
        immunity_duration_sds,
        symptomatic_probabilities_children,
        symptomatic_probabilities_teenagers,
        symptomatic_probabilities_adults,
        random_infection_probabilities,
        duration_parameter,
        susceptibility_parameters,
        temperature_parameters,
        num_infected_age_groups_viruses_mean
    )
end

main()
