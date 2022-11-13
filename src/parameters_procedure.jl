using Base.Threads
using DelimitedFiles
using XGBoost
using Statistics
using LatinHypercubeSampling
using JLD

include("data/etiology.jl")
include("util/moving_avg.jl")

include("util/regression.jl")

function main()
    with_prediction = true

    num_runs_1 = 218
    num_runs_2 = 132
    num_runs_3 = 60
    num_runs = num_runs_1 + num_runs_2 + num_runs_3
    num_years = 2

    forest_num_rounds = 100
    forest_max_depth = 8

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_runs)
    duration_parameters = Array{Float64, 1}(undef, num_runs)
    susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_runs)
    temperature_parameters = Array{Vector{Float64}, 1}(undef, num_runs)
    random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_runs)
    immune_memory_susceptibility_levels = Array{Vector{Float64}, 1}(undef, num_runs)
    mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_runs)

    for i = 1:num_runs_1
        incidence_arr[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "1", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
        duration_parameters[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "1", "tables", "results_$(i).jld"))["duration_parameter"]
        susceptibility_parameters[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "1", "tables", "results_$(i).jld"))["susceptibility_parameters"]
        temperature_parameters[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "1", "tables", "results_$(i).jld"))["temperature_parameters"]
        immune_memory_susceptibility_levels[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "1", "tables", "results_$(i).jld"))["immune_memory_susceptibility_levels"]
        mean_immunity_durations[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "1", "tables", "results_$(i).jld"))["mean_immunity_durations"]
        random_infection_probabilities[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "1", "tables", "results_$(i).jld"))["random_infection_probabilities"]
    end

    for i = 1:num_runs_2
        incidence_arr[i + num_runs_1] = load(joinpath(@__DIR__, "..", "parameters_labels", "2", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
        duration_parameters[i + num_runs_1] = load(joinpath(@__DIR__, "..", "parameters_labels", "2", "tables", "results_$(i).jld"))["duration_parameter"]
        susceptibility_parameters[i + num_runs_1] = load(joinpath(@__DIR__, "..", "parameters_labels", "2", "tables", "results_$(i).jld"))["susceptibility_parameters"]
        temperature_parameters[i + num_runs_1] = load(joinpath(@__DIR__, "..", "parameters_labels", "2", "tables", "results_$(i).jld"))["temperature_parameters"]
        immune_memory_susceptibility_levels[i + num_runs_1] = load(joinpath(@__DIR__, "..", "parameters_labels", "2", "tables", "results_$(i).jld"))["immune_memory_susceptibility_levels"]
        mean_immunity_durations[i + num_runs_1] = load(joinpath(@__DIR__, "..", "parameters_labels", "2", "tables", "results_$(i).jld"))["mean_immunity_durations"]
        random_infection_probabilities[i + num_runs_1] = load(joinpath(@__DIR__, "..", "parameters_labels", "2", "tables", "results_$(i).jld"))["random_infection_probabilities"]
    end

    for i = 1:num_runs_3
        incidence_arr[i + num_runs_1 + num_runs_2] = load(joinpath(@__DIR__, "..", "parameters_labels", "3", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
        duration_parameters[i + num_runs_1 + num_runs_2] = load(joinpath(@__DIR__, "..", "parameters_labels", "3", "tables", "results_$(i).jld"))["duration_parameter"]
        susceptibility_parameters[i + num_runs_1 + num_runs_2] = load(joinpath(@__DIR__, "..", "parameters_labels", "3", "tables", "results_$(i).jld"))["susceptibility_parameters"]
        temperature_parameters[i + num_runs_1 + num_runs_2] = load(joinpath(@__DIR__, "..", "parameters_labels", "3", "tables", "results_$(i).jld"))["temperature_parameters"]
        immune_memory_susceptibility_levels[i + num_runs_1 + num_runs_2] = load(joinpath(@__DIR__, "..", "parameters_labels", "3", "tables", "results_$(i).jld"))["immune_memory_susceptibility_levels"]
        mean_immunity_durations[i + num_runs_1 + num_runs_2] = load(joinpath(@__DIR__, "..", "parameters_labels", "3", "tables", "results_$(i).jld"))["mean_immunity_durations"]
        random_infection_probabilities[i + num_runs_1 + num_runs_2] = load(joinpath(@__DIR__, "..", "parameters_labels", "3", "tables", "results_$(i).jld"))["random_infection_probabilities"]
    end

    num_params = 33
    num_viruses = 7
    X = zeros(Float64, num_runs, num_params)

    for i = 1:num_runs
        X[i, 1] = duration_parameters[i]
        for k = 1:num_viruses
            X[i, 1 + k] = susceptibility_parameters[i][k]
        end
        for k = 1:num_viruses
            X[i, 1 + num_viruses + k] = temperature_parameters[i][k]
        end
        for k = 1:num_viruses
            X[i, 1 + 2 * num_viruses + k] = immune_memory_susceptibility_levels[i][k]
        end
        for k = 1:num_viruses
            X[i, 1 + 3 * num_viruses + k] = mean_immunity_durations[i][k]
        end
        for k = 1:4
            X[i, 1 + 4 * num_viruses + k] = random_infection_probabilities[i][k]
        end
    end

    etiology = get_etiology()

    infected_data_0_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n') ./ 10072
    infected_data_3_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n') ./ 10072
    infected_data_7_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n') ./ 10072
    infected_data_15_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n') ./ 10072

    infected_data_0 = infected_data_0_all[2:53, 24:(23 + num_years)]
    infected_data_0_1 = etiology[:, 1] .* infected_data_0
    infected_data_0_2 = etiology[:, 2] .* infected_data_0
    infected_data_0_3 = etiology[:, 3] .* infected_data_0
    infected_data_0_4 = etiology[:, 4] .* infected_data_0
    infected_data_0_5 = etiology[:, 5] .* infected_data_0
    infected_data_0_6 = etiology[:, 6] .* infected_data_0
    infected_data_0_7 = etiology[:, 7] .* infected_data_0
    infected_data_0_viruses = cat(
        vec(infected_data_0_1),
        vec(infected_data_0_2),
        vec(infected_data_0_3),
        vec(infected_data_0_4),
        vec(infected_data_0_5),
        vec(infected_data_0_6),
        vec(infected_data_0_7),
        dims = 2)

    infected_data_3 = infected_data_3_all[2:53, 24:(23 + num_years)]
    infected_data_3_1 = etiology[:, 1] .* infected_data_3
    infected_data_3_2 = etiology[:, 2] .* infected_data_3
    infected_data_3_3 = etiology[:, 3] .* infected_data_3
    infected_data_3_4 = etiology[:, 4] .* infected_data_3
    infected_data_3_5 = etiology[:, 5] .* infected_data_3
    infected_data_3_6 = etiology[:, 6] .* infected_data_3
    infected_data_3_7 = etiology[:, 7] .* infected_data_3
    infected_data_3_viruses = cat(
        vec(infected_data_3_1),
        vec(infected_data_3_2),
        vec(infected_data_3_3),
        vec(infected_data_3_4),
        vec(infected_data_3_5),
        vec(infected_data_3_6),
        vec(infected_data_3_7),
        dims = 2)

    infected_data_7 = infected_data_7_all[2:53, 24:(23 + num_years)]
    infected_data_7_1 = etiology[:, 1] .* infected_data_7
    infected_data_7_2 = etiology[:, 2] .* infected_data_7
    infected_data_7_3 = etiology[:, 3] .* infected_data_7
    infected_data_7_4 = etiology[:, 4] .* infected_data_7
    infected_data_7_5 = etiology[:, 5] .* infected_data_7
    infected_data_7_6 = etiology[:, 6] .* infected_data_7
    infected_data_7_7 = etiology[:, 7] .* infected_data_7
    infected_data_7_viruses = cat(
        vec(infected_data_7_1),
        vec(infected_data_7_2),
        vec(infected_data_7_3),
        vec(infected_data_7_4),
        vec(infected_data_7_5),
        vec(infected_data_7_6),
        vec(infected_data_7_7),
        dims = 2)

    infected_data_15 = infected_data_15_all[2:53, 24:(23 + num_years)]
    infected_data_15_1 = etiology[:, 1] .* infected_data_15
    infected_data_15_2 = etiology[:, 2] .* infected_data_15
    infected_data_15_3 = etiology[:, 3] .* infected_data_15
    infected_data_15_4 = etiology[:, 4] .* infected_data_15
    infected_data_15_5 = etiology[:, 5] .* infected_data_15
    infected_data_15_6 = etiology[:, 6] .* infected_data_15
    infected_data_15_7 = etiology[:, 7] .* infected_data_15
    infected_data_15_viruses = cat(
        vec(infected_data_15_1),
        vec(infected_data_15_2),
        vec(infected_data_15_3),
        vec(infected_data_15_4),
        vec(infected_data_15_5),
        vec(infected_data_15_6),
        vec(infected_data_15_7),
        dims = 2)

    num_infected_age_groups_viruses = cat(
        infected_data_0_viruses,
        infected_data_3_viruses,
        infected_data_7_viruses,
        infected_data_15_viruses,
        dims = 3,
    )

    y = zeros(Float64, num_runs)
    for i = 1:num_runs
        sum = 0.0
        for w = 1:size(num_infected_age_groups_viruses)[1]
            for v = 1:size(num_infected_age_groups_viruses)[2]
                for a = 1:size(num_infected_age_groups_viruses)[3]
                    sum += (num_infected_age_groups_viruses[w, v, a] - incidence_arr[i][w, v, a])^2
                end
            end
        end
        # sum /= size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3]
        y[i] = sum
    end

    println(minimum(y))
    println(argmin(y))
    println(maximum(y))
    println(argmax(y))

    pos_min_y = argmin(y)

    bst = xgboost((X, y), num_round=forest_num_rounds, max_depth=forest_max_depth, objective="reg:squarederror")

    if with_prediction
        S = 20
        num_samples = 3000
        # num_samples = 100
        min_values = zeros(Float64, S) .+ 99999.0
        duration_parameters_min = zeros(Float64, S)
        susceptibility_parameters_min = zeros(Float64, num_viruses, S)
        temperature_parameters_min = zeros(Float64, num_viruses, S)
        immune_memory_susceptibility_levels_min = zeros(Float64, num_viruses, S)
        mean_immunity_durations_min = zeros(Float64, num_viruses, S)
        random_infection_probabilities_min = zeros(Float64, 4, S)

        num_parameters = 33
        @time latin_hypercube_plan, _ = LHCoptim(num_samples, num_parameters, 5)

        duration_parameter_default = duration_parameters[pos_min_y]
        susceptibility_parameters_default = susceptibility_parameters[pos_min_y]
        temperature_parameters_default = temperature_parameters[pos_min_y]
        immune_memory_susceptibility_levels_default = immune_memory_susceptibility_levels[pos_min_y]
        mean_immunity_durations_default = mean_immunity_durations[pos_min_y]
        random_infection_probabilities_default = random_infection_probabilities[pos_min_y]

        # println(duration_parameter_default)
        # println(susceptibility_parameters_default)
        # println(temperature_parameters_default)
        # println(immune_memory_susceptibility_levels_default)
        # println(mean_immunity_durations_default)
        # println(random_infection_probabilities_default)
        # return

        for i = 1:7
            if temperature_parameters_default[i] < -0.95
                temperature_parameters_default[i] = -0.95
            elseif temperature_parameters_default[i] > -0.05
                temperature_parameters_default[i] = -0.05
            end
    
            if immune_memory_susceptibility_levels_default[i] > 0.95
                immune_memory_susceptibility_levels_default[i] = 0.95
            elseif immune_memory_susceptibility_levels_default[i] < 0.05
                immune_memory_susceptibility_levels_default[i] = 0.05
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
            (immune_memory_susceptibility_levels_default[1] - 0.05, immune_memory_susceptibility_levels_default[1] + 0.05),
            (immune_memory_susceptibility_levels_default[2] - 0.05, immune_memory_susceptibility_levels_default[2] + 0.05),
            (immune_memory_susceptibility_levels_default[3] - 0.05, immune_memory_susceptibility_levels_default[3] + 0.05),
            (immune_memory_susceptibility_levels_default[4] - 0.05, immune_memory_susceptibility_levels_default[4] + 0.05),
            (immune_memory_susceptibility_levels_default[5] - 0.05, immune_memory_susceptibility_levels_default[5] + 0.05),
            (immune_memory_susceptibility_levels_default[6] - 0.05, immune_memory_susceptibility_levels_default[6] + 0.05),
            (immune_memory_susceptibility_levels_default[7] - 0.05, immune_memory_susceptibility_levels_default[7] + 0.05),
            (mean_immunity_durations[1] - 5.0, mean_immunity_durations[1] + 5.0),
            (mean_immunity_durations[2] - 5.0, mean_immunity_durations[2] + 5.0),
            (mean_immunity_durations[3] - 5.0, mean_immunity_durations[3] + 5.0),
            (mean_immunity_durations[4] - 5.0, mean_immunity_durations[4] + 5.0),
            (mean_immunity_durations[5] - 5.0, mean_immunity_durations[5] + 5.0),
            (mean_immunity_durations[6] - 5.0, mean_immunity_durations[6] + 5.0),
            (mean_immunity_durations[7] - 5.0, mean_immunity_durations[7] + 5.0),
            (random_infection_probabilities_default[1] - random_infection_probabilities_default[1] * 0.05, random_infection_probabilities_default[1] + random_infection_probabilities_default[1] * 0.05),
            (random_infection_probabilities_default[2] - random_infection_probabilities_default[2] * 0.05, random_infection_probabilities_default[2] + random_infection_probabilities_default[2] * 0.05),
            (random_infection_probabilities_default[3] - random_infection_probabilities_default[3] * 0.05, random_infection_probabilities_default[3] + random_infection_probabilities_default[3] * 0.05),
            (random_infection_probabilities_default[4] - random_infection_probabilities_default[4] * 0.05, random_infection_probabilities_default[4] + random_infection_probabilities_default[4] * 0.05),
        ])

        mean_immunity_durations = zeros(Float64, 7)

        for i = 1:num_samples
            duration_parameter = points[i, 1]
            susceptibility_parameters = points[i, 2:8]
            temperature_parameters = points[i, 9:15]
            immune_memory_susceptibility_levels =  points[i, 16:22]
            random_infection_probabilities = points[i, 30:33]

            for k = 1:num_viruses
                mean_immunity_durations[k] = points[i, 22 + k]
            end

            par_vec = [duration_parameter]
            append!(par_vec, susceptibility_parameters)
            append!(par_vec, temperature_parameters)
            append!(par_vec, immune_memory_susceptibility_levels)
            append!(par_vec, mean_immunity_durations)
            append!(par_vec, random_infection_probabilities)

            r = reshape(par_vec, 1, :)

            SSE = predict(bst, r)[1]
            for k = 1:S
                if SSE < min_values[k]
                    min_values[k] = SSE

                    duration_parameters_min[k] = duration_parameter
                    for j = 1:num_viruses
                        susceptibility_parameters_min[j, k] = susceptibility_parameters[j]
                        temperature_parameters_min[j, k] = temperature_parameters[j]
                        immune_memory_susceptibility_levels_min[j, k] = immune_memory_susceptibility_levels[j]
                        mean_immunity_durations_min[j, k] = mean_immunity_durations[j]
                    end
                    for j = 1:4
                        random_infection_probabilities_min[j, k] = random_infection_probabilities[j]
                    end
                    break
                end
            end
        end
        for i = 1:S
            println()
            println("---------------------------------------------------")
            println(i)
            println(min_values[i])
            println("Real: ")
            println("duration_parameter = $(duration_parameters_min[i])")
            println("susceptibility_parameters = $(susceptibility_parameters_min[:, i])")
            println("temperature_parameters = $(temperature_parameters_min[:, i])")
            println("immune_memory_susceptibility_levels = $(immune_memory_susceptibility_levels_min[:, i])")
            println("mean_immunity_durations = $(mean_immunity_durations_min[:, i])")
            println("random_infection_probabilities = $(random_infection_probabilities_min[:, i])")
            println("---------------------------------------------------")
        end
    end
end

main()
