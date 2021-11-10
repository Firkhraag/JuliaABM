using Base.Threads
using Distributions
using CSV
using DataFrames
using Random

include("data/district_households.jl")
include("data/district_nums.jl")

function get_num_of_people_and_households(
    thread_id::Int,
    num_threads::Int,
    district_nums::Vector{Int},
    district_households::Matrix{Int}
)::Tuple{Int, Int}
    num_agents = 0
    num_households = 0
    for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
        for _ in 1:district_households[index, 1]
            # 1P
            num_agents += 1
            num_households += 1
        end
        for _ in 1:district_households[index, 2]
            # PWOP2P0C
            num_agents += 2
            num_households += 1
        end
        for _ in 1:district_households[index, 3]
            # PWOP3P0C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 4]
            # PWOP3P1C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 5]
            # PWOP4P0C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 6]
            # PWOP4P1C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 7]
            # PWOP4P2C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 8]
            # PWOP5P0C
            num_agents += 5
            num_households += 1
        end
        for _ in 1:district_households[index, 9]
            # PWOP5P1C
            num_agents += 5
            num_households += 1
        end
        for _ in 1:district_households[index, 10]
            # PWOP5P2C
            num_agents += 5
            num_households += 1
        end
        for _ in 1:district_households[index, 11]
            # PWOP5P3C
            num_agents += 5
            num_households += 1
        end
        for _ in 1:district_households[index, 12]
            # PWOP6P0C
            num_agents += 6
            num_households += 1
        end
        for _ in 1:district_households[index, 13]
            # PWOP6P1C
            num_agents += 6
            num_households += 1
        end
        for _ in 1:district_households[index, 14]
            # PWOP6P2C
            num_agents += 6
            num_households += 1
        end
        for _ in 1:district_households[index, 15]
            # PWOP6P3C
            num_agents += 6
            num_households += 1
        end
        for _ in 1:district_households[index, 16]
            # 2PWOP4P0C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 17]
            # 2PWOP5P0C
            num_agents += 5
            num_households += 1
        end
        for _ in 1:district_households[index, 18]
            # 2PWOP5P1C
            num_agents += 5
            num_households += 1
        end
        for _ in 1:district_households[index, 19]
            # 2PWOP6P0C
            num_agents += 6
            num_households += 1
        end
        for _ in 1:district_households[index, 20]
            # 2PWOP6P1C
            num_agents += 6
            num_households += 1
        end
        for _ in 1:district_households[index, 21]
            # 2PWOP6P2C
            num_agents += 6
            num_households += 1
        end
        for _ in 1:district_households[index, 22]
            # SMWC2P0C
            num_agents += 2
            num_households += 1
        end
        for _ in 1:district_households[index, 23]
            # SMWC2P1C
            num_agents += 2
            num_households += 1
        end
        for _ in 1:district_households[index, 24]
            # SMWC3P0C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 25]
            # SMWC3P1C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 26]
            # SMWC3P2C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 27]
            # SMWC4P0C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 28]
            # SMWC4P1C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 29]
            # SMWC4P2C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 30]
            # SMWC4P3C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 31]
            # SFWC2P0C
            num_agents += 2
            num_households += 1
        end
        for _ in 1:district_households[index, 32]
            # SFWC2P1C
            num_agents += 2
            num_households += 1
        end
        for _ in 1:district_households[index, 33]
            # SFWC3P0C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 34]
            # SFWC3P1C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 35]
            # SFWC3P2C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 36]
            # SPWCWP3P0C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 37]
            # SPWCWP3P1C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 38]
            # SPWCWP4P0C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 39]
            # SPWCWP4P1C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 40]
            # SPWCWP4P2C
            num_agents += 4
            num_households += 1
        end

        for _ in 1:district_households[index, 41]
            # SPWCWPWOP3P0C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 42]
            # SPWCWPWOP3P1C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 43]
            # SPWCWPWOP4P0C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 44]
            # SPWCWPWOP4P1C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 45]
            # SPWCWPWOP4P2C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 46]
            # SPWCWPWOP5P0C
            num_agents += 5
            num_households += 1
        end
        for _ in 1:district_households[index, 47]
            # SPWCWPWOP5P1C
            num_agents += 5
            num_households += 1
        end
        for _ in 1:district_households[index, 48]
            # SPWCWPWOP5P2C
            num_agents += 5
            num_households += 1
        end

        for _ in 1:district_households[index, 49]
            # O2P0C
            num_agents += 2
            num_households += 1
        end
        for _ in 1:district_households[index, 50]
            # O2P1C
            num_agents += 2
            num_households += 1
        end
        for _ in 1:district_households[index, 51]
            # O3P0C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 52]
            # O3P1C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 53]
            # O3P2C
            num_agents += 3
            num_households += 1
        end
        for _ in 1:district_households[index, 54]
            # O4P0C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 55]
            # O4P1C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 56]
            # O4P2C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 57]
            # O4P3C
            num_agents += 4
            num_households += 1
        end
        for _ in 1:district_households[index, 58]
            # O5P0C
            num_agents += 5
            num_households += 1
        end
        for _ in 1:district_households[index, 59]
            # O5P1C
            num_agents += 5
            num_households += 1
        end
        for _ in 1:district_households[index, 60]
            # O5P2C
            num_agents += 5
            num_households += 1
        end
        for _ in 1:district_households[index, 61]
            # O5P3C
            num_agents += 5
            num_households += 1
        end
        for _ in 1:district_households[index, 62]
            # O6P0C
            num_agents += 6
            num_households += 1
        end
        for _ in 1:district_households[index, 63]
            # O6P1C
            num_agents += 6
            num_households += 1
        end
        for _ in 1:district_households[index, 64]
            # O6P2C
            num_agents += 6
            num_households += 1
        end
        for _ in 1:district_households[index, 65]
            # O6P3C
            num_agents += 6
            num_households += 1
        end
    end
    return num_agents, num_households
end

function get_district_people_ids(
    district_nums::Vector{Int},
    district_households::Matrix{Int}
)::Tuple{Vector{Int}, Vector{Int}}
    start_agent_ids_districts = zeros(Int, length(district_nums))
    end_agent_ids_districts = zeros(Int, length(district_nums))
    agent_id = 1
    for index in district_nums
        start_agent_ids_districts[index] = agent_id
        for _ in 1:district_households[index, 1]
            # 1P
            agent_id += 1
        end
        for _ in 1:district_households[index, 2]
            # PWOP2P0C
            agent_id += 2
        end
        for _ in 1:district_households[index, 3]
            # PWOP3P0C
            agent_id += 3
        end
        for _ in 1:district_households[index, 4]
            # PWOP3P1C
            agent_id += 3
        end
        for _ in 1:district_households[index, 5]
            # PWOP4P0C
            agent_id += 4
        end
        for _ in 1:district_households[index, 6]
            # PWOP4P1C
            agent_id += 4
        end
        for _ in 1:district_households[index, 7]
            # PWOP4P2C
            agent_id += 4
        end
        for _ in 1:district_households[index, 8]
            # PWOP5P0C
            agent_id += 5
        end
        for _ in 1:district_households[index, 9]
            # PWOP5P1C
            agent_id += 5
        end
        for _ in 1:district_households[index, 10]
            # PWOP5P2C
            agent_id += 5
        end
        for _ in 1:district_households[index, 11]
            # PWOP5P3C
            agent_id += 5
        end
        for _ in 1:district_households[index, 12]
            # PWOP6P0C
            agent_id += 6
        end
        for _ in 1:district_households[index, 13]
            # PWOP6P1C
            agent_id += 6
        end
        for _ in 1:district_households[index, 14]
            # PWOP6P2C
            agent_id += 6
        end
        for _ in 1:district_households[index, 15]
            # PWOP6P3C
            agent_id += 6
        end
        for _ in 1:district_households[index, 16]
            # 2PWOP4P0C
            agent_id += 4
        end
        for _ in 1:district_households[index, 17]
            # 2PWOP5P0C
            agent_id += 5
        end
        for _ in 1:district_households[index, 18]
            # 2PWOP5P1C
            agent_id += 5
        end
        for _ in 1:district_households[index, 19]
            # 2PWOP6P0C
            agent_id += 6
        end
        for _ in 1:district_households[index, 20]
            # 2PWOP6P1C
            agent_id += 6
        end
        for _ in 1:district_households[index, 21]
            # 2PWOP6P2C
            agent_id += 6
        end
        for _ in 1:district_households[index, 22]
            # SMWC2P0C
            agent_id += 2
        end
        for _ in 1:district_households[index, 23]
            # SMWC2P1C
            agent_id += 2
        end
        for _ in 1:district_households[index, 24]
            # SMWC3P0C
            agent_id += 3
        end
        for _ in 1:district_households[index, 25]
            # SMWC3P1C
            agent_id += 3
        end
        for _ in 1:district_households[index, 26]
            # SMWC3P2C
            agent_id += 3
        end
        for _ in 1:district_households[index, 27]
            # SMWC4P0C
            agent_id += 4
        end
        for _ in 1:district_households[index, 28]
            # SMWC4P1C
            agent_id += 4
        end
        for _ in 1:district_households[index, 29]
            # SMWC4P2C
            agent_id += 4
        end
        for _ in 1:district_households[index, 30]
            # SMWC4P3C
            agent_id += 4
        end
        for _ in 1:district_households[index, 31]
            # SFWC2P0C
            agent_id += 2
        end
        for _ in 1:district_households[index, 32]
            # SFWC2P1C
            agent_id += 2
        end
        for _ in 1:district_households[index, 33]
            # SFWC3P0C
            agent_id += 3
        end
        for _ in 1:district_households[index, 34]
            # SFWC3P1C
            agent_id += 3
        end
        for _ in 1:district_households[index, 35]
            # SFWC3P2C
            agent_id += 3
        end
        for _ in 1:district_households[index, 36]
            # SPWCWP3P0C
            agent_id += 3
        end
        for _ in 1:district_households[index, 37]
            # SPWCWP3P1C
            agent_id += 3
        end
        for _ in 1:district_households[index, 38]
            # SPWCWP4P0C
            agent_id += 4
        end
        for _ in 1:district_households[index, 39]
            # SPWCWP4P1C
            agent_id += 4
        end
        for _ in 1:district_households[index, 40]
            # SPWCWP4P2C
            agent_id += 4
        end

        for _ in 1:district_households[index, 41]
            # SPWCWPWOP3P0C
            agent_id += 3
        end
        for _ in 1:district_households[index, 42]
            # SPWCWPWOP3P1C
            agent_id += 3
        end
        for _ in 1:district_households[index, 43]
            # SPWCWPWOP4P0C
            agent_id += 4
        end
        for _ in 1:district_households[index, 44]
            # SPWCWPWOP4P1C
            agent_id += 4
        end
        for _ in 1:district_households[index, 45]
            # SPWCWPWOP4P2C
            agent_id += 4
        end
        for _ in 1:district_households[index, 46]
            # SPWCWPWOP5P0C
            agent_id += 5
        end
        for _ in 1:district_households[index, 47]
            # SPWCWPWOP5P1C
            agent_id += 5
        end
        for _ in 1:district_households[index, 48]
            # SPWCWPWOP5P2C
            agent_id += 5
        end

        for _ in 1:district_households[index, 49]
            # O2P0C
            agent_id += 2
        end
        for _ in 1:district_households[index, 50]
            # O2P1C
            agent_id += 2
        end
        for _ in 1:district_households[index, 51]
            # O3P0C
            agent_id += 3
        end
        for _ in 1:district_households[index, 52]
            # O3P1C
            agent_id += 3
        end
        for _ in 1:district_households[index, 53]
            # O3P2C
            agent_id += 3
        end
        for _ in 1:district_households[index, 54]
            # O4P0C
            agent_id += 4
        end
        for _ in 1:district_households[index, 55]
            # O4P1C
            agent_id += 4
        end
        for _ in 1:district_households[index, 56]
            # O4P2C
            agent_id += 4
        end
        for _ in 1:district_households[index, 57]
            # O4P3C
            agent_id += 4
        end
        for _ in 1:district_households[index, 58]
            # O5P0C
            agent_id += 5
        end
        for _ in 1:district_households[index, 59]
            # O5P1C
            agent_id += 5
        end
        for _ in 1:district_households[index, 60]
            # O5P2C
            agent_id += 5
        end
        for _ in 1:district_households[index, 61]
            # O5P3C
            agent_id += 5
        end
        for _ in 1:district_households[index, 62]
            # O6P0C
            agent_id += 6
        end
        for _ in 1:district_households[index, 63]
            # O6P1C
            agent_id += 6
        end
        for _ in 1:district_households[index, 64]
            # O6P2C
            agent_id += 6
        end
        for _ in 1:district_households[index, 65]
            # O6P3C
            agent_id += 6
        end
        end_agent_ids_districts[index] = agent_id - 1
    end
    return start_agent_ids_districts, end_agent_ids_districts
end

function main()
    # district_nums = get_district_nums()
    # district_households = get_district_households()

    # start_agent_ids_districts, end_agent_ids_districts = get_district_people_ids(
    #     district_nums, district_households)
    # println("start_agent_ids_districts = $(start_agent_ids_districts)")
    # println("end_agent_ids_districts = $(end_agent_ids_districts)")
    # return

    num_threads = nthreads()

    kindergarten_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "kindergartens.csv")))
    school_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "schools.csv")))
    university_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "universities.csv")))
    shop_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "shops.csv")))
    restaurant_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "restaurants.csv")))

    num_kindergartens = zeros(Int, num_threads)
    @threads for thread_id in 1:num_threads
        for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
            kindergartens_coords_district_df = kindergarten_coords_df[kindergarten_coords_df.dist .== index, :]
            num_kindergartens[thread_id] += size(kindergartens_coords_district_df)[1]
        end
    end

    num_schools = zeros(Int, num_threads)
    @threads for thread_id in 1:num_threads
        for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
            schools_coords_district_df = school_coords_df[school_coords_df.dist .== index, :]
            num_schools[thread_id] += size(schools_coords_district_df)[1]
        end
    end

    num_universities = zeros(Int, num_threads)
    @threads for thread_id in 1:num_threads
        for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
            universities_coords_district_df = university_coords_df[university_coords_df.dist .== index, :]
            num_universities[thread_id] += size(universities_coords_district_df)[1]
        end
    end

    num_shops = zeros(Int, num_threads)
    @threads for thread_id in 1:num_threads
        for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
            shops_coords_district_df = shop_coords_df[shop_coords_df.dist .== index, :]
            num_shops[thread_id] += size(shops_coords_district_df)[1]
        end
    end

    num_restaurants = zeros(Int, num_threads)
    @threads for thread_id in 1:num_threads
        for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
            restaurants_coords_district_df = restaurant_coords_df[restaurant_coords_df.dist .== index, :]
            num_restaurants[thread_id] += size(restaurants_coords_district_df)[1]
        end
    end

    num_agents = Array{Int, 1}(undef, num_threads)
    num_households = Array{Int, 1}(undef, num_threads)
    @threads for thread_id in 1:num_threads
        num_agents[thread_id], num_households[thread_id] = get_num_of_people_and_households(
            thread_id, num_threads, district_nums, district_households)
    end

    println("const num_agents = $(sum(num_agents))")
    print("const start_agent_ids = Int[1, ")
    sum_entities = 1
    for thread_id in 2:(num_threads - 1)
        sum_entities += num_agents[thread_id - 1]
        print("$(sum_entities), ")
    end
    sum_entities += num_agents[num_threads - 1]
    println("$(sum_entities)]")
    print("const end_agent_ids = Int[")
    sum_entities = 0
    for thread_id in 1:(num_threads - 1)
        sum_entities += num_agents[thread_id]
        print("$(sum_entities), ")
    end
    sum_entities += num_agents[num_threads]
    println("$(sum_entities)]")

    println("const num_households = $(sum(num_households))")
    print("const start_household_ids = Int[1, ")
    sum_entities = 1
    for thread_id in 2:(num_threads - 1)
        sum_entities += num_households[thread_id - 1]
        print("$(sum_entities), ")
    end
    sum_entities += num_households[num_threads - 1]
    println("$(sum_entities)]")
    print("const end_household_ids = Int[")
    sum_entities = 0
    for thread_id in 1:(num_threads - 1)
        sum_entities += num_households[thread_id]
        print("$(sum_entities), ")
    end
    sum_entities += num_households[num_threads]
    println("$(sum_entities)]")

    println("const num_kindergartens = $(size(kindergarten_coords_df)[1])")
    print("const start_kindergarten_ids = Int[1, ")
    sum_entities = 1
    for thread_id in 2:(num_threads - 1)
        sum_entities += num_kindergartens[thread_id - 1]
        print("$(sum_entities), ")
    end
    sum_entities += num_kindergartens[num_threads - 1]
    println("$(sum_entities)]")
    print("const end_kindergarten_ids = Int[")
    sum_entities = 0
    for thread_id in 1:(num_threads - 1)
        sum_entities += num_kindergartens[thread_id]
        print("$(sum_entities), ")
    end
    sum_entities += num_kindergartens[num_threads]
    println("$(sum_entities)]")

    println("const num_schools = $(size(school_coords_df)[1])")
    print("const start_school_ids = Int[1, ")
    sum_entities = 1
    for thread_id in 2:(num_threads - 1)
        sum_entities += num_schools[thread_id - 1]
        print("$(sum_entities), ")
    end
    sum_entities += num_schools[num_threads - 1]
    println("$(sum_entities)]")
    print("const end_school_ids = Int[")
    sum_entities = 0
    for thread_id in 1:(num_threads - 1)
        sum_entities += num_schools[thread_id]
        print("$(sum_entities), ")
    end
    sum_entities += num_schools[num_threads]
    println("$(sum_entities)]")

    println("const num_universities = $(size(university_coords_df)[1])")
    print("const start_university_ids = Int[1, ")
    sum_entities = 1
    for thread_id in 2:(num_threads - 1)
        sum_entities += num_universities[thread_id - 1]
        print("$(sum_entities), ")
    end
    sum_entities += num_universities[num_threads - 1]
    println("$(sum_entities)]")
    print("const end_university_ids = Int[")
    sum_entities = 0
    for thread_id in 1:(num_threads - 1)
        sum_entities += num_universities[thread_id]
        print("$(sum_entities), ")
    end
    sum_entities += num_universities[num_threads]
    println("$(sum_entities)]")

    println("const num_shops = $(size(shop_coords_df)[1])")
    print("const start_shop_ids = Int[1, ")
    sum_entities = 1
    for thread_id in 2:(num_threads - 1)
        sum_entities += num_shops[thread_id - 1]
        print("$(sum_entities), ")
    end
    sum_entities += num_shops[num_threads - 1]
    println("$(sum_entities)]")
    print("const end_shop_ids = Int[")
    sum_entities = 0
    for thread_id in 1:(num_threads - 1)
        sum_entities += num_shops[thread_id]
        print("$(sum_entities), ")
    end
    sum_entities += num_shops[num_threads]
    println("$(sum_entities)]")

    println("const num_restaurants = $(size(restaurant_coords_df)[1])")
    print("const start_restaurant_ids = Int[1, ")
    sum_entities = 1
    for thread_id in 2:(num_threads - 1)
        sum_entities += num_restaurants[thread_id - 1]
        print("$(sum_entities), ")
    end
    sum_entities += num_restaurants[num_threads - 1]
    println("$(sum_entities)]")
    print("const end_restaurant_ids = Int[")
    sum_entities = 0
    for thread_id in 1:(num_threads - 1)
        sum_entities += num_restaurants[thread_id]
        print("$(sum_entities), ")
    end
    sum_entities += num_restaurants[num_threads]
    println("$(sum_entities)]")
end

main()
