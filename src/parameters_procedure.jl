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

    # num_runs_1 = 220
    # num_runs_2 = 147
    # num_runs_3 = 98
    # num_runs_4 = 628
    # num_runs_5 = 9

    num_runs_1 = 219
    num_runs_2 = 147
    num_runs_3 = 85
    num_runs_4 = 400
    num_runs_5 = 0

    num_runs = num_runs_1 + num_runs_2 + num_runs_3 + num_runs_4 + num_runs_5
    num_years = 2

    # 0.06593633291168932 - 0.013 ошибка на одну симуляцию
    # forest_num_rounds = 30000
    forest_num_rounds = 15000
    forest_max_depth = 4

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

    for i = 1:num_runs_4
        incidence_arr[i + num_runs_1 + num_runs_2 + num_runs_3] = load(joinpath(@__DIR__, "..", "parameters_labels", "test", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
        duration_parameters[i + num_runs_1 + num_runs_2 + num_runs_3] = load(joinpath(@__DIR__, "..", "parameters_labels", "test", "tables", "results_$(i).jld"))["duration_parameter"]
        susceptibility_parameters[i + num_runs_1 + num_runs_2 + num_runs_3] = load(joinpath(@__DIR__, "..", "parameters_labels", "test", "tables", "results_$(i).jld"))["susceptibility_parameters"]
        temperature_parameters[i + num_runs_1 + num_runs_2 + num_runs_3] = load(joinpath(@__DIR__, "..", "parameters_labels", "test", "tables", "results_$(i).jld"))["temperature_parameters"]
        immune_memory_susceptibility_levels[i + num_runs_1 + num_runs_2 + num_runs_3] = load(joinpath(@__DIR__, "..", "parameters_labels", "test", "tables", "results_$(i).jld"))["immune_memory_susceptibility_levels"]
        mean_immunity_durations[i + num_runs_1 + num_runs_2 + num_runs_3] = load(joinpath(@__DIR__, "..", "parameters_labels", "test", "tables", "results_$(i).jld"))["mean_immunity_durations"]
        random_infection_probabilities[i + num_runs_1 + num_runs_2 + num_runs_3] = load(joinpath(@__DIR__, "..", "parameters_labels", "test", "tables", "results_$(i).jld"))["random_infection_probabilities"]
    end

    for i = 1:num_runs_5
        incidence_arr[i + num_runs_1 + num_runs_2 + num_runs_3 + num_runs_4] = load(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
        duration_parameters[i + num_runs_1 + num_runs_2 + num_runs_3 + num_runs_4] = load(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(i).jld"))["duration_parameter"]
        susceptibility_parameters[i + num_runs_1 + num_runs_2 + num_runs_3 + num_runs_4] = load(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(i).jld"))["susceptibility_parameters"]
        temperature_parameters[i + num_runs_1 + num_runs_2 + num_runs_3 + num_runs_4] = load(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(i).jld"))["temperature_parameters"]
        immune_memory_susceptibility_levels[i + num_runs_1 + num_runs_2 + num_runs_3 + num_runs_4] = load(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(i).jld"))["immune_memory_susceptibility_levels"]
        mean_immunity_durations[i + num_runs_1 + num_runs_2 + num_runs_3 + num_runs_4] = load(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(i).jld"))["mean_immunity_durations"]
        random_infection_probabilities[i + num_runs_1 + num_runs_2 + num_runs_3 + num_runs_4] = load(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(i).jld"))["random_infection_probabilities"]
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
        y[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    end

    # y = zeros(Float64, num_runs)
    # for i = 1:num_runs
    #     sum = 0.0
    #     for w = 1:size(num_infected_age_groups_viruses)[1]
    #         for v = 1:size(num_infected_age_groups_viruses)[2]
    #             for a = 1:size(num_infected_age_groups_viruses)[3]
    #                 sum += (num_infected_age_groups_viruses[w, v, a] - incidence_arr[i][w, v, a])^2
    #             end
    #         end
    #     end
    #     # sum /= size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3]
    #     y[i] = sum
    # end

    # y = zeros(Float64, num_runs)
    # for i = 1:num_runs
    #     sum = 0.0
    #     sum_data = 0.0
    #     for w = 1:size(num_infected_age_groups_viruses)[1]
    #         for v = 1:size(num_infected_age_groups_viruses)[2]
    #             for a = 1:size(num_infected_age_groups_viruses)[3]
    #                 sum += abs(num_infected_age_groups_viruses[w, v, a] - incidence_arr[i][w, v, a])
    #                 sum_data += incidence_arr[i][w, v, a]
    #             end
    #         end
    #     end
    #     sum /= sum_data
    #     # sum /= size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3]
    #     y[i] = sum
    # end

    println(minimum(y))
    println(argmin(y))
    # return
    # println(maximum(y))
    # println(argmax(y))

    pos_min_y = argmin(y)

    # println(duration_parameters[pos_min_y])
    # println(susceptibility_parameters[pos_min_y])
    # println(temperature_parameters[pos_min_y])
    # println(immune_memory_susceptibility_levels[pos_min_y])
    # println(mean_immunity_durations[pos_min_y])
    # println(random_infection_probabilities[pos_min_y])

    println("duration_parameter = $(duration_parameters[pos_min_y])")
    println("susceptibility_parameters = $(susceptibility_parameters[pos_min_y])")
    println("temperature_parameters = $(temperature_parameters[pos_min_y])")
    println("immune_memory_susceptibility_levels = $(immune_memory_susceptibility_levels[pos_min_y])")
    println("mean_immunity_durations = $(mean_immunity_durations[pos_min_y])")
    println("random_infection_probabilities = $(random_infection_probabilities[pos_min_y])")
    return


    # println(size(X))
    # println(size(y))
    # # return

    # if in3_4 && duration_parameters[pos_min_y] > 4
    #     min_v = 999999.0
    #     for i = 1:length(y)
    #         if duration_parameters[pos_min_y] < 4
    #             if y[i] < min_v
    #                 min_v = y[i]
    #                 pos_min_y = i
    #             end
    #         end
    #     end
    # end




    # sum_v = 0.0
    # for i = 1:5
    #     incidence_arr = load(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
    #     duration_parameter = load(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(i).jld"))["duration_parameter"]
    #     susceptibility_parameters = load(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(i).jld"))["susceptibility_parameters"]
    #     temperature_parameters = load(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(i).jld"))["temperature_parameters"]
    #     immune_memory_susceptibility_levels = load(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(i).jld"))["immune_memory_susceptibility_levels"]
    #     mean_immunity_durations = load(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(i).jld"))["mean_immunity_durations"]
    #     random_infection_probabilities = load(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(i).jld"))["random_infection_probabilities"]
        
    #     par_vec = [duration_parameter]
    #     append!(par_vec, susceptibility_parameters)
    #     append!(par_vec, temperature_parameters)
    #     append!(par_vec, immune_memory_susceptibility_levels)
    #     append!(par_vec, mean_immunity_durations)
    #     append!(par_vec, random_infection_probabilities)

    #     r = reshape(par_vec, 1, :)

    #     bst = xgboost((X, y), num_round=forest_num_rounds, max_depth=forest_max_depth, objective="reg:absoluteerror", η=0.0001)
    #     nMAE = predict(bst, r)[1]

    #     real_nMAE = sum(abs.(incidence_arr - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    #     sum_v += abs(nMAE - real_nMAE)
    # end
    # println(sum_v)
    # return

    bst = xgboost((X, y), num_round=forest_num_rounds, max_depth=forest_max_depth, objective="reg:absoluteerror", η=0.0001)
    if with_prediction
        num_global_iterations = 100
        num_samples = 1500
        num_parameters = 33
        @time latin_hypercube_plan, _ = LHCoptim(num_samples, num_parameters, 10)

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

        mean_immunity_durations = zeros(Float64, 7)
        min_value = 999999.0

        for m = 1:num_global_iterations
            println("Iteration: $(m)")
            duration_parameter_step = duration_parameter_default
            susceptibility_parameters_step = copy(susceptibility_parameters_default)
            temperature_parameters_step = copy(temperature_parameters_default)
            immune_memory_susceptibility_levels_step = copy(immune_memory_susceptibility_levels_default)
            mean_immunity_durations_step = copy(mean_immunity_durations_default)
            random_infection_probabilities_step = copy(random_infection_probabilities_default)

            if duration_parameter_step > 5.4
                duration_parameter_step = 5.4
            end
            if duration_parameter_step < 2.6
                duration_parameter_step = 2.6
            end
            for i = 1:7
                if susceptibility_parameters_step[i] < 1.1
                    susceptibility_parameters_step[i] = 1.1
                elseif susceptibility_parameters_step[i] > 7.9
                    susceptibility_parameters_step[i] = 7.9
                end

                if temperature_parameters_step[i] < -0.95
                    temperature_parameters_step[i] = -0.95
                elseif temperature_parameters_step[i] > -0.05
                    temperature_parameters_step[i] = -0.05
                end
        
                if immune_memory_susceptibility_levels_step[i] > 0.95
                    immune_memory_susceptibility_levels_step[i] = 0.95
                elseif immune_memory_susceptibility_levels_step[i] < 0.55
                    immune_memory_susceptibility_levels_step[i] = 0.55
                end
            end
        
            points = scaleLHC(latin_hypercube_plan, [
                (duration_parameter_step - 0.1, duration_parameter_step + 0.1),
                (susceptibility_parameters_step[1] - 0.2, susceptibility_parameters_step[1] + 0.2),
                (susceptibility_parameters_step[2] - 0.2, susceptibility_parameters_step[2] + 0.2),
                (susceptibility_parameters_step[3] - 0.2, susceptibility_parameters_step[3] + 0.2),
                (susceptibility_parameters_step[4] - 0.2, susceptibility_parameters_step[4] + 0.2),
                (susceptibility_parameters_step[5] - 0.2, susceptibility_parameters_step[5] + 0.2),
                (susceptibility_parameters_step[6] - 0.2, susceptibility_parameters_step[6] + 0.2),
                (susceptibility_parameters_step[7] - 0.2, susceptibility_parameters_step[7] + 0.2),
                (temperature_parameters_step[1] - 0.05, temperature_parameters_step[1] + 0.05),
                (temperature_parameters_step[2] - 0.05, temperature_parameters_step[2] + 0.05),
                (temperature_parameters_step[3] - 0.05, temperature_parameters_step[3] + 0.05),
                (temperature_parameters_step[4] - 0.05, temperature_parameters_step[4] + 0.05),
                (temperature_parameters_step[5] - 0.05, temperature_parameters_step[5] + 0.05),
                (temperature_parameters_step[6] - 0.05, temperature_parameters_step[6] + 0.05),
                (temperature_parameters_step[7] - 0.05, temperature_parameters_step[7] + 0.05),
                (immune_memory_susceptibility_levels_step[1] - 0.05, immune_memory_susceptibility_levels_step[1] + 0.05),
                (immune_memory_susceptibility_levels_step[2] - 0.05, immune_memory_susceptibility_levels_step[2] + 0.05),
                (immune_memory_susceptibility_levels_step[3] - 0.05, immune_memory_susceptibility_levels_step[3] + 0.05),
                (immune_memory_susceptibility_levels_step[4] - 0.05, immune_memory_susceptibility_levels_step[4] + 0.05),
                (immune_memory_susceptibility_levels_step[5] - 0.05, immune_memory_susceptibility_levels_step[5] + 0.05),
                (immune_memory_susceptibility_levels_step[6] - 0.05, immune_memory_susceptibility_levels_step[6] + 0.05),
                (immune_memory_susceptibility_levels_step[7] - 0.05, immune_memory_susceptibility_levels_step[7] + 0.05),
                (mean_immunity_durations_step[1] - 10.0, mean_immunity_durations_step[1] + 10.0),
                (mean_immunity_durations_step[2] - 10.0, mean_immunity_durations_step[2] + 10.0),
                (mean_immunity_durations_step[3] - 10.0, mean_immunity_durations_step[3] + 10.0),
                (mean_immunity_durations_step[4] - 10.0, mean_immunity_durations_step[4] + 10.0),
                (mean_immunity_durations_step[5] - 10.0, mean_immunity_durations_step[5] + 10.0),
                (mean_immunity_durations_step[6] - 10.0, mean_immunity_durations_step[6] + 10.0),
                (mean_immunity_durations_step[7] - 10.0, mean_immunity_durations_step[7] + 10.0),
                (random_infection_probabilities_step[1] - random_infection_probabilities_step[1] * 0.1, random_infection_probabilities_step[1] + random_infection_probabilities_step[1] * 0.1),
                (random_infection_probabilities_step[2] - random_infection_probabilities_step[2] * 0.1, random_infection_probabilities_step[2] + random_infection_probabilities_step[2] * 0.1),
                (random_infection_probabilities_step[3] - random_infection_probabilities_step[3] * 0.1, random_infection_probabilities_step[3] + random_infection_probabilities_step[3] * 0.1),
                (random_infection_probabilities_step[4] - random_infection_probabilities_step[4] * 0.1, random_infection_probabilities_step[4] + random_infection_probabilities_step[4] * 0.1),
            ])

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

                nMAE = predict(bst, r)[1]
                if nMAE < min_value
                    min_value = nMAE
                    duration_parameter_default = duration_parameter
                    for j = 1:num_viruses
                        susceptibility_parameters_default[j] = susceptibility_parameters[j]
                        temperature_parameters_default[j] = temperature_parameters[j]
                        immune_memory_susceptibility_levels_default[j] = immune_memory_susceptibility_levels[j]
                        mean_immunity_durations_default[j] = mean_immunity_durations[j]
                    end
                    for j = 1:4
                        random_infection_probabilities_default[j] = random_infection_probabilities[j]
                    end
                end
            end
        end
        println(min_value)
        println("duration_parameter = $(duration_parameter_default)")
        println("susceptibility_parameters = $(susceptibility_parameters_default)")
        println("temperature_parameters = $(temperature_parameters_default)")
        println("immune_memory_susceptibility_levels = $(immune_memory_susceptibility_levels_default)")
        println("mean_immunity_durations = $(mean_immunity_durations_default)")
        println("random_infection_probabilities = $(random_infection_probabilities_default)")
    end
end

@time main()
