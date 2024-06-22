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
    # num_initial_runs = 1000
    # X = zeros(Float64, num_initial_runs, 26)
    # y = zeros(Float64, num_initial_runs, 1456)
    # for i = 1:num_initial_runs
    #     y[i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["observed_cases"])
    #     X[i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["duration_parameter"]
    #     X[i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["susceptibility_parameters"]
    #     X[i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["temperature_parameters"]
    #     X[i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["mean_immunity_durations"]
    #     X[i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["random_infection_probabilities"]
    # end

    # num_initial_runs = 200
    # X = zeros(Float64, num_initial_runs * 3, 26)
    # y = zeros(Float64, num_initial_runs * 3, 1456)
    # for i = 1:num_initial_runs
    #     y[i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual1", "results_$(i).jld"))["observed_cases"])
    #     X[i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual1", "results_$(i).jld"))["duration_parameter"]
    #     X[i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual1", "results_$(i).jld"))["susceptibility_parameters"]
    #     X[i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual1", "results_$(i).jld"))["temperature_parameters"]
    #     X[i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual1", "results_$(i).jld"))["mean_immunity_durations"]
    #     X[i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual1", "results_$(i).jld"))["random_infection_probabilities"]
    # end
    # for i = 1:num_initial_runs
    #     y[num_initial_runs + i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual2", "results_$(i).jld"))["observed_cases"])
    #     X[num_initial_runs + i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual2", "results_$(i).jld"))["duration_parameter"]
    #     X[num_initial_runs + i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual2", "results_$(i).jld"))["susceptibility_parameters"]
    #     X[num_initial_runs + i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual2", "results_$(i).jld"))["temperature_parameters"]
    #     X[num_initial_runs + i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual2", "results_$(i).jld"))["mean_immunity_durations"]
    #     X[num_initial_runs + i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual2", "results_$(i).jld"))["random_infection_probabilities"]
    # end
    # for i = 1:num_initial_runs
    #     y[2 * num_initial_runs + i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual3", "results_$(i).jld"))["observed_cases"])
    #     X[2 * num_initial_runs + i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual3", "results_$(i).jld"))["duration_parameter"]
    #     X[2 * num_initial_runs + i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual3", "results_$(i).jld"))["susceptibility_parameters"]
    #     X[2 * num_initial_runs + i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual3", "results_$(i).jld"))["temperature_parameters"]
    #     X[2 * num_initial_runs + i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual3", "results_$(i).jld"))["mean_immunity_durations"]
    #     X[2 * num_initial_runs + i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual3", "results_$(i).jld"))["random_infection_probabilities"]
    # end
    # CSV.write(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual_y.csv"),  Tables.table(y), writeheader = false)
    # CSV.write(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual_params.csv"),  Tables.table(X), writeheader = false)

    num_initial_runs = 200
    X = zeros(Float64, num_initial_runs * 15 + 1000, 26)
    y = zeros(Float64, num_initial_runs * 15 + 1000, 1456)
    for i = 1:num_initial_runs
        y[i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual1", "results_$(i).jld"))["observed_cases"])
        X[i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual1", "results_$(i).jld"))["duration_parameter"]
        X[i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual1", "results_$(i).jld"))["susceptibility_parameters"]
        X[i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual1", "results_$(i).jld"))["temperature_parameters"]
        X[i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual1", "results_$(i).jld"))["mean_immunity_durations"]
        X[i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual1", "results_$(i).jld"))["random_infection_probabilities"]
    end
    for i = 1:num_initial_runs
        y[num_initial_runs + i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual2", "results_$(i).jld"))["observed_cases"])
        X[num_initial_runs + i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual2", "results_$(i).jld"))["duration_parameter"]
        X[num_initial_runs + i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual2", "results_$(i).jld"))["susceptibility_parameters"]
        X[num_initial_runs + i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual2", "results_$(i).jld"))["temperature_parameters"]
        X[num_initial_runs + i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual2", "results_$(i).jld"))["mean_immunity_durations"]
        X[num_initial_runs + i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual2", "results_$(i).jld"))["random_infection_probabilities"]
    end
    for i = 1:num_initial_runs
        y[2 * num_initial_runs + i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual3", "results_$(i).jld"))["observed_cases"])
        X[2 * num_initial_runs + i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual3", "results_$(i).jld"))["duration_parameter"]
        X[2 * num_initial_runs + i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual3", "results_$(i).jld"))["susceptibility_parameters"]
        X[2 * num_initial_runs + i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual3", "results_$(i).jld"))["temperature_parameters"]
        X[2 * num_initial_runs + i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual3", "results_$(i).jld"))["mean_immunity_durations"]
        X[2 * num_initial_runs + i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_manual3", "results_$(i).jld"))["random_infection_probabilities"]
    end

    for i = 1:num_initial_runs
        y[3 * num_initial_runs + i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube1", "results_$(i).jld"))["observed_cases"])
        X[3 * num_initial_runs + i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube1", "results_$(i).jld"))["duration_parameter"]
        X[3 * num_initial_runs + i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube1", "results_$(i).jld"))["susceptibility_parameters"]
        X[3 * num_initial_runs + i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube1", "results_$(i).jld"))["temperature_parameters"]
        X[3 * num_initial_runs + i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube1", "results_$(i).jld"))["mean_immunity_durations"]
        X[3 * num_initial_runs + i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube1", "results_$(i).jld"))["random_infection_probabilities"]
    end
    for i = 1:num_initial_runs
        y[4 * num_initial_runs + i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube2", "results_$(i).jld"))["observed_cases"])
        X[4 * num_initial_runs + i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube2", "results_$(i).jld"))["duration_parameter"]
        X[4 * num_initial_runs + i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube2", "results_$(i).jld"))["susceptibility_parameters"]
        X[4 * num_initial_runs + i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube2", "results_$(i).jld"))["temperature_parameters"]
        X[4 * num_initial_runs + i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube2", "results_$(i).jld"))["mean_immunity_durations"]
        X[4 * num_initial_runs + i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube2", "results_$(i).jld"))["random_infection_probabilities"]
    end
    for i = 1:num_initial_runs
        y[5 * num_initial_runs + i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube3", "results_$(i).jld"))["observed_cases"])
        X[5 * num_initial_runs + i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube3", "results_$(i).jld"))["duration_parameter"]
        X[5 * num_initial_runs + i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube3", "results_$(i).jld"))["susceptibility_parameters"]
        X[5 * num_initial_runs + i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube3", "results_$(i).jld"))["temperature_parameters"]
        X[5 * num_initial_runs + i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube3", "results_$(i).jld"))["mean_immunity_durations"]
        X[5 * num_initial_runs + i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "mcmc_hypercube3", "results_$(i).jld"))["random_infection_probabilities"]
    end
    
    for i = 1:num_initial_runs
        y[6 * num_initial_runs + i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "surrogate1", "results_$(i).jld"))["observed_cases"])
        X[6 * num_initial_runs + i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate1", "results_$(i).jld"))["duration_parameter"]
        X[6 * num_initial_runs + i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate1", "results_$(i).jld"))["susceptibility_parameters"]
        X[6 * num_initial_runs + i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate1", "results_$(i).jld"))["temperature_parameters"]
        X[6 * num_initial_runs + i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate1", "results_$(i).jld"))["mean_immunity_durations"]
        X[6 * num_initial_runs + i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate1", "results_$(i).jld"))["random_infection_probabilities"]
    end
    for i = 1:num_initial_runs
        y[7 * num_initial_runs + i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "surrogate2", "results_$(i).jld"))["observed_cases"])
        X[7 * num_initial_runs + i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate2", "results_$(i).jld"))["duration_parameter"]
        X[7 * num_initial_runs + i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate2", "results_$(i).jld"))["susceptibility_parameters"]
        X[7 * num_initial_runs + i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate2", "results_$(i).jld"))["temperature_parameters"]
        X[7 * num_initial_runs + i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate2", "results_$(i).jld"))["mean_immunity_durations"]
        X[7 * num_initial_runs + i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate2", "results_$(i).jld"))["random_infection_probabilities"]
    end
    for i = 1:num_initial_runs
        y[8 * num_initial_runs + i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "surrogate3", "results_$(i).jld"))["observed_cases"])
        X[8 * num_initial_runs + i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate3", "results_$(i).jld"))["duration_parameter"]
        X[8 * num_initial_runs + i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate3", "results_$(i).jld"))["susceptibility_parameters"]
        X[8 * num_initial_runs + i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate3", "results_$(i).jld"))["temperature_parameters"]
        X[8 * num_initial_runs + i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate3", "results_$(i).jld"))["mean_immunity_durations"]
        X[8 * num_initial_runs + i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "surrogate3", "results_$(i).jld"))["random_infection_probabilities"]
    end

    k = 1
    for i = 1:10
        for j = 1:20
            y[9 * num_initial_runs + k, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "swarm1", "$(i)", "results_$(j).jld"))["observed_cases"])
            X[9 * num_initial_runs + k, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm1", "$(i)", "results_$(j).jld"))["duration_parameter"]
            X[9 * num_initial_runs + k, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm1", "$(i)", "results_$(j).jld"))["susceptibility_parameters"]
            X[9 * num_initial_runs + k, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm1", "$(i)", "results_$(j).jld"))["temperature_parameters"]
            X[9 * num_initial_runs + k, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm1", "$(i)", "results_$(j).jld"))["mean_immunity_durations"]
            X[9 * num_initial_runs + k, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm1", "$(i)", "results_$(j).jld"))["random_infection_probabilities"]
            k += 1
        end
    end

    k = 1
    for i = 1:10
        for j = 1:20
            y[10 * num_initial_runs + k, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "swarm2", "$(i)", "results_$(j).jld"))["observed_cases"])
            X[10 * num_initial_runs + k, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm2", "$(i)", "results_$(j).jld"))["duration_parameter"]
            X[10 * num_initial_runs + k, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm2", "$(i)", "results_$(j).jld"))["susceptibility_parameters"]
            X[10 * num_initial_runs + k, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm2", "$(i)", "results_$(j).jld"))["temperature_parameters"]
            X[10 * num_initial_runs + k, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm2", "$(i)", "results_$(j).jld"))["mean_immunity_durations"]
            X[10 * num_initial_runs + k, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm2", "$(i)", "results_$(j).jld"))["random_infection_probabilities"]
            k += 1
        end
    end

    k = 1
    for i = 1:10
        for j = 1:20
            y[11 * num_initial_runs + k, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "swarm3", "$(i)", "results_$(j).jld"))["observed_cases"])
            X[11 * num_initial_runs + k, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm3", "$(i)", "results_$(j).jld"))["duration_parameter"]
            X[11 * num_initial_runs + k, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm3", "$(i)", "results_$(j).jld"))["susceptibility_parameters"]
            X[11 * num_initial_runs + k, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm3", "$(i)", "results_$(j).jld"))["temperature_parameters"]
            X[11 * num_initial_runs + k, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm3", "$(i)", "results_$(j).jld"))["mean_immunity_durations"]
            X[11 * num_initial_runs + k, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm3", "$(i)", "results_$(j).jld"))["random_infection_probabilities"]
            k += 1
        end
    end

    k = 1
    for i = 1:20
        for j = 1:10
            y[12 * num_initial_runs + k, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "ga1", "$(i)", "results_$(j).jld"))["observed_cases"])
            X[12 * num_initial_runs + k, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "ga1", "$(i)", "results_$(j).jld"))["duration_parameter"]
            X[12 * num_initial_runs + k, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "ga1", "$(i)", "results_$(j).jld"))["susceptibility_parameters"]
            X[12 * num_initial_runs + k, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "ga1", "$(i)", "results_$(j).jld"))["temperature_parameters"]
            X[12 * num_initial_runs + k, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "ga1", "$(i)", "results_$(j).jld"))["mean_immunity_durations"]
            X[12 * num_initial_runs + k, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "ga1", "$(i)", "results_$(j).jld"))["random_infection_probabilities"]
            k += 1
        end
    end

    k = 1
    for i = 1:20
        for j = 1:10
            y[13 * num_initial_runs + k, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "ga2", "$(i)", "results_$(j).jld"))["observed_cases"])
            X[13 * num_initial_runs + k, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "ga2", "$(i)", "results_$(j).jld"))["duration_parameter"]
            X[13 * num_initial_runs + k, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "ga2", "$(i)", "results_$(j).jld"))["susceptibility_parameters"]
            X[13 * num_initial_runs + k, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "ga2", "$(i)", "results_$(j).jld"))["temperature_parameters"]
            X[13 * num_initial_runs + k, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "ga2", "$(i)", "results_$(j).jld"))["mean_immunity_durations"]
            X[13 * num_initial_runs + k, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "ga2", "$(i)", "results_$(j).jld"))["random_infection_probabilities"]
            k += 1
        end
    end

    k = 1
    for i = 1:20
        for j = 1:10
            y[14 * num_initial_runs + k, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "ga3", "$(i)", "results_$(j).jld"))["observed_cases"])
            X[14 * num_initial_runs + k, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "ga3", "$(i)", "results_$(j).jld"))["duration_parameter"]
            X[14 * num_initial_runs + k, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "ga3", "$(i)", "results_$(j).jld"))["susceptibility_parameters"]
            X[14 * num_initial_runs + k, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "ga3", "$(i)", "results_$(j).jld"))["temperature_parameters"]
            X[14 * num_initial_runs + k, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "ga3", "$(i)", "results_$(j).jld"))["mean_immunity_durations"]
            X[14 * num_initial_runs + k, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "ga3", "$(i)", "results_$(j).jld"))["random_infection_probabilities"]
            k += 1
        end
    end

    for i = 1:1000
        y[15 * num_initial_runs + i, :] = vec(load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["observed_cases"])
        X[15 * num_initial_runs + i, 1] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["duration_parameter"]
        X[15 * num_initial_runs + i, 2:8] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["susceptibility_parameters"]
        X[15 * num_initial_runs + i, 9:15] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["temperature_parameters"]
        X[15 * num_initial_runs + i, 16:22] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["mean_immunity_durations"]
        X[15 * num_initial_runs + i, 23:26] = load(joinpath(@__DIR__, "..", "output", "tables", "lhs", "initial", "results_$(i).jld"))["random_infection_probabilities"]
    end

    CSV.write(joinpath(@__DIR__, "..", "output", "tables", "all_y.csv"),  Tables.table(y), writeheader = false)
    CSV.write(joinpath(@__DIR__, "..", "output", "tables", "all_params.csv"),  Tables.table(X), writeheader = false)

    # # Распределение вирусов в течение года
    # etiology = get_etiology()
    # # Заболеваемость различными вирусами в разных возрастных группах за рассматриваемые года
    # num_infected_age_groups_viruses = vec(get_incidence(etiology, true, flu_starting_index, true))
    # CSV.write(joinpath(@__DIR__, "..", "output", "tables", "data_y.csv"),  Tables.table(num_infected_age_groups_viruses), writeheader = false)
end

main()
