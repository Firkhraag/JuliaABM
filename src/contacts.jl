using Base.Threads
using Distributions
using Random
using DelimitedFiles
using DataFrames
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

include("util/stats.jl")

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

    get_stats(agents)
    # return

    println("Simulation...")
    
    # --------------------------TBD ZONE-----------------------------------

    # println("Holiday")
    # @time run_simulation_evaluation(
    #     num_threads, thread_rng, agents, households, kindergartens,
    #     schools, universities, shops, restaurants, true)
    # println("Weekday")
    # @time run_simulation_evaluation(
    #     num_threads, thread_rng, agents, households, kindergartens,
    #     schools, universities, shops, restaurants, false)

    # -------------------------------------------------------------

    # println("Holiday")
    # @time run_simulation_evaluation(
    #     num_threads, thread_rng, agents, households, kindergartens,
    #     schools, universities, shops, restaurants, true)
    println("Weekday")
    @time run_simulation_evaluation(
        num_threads, thread_rng, agents, households, kindergartens,
        schools, universities, false)
    
    age_groups_nums = zeros(Int, 90)
    for agent in agents
        age_groups_nums[agent.age + 1] += 1
    end
    writedlm(joinpath(@__DIR__, "..", "input", "tables", "age_groups_nums.csv"), age_groups_nums, ',')
end

main()
