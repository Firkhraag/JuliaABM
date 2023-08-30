using Base.Threads
using DelimitedFiles
using XGBoost
using Statistics
using LatinHypercubeSampling
using JLD

include("data/etiology.jl")
include("util/moving_avg.jl")

include("util/regression.jl")
include("main.jl")

function main()
    num_initial_runs = 1000
    num_runs = 100
    num_files = 0
    for i in readdir(joinpath(@__DIR__, "..", "surrogate", "tables", "procedure"))
        num_files += 1
    end

    num_years = 2

    forest_num_rounds = 3000
    forest_max_depth = 10
    η = 0.001

    num_parameters = 26
    num_viruses = 7

    for _ = 1:num_runs
        incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_initial_runs + num_files)
        duration_parameters = Array{Float64, 1}(undef, num_initial_runs + num_files)
        susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_initial_runs + num_files)
        temperature_parameters = Array{Vector{Float64}, 1}(undef, num_initial_runs + num_files)
        random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_initial_runs + num_files)
        # immune_memory_susceptibility_levels = Array{Vector{Float64}, 1}(undef, num_initial_runs + num_files)
        mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_initial_runs + num_files)

        for i = 1:num_initial_runs
            # println(i)
            incidence_arr[i] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"))["observed_cases"] ./ 10072
            duration_parameters[i] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"))["duration_parameter"]
            susceptibility_parameters[i] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"))["susceptibility_parameters"]
            temperature_parameters[i] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"))["temperature_parameters"]
            # immune_memory_susceptibility_levels[i] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"))["immune_memory_susceptibility_levels"]
            mean_immunity_durations[i] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"))["mean_immunity_durations"]
            random_infection_probabilities[i] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"))["random_infection_probabilities"]
        end

        for i = 1:num_files
            incidence_arr[i + num_initial_runs] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "procedure", "results_$(i).jld"))["observed_cases"] ./ 10072
            duration_parameters[i + num_initial_runs] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "procedure", "results_$(i).jld"))["duration_parameter"]
            susceptibility_parameters[i + num_initial_runs] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "procedure", "results_$(i).jld"))["susceptibility_parameters"]
            temperature_parameters[i + num_initial_runs] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "procedure", "results_$(i).jld"))["temperature_parameters"]
            # immune_memory_susceptibility_levels[i + num_initial_runs] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "procedure", "results_$(i).jld"))["immune_memory_susceptibility_levels"]
            mean_immunity_durations[i + num_initial_runs] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "procedure", "results_$(i).jld"))["mean_immunity_durations"]
            random_infection_probabilities[i + num_initial_runs] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "procedure", "results_$(i).jld"))["random_infection_probabilities"]
        end

        X = zeros(Float64, num_initial_runs + num_files, num_parameters)

        for i = 1:num_initial_runs + num_files
            X[i, 1] = duration_parameters[i]
            for k = 1:num_viruses
                X[i, 1 + k] = susceptibility_parameters[i][k]
            end
            for k = 1:num_viruses
                X[i, 1 + num_viruses + k] = temperature_parameters[i][k]
            end
            for k = 1:num_viruses
                X[i, 1 + 2 * num_viruses + k] = mean_immunity_durations[i][k]
            end
            for k = 1:4
                X[i, 1 + 3 * num_viruses + k] = random_infection_probabilities[i][k]
            end
            # for k = 1:num_viruses
            #     X[i, 1 + 4 * num_viruses + k] = immune_memory_susceptibility_levels[i][k]
            # end
        end

        etiology = get_etiology()

        infected_data_0_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n') ./ 10072
        infected_data_3_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n') ./ 10072
        infected_data_7_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n') ./ 10072
        infected_data_15_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n') ./ 10072

        infected_data_0 = infected_data_0_all[
            2:53, flu_starting_index:((flu_starting_index - flu_starting_index_immmunity_bias) + num_years)]
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

        infected_data_3 = infected_data_3_all[
            2:53, flu_starting_index:((flu_starting_index - flu_starting_index_immmunity_bias) + num_years)]
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

        infected_data_7 = infected_data_7_all[
            2:53, flu_starting_index:((flu_starting_index - flu_starting_index_immmunity_bias) + num_years)]
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

        infected_data_15 = infected_data_15_all[
            2:53, flu_starting_index:((flu_starting_index - flu_starting_index_immmunity_bias) + num_years)]
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

        y = zeros(Float64, num_initial_runs + num_files)
        for i = eachindex(y)
            y[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        end

        # println("Min nMAE: $(minimum(y))")

        bst = xgboost((X, y), num_round=forest_num_rounds, max_depth=forest_max_depth, objective="reg:squarederror", η = η, watchlist=[])
        # println(importancereport(bst))

        # println("Test")
        # for i = 1:num_files
        #     par_vec = [duration_parameters[i + num_initial_runs]]
        #     append!(par_vec, susceptibility_parameters[i + num_initial_runs])
        #     append!(par_vec, temperature_parameters[i + num_initial_runs])
        #     append!(par_vec, mean_immunity_durations[i + num_initial_runs])
        #     append!(par_vec, random_infection_probabilities[i + num_initial_runs])

        #     r = reshape(par_vec, 1, :)

        #     nMAE = predict(bst, r)[1]

        #     println("Real: $(y[i + num_initial_runs])")
        #     println("Predicted: $(nMAE)")
        # end
        # return

        num_lhs_iterations = 20
        lhs_num_steps = 2000
        nMAE_min = 999999.0
        pos_min_y = argmin(y)
        duration_parameter_default = duration_parameters[pos_min_y]
        susceptibility_parameters_default = susceptibility_parameters[pos_min_y]
        temperature_parameters_default = temperature_parameters[pos_min_y]
        mean_immunity_durations_default = mean_immunity_durations[pos_min_y]
        random_infection_probabilities_default = random_infection_probabilities[pos_min_y]

        for m = 1:num_lhs_iterations
            duration_parameter_step = duration_parameter_default
            susceptibility_parameters_step = copy(susceptibility_parameters_default)
            temperature_parameters_step = copy(temperature_parameters_default)
            mean_immunity_durations_step = copy(mean_immunity_durations_default)
            random_infection_probabilities_step = copy(random_infection_probabilities_default)

            if duration_parameter_step > 0.95
                duration_parameter_step = 0.95
            end
            if duration_parameter_step < 0.05
                duration_parameter_step = 0.05
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

                if mean_immunity_durations_step[i] < 40.0
                    mean_immunity_durations_step[i] = 40.0
                elseif mean_immunity_durations_step[i] > 355.0
                    mean_immunity_durations_step[i] = 355.0
                end
            end
            
            latin_hypercube_plan, _ = LHCoptim(lhs_num_steps, num_parameters, 10)
            points = scaleLHC(latin_hypercube_plan, [
                (duration_parameter_step - 0.05, duration_parameter_step + 0.05),
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

            for i = 1:lhs_num_steps
                duration_parameter_lhs = points[i, 1]
                susceptibility_parameters_lhs = points[i, 2:8]
                temperature_parameters_lhs = points[i, 9:15]
                mean_immunity_durations_lhs = points[i, 16:22]
                random_infection_probabilities_lhs = points[i, 23:26]
                
                par_vec = [duration_parameter_lhs]
                append!(par_vec, susceptibility_parameters_lhs)
                append!(par_vec, temperature_parameters_lhs)
                append!(par_vec, mean_immunity_durations_lhs)
                append!(par_vec, random_infection_probabilities_lhs)

                r = reshape(par_vec, 1, :)

                nMAE = predict(bst, r)[1]
                if nMAE < nMAE_min
                    nMAE_min = nMAE
                    duration_parameter_default = duration_parameter_lhs
                    for j = 1:num_viruses
                        susceptibility_parameters_default[j] = susceptibility_parameters_lhs[j]
                        temperature_parameters_default[j] = temperature_parameters_lhs[j]
                        mean_immunity_durations_default[j] = mean_immunity_durations_lhs[j]
                    end
                    for j = 1:4
                        random_infection_probabilities_default[j] = random_infection_probabilities_lhs[j]
                    end
                end
            end
        end

        println("Predicted nMAE_min: $(nMAE_min)")

        num_files += 1

        main(
            duration_parameter_default,
            susceptibility_parameters_default,
            temperature_parameters_default,
            mean_immunity_durations_default,
            random_infection_probabilities_default,
            [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
            num_files,
        )
    end
end

main()
