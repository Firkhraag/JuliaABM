using DelimitedFiles
using Plots
using Statistics
using Distributions
using LaTeXStrings
using JLD

include("../util/moving_avg.jl")
include("../util/regression.jl")
include("../data/etiology.jl")
include("../global/variables.jl")

# default(legendfontsize = 15, guidefont = (22, :black), tickfont = (15, :black))
default(legendfontsize = 11, guidefont = (12, :black), tickfont = (11, :black))

const is_russian = false

function plot_infection_curves()
    num_runs = 200
    # num_runs = 151
    # num_runs = 70
    # num_runs = 10
    num_years = 3

    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_means = zeros(Float64, 52, num_runs)

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    infected_data_mean = mean(infected_data[39:45, 2:53], dims = 1)[1, :]

    # isolation_probabilities_day_1 = Array{Vector{Float64}, 1}(undef, num_runs)
    isolation_probability_day_1_1 = Array{Float64, 1}(undef, num_runs)
    isolation_probability_day_1_2 = Array{Float64, 1}(undef, num_runs)
    isolation_probability_day_1_3 = Array{Float64, 1}(undef, num_runs)
    isolation_probability_day_1_4 = Array{Float64, 1}(undef, num_runs)

    # isolation_probabilities_day_2 = Array{Vector{Float64}, 1}(undef, num_runs)
    isolation_probability_day_2_1 = Array{Float64, 1}(undef, num_runs)
    isolation_probability_day_2_2 = Array{Float64, 1}(undef, num_runs)
    isolation_probability_day_2_3 = Array{Float64, 1}(undef, num_runs)
    isolation_probability_day_2_4 = Array{Float64, 1}(undef, num_runs)

    # isolation_probabilities_day_3 = Array{Vector{Float64}, 1}(undef, num_runs)
    isolation_probability_day_3_1 = Array{Float64, 1}(undef, num_runs)
    isolation_probability_day_3_2 = Array{Float64, 1}(undef, num_runs)
    isolation_probability_day_3_3 = Array{Float64, 1}(undef, num_runs)
    isolation_probability_day_3_4 = Array{Float64, 1}(undef, num_runs)

    recovered_duration_mean = Array{Float64, 1}(undef, num_runs)
    recovered_duration_sd = Array{Float64, 1}(undef, num_runs)

    # mean_household_contact_durations = Array{Vector{Float64}, 1}(undef, num_runs)
    mean_household_contact_duration_1 = Array{Float64, 1}(undef, num_runs)
    mean_household_contact_duration_2 = Array{Float64, 1}(undef, num_runs)
    mean_household_contact_duration_3 = Array{Float64, 1}(undef, num_runs)
    mean_household_contact_duration_4 = Array{Float64, 1}(undef, num_runs)
    mean_household_contact_duration_5 = Array{Float64, 1}(undef, num_runs)

    # household_contact_duration_sds = Array{Vector{Float64}, 1}(undef, num_runs)
    household_contact_duration_sd_1 = Array{Float64, 1}(undef, num_runs)
    household_contact_duration_sd_2 = Array{Float64, 1}(undef, num_runs)
    household_contact_duration_sd_3 = Array{Float64, 1}(undef, num_runs)
    household_contact_duration_sd_4 = Array{Float64, 1}(undef, num_runs)
    household_contact_duration_sd_5 = Array{Float64, 1}(undef, num_runs)

    # other_contact_duration_shapes = Array{Vector{Float64}, 1}(undef, num_runs)
    other_contact_duration_shape_1 = Array{Float64, 1}(undef, num_runs)
    other_contact_duration_shape_2 = Array{Float64, 1}(undef, num_runs)
    other_contact_duration_shape_3 = Array{Float64, 1}(undef, num_runs)
    other_contact_duration_shape_4 = Array{Float64, 1}(undef, num_runs)
    other_contact_duration_shape_5 = Array{Float64, 1}(undef, num_runs)

    # other_contact_duration_scales = Array{Vector{Float64}, 1}(undef, num_runs)
    other_contact_duration_scale_1 = Array{Float64, 1}(undef, num_runs)
    other_contact_duration_scale_2 = Array{Float64, 1}(undef, num_runs)
    other_contact_duration_scale_3 = Array{Float64, 1}(undef, num_runs)
    other_contact_duration_scale_4 = Array{Float64, 1}(undef, num_runs)
    other_contact_duration_scale_5 = Array{Float64, 1}(undef, num_runs)

    duration_parameter = Array{Float64, 1}(undef, num_runs)

    # susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_runs)
    susceptibility_parameter_1 = Array{Float64, 1}(undef, num_runs)
    susceptibility_parameter_2 = Array{Float64, 1}(undef, num_runs)
    susceptibility_parameter_3 = Array{Float64, 1}(undef, num_runs)
    susceptibility_parameter_4 = Array{Float64, 1}(undef, num_runs)
    susceptibility_parameter_5 = Array{Float64, 1}(undef, num_runs)
    susceptibility_parameter_6 = Array{Float64, 1}(undef, num_runs)
    susceptibility_parameter_7 = Array{Float64, 1}(undef, num_runs)

    # temperature_parameters = Array{Vector{Float64}, 1}(undef, num_runs)
    temperature_parameter_1 = Array{Float64, 1}(undef, num_runs)
    temperature_parameter_2 = Array{Float64, 1}(undef, num_runs)
    temperature_parameter_3 = Array{Float64, 1}(undef, num_runs)
    temperature_parameter_4 = Array{Float64, 1}(undef, num_runs)
    temperature_parameter_5 = Array{Float64, 1}(undef, num_runs)
    temperature_parameter_6 = Array{Float64, 1}(undef, num_runs)
    temperature_parameter_7 = Array{Float64, 1}(undef, num_runs)

    # random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_runs)
    random_infection_probability_1 = Array{Float64, 1}(undef, num_runs)
    random_infection_probability_2 = Array{Float64, 1}(undef, num_runs)
    random_infection_probability_3 = Array{Float64, 1}(undef, num_runs)
    random_infection_probability_4 = Array{Float64, 1}(undef, num_runs)

    # mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_runs)
    mean_immunity_duration_1 = Array{Float64, 1}(undef, num_runs)
    mean_immunity_duration_2 = Array{Float64, 1}(undef, num_runs)
    mean_immunity_duration_3 = Array{Float64, 1}(undef, num_runs)
    mean_immunity_duration_4 = Array{Float64, 1}(undef, num_runs)
    mean_immunity_duration_5 = Array{Float64, 1}(undef, num_runs)
    mean_immunity_duration_6 = Array{Float64, 1}(undef, num_runs)
    mean_immunity_duration_7 = Array{Float64, 1}(undef, num_runs)

    # incubation_period_durations = Array{Vector{Float64}, 1}(undef, num_runs)
    incubation_period_duration_1 = Array{Float64, 1}(undef, num_runs)
    incubation_period_duration_2 = Array{Float64, 1}(undef, num_runs)
    incubation_period_duration_3 = Array{Float64, 1}(undef, num_runs)
    incubation_period_duration_4 = Array{Float64, 1}(undef, num_runs)
    incubation_period_duration_5 = Array{Float64, 1}(undef, num_runs)
    incubation_period_duration_6 = Array{Float64, 1}(undef, num_runs)
    incubation_period_duration_7 = Array{Float64, 1}(undef, num_runs)

    # incubation_period_duration_variances = Array{Vector{Float64}, 1}(undef, num_runs)
    incubation_period_duration_variance_1 = Array{Float64, 1}(undef, num_runs)
    incubation_period_duration_variance_2 = Array{Float64, 1}(undef, num_runs)
    incubation_period_duration_variance_3 = Array{Float64, 1}(undef, num_runs)
    incubation_period_duration_variance_4 = Array{Float64, 1}(undef, num_runs)
    incubation_period_duration_variance_5 = Array{Float64, 1}(undef, num_runs)
    incubation_period_duration_variance_6 = Array{Float64, 1}(undef, num_runs)
    incubation_period_duration_variance_7 = Array{Float64, 1}(undef, num_runs)

    # infection_period_durations_child = Array{Vector{Float64}, 1}(undef, num_runs)
    infection_period_duration_child_1 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_child_2 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_child_3 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_child_4 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_child_5 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_child_6 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_child_7 = Array{Float64, 1}(undef, num_runs)

    # infection_period_duration_variances_child = Array{Vector{Float64}, 1}(undef, num_runs)
    infection_period_duration_variance_child_1 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_variance_child_2 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_variance_child_3 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_variance_child_4 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_variance_child_5 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_variance_child_6 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_variance_child_7 = Array{Float64, 1}(undef, num_runs)

    # infection_period_durations_adult = Array{Vector{Float64}, 1}(undef, num_runs)
    infection_period_duration_adult_1 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_adult_2 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_adult_3 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_adult_4 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_adult_5 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_adult_6 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_adult_7 = Array{Float64, 1}(undef, num_runs)

    # infection_period_duration_variances_adult = Array{Vector{Float64}, 1}(undef, num_runs)
    infection_period_duration_variance_adult_1 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_variance_adult_2 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_variance_adult_3 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_variance_adult_4 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_variance_adult_5 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_variance_adult_6 = Array{Float64, 1}(undef, num_runs)
    infection_period_duration_variance_adult_7 = Array{Float64, 1}(undef, num_runs)

    # symptomatic_probabilities_child = Array{Vector{Float64}, 1}(undef, num_runs)
    symptomatic_probability_child_1 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_child_2 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_child_3 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_child_4 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_child_5 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_child_6 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_child_7 = Array{Float64, 1}(undef, num_runs)

    # symptomatic_probabilities_teenager = Array{Vector{Float64}, 1}(undef, num_runs)
    symptomatic_probability_teenager_1 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_teenager_2 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_teenager_3 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_teenager_4 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_teenager_5 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_teenager_6 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_teenager_7 = Array{Float64, 1}(undef, num_runs)

    # symptomatic_probabilities_adult = Array{Vector{Float64}, 1}(undef, num_runs)
    symptomatic_probability_adult_1 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_adult_2 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_adult_3 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_adult_4 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_adult_5 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_adult_6 = Array{Float64, 1}(undef, num_runs)
    symptomatic_probability_adult_7 = Array{Float64, 1}(undef, num_runs)

    # mean_viral_loads_infant = Array{Vector{Float64}, 1}(undef, num_runs)
    mean_viral_load_infant_1 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_infant_2 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_infant_3 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_infant_4 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_infant_5 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_infant_6 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_infant_7 = Array{Float64, 1}(undef, num_runs)

    # mean_viral_loads_child = Array{Vector{Float64}, 1}(undef, num_runs)
    mean_viral_load_child_1 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_child_2 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_child_3 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_child_4 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_child_5 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_child_6 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_child_7 = Array{Float64, 1}(undef, num_runs)

    # mean_viral_loads_adult = Array{Vector{Float64}, 1}(undef, num_runs)
    mean_viral_load_adult_1 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_adult_2 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_adult_3 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_adult_4 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_adult_5 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_adult_6 = Array{Float64, 1}(undef, num_runs)
    mean_viral_load_adult_7 = Array{Float64, 1}(undef, num_runs)

    for i = 1:num_runs
        println("Run: $(i)")
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end

        # isolation_probabilities_day_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_1"]
        isolation_probability_day_1_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_1"][1]
        isolation_probability_day_1_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_1"][2]
        isolation_probability_day_1_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_1"][3]
        isolation_probability_day_1_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_1"][4]
        
        # isolation_probabilities_day_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_2"]
        isolation_probability_day_2_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_2"][1]
        isolation_probability_day_2_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_2"][2]
        isolation_probability_day_2_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_2"][3]
        isolation_probability_day_2_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_2"][4]
        
        # isolation_probabilities_day_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_3"]
        isolation_probability_day_3_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_3"][1]
        isolation_probability_day_3_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_3"][2]
        isolation_probability_day_3_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_3"][3]
        isolation_probability_day_3_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["isolation_probabilities_day_3"][4]

        recovered_duration_mean[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["recovered_duration_mean"]
        recovered_duration_sd[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["recovered_duration_sd"]
        
        # mean_household_contact_durations[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_household_contact_durations"]
        mean_household_contact_duration_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_household_contact_durations"][1]
        mean_household_contact_duration_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_household_contact_durations"][2]
        mean_household_contact_duration_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_household_contact_durations"][3]
        mean_household_contact_duration_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_household_contact_durations"][4]
        mean_household_contact_duration_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_household_contact_durations"][5]
        
        # household_contact_duration_sds[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["household_contact_duration_sds"]
        household_contact_duration_sd_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["household_contact_duration_sds"][1]
        household_contact_duration_sd_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["household_contact_duration_sds"][2]
        household_contact_duration_sd_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["household_contact_duration_sds"][3]
        household_contact_duration_sd_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["household_contact_duration_sds"][4]
        household_contact_duration_sd_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["household_contact_duration_sds"][5]
        
        # other_contact_duration_shapes[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["other_contact_duration_shapes"]
        other_contact_duration_shape_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["other_contact_duration_shapes"][1]
        other_contact_duration_shape_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["other_contact_duration_shapes"][2]
        other_contact_duration_shape_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["other_contact_duration_shapes"][3]
        other_contact_duration_shape_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["other_contact_duration_shapes"][4]
        other_contact_duration_shape_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["other_contact_duration_shapes"][5]
        
        # other_contact_duration_scales[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["other_contact_duration_scales"]
        other_contact_duration_scale_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["other_contact_duration_scales"][1]
        other_contact_duration_scale_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["other_contact_duration_scales"][2]
        other_contact_duration_scale_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["other_contact_duration_scales"][3]
        other_contact_duration_scale_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["other_contact_duration_scales"][4]
        other_contact_duration_scale_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["other_contact_duration_scales"][5]
        
        duration_parameter[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["duration_parameter"]
        
        # susceptibility_parameters[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["susceptibility_parameters"]
        susceptibility_parameter_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["susceptibility_parameters"][1]
        susceptibility_parameter_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["susceptibility_parameters"][2]
        susceptibility_parameter_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["susceptibility_parameters"][3]
        susceptibility_parameter_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["susceptibility_parameters"][4]
        susceptibility_parameter_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["susceptibility_parameters"][5]
        susceptibility_parameter_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["susceptibility_parameters"][6]
        susceptibility_parameter_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["susceptibility_parameters"][7]
        
        # temperature_parameters[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["temperature_parameters"]
        temperature_parameter_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["temperature_parameters"][1]
        temperature_parameter_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["temperature_parameters"][2]
        temperature_parameter_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["temperature_parameters"][3]
        temperature_parameter_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["temperature_parameters"][4]
        temperature_parameter_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["temperature_parameters"][5]
        temperature_parameter_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["temperature_parameters"][6]
        temperature_parameter_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["temperature_parameters"][7]
        
        # random_infection_probabilities[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["random_infection_probabilities"]
        random_infection_probability_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["random_infection_probabilities"][1]
        random_infection_probability_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["random_infection_probabilities"][2]
        random_infection_probability_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["random_infection_probabilities"][3]
        random_infection_probability_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["random_infection_probabilities"][4]
        
        # mean_immunity_durations[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_immunity_durations"]
        mean_immunity_duration_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_immunity_durations"][1]
        mean_immunity_duration_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_immunity_durations"][2]
        mean_immunity_duration_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_immunity_durations"][3]
        mean_immunity_duration_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_immunity_durations"][4]
        mean_immunity_duration_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_immunity_durations"][5]
        mean_immunity_duration_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_immunity_durations"][6]
        mean_immunity_duration_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_immunity_durations"][7]
        
        # incubation_period_durations[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_durations"]
        incubation_period_duration_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_durations"][1]
        incubation_period_duration_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_durations"][2]
        incubation_period_duration_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_durations"][3]
        incubation_period_duration_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_durations"][4]
        incubation_period_duration_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_durations"][5]
        incubation_period_duration_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_durations"][6]
        incubation_period_duration_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_durations"][7]
        
        # incubation_period_duration_variances[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_duration_variances"]
        incubation_period_duration_variance_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_duration_variances"][1]
        incubation_period_duration_variance_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_duration_variances"][2]
        incubation_period_duration_variance_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_duration_variances"][3]
        incubation_period_duration_variance_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_duration_variances"][4]
        incubation_period_duration_variance_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_duration_variances"][5]
        incubation_period_duration_variance_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_duration_variances"][6]
        incubation_period_duration_variance_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["incubation_period_duration_variances"][7]
        
        # infection_period_durations_child[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_child"]
        infection_period_duration_child_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_child"][1]
        infection_period_duration_child_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_child"][2]
        infection_period_duration_child_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_child"][3]
        infection_period_duration_child_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_child"][4]
        infection_period_duration_child_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_child"][5]
        infection_period_duration_child_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_child"][6]
        infection_period_duration_child_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_child"][7]
        
        # infection_period_duration_variances_child[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_child"]
        infection_period_duration_variance_child_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_child"][1]
        infection_period_duration_variance_child_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_child"][2]
        infection_period_duration_variance_child_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_child"][3]
        infection_period_duration_variance_child_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_child"][4]
        infection_period_duration_variance_child_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_child"][5]
        infection_period_duration_variance_child_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_child"][6]
        infection_period_duration_variance_child_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_child"][7]
        
        # infection_period_durations_adult[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_adult"]
        infection_period_duration_adult_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_adult"][1]
        infection_period_duration_adult_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_adult"][2]
        infection_period_duration_adult_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_adult"][3]
        infection_period_duration_adult_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_adult"][4]
        infection_period_duration_adult_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_adult"][5]
        infection_period_duration_adult_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_adult"][6]
        infection_period_duration_adult_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_durations_adult"][7]
        
        # infection_period_duration_variances_adult[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_adult"]
        infection_period_duration_variance_adult_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_adult"][1]
        infection_period_duration_variance_adult_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_adult"][2]
        infection_period_duration_variance_adult_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_adult"][3]
        infection_period_duration_variance_adult_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_adult"][4]
        infection_period_duration_variance_adult_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_adult"][5]
        infection_period_duration_variance_adult_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_adult"][6]
        infection_period_duration_variance_adult_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["infection_period_duration_variances_adult"][7]

        # symptomatic_probabilities_child[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probability_child"]
        symptomatic_probability_child_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_child"][1]
        symptomatic_probability_child_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_child"][2]
        symptomatic_probability_child_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_child"][3]
        symptomatic_probability_child_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_child"][4]
        symptomatic_probability_child_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_child"][5]
        symptomatic_probability_child_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_child"][6]
        symptomatic_probability_child_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_child"][7]
        
        # symptomatic_probabilities_teenager[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probability_teenager"]
        symptomatic_probability_teenager_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_teenager"][1]
        symptomatic_probability_teenager_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_teenager"][2]
        symptomatic_probability_teenager_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_teenager"][3]
        symptomatic_probability_teenager_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_teenager"][4]
        symptomatic_probability_teenager_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_teenager"][5]
        symptomatic_probability_teenager_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_teenager"][6]
        symptomatic_probability_teenager_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_teenager"][7]
        
        # symptomatic_probabilities_adult[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probability_adult"]
        symptomatic_probability_adult_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_adult"][1]
        symptomatic_probability_adult_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_adult"][2]
        symptomatic_probability_adult_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_adult"][3]
        symptomatic_probability_adult_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_adult"][4]
        symptomatic_probability_adult_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_adult"][5]
        symptomatic_probability_adult_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_adult"][6]
        symptomatic_probability_adult_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["symptomatic_probabilities_adult"][7]
        
        # mean_viral_loads_infant[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_infant"]
        mean_viral_load_infant_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_infant"][1]
        mean_viral_load_infant_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_infant"][2]
        mean_viral_load_infant_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_infant"][3]
        mean_viral_load_infant_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_infant"][4]
        mean_viral_load_infant_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_infant"][5]
        mean_viral_load_infant_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_infant"][6]
        mean_viral_load_infant_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_infant"][7]
        
        # mean_viral_loads_child[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_child"]
        mean_viral_load_child_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_child"][1]
        mean_viral_load_child_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_child"][2]
        mean_viral_load_child_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_child"][3]
        mean_viral_load_child_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_child"][4]
        mean_viral_load_child_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_child"][5]
        mean_viral_load_child_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_child"][6]
        mean_viral_load_child_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_child"][7]
        
        # mean_viral_loads_adult[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_adult"]
        mean_viral_load_adult_1[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_adult"][1]
        mean_viral_load_adult_2[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_adult"][2]
        mean_viral_load_adult_3[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_adult"][3]
        mean_viral_load_adult_4[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_adult"][4]
        mean_viral_load_adult_5[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_adult"][5]
        mean_viral_load_adult_6[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_adult"][6]
        mean_viral_load_adult_7[i] = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["mean_viral_loads_adult"][7]
    end

    for i = 1:52
        for j = 1:num_runs
            for k = 1:num_years
                incidence_arr_means[i, j] += incidence_arr[j, k][i]
            end
            incidence_arr_means[i, j] /= num_years
        end
    end

    incidence_arr = Array{Matrix{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52, 4)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["observed_cases"]
        for j = 1:num_years
            incidence_arr[i, j] = sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :][(52 * (j - 1) + 1):(52 * (j - 1) + 52), :]
        end
    end

    incidence_arr_mean_age_groups = zeros(Float64, 52, 4, num_runs)
    for i = 1:52
        for k = 1:4
            for j = 1:num_runs
                for z = 1:num_years
                    incidence_arr_mean_age_groups[i, k, j] += incidence_arr[j, z][i, k]
                end
                incidence_arr_mean_age_groups[i, k, j] /= num_years
            end
        end
    end

    # General age groups
    incidence_arr = Array{Matrix{Float64}, 2}(undef, num_runs, num_years)
    viruses_mean = zeros(Float64, 52, 7)

    for i = 1:10
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
        for j = 1:num_years
            incidence_arr[i, j] = sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52), :]
        end
    end

    for i = 1:52
        for k = 1:7
            for j = 1:10
                for z = 1:num_years
                    viruses_mean[i, k] += incidence_arr[j, z][i, k]
                end
            end
            viruses_mean[i, k] /= num_runs * num_years
        end
    end

    incidence_arr = Array{Matrix{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean_viruses = zeros(Float64, 52, 7, num_runs)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["observed_cases"]
        for j = 1:num_years
            incidence_arr[i, j] = sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52), :]
        end
    end

    for i = 1:52
        for k = 1:7
            for j = 1:num_runs
                for z = 1:num_years
                    incidence_arr_mean_viruses[i, k, j] += incidence_arr[j, z][i, k]
                end
                incidence_arr_mean_viruses[i, k, j] /= num_years
            end
        end
    end

    rt_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    rt_arr_means = zeros(Float64, 365, num_runs)

    for i = 1:num_runs
        rt = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["rt"]
        for j = 1:num_years
            rt_arr[i, j] = moving_average(rt, 10)[(365 * (j - 1) + 1):(365 * (j - 1) + 365)]
        end
    end

    rt_arr_mean = zeros(Float64, 365)
    for i = 1:365
        for j = 1:num_runs
            for z = 1:num_years
                rt_arr_means[i, j] += rt_arr[j, z][i]
            end
            rt_arr_means[i, j] /= num_years
        end
    end

    ticks = range(1, stop = 52, length = 7)
    ticks_rt = range(1, stop = 365, length = 7)

    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    incidence_plot = plot(
        1:52,
        [incidence_arr_means[:, i] for i = 1:num_runs],
        lw = 1,
        xticks = (ticks, ticklabels),
        legend = false,
        grid = true,
        color = [:grey for i = 1:num_runs],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "incidence.pdf"))

    return

    # xlabel_name = "Month"
    # if is_russian
    #     xlabel_name = "Месяц"
    # end

    # ylabel_name = L"R_t"
    # if is_russian
    #     ylabel_name = "Rt"
    # end

    # rt_plot = plot(
    #     1:365,
    #     [rt_arr_means[1:365, i] for i = 1:num_runs],
    #     lw = 1,
    #     xticks = (ticks_rt, ticklabels),
    #     color = [:grey for i = 1:num_runs],
    #     legend = false,
    #     grid = true,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )
    # savefig(rt_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "rt.pdf"))

    # Max
    # y = incidence_arr_means[argmax(infected_data_mean), :]
    # Sum
    # y = sum(incidence_arr_means, dims = 1)[1, :]
    # First peak
    # y = incidence_arr_means[10, :]
    # Second peak
    y = incidence_arr_means[13, :]

    # Num params: 144
    X = cat(
        isolation_probability_day_1_1, isolation_probability_day_1_2,
        isolation_probability_day_1_3, isolation_probability_day_1_4,
        isolation_probability_day_2_1, isolation_probability_day_2_2,
        isolation_probability_day_2_3, isolation_probability_day_2_4,
        isolation_probability_day_3_1, isolation_probability_day_3_2,
        isolation_probability_day_3_3, isolation_probability_day_3_4,
        recovered_duration_mean, recovered_duration_sd,
        mean_household_contact_duration_1, mean_household_contact_duration_2,
        mean_household_contact_duration_3, mean_household_contact_duration_4,
        mean_household_contact_duration_5,
        household_contact_duration_sd_1, household_contact_duration_sd_2,
        household_contact_duration_sd_3, household_contact_duration_sd_4,
        household_contact_duration_sd_5,
        other_contact_duration_shape_1, other_contact_duration_shape_2,
        other_contact_duration_shape_3, other_contact_duration_shape_4,
        other_contact_duration_shape_5,
        other_contact_duration_scale_1, other_contact_duration_scale_2,
        other_contact_duration_scale_3, other_contact_duration_scale_4,
        other_contact_duration_scale_5,
        duration_parameter,
        susceptibility_parameter_1, susceptibility_parameter_2,
        susceptibility_parameter_3, susceptibility_parameter_4,
        susceptibility_parameter_5, susceptibility_parameter_6,
        susceptibility_parameter_7,
        temperature_parameter_1, temperature_parameter_2,
        temperature_parameter_3, temperature_parameter_4,
        temperature_parameter_5, temperature_parameter_6,
        temperature_parameter_7,
        random_infection_probability_1, random_infection_probability_2,
        random_infection_probability_3, random_infection_probability_4,
        mean_immunity_duration_1, mean_immunity_duration_2, mean_immunity_duration_3,
        mean_immunity_duration_4, mean_immunity_duration_5, mean_immunity_duration_6,
        mean_immunity_duration_7,
        incubation_period_duration_1, incubation_period_duration_2,
        incubation_period_duration_3, incubation_period_duration_4,
        incubation_period_duration_5, incubation_period_duration_6,
        incubation_period_duration_7,
        incubation_period_duration_variance_1, incubation_period_duration_variance_2,
        incubation_period_duration_variance_3, incubation_period_duration_variance_4,
        incubation_period_duration_variance_5, incubation_period_duration_variance_6,
        incubation_period_duration_variance_7,
        infection_period_duration_child_1, infection_period_duration_child_2,
        infection_period_duration_child_3, infection_period_duration_child_4,
        infection_period_duration_child_5, infection_period_duration_child_6,
        infection_period_duration_child_7,
        infection_period_duration_variance_child_1,
        infection_period_duration_variance_child_2,
        infection_period_duration_variance_child_3,
        infection_period_duration_variance_child_4,
        infection_period_duration_variance_child_5,
        infection_period_duration_variance_child_6,
        infection_period_duration_variance_child_7,
        infection_period_duration_adult_1, infection_period_duration_adult_2,
        infection_period_duration_adult_3, infection_period_duration_adult_4,
        infection_period_duration_adult_5, infection_period_duration_adult_6,
        infection_period_duration_adult_7,
        infection_period_duration_variance_adult_1,
        infection_period_duration_variance_adult_2,
        infection_period_duration_variance_adult_3,
        infection_period_duration_variance_adult_4,
        infection_period_duration_variance_adult_5,
        infection_period_duration_variance_adult_6,
        infection_period_duration_variance_adult_7,
        symptomatic_probability_child_1, symptomatic_probability_child_2,
        symptomatic_probability_child_3, symptomatic_probability_child_4,
        symptomatic_probability_child_5, symptomatic_probability_child_6,
        symptomatic_probability_child_7,
        symptomatic_probability_teenager_1, symptomatic_probability_teenager_2,
        symptomatic_probability_teenager_3, symptomatic_probability_teenager_4,
        symptomatic_probability_teenager_5, symptomatic_probability_teenager_6,
        symptomatic_probability_teenager_7,
        symptomatic_probability_adult_1, symptomatic_probability_adult_2,
        symptomatic_probability_adult_3, symptomatic_probability_adult_4,
        symptomatic_probability_adult_5, symptomatic_probability_adult_6,
        symptomatic_probability_adult_7,
        mean_viral_load_infant_1, mean_viral_load_infant_2, mean_viral_load_infant_3,
        mean_viral_load_infant_4, mean_viral_load_infant_5, mean_viral_load_infant_6,
        mean_viral_load_infant_7,
        mean_viral_load_child_1, mean_viral_load_child_2, mean_viral_load_child_3,
        mean_viral_load_child_4, mean_viral_load_child_5, mean_viral_load_child_6,
        mean_viral_load_child_7, 
        mean_viral_load_adult_1, mean_viral_load_adult_2, mean_viral_load_adult_3,
        mean_viral_load_adult_4, mean_viral_load_adult_5, mean_viral_load_adult_6,
        mean_viral_load_adult_7,
        dims = 2)
    params_arr = [
        "isolation_probability_day_1_1", "isolation_probability_day_1_2",
        "isolation_probability_day_1_3", "isolation_probability_day_1_4",
        "isolation_probability_day_2_1", "isolation_probability_day_2_2",
        "isolation_probability_day_2_3", "isolation_probability_day_2_4",
        "isolation_probability_day_3_1", "isolation_probability_day_3_2",
        "isolation_probability_day_3_3", "isolation_probability_day_3_4",
        "recovered_duration_mean", "recovered_duration_sd",
        "mean_household_contact_duration_1", "mean_household_contact_duration_2",
        "mean_household_contact_duration_3", "mean_household_contact_duration_4",
        "mean_household_contact_duration_5",
        "household_contact_duration_sd_1", "household_contact_duration_sd_2",
        "household_contact_duration_sd_3", "household_contact_duration_sd_4",
        "household_contact_duration_sd_5",
        "other_contact_duration_shape_1", "other_contact_duration_shape_2",
        "other_contact_duration_shape_3", "other_contact_duration_shape_4",
        "other_contact_duration_shape_5",
        "other_contact_duration_scale_1", "other_contact_duration_scale_2",
        "other_contact_duration_scale_3", "other_contact_duration_scale_4",
        "other_contact_duration_scale_5",
        "duration_parameter",
        "susceptibility_parameter_1", "susceptibility_parameter_2",
        "susceptibility_parameter_3", "susceptibility_parameter_4",
        "susceptibility_parameter_5", "susceptibility_parameter_6",
        "susceptibility_parameter_7",
        "temperature_parameter_1", "temperature_parameter_2",
        "temperature_parameter_3", "temperature_parameter_4",
        "temperature_parameter_5", "temperature_parameter_6",
        "temperature_parameter_7",
        "random_infection_probability_1", "random_infection_probability_2",
        "random_infection_probability_3", "random_infection_probability_4",
        "mean_immunity_duration_1", "mean_immunity_duration_2", "mean_immunity_duration_3",
        "mean_immunity_duration_4", "mean_immunity_duration_5", "mean_immunity_duration_6",
        "mean_immunity_duration_7",
        "incubation_period_duration_1", "incubation_period_duration_2",
        "incubation_period_duration_3", "incubation_period_duration_4",
        "incubation_period_duration_5", "incubation_period_duration_6",
        "incubation_period_duration_7",
        "incubation_period_duration_variance_1", "incubation_period_duration_variance_2",
        "incubation_period_duration_variance_3", "incubation_period_duration_variance_4",
        "incubation_period_duration_variance_5", "incubation_period_duration_variance_6",
        "incubation_period_duration_variance_7",
        "infection_period_duration_child_1", "infection_period_duration_child_2",
        "infection_period_duration_child_3", "infection_period_duration_child_4",
        "infection_period_duration_child_5", "infection_period_duration_child_6",
        "infection_period_duration_child_7",
        "infection_period_duration_variance_child_1",
        "infection_period_duration_variance_child_2",
        "infection_period_duration_variance_child_3",
        "infection_period_duration_variance_child_4",
        "infection_period_duration_variance_child_5",
        "infection_period_duration_variance_child_6",
        "infection_period_duration_variance_child_7",
        "infection_period_duration_adult_1", "infection_period_duration_adult_2",
        "infection_period_duration_adult_3", "infection_period_duration_adult_4",
        "infection_period_duration_adult_5", "infection_period_duration_adult_6",
        "infection_period_duration_adult_7",
        "infection_period_duration_variance_adult_1",
        "infection_period_duration_variance_adult_2",
        "infection_period_duration_variance_adult_3",
        "infection_period_duration_variance_adult_4",
        "infection_period_duration_variance_adult_5",
        "infection_period_duration_variance_adult_6",
        "infection_period_duration_variance_adult_7",
        "symptomatic_probability_child_1", "symptomatic_probability_child_2",
        "symptomatic_probability_child_3", "symptomatic_probability_child_4",
        "symptomatic_probability_child_5", "symptomatic_probability_child_6",
        "symptomatic_probability_child_7",
        "symptomatic_probability_teenager_1", "symptomatic_probability_teenager_2",
        "symptomatic_probability_teenager_3", "symptomatic_probability_teenager_4",
        "symptomatic_probability_teenager_5", "symptomatic_probability_teenager_6",
        "symptomatic_probability_teenager_7",
        "symptomatic_probability_adult_1", "symptomatic_probability_adult_2",
        "symptomatic_probability_adult_3", "symptomatic_probability_adult_4",
        "symptomatic_probability_adult_5", "symptomatic_probability_adult_6",
        "symptomatic_probability_adult_7",
        "mean_viral_load_infant_1", "mean_viral_load_infant_2", "mean_viral_load_infant_3",
        "mean_viral_load_infant_4", "mean_viral_load_infant_5", "mean_viral_load_infant_6",
        "mean_viral_load_infant_7",
        "mean_viral_load_child_1", "mean_viral_load_child_2", "mean_viral_load_child_3",
        "mean_viral_load_child_4", "mean_viral_load_child_5", "mean_viral_load_child_6",
        "mean_viral_load_child_7", 
        "mean_viral_load_adult_1", "mean_viral_load_adult_2", "mean_viral_load_adult_3",
        "mean_viral_load_adult_4", "mean_viral_load_adult_5", "mean_viral_load_adult_6",
        "mean_viral_load_adult_7",
    ]

    # First peak
    # ["duration_parameter", "susceptibility_parameter_3", "susceptibility_parameter_4", "other_contact_duration_shape_2", "susceptibility_parameter_6", "susceptibility_parameter_5", "other_contact_duration_scale_4", "other_contact_duration_shape_4", "mean_viral_load_adult_3", "other_contact_duration_scale_2", "isolation_probability_day_2_4", "symptomatic_probability_adult_6", "mean_household_contact_duration_4", "infection_period_duration_adult_5", "isolation_probability_day_2_1", "temperature_parameter_3", "symptomatic_probability_adult_3", "mean_viral_load_child_6", "mean_viral_load_adult_6", "incubation_period_duration_5", "mean_viral_load_adult_1", "mean_viral_load_child_3", "mean_viral_load_adult_5", "mean_immunity_duration_6", "recovered_duration_mean", "mean_viral_load_infant_4", "mean_immunity_duration_5", "infection_period_duration_variance_child_6", "infection_period_duration_child_5", "mean_viral_load_child_4", "mean_household_contact_duration_5", "infection_period_duration_adult_3", "symptomatic_probability_teenager_3", "symptomatic_probability_child_2", "other_contact_duration_shape_1", "mean_viral_load_infant_2", "mean_immunity_duration_1", "temperature_parameter_4", "household_contact_duration_sd_3", "infection_period_duration_variance_adult_3", "temperature_parameter_5", "incubation_period_duration_3", "isolation_probability_day_3_1"]

    # Second peak
    # ["duration_parameter", "susceptibility_parameter_3", "susceptibility_parameter_4", "other_contact_duration_shape_2", "recovered_duration_mean", "mean_viral_load_adult_3", "susceptibility_parameter_6", "other_contact_duration_shape_4", "mean_viral_load_child_3", "infection_period_duration_adult_3", "other_contact_duration_scale_4", "isolation_probability_day_2_4", "mean_viral_load_infant_6", "mean_household_contact_duration_4", "symptomatic_probability_adult_6", "mean_viral_load_infant_4", "isolation_probability_day_3_4", "symptomatic_probability_adult_1", "infection_period_duration_adult_5", "incubation_period_duration_5", "symptomatic_probability_child_7", "symptomatic_probability_teenager_2", "mean_viral_load_child_7", "temperature_parameter_1", "other_contact_duration_scale_2", "mean_viral_load_adult_4", "infection_period_duration_adult_4", "symptomatic_probability_teenager_3", "symptomatic_probability_child_2", "other_contact_duration_shape_3", "symptomatic_probability_child_4", "infection_period_duration_child_3", "mean_immunity_duration_4", "infection_period_duration_child_5"]

    # Max peak
    # ["susceptibility_parameter_1", "duration_parameter", "mean_viral_load_adult_1", "susceptibility_parameter_4", "susceptibility_parameter_2", "infection_period_duration_adult_1", "symptomatic_probability_adult_1", "other_contact_duration_shape_4", "mean_viral_load_adult_4", "mean_household_contact_duration_4", "other_contact_duration_scale_1", "isolation_probability_day_1_3", "mean_household_contact_duration_5", "mean_viral_load_child_1", "other_contact_duration_shape_2", "infection_period_duration_adult_4", "other_contact_duration_shape_5", "symptomatic_probability_child_1", "recovered_duration_mean", "other_contact_duration_scale_4", "infection_period_duration_child_1", "household_contact_duration_sd_5", "mean_viral_load_adult_7", "susceptibility_parameter_7", "symptomatic_probability_child_5"]

    # Num of infected
    # ["duration_parameter", "susceptibility_parameter_1", "other_contact_duration_scale_4", "susceptibility_parameter_4", "other_contact_duration_shape_4", "mean_viral_load_adult_1", "susceptibility_parameter_3", "other_contact_duration_shape_2", "susceptibility_parameter_2", "recovered_duration_mean", "symptomatic_probability_adult_1", "susceptibility_parameter_6", "mean_viral_load_adult_3", "other_contact_duration_scale_2", "mean_viral_load_child_3", "infection_period_duration_adult_1", "mean_household_contact_duration_4", "infection_period_duration_adult_3", "isolation_probability_day_2_4", "mean_viral_load_infant_6", "symptomatic_probability_teenager_3", "temperature_parameter_1", "incubation_period_duration_5", "infection_period_duration_variance_adult_4", "infection_period_duration_adult_2", "mean_immunity_duration_5", "symptomatic_probability_child_5", "mean_viral_load_adult_2", "infection_period_duration_child_1", "infection_period_duration_adult_4", "infection_period_duration_adult_7", "isolation_probability_day_3_4", "mean_viral_load_child_1", "symptomatic_probability_adult_6", "symptomatic_probability_adult_3", "other_contact_duration_shape_1", "mean_viral_load_adult_4", "infection_period_duration_variance_child_6", "infection_period_duration_variance_adult_3", "symptomatic_probability_teenager_1", "mean_viral_load_child_2", "mean_viral_load_adult_6", "other_contact_duration_scale_1", "isolation_probability_day_1_4", "isolation_probability_day_1_3", "isolation_probability_day_2_2", "household_contact_duration_sd_5", "mean_immunity_duration_4", "mean_immunity_duration_1", "infection_period_duration_variance_adult_1", "mean_viral_load_child_6", "temperature_parameter_4", "symptomatic_probability_teenager_2", "isolation_probability_day_3_3", "other_contact_duration_scale_3", "symptomatic_probability_teenager_5"]

    @time param_ids = stepwise_regression(X, y)
    println(params_arr[param_ids])

    return


























    peak_weeks = [10, 19, 28, 34, 39]
    num_best_vars = 5
    max_corr_values = [zeros(Float64, num_best_vars), zeros(Float64, num_best_vars), zeros(Float64, num_best_vars), zeros(Float64, num_best_vars), zeros(Float64, num_best_vars)]
    max_corr_names = [["" for _ = 1:num_best_vars], ["" for _ = 1:num_best_vars], ["" for _ = 1:num_best_vars], ["" for _ = 1:num_best_vars], ["" for _ = 1:num_best_vars]]
    max_corr_value_viruses = [zeros(Float64, num_best_vars), zeros(Float64, num_best_vars), zeros(Float64, num_best_vars), zeros(Float64, num_best_vars), zeros(Float64, num_best_vars), zeros(Float64, num_best_vars), zeros(Float64, num_best_vars)]
    max_corr_name_viruses = [["" for _ = 1:num_best_vars], ["" for _ = 1:num_best_vars], ["" for _ = 1:num_best_vars], ["" for _ = 1:num_best_vars], ["" for _ = 1:num_best_vars], ["" for _ = 1:num_best_vars], ["" for _ = 1:num_best_vars]]
    
    open(joinpath(@__DIR__, "..", "..", "sensitivity", "output.txt"), "w") do io
        corr = 0.0
        corr_age_groups = [0.0 for _ = 1:4]
        corr_viruses = [0.0 for _ = 1:7]

        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_1_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Isolation_probability_day_1_1"
                    break
                end
            end
            # println(io, "Isolation_probability_day_1_1, peak $(k): $(corr)")
        end
        # println(argmax(viruses_mean[:, 1]))
        # println(incidence_arr_mean_viruses[argmax(viruses_mean[:, 1]), 1, :])
        # println(cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, 1]), 1, :], isolation_probability_day_1_1))
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], isolation_probability_day_1_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Isolation_probability_day_1_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_1_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Isolation_probability_day_1_2"
                    break
                end
            end
            # println(io, "Isolation_probability_day_1_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], isolation_probability_day_1_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Isolation_probability_day_1_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_1_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Isolation_probability_day_1_3"
                    break
                end
            end
            # println(io, "Isolation_probability_day_1_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], isolation_probability_day_1_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Isolation_probability_day_1_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_1_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Isolation_probability_day_1_4"
                    break
                end
            end
            # println(io, "Isolation_probability_day_1_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], isolation_probability_day_1_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Isolation_probability_day_1_4"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_2_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Isolation_probability_day_2_1"
                    break
                end
            end
            # println(io, "Isolation_probability_day_2_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], isolation_probability_day_2_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Isolation_probability_day_2_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_2_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Isolation_probability_day_2_2"
                    break
                end
            end
            # println(io, "Isolation_probability_day_2_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], isolation_probability_day_2_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Isolation_probability_day_2_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_2_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Isolation_probability_day_2_3"
                    break
                end
            end
            # println(io, "Isolation_probability_day_2_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], isolation_probability_day_2_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Isolation_probability_day_2_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_2_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Isolation_probability_day_2_4"
                    break
                end
            end
            # println(io, "Isolation_probability_day_2_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], isolation_probability_day_2_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Isolation_probability_day_2_4"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_3_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Isolation_probability_day_3_1"
                    break
                end
            end
            # println(io, "Isolation_probability_day_3_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], isolation_probability_day_3_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Isolation_probability_day_3_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_3_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Isolation_probability_day_3_2"
                    break
                end
            end
            # println(io, "Isolation_probability_day_3_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], isolation_probability_day_3_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Isolation_probability_day_3_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_3_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Isolation_probability_day_3_3"
                    break
                end
            end
            # println(io, "Isolation_probability_day_3_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], isolation_probability_day_3_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Isolation_probability_day_3_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_3_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Isolation_probability_day_3_4"
                    break
                end
            end
            # println(io, "Isolation_probability_day_3_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], isolation_probability_day_3_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Isolation_probability_day_3_4"
                    break
                end
            end
        end
        # println(io, "")
        

        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], recovered_duration_mean)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Recovered_duration_mean"
                    break
                end
            end
            # println(io, "Recovered_duration_mean, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], recovered_duration_mean)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Recovered_duration_mean"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], recovered_duration_sd)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Recovered_duration_sd"
                    break
                end
            end
            # println(io, "Recovered_duration_sd, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], recovered_duration_sd)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Recovered_duration_sd"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_household_contact_duration_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_household_contact_duration_1"
                    break
                end
            end
            # println(io, "Mean_household_contact_duration_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_household_contact_duration_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_household_contact_duration_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_household_contact_duration_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_household_contact_duration_2"
                    break
                end
            end
            # println(io, "Mean_household_contact_duration_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_household_contact_duration_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_household_contact_duration_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_household_contact_duration_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_household_contact_duration_3"
                    break
                end
            end
            # println(io, "Mean_household_contact_duration_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_household_contact_duration_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_household_contact_duration_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_household_contact_duration_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_household_contact_duration_4"
                    break
                end
            end
            # println(io, "Mean_household_contact_duration_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_household_contact_duration_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_household_contact_duration_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_household_contact_duration_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_household_contact_duration_5"
                    break
                end
            end
            # println(io, "Mean_household_contact_duration_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_household_contact_duration_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_household_contact_duration_5"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], household_contact_duration_sd_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Household_contact_duration_sd_1"
                    break
                end
            end
            # println(io, "Household_contact_duration_sd_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], household_contact_duration_sd_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Household_contact_duration_sd_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], household_contact_duration_sd_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Household_contact_duration_sd_2"
                    break
                end
            end
            # println(io, "Household_contact_duration_sd_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], household_contact_duration_sd_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Household_contact_duration_sd_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], household_contact_duration_sd_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Household_contact_duration_sd_3"
                    break
                end
            end
            # println(io, "Household_contact_duration_sd_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], household_contact_duration_sd_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Household_contact_duration_sd_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], household_contact_duration_sd_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Household_contact_duration_sd_4"
                    break
                end
            end
            # println(io, "Household_contact_duration_sd_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], household_contact_duration_sd_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Household_contact_duration_sd_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], household_contact_duration_sd_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Household_contact_duration_sd_5"
                    break
                end
            end
            # println(io, "Household_contact_duration_sd_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], household_contact_duration_sd_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Household_contact_duration_sd_5"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], other_contact_duration_shape_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Other_contact_duration_shape_1"
                    break
                end
            end
            # println(io, "Other_contact_duration_shape_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], other_contact_duration_shape_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Other_contact_duration_shape_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], other_contact_duration_shape_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Other_contact_duration_shape_2"
                    break
                end
            end
            # println(io, "Other_contact_duration_shape_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], other_contact_duration_shape_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Other_contact_duration_shape_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], other_contact_duration_shape_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Other_contact_duration_shape_3"
                    break
                end
            end
            # println(io, "Other_contact_duration_shape_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], other_contact_duration_shape_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Other_contact_duration_shape_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], other_contact_duration_shape_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Other_contact_duration_shape_4"
                    break
                end
            end
            # println(io, "Other_contact_duration_shape_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], other_contact_duration_shape_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Other_contact_duration_shape_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], other_contact_duration_shape_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Other_contact_duration_shape_5"
                    break
                end
            end
            # println(io, "Other_contact_duration_shape_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], other_contact_duration_shape_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Other_contact_duration_shape_5"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], other_contact_duration_scale_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Other_contact_duration_scale_1"
                    break
                end
            end
            # println(io, "Other_contact_duration_scale_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], other_contact_duration_scale_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Other_contact_duration_scale_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], other_contact_duration_scale_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Other_contact_duration_scale_2"
                    break
                end
            end
            # println(io, "Other_contact_duration_scale_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], other_contact_duration_scale_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Other_contact_duration_scale_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], other_contact_duration_scale_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Other_contact_duration_scale_3"
                    break
                end
            end
            # println(io, "Other_contact_duration_scale_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], other_contact_duration_scale_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Other_contact_duration_scale_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], other_contact_duration_scale_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Other_contact_duration_scale_4"
                    break
                end
            end
            # println(io, "Other_contact_duration_scale_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], other_contact_duration_scale_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Other_contact_duration_scale_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], other_contact_duration_scale_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Other_contact_duration_scale_5"
                    break
                end
            end
            # println(io, "Other_contact_duration_scale_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], other_contact_duration_scale_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Other_contact_duration_scale_5"
                    break
                end
            end
        end
        # println(io, "")

        
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], duration_parameter)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Duration_parameter"
                    break
                end
            end
            # println(io, "Duration_parameter, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], duration_parameter)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Duration_parameter"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], susceptibility_parameter_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Susceptibility_parameter_1"
                    break
                end
            end
            # println(io, "Susceptibility_parameter_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], susceptibility_parameter_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Susceptibility_parameter_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], susceptibility_parameter_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Susceptibility_parameter_2"
                    break
                end
            end
            # println(io, "Susceptibility_parameter_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], susceptibility_parameter_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Susceptibility_parameter_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], susceptibility_parameter_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Susceptibility_parameter_3"
                    break
                end
            end
            # println(io, "Susceptibility_parameter_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], susceptibility_parameter_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Susceptibility_parameter_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], susceptibility_parameter_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Susceptibility_parameter_4"
                    break
                end
            end
            # println(io, "Susceptibility_parameter_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], susceptibility_parameter_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Susceptibility_parameter_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], susceptibility_parameter_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Susceptibility_parameter_5"
                    break
                end
            end
            # println(io, "Susceptibility_parameter_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], susceptibility_parameter_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Susceptibility_parameter_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], susceptibility_parameter_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Susceptibility_parameter_6"
                    break
                end
            end
            # println(io, "Susceptibility_parameter_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], susceptibility_parameter_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Susceptibility_parameter_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], susceptibility_parameter_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Susceptibility_parameter_7"
                    break
                end
            end
            # println(io, "Susceptibility_parameter_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], susceptibility_parameter_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Susceptibility_parameter_7"
                    break
                end
            end
        end
        # println(io, "")

        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], temperature_parameter_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Temperature_parameter_1"
                    break
                end
            end
            # println(io, "Temperature_parameter_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], temperature_parameter_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Temperature_parameter_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], temperature_parameter_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Temperature_parameter_2"
                    break
                end
            end
            # println(io, "Temperature_parameter_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], temperature_parameter_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Temperature_parameter_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], temperature_parameter_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Temperature_parameter_3"
                    break
                end
            end
            # println(io, "Temperature_parameter_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], temperature_parameter_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Temperature_parameter_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], temperature_parameter_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Temperature_parameter_4"
                    break
                end
            end
            # println(io, "Temperature_parameter_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], temperature_parameter_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Temperature_parameter_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], temperature_parameter_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Temperature_parameter_5"
                    break
                end
            end
            # println(io, "Temperature_parameter_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], temperature_parameter_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Temperature_parameter_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], temperature_parameter_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Temperature_parameter_6"
                    break
                end
            end
            # println(io, "Temperature_parameter_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], temperature_parameter_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Temperature_parameter_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], temperature_parameter_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Temperature_parameter_7"
                    break
                end
            end
            # println(io, "Temperature_parameter_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], temperature_parameter_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Temperature_parameter_7"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], random_infection_probability_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Random_infection_probability_1"
                    break
                end
            end
            # println(io, "Random_infection_probability_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], random_infection_probability_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Random_infection_probability_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], random_infection_probability_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Random_infection_probability_2"
                    break
                end
            end
            # println(io, "Random_infection_probability_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], random_infection_probability_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Random_infection_probability_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], random_infection_probability_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Random_infection_probability_3"
                    break
                end
            end
            # println(io, "Random_infection_probability_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], random_infection_probability_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Random_infection_probability_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], random_infection_probability_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Random_infection_probability_4"
                    break
                end
            end
            # println(io, "Random_infection_probability_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], random_infection_probability_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Random_infection_probability_4"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_immunity_duration_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_immunity_duration_1"
                    break
                end
            end
            # println(io, "Mean_immunity_duration_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_immunity_duration_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_immunity_duration_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_immunity_duration_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_immunity_duration_2"
                    break
                end
            end
            # println(io, "Mean_immunity_duration_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_immunity_duration_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_immunity_duration_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_immunity_duration_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_immunity_duration_3"
                    break
                end
            end
            # println(io, "Mean_immunity_duration_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_immunity_duration_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_immunity_duration_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_immunity_duration_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_immunity_duration_4"
                    break
                end
            end
            # println(io, "Mean_immunity_duration_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_immunity_duration_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_immunity_duration_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_immunity_duration_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_immunity_duration_5"
                    break
                end
            end
            # println(io, "Mean_immunity_duration_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_immunity_duration_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_immunity_duration_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_immunity_duration_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_immunity_duration_6"
                    break
                end
            end
            # println(io, "Mean_immunity_duration_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_immunity_duration_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_immunity_duration_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_immunity_duration_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_immunity_duration_7"
                    break
                end
            end
            # println(io, "Mean_immunity_duration_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_immunity_duration_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_immunity_duration_7"
                    break
                end
            end
        end
        # println(io, "")

        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Incubation_period_duration_1"
                    break
                end
            end
            # println(io, "Incubation_period_duration_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], incubation_period_duration_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Incubation_period_duration_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Incubation_period_duration_2"
                    break
                end
            end
            # println(io, "Incubation_period_duration_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], incubation_period_duration_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Incubation_period_duration_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Incubation_period_duration_3"
                    break
                end
            end
            # println(io, "Incubation_period_duration_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], incubation_period_duration_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Incubation_period_duration_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Incubation_period_duration_4"
                    break
                end
            end
            # println(io, "Incubation_period_duration_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], incubation_period_duration_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Incubation_period_duration_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Incubation_period_duration_5"
                    break
                end
            end
            # println(io, "Incubation_period_duration_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], incubation_period_duration_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Incubation_period_duration_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Incubation_period_duration_6"
                    break
                end
            end
            # println(io, "Incubation_period_duration_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], incubation_period_duration_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Incubation_period_duration_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Incubation_period_duration_7"
                    break
                end
            end
            # println(io, "Incubation_period_duration_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], incubation_period_duration_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Incubation_period_duration_7"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_variance_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Incubation_period_duration_variance_1"
                    break
                end
            end
            # println(io, "Incubation_period_duration_variance_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], incubation_period_duration_variance_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Incubation_period_duration_variance_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_variance_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Incubation_period_duration_variance_2"
                    break
                end
            end
            # println(io, "Incubation_period_duration_variance_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], incubation_period_duration_variance_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Incubation_period_duration_variance_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_variance_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Incubation_period_duration_variance_3"
                    break
                end
            end
            # println(io, "Incubation_period_duration_variance_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], incubation_period_duration_variance_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Incubation_period_duration_variance_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_variance_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Incubation_period_duration_variance_4"
                    break
                end
            end
            # println(io, "Incubation_period_duration_variance_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], incubation_period_duration_variance_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Incubation_period_duration_variance_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_variance_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Incubation_period_duration_variance_5"
                    break
                end
            end
            # println(io, "Incubation_period_duration_variance_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], incubation_period_duration_variance_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Incubation_period_duration_variance_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_variance_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Incubation_period_duration_variance_6"
                    break
                end
            end
            # println(io, "Incubation_period_duration_variance_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], incubation_period_duration_variance_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Incubation_period_duration_variance_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_variance_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Incubation_period_duration_variance_7"
                    break
                end
            end
            # println(io, "Incubation_period_duration_variance_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], incubation_period_duration_variance_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Incubation_period_duration_variance_7"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_child_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_child_1"
                    break
                end
            end
            # println(io, "Infection_period_duration_child_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_child_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_child_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_child_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_child_2"
                    break
                end
            end
            # println(io, "Infection_period_duration_child_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_child_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_child_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_child_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_child_3"
                    break
                end
            end
            # println(io, "Infection_period_duration_child_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_child_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_child_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_child_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_child_4"
                    break
                end
            end
            # println(io, "Infection_period_duration_child_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_child_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_child_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_child_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_child_5"
                    break
                end
            end
            # println(io, "Infection_period_duration_child_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_child_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_child_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_child_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_child_6"
                    break
                end
            end
            # println(io, "Infection_period_duration_child_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_child_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_child_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_child_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_child_7"
                    break
                end
            end
            # println(io, "Infection_period_duration_child_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_child_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_child_7"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_child_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_variance_child_1"
                    break
                end
            end
            # println(io, "Infection_period_duration_variance_child_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_variance_child_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_variance_child_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_child_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_variance_child_2"
                    break
                end
            end
            # println(io, "Infection_period_duration_variance_child_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_variance_child_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_variance_child_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_child_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_variance_child_3"
                    break
                end
            end
            # println(io, "Infection_period_duration_variance_child_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_variance_child_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_variance_child_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_child_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_variance_child_4"
                    break
                end
            end
            # println(io, "Infection_period_duration_variance_child_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_variance_child_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_variance_child_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_child_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_variance_child_5"
                    break
                end
            end
            # println(io, "Infection_period_duration_variance_child_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_variance_child_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_variance_child_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_child_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_variance_child_6"
                    break
                end
            end
            # println(io, "Infection_period_duration_variance_child_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_variance_child_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_variance_child_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_child_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_variance_child_7"
                    break
                end
            end
            # println(io, "Infection_period_duration_variance_child_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_variance_child_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_variance_child_7"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_adult_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_adult_1"
                    break
                end
            end
            # println(io, "Infection_period_duration_adult_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_adult_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_adult_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_adult_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_adult_2"
                    break
                end
            end
            # println(io, "Infection_period_duration_adult_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_adult_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_adult_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_adult_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_adult_3"
                    break
                end
            end
            # println(io, "Infection_period_duration_adult_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_adult_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_adult_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_adult_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_adult_4"
                    break
                end
            end
            # println(io, "Infection_period_duration_adult_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_adult_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_adult_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_adult_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_adult_5"
                    break
                end
            end
            # println(io, "Infection_period_duration_adult_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_adult_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_adult_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_adult_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_adult_6"
                    break
                end
            end
            # println(io, "Infection_period_duration_adult_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_adult_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_adult_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_adult_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_adult_7"
                    break
                end
            end
            # println(io, "Infection_period_duration_adult_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_adult_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_adult_7"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_adult_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_variance_adult_1"
                    break
                end
            end
            # println(io, "Infection_period_duration_variance_adult_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_variance_adult_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_variance_adult_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_adult_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_variance_adult_2"
                    break
                end
            end
            # println(io, "Infection_period_duration_variance_adult_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_variance_adult_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_variance_adult_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_adult_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_variance_adult_3"
                    break
                end
            end
            # println(io, "Infection_period_duration_variance_adult_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_variance_adult_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_variance_adult_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_adult_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_variance_adult_4"
                    break
                end
            end
            # println(io, "Infection_period_duration_variance_adult_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_variance_adult_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_variance_adult_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_adult_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_variance_adult_5"
                    break
                end
            end
            # println(io, "Infection_period_duration_variance_adult_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_variance_adult_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_variance_adult_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_adult_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_variance_adult_6"
                    break
                end
            end
            # println(io, "Infection_period_duration_variance_adult_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_variance_adult_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_variance_adult_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_adult_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Infection_period_duration_variance_adult_7"
                    break
                end
            end
            # println(io, "Infection_period_duration_variance_adult_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], infection_period_duration_variance_adult_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Infection_period_duration_variance_adult_7"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_child_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_child_1"
                    break
                end
            end
            # println(io, "Symptomatic_probability_child_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_child_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_child_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_child_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_child_2"
                    break
                end
            end
            # println(io, "Symptomatic_probability_child_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_child_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_child_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_child_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_child_3"
                    break
                end
            end
            # println(io, "Symptomatic_probability_child_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_child_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_child_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_child_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_child_4"
                    break
                end
            end
            # println(io, "Symptomatic_probability_child_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_child_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_child_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_child_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_child_5"
                    break
                end
            end
            # println(io, "Symptomatic_probability_child_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_child_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_child_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_child_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_child_6"
                    break
                end
            end
            # println(io, "Symptomatic_probability_child_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_child_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_child_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_child_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_child_7"
                    break
                end
            end
            # println(io, "Symptomatic_probability_child_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_child_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_child_7"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_teenager_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_teenager_1"
                    break
                end
            end
            # println(io, "Symptomatic_probability_teenager_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_teenager_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_teenager_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_teenager_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_teenager_2"
                    break
                end
            end
            # println(io, "Symptomatic_probability_teenager_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_teenager_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_teenager_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_teenager_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_teenager_3"
                    break
                end
            end
            # println(io, "Symptomatic_probability_teenager_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_teenager_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_teenager_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_teenager_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_teenager_4"
                    break
                end
            end
            # println(io, "Symptomatic_probability_teenager_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_teenager_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_teenager_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_teenager_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_teenager_5"
                    break
                end
            end
            # println(io, "Symptomatic_probability_teenager_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_teenager_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_teenager_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_teenager_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_teenager_6"
                    break
                end
            end
            # println(io, "Symptomatic_probability_teenager_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_teenager_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_teenager_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_teenager_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_teenager_7"
                    break
                end
            end
            # println(io, "Symptomatic_probability_teenager_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_teenager_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_teenager_7"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_adult_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_adult_1"
                    break
                end
            end
            # println(io, "Symptomatic_probability_adult_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_adult_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_adult_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_adult_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_adult_2"
                    break
                end
            end
            # println(io, "Symptomatic_probability_adult_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_adult_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_adult_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_adult_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_adult_3"
                    break
                end
            end
            # println(io, "Symptomatic_probability_adult_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_adult_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_adult_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_adult_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_adult_4"
                    break
                end
            end
            # println(io, "Symptomatic_probability_adult_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_adult_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_adult_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_adult_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_adult_5"
                    break
                end
            end
            # println(io, "Symptomatic_probability_adult_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_adult_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_adult_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_adult_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_adult_6"
                    break
                end
            end
            # println(io, "Symptomatic_probability_adult_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_adult_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_adult_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_adult_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Symptomatic_probability_adult_7"
                    break
                end
            end
            # println(io, "Symptomatic_probability_adult_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], symptomatic_probability_adult_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Symptomatic_probability_adult_7"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_infant_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_infant_1"
                    break
                end
            end
            # println(io, "Mean_viral_load_infant_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_infant_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_infant_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_infant_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_infant_2"
                    break
                end
            end
            # println(io, "Mean_viral_load_infant_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_infant_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_infant_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_infant_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_infant_3"
                    break
                end
            end
            # println(io, "Mean_viral_load_infant_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_infant_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_infant_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_infant_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_infant_4"
                    break
                end
            end
            # println(io, "Mean_viral_load_infant_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_infant_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_infant_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_infant_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_infant_5"
                    break
                end
            end
            # println(io, "Mean_viral_load_infant_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_infant_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_infant_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_infant_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_infant_6"
                    break
                end
            end
            # println(io, "Mean_viral_load_infant_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_infant_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_infant_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_infant_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_infant_7"
                    break
                end
            end
            # println(io, "Mean_viral_load_infant_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_infant_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_infant_7"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_child_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_child_1"
                    break
                end
            end
            # println(io, "Mean_viral_load_child_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_child_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_child_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_child_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_child_2"
                    break
                end
            end
            # println(io, "Mean_viral_load_child_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_child_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_child_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_child_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_child_3"
                    break
                end
            end
            # println(io, "Mean_viral_load_child_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_child_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_child_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_child_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_child_4"
                    break
                end
            end
            # println(io, "Mean_viral_load_child_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_child_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_child_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_child_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_child_5"
                    break
                end
            end
            # println(io, "Mean_viral_load_child_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_child_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_child_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_child_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_child_6"
                    break
                end
            end
            # println(io, "Mean_viral_load_child_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_child_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_child_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_child_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_child_7"
                    break
                end
            end
            # println(io, "Mean_viral_load_child_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_child_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_child_7"
                    break
                end
            end
        end
        # println(io, "")


        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_adult_1)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_adult_1"
                    break
                end
            end
            # println(io, "Mean_viral_load_adult_1, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_adult_1)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_adult_1"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_adult_2)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_adult_2"
                    break
                end
            end
            # println(io, "Mean_viral_load_adult_2, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_adult_2)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_adult_2"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_adult_3)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_adult_3"
                    break
                end
            end
            # println(io, "Mean_viral_load_adult_3, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_adult_3)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_adult_3"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_adult_4)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_adult_4"
                    break
                end
            end
            # println(io, "Mean_viral_load_adult_4, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_adult_4)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_adult_4"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_adult_5)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_adult_5"
                    break
                end
            end
            # println(io, "Mean_viral_load_adult_5, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_adult_5)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_adult_5"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_adult_6)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_adult_6"
                    break
                end
            end
            # println(io, "Mean_viral_load_adult_6, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_adult_6)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_adult_6"
                    break
                end
            end
        end
        # println(io, "")
        for k = 1:length(peak_weeks)
            i = peak_weeks[k]
            corr = cor(incidence_arr_means[i, :], mean_viral_load_adult_7)
            for z = 1:num_best_vars
                if abs(corr) > abs(max_corr_values[k][z])
                    max_corr_values[k][z] = corr
                    max_corr_names[k][z] = "Mean_viral_load_adult_7"
                    break
                end
            end
            # println(io, "Mean_viral_load_adult_7, peak $(k): $(corr)")
        end
        for l = 1:7
            corr_viruses[l] = cor(incidence_arr_mean_viruses[argmax(viruses_mean[:, l]), l, :], mean_viral_load_adult_7)
            for z = 1:num_best_vars
                if abs(corr_viruses[l]) > abs(max_corr_value_viruses[l][z])
                    max_corr_value_viruses[l][z] = corr_viruses[l]
                    max_corr_name_viruses[l][z] = "Mean_viral_load_adult_7"
                    break
                end
            end
        end
        # println(io, "")

        for k = 1:length(peak_weeks)
            for z = 1:num_best_vars
                println(io, "Correlated variable $(z), peak $(k): $(max_corr_names[k][z]), value: $(max_corr_values[k][z])")
            end
            println(io, "")
        end
        for k = 1:7
            for z = 1:num_best_vars
                println(io, "Correlated variable $(z), virus $(k): $(max_corr_name_viruses[k][z]), value: $(max_corr_value_viruses[k][z])")
            end
            println(io, "")
        end
    end
end

function plot_incidences()
    num_runs = 1
    num_years = 3

    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence[i] += incidence_arr[k, j][i]
            end
        end
        incidence[i] /= num_runs * num_years
    end

    duration_parameter = 3.711739847454133
    susceptibility_parameters = [3.049958771387343, 3.797783962069675, 3.6978664192949933, 5.583601319315603, 4.070443207586069, 3.957334570191713, 4.612042877757162]
    temperature_parameters = -[-0.8786105957534528, -0.7631003916718199, -0.0868996083281797, -0.15656565656565657, -0.1027107812822098, -0.05588538445681307, -0.16932591218305615]
    random_infection_probabilities = [0.00011551556380127805, 6.822016079158936e-5, 4.922135642135645e-5, 6.844135229849516e-7]
    mean_immunity_durations = [255.05916305916304, 312.7078952793239, 101.87487116058544, 27.368377654091933, 77.08431251288393, 117.33374561945988, 103.15357658214802]

    d_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_d_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                d_minus_2[j] += d_minus_2[52 * (i - 1) + j]
            end
        end
    end
    d_minus_2 = d_minus_2[1:52] ./ num_years

    d_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_d_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                d_minus_1[j] += d_minus_1[52 * (i - 1) + j]
            end
        end
    end
    d_minus_1 = d_minus_1[1:52] ./ num_years

    d_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_d_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                d_1[j] += d_1[52 * (i - 1) + j]
            end
        end
    end
    d_1 = d_1[1:52] ./ num_years

    d_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_d_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                d_2[j] += d_2[52 * (i - 1) + j]
            end
        end
    end
    d_2 = d_2[1:52] ./ num_years

    s1_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s1_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s1_minus_2[j] += s1_minus_2[52 * (i - 1) + j]
            end
        end
    end
    s1_minus_2 = s1_minus_2[1:52] ./ num_years
    
    s1_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s1_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s1_minus_1[j] += s1_minus_1[52 * (i - 1) + j]
            end
        end
    end
    s1_minus_1 = s1_minus_1[1:52] ./ num_years

    s1_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s1_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s1_1[j] += s1_1[52 * (i - 1) + j]
            end
        end
    end
    s1_1 = s1_1[1:52] ./ num_years
    
    s1_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s1_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s1_2[j] += s1_2[52 * (i - 1) + j]
            end
        end
    end
    s1_2 = s1_2[1:52] ./ num_years

    s2_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s2_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s2_minus_2[j] += s2_minus_2[52 * (i - 1) + j]
            end
        end
    end
    s2_minus_2 = s2_minus_2[1:52] ./ num_years
    
    s2_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s2_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s2_minus_1[j] += s2_minus_1[52 * (i - 1) + j]
            end
        end
    end
    s2_minus_1 = s2_minus_1[1:52] ./ num_years
    
    s2_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s2_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s2_1[j] += s2_1[52 * (i - 1) + j]
            end
        end
    end
    s2_1 = s2_1[1:52] ./ num_years
    
    s2_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s2_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s2_2[j] += s2_2[52 * (i - 1) + j]
            end
        end
    end
    s2_2 = s2_2[1:52] ./ num_years

    s3_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s3_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s3_minus_2[j] += s3_minus_2[52 * (i - 1) + j]
            end
        end
    end
    s3_minus_2 = s3_minus_2[1:52] ./ num_years
    
    s3_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s3_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s3_minus_1[j] += s3_minus_1[52 * (i - 1) + j]
            end
        end
    end
    s3_minus_1 = s3_minus_1[1:52] ./ num_years
    
    s3_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s3_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s3_1[j] += s3_1[52 * (i - 1) + j]
            end
        end
    end
    s3_1 = s3_1[1:52] ./ num_years
    
    s3_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s3_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s3_2[j] += s3_2[52 * (i - 1) + j]
            end
        end
    end
    s3_2 = s3_2[1:52] ./ num_years

    s4_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s4_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s4_minus_2[j] += s4_minus_2[52 * (i - 1) + j]
            end
        end
    end
    s4_minus_2 = s4_minus_2[1:52] ./ num_years
    
    s4_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s4_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s4_minus_1[j] += s4_minus_1[52 * (i - 1) + j]
            end
        end
    end
    s4_minus_1 = s4_minus_1[1:52] ./ num_years
    
    s4_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s4_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s4_1[j] += s4_1[52 * (i - 1) + j]
            end
        end
    end
    s4_1 = s4_1[1:52] ./ num_years
    
    s4_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s4_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s4_2[j] += s4_2[52 * (i - 1) + j]
            end
        end
    end
    s4_2 = s4_2[1:52] ./ num_years

    s5_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s5_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s5_minus_2[j] += s5_minus_2[52 * (i - 1) + j]
            end
        end
    end
    s5_minus_2 = s5_minus_2[1:52] ./ num_years
    
    s5_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s5_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s5_minus_1[j] += s5_minus_1[52 * (i - 1) + j]
            end
        end
    end
    s5_minus_1 = s5_minus_1[1:52] ./ num_years
    
    s5_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s5_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s5_1[j] += s5_1[52 * (i - 1) + j]
            end
        end
    end
    s5_1 = s5_1[1:52] ./ num_years
    
    s5_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s5_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s5_2[j] += s5_2[52 * (i - 1) + j]
            end
        end
    end
    s5_2 = s5_2[1:52] ./ num_years

    s6_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s6_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s6_minus_2[j] += s6_minus_2[52 * (i - 1) + j]
            end
        end
    end
    s6_minus_2 = s6_minus_2[1:52] ./ num_years

    s6_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s6_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s6_minus_1[j] += s6_minus_1[52 * (i - 1) + j]
            end
        end
    end
    s6_minus_1 = s6_minus_1[1:52] ./ num_years
    
    s6_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s6_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s6_1[j] += s6_1[52 * (i - 1) + j]
            end
        end
    end
    s6_1 = s6_1[1:52] ./ num_years
    
    s6_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s6_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s6_2[j] += s6_2[52 * (i - 1) + j]
            end
        end
    end
    s6_2 = s6_2[1:52] ./ num_years

    s7_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s7_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s7_minus_2[j] += s7_minus_2[52 * (i - 1) + j]
            end
        end
    end
    s7_minus_2 = s7_minus_2[1:52] ./ num_years
    
    s7_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s7_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s7_minus_1[j] += s7_minus_1[52 * (i - 1) + j]
            end
        end
    end
    s7_minus_1 = s7_minus_1[1:52] ./ num_years
    
    s7_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s7_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s7_1[j] += s7_1[52 * (i - 1) + j]
            end
        end
    end
    s7_1 = s7_1[1:52] ./ num_years
    
    s7_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_s7_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s7_2[j] += s7_2[52 * (i - 1) + j]
            end
        end
    end
    s7_2 = s7_2[1:52] ./ num_years

    t1_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t1_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t1_minus_2[j] += t1_minus_2[52 * (i - 1) + j]
            end
        end
    end
    t1_minus_2 = t1_minus_2[1:52] ./ num_years
    
    t1_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t1_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t1_minus_1[j] += t1_minus_1[52 * (i - 1) + j]
            end
        end
    end
    t1_minus_1 = t1_minus_1[1:52] ./ num_years
    
    t1_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t1_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t1_1[j] += t1_1[52 * (i - 1) + j]
            end
        end
    end
    t1_1 = t1_1[1:52] ./ num_years
    
    t1_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t1_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t1_2[j] += t1_2[52 * (i - 1) + j]
            end
        end
    end
    t1_2 = t1_2[1:52] ./ num_years

    t2_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t2_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t2_minus_2[j] += t2_minus_2[52 * (i - 1) + j]
            end
        end
    end
    t2_minus_2 = t2_minus_2[1:52] ./ num_years
    
    t2_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t2_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t2_minus_1[j] += t2_minus_1[52 * (i - 1) + j]
            end
        end
    end
    t2_minus_1 = t2_minus_1[1:52] ./ num_years
    
    t2_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t2_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t2_1[j] += t2_1[52 * (i - 1) + j]
            end
        end
    end
    t2_1 = t2_1[1:52] ./ num_years
    
    t2_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t2_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t2_2[j] += t2_2[52 * (i - 1) + j]
            end
        end
    end
    t2_2 = t2_2[1:52] ./ num_years

    t3_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t3_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t3_minus_2[j] += t3_minus_2[52 * (i - 1) + j]
            end
        end
    end
    t3_minus_2 = t3_minus_2[1:52] ./ num_years
    
    t3_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t3_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t3_minus_1[j] += t3_minus_1[52 * (i - 1) + j]
            end
        end
    end
    t3_minus_1 = t3_minus_1[1:52] ./ num_years
    
    t3_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t3_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t3_1[j] += t3_1[52 * (i - 1) + j]
            end
        end
    end
    t3_1 = t3_1[1:52] ./ num_years
    
    t3_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t3_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t3_2[j] += t3_2[52 * (i - 1) + j]
            end
        end
    end
    t3_2 = t3_2[1:52] ./ num_years

    t4_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t4_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t4_minus_2[j] += t4_minus_2[52 * (i - 1) + j]
            end
        end
    end
    t4_minus_2 = t4_minus_2[1:52] ./ num_years
    
    t4_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t4_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t4_minus_1[j] += t4_minus_1[52 * (i - 1) + j]
            end
        end
    end
    t4_minus_1 = t4_minus_1[1:52] ./ num_years
    
    t4_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t4_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t4_1[j] += t4_1[52 * (i - 1) + j]
            end
        end
    end
    t4_1 = t4_1[1:52] ./ num_years
    
    t4_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t4_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t4_2[j] += t4_2[52 * (i - 1) + j]
            end
        end
    end
    t4_2 = t4_2[1:52] ./ num_years

    t5_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t5_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t5_minus_2[j] += t5_minus_2[52 * (i - 1) + j]
            end
        end
    end
    t5_minus_2 = t5_minus_2[1:52] ./ num_years
    
    t5_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t5_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t5_minus_1[j] += t5_minus_1[52 * (i - 1) + j]
            end
        end
    end
    t5_minus_1 = t5_minus_1[1:52] ./ num_years
    
    t5_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t5_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t5_1[j] += t5_1[52 * (i - 1) + j]
            end
        end
    end
    t5_1 = t5_1[1:52] ./ num_years
    
    t5_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t5_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t5_2[j] += t5_2[52 * (i - 1) + j]
            end
        end
    end
    t5_2 = t5_2[1:52] ./ num_years

    t6_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t6_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t6_minus_2[j] += t6_minus_2[52 * (i - 1) + j]
            end
        end
    end
    t6_minus_2 = t6_minus_2[1:52] ./ num_years
    
    t6_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t6_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t6_minus_1[j] += t6_minus_1[52 * (i - 1) + j]
            end
        end
    end
    t6_minus_1 = t6_minus_1[1:52] ./ num_years
    
    t6_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t6_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t6_1[j] += t6_1[52 * (i - 1) + j]
            end
        end
    end
    t6_1 = t6_1[1:52] ./ num_years
    
    t6_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t6_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t6_2[j] += t6_2[52 * (i - 1) + j]
            end
        end
    end
    t6_2 = t6_2[1:52] ./ num_years

    t7_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t7_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t7_minus_2[j] += t7_minus_2[52 * (i - 1) + j]
            end
        end
    end
    t7_minus_2 = t7_minus_2[1:52] ./ num_years
    
    t7_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t7_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t7_minus_1[j] += t7_minus_1[52 * (i - 1) + j]
            end
        end
    end
    t7_minus_1 = t7_minus_1[1:52] ./ num_years
    
    t7_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t7_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t7_1[j] += t7_1[52 * (i - 1) + j]
            end
        end
    end
    t7_1 = t7_1[1:52] ./ num_years
    
    t7_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_t7_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t7_2[j] += t7_2[52 * (i - 1) + j]
            end
        end
    end
    t7_2 = t7_2[1:52] ./ num_years

    p1_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p1_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p1_minus_2[j] += p1_minus_2[52 * (i - 1) + j]
            end
        end
    end
    p1_minus_2 = p1_minus_2[1:52] ./ num_years
    
    p1_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p1_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p1_minus_1[j] += p1_minus_1[52 * (i - 1) + j]
            end
        end
    end
    p1_minus_1 = p1_minus_1[1:52] ./ num_years
    
    p1_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p1_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p1_1[j] += p1_1[52 * (i - 1) + j]
            end
        end
    end
    p1_1 = p1_1[1:52] ./ num_years
    
    p1_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p1_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p1_2[j] += p1_2[52 * (i - 1) + j]
            end
        end
    end
    p1_2 = p1_2[1:52] ./ num_years

    p2_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p2_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p2_minus_2[j] += p2_minus_2[52 * (i - 1) + j]
            end
        end
    end
    p2_minus_2 = p2_minus_2[1:52] ./ num_years
    
    p2_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p2_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p2_minus_1[j] += p2_minus_1[52 * (i - 1) + j]
            end
        end
    end
    p2_minus_1 = p2_minus_1[1:52] ./ num_years
    
    p2_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p2_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p2_1[j] += p2_1[52 * (i - 1) + j]
            end
        end
    end
    p2_1 = p2_1[1:52] ./ num_years
    
    p2_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p2_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p2_2[j] += p2_2[52 * (i - 1) + j]
            end
        end
    end
    p2_2 = p2_2[1:52] ./ num_years

    p3_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p3_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p3_minus_2[j] += p3_minus_2[52 * (i - 1) + j]
            end
        end
    end
    p3_minus_2 = p3_minus_2[1:52] ./ num_years
    
    p3_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p3_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p3_minus_1[j] += p3_minus_1[52 * (i - 1) + j]
            end
        end
    end
    p3_minus_1 = p3_minus_1[1:52] ./ num_years
    
    p3_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p3_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p3_1[j] += p3_1[52 * (i - 1) + j]
            end
        end
    end
    p3_1 = p3_1[1:52] ./ num_years
    
    p3_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p3_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p3_2[j] += p3_2[52 * (i - 1) + j]
            end
        end
    end
    p3_2 = p3_2[1:52] ./ num_years
    
    p4_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p4_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p4_minus_2[j] += p4_minus_2[52 * (i - 1) + j]
            end
        end
    end
    p4_minus_2 = p4_minus_2[1:52] ./ num_years
    
    p4_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p4_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p4_minus_1[j] += p4_minus_1[52 * (i - 1) + j]
            end
        end
    end
    p4_minus_1 = p4_minus_1[1:52] ./ num_years
    
    p4_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p4_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p4_1[j] += p4_1[52 * (i - 1) + j]
            end
        end
    end
    p4_1 = p4_1[1:52] ./ num_years
    
    p4_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_p4_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p4_2[j] += p4_2[52 * (i - 1) + j]
            end
        end
    end
    p4_2 = p4_2[1:52] ./ num_years

    r1_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r1_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r1_minus_2[j] += r1_minus_2[52 * (i - 1) + j]
            end
        end
    end
    r1_minus_2 = r1_minus_2[1:52] ./ num_years
    
    r1_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r1_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r1_minus_1[j] += r1_minus_1[52 * (i - 1) + j]
            end
        end
    end
    r1_minus_1 = r1_minus_1[1:52] ./ num_years
    
    r1_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r1_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r1_1[j] += r1_1[52 * (i - 1) + j]
            end
        end
    end
    r1_1 = r1_1[1:52] ./ num_years
    
    r1_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r1_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r1_2[j] += r1_2[52 * (i - 1) + j]
            end
        end
    end
    r1_2 = r1_2[1:52] ./ num_years

    r2_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r2_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r2_minus_2[j] += r2_minus_2[52 * (i - 1) + j]
            end
        end
    end
    r2_minus_2 = r2_minus_2[1:52] ./ num_years
    
    r2_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r2_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r2_minus_1[j] += r2_minus_1[52 * (i - 1) + j]
            end
        end
    end
    r2_minus_1 = r2_minus_1[1:52] ./ num_years
    
    r2_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r2_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r2_1[j] += r2_1[52 * (i - 1) + j]
            end
        end
    end
    r2_1 = r2_1[1:52] ./ num_years
    
    r2_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r2_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r2_2[j] += r2_2[52 * (i - 1) + j]
            end
        end
    end
    r2_2 = r2_2[1:52] ./ num_years

    r3_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r3_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r3_minus_2[j] += r3_minus_2[52 * (i - 1) + j]
            end
        end
    end
    r3_minus_2 = r3_minus_2[1:52] ./ num_years
    
    r3_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r3_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r3_minus_1[j] += r3_minus_1[52 * (i - 1) + j]
            end
        end
    end
    r3_minus_1 = r3_minus_1[1:52] ./ num_years
    
    r3_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r3_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r3_1[j] += r3_1[52 * (i - 1) + j]
            end
        end
    end
    r3_1 = r3_1[1:52] ./ num_years
    
    r3_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r3_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r3_2[j] += r3_2[52 * (i - 1) + j]
            end
        end
    end
    r3_2 = r3_2[1:52] ./ num_years

    r4_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r4_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r4_minus_2[j] += r4_minus_2[52 * (i - 1) + j]
            end
        end
    end
    r4_minus_2 = r4_minus_2[1:52] ./ num_years
    
    r4_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r4_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r4_minus_1[j] += r4_minus_1[52 * (i - 1) + j]
            end
        end
    end
    r4_minus_1 = r4_minus_1[1:52] ./ num_years
    
    r4_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r4_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r4_1[j] += r4_1[52 * (i - 1) + j]
            end
        end
    end
    r4_1 = r4_1[1:52] ./ num_years
    
    r4_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r4_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r4_2[j] += r4_2[52 * (i - 1) + j]
            end
        end
    end
    r4_2 = r4_2[1:52] ./ num_years

    r5_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r5_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r5_minus_2[j] += r5_minus_2[52 * (i - 1) + j]
            end
        end
    end
    r5_minus_2 = r5_minus_2[1:52] ./ num_years
    
    r5_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r5_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r5_minus_1[j] += r5_minus_1[52 * (i - 1) + j]
            end
        end
    end
    r5_minus_1 = r5_minus_1[1:52] ./ num_years
    
    r5_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r5_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r5_1[j] += r5_1[52 * (i - 1) + j]
            end
        end
    end
    r5_1 = r5_1[1:52] ./ num_years
    
    r5_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r5_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r5_2[j] += r5_2[52 * (i - 1) + j]
            end
        end
    end
    r5_2 = r5_2[1:52] ./ num_years

    r6_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r6_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r6_minus_2[j] += r6_minus_2[52 * (i - 1) + j]
            end
        end
    end
    r6_minus_2 = r6_minus_2[1:52] ./ num_years
    
    r6_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r6_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r6_minus_1[j] += r6_minus_1[52 * (i - 1) + j]
            end
        end
    end
    r6_minus_1 = r6_minus_1[1:52] ./ num_years
    
    r6_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r6_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r6_1[j] += r6_1[52 * (i - 1) + j]
            end
        end
    end
    r6_1 = r6_1[1:52] ./ num_years
    
    r6_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r6_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r6_2[j] += r6_2[52 * (i - 1) + j]
            end
        end
    end
    r6_2 = r6_2[1:52] ./ num_years

    r7_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r7_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r7_minus_2[j] += r7_minus_2[52 * (i - 1) + j]
            end
        end
    end
    r7_minus_2 = r7_minus_2[1:52] ./ num_years
    
    r7_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r7_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r7_minus_1[j] += r7_minus_1[52 * (i - 1) + j]
            end
        end
    end
    r7_minus_1 = r7_minus_1[1:52] ./ num_years
    
    r7_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r7_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r7_1[j] += r7_1[52 * (i - 1) + j]
            end
        end
    end
    r7_1 = r7_1[1:52] ./ num_years
    
    r7_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "2nd", "infected_data_r7_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r7_2[j] += r7_2[52 * (i - 1) + j]
            end
        end
    end
    r7_2 = r7_2[1:52] ./ num_years

    # ticks = range(1, stop = 52, length = 13)
    # ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    yticks = [2, 6, 10, 14]
    yticklabels = ["2", "6", "10", "14"]
    incidence_plot = plot(
        1:52,
        [d_minus_2 d_minus_1 incidence d_1 d_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        legend = (0.91, 1.0),
        ylims = (0, 17),
        margin = 2Plots.mm,
        label = ["$(round(duration_parameter * 0.8, digits = 2))" "$(round(duration_parameter * 0.9, digits = 2))" "$(round(duration_parameter, digits = 2))" "$(round(duration_parameter * 1.1, digits = 2))" "$(round(duration_parameter * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "d.pdf"))

    incidence_plot = plot(
        1:52,
        [s1_minus_2 s1_minus_1 incidence s1_1 s1_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        label = ["$(round(susceptibility_parameters[1] * 0.8, digits = 2))" "$(round(susceptibility_parameters[1] * 0.9, digits = 2))" "$(round(susceptibility_parameters[1], digits = 2))" "$(round(susceptibility_parameters[1] * 1.1, digits = 2))" "$(round(susceptibility_parameters[1] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "s1.pdf"))

    incidence_plot = plot(
        1:52,
        [s2_minus_2 s2_minus_1 incidence s2_1 s2_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        label = ["$(round(susceptibility_parameters[2] * 0.8, digits = 2))" "$(round(susceptibility_parameters[2] * 0.9, digits = 2))" "$(round(susceptibility_parameters[2], digits = 2))" "$(round(susceptibility_parameters[2] * 1.1, digits = 2))" "$(round(susceptibility_parameters[2] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "s2.pdf"))

    incidence_plot = plot(
        1:52,
        [s3_minus_2 s3_minus_1 incidence s3_1 s3_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(susceptibility_parameters[3] * 0.8, digits = 2))" "$(round(susceptibility_parameters[3] * 0.9, digits = 2))" "$(round(susceptibility_parameters[3], digits = 2))" "$(round(susceptibility_parameters[3] * 1.1, digits = 2))" "$(round(susceptibility_parameters[3] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "s3.pdf"))

    incidence_plot = plot(
        1:52,
        [s4_minus_2 s4_minus_1 incidence s4_1 s4_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.85, 0.95),
        label = ["$(round(susceptibility_parameters[4] * 0.8, digits = 2))" "$(round(susceptibility_parameters[4] * 0.9, digits = 2))" "$(round(susceptibility_parameters[4], digits = 2))" "$(round(susceptibility_parameters[4] * 1.1, digits = 2))" "$(round(susceptibility_parameters[4] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "s4.pdf"))

    incidence_plot = plot(
        1:52,
        [s5_minus_2 s5_minus_1 incidence s5_1 s5_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 1.0),
        ylims = (0, 13),
        label = ["$(round(susceptibility_parameters[5] * 0.8, digits = 2))" "$(round(susceptibility_parameters[5] * 0.9, digits = 2))" "$(round(susceptibility_parameters[5], digits = 2))" "$(round(susceptibility_parameters[5] * 1.1, digits = 2))" "$(round(susceptibility_parameters[5] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "s5.pdf"))

    incidence_plot = plot(
        1:52,
        [s6_minus_2 s6_minus_1 incidence s6_1 s6_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.92, 0.98),
        label = ["$(round(susceptibility_parameters[6] * 0.8, digits = 2))" "$(round(susceptibility_parameters[6] * 0.9, digits = 2))" "$(round(susceptibility_parameters[6], digits = 2))" "$(round(susceptibility_parameters[6] * 1.1, digits = 2))" "$(round(susceptibility_parameters[6] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "s6.pdf"))

    incidence_plot = plot(
        1:52,
        [s7_minus_2 s7_minus_1 incidence s7_1 s7_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(susceptibility_parameters[7] * 0.8, digits = 2))" "$(round(susceptibility_parameters[7] * 0.9, digits = 2))" "$(round(susceptibility_parameters[7], digits = 2))" "$(round(susceptibility_parameters[7] * 1.1, digits = 2))" "$(round(susceptibility_parameters[7] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "s7.pdf"))

    incidence_plot = plot(
        1:52,
        [t1_minus_2 t1_minus_1 incidence t1_1 t1_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[1], digits = 2))" "$(0.75)" "$(1.0)"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "t1.pdf"))

    incidence_plot = plot(
        1:52,
        [t2_minus_2 t2_minus_1 incidence t2_1 t2_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[2], digits = 2))" "$(0.75)" "$(1.0)"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "t2.pdf"))

    incidence_plot = plot(
        1:52,
        [t3_minus_2 t3_minus_1 incidence t3_1 t3_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[3], digits = 2))" "$(0.75)" "$(1.0)"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "t3.pdf"))

    incidence_plot = plot(
        1:52,
        [t4_minus_2 t4_minus_1 incidence t4_1 t4_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[4], digits = 2))" "$(0.75)" "$(1.0)"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "t4.pdf"))

    incidence_plot = plot(
        1:52,
        [t5_minus_2 t5_minus_1 incidence t5_1 t5_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[5], digits = 2))" "$(0.75)" "$(1.0)"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "t5.pdf"))

    incidence_plot = plot(
        1:52,
        [t6_minus_2 t6_minus_1 incidence t6_1 t6_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[6], digits = 2))" "$(0.75)" "$(1.0)"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "t6.pdf"))

    incidence_plot = plot(
        1:52,
        [t7_minus_2 t7_minus_1 incidence t7_1 t7_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[7], digits = 2))" "$(0.75)" "$(1.0)"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "t7.pdf"))

    incidence_plot = plot(
        1:52,
        [p1_minus_2 p1_minus_1 incidence p1_1 p1_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(random_infection_probabilities[1] * 0.1, digits = 6))" "$(round(random_infection_probabilities[1] * 0.5, digits = 6))" "$(round(random_infection_probabilities[1], digits = 6))" "$(round(random_infection_probabilities[1] * 2.0, digits = 6))" "$(round(random_infection_probabilities[1] * 10.0, digits = 6))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "p1.pdf"))

    incidence_plot = plot(
        1:52,
        [p2_minus_2 p2_minus_1 incidence p2_1 p2_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(random_infection_probabilities[2] * 0.1, digits = 6))" "$(round(random_infection_probabilities[2] * 0.5, digits = 6))" "$(round(random_infection_probabilities[2], digits = 6))" "$(round(random_infection_probabilities[2] * 2.0, digits = 6))" "$(round(random_infection_probabilities[2] * 10.0, digits = 6))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "p2.pdf"))

    incidence_plot = plot(
        1:52,
        [p3_minus_2 p3_minus_1 incidence p3_1 p3_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(random_infection_probabilities[3] * 0.1, digits = 6))" "$(round(random_infection_probabilities[3] * 0.5, digits = 6))" "$(round(random_infection_probabilities[3], digits = 6))" "$(round(random_infection_probabilities[3] * 2.0, digits = 6))" "$(round(random_infection_probabilities[3] * 10.0, digits = 6))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "p3.pdf"))

    incidence_plot = plot(
        1:52,
        [p4_minus_2 p4_minus_1 incidence p4_1 p4_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(random_infection_probabilities[4] * 0.1, digits = 7))" "$(round(random_infection_probabilities[4] * 0.5, digits = 7))" "$(round(random_infection_probabilities[4], digits = 7))" "$(round(random_infection_probabilities[4] * 2.0, digits = 7))" "$(round(random_infection_probabilities[4] * 10.0, digits = 7))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "p4.pdf"))

    incidence_plot = plot(
        1:52,
        [r1_minus_2 r1_minus_1 incidence r1_1 r1_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(mean_immunity_durations[1] * 0.8, digits = 2))" "$(round(mean_immunity_durations[1] * 0.9, digits = 2))" "$(round(mean_immunity_durations[1], digits = 2))" "$(round(mean_immunity_durations[1] * 1.1, digits = 2))" "$(round(mean_immunity_durations[1] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "r1.pdf"))

    incidence_plot = plot(
        1:52,
        [r2_minus_2 r2_minus_1 incidence r2_1 r2_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(mean_immunity_durations[2] * 0.8, digits = 2))" "$(round(mean_immunity_durations[2] * 0.9, digits = 2))" "$(round(mean_immunity_durations[2], digits = 2))" "$(round(mean_immunity_durations[2] * 1.1, digits = 2))" "$(round(mean_immunity_durations[2] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "r2.pdf"))

    incidence_plot = plot(
        1:52,
        [r3_minus_2 r3_minus_1 incidence r3_1 r3_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(mean_immunity_durations[3] * 0.8, digits = 2))" "$(round(mean_immunity_durations[3] * 0.9, digits = 2))" "$(round(mean_immunity_durations[3], digits = 2))" "$(round(mean_immunity_durations[3] * 1.1, digits = 2))" "$(round(mean_immunity_durations[3] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "r3.pdf"))

    incidence_plot = plot(
        1:52,
        [r4_minus_2 r4_minus_1 incidence r4_1 r4_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(mean_immunity_durations[4] * 0.8, digits = 2))" "$(round(mean_immunity_durations[4] * 0.9, digits = 2))" "$(round(mean_immunity_durations[4], digits = 2))" "$(round(mean_immunity_durations[4] * 1.1, digits = 2))" "$(round(mean_immunity_durations[4] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "r4.pdf"))

    incidence_plot = plot(
        1:52,
        [r5_minus_2 r5_minus_1 incidence r5_1 r5_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(mean_immunity_durations[5] * 0.8, digits = 2))" "$(round(mean_immunity_durations[5] * 0.9, digits = 2))" "$(round(mean_immunity_durations[5], digits = 2))" "$(round(mean_immunity_durations[5] * 1.1, digits = 2))" "$(round(mean_immunity_durations[5] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "r5.pdf"))

    incidence_plot = plot(
        1:52,
        [r6_minus_2 r6_minus_1 incidence r6_1 r6_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(mean_immunity_durations[6] * 0.8, digits = 2))" "$(round(mean_immunity_durations[6] * 0.9, digits = 2))" "$(round(mean_immunity_durations[6], digits = 2))" "$(round(mean_immunity_durations[6] * 1.1, digits = 2))" "$(round(mean_immunity_durations[6] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "r6.pdf"))

    incidence_plot = plot(
        1:52,
        [r7_minus_2 r7_minus_1 incidence r7_1 r7_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(mean_immunity_durations[7] * 0.8, digits = 2))" "$(round(mean_immunity_durations[7] * 0.9, digits = 2))" "$(round(mean_immunity_durations[7], digits = 2))" "$(round(mean_immunity_durations[7] * 1.1, digits = 2))" "$(round(mean_immunity_durations[7] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "r7.pdf"))
end

# plot_infection_curves()
plot_incidences()
