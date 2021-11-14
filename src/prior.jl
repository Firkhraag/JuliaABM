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

include("util/burnin.jl")
include("util/reset.jl")
include("util/stats.jl")

function multiple_simulations(
    agents::Vector{Agent},
    households::Vector{Household},
    shops::Vector{PublicSpace},
    restaurants::Vector{PublicSpace},
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    num_runs::Int,
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    infectivities::Array{Float64, 4},
    etiology::Matrix{Float64},
    temperature::Vector{Float64},
    min_temp::Float64,
    max_min_temp::Float64,
    viruses::Vector{Virus},
    duration_parameter_default::Float64,
    susceptibility_parameters_default::Vector{Float64},
    temperature_parameters_default::Vector{Float64},
    a1_symptomatic_parameters_default::Vector{Float64},
    a2_symptomatic_parameters_default::Vector{Float64},
    a3_symptomatic_parameters_default::Vector{Float64},
    random_infection_probabilities_default::Vector{Float64},
    num_infected_age_groups_viruses_mean::Array{Float64, 3}
)
    latin_hypercube_plan, _ = LHCoptim(num_runs, 25, 1000)

    # for i = 1:7
    #     if temperature_parameters_default[i] < -0.95
    #         temperature_parameters_default[i] = -0.95
    #     elseif temperature_parameters_default[i] > -0.05
    #         temperature_parameters_default[i] = -0.05
    #     end
    # end

    # for i = 1:2
    #     if a1_symptomatic_parameters_default[i] < 0.0
    #         a1_symptomatic_parameters_default[i] = 0.01
    #     end
    #     if a3_symptomatic_parameters_default[i] > 0.5
    #         a3_symptomatic_parameters_default[i] = 0.49
    #     end
    # end

    # for i = 1:4
    #     if random_infection_probabilities_default[i] < 0.0
    #         random_infection_probabilities_default[i] = 0.000025
    #     end
    # end

    points = scaleLHC(latin_hypercube_plan, [
        (duration_parameter_default - 0.01, duration_parameter_default + 0.15),
        (susceptibility_parameters_default[1] - 0.1, susceptibility_parameters_default[1] + 0.1),
        (susceptibility_parameters_default[2] - 0.1, susceptibility_parameters_default[2] + 0.1),
        (susceptibility_parameters_default[3] - 0.1, susceptibility_parameters_default[3] + 0.1),
        (susceptibility_parameters_default[4] - 0.1, susceptibility_parameters_default[4] + 0.1),
        (susceptibility_parameters_default[5] - 0.1, susceptibility_parameters_default[5] + 0.1),
        (susceptibility_parameters_default[6] - 0.1, susceptibility_parameters_default[6] + 0.1),
        (susceptibility_parameters_default[7] - 0.1, susceptibility_parameters_default[7] + 0.1),
        (temperature_parameters_default[1] - 0.001, temperature_parameters_default[1] + 0.03),
        (temperature_parameters_default[2] - 0.05, temperature_parameters_default[2] + 0.05),
        (temperature_parameters_default[3] - 0.05, temperature_parameters_default[3] + 0.05),
        (temperature_parameters_default[4] - 0.05, temperature_parameters_default[4] + 0.05),
        (temperature_parameters_default[5] - 0.05, temperature_parameters_default[5] + 0.05),
        (temperature_parameters_default[6] - 0.05, temperature_parameters_default[6] + 0.05),
        (temperature_parameters_default[7] - 0.05, temperature_parameters_default[7] + 0.05),
        (a1_symptomatic_parameters_default[1] - 0.05, a1_symptomatic_parameters_default[1] + 0.05),
        (a1_symptomatic_parameters_default[2] - 0.05, a1_symptomatic_parameters_default[2] + 0.05),
        (a2_symptomatic_parameters_default[1] - 0.005, a2_symptomatic_parameters_default[1] + 0.005),
        (a2_symptomatic_parameters_default[2] - 0.005, a2_symptomatic_parameters_default[2] + 0.005),
        (a3_symptomatic_parameters_default[1], a3_symptomatic_parameters_default[1] + 0.005),
        (a3_symptomatic_parameters_default[2] - 0.001, a3_symptomatic_parameters_default[2] + 0.001),
        (random_infection_probabilities_default[1] - 0.0005, random_infection_probabilities_default[1] + 0.0005),
        (random_infection_probabilities_default[2] - 0.0003, random_infection_probabilities_default[2] + 0.0003),
        (random_infection_probabilities_default[3] - 0.0001, random_infection_probabilities_default[3] + 0.0001),
        (random_infection_probabilities_default[4] - 0.0000005, random_infection_probabilities_default[4] + 0.0000005),
    ])

    S_min = 3.5760008552260814e9

    for i = 1:num_runs
        println(i)

        duration_parameter = points[i, 1]
        susceptibility_parameters = points[i, 2:8]
        temperature_parameters = points[i, 9:15]
        a1_symptomatic_parameters = points[i, 16:17]
        a2_symptomatic_parameters = points[i, 18:19]
        a3_symptomatic_parameters = points[i, 20:21]
        random_infection_probabilities = points[i, 22:25]

        reset_population(
            agents,
            num_threads,
            thread_rng,
            start_agent_ids,
            end_agent_ids,
            infectivities,
            a1_symptomatic_parameters,
            a2_symptomatic_parameters,
            a3_symptomatic_parameters,
            viruses)

        temp_influences = Array{Float64,2}(undef, 7, 365)
        year_day = 213
        for i in 1:365
            current_temp = (temperature[year_day] - min_temp) / max_min_temp
            for v in 1:7
                temp_influences[v, i] = temperature_parameters[v] * current_temp + 1.0
            end
            if year_day == 365
                year_day = 1
            else
                year_day += 1
            end
        end

        @time num_infected_age_groups_viruses = run_simulation(
            num_threads, thread_rng, agents, households,
            shops, restaurants, infectivities,  temp_influences, duration_parameter,
            susceptibility_parameters, a1_symptomatic_parameters,
            a2_symptomatic_parameters, a3_symptomatic_parameters,
            random_infection_probabilities, etiology, false)

        S_square = sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)

        if S_square < S_min
            S_min = S_square
        end

        println("S = ", S_square)
        println("S_min = ", S_min)

        open("output/output.txt", "a") do io
            println(io, "S: ", S_square)
            println(io, "duration_parameter = ", duration_parameter)
            println(io, "susceptibility_parameters = ", susceptibility_parameters)
            println(io, "temperature_parameters = ", temperature_parameters)
            println(io, "a1_symptomatic_parameters = ", a1_symptomatic_parameters)
            println(io, "a2_symptomatic_parameters = ", a2_symptomatic_parameters)
            println(io, "a3_symptomatic_parameters = ", a3_symptomatic_parameters)
            println(io, "random_infection_probabilities = ", random_infection_probabilities)
            println(io)
        end
    end
end

function main()
    println("Initialization...")

    num_threads = nthreads()

    viruses = Virus[
        Virus(1, 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 0.32, 0.16, 365),
        Virus(2, 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 0.32, 0.16, 365),
        Virus(3, 1.9, 0.175, 1, 7, 10.1, 4.93, 3, 12, 11.4, 6.25, 4, 14, 3.5, 0.5, 0.3, 60),
        Virus(4, 4.4, 0.937, 1, 7, 7.4, 2.66, 3, 12, 9.3, 4.0, 4, 14, 6.0, 0.5, 0.3, 60),
        Virus(5, 5.6, 1.51, 1, 7, 8.0, 3.1, 3, 12, 9.0, 3.92, 4, 14, 4.1, 0.5, 0.3, 90),
        Virus(6, 2.6, 0.327, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.8, 0.5, 0.3, 90),
        Virus(7, 3.2, 0.496, 1, 7, 6.5, 2.37, 3, 12, 7.5, 3.1, 4, 14, 4.93, 0.5, 0.3, 365)]

    infectivities = Array{Float64,4}(undef, 7, 7, 13, 21)
    for days_infected in -6:14
        days_infected_index = days_infected + 7
        for infection_period in 2:14
            infection_period_index = infection_period - 1
            for incubation_period in 1:7
                min_days_infected = 1 - incubation_period
                mean_infectivities = [4.6, 4.7, 3.5, 6.0, 4.1, 4.8, 4.93]
                for i in 1:7
                    if (days_infected >= min_days_infected) && (days_infected <= infection_period)
                        infectivities[i, incubation_period, infection_period_index, days_infected_index] = get_infectivity(
                            days_infected, incubation_period, infection_period, mean_infectivities[i])
                    end
                end
            end
        end
    end

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

    # Минимальная температура воздуха
    min_temp = -7.2
    # Max - Min температура
    max_min_temp = 26.6

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

    shop_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "shops.csv")))
    # Массив для хранения продовольственных магазинов
    shops = Array{PublicSpace, 1}(undef, num_shops)
    for i in 1:size(shop_coords_df, 1)
        shops[i] = PublicSpace(
            shop_coords_df[i, :dist],
            shop_coords_df[i, :x],
            shop_coords_df[i, :y],
            ceil(Int, rand(Gamma(shop_capacity_shape, shop_capacity_scale))),
            shop_num_groups,
        )
    end

    restaurant_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "restaurants.csv")))
    # Массив для хранения ресторанов/кафе/столовых
    restaurants = Array{PublicSpace, 1}(undef, num_restaurants)
    for i in 1:size(restaurant_coords_df, 1)
        restaurants[i] = PublicSpace(
            restaurant_coords_df[i, :dist],
            restaurant_coords_df[i, :x],
            restaurant_coords_df[i, :y],
            restaurant_coords_df[i, :seats],
            restaurant_num_groups,
        )
    end

    # duration_parameter = 3.075159760874048
    # susceptibility_parameters = [6.000169037311895, 6.015038136466708, 6.382343846629561, 7.881645021645022, 7.655260770975056, 7.199527932385074, 7.0009008451865595]
    # temperature_parameters = [-0.9258812615955474, -0.6183281797567513, -0.13619872191300764, -0.3328756957328386, -0.06060606060606061, -0.11566687280972995, -0.6581199752628325]
    # a1_symptomatic_parameters = [1.62, 0.6]
    # a2_symptomatic_parameters = [0.07, 0.015]
    # a3_symptomatic_parameters = [0.01, 0.3]
    # random_infection_probabilities = [0.0026, 0.0018, 0.0008, 0.00001]

    # duration_parameter = 3.1425066996495583
    # susceptibility_parameters = [6.043026180169038, 6.082385075242218, 6.4252009894867035, 7.940828695114409, 7.608321995464853, 7.230140177283033, 6.998860028860029]
    # temperature_parameters = [-0.9391465677179964, -0.5989404246547104, -0.17191300762729333, -0.29920222634508353, -0.08815708101422387, -0.1064831993403422, -0.6979158936301795]
    # a1_symptomatic_parameters = [1.649591836734694, 0.6071428571428571]
    # a2_symptomatic_parameters = [0.07112244897959184, 0.013673469387755101]
    # a3_symptomatic_parameters = [0.00826530612244898, 0.2972448979591837]
    # random_infection_probabilities = [0.0021, 0.0015612244897959184, 0.0007081632653061225, 5.0e-6]

    # duration_parameter = 3.1690373118944564
    # susceptibility_parameters = [6.085883323026181, 6.084425891568749, 6.394588744588744, 7.8734817563389, 7.675668934240363, 7.134221809936094, 7.049880437023294]
    # temperature_parameters = [-0.927922077922078, -0.6183281797567513, -0.1321170892599464, -0.2838961038961039, -0.12999381570810142, -0.14015666872809732, -0.6703648732220162]
    # a1_symptomatic_parameters = [1.626122448979592, 0.5877551020408163]
    # a2_symptomatic_parameters = [0.06612244897959184, 0.013163265306122447]
    # a3_symptomatic_parameters = [0.005306122448979591, 0.2985714285714286]
    # random_infection_probabilities = [0.0024979591836734693, 0.0013959183673469388, 0.0006775510204081633, 1.0000000000000006e-6]

    # duration_parameter = 3.1955679241393544
    # susceptibility_parameters = [6.161393527107813, 6.05381364667079, 6.319078540507112, 7.826542980828696, 7.620566893424037, 7.172997320140176, 7.145798804370233]
    # temperature_parameters = [-0.9452690166975882, -0.654042465471037, -0.1780354566068852, -0.2726716141001856, -0.1432591218305504, -0.14729952587095446, -0.6652628324056897]
    # a1_symptomatic_parameters = [1.6455102040816327, 0.5704081632653061]
    # a2_symptomatic_parameters = [0.06785714285714287, 0.009795918367346937]
    # a3_symptomatic_parameters = [0.0025510204081632642, 0.29940816326530617]
    # random_infection_probabilities = [0.002406122448979592, 0.0013775510204081633, 0.0005775510204081633, 1.3163265306122453e-6]

    duration_parameter = 3.232710781282212
    susceptibility_parameters = [6.110373118944548, 5.95381364667079, 6.341527520098949, 7.889808286951145, 7.5205668934240375, 7.236262626262625, 7.17232941661513]
    temperature_parameters = [-0.9932282003710576, -0.667307771593486, -0.14028035456606885, -0.2777736549165121, -0.1463203463203463, -0.1054627911770769, -0.6683240568954857]
    a1_symptomatic_parameters = [1.6138775510204082, 0.557142857142857]
    a2_symptomatic_parameters = [0.06755102040816327, 0.009897959183673467]
    a3_symptomatic_parameters = [0.0, 0.30024489795918374]
    random_infection_probabilities = [0.002253061224489796, 0.0015795918367346939, 0.0005428571428571429, 1.0204081632653065e-6]

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, households, viruses, infectivities, a1_symptomatic_parameters,
            a2_symptomatic_parameters, a3_symptomatic_parameters, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people,
            district_people_households, district_nums)
    end

    @time set_connections(
        agents, households, kindergartens, schools, universities,
        workplaces, shops, restaurants, thread_rng,
        num_threads, homes_coords_df)

    println("Simulation...")

    temp_influences = Array{Float64,2}(undef, 7, 365)
    year_day = 213
    for i in 1:365
        current_temp = (temperature[year_day] - min_temp) / max_min_temp
        for v in 1:7
            temp_influences[v, i] = temperature_parameters[v] * current_temp + 1.0
        end
        if year_day == 365
            year_day = 1
        else
            year_day += 1
        end
    end

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

    num_runs = 50
    multiple_simulations(
        agents,
        households,
        shops,
        restaurants,
        num_threads,
        thread_rng,
        num_runs,
        start_agent_ids,
        end_agent_ids,
        infectivities,
        etiology,
        temperature,
        min_temp,
        max_min_temp,
        viruses,
        duration_parameter,
        susceptibility_parameters,
        temperature_parameters,
        a1_symptomatic_parameters,
        a2_symptomatic_parameters,
        a3_symptomatic_parameters,
        random_infection_probabilities,
        num_infected_age_groups_viruses_mean
    )
end

main()
