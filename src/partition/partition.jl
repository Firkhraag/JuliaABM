using Base.Threads
using Distributions
using Random

include("../model/virus.jl")
include("../model/collective.jl")

include("initialization.jl")

include("../data/district_households.jl")
include("../data/district_people.jl")
include("../data/district_people_households.jl")
include("../data/district_nums.jl")
include("../data/temperature.jl")
include("../data/etiology.jl")

function main()
    district_nums = get_district_nums()
    district_households = get_district_households()

    num_threads = nthreads()
    println("Partition...")
    @time @threads for thread_id in 1:num_threads
        local num_people = create_population(thread_id, num_threads, district_nums, district_households)
        println("Thread: $(thread_id), Size: $(num_people)")
    end
end

main()
