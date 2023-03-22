using DelimitedFiles
using Statistics
using StatsPlots
using Plots
using LaTeXStrings
using JLD
using Distributions

include("../../data/temperature.jl")
include("../../util/moving_avg.jl")
include("../../data/etiology.jl")

default(legendfontsize = 9, guidefont = (12, :black), tickfont = (11, :black))

# const is_russian = false
const is_russian = true

const num_runs = 1
const num_years = 3

const with_quarantine = false
# const with_quarantine = true

const with_global_warming = false
# const with_global_warming = true

function confidence(x::Vector{Float64})
    alpha = 0.05
    tstar = quantile(TDist(length(x) - 1), 1 - alpha / 2)
    tstar = 1.96
    tstar = 3.18
    # 90 % confidence
    tstar = 2.35
    SE = std(x) / sqrt(length(x))
    return tstar * SE
end

function t_test(x; conf_level=0.95)
    alpha = (1 - conf_level)
    tstar = quantile(TDist(length(x)-1), 1 - alpha/2)
    SE = std(x)/sqrt(length(x))

    lo, hi = mean(x) + [-1, 1] * tstar * SE
    "($lo, $hi)"
end

function plot_incidence_time_series()
    incidence_arr = Array{Vector{Float64}, 1}(undef, num_runs)
    incidence_arr_mean = zeros(Float64, 52 * num_years)
    
    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ 10072
        incidence_arr[i] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]
    end

    # confidence_model = zeros(Float64, 52 * num_years)
    # for i = 1:(52 * num_years)
    #     confidence_model[i] = confidence([incidence_arr[k][i] for k = 1:num_runs])
    # end

    for i = 1:(52 * num_years)
        for k = 1:num_runs
            incidence_arr_mean[i] += incidence_arr[k][i]
        end
        incidence_arr_mean[i] /= num_runs
    end    

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n') ./ 10072
    infected_data = vec(transpose(infected_data[42:(41 + num_years), 2:53]))

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

    incidence_plot = plot(
        1:(52 * num_years),
        [incidence_arr_mean infected_data],
        lw = 1.5,
        xticks = (ticks, ticklabels),
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

    # confidence_model = zeros(Float64, 52 * num_years, 4)
    # for i = 1:(52 * num_years)
    #     for k = 1:4
    #         confidence_model[i, k] = confidence([incidence_arr[j][i, k] for j = 1:num_runs])
    #     end
    # end

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n') ./ 10072
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n') ./ 10072
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n') ./ 10072
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n') ./ 10072

    infected_data_mean = cat(
        vec(infected_data_0[2:53, 24:(23 + num_years)]),
        vec(infected_data_3[2:53, 24:(23 + num_years)]),
        vec(infected_data_7[2:53, 24:(23 + num_years)]),
        vec(infected_data_15[2:53, 24:(23 + num_years)]),
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

    # confidence_model = zeros(Float64, (52 * num_years), 7)
    # for i = 1:(52 * num_years)
    #     for k = 1:7
    #         confidence_model[i, k] = confidence([incidence_arr[j][i, k] for j = 1:num_runs])
    #     end
    # end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n') ./ 10072
    infected_data = transpose(infected_data[42:(41 + num_years), 2:53])
    
    etiology = get_etiology()

    infected_data_1 = etiology[:, 1] .* infected_data
    infected_data_2 = etiology[:, 2] .* infected_data
    infected_data_3 = etiology[:, 3] .* infected_data
    infected_data_4 = etiology[:, 4] .* infected_data
    infected_data_5 = etiology[:, 5] .* infected_data
    infected_data_6 = etiology[:, 6] .* infected_data
    infected_data_7 = etiology[:, 7] .* infected_data
    infected_data_viruses = cat(
        vec(infected_data_1),
        vec(infected_data_2),
        vec(infected_data_3),
        vec(infected_data_4),
        vec(infected_data_5),
        vec(infected_data_6),
        vec(infected_data_7),
        dims = 2)

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

    for i in 1:7
        nMAE = sum(abs.(incidence_arr_mean[:, i] - infected_data_viruses[:, i])) / sum(infected_data_viruses[:, i])
        println(nMAE)
    end
    return

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
    
    rt_plot = plot(
        1:(365 * num_years),
        rt_arr_mean,
        lw = 1.5,
        xticks = (ticks, ticklabels),
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

function print_statistics_time_series(mode::Int)
    # mode: 1 - all, 2 - train, 3 - test
    modeled_time = 52 * num_years
    bias = 0
    if mode == 2 & num_years > 1
        modeled_time = 52 * (num_years - 1)
    elseif mode == 3 & num_years > 1
        bias += 52 * (num_years - 1)
    end

    incidence_arr = Array{Vector{Float64}, 1}(undef, num_runs)
    incidence_arr_mean = zeros(Float64, modeled_time)

    observed_num_infected_age_groups_viruses = Array{Array{Float64, 3}, 1}(undef, num_runs)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"] ./ 10072
        incidence_arr[i] = sum(sum(observed_num_infected_age_groups_viruses[i], dims = 3)[:, :, 1], dims = 2)[:, 1]
    end

    for i = (1 + bias):modeled_time
        for j = 1:num_runs
            incidence_arr_mean[i] += incidence_arr[j][i]
        end
        incidence_arr_mean[i] /= num_runs
    end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n') ./ 10072
    infected_data_mean = vec(transpose(infected_data[42:(41 + num_years), 2:53]))
    if mode == 2 & num_years > 1
        infected_data_mean = vec(transpose(infected_data[42:(41 + num_years - 1), 2:53]))
    end
    
    nMAE_general = sum(abs.(incidence_arr_mean[(1 + bias):end] - infected_data_mean[(1 + bias):end])) / sum(infected_data_mean[(1 + bias):end])
    println("General nMAE: $(nMAE_general)")

    # ------------------

    incidence_arr = Array{Matrix{Float64}, 1}(undef, num_runs)
    incidence_arr_mean = zeros(Float64, modeled_time, 4)

    for i = 1:num_runs
        incidence_arr[i] = sum(observed_num_infected_age_groups_viruses[i], dims = 2)[:, 1, :]
    end

    incidence_arr_mean = zeros(Float64, modeled_time, 4)
    for i = (1 + bias):modeled_time
        for k = 1:4
            for j = 1:num_runs
                incidence_arr_mean[i, k] += incidence_arr[j][i, k]
            end
            incidence_arr_mean[i, k] /= num_runs
        end
    end

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n') ./ 10072
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n') ./ 10072
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n') ./ 10072
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n') ./ 10072

    infected_data_mean = cat(
        vec(infected_data_0[2:53, 24:(23 + num_years)]),
        vec(infected_data_3[2:53, 24:(23 + num_years)]),
        vec(infected_data_7[2:53, 24:(23 + num_years)]),
        vec(infected_data_15[2:53, 24:(23 + num_years)]),
        dims = 2,
    )

    if mode == 2 & num_years > 1
        infected_data_mean = cat(
        vec(infected_data_0[2:53, 24:(23 + num_years - 1)]),
        vec(infected_data_3[2:53, 24:(23 + num_years - 1)]),
        vec(infected_data_7[2:53, 24:(23 + num_years - 1)]),
        vec(infected_data_15[2:53, 24:(23 + num_years - 1)]),
        dims = 2,
    )
    end

    nMAE_0_2 = sum(abs.(incidence_arr_mean[(1 + bias):end, 1] - infected_data_mean[(1 + bias):end, 1])) / sum(infected_data_mean[(1 + bias):end, 1])
    println("0-2 nMAE: $(nMAE_0_2)")

    nMAE_3_6 = sum(abs.(incidence_arr_mean[(1 + bias):end, 2] - infected_data_mean[(1 + bias):end, 2])) / sum(infected_data_mean[(1 + bias):end, 2])
    println("3-6 nMAE: $(nMAE_3_6)")

    nMAE_7_14 = sum(abs.(incidence_arr_mean[(1 + bias):end, 3] - infected_data_mean[(1 + bias):end, 3])) / sum(infected_data_mean[(1 + bias):end, 3])
    println("7-14 nMAE: $(nMAE_7_14)")

    nMAE_15 = sum(abs.(incidence_arr_mean[(1 + bias):end, 4] - infected_data_mean[(1 + bias):end, 4])) / sum(infected_data_mean[(1 + bias):end, 4])
    println("15+ nMAE: $(nMAE_15)")

    # ------------------
    incidence_arr = Array{Matrix{Float64}, 1}(undef, num_runs)
    for i = 1:num_runs
        incidence_arr[i] = sum(observed_num_infected_age_groups_viruses[i], dims = 3)[:, :, 1]
    end

    incidence_arr_mean = zeros(Float64, modeled_time, 7)
    for i = (1 + bias):modeled_time
        for k = 1:7
            for j = 1:num_runs
                incidence_arr_mean[i, k] += incidence_arr[j][i, k]
            end
            incidence_arr_mean[i, k] /= num_runs
        end
    end

    infected_data_d = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n') ./ 10072
    infected_data = transpose(infected_data_d[42:(41 + num_years), 2:53])

    if mode == 2 & num_years > 1
        infected_data = transpose(infected_data_d[42:(41 + num_years - 1), 2:53])
    end

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

    nMAE_FluA = sum(abs.(incidence_arr_mean[(1 + bias):end, 1] - infected_data_viruses_mean[(1 + bias):end, 1])) / sum(infected_data_viruses_mean[(1 + bias):end, 1])
    println("FluA nMAE: $(nMAE_FluA)")

    nMAE_FluB = sum(abs.(incidence_arr_mean[(1 + bias):end, 2] - infected_data_viruses_mean[(1 + bias):end, 2])) / sum(infected_data_viruses_mean[(1 + bias):end, 2])
    println("FluB nMAE: $(nMAE_FluB)")

    nMAE_RV = sum(abs.(incidence_arr_mean[(1 + bias):end, 3] - infected_data_viruses_mean[(1 + bias):end, 3])) / sum(infected_data_viruses_mean[(1 + bias):end, 3])
    println("RV nMAE: $(nMAE_RV)")

    nMAE_RSV = sum(abs.(incidence_arr_mean[(1 + bias):end, 4] - infected_data_viruses_mean[(1 + bias):end, 4])) / sum(infected_data_viruses_mean[(1 + bias):end, 4])
    println("RSV nMAE: $(nMAE_RSV)")

    nMAE_AdV = sum(abs.(incidence_arr_mean[(1 + bias):end, 5] - infected_data_viruses_mean[(1 + bias):end, 5])) / sum(infected_data_viruses_mean[(1 + bias):end, 5])
    println("AdV nMAE: $(nMAE_AdV)")

    nMAE_PIV = sum(abs.(incidence_arr_mean[(1 + bias):end, 6] - infected_data_viruses_mean[(1 + bias):end, 6])) / sum(infected_data_viruses_mean[(1 + bias):end, 6])
    println("PIV nMAE: $(nMAE_PIV)")

    nMAE_CoV = sum(abs.(incidence_arr_mean[(1 + bias):end, 7] - infected_data_viruses_mean[(1 + bias):end, 7])) / sum(infected_data_viruses_mean[(1 + bias):end, 7])
    println("CoV nMAE: $(nMAE_CoV)")

    averaged_nMAE = nMAE_FluA + nMAE_FluB + nMAE_RV + nMAE_RSV + nMAE_AdV + nMAE_PIV + nMAE_CoV + nMAE_general + nMAE_0_2 + nMAE_3_6 + nMAE_7_14 + nMAE_15
    println("Averaged nMAE: $(averaged_nMAE / 12)")

    # ---
    incidence_arr_mean = zeros(Float64, modeled_time, 7, 4)
    for i = (1 + bias):modeled_time
        for v = 1:7
            for k = 1:4
                for j = 1:num_runs
                    incidence_arr_mean[i, v, k] += observed_num_infected_age_groups_viruses[j][i, v, k]
                end
                incidence_arr_mean[i, v, k] /= num_runs
            end
        end
    end

    infected_data_0_all = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n') ./ 10072
    infected_data_3_all = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n') ./ 10072
    infected_data_7_all = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n') ./ 10072
    infected_data_15_all = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n') ./ 10072

    infected_data_0 = infected_data_0_all[2:53, 24:(23 + num_years)]
    if mode == 2 & num_years > 1
        infected_data_0 = infected_data_0_all[2:53, 24:(23 + num_years - 1)]
    end
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
    if mode == 2 & num_years > 1
        infected_data_3 = infected_data_3_all[2:53, 24:(23 + num_years - 1)]
    end
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
    if mode == 2 & num_years > 1
        infected_data_7 = infected_data_7_all[2:53, 24:(23 + num_years - 1)]
    end
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
    if mode == 2 & num_years > 1
        infected_data_15 = infected_data_15_all[2:53, 24:(23 + num_years - 1)]
    end
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

    println("nMAE = $(sum(abs.(incidence_arr_mean[(1 + bias):end, :, :] - num_infected_age_groups_viruses[(1 + bias):end, :, :])) / sum(num_infected_age_groups_viruses[(1 + bias):end, :, :]))")
    println("RSS = $(sum((num_infected_age_groups_viruses[(1 + bias):end, :, :] - incidence_arr_mean[(1 + bias):end, :, :]).^2))")
end

function plot_incidence_quarantine()
    num_runs_quarantine = 5
    incidence_arr = Array{Vector{Float64}, 1}(undef, num_runs_quarantine + 1)

    observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_1.jld"))["observed_cases"] ./ 10072
    incidence_arr[1] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]

    for i = 1:num_runs_quarantine
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_quarantine_$(i).jld"))["observed_cases"] ./ 10072
        incidence_arr[i + 1] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]
    end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n') ./ 10072
    infected_data = vec(transpose(infected_data[42:(41 + num_years), 2:53]))

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    yticks = [0, 4, 8, 12]
    yticklabels = ["0" "4" "8" "12"]

    # 0.2  0.1  0.3  0.2_14  0.1_14  0.3_14
    label_names = ["без карантина" "порог 0.2, 7 дней" "порог 0.1, 7 дней" "порог 0.3, 7 дней" "порог 0.2, 14 дней" "порог 0.1, 14 дней"]
    if is_russian
        label_names = ["без карантина" "порог 0.2, 7 дней" "порог 0.1, 7 дней" "порог 0.3, 7 дней" "порог 0.2, 14 дней" "порог 0.1, 14 дней"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    incidence_arr_mean = Array{Vector{Float64}, 1}(undef, num_runs_quarantine + 1)
    for i = 1:num_runs_quarantine + 1
        incidence_arr_mean[i] = zeros(Float64, 52)
        for j = 1:52
            for k = 1:num_years
                incidence_arr_mean[i][j] += incidence_arr[i][52 * (k - 1) + j]
            end
        end
        incidence_arr_mean[i] /= num_years
    end

    incidence_plot = plot(
        1:52,
        [incidence_arr_mean[i][1:52] for i = 1:(num_runs_quarantine + 1)],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        margin = 4Plots.mm,
        grid = true,
        legend = (0.68, 0.98),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        # ribbon = confidence_model,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "model_incidence_quarantine.pdf"))
end

function plot_incidence_warming()
    num_runs_warming = 4
    incidence_arr = Array{Vector{Float64}, 1}(undef, num_runs_warming + 1)

    for i = 1:num_runs_warming
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_warming_$(i).jld"))["observed_cases"] ./ 10072
        incidence_arr[i] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]
    end

    observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_1.jld"))["observed_cases"] ./ 10072
    incidence_arr[num_runs_warming + 1] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["+0 °С" "+1 °С" "+2 °С" "+3 °С" "+4 °С"]
    if is_russian
        label_names = ["+0 °С" "+1 °С" "+2 °С" "+3 °С" "+4 °С"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    # println("Ratio of the max number of infected")
    # println(1 - maximum(incidence_arr[2]) / maximum(incidence_arr[1]))
    # println(1 - maximum(incidence_arr[3]) / maximum(incidence_arr[1]))
    # println(1 - maximum(incidence_arr[4]) / maximum(incidence_arr[1]))
    # println(1 - maximum(incidence_arr[5]) / maximum(incidence_arr[1]))

    # println("Max pos")
    # println(argmax(incidence_arr[1]))
    # println(argmax(incidence_arr[2]))
    # println(argmax(incidence_arr[3]))
    # println(argmax(incidence_arr[4]))
    # println(argmax(incidence_arr[5]))

    incidence_arr_mean = Array{Vector{Float64}, 1}(undef, num_runs_warming + 1)
    for i = 1:num_runs_warming + 1
        incidence_arr_mean[i] = zeros(Float64, 52)
        for j = 1:52
            for k = 1:num_years
                incidence_arr_mean[i][j] += incidence_arr[i][52 * (k - 1) + j]
            end
        end
        incidence_arr_mean[i] /= num_years
    end
    
    incidence_plot = plot(
        1:52,
        [incidence_arr_mean[i][1:52] for i = (num_runs_warming + 1):-1:1],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        margin = 4Plots.mm,
        grid = true,
        legend = (0.75, 0.98),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        # ribbon = confidence_model,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "model_incidence_warming.pdf"))
end

function plot_incidence_herd_immunity_time_series()
    num_runs_herd_immunity = 6
    incidence_arr = Array{Vector{Float64}, 1}(undef, num_runs_herd_immunity)

    for i = 1:num_runs_herd_immunity
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_herd_immunity_$(i).jld"))["observed_cases"] ./ 10072
        incidence_arr[i] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]
    end

    # confidence_model = zeros(Float64, 52 * num_years)
    # for i = 1:(52 * num_years)
    #     confidence_model[i] = confidence([incidence_arr[k][i] for k = 1:num_runs_herd_immunity])
    # end  

    ticks = range(1, stop = (52.14285 * num_years), length = 19)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["a = 1.0" "a = 0.9" "a = 0.8" "a = 0.7" "a = 0.6" "a = 0.5"]
    if is_russian
        label_names = ["a = 1.0" "a = 0.9" "a = 0.8" "a = 0.7" "a = 0.6" "a = 0.5"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    # println("Ratio of the max number of infected")
    # println(1 - maximum(incidence_arr[2]) / maximum(incidence_arr[1]))
    # println(1 - maximum(incidence_arr[3]) / maximum(incidence_arr[1]))
    # println(1 - maximum(incidence_arr[4]) / maximum(incidence_arr[1]))
    # println(1 - maximum(incidence_arr[5]) / maximum(incidence_arr[1]))

    # println("Max pos")
    # println(argmax(incidence_arr[1]))
    # println(argmax(incidence_arr[2]))
    # println(argmax(incidence_arr[3]))
    # println(argmax(incidence_arr[4]))
    # println(argmax(incidence_arr[5]))
    
    incidence_plot = plot(
        1:(52 * num_years),
        [incidence_arr[i] for i = 1:(num_runs_herd_immunity)],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        margin = 4Plots.mm,
        xrotation = 45,
        grid = true,
        legend = (0.93, 0.98),
        size = (800, 500),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        # ribbon = confidence_model,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "model_incidence_herd_immunity_time_series.pdf"))
end

function plot_incidence(
    type::String = "observed_cases",
)
    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))[type] ./ 10072
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
        # yticks = (yticks, yticklabels),
        label = label_names,
        grid = true,
        legend = (0.9, 0.98),
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        ribbon = [confidence_model confidence_data],
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
            ribbon = [confidence_model[:, i] confidence_data[:, i]],
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

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n') ./ 10072

    infected_data = transpose(infected_data[42:(41 + num_years), 2:53])
    etiology = get_etiology()

    infected_data_1 = etiology[:, 1] .* infected_data
    infected_data_2 = etiology[:, 2] .* infected_data
    infected_data_3 = etiology[:, 3] .* infected_data
    infected_data_4 = etiology[:, 4] .* infected_data
    infected_data_5 = etiology[:, 5] .* infected_data
    infected_data_6 = etiology[:, 6] .* infected_data
    infected_data_7 = etiology[:, 7] .* infected_data
    infected_data_viruses_conf = cat(
        infected_data_1,
        infected_data_2,
        infected_data_3,
        infected_data_4,
        infected_data_5,
        infected_data_6,
        infected_data_7,
        dims = 3)
    infected_data_viruses = cat(
        vec(infected_data_1),
        vec(infected_data_2),
        vec(infected_data_3),
        vec(infected_data_4),
        vec(infected_data_5),
        vec(infected_data_6),
        vec(infected_data_7),
        dims = 2)


    infected_data_viruses_confidence = zeros(Float64, 52, 7)
    for i = 1:52
        for j = 1:7
            infected_data_viruses_confidence[i, j] = confidence(infected_data_viruses_conf[i, :, j])
        end
    end

    infected_data_viruses_mean = copy(infected_data_viruses[1:52, :])
    infected_data_viruses_mean .+= infected_data_viruses[53:104, :]
    infected_data_viruses_mean .+= infected_data_viruses[105:156, :]
    infected_data_viruses_mean ./= 3

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
            ribbon = [confidence_model[:, i] infected_data_viruses_confidence[:, i]],
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
        savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "incidence$(viruses[i])_quarantine.pdf" : with_global_warming ? "incidence$(viruses[i])_warming.pdf" : "incidence$(viruses[i]).pdf"))
    end
end

function plot_rt()
    rt_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    rt_arr_mean = zeros(Float64, 365)

    for i = 1:num_runs
        rt = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["rt"]
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
        ticklabels = ["Детсад" "Школа" "Вуз" "Работа" "Дом"]
    end

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

function plot_closures_time_series()
    num_years = 3
    num_runs_quarantine = 5
    num_schools_closed = Array{Vector{Float64}, 1}(undef, num_runs_quarantine + 1)
    
    # num_schools_closed_model = zeros(Float64, 365 * num_years)
    # num_schools_closed_model = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_quarantine_1.jld"))["num_schools_closed"]
    
    num_schools_closed[1] = zeros(Float64, (365 * num_years))
    for i = 1:num_runs_quarantine
        num_schools_closed[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_quarantine_$(i).jld"))["num_schools_closed"][1:(365 * num_years)]
        num_schools_closed[i + 1] = moving_average(num_schools_closed[i + 1], 20)
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

    ylabel_name = "Number of school closures"
    if is_russian
        ylabel_name = "Число закрытий"
    end

    label_names = ["базовый" "порог 0.2" "порог 0.1" "порог 0.3" "порог 0.2, 14 дней" "порог 0.1, 14 дней"]
    if is_russian
        label_names = ["базовый" "порог 0.2" "порог 0.1" "порог 0.3" "порог 0.2, 14 дней" "порог 0.1, 14 дней"]
    end

    for i = 1:(num_runs_quarantine + 1)
        num_schools_closed[i] = moving_average(num_schools_closed[i], 3)
    end

    closures_plot = plot(
        # 1:(365 * num_years),
        1:365,
        [num_schools_closed[i][1:365] for i = 1:(num_runs_quarantine + 1)],
        lw = 1.5,
        label = label_names,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        xticks = (ticks, ticklabels),
        # yticks = ([0, 20, 40, 60], ["0", "20", "40", "60"]),
        grid = true,
        # legend = false,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Temperature, °C}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )

    savefig(closures_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "num_closures_time_series.pdf"))
end

function plot_temperature_time_series()
    num_years = 3
    num_runs_temp = 4
    # temperature_data = Array{Vector{Float64}, 2}(undef, num_runs_temp + 1)
    temperature_data_rearranged = Array{Vector{Float64}, 1}(undef, num_runs_temp + 1)
    
    # temperature_model = zeros(Float64, 365 * num_years)
    # temperature_model = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_quarantine_1.jld"))["temperature"]
    
    temperature_data = get_air_temperature()
    append!(temperature_data, temperature_data)
    append!(temperature_data, temperature_data)
    temperature_data_rearranged[1] = Float64[]
    append!(temperature_data_rearranged[1], temperature_data[213:365])
    append!(temperature_data_rearranged[1], temperature_data[1:212])

    append!(temperature_data_rearranged[1], temperature_data[578:730])
    append!(temperature_data_rearranged[1], temperature_data[366:577])

    append!(temperature_data_rearranged[1], temperature_data[943:1095])
    append!(temperature_data_rearranged[1], temperature_data[731:942])

    for i = 1:num_runs_temp
        temperature_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "temperature_$(i).csv"), ',', Float64, '\n')
        temperature_data = moving_average(temperature_data, 10)

        temperature_data_rearranged[i + 1] = Float64[]
        append!(temperature_data_rearranged[i + 1], temperature_data[213:365])
        append!(temperature_data_rearranged[i + 1], temperature_data[1:212])

        append!(temperature_data_rearranged[i + 1], temperature_data[578:730])
        append!(temperature_data_rearranged[i + 1], temperature_data[366:577])

        append!(temperature_data_rearranged[i + 1], temperature_data[943:1095])
        append!(temperature_data_rearranged[i + 1], temperature_data[731:942])
    end

    ticks = range(1, stop = (365 * num_years), length = 19)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["базовый" "+4 °С" "+3 °С" "+2 °С" "+1 °С"]
    if is_russian
        label_names = ["базовый" "+4 °С" "+3 °С" "+2 °С" "+1 °С"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Temperature, °C"
    if is_russian
        ylabel_name = "Температура, °C"
    end

    temperature_plot = plot(
        # 1:(365 * num_years),
        1:365,
        [temperature_data_rearranged[i][1:365] for i = 1:(num_runs_temp + 1)],
        lw = 1.5,
        label = label_names,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        xticks = (ticks, ticklabels),
        grid = true,
        margin = 6Plots.mm,
        xrotation = 45,
        # legend = (0.51, 0.91),
        # legend = (0.42, 0.98),
        # right_margin = 14Plots.mm,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Temperature, °C}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )

    savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "temperature.pdf"))
end

function print_scenario_statistics(quarantine_index::Int, warming_index::Int)
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
    for i = 1:1
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_quarantine_$(quarantine_index).jld"))["observed_cases"]
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
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_warming_$(warming_index).jld"))["observed_cases"]
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

    println("Ratio of the max number of infected - quaranteen: $(1 - max_value_quarantine / max_value)")
    println("Ratio of the number of observed infections - quaranteen: $(1 - all_number_observed_infections_quarantine / all_number_observed_infections)")
    println("Ratio of the max number of infected - warming: $(1 - max_value_warming / max_value)")
    println("Ratio of the number of observed infections - warming: $(1 - all_number_observed_infections_warming / all_number_observed_infections)")
    println("Max pos: $(pos)")
    println("Max pos quaranteen: $(pos_quarantine)")
    println("Max pos warming: $(pos_warming)")
end

# plot_incidence_time_series()
# plot_incidence_age_groups_time_series()
# plot_incidence_viruses_time_series()
# plot_rt_time_series()

# mode: 1 - all, 2 - train, 3 - test
# print_statistics_time_series(1)
# print_statistics_time_series(2)
# print_statistics_time_series(3)

plot_incidence("all_cases")
# plot_incidence_age_groups()
# plot_incidence_viruses()
# plot_rt()
# plot_infection_activities()

# plot_incidence_quarantine()
# plot_closures_time_series()

# plot_incidence_warming()
# plot_temperature_time_series()
# plot_incidence_scenarios_quaranteen()
# plot_incidence_scenarios_warming()

# plot_incidence_herd_immunity_time_series()

# plot_incidence_scenarios()


# plot_r0()

# ["порог 0.2, 7 дней" "порог 0.1, 7 дней" "порог 0.3, 7 дней" "порог 0.2, 14 дней" "порог 0.1, 14 дней"]
# ["+4 °С" "+3 °С" "+2 °С" "+1 °С"]

# println()
# print_scenario_statistics(1, 1)
# println()
# print_scenario_statistics(2, 2)
# println()
# print_scenario_statistics(3, 3)
# println()
# print_scenario_statistics(4, 4)
# println()
# print_scenario_statistics(5, 4)

# plot_incidence_age_groups_viruses()
# plot_incidence_etiology()
