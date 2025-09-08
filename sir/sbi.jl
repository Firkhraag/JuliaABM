using Base.Threads
using DelimitedFiles
using Statistics
using LatinHypercubeSampling
using CSV
using JLD2
using DataFrames
using Distributions

function main()
    num_initial_runs = 10
    X = zeros(Float64, num_initial_runs, 4)
    y = zeros(Float64, num_initial_runs, 1200)
    for i = 1:num_initial_runs
        y[i, :] = vec(load(joinpath(@__DIR__, "lhs", "results_$(i).jld2"))["result"])
        X[i, 1] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld2"))["β_parameter"]
        X[i, 2] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld2"))["c_parameter"]
        X[i, 3] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld2"))["γ_parameter"]
        X[i, 4] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld2"))["I0_parameter"]
    end
    CSV.write(joinpath(@__DIR__, "lhs_y.csv"),  Tables.table(y), writeheader = false)
    CSV.write(joinpath(@__DIR__, "lhs_params.csv"),  Tables.table(X), writeheader = false)
end

main()