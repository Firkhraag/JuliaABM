using Base.Threads
using DelimitedFiles
# using XGBoost
using Statistics
using LatinHypercubeSampling
using JLD

include("data/etiology.jl")
include("util/moving_avg.jl")

include("util/regression.jl")

function main()
    num_runs = 1000

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

    for i = 1:num_runs
        println(i)
        incidence_arr[i] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"))["observed_cases"] ./ 10072
        duration_parameters[i] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"))["duration_parameter"]
        susceptibility_parameters[i] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"))["susceptibility_parameters"]
        temperature_parameters[i] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"))["temperature_parameters"]
        immune_memory_susceptibility_levels[i] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"))["immune_memory_susceptibility_levels"]
        mean_immunity_durations[i] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"))["mean_immunity_durations"]
        random_infection_probabilities[i] = load(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"))["random_infection_probabilities"]
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

    y = zeros(Float64, num_runs)
    for i = 1:num_runs
        y[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    end

    println(minimum(y))
    println(argmin(y))
    println(maximum(y))
    println(argmax(y))

    println(mean(y))
    return

    # bst = xgboost((X, y), num_round=forest_num_rounds, max_depth=forest_max_depth, objective="reg:squarederror")
    # # println(importancereport(bst))

    # duration_parameter = 0.23703365311405514
    # susceptibility_parameters = [3.0731248200497587, 3.0315005376748694, 3.4960107319671523, 4.558457619595636, 3.9627987624113588, 3.751417011489648, 4.552998584572433]
    # temperature_parameters = [-0.8747474747474746, -0.9177827791629244, -0.051010101010101006, -0.16313131313131315, -0.003030303030303022, -0.08442528431390421, -0.35326291827502476]
    # immune_memory_susceptibility_levels = [0.8944639240038756, 0.9430303030303029, 0.9336363636363636, 0.9363636363636363, 0.8876594776594775, 0.8817572117572116, 0.946060606060606]
    # mean_immunity_durations = [357.979797979798, 326.2129504744517, 133.30517744372466, 99.91903541540344, 105.99775039968745, 148.27512119521802, 162.6804553051528]
    # random_infection_probabilities = [0.00138, 0.00077, 0.0004, 9.2e-6]

    # par_vec = [duration_parameter]
    # append!(par_vec, susceptibility_parameters)
    # append!(par_vec, temperature_parameters)
    # append!(par_vec, immune_memory_susceptibility_levels)
    # append!(par_vec, mean_immunity_durations)
    # append!(par_vec, random_infection_probabilities)

    # r = reshape(par_vec, 1, :)

    # SSE = predict(bst, r)[1]
    # println(SSE)

    # println(importancereport(bst))

    # return

    # num_evaluation_runs = 15
    # incidence_arr_evaluation = Array{Array{Float64, 3}, 1}(undef, num_evaluation_runs)
    # duration_parameters_evaluation = Array{Float64, 1}(undef, num_evaluation_runs)
    # susceptibility_parameters_evaluation = Array{Vector{Float64}, 1}(undef, num_evaluation_runs)
    # temperature_parameters_evaluation = Array{Vector{Float64}, 1}(undef, num_evaluation_runs)
    # random_infection_probabilities_evaluation = Array{Vector{Float64}, 1}(undef, num_evaluation_runs)
    # immune_memory_susceptibility_levels_evaluation = Array{Vector{Float64}, 1}(undef, num_evaluation_runs)
    # mean_immunity_durations_evaluation = Array{Vector{Float64}, 1}(undef, num_evaluation_runs)

    # for i = 1:num_evaluation_runs
    #     incidence_arr_evaluation[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "tables", "results_$(i + 132).jld"))["observed_cases"] ./ 10072
    #     duration_parameters_evaluation[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "tables", "results_$(i + 132).jld"))["duration_parameter"]
    #     susceptibility_parameters_evaluation[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "tables", "results_$(i + 132).jld"))["susceptibility_parameters"]
    #     temperature_parameters_evaluation[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "tables", "results_$(i + 132).jld"))["temperature_parameters"]
    #     immune_memory_susceptibility_levels_evaluation[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "tables", "results_$(i + 132).jld"))["immune_memory_susceptibility_levels"]
    #     mean_immunity_durations_evaluation[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "tables", "results_$(i + 132).jld"))["mean_immunity_durations"]
    #     random_infection_probabilities_evaluation[i] = load(joinpath(@__DIR__, "..", "parameters_labels", "tables", "results_$(i + 132).jld"))["random_infection_probabilities"]
    # end

    # result_value = 0.0
    # for i = 1:num_evaluation_runs
    #     par_vec = [duration_parameters_evaluation[i]]
    #     append!(par_vec, susceptibility_parameters_evaluation[i])
    #     append!(par_vec, temperature_parameters_evaluation[i])
    #     append!(par_vec, immune_memory_susceptibility_levels_evaluation[i])
    #     append!(par_vec, mean_immunity_durations_evaluation[i])
    #     append!(par_vec, random_infection_probabilities_evaluation[i])

    #     r = reshape(par_vec, 1, :)

    #     SSE = predict(bst, r)[1]
        
    #     real_SSE = 0.0
    #     for w = 1:size(num_infected_age_groups_viruses)[1]
    #         for v = 1:size(num_infected_age_groups_viruses)[2]
    #             for a = 1:size(num_infected_age_groups_viruses)[3]
    #                 real_SSE += (num_infected_age_groups_viruses[w, v, a] - incidence_arr_evaluation[i][w, v, a])^2
    #             end
    #         end
    #     end

    #     result_value += (SSE - real_SSE)^2
    # end
    # result_value /= num_evaluation_runs

    # println(result_value)




    # if with_prediction
    #     num_global_iterations = 10
    #     num_samples = 2000
    #     # num_samples = 100
    #     # num_parameters = 33
    #     num_parameters = 29
    #     @time latin_hypercube_plan, _ = LHCoptim(num_samples, num_parameters, 10)

    #     duration_parameter_default = duration_parameters[pos_min_y]
    #     susceptibility_parameters_default = susceptibility_parameters[pos_min_y]
    #     temperature_parameters_default = temperature_parameters[pos_min_y]
    #     immune_memory_susceptibility_levels_default = immune_memory_susceptibility_levels[pos_min_y]
    #     mean_immunity_durations_default = mean_immunity_durations[pos_min_y]
    #     # random_infection_probabilities_default = random_infection_probabilities[pos_min_y]

    #     # println(duration_parameter_default)
    #     # println(susceptibility_parameters_default)
    #     # println(temperature_parameters_default)
    #     # println(immune_memory_susceptibility_levels_default)
    #     # println(mean_immunity_durations_default)
    #     # println(random_infection_probabilities_default)
    #     # return

    #     mean_immunity_durations = zeros(Float64, 7)
    #     min_value = 999999.0

    #     for m = 1:num_global_iterations
    #         duration_parameter_step = duration_parameter_default
    #         susceptibility_parameters_step = copy(susceptibility_parameters_default)
    #         temperature_parameters_step = copy(temperature_parameters_default)
    #         immune_memory_susceptibility_levels_step = copy(immune_memory_susceptibility_levels_default)
    #         mean_immunity_durations_step = copy(mean_immunity_durations_default)
    #         # random_infection_probabilities_step = copy(random_infection_probabilities_default)

    #         if duration_parameter_step > 0.95
    #             duration_parameter_step = 0.95
    #         end
    #         if duration_parameter_step < 0.05
    #             duration_parameter_step = 0.05
    #         end
    #         for i = 1:7
    #             if susceptibility_parameters_step[i] < 1.1
    #                 susceptibility_parameters_step[i] = 1.1
    #             elseif susceptibility_parameters_step[i] > 7.9
    #                 susceptibility_parameters_step[i] = 7.9
    #             end

    #             if temperature_parameters_step[i] < -0.95
    #                 temperature_parameters_step[i] = -0.95
    #             elseif temperature_parameters_step[i] > -0.05
    #                 temperature_parameters_step[i] = -0.05
    #             end
        
    #             if immune_memory_susceptibility_levels_step[i] > 0.95
    #                 immune_memory_susceptibility_levels_step[i] = 0.95
    #             elseif immune_memory_susceptibility_levels_step[i] < 0.55
    #                 immune_memory_susceptibility_levels_step[i] = 0.55
    #             end
    #         end
        
    #         points = scaleLHC(latin_hypercube_plan, [
    #             # (duration_parameter_step - 0.1, duration_parameter_step + 0.1),
    #             (duration_parameter_step - 0.05, duration_parameter_step + 0.05),
    #             (susceptibility_parameters_step[1] - 0.2, susceptibility_parameters_step[1] + 0.2),
    #             (susceptibility_parameters_step[2] - 0.2, susceptibility_parameters_step[2] + 0.2),
    #             (susceptibility_parameters_step[3] - 0.2, susceptibility_parameters_step[3] + 0.2),
    #             (susceptibility_parameters_step[4] - 0.2, susceptibility_parameters_step[4] + 0.2),
    #             (susceptibility_parameters_step[5] - 0.2, susceptibility_parameters_step[5] + 0.2),
    #             (susceptibility_parameters_step[6] - 0.2, susceptibility_parameters_step[6] + 0.2),
    #             (susceptibility_parameters_step[7] - 0.2, susceptibility_parameters_step[7] + 0.2),
    #             (temperature_parameters_step[1] - 0.05, temperature_parameters_step[1] + 0.05),
    #             (temperature_parameters_step[2] - 0.05, temperature_parameters_step[2] + 0.05),
    #             (temperature_parameters_step[3] - 0.05, temperature_parameters_step[3] + 0.05),
    #             (temperature_parameters_step[4] - 0.05, temperature_parameters_step[4] + 0.05),
    #             (temperature_parameters_step[5] - 0.05, temperature_parameters_step[5] + 0.05),
    #             (temperature_parameters_step[6] - 0.05, temperature_parameters_step[6] + 0.05),
    #             (temperature_parameters_step[7] - 0.05, temperature_parameters_step[7] + 0.05),
    #             (immune_memory_susceptibility_levels_step[1] - 0.05, immune_memory_susceptibility_levels_step[1] + 0.05),
    #             (immune_memory_susceptibility_levels_step[2] - 0.05, immune_memory_susceptibility_levels_step[2] + 0.05),
    #             (immune_memory_susceptibility_levels_step[3] - 0.05, immune_memory_susceptibility_levels_step[3] + 0.05),
    #             (immune_memory_susceptibility_levels_step[4] - 0.05, immune_memory_susceptibility_levels_step[4] + 0.05),
    #             (immune_memory_susceptibility_levels_step[5] - 0.05, immune_memory_susceptibility_levels_step[5] + 0.05),
    #             (immune_memory_susceptibility_levels_step[6] - 0.05, immune_memory_susceptibility_levels_step[6] + 0.05),
    #             (immune_memory_susceptibility_levels_step[7] - 0.05, immune_memory_susceptibility_levels_step[7] + 0.05),
    #             (mean_immunity_durations_step[1] - 10.0, mean_immunity_durations_step[1] + 10.0),
    #             (mean_immunity_durations_step[2] - 10.0, mean_immunity_durations_step[2] + 10.0),
    #             (mean_immunity_durations_step[3] - 10.0, mean_immunity_durations_step[3] + 10.0),
    #             (mean_immunity_durations_step[4] - 10.0, mean_immunity_durations_step[4] + 10.0),
    #             (mean_immunity_durations_step[5] - 10.0, mean_immunity_durations_step[5] + 10.0),
    #             (mean_immunity_durations_step[6] - 10.0, mean_immunity_durations_step[6] + 10.0),
    #             (mean_immunity_durations_step[7] - 10.0, mean_immunity_durations_step[7] + 10.0),
    #             # (random_infection_probabilities_step[1] - random_infection_probabilities_step[1] * 0.1, random_infection_probabilities_step[1] + random_infection_probabilities_step[1] * 0.1),
    #             # (random_infection_probabilities_step[2] - random_infection_probabilities_step[2] * 0.1, random_infection_probabilities_step[2] + random_infection_probabilities_step[2] * 0.1),
    #             # (random_infection_probabilities_step[3] - random_infection_probabilities_step[3] * 0.1, random_infection_probabilities_step[3] + random_infection_probabilities_step[3] * 0.1),
    #             # (random_infection_probabilities_step[4] - random_infection_probabilities_step[4] * 0.1, random_infection_probabilities_step[4] + random_infection_probabilities_step[4] * 0.1),
    #         ])

    #         for i = 1:num_samples
    #             duration_parameter = points[i, 1]
    #             susceptibility_parameters = points[i, 2:8]
    #             temperature_parameters = points[i, 9:15]
    #             immune_memory_susceptibility_levels =  points[i, 16:22]
    #             # random_infection_probabilities = points[i, 30:33]

    #             for k = 1:num_viruses
    #                 mean_immunity_durations[k] = points[i, 22 + k]
    #             end

    #             par_vec = [duration_parameter]
    #             append!(par_vec, susceptibility_parameters)
    #             append!(par_vec, temperature_parameters)
    #             append!(par_vec, immune_memory_susceptibility_levels)
    #             append!(par_vec, mean_immunity_durations)
    #             # append!(par_vec, random_infection_probabilities)

    #             r = reshape(par_vec, 1, :)

    #             nMAE = predict(bst, r)[1]
    #             if nMAE < min_value
    #                 min_value = nMAE
    #                 duration_parameter_default = duration_parameter
    #                 for j = 1:num_viruses
    #                     susceptibility_parameters_default[j] = susceptibility_parameters[j]
    #                     temperature_parameters_default[j] = temperature_parameters[j]
    #                     immune_memory_susceptibility_levels_default[j] = immune_memory_susceptibility_levels[j]
    #                     mean_immunity_durations_default[j] = mean_immunity_durations[j]
    #                 end
    #                 # for j = 1:4
    #                 #     random_infection_probabilities_default[j] = random_infection_probabilities[j]
    #                 # end
    #             end
    #         end

    #         println("m = $(m), nMAE = $(min_value)")
    #     end
    #     println(min_value)
    #     println("duration_parameter = $(duration_parameter_default)")
    #     println("susceptibility_parameters = $(susceptibility_parameters_default)")
    #     println("temperature_parameters = $(temperature_parameters_default)")
    #     println("immune_memory_susceptibility_levels = $(immune_memory_susceptibility_levels_default)")
    #     println("mean_immunity_durations = $(mean_immunity_durations_default)")
    #     # println("random_infection_probabilities = $(random_infection_probabilities_default)")
    # end


end

main()
