using Base.Threads
using Distributions
using Random

include("initialization.jl")
include("../data/district_households.jl")
include("../data/district_nums.jl")

function main()
    district_nums = get_district_nums()
    district_households = get_district_households()

    num_threads = nthreads()
    num_people = Array{Int, 1}(undef, num_threads)
    @threads for thread_id in 1:num_threads
        num_people[thread_id] = get_num_of_people(thread_id, num_threads, district_nums, district_households)
    end

    println("const num_people = $(sum(num_people))")

    print("const start_agent_ids = Int[1, ")
    sum_people = 1
    for thread_id in 2:(num_threads - 1)
        sum_people += num_people[thread_id - 1]
        print("$(sum_people), ")
    end
    sum_people += num_people[num_threads - 1]
    println("$(sum_people)]")

    print("const end_agent_ids = Int[")
    sum_people = 0
    for thread_id in 1:(num_threads - 1)
        sum_people += num_people[thread_id]
        print("$(sum_people), ")
    end
    sum_people += num_people[num_threads]
    println("$(sum_people)]")
end

main()
