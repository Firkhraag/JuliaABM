using DelimitedFiles
using Plots
using Statistics
using LaTeXStrings
using JLD

include("../util/moving_avg.jl")
include("../data/etiology.jl")
include("../global/variables.jl")

# default(legendfontsize = 15, guidefont = (22, :black), tickfont = (15, :black))
default(legendfontsize = 11, guidefont = (12, :black), tickfont = (11, :black))

const is_russian = false

function plot_infection_curves()
    num_runs = 100
    num_years = 3

    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_means = zeros(Float64, 52, num_runs)

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
        grid = !is_russian,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "incidence.pdf"))

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = L"R_t"
    if is_russian
        ylabel_name = "Rt"
    end

    rt_plot = plot(
        1:365,
        [rt_arr_means[1:365, i] for i = 1:num_runs],
        lw = 1,
        xticks = (ticks_rt, ticklabels),
        legend = false,
        grid = !is_russian,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(rt_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "rt.pdf"))

    open(joinpath(@__DIR__, "..", "..", "sensitivity", "output.txt"), "w") do io
        corr = 0.0


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_1_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Isolation_probability_day_1_1, w$(i): $(corr)")
        end
        println(io, "Isolation_probability_day_1_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_1_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Isolation_probability_day_1_2, w$(i): $(corr)")
        end
        println(io, "Isolation_probability_day_1_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_1_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Isolation_probability_day_1_3, w$(i): $(corr)")
        end
        println(io, "Isolation_probability_day_1_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_1_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Isolation_probability_day_1_4, w$(i): $(corr)")
        end
        println(io, "Isolation_probability_day_1_4, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_2_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Isolation_probability_day_2_1, w$(i): $(corr)")
        end
        println(io, "Isolation_probability_day_2_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_2_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Isolation_probability_day_2_2, w$(i): $(corr)")
        end
        println(io, "Isolation_probability_day_2_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_2_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Isolation_probability_day_2_3, w$(i): $(corr)")
        end
        println(io, "Isolation_probability_day_2_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_2_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Isolation_probability_day_2_4, w$(i): $(corr)")
        end
        println(io, "Isolation_probability_day_2_4, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_3_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Isolation_probability_day_3_1, w$(i): $(corr)")
        end
        println(io, "Isolation_probability_day_3_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_3_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Isolation_probability_day_3_2, w$(i): $(corr)")
        end
        println(io, "Isolation_probability_day_3_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_3_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Isolation_probability_day_3_3, w$(i): $(corr)")
        end
        println(io, "Isolation_probability_day_3_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], isolation_probability_day_3_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Isolation_probability_day_3_4, w$(i): $(corr)")
        end
        println(io, "Isolation_probability_day_3_4, overall: $(max_value)")
        println(io, "")
        

        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], recovered_duration_mean)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Recovered_duration_mean, w$(i): $(corr)")
        end
        println(io, "Recovered_duration_mean, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], recovered_duration_sd)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Recovered_duration_sd, w$(i): $(corr)")
        end
        println(io, "Recovered_duration_sd, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_household_contact_duration_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_household_contact_duration_1, w$(i): $(corr)")
        end
        println(io, "Mean_household_contact_duration_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_household_contact_duration_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_household_contact_duration_2, w$(i): $(corr)")
        end
        println(io, "Mean_household_contact_duration_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_household_contact_duration_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_household_contact_duration_3, w$(i): $(corr)")
        end
        println(io, "Mean_household_contact_duration_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_household_contact_duration_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_household_contact_duration_4, w$(i): $(corr)")
        end
        println(io, "Mean_household_contact_duration_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_household_contact_duration_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_household_contact_duration_5, w$(i): $(corr)")
        end
        println(io, "Mean_household_contact_duration_5, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], household_contact_duration_sd_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Household_contact_duration_sd_1, w$(i): $(corr)")
        end
        println(io, "Household_contact_duration_sd_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], household_contact_duration_sd_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Household_contact_duration_sd_2, w$(i): $(corr)")
        end
        println(io, "Household_contact_duration_sd_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], household_contact_duration_sd_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Household_contact_duration_sd_3, w$(i): $(corr)")
        end
        println(io, "Household_contact_duration_sd_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], household_contact_duration_sd_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Household_contact_duration_sd_4, w$(i): $(corr)")
        end
        println(io, "Household_contact_duration_sd_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], household_contact_duration_sd_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Household_contact_duration_sd_5, w$(i): $(corr)")
        end
        println(io, "Household_contact_duration_sd_5, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], other_contact_duration_shape_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Other_contact_duration_shape_1, w$(i): $(corr)")
        end
        println(io, "Other_contact_duration_shape_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], other_contact_duration_shape_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Other_contact_duration_shape_2, w$(i): $(corr)")
        end
        println(io, "Other_contact_duration_shape_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], other_contact_duration_shape_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Other_contact_duration_shape_3, w$(i): $(corr)")
        end
        println(io, "Other_contact_duration_shape_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], other_contact_duration_shape_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Other_contact_duration_shape_4, w$(i): $(corr)")
        end
        println(io, "Other_contact_duration_shape_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], other_contact_duration_shape_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Other_contact_duration_shape_5, w$(i): $(corr)")
        end
        println(io, "Other_contact_duration_shape_5, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], other_contact_duration_scale_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Other_contact_duration_scale_1, w$(i): $(corr)")
        end
        println(io, "Other_contact_duration_scale_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], other_contact_duration_scale_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Other_contact_duration_scale_2, w$(i): $(corr)")
        end
        println(io, "Other_contact_duration_scale_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], other_contact_duration_scale_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Other_contact_duration_scale_3, w$(i): $(corr)")
        end
        println(io, "Other_contact_duration_scale_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], other_contact_duration_scale_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Other_contact_duration_scale_4, w$(i): $(corr)")
        end
        println(io, "Other_contact_duration_scale_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], other_contact_duration_scale_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Other_contact_duration_scale_5, w$(i): $(corr)")
        end
        println(io, "Other_contact_duration_scale_5, overall: $(max_value)")
        println(io, "")

        
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], duration_parameter)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Duration_parameter, w$(i): $(corr)")
        end
        println(io, "Duration_parameter, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], susceptibility_parameter_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Susceptibility_parameter_1, w$(i): $(corr)")
        end
        println(io, "Susceptibility_parameter_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], susceptibility_parameter_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Susceptibility_parameter_2, w$(i): $(corr)")
        end
        println(io, "Susceptibility_parameter_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], susceptibility_parameter_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Susceptibility_parameter_3, w$(i): $(corr)")
        end
        println(io, "Susceptibility_parameter_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], susceptibility_parameter_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Susceptibility_parameter_4, w$(i): $(corr)")
        end
        println(io, "Susceptibility_parameter_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], susceptibility_parameter_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Susceptibility_parameter_5, w$(i): $(corr)")
        end
        println(io, "Susceptibility_parameter_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], susceptibility_parameter_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Susceptibility_parameter_6, w$(i): $(corr)")
        end
        println(io, "Susceptibility_parameter_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], susceptibility_parameter_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Susceptibility_parameter_7, w$(i): $(corr)")
        end
        println(io, "Susceptibility_parameter_7, overall: $(max_value)")
        println(io, "")

        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], temperature_parameter_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Temperature_parameter_1, w$(i): $(corr)")
        end
        println(io, "Temperature_parameter_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], temperature_parameter_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Temperature_parameter_2, w$(i): $(corr)")
        end
        println(io, "Temperature_parameter_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], temperature_parameter_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Temperature_parameter_3, w$(i): $(corr)")
        end
        println(io, "Temperature_parameter_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], temperature_parameter_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Temperature_parameter_4, w$(i): $(corr)")
        end
        println(io, "Temperature_parameter_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], temperature_parameter_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Temperature_parameter_5, w$(i): $(corr)")
        end
        println(io, "Temperature_parameter_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], temperature_parameter_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Temperature_parameter_6, w$(i): $(corr)")
        end
        println(io, "Temperature_parameter_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], temperature_parameter_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Temperature_parameter_7, w$(i): $(corr)")
        end
        println(io, "Temperature_parameter_7, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], random_infection_probability_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Random_infection_probability_1, w$(i): $(corr)")
        end
        println(io, "Random_infection_probability_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], random_infection_probability_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Random_infection_probability_2, w$(i): $(corr)")
        end
        println(io, "Random_infection_probability_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], random_infection_probability_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Random_infection_probability_3, w$(i): $(corr)")
        end
        println(io, "Random_infection_probability_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], random_infection_probability_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Random_infection_probability_4, w$(i): $(corr)")
        end
        println(io, "Random_infection_probability_4, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_immunity_duration_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_immunity_duration_1, w$(i): $(corr)")
        end
        println(io, "Mean_immunity_duration_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_immunity_duration_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_immunity_duration_2, w$(i): $(corr)")
        end
        println(io, "Mean_immunity_duration_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_immunity_duration_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_immunity_duration_3, w$(i): $(corr)")
        end
        println(io, "Mean_immunity_duration_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_immunity_duration_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_immunity_duration_4, w$(i): $(corr)")
        end
        println(io, "Mean_immunity_duration_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_immunity_duration_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_immunity_duration_5, w$(i): $(corr)")
        end
        println(io, "Mean_immunity_duration_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_immunity_duration_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_immunity_duration_6, w$(i): $(corr)")
        end
        println(io, "Mean_immunity_duration_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_immunity_duration_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_immunity_duration_7, w$(i): $(corr)")
        end
        println(io, "Mean_immunity_duration_7, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Incubation_period_duration_1, w$(i): $(corr)")
        end
        println(io, "Incubation_period_duration_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Incubation_period_duration_2, w$(i): $(corr)")
        end
        println(io, "Incubation_period_duration_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Incubation_period_duration_3, w$(i): $(corr)")
        end
        println(io, "Incubation_period_duration_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Incubation_period_duration_4, w$(i): $(corr)")
        end
        println(io, "Incubation_period_duration_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Incubation_period_duration_5, w$(i): $(corr)")
        end
        println(io, "Incubation_period_duration_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Incubation_period_duration_6, w$(i): $(corr)")
        end
        println(io, "Incubation_period_duration_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Incubation_period_duration_7, w$(i): $(corr)")
        end
        println(io, "Incubation_period_duration_7, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_variance_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Incubation_period_duration_variance_1, w$(i): $(corr)")
        end
        println(io, "Incubation_period_duration_variance_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_variance_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Incubation_period_duration_variance_2, w$(i): $(corr)")
        end
        println(io, "Incubation_period_duration_variance_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_variance_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Incubation_period_duration_variance_3, w$(i): $(corr)")
        end
        println(io, "Incubation_period_duration_variance_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_variance_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Incubation_period_duration_variance_4, w$(i): $(corr)")
        end
        println(io, "Incubation_period_duration_variance_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_variance_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Incubation_period_duration_variance_5, w$(i): $(corr)")
        end
        println(io, "Incubation_period_duration_variance_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_variance_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Incubation_period_duration_variance_6, w$(i): $(corr)")
        end
        println(io, "Incubation_period_duration_variance_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], incubation_period_duration_variance_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Incubation_period_duration_variance_7, w$(i): $(corr)")
        end
        println(io, "Incubation_period_duration_variance_7, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_child_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_child_1, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_child_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_child_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_child_2, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_child_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_child_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_child_3, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_child_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_child_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_child_4, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_child_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_child_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_child_5, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_child_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_child_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_child_6, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_child_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_child_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_child_7, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_child_7, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_child_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_variance_child_1, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_variance_child_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_child_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_variance_child_2, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_variance_child_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_child_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_variance_child_3, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_variance_child_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_child_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_variance_child_4, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_variance_child_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_child_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_variance_child_5, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_variance_child_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_child_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_variance_child_6, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_variance_child_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_child_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_variance_child_7, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_variance_child_7, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_adult_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_adult_1, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_adult_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_adult_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_adult_2, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_adult_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_adult_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_adult_3, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_adult_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_adult_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_adult_4, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_adult_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_adult_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_adult_5, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_adult_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_adult_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_adult_6, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_adult_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_adult_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_adult_7, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_adult_7, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_adult_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_variance_adult_1, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_variance_adult_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_adult_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_variance_adult_2, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_variance_adult_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_adult_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_variance_adult_3, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_variance_adult_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_adult_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_variance_adult_4, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_variance_adult_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_adult_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_variance_adult_5, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_variance_adult_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_adult_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_variance_adult_6, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_variance_adult_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], infection_period_duration_variance_adult_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Infection_period_duration_variance_adult_7, w$(i): $(corr)")
        end
        println(io, "Infection_period_duration_variance_adult_7, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_child_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_child_1, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_child_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_child_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_child_2, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_child_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_child_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_child_3, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_child_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_child_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_child_4, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_child_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_child_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_child_5, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_child_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_child_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_child_6, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_child_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_child_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_child_7, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_child_7, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_teenager_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_teenager_1, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_teenager_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_teenager_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_teenager_2, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_teenager_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_teenager_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_teenager_3, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_teenager_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_teenager_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_teenager_4, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_teenager_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_teenager_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_teenager_5, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_teenager_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_teenager_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_teenager_6, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_teenager_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_teenager_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_teenager_7, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_teenager_7, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_adult_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_adult_1, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_adult_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_adult_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_adult_2, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_adult_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_adult_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_adult_3, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_adult_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_adult_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_adult_4, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_adult_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_adult_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_adult_5, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_adult_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_adult_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_adult_6, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_adult_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], symptomatic_probability_adult_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Symptomatic_probability_adult_7, w$(i): $(corr)")
        end
        println(io, "Symptomatic_probability_adult_7, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_infant_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_infant_1, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_infant_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_infant_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_infant_2, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_infant_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_infant_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_infant_3, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_infant_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_infant_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_infant_4, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_infant_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_infant_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_infant_5, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_infant_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_infant_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_infant_6, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_infant_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_infant_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_infant_7, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_infant_7, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_child_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_child_1, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_child_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_child_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_child_2, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_child_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_child_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_child_3, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_child_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_child_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_child_4, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_child_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_child_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_child_5, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_child_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_child_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_child_6, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_child_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_child_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_child_7, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_child_7, overall: $(max_value)")
        println(io, "")


        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_adult_1)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_adult_1, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_adult_1, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_adult_2)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_adult_2, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_adult_2, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_adult_3)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_adult_3, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_adult_3, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_adult_4)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_adult_4, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_adult_4, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_adult_5)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_adult_5, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_adult_5, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_adult_6)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_adult_6, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_adult_6, overall: $(max_value)")
        println(io, "")
        max_value = 0.0
        for i = 1:52
            corr = cor(incidence_arr_means[i, :], mean_viral_load_adult_7)
            if abs(corr) > abs(max_value)
                max_value = corr
            end
            println(io, "Mean_viral_load_adult_7, w$(i): $(corr)")
        end
        println(io, "Mean_viral_load_adult_7, overall: $(max_value)")
        println(io, "")
    end
end

# function plot_incidences()
#     duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
#     duration_parameter = mean(duration_parameter_array[burnin:step:length(duration_parameter_array)])

#     susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
#     susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
#     susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
#     susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
#     susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
#     susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
#     susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))

#     susceptibility_parameter_1_array = susceptibility_parameter_1_array[burnin:step:length(susceptibility_parameter_1_array)]
#     susceptibility_parameter_2_array = susceptibility_parameter_2_array[burnin:step:length(susceptibility_parameter_2_array)]
#     susceptibility_parameter_3_array = susceptibility_parameter_3_array[burnin:step:length(susceptibility_parameter_3_array)]
#     susceptibility_parameter_4_array = susceptibility_parameter_4_array[burnin:step:length(susceptibility_parameter_4_array)]
#     susceptibility_parameter_5_array = susceptibility_parameter_5_array[burnin:step:length(susceptibility_parameter_5_array)]
#     susceptibility_parameter_6_array = susceptibility_parameter_6_array[burnin:step:length(susceptibility_parameter_6_array)]
#     susceptibility_parameter_7_array = susceptibility_parameter_7_array[burnin:step:length(susceptibility_parameter_7_array)]

#     susceptibility_parameters = [
#         mean(susceptibility_parameter_1_array),
#         mean(susceptibility_parameter_2_array),
#         mean(susceptibility_parameter_3_array),
#         mean(susceptibility_parameter_4_array),
#         mean(susceptibility_parameter_5_array),
#         mean(susceptibility_parameter_6_array),
#         mean(susceptibility_parameter_7_array)]

#     temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
#     temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
#     temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
#     temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
#     temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
#     temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
#     temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))
 
#     temperature_parameter_1_array = temperature_parameter_1_array[burnin:step:length(temperature_parameter_1_array)]
#     temperature_parameter_2_array = temperature_parameter_2_array[burnin:step:length(temperature_parameter_2_array)]
#     temperature_parameter_3_array = temperature_parameter_3_array[burnin:step:length(temperature_parameter_3_array)]
#     temperature_parameter_4_array = temperature_parameter_4_array[burnin:step:length(temperature_parameter_4_array)]
#     temperature_parameter_5_array = temperature_parameter_5_array[burnin:step:length(temperature_parameter_5_array)]
#     temperature_parameter_6_array = temperature_parameter_6_array[burnin:step:length(temperature_parameter_6_array)]
#     temperature_parameter_7_array = temperature_parameter_7_array[burnin:step:length(temperature_parameter_7_array)]

#     temperature_parameters = [
#         mean(temperature_parameter_1_array),
#         mean(temperature_parameter_2_array),
#         mean(temperature_parameter_3_array),
#         mean(temperature_parameter_4_array),
#         mean(temperature_parameter_5_array),
#         mean(temperature_parameter_6_array),
#         mean(temperature_parameter_7_array)]

#     incidence = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data.csv"), ',', Float64)

#     d_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_d_-2.csv"), ',', Float64)
#     d_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_d_-1.csv"), ',', Float64)
#     d_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_d_1.csv"), ',', Float64)
#     d_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_d_2.csv"), ',', Float64)

#     s1_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s1_-2.csv"), ',', Float64)
#     s1_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s1_-1.csv"), ',', Float64)
#     s1_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s1_1.csv"), ',', Float64)
#     s1_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s1_2.csv"), ',', Float64)

#     s2_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s2_-2.csv"), ',', Float64)
#     s2_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s2_-1.csv"), ',', Float64)
#     s2_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s2_1.csv"), ',', Float64)
#     s2_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s2_2.csv"), ',', Float64)

#     s3_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s3_-2.csv"), ',', Float64)
#     s3_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s3_-1.csv"), ',', Float64)
#     s3_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s3_1.csv"), ',', Float64)
#     s3_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s3_2.csv"), ',', Float64)

#     s4_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s4_-2.csv"), ',', Float64)
#     s4_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s4_-1.csv"), ',', Float64)
#     s4_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s4_1.csv"), ',', Float64)
#     s4_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s4_2.csv"), ',', Float64)

#     s5_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s5_-2.csv"), ',', Float64)
#     s5_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s5_-1.csv"), ',', Float64)
#     s5_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s5_1.csv"), ',', Float64)
#     s5_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s5_2.csv"), ',', Float64)

#     s6_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s6_-2.csv"), ',', Float64)
#     s6_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s6_-1.csv"), ',', Float64)
#     s6_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s6_1.csv"), ',', Float64)
#     s6_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s6_2.csv"), ',', Float64)

#     s7_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s7_-2.csv"), ',', Float64)
#     s7_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s7_-1.csv"), ',', Float64)
#     s7_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s7_1.csv"), ',', Float64)
#     s7_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s7_2.csv"), ',', Float64)

#     t1_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t1_-2.csv"), ',', Float64)
#     t1_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t1_-1.csv"), ',', Float64)
#     t1_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t1_1.csv"), ',', Float64)
#     t1_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t1_2.csv"), ',', Float64)

#     t2_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t2_-2.csv"), ',', Float64)
#     t2_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t2_-1.csv"), ',', Float64)
#     t2_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t2_1.csv"), ',', Float64)
#     t2_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t2_2.csv"), ',', Float64)

#     t3_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t3_-2.csv"), ',', Float64)
#     t3_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t3_-1.csv"), ',', Float64)
#     t3_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t3_1.csv"), ',', Float64)
#     t3_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t3_2.csv"), ',', Float64)

#     t4_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t4_-2.csv"), ',', Float64)
#     t4_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t4_-1.csv"), ',', Float64)
#     t4_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t4_1.csv"), ',', Float64)
#     t4_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t4_2.csv"), ',', Float64)

#     t5_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t5_-2.csv"), ',', Float64)
#     t5_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t5_-1.csv"), ',', Float64)
#     t5_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t5_1.csv"), ',', Float64)
#     t5_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t5_2.csv"), ',', Float64)

#     t6_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t6_-2.csv"), ',', Float64)
#     t6_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t6_-1.csv"), ',', Float64)
#     t6_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t6_1.csv"), ',', Float64)
#     t6_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t6_2.csv"), ',', Float64)

#     t7_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t7_-2.csv"), ',', Float64)
#     t7_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t7_-1.csv"), ',', Float64)
#     t7_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t7_1.csv"), ',', Float64)
#     t7_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t7_2.csv"), ',', Float64)

#     # ticks = range(1, stop = 52, length = 13)
#     # ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
#     ticks = range(1, stop = 52, length = 7)
#     ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
#     yticks = [2, 6, 10, 14]
#     yticklabels = ["2", "6", "10", "14"]
#     incidence_plot = plot(
#         1:52,
#         [d_minus_2 d_minus_1 incidence d_1 d_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         yticks = (yticks, yticklabels),
#         legend = (0.91, 1.0),
#         ylims = (0, 17),
#         margin = 2Plots.mm,
#         label = ["$(round(duration_parameter * 0.8, digits = 2))" "$(round(duration_parameter * 0.9, digits = 2))" "$(round(duration_parameter, digits = 2))" "$(round(duration_parameter * 1.1, digits = 2))" "$(round(duration_parameter * 1.2, digits = 2))"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "d.pdf"))

#     incidence_plot = plot(
#         1:52,
#         [s1_minus_2 s1_minus_1 incidence s1_1 s1_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         margin = 2Plots.mm,
#         label = ["$(round(susceptibility_parameters[1] * 0.8, digits = 2))" "$(round(susceptibility_parameters[1] * 0.9, digits = 2))" "$(round(susceptibility_parameters[1], digits = 2))" "$(round(susceptibility_parameters[1] * 1.1, digits = 2))" "$(round(susceptibility_parameters[1] * 1.2, digits = 2))"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "s1.pdf"))

#     incidence_plot = plot(
#         1:52,
#         [s2_minus_2 s2_minus_1 incidence s2_1 s2_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         margin = 2Plots.mm,
#         label = ["$(round(susceptibility_parameters[2] * 0.8, digits = 2))" "$(round(susceptibility_parameters[2] * 0.9, digits = 2))" "$(round(susceptibility_parameters[2], digits = 2))" "$(round(susceptibility_parameters[2] * 1.1, digits = 2))" "$(round(susceptibility_parameters[2] * 1.2, digits = 2))"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "s2.pdf"))

#     incidence_plot = plot(
#         1:52,
#         [s3_minus_2 s3_minus_1 incidence s3_1 s3_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         margin = 2Plots.mm,
#         legend = (0.91, 0.95),
#         label = ["$(round(susceptibility_parameters[3] * 0.8, digits = 2))" "$(round(susceptibility_parameters[3] * 0.9, digits = 2))" "$(round(susceptibility_parameters[3], digits = 2))" "$(round(susceptibility_parameters[3] * 1.1, digits = 2))" "$(round(susceptibility_parameters[3] * 1.2, digits = 2))"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "s3.pdf"))

#     incidence_plot = plot(
#         1:52,
#         [s4_minus_2 s4_minus_1 incidence s4_1 s4_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         margin = 2Plots.mm,
#         legend = (0.85, 0.95),
#         label = ["$(round(susceptibility_parameters[4] * 0.8, digits = 2))" "$(round(susceptibility_parameters[4] * 0.9, digits = 2))" "$(round(susceptibility_parameters[4], digits = 2))" "$(round(susceptibility_parameters[4] * 1.1, digits = 2))" "$(round(susceptibility_parameters[4] * 1.2, digits = 2))"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "s4.pdf"))

#     incidence_plot = plot(
#         1:52,
#         [s5_minus_2 s5_minus_1 incidence s5_1 s5_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         margin = 2Plots.mm,
#         legend = (0.91, 1.0),
#         ylims = (0, 13),
#         label = ["$(round(susceptibility_parameters[5] * 0.8, digits = 2))" "$(round(susceptibility_parameters[5] * 0.9, digits = 2))" "$(round(susceptibility_parameters[5], digits = 2))" "$(round(susceptibility_parameters[5] * 1.1, digits = 2))" "$(round(susceptibility_parameters[5] * 1.2, digits = 2))"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "s5.pdf"))

#     incidence_plot = plot(
#         1:52,
#         [s6_minus_2 s6_minus_1 incidence s6_1 s6_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         margin = 2Plots.mm,
#         legend = (0.92, 0.98),
#         label = ["$(round(susceptibility_parameters[6] * 0.8, digits = 2))" "$(round(susceptibility_parameters[6] * 0.9, digits = 2))" "$(round(susceptibility_parameters[6], digits = 2))" "$(round(susceptibility_parameters[6] * 1.1, digits = 2))" "$(round(susceptibility_parameters[6] * 1.2, digits = 2))"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "s6.pdf"))

#     incidence_plot = plot(
#         1:52,
#         [s7_minus_2 s7_minus_1 incidence s7_1 s7_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         margin = 2Plots.mm,
#         legend = (0.91, 0.95),
#         label = ["$(round(susceptibility_parameters[7] * 0.8, digits = 2))" "$(round(susceptibility_parameters[7] * 0.9, digits = 2))" "$(round(susceptibility_parameters[7], digits = 2))" "$(round(susceptibility_parameters[7] * 1.1, digits = 2))" "$(round(susceptibility_parameters[7] * 1.2, digits = 2))"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "s7.pdf"))

#     incidence_plot = plot(
#         1:52,
#         [t1_minus_2 t1_minus_1 incidence t1_1 t1_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         margin = 2Plots.mm,
#         legend = (0.91, 0.95),
#         label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[1], digits = 2))" "$(0.75)" "$(1.0)"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "t1.pdf"))

#     incidence_plot = plot(
#         1:52,
#         [t2_minus_2 t2_minus_1 incidence t2_1 t2_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         margin = 2Plots.mm,
#         legend = (0.91, 0.95),
#         label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[2], digits = 2))" "$(0.75)" "$(1.0)"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "t2.pdf"))

#     incidence_plot = plot(
#         1:52,
#         [t3_minus_2 t3_minus_1 incidence t3_1 t3_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         margin = 2Plots.mm,
#         legend = (0.91, 0.95),
#         label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[3], digits = 2))" "$(0.75)" "$(1.0)"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "t3.pdf"))

#     incidence_plot = plot(
#         1:52,
#         [t4_minus_2 t4_minus_1 incidence t4_1 t4_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         margin = 2Plots.mm,
#         legend = (0.91, 0.95),
#         label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[4], digits = 2))" "$(0.75)" "$(1.0)"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "t4.pdf"))

#     incidence_plot = plot(
#         1:52,
#         [t5_minus_2 t5_minus_1 incidence t5_1 t5_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         margin = 2Plots.mm,
#         legend = (0.91, 0.95),
#         label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[5], digits = 2))" "$(0.75)" "$(1.0)"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "t5.pdf"))

#     incidence_plot = plot(
#         1:52,
#         [t6_minus_2 t6_minus_1 incidence t6_1 t6_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         margin = 2Plots.mm,
#         legend = (0.91, 0.95),
#         label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[6], digits = 2))" "$(0.75)" "$(1.0)"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "t6.pdf"))

#     incidence_plot = plot(
#         1:52,
#         [t7_minus_2 t7_minus_1 incidence t7_1 t7_2],
#         lw = 3,
#         xticks = (ticks, ticklabels),
#         margin = 2Plots.mm,
#         legend = (0.91, 0.95),
#         label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[7], digits = 2))" "$(0.75)" "$(1.0)"],
#         # xlabel = L"\textrm{\sffamily Month}",
#         # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
#         xlabel = "Month",
#         ylabel = "Cases per 1000 people",
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "t7.pdf"))
# end

plot_infection_curves()
