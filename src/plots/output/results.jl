using DelimitedFiles
using Statistics
using StatsPlots
using Plots
using LaTeXStrings
using JLD
using Distributions

include("../../util/moving_avg.jl")
include("../../data/etiology.jl")

default(legendfontsize = 9, guidefont = (12, :black), tickfont = (11, :black))

# const is_russian = false
const is_russian = true

const num_runs = 10
# const num_runs = 1
const num_years = 3
# const num_years = 1

const with_quarantine = false
# const with_quarantine = true

const with_global_warming = false
# const with_global_warming = true

function confidence(x::Vector{Float64})
    alpha = 0.05
    tstar = quantile(TDist(length(x) - 1), 1 - alpha / 2)
    SE = std(x) / sqrt(length(x))
    return tstar * SE
end

function plot_incidence_time_series()
    incidence_arr = Array{Vector{Float64}, 1}(undef, num_runs)
    incidence_arr_mean = zeros(Float64, 52 * num_years)
    
    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ 10072
        incidence_arr[i] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]
    end

    confidence_model = zeros(Float64, 52 * num_years)
    for i = 1:(52 * num_years)
        confidence_model[i] = confidence([incidence_arr[k][i] for k = 1:num_runs])
    end

    for i = 1:(52 * num_years)
        for k = 1:num_runs
            incidence_arr_mean[i] += incidence_arr[k][i]
        end
        incidence_arr_mean[i] /= num_runs
    end    

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n') ./ 10072
    # infected_data = vec(transpose(infected_data[43:45, 2:53]))
    infected_data = vec(transpose(infected_data[42:44, 2:53]))

    ticks = range(1, stop = (52.14285 * num_years), length = 19)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
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

    # incidence_plot = plot(
    #     1:52,
    #     [incidence_arr_mean infected_data_mean],
    #     lw = 1.5,
    #     xticks = (ticks, ticklabels),
    #     yticks = (yticks, yticklabels),
    #     label = label_names,
    #     grid = true,
    #     legend = (0.9, 0.98),
    #     color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
    #     ribbon = [confidence_model confidence_data],
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )
    incidence_plot = plot(
        1:(52 * num_years),
        [incidence_arr_mean infected_data],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        # yticks = (yticks, yticklabels),
        label = label_names,
        margin = 6Plots.mm,
        xrotation = 45,
        grid = true,
        legend = (0.9, 0.98),
        size = (800, 500),
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        # ribbon = confidence_model,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "model_incidence_quarantine_time_series.pdf" : with_global_warming ? "model_incidence_warming_time_series.pdf" : "model_incidence_time_series.pdf"))
end

function plot_incidence_age_groups_time_series()
    incidence_arr = Array{Matrix{Float64}, 1}(undef, num_runs)
    incidence_arr_mean = zeros(Float64, 52 * num_years, 4)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ 10072
        incidence_arr[i] = sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :]
    end

    for i = 1:(52 * num_years)
        for k = 1:4
            for j = 1:num_runs
                incidence_arr_mean[i, k] += incidence_arr[j][i, k]
            end
            incidence_arr_mean[i, k] /= num_runs
        end
    end

    confidence_model = zeros(Float64, 52 * num_years, 4)
    for i = 1:(52 * num_years)
        for k = 1:4
            confidence_model[i, k] = confidence([incidence_arr[j][i, k] for j = 1:num_runs])
        end
    end

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n') ./ 10072
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n') ./ 10072
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n') ./ 10072
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n') ./ 10072

    infected_data_mean = cat(
        vec(infected_data_0[2:53, 24:26]),
        vec(infected_data_3[2:53, 24:26]),
        vec(infected_data_7[2:53, 24:26]),
        vec(infected_data_15[2:53, 24:26]),
        dims = 2,
    )

    ticks = range(1, stop = (52.14285 * num_years), length = 19)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

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

    age_groups = ["0-2", "3-6", "7-14", "15+"]
    for i = 1:4
        incidence_plot = plot(
            1:(52 * num_years),
            [incidence_arr_mean[:, i] infected_data_mean[:, i]],
            lw = 1.5,
            xticks = (ticks, ticklabels),
            label = label_names,
            margin = 6Plots.mm,
            xrotation = 45,
            grid = true,
            size = (800, 500),
            legend = (0.9, 0.98),
            color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
            # ribbon = [confidence_model[:, i]],
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
        savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "incidence$(age_groups[i])_quarantine_time_series.pdf" : with_global_warming ? "incidence$(age_groups[i])_warming_time_series.pdf" : "incidence$(age_groups[i])_time_series.pdf"))
    end
end

function plot_incidence_viruses_time_series()
    incidence_arr = Array{Matrix{Float64}, 1}(undef, num_runs)
    incidence_arr_mean = zeros(Float64, (52 * num_years), 7)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ 10072
        incidence_arr[i] = sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1]
    end

    for i = 1:(52 * num_years)
        for k = 1:7
            for j = 1:num_runs
                incidence_arr_mean[i, k] += incidence_arr[j][i, k]
            end
            incidence_arr_mean[i, k] /= num_runs
        end
    end

    confidence_model = zeros(Float64, (52 * num_years), 7)
    for i = 1:(52 * num_years)
        for k = 1:7
            confidence_model[i, k] = confidence([incidence_arr[j][i, k] for j = 1:num_runs])
        end
    end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n') ./ 10072

    FluA_arr = [1.0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 25, 50, 60, 75, 310, 1675, 1850, 1500, 1250, 900, 375, 350, 290, 220, 175, 165, 100, 50, 40, 25, 15, 9, 4, 2, 1, 1, 1, 1, 1, 1, 1, 1]
    FluA_arr2 = [1.0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 15, 44, 72, 50, 10, 80, 266, 333, 480, 588, 625, 575, 622, 423, 450, 269, 190, 138, 89, 60, 30, 20, 12, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1]

    RV_arr = [50.0, 50, 86, 90, 70, 74, 97, 115, 158, 130, 131, 103, 112, 112, 136, 90, 111, 128, 130, 140, 118, 152, 49, 22, 51, 80, 82, 100, 78, 57, 70, 73, 102, 101, 80, 62, 68, 60, 66, 52, 42, 69, 74, 38, 50, 42, 36, 38, 24, 44, 45, 40]
    RV_arr2 = [11.0, 10, 20, 24, 10, 20, 41, 42, 43, 54, 42, 52, 39, 37, 20, 15, 20, 38, 41, 28, 30, 21, 9, 1, 10, 50, 62, 52, 31, 40, 36, 41, 42, 32, 84, 71, 78, 72, 32, 28, 39, 37, 72, 67, 41, 52, 40, 24, 40, 39, 36, 30]
    
    RSV_arr = [8.0, 8, 8, 8, 8, 5, 7, 8, 11, 11, 18, 14, 15, 18, 35, 55, 53, 70, 90, 130, 45, 30, 80, 140, 100, 120, 145, 180, 150, 68, 72, 60, 80, 75, 55, 60, 65, 62, 50, 45, 50, 20, 24, 19, 15, 10, 10, 9, 11, 10, 9, 8]
    RSV_arr2 = [8.0, 9, 9, 4, 4, 10, 9, 10, 3, 12, 8, 10, 12, 7, 10, 13, 9, 15, 21, 25, 30, 10, 2, 22, 18, 30, 77, 72, 48, 61, 90, 120, 150, 145, 92, 119, 78, 69, 49, 57, 49, 43, 46, 24, 40, 24, 24, 10, 10, 9, 7, 11]

    AdV_arr = [20.0, 30, 40, 20, 30, 25, 15, 19, 17, 18, 20, 25, 30, 21, 38, 40, 42, 30, 40, 50, 51, 41, 10, 8, 30, 40, 38, 70, 67, 20, 28, 20, 29, 20, 28, 16, 10, 20, 18, 27, 19, 19, 32, 31, 20, 20, 15, 8, 20, 35, 35, 35]
    AdV_arr2 = [9.0, 11, 13, 5, 7, 12, 12, 18, 16, 22, 18, 22, 31, 32, 33, 17, 28, 39, 29, 40, 30, 56, 11, 1, 38, 30, 39, 28, 59, 19, 46, 20, 22, 47, 38, 40, 25, 17, 18, 10, 6, 6, 21, 11, 19, 12, 27, 18, 10, 27, 10, 10]

    PIV_arr = [15.0, 18, 20, 33, 15, 36, 33, 38, 38, 50, 40, 43, 46, 75, 55, 35, 85, 53, 65, 40, 70, 20, 10, 45, 32, 33, 51, 34, 22, 12, 12, 14, 16, 18, 20, 8, 24, 20, 15, 5, 20, 15, 15, 20, 19, 18, 31, 18, 18, 17, 15, 14]
    PIV_arr2 = [10.0, 11, 6, 8, 12, 19, 22, 20, 20, 22, 28, 32, 47, 29, 31, 38, 17, 40, 31, 36, 32, 48, 11, 6, 30, 38, 12, 30, 22, 12, 20, 17, 30, 45, 11, 14, 17, 15, 15, 10, 15, 20, 17, 18, 23, 10, 10, 18, 17, 16, 17, 14]

    CoV_arr = [1.0, 2, 1, 2, 1, 1, 2, 1, 2, 1, 1, 2, 8, 10, 5, 7, 7, 14, 8, 25, 35, 30, 1, 5, 16, 14, 25, 35, 32, 50, 10, 18, 12, 30, 36, 25, 14, 16, 5, 3, 1, 3, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    CoV_arr2 = [5.0, 1, 1, 2, 1, 1, 6, 1, 3, 1, 1, 5, 9, 1, 5, 1, 1, 5, 1, 3, 2, 1, 5, 1, 3, 1, 1, 9, 5, 5, 9, 3, 4, 3, 12, 18, 16, 15, 7, 1, 13, 3, 3, 10, 2, 1, 1, 1, 1, 1, 1, 1]

    FluA_arr = moving_average(FluA_arr, 3)
    RV_arr = moving_average(RV_arr, 3)
    RSV_arr = moving_average(RSV_arr, 3)
    AdV_arr = moving_average(AdV_arr, 3)
    PIV_arr = moving_average(PIV_arr, 3)
    CoV_arr = moving_average(CoV_arr, 3)

    FluA_arr2 = moving_average(FluA_arr2, 3)
    RV_arr2 = moving_average(RV_arr2, 3)
    RSV_arr2 = moving_average(RSV_arr2, 3)
    AdV_arr2 = moving_average(AdV_arr2, 3)
    PIV_arr2 = moving_average(PIV_arr2, 3)
    CoV_arr2 = moving_average(CoV_arr2, 3)

    FluB_arr = FluA_arr .* 1/3
    FluB_arr2 = FluA_arr2 .* 1/3

    sum_arr = FluA_arr + FluB_arr + RV_arr + RSV_arr + AdV_arr + PIV_arr + CoV_arr
    sum_arr2 = FluA_arr2 + FluB_arr2 + RV_arr2 + RSV_arr2 + AdV_arr2 + PIV_arr2 + CoV_arr2

    FluA_ratio = FluA_arr ./ sum_arr
    FluB_ratio = FluB_arr ./ sum_arr
    RV_ratio = RV_arr ./ sum_arr
    RSV_ratio = RSV_arr ./ sum_arr
    AdV_ratio = AdV_arr ./ sum_arr
    PIV_ratio = PIV_arr ./ sum_arr
    CoV_ratio = CoV_arr ./ sum_arr

    FluA_ratio2 = FluA_arr2 ./ sum_arr2
    FluB_ratio2 = FluB_arr2 ./ sum_arr2
    RV_ratio2 = RV_arr2 ./ sum_arr2
    RSV_ratio2 = RSV_arr2 ./ sum_arr2
    AdV_ratio2 = AdV_arr2 ./ sum_arr2
    PIV_ratio2 = PIV_arr2 ./ sum_arr2
    CoV_ratio2 = CoV_arr2 ./ sum_arr2

    FluA_ratio = moving_average(FluA_ratio, 3)
    FluB_ratio = moving_average(FluB_ratio, 3)
    RV_ratio = moving_average(RV_ratio, 3)
    RSV_ratio = moving_average(RSV_ratio, 3)
    AdV_ratio = moving_average(AdV_ratio, 3)
    PIV_ratio = moving_average(PIV_ratio, 3)
    CoV_ratio = moving_average(CoV_ratio, 3)

    FluA_ratio2 = moving_average(FluA_ratio2, 3)
    FluB_ratio2 = moving_average(FluB_ratio2, 3)
    RV_ratio2 = moving_average(RV_ratio2, 3)
    RSV_ratio2 = moving_average(RSV_ratio2, 3)
    AdV_ratio2 = moving_average(AdV_ratio2, 3)
    PIV_ratio2 = moving_average(PIV_ratio2, 3)
    CoV_ratio2 = moving_average(CoV_ratio2, 3)

    etiology = hcat(FluA_ratio, FluB_ratio, RV_ratio, RSV_ratio, AdV_ratio, PIV_ratio, CoV_ratio)
    etiology2 = hcat(FluA_ratio2, FluB_ratio2, RV_ratio2, RSV_ratio2, AdV_ratio2, PIV_ratio2, CoV_ratio2)

    infected_data = transpose(infected_data[42:44, 2:53])
    etiology = get_etiology()

    infected_data_1 = etiology[:, 1] .* infected_data
    infected_data_2 = etiology[:, 2] .* infected_data
    infected_data_3 = etiology[:, 3] .* infected_data
    infected_data_4 = etiology[:, 4] .* infected_data
    infected_data_5 = etiology[:, 5] .* infected_data
    infected_data_6 = etiology[:, 6] .* infected_data
    infected_data_7 = etiology[:, 7] .* infected_data
    infected_data_viruses_1 = cat(
        vec(infected_data_1),
        vec(infected_data_2),
        vec(infected_data_3),
        vec(infected_data_4),
        vec(infected_data_5),
        vec(infected_data_6),
        vec(infected_data_7),
        dims = 2)

    # infected_data_1 = etiology[:, 1] .* infected_data
    # infected_data_2 = etiology[:, 2] .* infected_data
    # infected_data_3 = etiology[:, 3] .* infected_data
    # infected_data_4 = etiology[:, 4] .* infected_data
    # infected_data_5 = etiology[:, 5] .* infected_data
    # infected_data_6 = etiology[:, 6] .* infected_data
    # infected_data_7 = etiology[:, 7] .* infected_data

    # infected_data_viruses_1 = cat(
    #     infected_data_1,
    #     infected_data_2,
    #     infected_data_3,
    #     infected_data_4,
    #     infected_data_5,
    #     infected_data_6,
    #     infected_data_7,
    #     dims = 3)

    infected_data_1_2 = etiology2[:, 1] .* infected_data
    infected_data_2_2 = etiology2[:, 2] .* infected_data
    infected_data_3_2 = etiology2[:, 3] .* infected_data
    infected_data_4_2 = etiology2[:, 4] .* infected_data
    infected_data_5_2 = etiology2[:, 5] .* infected_data
    infected_data_6_2 = etiology2[:, 6] .* infected_data
    infected_data_7_2 = etiology2[:, 7] .* infected_data
    infected_data_viruses_2 = cat(
        vec(infected_data_1_2),
        vec(infected_data_2_2),
        vec(infected_data_3_2),
        vec(infected_data_4_2),
        vec(infected_data_5_2),
        vec(infected_data_6_2),
        vec(infected_data_7_2),
        dims = 2)

    infected_data_viruses = (infected_data_viruses_1 + infected_data_viruses_2) ./ 2
    # infected_data_viruses = cat(infected_data_viruses_1, infected_data_viruses_2, dims = 2)

    ticks = range(1, stop = (52.14285 * num_years), length = 19)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

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

    viruses = ["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"]
    for i in 1:7
        incidence_plot = plot(
            1:(52 * num_years),
            [incidence_arr_mean[:, i] infected_data_viruses[:, i]],
            lw = 1.5,
            xticks = (ticks, ticklabels),
            label = label_names,
            margin = 6Plots.mm,
            xrotation = 45,
            grid = true,
            size = (800, 500),
            legend = (0.9, 0.98),
            color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
            # ribbon = [confidence_model[:, i]],
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
        savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "incidence$(viruses[i])_quarantine_time_series.pdf" : with_global_warming ? "incidence$(viruses[i])_warming_time_series.pdf" : "incidence$(viruses[i])_time_series.pdf"))
    end
end

function plot_rt_time_series()
    rt_arr = Array{Vector{Float64}, 1}(undef, num_runs)
    rt_arr_mean = zeros(Float64, (365 * num_years))

    for i = 1:num_runs
        rt = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["rt"]
        # rt = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i + 1).jld"))["rt"]
            rt_arr[i] = moving_average(rt, 20)
    end

    rt_arr_mean = zeros(Float64, (365 * num_years))
    for i = 1:(365 * num_years)
        for j = 1:num_runs
            rt_arr_mean[i] += rt_arr[j][i]
        end
        rt_arr_mean[i] /= num_runs
    end

    # confidence_model = zeros(Float64, (365 * num_years))
    # for i = 1:(365 * num_years)
    #     confidence_model[i] = confidence([rt_arr[k, j][i] for j = 1:num_years for k = 1:num_runs])
    # end

    ticks = range(1, stop = (365 * num_years), length = 19)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = L"R_t"
    
    yticks = [0.8, 1.0, 1.2, 1.4]
    yticklabels = ["0.8", "1.0", "1.2", "1.4"]

    rt_plot = plot(
        1:(365 * num_years),
        rt_arr_mean,
        lw = 1.5,
        xticks = (ticks, ticklabels),
        # yticks = (yticks, yticklabels),
        margin = 6Plots.mm,
        xrotation = 45,
        legend = false,
        color = RGB(0.0, 0.0, 0.0),
        grid = true,
        size = (800, 500),
        # ribbon = confidence_model,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(
        rt_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "rt_quarantine_time_series.pdf" : with_global_warming ? "rt_warming_time_series.pdf" : "rt_time_series.pdf"))
end

function print_statistics_time_series()
    incidence_arr = Array{Vector{Float64}, 1}(undef, num_runs)
    incidence_arr_mean = zeros(Float64, (52 * num_years))

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"]
        incidence_arr[i] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]
    end

    for i = 1:(52 * num_years)
        for j = 1:num_runs
            incidence_arr_mean[i] += incidence_arr[j][i]
        end
        incidence_arr_mean[i] /= num_runs
    end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    infected_data_mean = vec(transpose(infected_data[42:44, 2:53]))

    

    nMAE_general = sum(abs.(incidence_arr_mean - infected_data_mean)) / sum(infected_data_mean)
    println("General nMAE: $(nMAE_general)")

    # ------------------

    incidence_arr = Array{Matrix{Float64}, 1}(undef, num_runs)
    incidence_arr_mean = zeros(Float64, (52 * num_years), 4)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"]
        incidence_arr[i] = sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :]
    end

    incidence_arr_mean = zeros(Float64, (52 * num_years), 4)
    for i = 1:(52 * num_years)
        for k = 1:4
            for j = 1:num_runs
                incidence_arr_mean[i, k] += incidence_arr[j][i, k]
            end
            incidence_arr_mean[i, k] /= num_runs
        end
    end

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_mean = cat(
        vec(infected_data_0[2:53, 24:26]),
        vec(infected_data_3[2:53, 24:26]),
        vec(infected_data_7[2:53, 24:26]),
        vec(infected_data_15[2:53, 24:26]),
        dims = 2,
    )

    nMAE_0_2 = sum(abs.(incidence_arr_mean[:, 1] - infected_data_mean[:, 1])) / sum(infected_data_mean[:, 1])
    println("0-2 nMAE: $(nMAE_0_2)")

    nMAE_3_6 = sum(abs.(incidence_arr_mean[:, 2] - infected_data_mean[:, 2])) / sum(infected_data_mean[:, 2])
    println("3-6 nMAE: $(nMAE_3_6)")

    nMAE_7_14 = sum(abs.(incidence_arr_mean[:, 3] - infected_data_mean[:, 3])) / sum(infected_data_mean[:, 3])
    println("7-14 nMAE: $(nMAE_7_14)")

    nMAE_15 = sum(abs.(incidence_arr_mean[:, 4] - infected_data_mean[:, 4])) / sum(infected_data_mean[:, 4])
    println("15+ nMAE: $(nMAE_15)")

    # ------------------

    incidence_arr = Array{Matrix{Float64}, 1}(undef, num_runs)
    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"]
        incidence_arr[i] = sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1]
    end

    incidence_arr_mean = zeros(Float64, (52 * num_years), 7)
    for i = 1:(52 * num_years)
        for k = 1:7
            for j = 1:num_runs
                incidence_arr_mean[i, k] += incidence_arr[j][i, k]
            end
            incidence_arr_mean[i, k] /= num_runs
        end
    end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    infected_data = transpose(infected_data[42:44, 2:53])

    etiology = get_etiology()

    infected_data_1 = etiology[:, 1] .* infected_data
    infected_data_2 = etiology[:, 2] .* infected_data
    infected_data_3 = etiology[:, 3] .* infected_data
    infected_data_4 = etiology[:, 4] .* infected_data
    infected_data_5 = etiology[:, 5] .* infected_data
    infected_data_6 = etiology[:, 6] .* infected_data
    infected_data_7 = etiology[:, 7] .* infected_data
    infected_data_viruses_mean = cat(
        vec(infected_data_1),
        vec(infected_data_2),
        vec(infected_data_3),
        vec(infected_data_4),
        vec(infected_data_5),
        vec(infected_data_6),
        vec(infected_data_7),
        dims = 2)

    nMAE_FluA = sum(abs.(incidence_arr_mean[:, 1] - infected_data_viruses_mean[:, 1])) / sum(infected_data_viruses_mean[:, 1])
    println("FluA nMAE: $(nMAE_FluA)")

    nMAE_FluB = sum(abs.(incidence_arr_mean[:, 2] - infected_data_viruses_mean[:, 2])) / sum(infected_data_viruses_mean[:, 2])
    println("FluB nMAE: $(nMAE_FluB)")

    nMAE_RV = sum(abs.(incidence_arr_mean[:, 3] - infected_data_viruses_mean[:, 3])) / sum(infected_data_viruses_mean[:, 3])
    println("RV nMAE: $(nMAE_RV)")

    nMAE_RSV = sum(abs.(incidence_arr_mean[:, 4] - infected_data_viruses_mean[:, 4])) / sum(infected_data_viruses_mean[:, 4])
    println("RSV nMAE: $(nMAE_RSV)")

    nMAE_AdV = sum(abs.(incidence_arr_mean[:, 5] - infected_data_viruses_mean[:, 5])) / sum(infected_data_viruses_mean[:, 5])
    println("AdV nMAE: $(nMAE_AdV)")

    nMAE_PIV = sum(abs.(incidence_arr_mean[:, 6] - infected_data_viruses_mean[:, 6])) / sum(infected_data_viruses_mean[:, 6])
    println("PIV nMAE: $(nMAE_PIV)")

    nMAE_CoV = sum(abs.(incidence_arr_mean[:, 7] - infected_data_viruses_mean[:, 7])) / sum(infected_data_viruses_mean[:, 7])
    println("CoV nMAE: $(nMAE_CoV)")

    averaged_nMAE = nMAE_FluA + nMAE_FluB + nMAE_RV + nMAE_RSV + nMAE_AdV + nMAE_PIV + nMAE_CoV + nMAE_general + nMAE_0_2 + nMAE_3_6 + nMAE_7_14 + nMAE_15
    println("Averaged nMAE: $(averaged_nMAE / 12)")
end

function plot_incidence()
    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ 10072
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    confidence_model = zeros(Float64, 52)
    for i = 1:52
        confidence_model[i] = confidence([incidence_arr[k, j][i] for j = 1:num_years for k = 1:num_runs])
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean[i] += incidence_arr[k, j][i]
            end
        end
        incidence_arr_mean[i] /= num_runs * num_years
    end    

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n') ./ 10072
    infected_data_mean = mean(infected_data[42:44, 2:53], dims = 1)[1, :]

    confidence_data = zeros(Float64, 52)
    for i = 1:52
        confidence_data[i] = confidence(infected_data[42:44, i + 1])
    end

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
        [incidence_arr_mean infected_data_mean],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        label = label_names,
        grid = true,
        legend = (0.9, 0.98),
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        # ribbon = [confidence_model confidence_data],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "model_incidence_quarantine.pdf" : with_global_warming ? "model_incidence_warming.pdf" : "model_incidence.pdf"))
end

function plot_incidence_scenarios()
    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    confidence_model = zeros(Float64, 52)
    for i = 1:52
        confidence_model[i] = confidence([incidence_arr[k, j][i] for j = 1:num_years for k = 1:num_runs])
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean[i] += incidence_arr[k, j][i]
            end
        end
        incidence_arr_mean[i] /= num_runs * num_years
    end

    incidence_arr_quarantine = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean_quarantine = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses_quarantine = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_quarantine_$(i).jld"))["observed_cases"] ./ 10072
        for j = 1:num_years
            incidence_arr_quarantine[i, j] = sum(sum(observed_num_infected_age_groups_viruses_quarantine, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    confidence_model_quarantine = zeros(Float64, 52)
    for i = 1:52
        confidence_model_quarantine[i] = confidence([incidence_arr_quarantine[k, j][i] for j = 1:num_years for k = 1:num_runs])
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean_quarantine[i] += incidence_arr_quarantine[k, j][i]
            end
        end
        incidence_arr_mean_quarantine[i] /= num_runs * num_years
    end

    incidence_arr_warming = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean_warming = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses_warming = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_warming_$(i).jld"))["observed_cases"] ./ 10072
        for j = 1:num_years
            incidence_arr_warming[i, j] = sum(sum(observed_num_infected_age_groups_viruses_warming, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    confidence_model_warming = zeros(Float64, 52)
    for i = 1:52
        confidence_model_warming[i] = confidence([incidence_arr_warming[k, j][i] for j = 1:num_years for k = 1:num_runs])
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean_warming[i] += incidence_arr_warming[k, j][i]
            end
        end
        incidence_arr_mean_warming[i] /= num_runs * num_years
    end

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    yticks = [0, 4, 8, 12]
    yticklabels = ["0" "4" "8" "12"]

    label_names = ["base" "quarantine" "warming"]
    if is_russian
        label_names = ["базовый" "карантин" "потепление"]
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
        [incidence_arr_mean incidence_arr_mean_quarantine incidence_arr_mean_warming],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        label = label_names,
        grid = true,
        legend = (0.85, 0.98),
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467) RGB(0.133, 0.533, 0.2)],
        ribbon = [confidence_model confidence_model_quarantine confidence_model_warming],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "model_incidence_scenarios.pdf"))
end

function plot_incidence_scenarios_quaranteen()
    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    confidence_model = zeros(Float64, 52)
    for i = 1:52
        confidence_model[i] = confidence([incidence_arr[k, j][i] for j = 1:num_years for k = 1:num_runs])
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean[i] += incidence_arr[k, j][i]
            end
        end
        incidence_arr_mean[i] /= num_runs * num_years
    end

    incidence_arr_quarantine = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean_quarantine = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses_quarantine = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_quarantine_$(i).jld"))["observed_cases"] ./ 10072
        for j = 1:num_years
            incidence_arr_quarantine[i, j] = sum(sum(observed_num_infected_age_groups_viruses_quarantine, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    confidence_model_quarantine = zeros(Float64, 52)
    for i = 1:52
        confidence_model_quarantine[i] = confidence([incidence_arr_quarantine[k, j][i] for j = 1:num_years for k = 1:num_runs])
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean_quarantine[i] += incidence_arr_quarantine[k, j][i]
            end
        end
        incidence_arr_mean_quarantine[i] /= num_runs * num_years
    end

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    yticks = [0, 4, 8, 12]
    yticklabels = ["0" "4" "8" "12"]

    label_names = ["base" "quarantine" "warming"]
    if is_russian
        label_names = ["базовый" "карантин"]
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
        [incidence_arr_mean incidence_arr_mean_quarantine],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        label = label_names,
        grid = true,
        legend = (0.85, 0.98),
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        ribbon = [confidence_model confidence_model_quarantine],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "model_incidence_scenarios_quaranteen.pdf"))
end

function plot_incidence_scenarios_warming()
    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    confidence_model = zeros(Float64, 52)
    for i = 1:52
        confidence_model[i] = confidence([incidence_arr[k, j][i] for j = 1:num_years for k = 1:num_runs])
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean[i] += incidence_arr[k, j][i]
            end
        end
        incidence_arr_mean[i] /= num_runs * num_years
    end

    incidence_arr_warming = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean_warming = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses_warming = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_warming_$(i).jld"))["observed_cases"] ./ 10072
        for j = 1:num_years
            incidence_arr_warming[i, j] = sum(sum(observed_num_infected_age_groups_viruses_warming, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    confidence_model_warming = zeros(Float64, 52)
    for i = 1:52
        confidence_model_warming[i] = confidence([incidence_arr_warming[k, j][i] for j = 1:num_years for k = 1:num_runs])
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean_warming[i] += incidence_arr_warming[k, j][i]
            end
        end
        incidence_arr_mean_warming[i] /= num_runs * num_years
    end

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    yticks = [0, 4, 8, 12]
    yticklabels = ["0" "4" "8" "12"]

    label_names = ["base" "warming"]
    if is_russian
        label_names = ["базовый" "потепление"]
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
        [incidence_arr_mean incidence_arr_mean_warming],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        label = label_names,
        grid = true,
        legend = (0.85, 0.98),
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        ribbon = [confidence_model confidence_model_warming],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "model_incidence_scenarios_warming.pdf"))
end

function plot_incidence_age_groups()
    incidence_arr = Array{Matrix{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52, 4)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ 10072
        for j = 1:num_years
            incidence_arr[i, j] = sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :][(52 * (j - 1) + 1):(52 * (j - 1) + 52), :]
        end
    end

    for i = 1:52
        for k = 1:4
            for j = 1:num_runs
                for z = 1:num_years
                    incidence_arr_mean[i, k] += incidence_arr[j, z][i, k]
                end
            end
            incidence_arr_mean[i, k] /= num_runs * num_years
        end
    end

    confidence_model = zeros(Float64, 52, 4)
    for i = 1:52
        for k = 1:4
            confidence_model[i, k] = confidence([incidence_arr[j, z][i, k] for j = 1:num_runs for z = 1:num_years])
        end
    end

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n') ./ 10072
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n') ./ 10072
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n') ./ 10072
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n') ./ 10072

    infected_data_mean = cat(
        mean(infected_data_0[2:53, 24:26], dims = 2)[:, 1],
        mean(infected_data_3[2:53, 24:26], dims = 2)[:, 1],
        mean(infected_data_7[2:53, 24:26], dims = 2)[:, 1],
        mean(infected_data_15[2:53, 24:26], dims = 2)[:, 1],
        dims = 2,
    )

    confidence_data = zeros(Float64, 52, 4)
    for i = 1:52
        confidence_data[i, 1] = confidence(infected_data_0[i + 1, 24:26])
        confidence_data[i, 2] = confidence(infected_data_3[i + 1, 24:26])
        confidence_data[i, 3] = confidence(infected_data_7[i + 1, 24:26])
        confidence_data[i, 4] = confidence(infected_data_15[i + 1, 24:26])
    end

    ticks = range(1, stop = 52, length = 7)

    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

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

    age_groups = ["0-2", "3-6", "7-14", "15+"]
    for i = 1:4
        incidence_plot = plot(
            1:52,
            [incidence_arr_mean[:, i] infected_data_mean[:, i]],
            lw = 1.5,
            xticks = (ticks, ticklabels),
            label = label_names,
            grid = true,
            legend = (0.9, 0.98),
            color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
            # ribbon = [confidence_model[:, i] confidence_data[:, i]],
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
        savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "incidence$(age_groups[i])_quarantine.pdf" : with_global_warming ? "incidence$(age_groups[i])_warming.pdf" : "incidence$(age_groups[i]).pdf"))
    end
end

function plot_incidence_viruses()
    incidence_arr = Array{Matrix{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52, 7)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ 10072
        for j = 1:num_years
            incidence_arr[i, j] = sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52), :]
        end
    end

    for i = 1:52
        for k = 1:7
            for j = 1:num_runs
                for z = 1:num_years
                    incidence_arr_mean[i, k] += incidence_arr[j, z][i, k]
                end
            end
            incidence_arr_mean[i, k] /= num_runs * num_years
        end
    end

    confidence_model = zeros(Float64, 52, 7)
    for i = 1:52
        for k = 1:7
            confidence_model[i, k] = confidence([incidence_arr[j, z][i, k] for j = 1:num_runs for z = 1:num_years])
        end
    end

    # incidence_arr = Array{Matrix{Float64}, 1}(undef, num_runs)

    # for i = 1:num_runs
    #     observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
    #     incidence_arr[i] = sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1]
    # end

    # incidence = zeros(Float64, 52, 7)
    # for i = 1:52
    #     for k = 1:7
    #         for j = 1:num_runs
    #             incidence[i, k] += incidence_arr[j][i, k]
    #         end
    #         incidence[i, k] /= num_runs
    #     end
    # end

    # confidence_model = zeros(Float64, 52, 7)
    # for i = 1:52
    #     for k = 1:7
    #         confidence_model[i, k] = confidence([incidence_arr[j][i, k] for j = 1:num_runs])
    #     end
    # end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n') ./ 10072

    FluA_arr = [1.0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 25, 50, 60, 75, 310, 1675, 1850, 1500, 1250, 900, 375, 350, 290, 220, 175, 165, 100, 50, 40, 25, 15, 9, 4, 2, 1, 1, 1, 1, 1, 1, 1, 1]
    FluA_arr2 = [1.0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 15, 44, 72, 50, 10, 80, 266, 333, 480, 588, 625, 575, 622, 423, 450, 269, 190, 138, 89, 60, 30, 20, 12, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1]

    RV_arr = [50.0, 50, 86, 90, 70, 74, 97, 115, 158, 130, 131, 103, 112, 112, 136, 90, 111, 128, 130, 140, 118, 152, 49, 22, 51, 80, 82, 100, 78, 57, 70, 73, 102, 101, 80, 62, 68, 60, 66, 52, 42, 69, 74, 38, 50, 42, 36, 38, 24, 44, 45, 40]
    RV_arr2 = [11.0, 10, 20, 24, 10, 20, 41, 42, 43, 54, 42, 52, 39, 37, 20, 15, 20, 38, 41, 28, 30, 21, 9, 1, 10, 50, 62, 52, 31, 40, 36, 41, 42, 32, 84, 71, 78, 72, 32, 28, 39, 37, 72, 67, 41, 52, 40, 24, 40, 39, 36, 30]
    
    RSV_arr = [8.0, 8, 8, 8, 8, 5, 7, 8, 11, 11, 18, 14, 15, 18, 35, 55, 53, 70, 90, 130, 45, 30, 80, 140, 100, 120, 145, 180, 150, 68, 72, 60, 80, 75, 55, 60, 65, 62, 50, 45, 50, 20, 24, 19, 15, 10, 10, 9, 11, 10, 9, 8]
    RSV_arr2 = [8.0, 9, 9, 4, 4, 10, 9, 10, 3, 12, 8, 10, 12, 7, 10, 13, 9, 15, 21, 25, 30, 10, 2, 22, 18, 30, 77, 72, 48, 61, 90, 120, 150, 145, 92, 119, 78, 69, 49, 57, 49, 43, 46, 24, 40, 24, 24, 10, 10, 9, 7, 11]

    AdV_arr = [20.0, 30, 40, 20, 30, 25, 15, 19, 17, 18, 20, 25, 30, 21, 38, 40, 42, 30, 40, 50, 51, 41, 10, 8, 30, 40, 38, 70, 67, 20, 28, 20, 29, 20, 28, 16, 10, 20, 18, 27, 19, 19, 32, 31, 20, 20, 15, 8, 20, 35, 35, 35]
    AdV_arr2 = [9.0, 11, 13, 5, 7, 12, 12, 18, 16, 22, 18, 22, 31, 32, 33, 17, 28, 39, 29, 40, 30, 56, 11, 1, 38, 30, 39, 28, 59, 19, 46, 20, 22, 47, 38, 40, 25, 17, 18, 10, 6, 6, 21, 11, 19, 12, 27, 18, 10, 27, 10, 10]

    PIV_arr = [15.0, 18, 20, 33, 15, 36, 33, 38, 38, 50, 40, 43, 46, 75, 55, 35, 85, 53, 65, 40, 70, 20, 10, 45, 32, 33, 51, 34, 22, 12, 12, 14, 16, 18, 20, 8, 24, 20, 15, 5, 20, 15, 15, 20, 19, 18, 31, 18, 18, 17, 15, 14]
    PIV_arr2 = [10.0, 11, 6, 8, 12, 19, 22, 20, 20, 22, 28, 32, 47, 29, 31, 38, 17, 40, 31, 36, 32, 48, 11, 6, 30, 38, 12, 30, 22, 12, 20, 17, 30, 45, 11, 14, 17, 15, 15, 10, 15, 20, 17, 18, 23, 10, 10, 18, 17, 16, 17, 14]

    CoV_arr = [1.0, 2, 1, 2, 1, 1, 2, 1, 2, 1, 1, 2, 8, 10, 5, 7, 7, 14, 8, 25, 35, 30, 1, 5, 16, 14, 25, 35, 32, 50, 10, 18, 12, 30, 36, 25, 14, 16, 5, 3, 1, 3, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    CoV_arr2 = [5.0, 1, 1, 2, 1, 1, 6, 1, 3, 1, 1, 5, 9, 1, 5, 1, 1, 5, 1, 3, 2, 1, 5, 1, 3, 1, 1, 9, 5, 5, 9, 3, 4, 3, 12, 18, 16, 15, 7, 1, 13, 3, 3, 10, 2, 1, 1, 1, 1, 1, 1, 1]

    FluA_arr = moving_average(FluA_arr, 3)
    RV_arr = moving_average(RV_arr, 3)
    RSV_arr = moving_average(RSV_arr, 3)
    AdV_arr = moving_average(AdV_arr, 3)
    PIV_arr = moving_average(PIV_arr, 3)
    CoV_arr = moving_average(CoV_arr, 3)

    FluA_arr2 = moving_average(FluA_arr2, 3)
    RV_arr2 = moving_average(RV_arr2, 3)
    RSV_arr2 = moving_average(RSV_arr2, 3)
    AdV_arr2 = moving_average(AdV_arr2, 3)
    PIV_arr2 = moving_average(PIV_arr2, 3)
    CoV_arr2 = moving_average(CoV_arr2, 3)

    FluB_arr = FluA_arr .* 1/3
    FluB_arr2 = FluA_arr2 .* 1/3

    sum_arr = FluA_arr + FluB_arr + RV_arr + RSV_arr + AdV_arr + PIV_arr + CoV_arr
    sum_arr2 = FluA_arr2 + FluB_arr2 + RV_arr2 + RSV_arr2 + AdV_arr2 + PIV_arr2 + CoV_arr2

    FluA_ratio = FluA_arr ./ sum_arr
    FluB_ratio = FluB_arr ./ sum_arr
    RV_ratio = RV_arr ./ sum_arr
    RSV_ratio = RSV_arr ./ sum_arr
    AdV_ratio = AdV_arr ./ sum_arr
    PIV_ratio = PIV_arr ./ sum_arr
    CoV_ratio = CoV_arr ./ sum_arr

    FluA_ratio2 = FluA_arr2 ./ sum_arr2
    FluB_ratio2 = FluB_arr2 ./ sum_arr2
    RV_ratio2 = RV_arr2 ./ sum_arr2
    RSV_ratio2 = RSV_arr2 ./ sum_arr2
    AdV_ratio2 = AdV_arr2 ./ sum_arr2
    PIV_ratio2 = PIV_arr2 ./ sum_arr2
    CoV_ratio2 = CoV_arr2 ./ sum_arr2

    FluA_ratio = moving_average(FluA_ratio, 3)
    FluB_ratio = moving_average(FluB_ratio, 3)
    RV_ratio = moving_average(RV_ratio, 3)
    RSV_ratio = moving_average(RSV_ratio, 3)
    AdV_ratio = moving_average(AdV_ratio, 3)
    PIV_ratio = moving_average(PIV_ratio, 3)
    CoV_ratio = moving_average(CoV_ratio, 3)

    FluA_ratio2 = moving_average(FluA_ratio2, 3)
    FluB_ratio2 = moving_average(FluB_ratio2, 3)
    RV_ratio2 = moving_average(RV_ratio2, 3)
    RSV_ratio2 = moving_average(RSV_ratio2, 3)
    AdV_ratio2 = moving_average(AdV_ratio2, 3)
    PIV_ratio2 = moving_average(PIV_ratio2, 3)
    CoV_ratio2 = moving_average(CoV_ratio2, 3)

    etiology = hcat(FluA_ratio, FluB_ratio, RV_ratio, RSV_ratio, AdV_ratio, PIV_ratio, CoV_ratio)
    etiology2 = hcat(FluA_ratio2, FluB_ratio2, RV_ratio2, RSV_ratio2, AdV_ratio2, PIV_ratio2, CoV_ratio2)

    infected_data = infected_data[42:44, 2:53]'

    etiology = get_etiology()

    infected_data_1 = etiology[:, 1] .* infected_data
    infected_data_2 = etiology[:, 2] .* infected_data
    infected_data_3 = etiology[:, 3] .* infected_data
    infected_data_4 = etiology[:, 4] .* infected_data
    infected_data_5 = etiology[:, 5] .* infected_data
    infected_data_6 = etiology[:, 6] .* infected_data
    infected_data_7 = etiology[:, 7] .* infected_data
    infected_data_viruses = cat(
        infected_data_1,
        infected_data_2,
        infected_data_3,
        infected_data_4,
        infected_data_5,
        infected_data_6,
        infected_data_7,
        dims = 3)

    infected_data_viruses_mean = mean(infected_data_viruses, dims = 2)[:, 1, :]

    infected_data_1 = etiology[:, 1] .* infected_data
    infected_data_2 = etiology[:, 2] .* infected_data
    infected_data_3 = etiology[:, 3] .* infected_data
    infected_data_4 = etiology[:, 4] .* infected_data
    infected_data_5 = etiology[:, 5] .* infected_data
    infected_data_6 = etiology[:, 6] .* infected_data
    infected_data_7 = etiology[:, 7] .* infected_data

    infected_data_viruses_1 = cat(
        infected_data_1,
        infected_data_2,
        infected_data_3,
        infected_data_4,
        infected_data_5,
        infected_data_6,
        infected_data_7,
        dims = 3)
    infected_data_1_2 = etiology2[:, 1] .* infected_data
    infected_data_2_2 = etiology2[:, 2] .* infected_data
    infected_data_3_2 = etiology2[:, 3] .* infected_data
    infected_data_4_2 = etiology2[:, 4] .* infected_data
    infected_data_5_2 = etiology2[:, 5] .* infected_data
    infected_data_6_2 = etiology2[:, 6] .* infected_data
    infected_data_7_2 = etiology2[:, 7] .* infected_data
    infected_data_viruses_2 = cat(
        infected_data_1_2,
        infected_data_2_2,
        infected_data_3_2,
        infected_data_4_2,
        infected_data_5_2,
        infected_data_6_2,
        infected_data_7_2,
        dims = 3)

    infected_data_viruses = (infected_data_viruses_1 + infected_data_viruses_2) ./ 2
    infected_data_viruses = cat(infected_data_viruses_1, infected_data_viruses_2, dims = 2)

    infected_data_viruses_confidence = zeros(Float64, 52, 7)
    for i = 1:52
        for j = 1:7
            infected_data_viruses_confidence[i, j] = confidence(infected_data_viruses[i, :, j])
        end
    end

    ticks = range(1, stop = 52, length = 7)

    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

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

    viruses = ["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"]
    for i in 1:7
        incidence_plot = plot(
            1:52,
            [incidence_arr_mean[:, i] infected_data_viruses_mean[:, i]],
            lw = 1.5,
            xticks = (ticks, ticklabels),
            label = label_names,
            grid = true,
            legend = (0.9, 0.98),
            color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
            # color = [RGB(0.5, 0.5, 0.5) RGB(0.933, 0.4, 0.467)],
            # ribbon = [confidence_model[:, i] infected_data_viruses_confidence[:, i]],
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
        savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "incidence$(viruses[i])_quarantine.pdf" : with_global_warming ? "incidence$(viruses[i])_warming.pdf" : "incidence$(viruses[i]).pdf"))
    end


    # incidence_plot = plot(
    #     1:52,
    #     [incidence_arr_mean[:, i] infected_data_viruses_mean[:, i]],
    #     lw = 1.5,
    #     xticks = (ticks, ticklabels),
    #     label = label_names,
    #     grid = true,
    #     legend = (0.9, 0.98),
    #     color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
    #     # color = [RGB(0.5, 0.5, 0.5) RGB(0.933, 0.4, 0.467)],
    #     ribbon = [confidence_model[:, i] infected_data_viruses_confidence[:, i]],
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )
    # savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "incidence$(viruses[i])_quarantine.pdf" : "incidence$(viruses[i]).pdf"))
end

# function plot_incidence_etiology()
#     etiology = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "etiology_data.csv"), ',', Float64)

#     etiology_sum = sum(etiology, dims = 2)
#     for i = 1:7
#         etiology[:, i] = etiology[:, i] ./ etiology_sum[:, 1]
#     end

#     ticks = range(1, stop = 52, length = 7)
    
#     ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
#     if is_russian
#         ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
#     end

#     xlabel_name = L"\textrm{\sffamily Month}"
#     if is_russian
#         xlabel_name = "Месяц"
#     end

#     ylabel_name = L"\textrm{\sffamily Ratio}"
#     if is_russian
#         ylabel_name = "Доля"
#     end

#     yticks = [0.1, 0.3, 0.5, 0.7]
#     yticklabels = ["0.1", "0.3", "0.5", "0.7"]
#     etiology_incidence_plot = plot(
#         1:52,
#         [etiology[:, i] for i = 1:7],
#         lw = 1.5,
#         xticks = (ticks, ticklabels),
#         yticks = (yticks, yticklabels),
#         legend = (0.5, 0.97),
#         # color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
#         color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
#         label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
#         grid = true,
#         xlabel = xlabel_name,
#         ylabel = ylabel_name,
#     )
#     savefig(etiology_incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "model_etiology.pdf"))
# end

# function plot_incidence_age_groups_viruses()
#     age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_1.jld"))["observed_cases"]
#     ticks = range(1, stop = 52, length = 7)
    
#     ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
#     if is_russian
#         ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
#     end

#     label_names = ["model" "data"]
#     if is_russian
#         label_names = ["модель" "данные"]
#     end

#     # xlabel_name = L"\textrm{\sffamily Month}"
#     xlabel_name = "Month"
#     if is_russian
#         xlabel_name = "Месяц"
#     end

#     # ylabel_name = L"\textrm{\sffamily Cases per 1000 people in a week}"
#     # ylabel_name = "Cases per 1000 people in a week"
#     ylabel_name = "Weekly incidence rate per 1000"
#     if is_russian
#         ylabel_name = "Число случаев на 1000 чел. / неделя"
#     end

#     etiology = get_etiology()

#     infected_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n') ./ 10072
#     infected_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n') ./ 10072
#     infected_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n') ./ 10072
#     infected_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n') ./ 10072

#     infected_data_0 = infected_data_0[2:53, 21:27]
#     infected_data_0_1 = etiology[:, 1] .* infected_data_0
#     infected_data_0_2 = etiology[:, 2] .* infected_data_0
#     infected_data_0_3 = etiology[:, 3] .* infected_data_0
#     infected_data_0_4 = etiology[:, 4] .* infected_data_0
#     infected_data_0_5 = etiology[:, 5] .* infected_data_0
#     infected_data_0_6 = etiology[:, 6] .* infected_data_0
#     infected_data_0_7 = etiology[:, 7] .* infected_data_0
#     infected_data_0_viruses = cat(
#         infected_data_0_1,
#         infected_data_0_2,
#         infected_data_0_3,
#         infected_data_0_4,
#         infected_data_0_5,
#         infected_data_0_6,
#         infected_data_0_7,
#         dims = 3)

#     infected_data_3 = infected_data_3[2:53, 21:27]
#     infected_data_3_1 = etiology[:, 1] .* infected_data_3
#     infected_data_3_2 = etiology[:, 2] .* infected_data_3
#     infected_data_3_3 = etiology[:, 3] .* infected_data_3
#     infected_data_3_4 = etiology[:, 4] .* infected_data_3
#     infected_data_3_5 = etiology[:, 5] .* infected_data_3
#     infected_data_3_6 = etiology[:, 6] .* infected_data_3
#     infected_data_3_7 = etiology[:, 7] .* infected_data_3
#     infected_data_3_viruses = cat(
#         infected_data_3_1,
#         infected_data_3_2,
#         infected_data_3_3,
#         infected_data_3_4,
#         infected_data_3_5,
#         infected_data_3_6,
#         infected_data_3_7,
#         dims = 3)

#     infected_data_7 = infected_data_7[2:53, 21:27]
#     infected_data_7_1 = etiology[:, 1] .* infected_data_7
#     infected_data_7_2 = etiology[:, 2] .* infected_data_7
#     infected_data_7_3 = etiology[:, 3] .* infected_data_7
#     infected_data_7_4 = etiology[:, 4] .* infected_data_7
#     infected_data_7_5 = etiology[:, 5] .* infected_data_7
#     infected_data_7_6 = etiology[:, 6] .* infected_data_7
#     infected_data_7_7 = etiology[:, 7] .* infected_data_7
#     infected_data_7_viruses = cat(
#         infected_data_7_1,
#         infected_data_7_2,
#         infected_data_7_3,
#         infected_data_7_4,
#         infected_data_7_5,
#         infected_data_7_6,
#         infected_data_7_7,
#         dims = 3)

#     infected_data_15 = infected_data_15[2:53, 21:27]
#     infected_data_15_1 = etiology[:, 1] .* infected_data_15
#     infected_data_15_2 = etiology[:, 2] .* infected_data_15
#     infected_data_15_3 = etiology[:, 3] .* infected_data_15
#     infected_data_15_4 = etiology[:, 4] .* infected_data_15
#     infected_data_15_5 = etiology[:, 5] .* infected_data_15
#     infected_data_15_6 = etiology[:, 6] .* infected_data_15
#     infected_data_15_7 = etiology[:, 7] .* infected_data_15
#     infected_data_15_viruses = cat(
#         infected_data_15_1,
#         infected_data_15_2,
#         infected_data_15_3,
#         infected_data_15_4,
#         infected_data_15_5,
#         infected_data_15_6,
#         infected_data_15_7,
#         dims = 3)

#     infected_data_0_viruses_mean = mean(infected_data_0_viruses, dims = 2)[:, 1, :]
#     infected_data_3_viruses_mean = mean(infected_data_3_viruses, dims = 2)[:, 1, :]
#     infected_data_7_viruses_mean = mean(infected_data_7_viruses, dims = 2)[:, 1, :]
#     infected_data_15_viruses_mean = mean(infected_data_15_viruses, dims = 2)[:, 1, :]

#     num_infected_age_groups_viruses_mean = cat(
#         infected_data_0_viruses_mean,
#         infected_data_3_viruses_mean,
#         infected_data_7_viruses_mean,
#         infected_data_15_viruses_mean,
#         dims = 3,
#     )

#     FluA_arr = [1.0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 25, 50, 60, 75, 310, 1675, 1850, 1500, 1250, 900, 375, 350, 290, 220, 175, 165, 100, 50, 40, 25, 15, 9, 4, 2, 1, 1, 1, 1, 1, 1, 1, 1]
#     FluA_arr2 = [1.0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 15, 44, 72, 50, 10, 80, 266, 333, 480, 588, 625, 575, 622, 423, 450, 269, 190, 138, 89, 60, 30, 20, 12, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1]

#     RV_arr = [50.0, 50, 86, 90, 70, 74, 97, 115, 158, 130, 131, 103, 112, 112, 136, 90, 111, 128, 130, 140, 118, 152, 49, 22, 51, 80, 82, 100, 78, 57, 70, 73, 102, 101, 80, 62, 68, 60, 66, 52, 42, 69, 74, 38, 50, 42, 36, 38, 24, 44, 45, 40]
#     RV_arr2 = [11.0, 10, 20, 24, 10, 20, 41, 42, 43, 54, 42, 52, 39, 37, 20, 15, 20, 38, 41, 28, 30, 21, 9, 1, 10, 50, 62, 52, 31, 40, 36, 41, 42, 32, 84, 71, 78, 72, 32, 28, 39, 37, 72, 67, 41, 52, 40, 24, 40, 39, 36, 30]
    
#     RSV_arr = [8.0, 8, 8, 8, 8, 5, 7, 8, 11, 11, 18, 14, 15, 18, 35, 55, 53, 70, 90, 130, 45, 30, 80, 140, 100, 120, 145, 180, 150, 68, 72, 60, 80, 75, 55, 60, 65, 62, 50, 45, 50, 20, 24, 19, 15, 10, 10, 9, 11, 10, 9, 8]
#     RSV_arr2 = [8.0, 9, 9, 4, 4, 10, 9, 10, 3, 12, 8, 10, 12, 7, 10, 13, 9, 15, 21, 25, 30, 10, 2, 22, 18, 30, 77, 72, 48, 61, 90, 120, 150, 145, 92, 119, 78, 69, 49, 57, 49, 43, 46, 24, 40, 24, 24, 10, 10, 9, 7, 11]

#     AdV_arr = [20.0, 30, 40, 20, 30, 25, 15, 19, 17, 18, 20, 25, 30, 21, 38, 40, 42, 30, 40, 50, 51, 41, 10, 8, 30, 40, 38, 70, 67, 20, 28, 20, 29, 20, 28, 16, 10, 20, 18, 27, 19, 19, 32, 31, 20, 20, 15, 8, 20, 35, 35, 35]
#     AdV_arr2 = [9.0, 11, 13, 5, 7, 12, 12, 18, 16, 22, 18, 22, 31, 32, 33, 17, 28, 39, 29, 40, 30, 56, 11, 1, 38, 30, 39, 28, 59, 19, 46, 20, 22, 47, 38, 40, 25, 17, 18, 10, 6, 6, 21, 11, 19, 12, 27, 18, 10, 27, 10, 10]

#     PIV_arr = [15.0, 18, 20, 33, 15, 36, 33, 38, 38, 50, 40, 43, 46, 75, 55, 35, 85, 53, 65, 40, 70, 20, 10, 45, 32, 33, 51, 34, 22, 12, 12, 14, 16, 18, 20, 8, 24, 20, 15, 5, 20, 15, 15, 20, 19, 18, 31, 18, 18, 17, 15, 14]
#     PIV_arr2 = [10.0, 11, 6, 8, 12, 19, 22, 20, 20, 22, 28, 32, 47, 29, 31, 38, 17, 40, 31, 36, 32, 48, 11, 6, 30, 38, 12, 30, 22, 12, 20, 17, 30, 45, 11, 14, 17, 15, 15, 10, 15, 20, 17, 18, 23, 10, 10, 18, 17, 16, 17, 14]

#     CoV_arr = [1.0, 2, 1, 2, 1, 1, 2, 1, 2, 1, 1, 2, 8, 10, 5, 7, 7, 14, 8, 25, 35, 30, 1, 5, 16, 14, 25, 35, 32, 50, 10, 18, 12, 30, 36, 25, 14, 16, 5, 3, 1, 3, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
#     CoV_arr2 = [5.0, 1, 1, 2, 1, 1, 6, 1, 3, 1, 1, 5, 9, 1, 5, 1, 1, 5, 1, 3, 2, 1, 5, 1, 3, 1, 1, 9, 5, 5, 9, 3, 4, 3, 12, 18, 16, 15, 7, 1, 13, 3, 3, 10, 2, 1, 1, 1, 1, 1, 1, 1]

#     FluA_arr = moving_average(FluA_arr, 3)
#     RV_arr = moving_average(RV_arr, 3)
#     RSV_arr = moving_average(RSV_arr, 3)
#     AdV_arr = moving_average(AdV_arr, 3)
#     PIV_arr = moving_average(PIV_arr, 3)
#     CoV_arr = moving_average(CoV_arr, 3)

#     FluA_arr2 = moving_average(FluA_arr2, 3)
#     RV_arr2 = moving_average(RV_arr2, 3)
#     RSV_arr2 = moving_average(RSV_arr2, 3)
#     AdV_arr2 = moving_average(AdV_arr2, 3)
#     PIV_arr2 = moving_average(PIV_arr2, 3)
#     CoV_arr2 = moving_average(CoV_arr2, 3)

#     FluB_arr = FluA_arr .* 1/3
#     FluB_arr2 = FluA_arr2 .* 1/3

#     sum_arr = FluA_arr + FluB_arr + RV_arr + RSV_arr + AdV_arr + PIV_arr + CoV_arr
#     sum_arr2 = FluA_arr2 + FluB_arr2 + RV_arr2 + RSV_arr2 + AdV_arr2 + PIV_arr2 + CoV_arr2

#     FluA_ratio = FluA_arr ./ sum_arr
#     FluB_ratio = FluB_arr ./ sum_arr
#     RV_ratio = RV_arr ./ sum_arr
#     RSV_ratio = RSV_arr ./ sum_arr
#     AdV_ratio = AdV_arr ./ sum_arr
#     PIV_ratio = PIV_arr ./ sum_arr
#     CoV_ratio = CoV_arr ./ sum_arr

#     FluA_ratio2 = FluA_arr2 ./ sum_arr2
#     FluB_ratio2 = FluB_arr2 ./ sum_arr2
#     RV_ratio2 = RV_arr2 ./ sum_arr2
#     RSV_ratio2 = RSV_arr2 ./ sum_arr2
#     AdV_ratio2 = AdV_arr2 ./ sum_arr2
#     PIV_ratio2 = PIV_arr2 ./ sum_arr2
#     CoV_ratio2 = CoV_arr2 ./ sum_arr2

#     FluA_ratio = moving_average(FluA_ratio, 3)
#     FluB_ratio = moving_average(FluB_ratio, 3)
#     RV_ratio = moving_average(RV_ratio, 3)
#     RSV_ratio = moving_average(RSV_ratio, 3)
#     AdV_ratio = moving_average(AdV_ratio, 3)
#     PIV_ratio = moving_average(PIV_ratio, 3)
#     CoV_ratio = moving_average(CoV_ratio, 3)

#     FluA_ratio2 = moving_average(FluA_ratio2, 3)
#     FluB_ratio2 = moving_average(FluB_ratio2, 3)
#     RV_ratio2 = moving_average(RV_ratio2, 3)
#     RSV_ratio2 = moving_average(RSV_ratio2, 3)
#     AdV_ratio2 = moving_average(AdV_ratio2, 3)
#     PIV_ratio2 = moving_average(PIV_ratio2, 3)
#     CoV_ratio2 = moving_average(CoV_ratio2, 3)

#     etiology = hcat(FluA_ratio, FluB_ratio, RV_ratio, RSV_ratio, AdV_ratio, PIV_ratio, CoV_ratio)
#     etiology2 = hcat(FluA_ratio2, FluB_ratio2, RV_ratio2, RSV_ratio2, AdV_ratio2, PIV_ratio2, CoV_ratio2)

#     infected_data_0_1 = etiology[:, 1] .* infected_data_0
#     infected_data_0_2 = etiology[:, 2] .* infected_data_0
#     infected_data_0_3 = etiology[:, 3] .* infected_data_0
#     infected_data_0_4 = etiology[:, 4] .* infected_data_0
#     infected_data_0_5 = etiology[:, 5] .* infected_data_0
#     infected_data_0_6 = etiology[:, 6] .* infected_data_0
#     infected_data_0_7 = etiology[:, 7] .* infected_data_0

#     infected_data_0_viruses_1 = cat(
#         infected_data_0_1,
#         infected_data_0_2,
#         infected_data_0_3,
#         infected_data_0_4,
#         infected_data_0_5,
#         infected_data_0_6,
#         infected_data_0_7,
#         dims = 3)
#     infected_data_0_1_2 = etiology2[:, 1] .* infected_data_0
#     infected_data_0_2_2 = etiology2[:, 2] .* infected_data_0
#     infected_data_0_3_2 = etiology2[:, 3] .* infected_data_0
#     infected_data_0_4_2 = etiology2[:, 4] .* infected_data_0
#     infected_data_0_5_2 = etiology2[:, 5] .* infected_data_0
#     infected_data_0_6_2 = etiology2[:, 6] .* infected_data_0
#     infected_data_0_7_2 = etiology2[:, 7] .* infected_data_0
#     infected_data_0_viruses_2 = cat(
#         infected_data_0_1_2,
#         infected_data_0_2_2,
#         infected_data_0_3_2,
#         infected_data_0_4_2,
#         infected_data_0_5_2,
#         infected_data_0_6_2,
#         infected_data_0_7_2,
#         dims = 3)

#     infected_data_3_1 = etiology[:, 1] .* infected_data_3
#     infected_data_3_2 = etiology[:, 2] .* infected_data_3
#     infected_data_3_3 = etiology[:, 3] .* infected_data_3
#     infected_data_3_4 = etiology[:, 4] .* infected_data_3
#     infected_data_3_5 = etiology[:, 5] .* infected_data_3
#     infected_data_3_6 = etiology[:, 6] .* infected_data_3
#     infected_data_3_7 = etiology[:, 7] .* infected_data_3
#     infected_data_3_viruses_1 = cat(
#         infected_data_3_1,
#         infected_data_3_2,
#         infected_data_3_3,
#         infected_data_3_4,
#         infected_data_3_5,
#         infected_data_3_6,
#         infected_data_3_7,
#         dims = 3)
#     infected_data_3_1_2 = etiology2[:, 1] .* infected_data_3
#     infected_data_3_2_2 = etiology2[:, 2] .* infected_data_3
#     infected_data_3_3_2 = etiology2[:, 3] .* infected_data_3
#     infected_data_3_4_2 = etiology2[:, 4] .* infected_data_3
#     infected_data_3_5_2 = etiology2[:, 5] .* infected_data_3
#     infected_data_3_6_2 = etiology2[:, 6] .* infected_data_3
#     infected_data_3_7_2 = etiology2[:, 7] .* infected_data_3
#     infected_data_3_viruses_2 = cat(
#         infected_data_3_1_2,
#         infected_data_3_2_2,
#         infected_data_3_3_2,
#         infected_data_3_4_2,
#         infected_data_3_5_2,
#         infected_data_3_6_2,
#         infected_data_3_7_2,
#         dims = 3)

#     infected_data_7_1 = etiology[:, 1] .* infected_data_7
#     infected_data_7_2 = etiology[:, 2] .* infected_data_7
#     infected_data_7_3 = etiology[:, 3] .* infected_data_7
#     infected_data_7_4 = etiology[:, 4] .* infected_data_7
#     infected_data_7_5 = etiology[:, 5] .* infected_data_7
#     infected_data_7_6 = etiology[:, 6] .* infected_data_7
#     infected_data_7_7 = etiology[:, 7] .* infected_data_7
#     infected_data_7_viruses_1 = cat(
#         infected_data_7_1,
#         infected_data_7_2,
#         infected_data_7_3,
#         infected_data_7_4,
#         infected_data_7_5,
#         infected_data_7_6,
#         infected_data_7_7,
#         dims = 3)
#     infected_data_7_1_2 = etiology2[:, 1] .* infected_data_7
#     infected_data_7_2_2 = etiology2[:, 2] .* infected_data_7
#     infected_data_7_3_2 = etiology2[:, 3] .* infected_data_7
#     infected_data_7_4_2 = etiology2[:, 4] .* infected_data_7
#     infected_data_7_5_2 = etiology2[:, 5] .* infected_data_7
#     infected_data_7_6_2 = etiology2[:, 6] .* infected_data_7
#     infected_data_7_7_2 = etiology2[:, 7] .* infected_data_7
#     infected_data_7_viruses_2 = cat(
#         infected_data_7_1_2,
#         infected_data_7_2_2,
#         infected_data_7_3_2,
#         infected_data_7_4_2,
#         infected_data_7_5_2,
#         infected_data_7_6_2,
#         infected_data_7_7_2,
#         dims = 3)

#     infected_data_15_1 = etiology[:, 1] .* infected_data_15
#     infected_data_15_2 = etiology[:, 2] .* infected_data_15
#     infected_data_15_3 = etiology[:, 3] .* infected_data_15
#     infected_data_15_4 = etiology[:, 4] .* infected_data_15
#     infected_data_15_5 = etiology[:, 5] .* infected_data_15
#     infected_data_15_6 = etiology[:, 6] .* infected_data_15
#     infected_data_15_7 = etiology[:, 7] .* infected_data_15
#     infected_data_15_viruses_1 = cat(
#         infected_data_15_1,
#         infected_data_15_2,
#         infected_data_15_3,
#         infected_data_15_4,
#         infected_data_15_5,
#         infected_data_15_6,
#         infected_data_15_7,
#         dims = 3)
#     infected_data_15_1_2 = etiology2[:, 1] .* infected_data_15
#     infected_data_15_2_2 = etiology2[:, 2] .* infected_data_15
#     infected_data_15_3_2 = etiology2[:, 3] .* infected_data_15
#     infected_data_15_4_2 = etiology2[:, 4] .* infected_data_15
#     infected_data_15_5_2 = etiology2[:, 5] .* infected_data_15
#     infected_data_15_6_2 = etiology2[:, 6] .* infected_data_15
#     infected_data_15_7_2 = etiology2[:, 7] .* infected_data_15
#     infected_data_15_viruses_2 = cat(
#         infected_data_15_1_2,
#         infected_data_15_2_2,
#         infected_data_15_3_2,
#         infected_data_15_4_2,
#         infected_data_15_5_2,
#         infected_data_15_6_2,
#         infected_data_15_7_2,
#         dims = 3)

#     infected_data_0_viruses = (infected_data_0_viruses_1 + infected_data_0_viruses_2) ./ 2
#     infected_data_3_viruses = (infected_data_3_viruses_1 + infected_data_3_viruses_2) ./ 2
#     infected_data_7_viruses = (infected_data_7_viruses_1 + infected_data_7_viruses_2) ./ 2
#     infected_data_15_viruses = (infected_data_15_viruses_1 + infected_data_15_viruses_2) ./ 2

#     infected_data_0_viruses = cat(infected_data_0_viruses_1, infected_data_0_viruses_2, dims = 2)
#     infected_data_3_viruses = cat(infected_data_3_viruses_1, infected_data_3_viruses_2, dims = 2)
#     infected_data_7_viruses = cat(infected_data_7_viruses_1, infected_data_7_viruses_2, dims = 2)
#     infected_data_15_viruses = cat(infected_data_15_viruses_1, infected_data_15_viruses_2, dims = 2)

#     infected_data_0_viruses_sd = confidence(infected_data_0_viruses, dims = 2)[:, 1, :]
#     infected_data_3_viruses_sd = confidence(infected_data_3_viruses, dims = 2)[:, 1, :]
#     infected_data_7_viruses_sd = confidence(infected_data_7_viruses, dims = 2)[:, 1, :]
#     infected_data_15_viruses_sd = confidence(infected_data_15_viruses, dims = 2)[:, 1, :]

#     num_infected_age_groups_viruses_sd = cat(
#         infected_data_0_viruses_sd,
#         infected_data_3_viruses_sd,
#         infected_data_7_viruses_sd,
#         infected_data_15_viruses_sd,
#         dims = 3,
#     )

#     viruses = ["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"]
#     age_groups = ["0-2", "3-6", "7-14", "15+"]
#     for i = 1:length(age_groups)
#         for j = 1:length(viruses)
#             incidence_plot = plot(
#                 1:52,
#                 # [age_groups[:, 1] infected_data_mean_0],
#                 num_infected_age_groups_viruses_mean[:, j, i],
#                 lw = 1.5,
#                 xticks = (ticks, ticklabels),
#                 label = label_names,
#                 grid = true,
#                 # color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
#                 color = [RGB(0.52, 0.52, 0.52) RGB(0.71, 0.71, 0.467)],
#                 # ribbon = [confidence_0_model confidence_0_data],
#                 ribbon = num_infected_age_groups_viruses_sd[:, j, i],
#                 xlabel = xlabel_name,
#                 ylabel = ylabel_name,
#             )
#             savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "results", "incidence_$(viruses[j])_$(age_groups[i]).pdf"))
#         end
#     end
# end

function plot_rt()
    rt_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    rt_arr_mean = zeros(Float64, 365)

    for i = 1:num_runs
        rt = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["rt"]
        # rt = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i + 1).jld"))["rt"]
        for j = 1:num_years
            rt_arr[i, j] = moving_average(rt, 20)[(365 * (j - 1) + 1):(365 * (j - 1) + 365)]
        end
    end

    rt_arr_mean = zeros(Float64, 365)
    for i = 1:365
        for j = 1:num_runs
            for z = 1:num_years
                rt_arr_mean[i] += rt_arr[j, z][i]
            end
        end
        rt_arr_mean[i] /= num_runs * num_years
    end

    confidence_model = zeros(Float64, 365)
    for i = 1:365
        confidence_model[i] = confidence([rt_arr[k, j][i] for j = 1:num_years for k = 1:num_runs])
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
        rt_arr_mean,
        lw = 1.5,
        xticks = (ticks, ticklabels),
        # yticks = (yticks, yticklabels),
        legend = false,
        color = RGB(0.0, 0.0, 0.0),
        grid = true,
        ribbon = confidence_model,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(
        rt_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "rt_quarantine.pdf" : with_global_warming ? "rt_warming.pdf" : "rt.pdf"))
end

function plot_infection_activities()
    num_activities = 5

    activity_sizes = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "activity_sizes.csv"), ',', Int, '\n')

    activities_cases_arr = Array{Matrix{Float64}, 2}(undef, num_runs, num_years)
    activities_cases_arr_mean = zeros(Float64, 365, num_activities)

    for i = 1:num_runs
        activities_cases = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["activities_cases"]
        for j = 1:num_years
            activities_cases_arr[i, j] = activities_cases[(365 * (j - 1) + 1):(365 * (j - 1) + 365), :]
        end
    end

    activities_cases_arr_mean = zeros(Float64, 365, num_activities)
    for i = 1:365
        for k = 1:num_activities
            for j = 1:num_runs
                for z = 1:num_years
                    activities_cases_arr_mean[i, k] += activities_cases_arr[j, z][i, k]
                end
            end
            activities_cases_arr_mean[i, k] /= num_runs * num_years
        end
    end

    for i = 1:num_activities
        activities_cases_arr_mean[:, i] ./= activity_sizes[i]
        activities_cases_arr_mean[:, i] .*= 100
        # activities_cases_arr_mean[:, i] = moving_average(activities_cases_arr_mean[:, i], 10)
    end

    confidence_model = zeros(Float64, num_activities)
    for i = 1:num_activities
        confidence_model[i] = confidence(activities_cases_arr_mean[:, i])
    end

    xlabel_name = "Activity"
    if is_russian
        xlabel_name = "Коллектив"
    end

    ylabel_name = "Ratio, %"
    if is_russian
        ylabel_name = "Доля, %"
    end

    ticks = [1, 2, 3, 4, 5]
    ticklabels = ["Daycare" "School" "College" "Work" "Home"]
    if is_russian
        ticklabels = ["Детсад" "Школа" "Универ" "Работа" "Дом"]
    end

    # activities_cases_plot = plot(
    #     1:365,
    #     [activities_cases_arr_mean[:, i] for i = 1:num_activities],
    #     lw = 1.5,
    #     xticks = (ticks, ticklabels),
    #     label = label_names,
    #     grid = true,
    #     legend = (0.9, 0.98),
    #     color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267)],
    #     # ribbon = [confidence_model[:, i] for i = 1:num_activities],
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )
    # savefig(activities_cases_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "activities_cases.pdf"))

    mean_values = [mean(activities_cases_arr_mean[:, i]) for i = 1:num_activities]

    activities_cases_plot = bar(
        [1, 2, 3, 4, 5],
        mean_values,
        grid = true,
        legend = false,
        xticks = (ticks, ticklabels),
        yerr = confidence_model,
        # color = RGB(0.66, 0.66, 0.66),
        color = RGB(0.5, 0.5, 0.5),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(activities_cases_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "activities_cases_quarantine.pdf" : with_global_warming ? "activities_cases_warming.pdf" : "activities_cases.pdf"))
end




function plot_infection_activities_2()
    num_activities = 5

    activity_sizes = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "activity_sizes.csv"), ',', Int, '\n')

    activities_cases_arr = Array{Matrix{Float64}, 2}(undef, num_runs, num_years)
    activities_cases_arr_mean = zeros(Float64, 365, num_activities)

    for i = 1:num_runs
        activities_cases = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["activities_cases"]
        for j = 1:num_years
            activities_cases_arr[i, j] = activities_cases[(365 * (j - 1) + 1):(365 * (j - 1) + 365), :]
        end
    end

    activities_cases_arr_mean = zeros(Float64, 365, num_activities)
    for i = 1:365
        for k = 1:num_activities
            for j = 1:num_runs
                for z = 1:num_years
                    activities_cases_arr_mean[i, k] += activities_cases_arr[j, z][i, k]
                end
            end
            activities_cases_arr_mean[i, k] /= num_runs * num_years
        end
    end

    for i = 1:num_activities
        activities_cases_arr_mean[:, i] ./= activity_sizes[i]
        activities_cases_arr_mean[:, i] .*= 100
        # activities_cases_arr_mean[:, i] = moving_average(activities_cases_arr_mean[:, i], 10)
    end

    confidence_model = zeros(Float64, num_activities)
    for i = 1:num_activities
        confidence_model[i] = confidence(activities_cases_arr_mean[:, i])
    end

    xlabel_name = "Activity"
    if is_russian
        xlabel_name = "Коллектив"
    end

    ylabel_name = "Ratio, %"
    if is_russian
        ylabel_name = "Доля"
    end

    ticks = [1, 2, 3, 4, 5]
    ticklabels = ["Kinder" "School" "College" "Work" "Home"]
    if is_russian
        ticklabels = ["Детсад" "Школа" "Универ" "Работа" "Дом"]
    end

    # activities_cases_plot = plot(
    #     1:365,
    #     [activities_cases_arr_mean[:, i] for i = 1:num_activities],
    #     lw = 1.5,
    #     xticks = (ticks, ticklabels),
    #     label = label_names,
    #     grid = true,
    #     legend = (0.9, 0.98),
    #     color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267)],
    #     # ribbon = [confidence_model[:, i] for i = 1:num_activities],
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )
    # savefig(activities_cases_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "activities_cases.pdf"))

    mean_values = [mean(activities_cases_arr_mean[:, i]) for i = 1:num_activities]

    activities_cases_plot = bar(
        [1, 2, 3, 4, 5],
        mean_values,
        grid = true,
        legend = false,
        xticks = (ticks, ticklabels),
        yerr = confidence_model,
        # color = RGB(0.66, 0.66, 0.66),
        color = RGB(0.5, 0.5, 0.5),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(activities_cases_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "activities_cases_quarantine.pdf" : with_global_warming ? "activities_cases_warming.pdf" : "activities_cases.pdf"))
end

# function plot_infection_activities()
#     num_activities = 5

#     activity_sizes = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "activity_sizes.csv"), ',', Int, '\n')

#     activities_cases_arr = Array{Matrix{Float64}, 2}(undef, num_runs, num_years)
#     activities_cases_arr_mean = zeros(Float64, 365, num_activities)

#     for i = 1:num_runs
#         activities_cases = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : "results_$(i).jld"))["activities_cases"]
#         for j = 1:num_years
#             activities_cases_arr[i, j] = activities_cases[(365 * (j - 1) + 1):(365 * (j - 1) + 365), :]
#         end
#     end

#     activities_cases_arr_mean = zeros(Float64, 365, num_activities)
#     for i = 1:365
#         for k = 1:num_activities
#             for j = 1:num_runs
#                 for z = 1:num_years
#                     activities_cases_arr_mean[i, k] += activities_cases_arr[j, z][i, k]
#                 end
#             end
#             activities_cases_arr_mean[i, k] /= num_runs * num_years
#         end
#     end

#     # println(activities_cases_arr_mean[5, 1])
#     # println(activities_cases_arr_mean[5, 2])
#     # println(activities_cases_arr_mean[5, 3])
#     # println(activities_cases_arr_mean[5, 4])
#     # println(activities_cases_arr_mean[5, 5])
#     # println(sum(activities_cases_arr_mean, dims = 2)[5, 1])

#     s = sum(activities_cases_arr_mean, dims = 2)[:, 1]
#     for i = 1:num_activities
#         activities_cases_arr_mean[:, i] ./= s
#         # activities_cases_arr_mean[:, i] = moving_average(activities_cases_arr_mean[:, i], 10)
#     end

#     confidence_model = zeros(Float64, num_activities)
#     for i = 1:num_activities
#         confidence_model[i] = confidence(activities_cases_arr_mean[:, i])
#     end

#     xlabel_name = "Activity"
#     if is_russian
#         xlabel_name = "Коллектив"
#     end

#     ylabel_name = "Incidence rate for activity per 1000"
#     if is_russian
#         ylabel_name = "Доля"
#     end

#     ticks = [1, 2, 3, 4, 5]
#     ticklabels = ["Kinder" "School" "College" "Work" "Home"]

#     # activities_cases_plot = plot(
#     #     1:365,
#     #     [activities_cases_arr_mean[:, i] for i = 1:num_activities],
#     #     lw = 1.5,
#     #     xticks = (ticks, ticklabels),
#     #     label = label_names,
#     #     grid = true,
#     #     legend = (0.9, 0.98),
#     #     color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267)],
#     #     # ribbon = [confidence_model[:, i] for i = 1:num_activities],
#     #     foreground_color_legend = nothing,
#     #     background_color_legend = nothing,
#     #     xlabel = xlabel_name,
#     #     ylabel = ylabel_name,
#     # )
#     # savefig(activities_cases_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "activities_cases.pdf"))

#     mean_values = [mean(activities_cases_arr_mean[:, i]) for i = 1:num_activities]

#     activities_cases_plot = bar(
#         [1, 2, 3, 4, 5],
#         mean_values,
#         grid = true,
#         legend = false,
#         xticks = (ticks, ticklabels),
#         yerr = confidence_model,
#         # color = RGB(0.66, 0.66, 0.66),
#         color = RGB(0.5, 0.5, 0.5),
#         foreground_color_legend = nothing,
#         background_color_legend = nothing,
#         xlabel = xlabel_name,
#         ylabel = ylabel_name,
#     )
#     # activities_cases_plot = plot(
#     #     1:365,
#     #     [activities_cases_arr_mean[:, i] for i = 1:num_activities],
#     #     grid = true,
#     #     legend = false,
#     #     # xticks = (ticks, ticklabels),
#     #     # yerr = confidence_model,
#     #     # color = RGB(0.66, 0.66, 0.66),
#     #     # color = RGB(0.5, 0.5, 0.5),
#     #     foreground_color_legend = nothing,
#     #     background_color_legend = nothing,
#     #     xlabel = xlabel_name,
#     #     ylabel = ylabel_name,
#     # )
#     savefig(activities_cases_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "activities_cases_quarantine.pdf" : "activities_cases.pdf"))
# end

function plot_r0()
    r0 = readdlm(
        joinpath(@__DIR__, "..", "..", "..", "output", "tables", "r0.csv"), ',', Float64)

    r0 = cat(r0[:, 8:12], r0[:, 1:7], dims=2)

    ticks = [1, 3, 5, 7, 9, 11]
    
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["model" "data"]
    if is_russian
        label_names = ["модель" "данные"]
    end

    xlabel_name = L"\textrm{\sffamily Month}"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = L"\textrm{\sffamily R0}"
    if is_russian
        ylabel_name = "R0"
    end

    registered_new_cases_plot = plot(
        1:12,
        [r0[i, :] for i = 1:7],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        legend = (0.5, 0.6),
        grid = true,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(
        registered_new_cases_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "r0.pdf"))
end

# function plot_incidence()
#     num_runs = 2

#     observed_incidence_arr = Array{Vector{Float64}, 1}(undef, num_runs)
#     incidence_arr = Array{Vector{Float64}, 1}(undef, num_runs)

#     for i = 1:num_runs
#         observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
#         observed_incidence_arr[i] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]
#         num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["all_cases"] ./ 10072
#         incidence_arr[i] = sum(sum(num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]
#     end

#     observed_incidence = zeros(Float64, 52)
#     for i = 1:52
#         for j = 1:num_runs
#             observed_incidence[i] += observed_incidence_arr[j][i]
#         end
#         observed_incidence[i] /= num_runs
#     end
#     incidence = zeros(Float64, 52)
#     for i = 1:52
#         for j = 1:num_runs
#             incidence[i] += incidence_arr[j][i]
#         end
#         incidence[i] /= num_runs
#     end

#     observed_confidence_model = zeros(Float64, 52)
#     for i = 1:52
#         observed_confidence_model[i] = confidence([observed_incidence_arr[k][i] for k = 1:num_runs])
#     end
#     confidence_model = zeros(Float64, 52)
#     for i = 1:52
#         confidence_model[i] = confidence([incidence_arr[k][i] for k = 1:num_runs])
#     end

#     infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n') ./ 10072
#     infected_data_mean = mean(infected_data[39:45, 2:53], dims = 1)[1, :]

#     confidence_data = zeros(Float64, 52)
#     for i = 1:52
#         confidence_data[i] = confidence(infected_data[39:45, i + 1])
#     end

#     ticks = range(1, stop = 52, length = 7)

#     ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
#     if is_russian
#         ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
#     end

#     label_names = ["model" "data" "model2"]
#     if is_russian
#         label_names = ["модель" "данные"]
#     end

#     # xlabel_name = L"\textrm{\sffamily Month}"
#     xlabel_name = "Month"
#     if is_russian
#         xlabel_name = "Месяц"
#     end

#     # ylabel_name = L"\textrm{\sffamily Cases per 1000 people in a week}"
#     ylabel_name = "Weekly incidence rate per 1000"
#     if is_russian
#         ylabel_name = "Число случаев на 1000 чел. / неделя"
#     end

#     incidence_plot = plot(
#         1:52,
#         [observed_incidence infected_data_mean incidence],
#         lw = 1.5,
#         xticks = (ticks, ticklabels),
#         label = label_names,
#         grid = true,
#         legend = (0.9, 0.98),
#         color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467) RGB(0.133, 0.533, 0.2)],
#         ribbon = [observed_confidence_model confidence_data confidence_model],
#         foreground_color_legend = nothing,
#         background_color_legend = nothing,
#         xlabel = xlabel_name,
#         ylabel = ylabel_name,
#     )
#     savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "model_incidence.pdf"))
# end

function print_statistics()
    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"]
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    # confidence_model = zeros(Float64, 52)
    # for i = 1:52
    #     confidence_model[i] = confidence([incidence_arr[k, j][i] for j = 1:num_years for k = 1:num_runs])
    # end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean[i] += incidence_arr[k, j][i]
            end
        end
        incidence_arr_mean[i] /= num_runs * num_years
    end

    max_value = maximum(incidence_arr_mean)
    all_number_observed_infections = sum(incidence_arr_mean)
    pos = argmax(incidence_arr_mean)

    incidence_arr_mean = zeros(Float64, 52)
    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_quarantine_$(i).jld"))["observed_cases"]
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    # confidence_model = zeros(Float64, 52)
    # for i = 1:52
    #     confidence_model[i] = confidence([incidence_arr[k, j][i] for j = 1:num_years for k = 1:num_runs])
    # end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean[i] += incidence_arr[k, j][i]
            end
        end
        incidence_arr_mean[i] /= num_runs * num_years
    end

    max_value_quarantine = maximum(incidence_arr_mean)
    all_number_observed_infections_quarantine = sum(incidence_arr_mean)
    pos_quarantine = argmax(incidence_arr_mean)

    incidence_arr_mean = zeros(Float64, 52)
    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_warming_$(i).jld"))["observed_cases"]
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    # confidence_model = zeros(Float64, 52)
    # for i = 1:52
    #     confidence_model[i] = confidence([incidence_arr[k, j][i] for j = 1:num_years for k = 1:num_runs])
    # end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean[i] += incidence_arr[k, j][i]
            end
        end
        incidence_arr_mean[i] /= num_runs * num_years
    end

    max_value_warming = maximum(incidence_arr_mean)
    all_number_observed_infections_warming = sum(incidence_arr_mean)
    pos_warming = argmax(incidence_arr_mean)

    println("Ratio of the max number of infected - quaranteen: $(max_value_quarantine / max_value)")
    println("Ratio of the number of observed infections - quaranteen: $(all_number_observed_infections_quarantine / all_number_observed_infections)")
    println("Ratio of the max number of infected - warming: $(max_value_warming / max_value)")
    println("Ratio of the number of observed infections - warming: $(all_number_observed_infections_warming / all_number_observed_infections)")
    println("Max pos: $(pos)")
    println("Max pos quaranteen: $(pos_quarantine)")
    println("Max pos warming: $(pos_warming)")

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    infected_data_mean = mean(infected_data[39:45, 2:53], dims = 1)[1, :]

    nMAE = sum(abs.(incidence_arr_mean - infected_data_mean)) / sum(infected_data_mean)
    println("General nMAE: $(nMAE)")

    # ------------------

    incidence_arr = Array{Matrix{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52, 4)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"]
        for j = 1:num_years
            incidence_arr[i, j] = sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :][(52 * (j - 1) + 1):(52 * (j - 1) + 52), :]
        end
    end

    incidence_arr_mean = zeros(Float64, 52, 4)
    for i = 1:52
        for k = 1:4
            for j = 1:num_runs
                for z = 1:num_years
                    incidence_arr_mean[i, k] += incidence_arr[j, z][i, k]
                end
            end
            incidence_arr_mean[i, k] /= num_runs * num_years
        end
    end

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_mean = cat(
        mean(infected_data_0[2:53, 22:27], dims = 2)[:, 1],
        mean(infected_data_3[2:53, 22:27], dims = 2)[:, 1],
        mean(infected_data_7[2:53, 22:27], dims = 2)[:, 1],
        mean(infected_data_15[2:53, 22:27], dims = 2)[:, 1],
        dims = 2,
    )

    nMAE = sum(abs.(incidence_arr_mean[:, 1] - infected_data_mean[:, 1])) / sum(infected_data_mean[:, 1])
    println("0-2 nMAE: $(nMAE)")

    nMAE = sum(abs.(incidence_arr_mean[:, 2] - infected_data_mean[:, 2])) / sum(infected_data_mean[:, 2])
    println("3-6 nMAE: $(nMAE)")

    nMAE = sum(abs.(incidence_arr_mean[:, 3] - infected_data_mean[:, 3])) / sum(infected_data_mean[:, 3])
    println("7-14 nMAE: $(nMAE)")

    nMAE = sum(abs.(incidence_arr_mean[:, 4] - infected_data_mean[:, 4])) / sum(infected_data_mean[:, 4])
    println("15+ nMAE: $(nMAE)")

    # ------------------

    incidence_arr = Array{Matrix{Float64}, 2}(undef, num_runs, num_years)
    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"]
        for j = 1:num_years
            incidence_arr[i, j] = sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52), :]
        end
    end

    incidence_arr_mean = zeros(Float64, 52, 7)
    for i = 1:52
        for k = 1:7
            for j = 1:num_runs
                for z = 1:num_years
                    incidence_arr_mean[i, k] += incidence_arr[j, z][i, k]
                end
            end
            incidence_arr_mean[i, k] /= num_runs * num_years
        end
    end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    infected_data = infected_data[39:45, 2:53]'

    etiology = get_etiology()

    infected_data_1 = etiology[:, 1] .* infected_data
    infected_data_2 = etiology[:, 2] .* infected_data
    infected_data_3 = etiology[:, 3] .* infected_data
    infected_data_4 = etiology[:, 4] .* infected_data
    infected_data_5 = etiology[:, 5] .* infected_data
    infected_data_6 = etiology[:, 6] .* infected_data
    infected_data_7 = etiology[:, 7] .* infected_data
    infected_data_viruses = cat(
        infected_data_1,
        infected_data_2,
        infected_data_3,
        infected_data_4,
        infected_data_5,
        infected_data_6,
        infected_data_7,
        dims = 3)

    infected_data_viruses_mean = mean(infected_data_viruses, dims = 2)[:, 1, :]

    nMAE = sum(abs.(incidence_arr_mean[:, 1] - infected_data_viruses_mean[:, 1])) / sum(infected_data_viruses_mean[:, 1])
    println("FluA nMAE: $(nMAE)")

    nMAE = sum(abs.(incidence_arr_mean[:, 2] - infected_data_viruses_mean[:, 2])) / sum(infected_data_viruses_mean[:, 2])
    println("FluB nMAE: $(nMAE)")

    nMAE = sum(abs.(incidence_arr_mean[:, 3] - infected_data_viruses_mean[:, 3])) / sum(infected_data_viruses_mean[:, 3])
    println("RV nMAE: $(nMAE)")

    nMAE = sum(abs.(incidence_arr_mean[:, 4] - infected_data_viruses_mean[:, 4])) / sum(infected_data_viruses_mean[:, 4])
    println("RSV nMAE: $(nMAE)")

    nMAE = sum(abs.(incidence_arr_mean[:, 5] - infected_data_viruses_mean[:, 5])) / sum(infected_data_viruses_mean[:, 5])
    println("AdV nMAE: $(nMAE)")

    nMAE = sum(abs.(incidence_arr_mean[:, 6] - infected_data_viruses_mean[:, 6])) / sum(infected_data_viruses_mean[:, 6])
    println("PIV nMAE: $(nMAE)")

    nMAE = sum(abs.(incidence_arr_mean[:, 7] - infected_data_viruses_mean[:, 7])) / sum(infected_data_viruses_mean[:, 7])
    println("CoV nMAE: $(nMAE)")
end

# plot_incidence_time_series()
# plot_incidence_age_groups_time_series()
# plot_incidence_viruses_time_series()
# plot_rt_time_series()
print_statistics_time_series()

# plot_incidence()
# plot_incidence_age_groups()
# plot_incidence_viruses()
# plot_rt()
# plot_infection_activities()
# plot_incidence_scenarios()
# plot_incidence_scenarios_quaranteen()
# plot_incidence_scenarios_warming()

# plot_r0()

# print_statistics()

# plot_incidence_age_groups_viruses()
# plot_incidence_etiology()
