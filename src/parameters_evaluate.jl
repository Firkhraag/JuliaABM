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
    # 100: 684956.9664301063
    # 200: 319658.0652706171
    # 300: 230646.30169942373
    # 400: 469582.3638388009
    # 422: 603352.515866496

    # 100: 684956.9664301063
    # 200: 319658.0652706171
    # 300: 230646.30169942373
    # 400: 469582.3638388009
    # 422: 603352.515866496

    num_runs_1 = 219
    num_runs_2 = 132
    num_runs_3 = 71
    num_runs = num_runs_1 + num_runs_2 + num_runs_3

    num_years = 2

    forest_num_rounds = 100
    forest_max_depth = 10

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

    bst = xgboost((X, y), num_round=forest_num_rounds, max_depth=forest_max_depth, objective="reg:squarederror")

    duration_parameter = 3.4981229101810194
    susceptibility_parameters = [2.991060937985877, 3.2468795530538848, 3.401898437854858, 4.649676110814129, 3.7163523159649126, 3.8596161196887557, 4.856247287821134]
    temperature_parameters = [-0.9306122448979591, -0.9078000691802144, -0.01428571428571429, -0.12176102079249784, -0.16673883420856778, -0.19917639906501897, -0.33896680397891044]
    random_infection_probabilities = [0.0014812661428353913, 0.0008664926507337254, 0.0003871328065857679, 9.304102575238382e-6]
    immune_memory_susceptibility_levels = [0.8659281154680671, 0.9648299319727879, 0.9616326530612245, 0.9726530612244898, 0.9628571428571429, 0.9738775510204082, 0.8885714285714285]
    mean_immunity_durations = [336.32831252685975, 308.6526629141642, 132.1112562498035, 92.83376833013635, 100.85806526000232, 141.48287440297122, 160.4937231184206]

    par_vec = [duration_parameter]
    append!(par_vec, susceptibility_parameters)
    append!(par_vec, temperature_parameters)
    append!(par_vec, immune_memory_susceptibility_levels)
    append!(par_vec, mean_immunity_durations)
    append!(par_vec, random_infection_probabilities)

    r = reshape(par_vec, 1, :)

    SSE = predict(bst, r)[1]
    println(SSE)

    println(importancereport(bst))

    return

    num_evaluation_runs = 15
    incidence_arr_evaluation = Array{Array{Float64, 3}, 1}(undef, num_evaluation_runs)
    duration_parameters_evaluation = Array{Float64, 1}(undef, num_evaluation_runs)
    susceptibility_parameters_evaluation = Array{Vector{Float64}, 1}(undef, num_evaluation_runs)
    temperature_parameters_evaluation = Array{Vector{Float64}, 1}(undef, num_evaluation_runs)
    random_infection_probabilities_evaluation = Array{Vector{Float64}, 1}(undef, num_evaluation_runs)
    immune_memory_susceptibility_levels_evaluation = Array{Vector{Float64}, 1}(undef, num_evaluation_runs)
    mean_immunity_durations_evaluation = Array{Vector{Float64}, 1}(undef, num_evaluation_runs)

    for i = 1:num_evaluation_runs
        incidence_arr_evaluation[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "tables", "results_$(i + 132).jld"))["observed_cases"] ./ 10072
        duration_parameters_evaluation[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "tables", "results_$(i + 132).jld"))["duration_parameter"]
        susceptibility_parameters_evaluation[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "tables", "results_$(i + 132).jld"))["susceptibility_parameters"]
        temperature_parameters_evaluation[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "tables", "results_$(i + 132).jld"))["temperature_parameters"]
        immune_memory_susceptibility_levels_evaluation[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "tables", "results_$(i + 132).jld"))["immune_memory_susceptibility_levels"]
        mean_immunity_durations_evaluation[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "tables", "results_$(i + 132).jld"))["mean_immunity_durations"]
        random_infection_probabilities_evaluation[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "tables", "results_$(i + 132).jld"))["random_infection_probabilities"]
    end

    result_value = 0.0
    for i = 1:num_evaluation_runs
        par_vec = [duration_parameters_evaluation[i]]
        append!(par_vec, susceptibility_parameters_evaluation[i])
        append!(par_vec, temperature_parameters_evaluation[i])
        append!(par_vec, immune_memory_susceptibility_levels_evaluation[i])
        append!(par_vec, mean_immunity_durations_evaluation[i])
        append!(par_vec, random_infection_probabilities_evaluation[i])

        r = reshape(par_vec, 1, :)

        SSE = predict(bst, r)[1]
        
        real_SSE = 0.0
        for w = 1:size(num_infected_age_groups_viruses)[1]
            for v = 1:size(num_infected_age_groups_viruses)[2]
                for a = 1:size(num_infected_age_groups_viruses)[3]
                    real_SSE += (num_infected_age_groups_viruses[w, v, a] - incidence_arr_evaluation[i][w, v, a])^2
                end
            end
        end

        result_value += (SSE - real_SSE)^2
    end
    result_value /= num_evaluation_runs

    println(result_value)
end

main()
