using DelimitedFiles
using Plots
using Statistics
using Distributions
using LaTeXStrings
using JLD

include("../../../server/lib/util/moving_avg.jl")
include("../../../server/lib/util/regression.jl")
include("../../../server/lib/data/etiology.jl")
include("../../../server/lib/global/variables.jl")

default(legendfontsize = 11, guidefont = (12, :black), tickfont = (11, :black))

const is_russian = false
const num_years = 2
const num_runs = 1

function confidence(x::Vector{Float64}, tstar::Float64 = 2.35)
    SE = std(x) / sqrt(length(x))
    return tstar * SE
end

function plot_work_contacts()
    num_connection_variants = 3
    minimum_conn_number = 4

    incidence_arr = Array{Vector{Float64}, 3}(undef, num_connection_variants, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, num_connection_variants, 52)

    for z = 1:num_connection_variants
        for i = 1:num_runs
            observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "contacts", "results_w_$(z + minimum_conn_number - 1).jld"))["incidence"] ./ 10072
            for j = 1:num_years
                incidence_arr[z, i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
            end
        end
    end

    for z = 1:num_connection_variants
        for i = 1:52
            for j = 1:num_years
                for k = 1:num_runs
                    incidence_arr_mean[z, i] += incidence_arr[z, k, j][i]
                end
            end
            incidence_arr_mean[z, i] /= num_runs * num_years
        end
    end

    sum_4 = sum(incidence_arr_mean[1, :])
    sum_5 = sum(incidence_arr_mean[2, :])
    sum_6 = sum(incidence_arr_mean[3, :])

    println("Work")
    println("Decrease in total number of cases for 4 compared to 5: $(1 - sum_4 / sum_5)")
    println("Increase in total number of cases for 6 compared to 5: $(sum_6 / sum_5 - 1)")

    maximum_4 = maximum(incidence_arr_mean[1, :])
    maximum_5 = maximum(incidence_arr_mean[2, :])
    maximum_6 = maximum(incidence_arr_mean[3, :])

    println("Decrease in max number of cases for 4 compared to 5: $(1 - maximum_4 / maximum_5)")
    println("Increase in max number of cases for 6 compared to 5: $(maximum_6 / maximum_5 - 1)")

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["m = 4" "m = 5" "m = 6"]

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
        [incidence_arr_mean[i, :] for i = 1:num_connection_variants],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = true,
        legend = (0.9, 0.98),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "contacts", "work_contacts_incidence.pdf"))

    rt_arr = Array{Vector{Float64}, 3}(undef, 4, num_runs, num_years)
    rt_arr_mean = zeros(Float64, num_connection_variants, 365)

    for z = 1:num_connection_variants
        for i = 1:num_runs
            rt = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "contacts", "results_w_$(z + minimum_conn_number - 1).jld"))["rt"]
            for j = 1:num_years
                rt_arr[z, i, j] = moving_average(rt, 20)[(365 * (j - 1) + 1):(365 * (j - 1) + 365)]
            end
        end
    end

    rt_arr_mean = zeros(Float64, num_connection_variants, 365)
    for l = 1:num_connection_variants
        for i = 1:365
            for j = 1:num_runs
                for z = 1:num_years
                    rt_arr_mean[l, i] += rt_arr[l, j, z][i]
                end
            end
            rt_arr_mean[l, i] /= num_runs * num_years
        end
    end

    ticks = range(1, stop = 365, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = L"R_t"
    
    yticks = [0.8, 1.0, 1.2, 1.4]
    yticklabels = ["0.8", "1.0", "1.2", "1.4"]

    rt_plot = plot(
        1:365,
        [rt_arr_mean[i, :] for i = 1:num_connection_variants],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        label = label_names,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2)],
        grid = true,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    savefig(
        rt_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "contacts", "work_contacts_rt.pdf"))
end

function plot_school_contacts()
    num_connection_variants = 4
    minimum_conn_number = 9

    incidence_arr = Array{Vector{Float64}, 3}(undef, num_connection_variants, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, num_connection_variants, 52)

    for z = 1:num_connection_variants
        for i = 1:num_runs
            observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "contacts", "results_s_$(z + minimum_conn_number - 1).jld"))["incidence"] ./ 10072
            for j = 1:num_years
                incidence_arr[z, i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
            end
        end
    end

    for z = 1:num_connection_variants
        for i = 1:52
            for j = 1:num_years
                for k = 1:num_runs
                    incidence_arr_mean[z, i] += incidence_arr[z, k, j][i]
                end
            end
            incidence_arr_mean[z, i] /= num_runs * num_years
        end
    end

    println("School")

    sum_9 = sum(incidence_arr_mean[1, :])
    sum_10 = sum(incidence_arr_mean[2, :])
    sum_11 = sum(incidence_arr_mean[3, :])
    sum_max = sum(incidence_arr_mean[4, :])

    println("Decrease in total number of cases for 9 compared to 10: $(1 - sum_9 / sum_10)")
    println("Increase in total number of cases for 11 compared to 10: $(sum_11 / sum_10 - 1)")
    println("Increase in total number of cases for max compared to 10: $(sum_max / sum_10 - 1)")

    maximum_9 = maximum(incidence_arr_mean[1, :])
    maximum_10 = maximum(incidence_arr_mean[2, :])
    maximum_11 = maximum(incidence_arr_mean[3, :])
    maximum_max = maximum(incidence_arr_mean[4, :])

    println("Decrease in max number of cases for 9 compared to 10: $(1 - maximum_9 / maximum_10)")
    println("Increase in max number of cases for 11 compared to 10: $(maximum_11 / maximum_10 - 1)")
    println("Increase in max number of cases for max compared to 10: $(maximum_max / maximum_10 - 1)")

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["m = 9" "m = 10" "m = 11" "m = max"]

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
        [incidence_arr_mean[i, :] for i = 1:num_connection_variants],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = true,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "contacts", "school_contacts_incidence.pdf"))

    rt_arr = Array{Vector{Float64}, 3}(undef, num_connection_variants, num_runs, num_years)
    rt_arr_mean = zeros(Float64, num_connection_variants, 365)

    for z = 1:num_connection_variants
        for i = 1:num_runs
            rt = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "contacts", "results_s_$(z + minimum_conn_number - 1).jld"))["rt"]
            for j = 1:num_years
                rt_arr[z, i, j] = moving_average(rt, 20)[(365 * (j - 1) + 1):(365 * (j - 1) + 365)]
            end
        end
    end

    rt_arr_mean = zeros(Float64, num_connection_variants, 365)
    for l = 1:num_connection_variants
        for i = 1:365
            for j = 1:num_runs
                for z = 1:num_years
                    rt_arr_mean[l, i] += rt_arr[l, j, z][i]
                end
            end
            rt_arr_mean[l, i] /= num_runs * num_years
        end
    end

    ticks = range(1, stop = 365, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = L"R_t"
    
    yticks = [0.8, 1.0, 1.2, 1.4]
    yticklabels = ["0.8", "1.0", "1.2", "1.4"]

    rt_plot = plot(
        1:365,
        [rt_arr_mean[i, :] for i = 1:num_connection_variants],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        label = label_names,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467)],
        grid = true,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    savefig(
        rt_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "contacts", "school_contacts_rt.pdf"))
end

function plot_infection_curves()
    num_runs_global_sensitivity = 500

    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs_global_sensitivity, num_years)
    incidence_arr_means = zeros(Float64, 52, num_runs_global_sensitivity)

    isolation_probability_day_1_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    isolation_probability_day_1_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    isolation_probability_day_1_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    isolation_probability_day_1_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    isolation_probability_day_2_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    isolation_probability_day_2_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    isolation_probability_day_2_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    isolation_probability_day_2_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    isolation_probability_day_3_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    isolation_probability_day_3_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    isolation_probability_day_3_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    isolation_probability_day_3_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    recovered_duration_mean = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    recovered_duration_sd = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    mean_household_contact_duration_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_household_contact_duration_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_household_contact_duration_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_household_contact_duration_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_household_contact_duration_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    household_contact_duration_sd_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    household_contact_duration_sd_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    household_contact_duration_sd_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    household_contact_duration_sd_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    household_contact_duration_sd_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    other_contact_duration_shape_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    other_contact_duration_shape_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    other_contact_duration_shape_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    other_contact_duration_shape_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    other_contact_duration_shape_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    other_contact_duration_scale_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    other_contact_duration_scale_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    other_contact_duration_scale_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    other_contact_duration_scale_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    other_contact_duration_scale_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    duration_parameter = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    susceptibility_parameter_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    susceptibility_parameter_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    susceptibility_parameter_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    susceptibility_parameter_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    susceptibility_parameter_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    susceptibility_parameter_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    susceptibility_parameter_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    temperature_parameter_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    temperature_parameter_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    temperature_parameter_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    temperature_parameter_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    temperature_parameter_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    temperature_parameter_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    temperature_parameter_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    random_infection_probability_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    random_infection_probability_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    random_infection_probability_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    random_infection_probability_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    mean_immunity_duration_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_immunity_duration_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_immunity_duration_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_immunity_duration_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_immunity_duration_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_immunity_duration_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_immunity_duration_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    incubation_period_duration_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    incubation_period_duration_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    incubation_period_duration_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    incubation_period_duration_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    incubation_period_duration_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    incubation_period_duration_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    incubation_period_duration_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    incubation_period_duration_variance_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    incubation_period_duration_variance_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    incubation_period_duration_variance_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    incubation_period_duration_variance_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    incubation_period_duration_variance_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    incubation_period_duration_variance_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    incubation_period_duration_variance_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    infection_period_duration_child_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_child_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_child_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_child_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_child_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_child_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_child_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    infection_period_duration_variance_child_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_variance_child_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_variance_child_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_variance_child_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_variance_child_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_variance_child_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_variance_child_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    infection_period_duration_adult_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_adult_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_adult_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_adult_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_adult_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_adult_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_adult_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    infection_period_duration_variance_adult_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_variance_adult_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_variance_adult_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_variance_adult_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_variance_adult_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_variance_adult_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    infection_period_duration_variance_adult_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    symptomatic_probability_child_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_child_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_child_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_child_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_child_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_child_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_child_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    symptomatic_probability_teenager_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_teenager_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_teenager_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_teenager_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_teenager_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_teenager_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_teenager_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    symptomatic_probability_adult_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_adult_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_adult_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_adult_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_adult_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_adult_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    symptomatic_probability_adult_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    mean_viral_load_infant_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_infant_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_infant_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_infant_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_infant_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_infant_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_infant_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    mean_viral_load_child_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_child_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_child_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_child_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_child_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_child_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_child_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    # mean_viral_loads_adult = Array{Vector{Float64}, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_adult_1 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_adult_2 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_adult_3 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_adult_4 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_adult_5 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_adult_6 = Array{Float64, 1}(undef, num_runs_global_sensitivity)
    mean_viral_load_adult_7 = Array{Float64, 1}(undef, num_runs_global_sensitivity)

    for i = 1:num_runs_global_sensitivity
        println("Run: $(i)")
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incidence"] ./ 10072
        for k = 1:num_years
            incidence_arr[i, k] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[(52 * (k - 1) + 1):(52 * (k - 1) + 52), :, 1], dims = 2)[:, 1]
        end

        isolation_probability_day_1_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["isolation_probabilities_day_1"][1]
        isolation_probability_day_1_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["isolation_probabilities_day_1"][2]
        isolation_probability_day_1_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["isolation_probabilities_day_1"][3]
        isolation_probability_day_1_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["isolation_probabilities_day_1"][4]
        
        isolation_probability_day_2_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["isolation_probabilities_day_2"][1]
        isolation_probability_day_2_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["isolation_probabilities_day_2"][2]
        isolation_probability_day_2_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["isolation_probabilities_day_2"][3]
        isolation_probability_day_2_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["isolation_probabilities_day_2"][4]
        
        isolation_probability_day_3_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["isolation_probabilities_day_3"][1]
        isolation_probability_day_3_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["isolation_probabilities_day_3"][2]
        isolation_probability_day_3_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["isolation_probabilities_day_3"][3]
        isolation_probability_day_3_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["isolation_probabilities_day_3"][4]

        recovered_duration_mean[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["recovered_duration_mean"]
        recovered_duration_sd[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["recovered_duration_sd"]
        
        mean_household_contact_duration_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_household_contact_durations"][1]
        mean_household_contact_duration_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_household_contact_durations"][2]
        mean_household_contact_duration_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_household_contact_durations"][3]
        mean_household_contact_duration_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_household_contact_durations"][4]
        mean_household_contact_duration_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_household_contact_durations"][5]
        
        household_contact_duration_sd_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["household_contact_duration_sds"][1]
        household_contact_duration_sd_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["household_contact_duration_sds"][2]
        household_contact_duration_sd_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["household_contact_duration_sds"][3]
        household_contact_duration_sd_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["household_contact_duration_sds"][4]
        household_contact_duration_sd_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["household_contact_duration_sds"][5]
        
        other_contact_duration_shape_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["other_contact_duration_shapes"][1]
        other_contact_duration_shape_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["other_contact_duration_shapes"][2]
        other_contact_duration_shape_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["other_contact_duration_shapes"][3]
        other_contact_duration_shape_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["other_contact_duration_shapes"][4]
        other_contact_duration_shape_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["other_contact_duration_shapes"][5]
        
        other_contact_duration_scale_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["other_contact_duration_scales"][1]
        other_contact_duration_scale_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["other_contact_duration_scales"][2]
        other_contact_duration_scale_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["other_contact_duration_scales"][3]
        other_contact_duration_scale_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["other_contact_duration_scales"][4]
        other_contact_duration_scale_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["other_contact_duration_scales"][5]
        
        duration_parameter[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["duration_parameter"]
        
        susceptibility_parameter_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["susceptibility_parameters"][1]
        susceptibility_parameter_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["susceptibility_parameters"][2]
        susceptibility_parameter_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["susceptibility_parameters"][3]
        susceptibility_parameter_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["susceptibility_parameters"][4]
        susceptibility_parameter_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["susceptibility_parameters"][5]
        susceptibility_parameter_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["susceptibility_parameters"][6]
        susceptibility_parameter_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["susceptibility_parameters"][7]
        
        temperature_parameter_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["temperature_parameters"][1]
        temperature_parameter_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["temperature_parameters"][2]
        temperature_parameter_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["temperature_parameters"][3]
        temperature_parameter_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["temperature_parameters"][4]
        temperature_parameter_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["temperature_parameters"][5]
        temperature_parameter_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["temperature_parameters"][6]
        temperature_parameter_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["temperature_parameters"][7]
        
        random_infection_probability_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["random_infection_probabilities"][1]
        random_infection_probability_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["random_infection_probabilities"][2]
        random_infection_probability_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["random_infection_probabilities"][3]
        random_infection_probability_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["random_infection_probabilities"][4]
        
        mean_immunity_duration_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_immunity_durations"][1]
        mean_immunity_duration_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_immunity_durations"][2]
        mean_immunity_duration_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_immunity_durations"][3]
        mean_immunity_duration_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_immunity_durations"][4]
        mean_immunity_duration_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_immunity_durations"][5]
        mean_immunity_duration_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_immunity_durations"][6]
        mean_immunity_duration_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_immunity_durations"][7]
        
        incubation_period_duration_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incubation_period_durations"][1]
        incubation_period_duration_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incubation_period_durations"][2]
        incubation_period_duration_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incubation_period_durations"][3]
        incubation_period_duration_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incubation_period_durations"][4]
        incubation_period_duration_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incubation_period_durations"][5]
        incubation_period_duration_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incubation_period_durations"][6]
        incubation_period_duration_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incubation_period_durations"][7]
        
        incubation_period_duration_variance_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incubation_period_duration_variances"][1]
        incubation_period_duration_variance_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incubation_period_duration_variances"][2]
        incubation_period_duration_variance_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incubation_period_duration_variances"][3]
        incubation_period_duration_variance_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incubation_period_duration_variances"][4]
        incubation_period_duration_variance_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incubation_period_duration_variances"][5]
        incubation_period_duration_variance_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incubation_period_duration_variances"][6]
        incubation_period_duration_variance_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incubation_period_duration_variances"][7]
        
        infection_period_duration_child_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_durations_child"][1]
        infection_period_duration_child_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_durations_child"][2]
        infection_period_duration_child_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_durations_child"][3]
        infection_period_duration_child_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_durations_child"][4]
        infection_period_duration_child_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_durations_child"][5]
        infection_period_duration_child_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_durations_child"][6]
        infection_period_duration_child_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_durations_child"][7]
        
        infection_period_duration_variance_child_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_duration_variances_child"][1]
        infection_period_duration_variance_child_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_duration_variances_child"][2]
        infection_period_duration_variance_child_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_duration_variances_child"][3]
        infection_period_duration_variance_child_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_duration_variances_child"][4]
        infection_period_duration_variance_child_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_duration_variances_child"][5]
        infection_period_duration_variance_child_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_duration_variances_child"][6]
        infection_period_duration_variance_child_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_duration_variances_child"][7]
        
        infection_period_duration_adult_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_durations_adult"][1]
        infection_period_duration_adult_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_durations_adult"][2]
        infection_period_duration_adult_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_durations_adult"][3]
        infection_period_duration_adult_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_durations_adult"][4]
        infection_period_duration_adult_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_durations_adult"][5]
        infection_period_duration_adult_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_durations_adult"][6]
        infection_period_duration_adult_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_durations_adult"][7]
        
        infection_period_duration_variance_adult_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_duration_variances_adult"][1]
        infection_period_duration_variance_adult_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_duration_variances_adult"][2]
        infection_period_duration_variance_adult_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_duration_variances_adult"][3]
        infection_period_duration_variance_adult_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_duration_variances_adult"][4]
        infection_period_duration_variance_adult_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_duration_variances_adult"][5]
        infection_period_duration_variance_adult_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_duration_variances_adult"][6]
        infection_period_duration_variance_adult_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["infection_period_duration_variances_adult"][7]

        symptomatic_probability_child_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_child"][1]
        symptomatic_probability_child_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_child"][2]
        symptomatic_probability_child_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_child"][3]
        symptomatic_probability_child_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_child"][4]
        symptomatic_probability_child_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_child"][5]
        symptomatic_probability_child_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_child"][6]
        symptomatic_probability_child_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_child"][7]
        
        symptomatic_probability_teenager_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_teenager"][1]
        symptomatic_probability_teenager_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_teenager"][2]
        symptomatic_probability_teenager_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_teenager"][3]
        symptomatic_probability_teenager_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_teenager"][4]
        symptomatic_probability_teenager_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_teenager"][5]
        symptomatic_probability_teenager_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_teenager"][6]
        symptomatic_probability_teenager_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_teenager"][7]
        
        symptomatic_probability_adult_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_adult"][1]
        symptomatic_probability_adult_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_adult"][2]
        symptomatic_probability_adult_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_adult"][3]
        symptomatic_probability_adult_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_adult"][4]
        symptomatic_probability_adult_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_adult"][5]
        symptomatic_probability_adult_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_adult"][6]
        symptomatic_probability_adult_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["symptomatic_probabilities_adult"][7]
        
        mean_viral_load_infant_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_infant"][1]
        mean_viral_load_infant_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_infant"][2]
        mean_viral_load_infant_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_infant"][3]
        mean_viral_load_infant_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_infant"][4]
        mean_viral_load_infant_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_infant"][5]
        mean_viral_load_infant_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_infant"][6]
        mean_viral_load_infant_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_infant"][7]
        
        mean_viral_load_child_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_child"][1]
        mean_viral_load_child_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_child"][2]
        mean_viral_load_child_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_child"][3]
        mean_viral_load_child_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_child"][4]
        mean_viral_load_child_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_child"][5]
        mean_viral_load_child_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_child"][6]
        mean_viral_load_child_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_child"][7]
        
        mean_viral_load_adult_1[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_adult"][1]
        mean_viral_load_adult_2[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_adult"][2]
        mean_viral_load_adult_3[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_adult"][3]
        mean_viral_load_adult_4[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_adult"][4]
        mean_viral_load_adult_5[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_adult"][5]
        mean_viral_load_adult_6[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_adult"][6]
        mean_viral_load_adult_7[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["mean_viral_loads_adult"][7]
    end

    for i = 1:52
        for j = 1:num_runs_global_sensitivity
            for k = 1:num_years
                incidence_arr_means[i, j] += incidence_arr[j, k][i]
            end
            incidence_arr_means[i, j] /= num_years
        end
    end

    incidence_arr = Array{Matrix{Float64}, 1}(undef, num_runs_global_sensitivity)
    incidence_arr_mean = zeros(Float64, (52 * num_years), 4)

    for i = 1:num_runs_global_sensitivity
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "results_$(i).jld"))["incidence"]
        incidence_arr[i] = sum(observed_num_infected_age_groups_viruses, dims = 2)[1:(52 * num_years), 1, :]
    end

    incidence_arr_mean_age_groups = zeros(Float64, (52 * num_years), 4, num_runs_global_sensitivity)
    for i = 1:(52 * num_years)
        for k = 1:4
            for j = 1:num_runs_global_sensitivity
                incidence_arr_mean_age_groups[i, k, j] = incidence_arr[j][i, k]
            end
        end
    end

    ticks = range(1, stop = (52.14285 * num_years), length = 13)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
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
        # 1:(52 * num_years),
        1:52,
        [incidence_arr_means[:, i] for i = 1:num_runs_global_sensitivity],
        lw = 1,
        xticks = (ticks, ticklabels),
        legend = false,
        grid = true,
        xrotation = 45,
        margin = 6Plots.mm,
        size = (800, 500),
        color = [:grey for i = 1:num_runs_global_sensitivity],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "incidence.pdf"))

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

    num_params = 11

    println("First peak")
    y = incidence_arr_means[10, :]
    @time param_ids = stepwise_regression(X, y, num_params)
    println(params_arr[param_ids])
    open("parameters/importance.txt", "a") do io
        println(io, params_arr[param_ids])
        println(io)
    end

    println("Second peak")
    y = incidence_arr_means[13, :]
    @time param_ids = stepwise_regression(X, y, num_params)
    println(params_arr[param_ids])
    open("parameters/importance.txt", "a") do io
        println(io, params_arr[param_ids])
        println(io)
    end

    println("Third peak")
    y = incidence_arr_means[19, :]
    @time param_ids = stepwise_regression(X, y, num_params)
    println(params_arr[param_ids])
    open("parameters/importance.txt", "a") do io
        println(io, params_arr[param_ids])
        println(io)
    end

    println("Fourth peak")
    y = incidence_arr_means[21, :]
    @time param_ids = stepwise_regression(X, y, num_params)
    println(params_arr[param_ids])
    open("parameters/importance.txt", "a") do io
        println(io, params_arr[param_ids])
        println(io)
    end

    println("Max")
    y = incidence_arr_means[27, :]
    @time param_ids = stepwise_regression(X, y, num_params)
    println(params_arr[param_ids])
    open("parameters/importance.txt", "a") do io
        println(io, params_arr[param_ids])
        println(io)
    end

    println("Sum")
    y = sum(incidence_arr_means, dims = 1)[1, :]
    @time param_ids = stepwise_regression(X, y, num_params)
    println(params_arr[param_ids])
    open("parameters/importance.txt", "a") do io
        println(io, params_arr[param_ids])
        println(io)
    end
end

function plot_incidences()
    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
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

    duration_parameter = 0.22637404671777045
    susceptibility_parameters = [3.095038052808992, 3.0554159364150997, 3.621467164928697, 4.612459518531132, 3.9086201477859595, 3.9490870441188344, 4.61599824854622]
    temperature_parameters = -[0.8846019152491571, 0.9313057237697472, 0.04837343942226003, 0.13610826071131651, 0.048281056835923, 0.07401637656561208, 0.36034078438752476]
    mean_immunity_durations = [358.53571508348136, 326.40686999692815, 128.36635586863198, 86.9285869152992, 110.11396877548141, 166.57369789857893, 153.80184097804894]
    random_infection_probabilities = [0.0013742087365687383, 0.0007810400878682918, 0.00039431021797935243, 9.16649170205853e-6]

    d_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_d_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                d_minus_2[j] += d_minus_2[52 * (i - 1) + j]
            end
        end
    end
    d_minus_2 = d_minus_2[1:52] ./ num_years

    d_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_d_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                d_minus_1[j] += d_minus_1[52 * (i - 1) + j]
            end
        end
    end
    d_minus_1 = d_minus_1[1:52] ./ num_years

    d_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_d_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                d_1[j] += d_1[52 * (i - 1) + j]
            end
        end
    end
    d_1 = d_1[1:52] ./ num_years

    d_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_d_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                d_2[j] += d_2[52 * (i - 1) + j]
            end
        end
    end
    d_2 = d_2[1:52] ./ num_years

    s1_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s1_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s1_minus_2[j] += s1_minus_2[52 * (i - 1) + j]
            end
        end
    end
    s1_minus_2 = s1_minus_2[1:52] ./ num_years
    
    s1_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s1_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s1_minus_1[j] += s1_minus_1[52 * (i - 1) + j]
            end
        end
    end
    s1_minus_1 = s1_minus_1[1:52] ./ num_years

    s1_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s1_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s1_1[j] += s1_1[52 * (i - 1) + j]
            end
        end
    end
    s1_1 = s1_1[1:52] ./ num_years
    
    s1_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s1_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s1_2[j] += s1_2[52 * (i - 1) + j]
            end
        end
    end
    s1_2 = s1_2[1:52] ./ num_years

    s2_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s2_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s2_minus_2[j] += s2_minus_2[52 * (i - 1) + j]
            end
        end
    end
    s2_minus_2 = s2_minus_2[1:52] ./ num_years
    
    s2_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s2_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s2_minus_1[j] += s2_minus_1[52 * (i - 1) + j]
            end
        end
    end
    s2_minus_1 = s2_minus_1[1:52] ./ num_years
    
    s2_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s2_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s2_1[j] += s2_1[52 * (i - 1) + j]
            end
        end
    end
    s2_1 = s2_1[1:52] ./ num_years
    
    s2_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s2_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s2_2[j] += s2_2[52 * (i - 1) + j]
            end
        end
    end
    s2_2 = s2_2[1:52] ./ num_years

    s3_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s3_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s3_minus_2[j] += s3_minus_2[52 * (i - 1) + j]
            end
        end
    end
    s3_minus_2 = s3_minus_2[1:52] ./ num_years
    
    s3_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s3_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s3_minus_1[j] += s3_minus_1[52 * (i - 1) + j]
            end
        end
    end
    s3_minus_1 = s3_minus_1[1:52] ./ num_years
    
    s3_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s3_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s3_1[j] += s3_1[52 * (i - 1) + j]
            end
        end
    end
    s3_1 = s3_1[1:52] ./ num_years
    
    s3_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s3_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s3_2[j] += s3_2[52 * (i - 1) + j]
            end
        end
    end
    s3_2 = s3_2[1:52] ./ num_years

    s4_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s4_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s4_minus_2[j] += s4_minus_2[52 * (i - 1) + j]
            end
        end
    end
    s4_minus_2 = s4_minus_2[1:52] ./ num_years
    
    s4_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s4_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s4_minus_1[j] += s4_minus_1[52 * (i - 1) + j]
            end
        end
    end
    s4_minus_1 = s4_minus_1[1:52] ./ num_years
    
    s4_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s4_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s4_1[j] += s4_1[52 * (i - 1) + j]
            end
        end
    end
    s4_1 = s4_1[1:52] ./ num_years
    
    s4_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s4_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s4_2[j] += s4_2[52 * (i - 1) + j]
            end
        end
    end
    s4_2 = s4_2[1:52] ./ num_years

    s5_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s5_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s5_minus_2[j] += s5_minus_2[52 * (i - 1) + j]
            end
        end
    end
    s5_minus_2 = s5_minus_2[1:52] ./ num_years
    
    s5_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s5_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s5_minus_1[j] += s5_minus_1[52 * (i - 1) + j]
            end
        end
    end
    s5_minus_1 = s5_minus_1[1:52] ./ num_years
    
    s5_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s5_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s5_1[j] += s5_1[52 * (i - 1) + j]
            end
        end
    end
    s5_1 = s5_1[1:52] ./ num_years
    
    s5_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s5_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s5_2[j] += s5_2[52 * (i - 1) + j]
            end
        end
    end
    s5_2 = s5_2[1:52] ./ num_years

    s6_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s6_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s6_minus_2[j] += s6_minus_2[52 * (i - 1) + j]
            end
        end
    end
    s6_minus_2 = s6_minus_2[1:52] ./ num_years

    s6_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s6_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s6_minus_1[j] += s6_minus_1[52 * (i - 1) + j]
            end
        end
    end
    s6_minus_1 = s6_minus_1[1:52] ./ num_years
    
    s6_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s6_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s6_1[j] += s6_1[52 * (i - 1) + j]
            end
        end
    end
    s6_1 = s6_1[1:52] ./ num_years
    
    s6_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s6_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s6_2[j] += s6_2[52 * (i - 1) + j]
            end
        end
    end
    s6_2 = s6_2[1:52] ./ num_years

    s7_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s7_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s7_minus_2[j] += s7_minus_2[52 * (i - 1) + j]
            end
        end
    end
    s7_minus_2 = s7_minus_2[1:52] ./ num_years
    
    s7_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s7_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s7_minus_1[j] += s7_minus_1[52 * (i - 1) + j]
            end
        end
    end
    s7_minus_1 = s7_minus_1[1:52] ./ num_years
    
    s7_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s7_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s7_1[j] += s7_1[52 * (i - 1) + j]
            end
        end
    end
    s7_1 = s7_1[1:52] ./ num_years
    
    s7_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_s7_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                s7_2[j] += s7_2[52 * (i - 1) + j]
            end
        end
    end
    s7_2 = s7_2[1:52] ./ num_years

    t1_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t1_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t1_minus_2[j] += t1_minus_2[52 * (i - 1) + j]
            end
        end
    end
    t1_minus_2 = t1_minus_2[1:52] ./ num_years
    
    t1_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t1_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t1_minus_1[j] += t1_minus_1[52 * (i - 1) + j]
            end
        end
    end
    t1_minus_1 = t1_minus_1[1:52] ./ num_years
    
    t1_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t1_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t1_1[j] += t1_1[52 * (i - 1) + j]
            end
        end
    end
    t1_1 = t1_1[1:52] ./ num_years
    
    t1_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t1_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t1_2[j] += t1_2[52 * (i - 1) + j]
            end
        end
    end
    t1_2 = t1_2[1:52] ./ num_years

    t2_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t2_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t2_minus_2[j] += t2_minus_2[52 * (i - 1) + j]
            end
        end
    end
    t2_minus_2 = t2_minus_2[1:52] ./ num_years
    
    t2_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t2_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t2_minus_1[j] += t2_minus_1[52 * (i - 1) + j]
            end
        end
    end
    t2_minus_1 = t2_minus_1[1:52] ./ num_years
    
    t2_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t2_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t2_1[j] += t2_1[52 * (i - 1) + j]
            end
        end
    end
    t2_1 = t2_1[1:52] ./ num_years
    
    t2_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t2_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t2_2[j] += t2_2[52 * (i - 1) + j]
            end
        end
    end
    t2_2 = t2_2[1:52] ./ num_years

    t3_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t3_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t3_minus_2[j] += t3_minus_2[52 * (i - 1) + j]
            end
        end
    end
    t3_minus_2 = t3_minus_2[1:52] ./ num_years
    
    t3_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t3_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t3_minus_1[j] += t3_minus_1[52 * (i - 1) + j]
            end
        end
    end
    t3_minus_1 = t3_minus_1[1:52] ./ num_years
    
    t3_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t3_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t3_1[j] += t3_1[52 * (i - 1) + j]
            end
        end
    end
    t3_1 = t3_1[1:52] ./ num_years
    
    t3_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t3_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t3_2[j] += t3_2[52 * (i - 1) + j]
            end
        end
    end
    t3_2 = t3_2[1:52] ./ num_years

    t4_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t4_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t4_minus_2[j] += t4_minus_2[52 * (i - 1) + j]
            end
        end
    end
    t4_minus_2 = t4_minus_2[1:52] ./ num_years
    
    t4_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t4_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t4_minus_1[j] += t4_minus_1[52 * (i - 1) + j]
            end
        end
    end
    t4_minus_1 = t4_minus_1[1:52] ./ num_years
    
    t4_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t4_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t4_1[j] += t4_1[52 * (i - 1) + j]
            end
        end
    end
    t4_1 = t4_1[1:52] ./ num_years
    
    t4_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t4_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t4_2[j] += t4_2[52 * (i - 1) + j]
            end
        end
    end
    t4_2 = t4_2[1:52] ./ num_years

    t5_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t5_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t5_minus_2[j] += t5_minus_2[52 * (i - 1) + j]
            end
        end
    end
    t5_minus_2 = t5_minus_2[1:52] ./ num_years
    
    t5_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t5_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t5_minus_1[j] += t5_minus_1[52 * (i - 1) + j]
            end
        end
    end
    t5_minus_1 = t5_minus_1[1:52] ./ num_years
    
    t5_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t5_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t5_1[j] += t5_1[52 * (i - 1) + j]
            end
        end
    end
    t5_1 = t5_1[1:52] ./ num_years
    
    t5_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t5_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t5_2[j] += t5_2[52 * (i - 1) + j]
            end
        end
    end
    t5_2 = t5_2[1:52] ./ num_years

    t6_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t6_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t6_minus_2[j] += t6_minus_2[52 * (i - 1) + j]
            end
        end
    end
    t6_minus_2 = t6_minus_2[1:52] ./ num_years
    
    t6_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t6_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t6_minus_1[j] += t6_minus_1[52 * (i - 1) + j]
            end
        end
    end
    t6_minus_1 = t6_minus_1[1:52] ./ num_years
    
    t6_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t6_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t6_1[j] += t6_1[52 * (i - 1) + j]
            end
        end
    end
    t6_1 = t6_1[1:52] ./ num_years
    
    t6_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t6_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t6_2[j] += t6_2[52 * (i - 1) + j]
            end
        end
    end
    t6_2 = t6_2[1:52] ./ num_years

    t7_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t7_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t7_minus_2[j] += t7_minus_2[52 * (i - 1) + j]
            end
        end
    end
    t7_minus_2 = t7_minus_2[1:52] ./ num_years
    
    t7_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t7_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t7_minus_1[j] += t7_minus_1[52 * (i - 1) + j]
            end
        end
    end
    t7_minus_1 = t7_minus_1[1:52] ./ num_years
    
    t7_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t7_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t7_1[j] += t7_1[52 * (i - 1) + j]
            end
        end
    end
    t7_1 = t7_1[1:52] ./ num_years
    
    t7_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_t7_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                t7_2[j] += t7_2[52 * (i - 1) + j]
            end
        end
    end
    t7_2 = t7_2[1:52] ./ num_years

    p1_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p1_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p1_minus_2[j] += p1_minus_2[52 * (i - 1) + j]
            end
        end
    end
    p1_minus_2 = p1_minus_2[1:52] ./ num_years
    
    p1_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p1_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p1_minus_1[j] += p1_minus_1[52 * (i - 1) + j]
            end
        end
    end
    p1_minus_1 = p1_minus_1[1:52] ./ num_years
    
    p1_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p1_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p1_1[j] += p1_1[52 * (i - 1) + j]
            end
        end
    end
    p1_1 = p1_1[1:52] ./ num_years
    
    p1_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p1_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p1_2[j] += p1_2[52 * (i - 1) + j]
            end
        end
    end
    p1_2 = p1_2[1:52] ./ num_years

    p2_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p2_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p2_minus_2[j] += p2_minus_2[52 * (i - 1) + j]
            end
        end
    end
    p2_minus_2 = p2_minus_2[1:52] ./ num_years
    
    p2_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p2_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p2_minus_1[j] += p2_minus_1[52 * (i - 1) + j]
            end
        end
    end
    p2_minus_1 = p2_minus_1[1:52] ./ num_years
    
    p2_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p2_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p2_1[j] += p2_1[52 * (i - 1) + j]
            end
        end
    end
    p2_1 = p2_1[1:52] ./ num_years
    
    p2_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p2_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p2_2[j] += p2_2[52 * (i - 1) + j]
            end
        end
    end
    p2_2 = p2_2[1:52] ./ num_years

    p3_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p3_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p3_minus_2[j] += p3_minus_2[52 * (i - 1) + j]
            end
        end
    end
    p3_minus_2 = p3_minus_2[1:52] ./ num_years
    
    p3_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p3_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p3_minus_1[j] += p3_minus_1[52 * (i - 1) + j]
            end
        end
    end
    p3_minus_1 = p3_minus_1[1:52] ./ num_years
    
    p3_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p3_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p3_1[j] += p3_1[52 * (i - 1) + j]
            end
        end
    end
    p3_1 = p3_1[1:52] ./ num_years
    
    p3_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p3_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p3_2[j] += p3_2[52 * (i - 1) + j]
            end
        end
    end
    p3_2 = p3_2[1:52] ./ num_years
    
    p4_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p4_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p4_minus_2[j] += p4_minus_2[52 * (i - 1) + j]
            end
        end
    end
    p4_minus_2 = p4_minus_2[1:52] ./ num_years
    
    p4_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p4_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p4_minus_1[j] += p4_minus_1[52 * (i - 1) + j]
            end
        end
    end
    p4_minus_1 = p4_minus_1[1:52] ./ num_years
    
    p4_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p4_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p4_1[j] += p4_1[52 * (i - 1) + j]
            end
        end
    end
    p4_1 = p4_1[1:52] ./ num_years
    
    p4_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_p4_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                p4_2[j] += p4_2[52 * (i - 1) + j]
            end
        end
    end
    p4_2 = p4_2[1:52] ./ num_years

    r1_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r1_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r1_minus_2[j] += r1_minus_2[52 * (i - 1) + j]
            end
        end
    end
    r1_minus_2 = r1_minus_2[1:52] ./ num_years
    
    r1_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r1_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r1_minus_1[j] += r1_minus_1[52 * (i - 1) + j]
            end
        end
    end
    r1_minus_1 = r1_minus_1[1:52] ./ num_years
    
    r1_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r1_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r1_1[j] += r1_1[52 * (i - 1) + j]
            end
        end
    end
    r1_1 = r1_1[1:52] ./ num_years
    
    r1_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r1_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r1_2[j] += r1_2[52 * (i - 1) + j]
            end
        end
    end
    r1_2 = r1_2[1:52] ./ num_years

    r2_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r2_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r2_minus_2[j] += r2_minus_2[52 * (i - 1) + j]
            end
        end
    end
    r2_minus_2 = r2_minus_2[1:52] ./ num_years
    
    r2_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r2_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r2_minus_1[j] += r2_minus_1[52 * (i - 1) + j]
            end
        end
    end
    r2_minus_1 = r2_minus_1[1:52] ./ num_years
    
    r2_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r2_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r2_1[j] += r2_1[52 * (i - 1) + j]
            end
        end
    end
    r2_1 = r2_1[1:52] ./ num_years
    
    r2_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r2_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r2_2[j] += r2_2[52 * (i - 1) + j]
            end
        end
    end
    r2_2 = r2_2[1:52] ./ num_years

    r3_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r3_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r3_minus_2[j] += r3_minus_2[52 * (i - 1) + j]
            end
        end
    end
    r3_minus_2 = r3_minus_2[1:52] ./ num_years
    
    r3_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r3_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r3_minus_1[j] += r3_minus_1[52 * (i - 1) + j]
            end
        end
    end
    r3_minus_1 = r3_minus_1[1:52] ./ num_years
    
    r3_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r3_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r3_1[j] += r3_1[52 * (i - 1) + j]
            end
        end
    end
    r3_1 = r3_1[1:52] ./ num_years
    
    r3_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r3_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r3_2[j] += r3_2[52 * (i - 1) + j]
            end
        end
    end
    r3_2 = r3_2[1:52] ./ num_years

    r4_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r4_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r4_minus_2[j] += r4_minus_2[52 * (i - 1) + j]
            end
        end
    end
    r4_minus_2 = r4_minus_2[1:52] ./ num_years
    
    r4_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r4_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r4_minus_1[j] += r4_minus_1[52 * (i - 1) + j]
            end
        end
    end
    r4_minus_1 = r4_minus_1[1:52] ./ num_years
    
    r4_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r4_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r4_1[j] += r4_1[52 * (i - 1) + j]
            end
        end
    end
    r4_1 = r4_1[1:52] ./ num_years
    
    r4_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r4_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r4_2[j] += r4_2[52 * (i - 1) + j]
            end
        end
    end
    r4_2 = r4_2[1:52] ./ num_years

    r5_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r5_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r5_minus_2[j] += r5_minus_2[52 * (i - 1) + j]
            end
        end
    end
    r5_minus_2 = r5_minus_2[1:52] ./ num_years
    
    r5_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r5_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r5_minus_1[j] += r5_minus_1[52 * (i - 1) + j]
            end
        end
    end
    r5_minus_1 = r5_minus_1[1:52] ./ num_years
    
    r5_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r5_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r5_1[j] += r5_1[52 * (i - 1) + j]
            end
        end
    end
    r5_1 = r5_1[1:52] ./ num_years
    
    r5_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r5_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r5_2[j] += r5_2[52 * (i - 1) + j]
            end
        end
    end
    r5_2 = r5_2[1:52] ./ num_years

    r6_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r6_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r6_minus_2[j] += r6_minus_2[52 * (i - 1) + j]
            end
        end
    end
    r6_minus_2 = r6_minus_2[1:52] ./ num_years
    
    r6_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r6_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r6_minus_1[j] += r6_minus_1[52 * (i - 1) + j]
            end
        end
    end
    r6_minus_1 = r6_minus_1[1:52] ./ num_years
    
    r6_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r6_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r6_1[j] += r6_1[52 * (i - 1) + j]
            end
        end
    end
    r6_1 = r6_1[1:52] ./ num_years
    
    r6_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r6_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r6_2[j] += r6_2[52 * (i - 1) + j]
            end
        end
    end
    r6_2 = r6_2[1:52] ./ num_years

    r7_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r7_-2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r7_minus_2[j] += r7_minus_2[52 * (i - 1) + j]
            end
        end
    end
    r7_minus_2 = r7_minus_2[1:52] ./ num_years
    
    r7_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r7_-1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r7_minus_1[j] += r7_minus_1[52 * (i - 1) + j]
            end
        end
    end
    r7_minus_1 = r7_minus_1[1:52] ./ num_years
    
    r7_1 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r7_1.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r7_1[j] += r7_1[52 * (i - 1) + j]
            end
        end
    end
    r7_1 = r7_1[1:52] ./ num_years
    
    r7_2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "sensitivity", "2nd", "infected_data_r7_2.csv"), ',', Float64) ./ 10072
    if num_years > 1
        for i = 2:num_years
            for j = 1:52
                r7_2[j] += r7_2[52 * (i - 1) + j]
            end
        end
    end
    r7_2 = r7_2[1:52] ./ num_years

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    yticks = [0, 4, 8, 12]
    yticklabels = ["0" "4" "8" "12"]

    label_names = ["model" "data"]
    if is_russian
        label_names = ["модель" "данные"]
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
        [d_minus_2 d_minus_1 incidence d_1 d_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        legend = (0.86, 1.0),
        margin = 2Plots.mm,
        label = ["d = $(round(duration_parameter * 0.8, digits = 2))" "d = $(round(duration_parameter * 0.9, digits = 2))" "d = $(round(duration_parameter, digits = 2))" "d = $(round(duration_parameter * 1.1, digits = 2))" "d = $(round(duration_parameter * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "d.pdf"))

    incidence_plot = plot(
        1:52,
        [s1_minus_2 s1_minus_1 incidence s1_1 s1_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        label = ["$(round(susceptibility_parameters[1] * 0.8, digits = 2))" "$(round(susceptibility_parameters[1] * 0.9, digits = 2))" "$(round(susceptibility_parameters[1], digits = 2))" "$(round(susceptibility_parameters[1] * 1.1, digits = 2))" "$(round(susceptibility_parameters[1] * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "s1.pdf"))

    incidence_plot = plot(
        1:52,
        [s2_minus_2 s2_minus_1 incidence s2_1 s2_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        label = ["$(round(susceptibility_parameters[2] * 0.8, digits = 2))" "$(round(susceptibility_parameters[2] * 0.9, digits = 2))" "$(round(susceptibility_parameters[2], digits = 2))" "$(round(susceptibility_parameters[2] * 1.1, digits = 2))" "$(round(susceptibility_parameters[2] * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "s2.pdf"))

    incidence_plot = plot(
        1:52,
        [s3_minus_2 s3_minus_1 incidence s3_1 s3_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(susceptibility_parameters[3] * 0.8, digits = 2))" "$(round(susceptibility_parameters[3] * 0.9, digits = 2))" "$(round(susceptibility_parameters[3], digits = 2))" "$(round(susceptibility_parameters[3] * 1.1, digits = 2))" "$(round(susceptibility_parameters[3] * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "s3.pdf"))

    incidence_plot = plot(
        1:52,
        [s4_minus_2 s4_minus_1 incidence s4_1 s4_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.85, 0.95),
        label = ["$(round(susceptibility_parameters[4] * 0.8, digits = 2))" "$(round(susceptibility_parameters[4] * 0.9, digits = 2))" "$(round(susceptibility_parameters[4], digits = 2))" "$(round(susceptibility_parameters[4] * 1.1, digits = 2))" "$(round(susceptibility_parameters[4] * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "s4.pdf"))

    incidence_plot = plot(
        1:52,
        [s5_minus_2 s5_minus_1 incidence s5_1 s5_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 1.0),
        label = ["$(round(susceptibility_parameters[5] * 0.8, digits = 2))" "$(round(susceptibility_parameters[5] * 0.9, digits = 2))" "$(round(susceptibility_parameters[5], digits = 2))" "$(round(susceptibility_parameters[5] * 1.1, digits = 2))" "$(round(susceptibility_parameters[5] * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "s5.pdf"))

    incidence_plot = plot(
        1:52,
        [s6_minus_2 s6_minus_1 incidence s6_1 s6_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.92, 0.98),
        label = ["$(round(susceptibility_parameters[6] * 0.8, digits = 2))" "$(round(susceptibility_parameters[6] * 0.9, digits = 2))" "$(round(susceptibility_parameters[6], digits = 2))" "$(round(susceptibility_parameters[6] * 1.1, digits = 2))" "$(round(susceptibility_parameters[6] * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "s6.pdf"))

    incidence_plot = plot(
        1:52,
        [s7_minus_2 s7_minus_1 incidence s7_1 s7_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(susceptibility_parameters[7] * 0.8, digits = 2))" "$(round(susceptibility_parameters[7] * 0.9, digits = 2))" "$(round(susceptibility_parameters[7], digits = 2))" "$(round(susceptibility_parameters[7] * 1.1, digits = 2))" "$(round(susceptibility_parameters[7] * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "s7.pdf"))

    incidence_plot = plot(
        1:52,
        [t1_minus_2 t1_minus_1 incidence t1_1 t1_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[1], digits = 2))" "$(0.75)" "$(1.0)"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "t1.pdf"))

    incidence_plot = plot(
        1:52,
        [t2_minus_2 t2_minus_1 incidence t2_1 t2_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[2], digits = 2))" "$(0.75)" "$(1.0)"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "t2.pdf"))

    incidence_plot = plot(
        1:52,
        [t3_minus_2 t3_minus_1 incidence t3_1 t3_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[3], digits = 2))" "$(0.75)" "$(1.0)"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "t3.pdf"))

    incidence_plot = plot(
        1:52,
        [t4_minus_2 t4_minus_1 incidence t4_1 t4_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[4], digits = 2))" "$(0.75)" "$(1.0)"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "t4.pdf"))

    incidence_plot = plot(
        1:52,
        [t5_minus_2 t5_minus_1 incidence t5_1 t5_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[5], digits = 2))" "$(0.75)" "$(1.0)"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "t5.pdf"))

    incidence_plot = plot(
        1:52,
        [t6_minus_2 t6_minus_1 incidence t6_1 t6_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[6], digits = 2))" "$(0.75)" "$(1.0)"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "t6.pdf"))

    incidence_plot = plot(
        1:52,
        [t7_minus_2 t7_minus_1 incidence t7_1 t7_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[7], digits = 2))" "$(0.75)" "$(1.0)"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "t7.pdf"))

    incidence_plot = plot(
        1:52,
        [p1_minus_2 p1_minus_1 incidence p1_1 p1_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(random_infection_probabilities[1] * 0.1, digits = 6))" "$(round(random_infection_probabilities[1] * 0.5, digits = 6))" "$(round(random_infection_probabilities[1], digits = 6))" "$(round(random_infection_probabilities[1] * 2.0, digits = 6))" "$(round(random_infection_probabilities[1] * 10.0, digits = 6))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "p1.pdf"))

    incidence_plot = plot(
        1:52,
        [p2_minus_2 p2_minus_1 incidence p2_1 p2_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(random_infection_probabilities[2] * 0.1, digits = 6))" "$(round(random_infection_probabilities[2] * 0.5, digits = 6))" "$(round(random_infection_probabilities[2], digits = 6))" "$(round(random_infection_probabilities[2] * 2.0, digits = 6))" "$(round(random_infection_probabilities[2] * 10.0, digits = 6))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "p2.pdf"))

    incidence_plot = plot(
        1:52,
        [p3_minus_2 p3_minus_1 incidence p3_1 p3_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(random_infection_probabilities[3] * 0.1, digits = 6))" "$(round(random_infection_probabilities[3] * 0.5, digits = 6))" "$(round(random_infection_probabilities[3], digits = 6))" "$(round(random_infection_probabilities[3] * 2.0, digits = 6))" "$(round(random_infection_probabilities[3] * 10.0, digits = 6))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "p3.pdf"))

    incidence_plot = plot(
        1:52,
        [p4_minus_2 p4_minus_1 incidence p4_1 p4_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(random_infection_probabilities[4] * 0.1, digits = 7))" "$(round(random_infection_probabilities[4] * 0.5, digits = 7))" "$(round(random_infection_probabilities[4], digits = 7))" "$(round(random_infection_probabilities[4] * 2.0, digits = 7))" "$(round(random_infection_probabilities[4] * 10.0, digits = 7))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "p4.pdf"))

    incidence_plot = plot(
        1:52,
        [r1_minus_2 r1_minus_1 incidence r1_1 r1_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(mean_immunity_durations[1] * 0.8, digits = 2))" "$(round(mean_immunity_durations[1] * 0.9, digits = 2))" "$(round(mean_immunity_durations[1], digits = 2))" "$(round(mean_immunity_durations[1] * 1.1, digits = 2))" "$(round(mean_immunity_durations[1] * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "r1.pdf"))

    incidence_plot = plot(
        1:52,
        [r2_minus_2 r2_minus_1 incidence r2_1 r2_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(mean_immunity_durations[2] * 0.8, digits = 2))" "$(round(mean_immunity_durations[2] * 0.9, digits = 2))" "$(round(mean_immunity_durations[2], digits = 2))" "$(round(mean_immunity_durations[2] * 1.1, digits = 2))" "$(round(mean_immunity_durations[2] * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "r2.pdf"))

    incidence_plot = plot(
        1:52,
        [r3_minus_2 r3_minus_1 incidence r3_1 r3_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(mean_immunity_durations[3] * 0.8, digits = 2))" "$(round(mean_immunity_durations[3] * 0.9, digits = 2))" "$(round(mean_immunity_durations[3], digits = 2))" "$(round(mean_immunity_durations[3] * 1.1, digits = 2))" "$(round(mean_immunity_durations[3] * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "r3.pdf"))

    incidence_plot = plot(
        1:52,
        [r4_minus_2 r4_minus_1 incidence r4_1 r4_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(mean_immunity_durations[4] * 0.8, digits = 2))" "$(round(mean_immunity_durations[4] * 0.9, digits = 2))" "$(round(mean_immunity_durations[4], digits = 2))" "$(round(mean_immunity_durations[4] * 1.1, digits = 2))" "$(round(mean_immunity_durations[4] * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "r4.pdf"))

    incidence_plot = plot(
        1:52,
        [r5_minus_2 r5_minus_1 incidence r5_1 r5_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(mean_immunity_durations[5] * 0.8, digits = 2))" "$(round(mean_immunity_durations[5] * 0.9, digits = 2))" "$(round(mean_immunity_durations[5], digits = 2))" "$(round(mean_immunity_durations[5] * 1.1, digits = 2))" "$(round(mean_immunity_durations[5] * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "r5.pdf"))

    incidence_plot = plot(
        1:52,
        [r6_minus_2 r6_minus_1 incidence r6_1 r6_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(mean_immunity_durations[6] * 0.8, digits = 2))" "$(round(mean_immunity_durations[6] * 0.9, digits = 2))" "$(round(mean_immunity_durations[6], digits = 2))" "$(round(mean_immunity_durations[6] * 1.1, digits = 2))" "$(round(mean_immunity_durations[6] * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "r6.pdf"))

    incidence_plot = plot(
        1:52,
        [r7_minus_2 r7_minus_1 incidence r7_1 r7_2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(mean_immunity_durations[7] * 0.8, digits = 2))" "$(round(mean_immunity_durations[7] * 0.9, digits = 2))" "$(round(mean_immunity_durations[7], digits = 2))" "$(round(mean_immunity_durations[7] * 1.1, digits = 2))" "$(round(mean_immunity_durations[7] * 1.2, digits = 2))"],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "sensitivity", "2nd", "r7.pdf"))
end

plot_work_contacts()
plot_school_contacts()

# plot_infection_curves()
plot_incidences()
