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

function main()
    num_initial_runs = 1000
    X = zeros(Float64, num_initial_runs, 26)
    y = zeros(Float64, num_initial_runs, 1456)
    y_data = zeros(Float64, num_initial_runs, 1456)
    for i = 1:num_initial_runs
        y[i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["observed_cases"])
        X[i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["duration_parameter"]
        X[i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["susceptibility_parameters"]
        X[i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["temperature_parameters"]
        X[i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["mean_immunity_durations"]
        X[i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["random_infection_probabilities"]
    end
    CSV.write(joinpath(@__DIR__, "..", "output", "tables", "lhs_y.csv"),  Tables.table(y), writeheader = false)
    CSV.write(joinpath(@__DIR__, "..", "output", "tables", "lhs_params.csv"),  Tables.table(X), writeheader = false)

    # Распределение вирусов в течение года
    etiology = get_etiology()
    # Заболеваемость различными вирусами в разных возрастных группах за рассматриваемые года
    num_infected_age_groups_viruses = vec(get_incidence(etiology, true, flu_starting_index, true))
    CSV.write(joinpath(@__DIR__, "..", "output", "tables", "data_y.csv"),  Tables.table(num_infected_age_groups_viruses), writeheader = false)
end

main()
