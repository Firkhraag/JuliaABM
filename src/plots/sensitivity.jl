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

const is_russian = true

function confidence(x::Vector{Float64})
    alpha = 0.05
    tstar = quantile(TDist(length(x) - 1), 1 - alpha / 2)
    SE = std(x) / sqrt(length(x))
    return tstar * SE
end

function plot_work_contacts()
    num_runs = 1
    num_years = 3
    num_var = 3

    incidence_arr = Array{Vector{Float64}, 3}(undef, num_var, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, num_var, 52)

    for z = 1:num_var
        for i = 1:num_runs
            observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "sensitivity", "contacts", "results_w_$(z + 3).jld"))["observed_cases"] ./ 10072
            for j = 1:num_years
                incidence_arr[z, i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
            end
        end
    end

    # confidence_model = zeros(Float64, 4, 52)
    # for z = 1:4
    #     for i = 1:52
    #         confidence_model[z, i] = confidence([incidence_arr[z, k, j][i] for j = 1:num_years for k = 1:num_runs])
    #     end
    # end

    for z = 1:num_var
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
    println(1 - sum_4 / sum_5)
    println(sum_6 / sum_5 - 1)

    maximum_4 = maximum(incidence_arr_mean[1, :])
    maximum_5 = maximum(incidence_arr_mean[2, :])
    maximum_6 = maximum(incidence_arr_mean[3, :])

    println()
    println(1 - maximum_4 / maximum_5)
    println(maximum_6 / maximum_5 - 1)

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    yticks = [0, 4, 8, 12]
    yticklabels = ["0" "4" "8" "12"]

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
        [incidence_arr_mean[i, :] for i = 1:num_var],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        label = label_names,
        grid = true,
        legend = (0.9, 0.98),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2)],
        # color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        # ribbon = [confidence_model[i, :] for i = 1:4],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "contacts", "work_contacts_incidence.pdf"))




    rt_arr = Array{Vector{Float64}, 3}(undef, 4, num_runs, num_years)
    rt_arr_mean = zeros(Float64, num_var, 365)

    for z = 1:num_var
        for i = 1:num_runs
            rt = load(joinpath(@__DIR__, "..", "..", "sensitivity", "contacts", "results_w_$(z + 3).jld"))["rt"]
            for j = 1:num_years
                rt_arr[z, i, j] = moving_average(rt, 20)[(365 * (j - 1) + 1):(365 * (j - 1) + 365)]
            end
        end
    end

    rt_arr_mean = zeros(Float64, num_var, 365)
    for l = 1:num_var
        for i = 1:365
            for j = 1:num_runs
                for z = 1:num_years
                    rt_arr_mean[l, i] += rt_arr[l, j, z][i]
                end
            end
            rt_arr_mean[l, i] /= num_runs * num_years
        end
    end

    # confidence_model = zeros(Float64, 365)
    # for i = 1:365
    #     confidence_model[i] = confidence([rt_arr[k, j][i] for j = 1:num_years for k = 1:num_runs])
    # end

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
        [rt_arr_mean[i, :] for i = 1:num_var],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        label = label_names,
        # color = RGB(0.0, 0.0, 0.0),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2)],
        grid = true,
        # ribbon = confidence_model,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    savefig(
        rt_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "contacts", "work_contacts_rt.pdf"))



    num_activities = 5
    activity_sizes = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "activity_sizes.csv"), ',', Int, '\n')

    activities_cases_arr = Array{Matrix{Float64}, 3}(undef, num_var, num_runs, num_years)

    for z = 1:num_var
        for i = 1:num_runs
            activities_cases = load(joinpath(@__DIR__, "..", "..", "sensitivity", "contacts", "results_w_$(z + 3).jld"))["activities_cases"]
            for j = 1:num_years
                activities_cases_arr[z, i, j] = activities_cases[(365 * (j - 1) + 1):(365 * (j - 1) + 365), :]
            end
        end
    end

    activities_cases_arr_mean = zeros(Float64, num_var, 365, num_activities)
    for l = 1:num_var
        for i = 1:365
            for k = 1:num_activities
                for j = 1:num_runs
                    for z = 1:num_years
                        activities_cases_arr_mean[l, i, k] += activities_cases_arr[l, j, z][i, k]
                    end
                end
                activities_cases_arr_mean[l, i, k] /= num_runs * num_years
            end
        end
    end

    for l = 1:num_var
        for i = 1:num_activities
            activities_cases_arr_mean[l, :, i] ./= activity_sizes[i]
            activities_cases_arr_mean[l, :, i] .*= 100
            # activities_cases_arr_mean[:, i] = moving_average(activities_cases_arr_mean[:, i], 10)
        end
    end

    mean_values = zeros(Float64, num_var, num_activities)
    for l = 1:num_var
        for i = 1:num_activities
            mean_values[l, i] = mean(activities_cases_arr_mean[l, :, i])
        end
    end

    println()
    println(mean_values[2, 4] / mean_values[1, 4])
    println(mean_values[3, 4] / mean_values[2, 4])
end

function plot_school_contacts()
    num_runs = 1
    num_years = 3
    num_var = 4

    incidence_arr = Array{Vector{Float64}, 3}(undef, num_var, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, num_var, 52)

    for z = 1:num_var
        for i = 1:num_runs
            observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "sensitivity", "contacts", "results_s_$(z + 8).jld"))["observed_cases"] ./ 10072
            for j = 1:num_years
                incidence_arr[z, i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
            end
        end
    end

    # confidence_model = zeros(Float64, 4, 52)
    # for z = 1:4
    #     for i = 1:52
    #         confidence_model[z, i] = confidence([incidence_arr[z, k, j][i] for j = 1:num_years for k = 1:num_runs])
    #     end
    # end

    for z = 1:num_var
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

    println(1 - sum_9 / sum_10)
    println(sum_11 / sum_10 - 1)
    println(sum_max / sum_10 - 1)

    println()

    maximum_9 = maximum(incidence_arr_mean[1, :])
    maximum_10 = maximum(incidence_arr_mean[2, :])
    maximum_11 = maximum(incidence_arr_mean[3, :])
    maximum_max = maximum(incidence_arr_mean[4, :])

    println(1 - maximum_9 / maximum_10)
    println(maximum_11 / maximum_10 - 1)
    println(maximum_max / maximum_10 - 1)

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    yticks = [0, 4, 8, 12]
    yticklabels = ["0" "4" "8" "12"]

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
        [incidence_arr_mean[i, :] for i = 1:num_var],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        label = label_names,
        grid = true,
        # legend = (0.9, 0.98),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467)],
        # color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        # ribbon = [confidence_model[i, :] for i = 1:4],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "contacts", "school_contacts_incidence.pdf"))




    rt_arr = Array{Vector{Float64}, 3}(undef, num_var, num_runs, num_years)
    rt_arr_mean = zeros(Float64, num_var, 365)

    for z = 1:num_var
        for i = 1:num_runs
            rt = load(joinpath(@__DIR__, "..", "..", "sensitivity", "contacts", "results_s_$(z + 8).jld"))["rt"]
            for j = 1:num_years
                rt_arr[z, i, j] = moving_average(rt, 20)[(365 * (j - 1) + 1):(365 * (j - 1) + 365)]
            end
        end
    end

    rt_arr_mean = zeros(Float64, num_var, 365)
    for l = 1:num_var
        for i = 1:365
            for j = 1:num_runs
                for z = 1:num_years
                    rt_arr_mean[l, i] += rt_arr[l, j, z][i]
                end
            end
            rt_arr_mean[l, i] /= num_runs * num_years
        end
    end

    # confidence_model = zeros(Float64, 365)
    # for i = 1:365
    #     confidence_model[i] = confidence([rt_arr[k, j][i] for j = 1:num_years for k = 1:num_runs])
    # end

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
        [rt_arr_mean[i, :] for i = 1:num_var],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        label = label_names,
        # color = RGB(0.0, 0.0, 0.0),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467)],
        grid = true,
        # ribbon = confidence_model,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    savefig(
        rt_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "contacts", "school_contacts_rt.pdf"))



    num_activities = 5
    activity_sizes = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "activity_sizes.csv"), ',', Int, '\n')

    activities_cases_arr = Array{Matrix{Float64}, 3}(undef, num_var, num_runs, num_years)

    for z = 1:num_var
        for i = 1:num_runs
            activities_cases = load(joinpath(@__DIR__, "..", "..", "sensitivity", "contacts", "results_s_$(z + 8).jld"))["activities_cases"]
            for j = 1:num_years
                activities_cases_arr[z, i, j] = activities_cases[(365 * (j - 1) + 1):(365 * (j - 1) + 365), :]
            end
        end
    end

    activities_cases_arr_mean = zeros(Float64, num_var, 365, num_activities)
    for l = 1:num_var
        for i = 1:365
            for k = 1:num_activities
                for j = 1:num_runs
                    for z = 1:num_years
                        activities_cases_arr_mean[l, i, k] += activities_cases_arr[l, j, z][i, k]
                    end
                end
                activities_cases_arr_mean[l, i, k] /= num_runs * num_years
            end
        end
    end

    for l = 1:num_var
        for i = 1:num_activities
            activities_cases_arr_mean[l, :, i] ./= activity_sizes[i]
            activities_cases_arr_mean[l, :, i] .*= 100
            # activities_cases_arr_mean[:, i] = moving_average(activities_cases_arr_mean[:, i], 10)
        end
    end

    mean_values = zeros(Float64, num_var, num_activities)
    for l = 1:num_var
        for i = 1:num_activities
            mean_values[l, i] = mean(activities_cases_arr_mean[l, :, i])
        end
    end

    println()
    println(mean_values[2, 4] / mean_values[1, 4])
    println(mean_values[3, 4] / mean_values[2, 4])
    println(mean_values[4, 4] / mean_values[2, 4])
end

# function plot_incidence_contacts_55()
#     num_runs = 2
#     num_years = 3

#     incidence_arr = Array{Vector{Float64}, 4}(undef, 4, 3, num_runs, num_years)
#     incidence_arr_mean = zeros(Float64, 4, 3, 52)

#     for z = 1:4
#         for x = 1:3
#             for i = 1:num_runs
#                 observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "sensitivity", "contacts", "results_$(z * 2 + 17)_$(x + 2)_$(i).jld"))["observed_cases"] ./ 10072
#                 for j = 1:num_years
#                     incidence_arr[z, x, i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
#                 end
#             end
#         end
#     end

#     for z = 1:4
#         for x = 1:3
#             for i = 1:52
#                 for j = 1:num_years
#                     for k = 1:num_runs
#                         incidence_arr_mean[z, x, i] += incidence_arr[z, x, k, j][i]
#                     end
#                 end
#                 incidence_arr_mean[z, x, i] /= num_runs * num_years
#             end
#         end
#     end

#     ticks = range(1, stop = 52, length = 7)
#     ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
#     if is_russian
#         ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
#     end

#     yticks = [0, 4, 8, 12]
#     yticklabels = ["0" "4" "8" "12"]

#     # label_names = ["3" "4" "5" "6"]
#     label_names = ["19_3" "19_4" "19_5" "21_3" "21_4" "21_5" "23_3" "23_4" "23_5" "25_3" "25_4" "25_5"]

#     xlabel_name = "Month"
#     if is_russian
#         xlabel_name = "Месяц"
#     end

#     ylabel_name = "Weekly incidence rate per 1000"
#     if is_russian
#         ylabel_name = "Число случаев на 1000 чел. / неделя"
#     end

#     incidence_plot = plot(
#         1:52,
#         [incidence_arr_mean[i, j, :] for i = 1:4 for j = 1:3],
#         lw = 2,
#         xticks = (ticks, ticklabels),
#         yticks = (yticks, yticklabels),
#         label = label_names,
#         grid = true,
#         legend = (0.9, 0.98),
#         # color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
#         # ribbon = [confidence_model[i, :] for i = 1:4],
#         foreground_color_legend = nothing,
#         background_color_legend = nothing,
#         xlabel = xlabel_name,
#         ylabel = ylabel_name,
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "contacts", "incidence.pdf"))
# end

# function plot_rt_contacts55()
#     num_runs = 2
#     num_years = 3

#     rt_arr = Array{Vector{Float64}, 4}(undef, 4, 3, num_runs, num_years)
#     rt_arr_mean = zeros(Float64, 4, 3, 365)

#     for z = 1:4
#         for x = 1:3
#             for i = 1:num_runs
#                 rt = load(joinpath(@__DIR__, "..", "..", "sensitivity", "contacts", "results_$(z * 2 + 17)_$(x + 2)_$(i).jld"))["rt"]
#                 for j = 1:num_years
#                     rt_arr[z, x, i, j] = moving_average(rt, 20)[(365 * (j - 1) + 1):(365 * (j - 1) + 365)]
#                 end
#             end
#         end
#     end

#     rt_arr_mean = zeros(Float64, 4, 3, 365)
#     for l = 1:4
#         for x = 1:3
#             for i = 1:365
#                 for j = 1:num_runs
#                     for z = 1:num_years
#                         rt_arr_mean[l, x, i] += rt_arr[l, x, j, z][i]
#                     end
#                 end
#                 rt_arr_mean[l, x, i] /= num_runs * num_years
#             end
#         end
#     end

#     # confidence_model = zeros(Float64, 365)
#     # for i = 1:365
#     #     confidence_model[i] = confidence([rt_arr[k, j][i] for j = 1:num_years for k = 1:num_runs])
#     # end

#     ticks = range(1, stop = 365, length = 7)
#     ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
#     if is_russian
#         ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
#     end

#     xlabel_name = "Month"
#     if is_russian
#         xlabel_name = "Месяц"
#     end

#     label_names = ["3" "4" "5" "6"]

#     ylabel_name = L"R_t"
    
#     yticks = [0.8, 1.0, 1.2, 1.4]
#     yticklabels = ["0.8", "1.0", "1.2", "1.4"]

#     rt_plot = plot(
#         1:365,
#         [rt_arr_mean[i, j, :] for i = 1:4 for j = 1:3],
#         lw = 1,
#         xticks = (ticks, ticklabels),
#         yticks = (yticks, yticklabels),
#         label = label_names,
#         # color = RGB(0.0, 0.0, 0.0),
#         grid = true,
#         # ribbon = confidence_model,
#         xlabel = xlabel_name,
#         ylabel = ylabel_name,
#     )
#     savefig(
#         rt_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "contacts", "rt.pdf"))
# end

function plot_incidence_contacts()
    num_runs = 5
    num_years = 3

    incidence_arr = Array{Vector{Float64}, 3}(undef, 4, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 4, 52)

    for z = 1:4
        for i = 1:num_runs
            observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "sensitivity", "contacts", "results_$(z + 2)_$(i).jld"))["observed_cases"] ./ 10072
            # observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "sensitivity", "contacts", "results_$(z + 2)_$(i).jld"))["all_cases"] ./ 10072
            for j = 1:num_years
                incidence_arr[z, i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
            end
        end
    end

    # confidence_model = zeros(Float64, 4, 52)
    # for z = 1:4
    #     for i = 1:52
    #         confidence_model[z, i] = confidence([incidence_arr[z, k, j][i] for j = 1:num_years for k = 1:num_runs])
    #     end
    # end

    for z = 1:4
        for i = 1:52
            for j = 1:num_years
                for k = 1:num_runs
                    incidence_arr_mean[z, i] += incidence_arr[z, k, j][i]
                end
            end
            incidence_arr_mean[z, i] /= num_runs * num_years
        end
    end

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    yticks = [0, 4, 8, 12]
    yticklabels = ["0" "4" "8" "12"]

    label_names = ["m = 3" "m = 4" "m = 5" "m = 6"]

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
        [incidence_arr_mean[i, :] for i = 1:4],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        label = label_names,
        grid = true,
        legend = (0.9, 0.98),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.133, 0.533, 0.2) RGB(0.267, 0.467, 0.667) RGB(0.667, 0.2, 0.467)],
        # color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        # ribbon = [confidence_model[i, :] for i = 1:4],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "contacts", "model_incidence.pdf"))
end

function plot_incidence_contacts2()
    num_runs = 5
    num_years = 3

    incidence_arr = Array{Vector{Float64}, 3}(undef, 4, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 4, 52)

    for z = 1:4
        for i = 1:num_runs
            observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "sensitivity", "contacts", "results_$(z * 2 + 17)_$(i).jld"))["observed_cases"] ./ 10072
            for j = 1:num_years
                incidence_arr[z, i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
            end
        end
    end

    # confidence_model = zeros(Float64, 4, 52)
    # for z = 1:4
    #     for i = 1:52
    #         confidence_model[z, i] = confidence([incidence_arr[z, k, j][i] for j = 1:num_years for k = 1:num_runs])
    #     end
    # end

    for z = 1:4
        for i = 1:52
            for j = 1:num_years
                for k = 1:num_runs
                    incidence_arr_mean[z, i] += incidence_arr[z, k, j][i]
                end
            end
            incidence_arr_mean[z, i] /= num_runs * num_years
        end
    end

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    yticks = [0, 4, 8, 12]
    yticklabels = ["0" "4" "8" "12"]

    label_names = ["19" "21" "23" "25"]

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
        [incidence_arr_mean[i, :] for i = 1:4],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        label = label_names,
        grid = true,
        legend = (0.9, 0.98),
        # color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        # ribbon = [confidence_model[i, :] for i = 1:4],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "contacts", "model_incidence_2.pdf"))
end

function plot_rt_contacts()
    num_runs = 5
    num_years = 3

    rt_arr = Array{Vector{Float64}, 3}(undef, 4, num_runs, num_years)
    rt_arr_mean = zeros(Float64, 4, 365)

    for z = 1:4
        for i = 1:num_runs
            rt = load(joinpath(@__DIR__, "..", "..", "sensitivity", "contacts", "results_$(z + 2)_$(i).jld"))["rt"]
            for j = 1:num_years
                rt_arr[z, i, j] = moving_average(rt, 20)[(365 * (j - 1) + 1):(365 * (j - 1) + 365)]
            end
        end
    end

    rt_arr_mean = zeros(Float64, 4, 365)
    for l = 1:4
        for i = 1:365
            for j = 1:num_runs
                for z = 1:num_years
                    rt_arr_mean[l, i] += rt_arr[l, j, z][i]
                end
            end
            rt_arr_mean[l, i] /= num_runs * num_years
        end
    end

    # confidence_model = zeros(Float64, 365)
    # for i = 1:365
    #     confidence_model[i] = confidence([rt_arr[k, j][i] for j = 1:num_years for k = 1:num_runs])
    # end

    ticks = range(1, stop = 365, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    label_names = ["m = 3" "m = 4" "m = 5" "m = 6"]

    ylabel_name = L"R_t"
    
    yticks = [0.8, 1.0, 1.2, 1.4]
    yticklabels = ["0.8", "1.0", "1.2", "1.4"]

    rt_plot = plot(
        1:365,
        [rt_arr_mean[i, :] for i = 1:4],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        label = label_names,
        # color = RGB(0.0, 0.0, 0.0),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.133, 0.533, 0.2) RGB(0.267, 0.467, 0.667) RGB(0.667, 0.2, 0.467)],
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        # ribbon = confidence_model,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(
        rt_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "contacts", "rt.pdf"))
end

function plot_rt_contacts2()
    num_runs = 5
    num_years = 3

    rt_arr = Array{Vector{Float64}, 3}(undef, 4, num_runs, num_years)
    rt_arr_mean = zeros(Float64, 4, 365)

    for z = 1:4
        for i = 1:num_runs
            rt = load(joinpath(@__DIR__, "..", "..", "sensitivity", "contacts", "results_$(z * 2 + 17)_$(i).jld"))["rt"]
            for j = 1:num_years
                rt_arr[z, i, j] = moving_average(rt, 20)[(365 * (j - 1) + 1):(365 * (j - 1) + 365)]
            end
        end
    end

    rt_arr_mean = zeros(Float64, 4, 365)
    for l = 1:4
        for i = 1:365
            for j = 1:num_runs
                for z = 1:num_years
                    rt_arr_mean[l, i] += rt_arr[l, j, z][i]
                end
            end
            rt_arr_mean[l, i] /= num_runs * num_years
        end
    end

    # confidence_model = zeros(Float64, 365)
    # for i = 1:365
    #     confidence_model[i] = confidence([rt_arr[k, j][i] for j = 1:num_years for k = 1:num_runs])
    # end

    ticks = range(1, stop = 365, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    label_names = ["19" "21" "23" "25"]

    ylabel_name = L"R_t"
    
    yticks = [0.8, 1.0, 1.2, 1.4]
    yticklabels = ["0.8", "1.0", "1.2", "1.4"]

    rt_plot = plot(
        1:365,
        [rt_arr_mean[i, :] for i = 1:4],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        label = label_names,
        # color = RGB(0.0, 0.0, 0.0),
        grid = true,
        # ribbon = confidence_model,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(
        rt_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "contacts", "rt2.pdf"))
end

function plot_infection_curves()
    num_runs = 315
    num_years = 2

    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_means = zeros(Float64, (52 * num_years), num_runs)

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    infected_data_mean = mean(infected_data[42:(41 + num_years), 2:53], dims = 1)[1, :]

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
        incidence_arr[i] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[1:(52 * num_years), :, 1], dims = 2)[:, 1]

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

    for i = 1:(52 * num_years)
        for j = 1:num_runs
            incidence_arr_means[i, j] = incidence_arr[j][i]
        end
    end

    incidence_arr = Array{Matrix{Float64}, 1}(undef, num_runs)
    incidence_arr_mean = zeros(Float64, (52 * num_years), 4)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["observed_cases"]
        incidence_arr[i] = sum(observed_num_infected_age_groups_viruses, dims = 2)[1:(52 * num_years), 1, :]
    end

    incidence_arr_mean_age_groups = zeros(Float64, (52 * num_years), 4, num_runs)
    for i = 1:(52 * num_years)
        for k = 1:4
            for j = 1:num_runs
                incidence_arr_mean_age_groups[i, k, j] = incidence_arr[j][i, k]
            end
        end
    end

    # General age groups
    incidence_arr = Array{Matrix{Float64}, 1}(undef, num_runs)
    viruses_mean = zeros(Float64, (52 * num_years), 7)

    for i = 1:10
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
        incidence_arr[i] = sum(observed_num_infected_age_groups_viruses, dims = 3)[1:(52 * num_years), :, 1]
    end

    for i = 1:(52 * num_years)
        for k = 1:7
            for j = 1:10
                viruses_mean[i, k] += incidence_arr[j][i, k]
            end
            viruses_mean[i, k] /= num_runs
        end
    end

    incidence_arr = Array{Matrix{Float64}, 1}(undef, num_runs)
    incidence_arr_mean_viruses = zeros(Float64, (52 * num_years), 7, num_runs)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["observed_cases"]
        incidence_arr[i] = sum(observed_num_infected_age_groups_viruses, dims = 3)[1:(52 * num_years), :, 1]
    end

    for i = 1:(52 * num_years)
        for k = 1:7
            for j = 1:num_runs
                incidence_arr_mean_viruses[i, k, j] = incidence_arr[j][i, k]
            end
        end
    end

    rt_arr = Array{Vector{Float64}, 1}(undef, num_runs)
    rt_arr_means = zeros(Float64, (365 * num_years), num_runs)

    for i = 1:num_runs
        rt = load(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "results_$(i).jld"))["rt"]
        rt_arr[i] = moving_average(rt, 10)
    end

    rt_arr_mean = zeros(Float64, 365)
    for i = 1:(365 * num_years)
        for j = 1:num_runs
            rt_arr_means[i, j] = rt_arr[j][i]
        end
    end

    # ticks = range(1, stop = (52.14285 * num_years), length = 19)
    # ticks_rt = range(1, stop = (365 * num_years), length = 19)

    # ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    # if is_russian
    #     ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    # end

    ticks = range(1, stop = (52.14285 * num_years), length = 13)
    ticks_rt = range(1, stop = (365 * num_years), length = 13)

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
        1:(52 * num_years),
        [incidence_arr_means[:, i] for i = 1:num_runs],
        lw = 1,
        xticks = (ticks, ticklabels),
        legend = false,
        grid = true,
        xrotation = 45,
        margin = 6Plots.mm,
        size = (800, 500),
        color = [:grey for i = 1:num_runs],
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "incidence.pdf"))

    # return

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

    println("First peak")
    y = incidence_arr_means[10, :]
    @time param_ids = stepwise_regression(X, y, 12)
    println(params_arr[param_ids])
    # ["susceptibility_parameter_4",
    # "duration_parameter",
    # "mean_viral_load_adult_4",
    # "susceptibility_parameter_3",
    # "infection_period_duration_adult_4",
    # "other_contact_duration_scale_4",
    # "symptomatic_probability_adult_3", ++++
    # "isolation_probability_day_2_4",
    # "mean_viral_load_child_4",
    # "mean_viral_load_adult_3",
    # "other_contact_duration_shape_4",
    # "infection_period_duration_child_4"]

    println("Second peak")
    y = incidence_arr_means[13, :]
    @time param_ids = stepwise_regression(X, y, 12)
    println(params_arr[param_ids])
    # ["susceptibility_parameter_4",
    # "duration_parameter",
    # "mean_viral_load_child_4",
    # "mean_viral_load_adult_4",
    # "infection_period_duration_adult_4",
    # "infection_period_duration_child_4",
    # "other_contact_duration_shape_4",
    # "other_contact_duration_scale_4",
    # "other_contact_duration_shape_2",
    # "susceptibility_parameter_3",
    # "isolation_probability_day_2_4",
    # "symptomatic_probability_adult_3"]
    

    println("Max")
    y = incidence_arr_means[argmax(infected_data_mean), :]
    @time param_ids = stepwise_regression(X, y, 12)
    println(params_arr[param_ids])
    # ["duration_parameter",
    # "symptomatic_probability_adult_1",
    # "symptomatic_probability_adult_2",
    # "mean_viral_load_adult_2",
    # "isolation_probability_day_2_4",
    # "infection_period_duration_adult_2",
    # "susceptibility_parameter_2",
    # "mean_viral_load_adult_1",
    # "mean_household_contact_duration_2",
    # "symptomatic_probability_teenager_1",
    # "infection_period_duration_adult_1",
    # "other_contact_duration_shape_4"]
    

    println("Sum")
    y = sum(incidence_arr_means, dims = 1)[1, :]
    @time param_ids = stepwise_regression(X, y, 12)
    println(params_arr[param_ids])
    # ["duration_parameter",
    # "susceptibility_parameter_4",
    # "other_contact_duration_scale_4",
    # "other_contact_duration_shape_4",
    # "susceptibility_parameter_1",
    # "susceptibility_parameter_2",
    # "susceptibility_parameter_3",
    # "mean_viral_load_adult_1",
    # "infection_period_duration_adult_1",
    # "isolation_probability_day_2_4",
    # "other_contact_duration_shape_2",
    # "infection_period_duration_adult_2"]
    
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

    # duration_parameter = 3.711739847454133
    # susceptibility_parameters = [3.049958771387343, 3.797783962069675, 3.6978664192949933, 5.583601319315603, 4.070443207586069, 3.957334570191713, 4.612042877757162]
    # temperature_parameters = -[-0.8786105957534528, -0.7631003916718199, -0.0868996083281797, -0.15656565656565657, -0.1027107812822098, -0.05588538445681307, -0.16932591218305615]
    # random_infection_probabilities = [0.00011551556380127805, 6.822016079158936e-5, 4.922135642135645e-5, 6.844135229849516e-7]
    # mean_immunity_durations = [255.05916305916304, 312.7078952793239, 101.87487116058544, 27.368377654091933, 77.08431251288393, 117.33374561945988, 103.15357658214802]

    duration_parameter = 0.23703365311405514
    susceptibility_parameters = [3.0731248200497587, 3.0315005376748694, 3.4960107319671523, 4.558457619595636, 3.9627987624113588, 3.751417011489648, 4.552998584572433]
    temperature_parameters = [-0.8747474747474746, -0.9177827791629244, -0.051010101010101006, -0.16313131313131315, -0.003030303030303022, -0.08442528431390421, -0.35326291827502476]
    immune_memory_susceptibility_levels = [0.8944639240038756, 0.9430303030303029, 0.9336363636363636, 0.9363636363636363, 0.8876594776594775, 0.8817572117572116, 0.946060606060606]
    mean_immunity_durations = [357.979797979798, 326.2129504744517, 133.30517744372466, 99.91903541540344, 105.99775039968745, 148.27512119521802, 162.6804553051528]
    random_infection_probabilities = [0.00138, 0.00077, 0.0004, 9.2e-6]

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
    
    # ticks = range(1, stop = 52, length = 7)
    # ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    # yticks = [2, 6, 10, 14]
    # yticklabels = ["2", "6", "10", "14"]

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
        # ylims = (0, 17),
        margin = 2Plots.mm,
        label = ["d = $(round(duration_parameter * 0.8, digits = 2))" "d = $(round(duration_parameter * 0.9, digits = 2))" "d = $(round(duration_parameter, digits = 2))" "d = $(round(duration_parameter * 1.1, digits = 2))" "d = $(round(duration_parameter * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "d.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "s1.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "s2.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "s3.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "s4.pdf"))

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
        # ylims = (0, 13),
        label = ["$(round(susceptibility_parameters[5] * 0.8, digits = 2))" "$(round(susceptibility_parameters[5] * 0.9, digits = 2))" "$(round(susceptibility_parameters[5], digits = 2))" "$(round(susceptibility_parameters[5] * 1.1, digits = 2))" "$(round(susceptibility_parameters[5] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "s5.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "s6.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "s7.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "t1.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "t2.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "t3.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "t4.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "t5.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "t6.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "t7.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "p1.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "p2.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "p3.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "p4.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "r1.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "r2.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "r3.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "r4.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "r5.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "r6.pdf"))

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
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "2nd", "r7.pdf"))
end

# plot_work_contacts()
# plot_school_contacts()

# plot_incidence_contacts()
# plot_incidence_contacts2()
# plot_rt_contacts()
# plot_rt_contacts2()

# plot_infection_curves()
plot_incidences()
