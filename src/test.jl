using Base.Threads
using DelimitedFiles
using Statistics
using LatinHypercubeSampling
using CSV
using JLD
using DataFrames
using Distributions

# Модель на сервере
include("../server/lib/data/etiology.jl")
include("../server/lib/data/incidence.jl")

include("../server/lib/global/variables.jl")

include("../server/lib/model/virus.jl")
include("../server/lib/model/agent.jl")
include("../server/lib/model/household.jl")
include("../server/lib/model/workplace.jl")
include("../server/lib/model/school.jl")
include("../server/lib/model/initialization.jl")
include("../server/lib/model/connections.jl")
include("../server/lib/model/contacts.jl")

include("../server/lib/util/moving_avg.jl")
include("../server/lib/util/stats.jl")
include("../server/lib/util/reset.jl")

# Локальная модель
include("model/simulation.jl")

function arg_n_smallest_values(A::AbstractArray{T,N}, n::Integer) where {T,N}
    perm = sortperm(vec(A))
    ci = CartesianIndices(A)
    return ci[perm[1:n]]
end

function run_test_model()

    println("Simulation")

    etiology = get_etiology()
    num_infected_age_groups_viruses = get_incidence(etiology, true, flu_starting_index, true)

    num_swarm_model_runs = 20
    num_initial_runs = 1000
    num_particles = 10

    num_years = 1
    num_parameters = 26
    num_viruses = 7

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, 20)
    duration_parameter = Array{Float64, 1}(undef, 20)
    susceptibility_parameters = Array{Vector{Float64}, 1}(undef, 20)
    temperature_parameters = Array{Vector{Float64}, 1}(undef, 20)
    random_infection_probabilities = Array{Vector{Float64}, 1}(undef, 20)
    mean_immunity_durations = Array{Vector{Float64}, 1}(undef, 20)

    y = zeros(Float64, 20)

    for i = 1:9
        for j = 1:20
            incidence_arr[j] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["observed_cases"]
            duration_parameter[i] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["duration_parameter"]
            # println(sum(abs.(incidence_arr[j] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses))
            println(duration_parameter[i])
        end
    end

end

run_test_model()
