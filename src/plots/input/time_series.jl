using DelimitedFiles
using Plots
using Statistics
using StatsPlots
using LaTeXStrings
using CategoricalArrays
using Interpolations
using JLD
using CSV
using DataFrames
using Distributions

include("../../global/variables.jl")
include("../../data/etiology.jl")
include("../../data/incidence.jl")
include("../../util/moving_avg.jl")

default(legendfontsize = 9, guidefont = (12, :black), tickfont = (11, :black))

const is_russian = false
const population_coef = 10072

function confidence(x::Vector{Float64}, tstar::Float64 = 2.35)
    SE = std(x) / sqrt(length(x))
    return tstar * SE
end

function plot_incidence_time_series()
    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ';', Float64, '\n')
    num_years = size(incidence_data, 2) - flu_starting_index_immmunity_bias
    incidence_data = vec(incidence_data[2:53, flu_starting_index:end]) ./ population_coef

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ';', Int, '\n') ./ population_coef
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ';', Int, '\n') ./ population_coef
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ';', Int, '\n') ./ population_coef
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ';', Int, '\n') ./ population_coef

    infected_data_mean = cat(
        vec(infected_data_0[2:53, flu_starting_index:end]),
        vec(infected_data_3[2:53, flu_starting_index:end]),
        vec(infected_data_7[2:53, flu_starting_index:end]),
        vec(infected_data_15[2:53, flu_starting_index:end]),
        dims = 2,
    )

    # ticks = range(1, stop = (52.14285 * num_years), length = 6 * num_years + 1)
    # ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    # if is_russian
    #     ticklabels = ["Авг 1999" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг 2000" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг 2001"]
    # end

    ticks = range(1, stop = (52.14285 * num_years), length = num_years)
    ticklabels = ["1996" "1997" "1998" "1999" "2000" "2001" "2002"]

    label_names = ["model" "data"]
    if is_russian
        label_names = ["модель" "данные"]
    end

    # xlabel_name = "Month"
    # if is_russian
    #     xlabel_name = "Месяц"
    # end

    xlabel_name = "Year"
    if is_russian
        xlabel_name = "Год"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    mean_incidence_plot = plot(
        1:length(incidence_data),
        incidence_data,
        lw = 1.5,
        legend = false,
        color = :black,
        xticks = (ticks, ticklabels),
        grid = true,
        size = (800, 500),
        margin = 6Plots.mm,
        xrotation = 45,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(mean_incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence_time_series.pdf"))

    age_groups = ["0-2", "3-6", "7-14", "15+"]
    for i = eachindex(age_groups)
        incidence_plot = plot(
            1:(52 * num_years),
            infected_data_mean[:, i],
            lw = 1.5,
            xticks = (ticks, ticklabels),
            label = label_names,
            margin = 6Plots.mm,
            xrotation = 45,
            grid = true,
            size = (800, 500),
            legend = false,
            color = :black,
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
        savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence_$(age_groups[i])_time_series.pdf"))
    end
end

function plot_incidence_time_series_all()
    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu_full.csv"), ';', Float64, '\n')
    incidence_data = vec(incidence_data[2:53, 2:end])

    years = collect(1959:2002)
    xs = [1959, 1970, 1979, 1989, 2002]
    ys = [5085, 7061, 7931, 8875, 10382]
    itp_cubic = interpolate(xs, ys, FritschCarlsonMonotonicInterpolation())
    mean_values = zeros(Float64, 44)
    for i in eachindex(years)
        mean_value = 0.0
        for j = 1:52
            incidence_data[(i - 1) * 52 + j] = incidence_data[(i - 1) * 52 + j] / itp_cubic(years[i])
            mean_value += incidence_data[(i - 1) * 52 + j]
        end
        mean_values[i] = mean_value / 52
    end

    ticks = [52 * ((i - 1) * 4 + 3) + 1 for i = 1:11]
    ticks = range(157, stop = length(incidence_data) - 51, length = 11)
    ticklabels = ["1962" "1966" "1970" "1974" "1978" "1982" "1986" "1990" "1994" "1998" "2002"]

    xlabel_name = "Year"
    if is_russian
        xlabel_name = "Год"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    mean_incidence_plot = plot(
        157:length(incidence_data) - 13,
        incidence_data[157:end - 13],
        lw = 1.5,
        legend = false,
        color = :black,
        xticks = (ticks, ticklabels),
        grid = true,
        size = (800, 500),
        margin = 6Plots.mm,
        xrotation = 45,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    savefig(mean_incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence_time_series_all.pdf"))

    itp_cubic = interpolate([i * 52 for i = 1:44], mean_values, FritschCarlsonMonotonicInterpolation())
    incidence_plot = plot(
        157:length(incidence_data) - 52,
        x -> itp_cubic(x),
        lw = 1.5,
        legend = false,
        color = :black,
        xticks = (ticks, ticklabels),
        grid = true,
        size = (800, 500),
        margin = 6Plots.mm,
        xrotation = 45,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence_time_series_all_mean.pdf"))
end

function plot_incidence()
    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ';', Float64, '\n') ./ population_coef
    incidence_data_mean = mean(incidence_data[2:53, flu_starting_index:end], dims = 2)[:, 1]

    incidence_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ';', Int, '\n') ./ population_coef
    incidence_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ';', Int, '\n') ./ population_coef
    incidence_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ';', Int, '\n') ./ population_coef
    incidence_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ';', Int, '\n') ./ population_coef

    incidence_data_mean_0 = mean(incidence_data_0[2:53, flu_starting_index:end], dims = 2)[:, 1]
    incidence_data_mean_3 = mean(incidence_data_3[2:53, flu_starting_index:end], dims = 2)[:, 1]
    incidence_data_mean_7 = mean(incidence_data_7[2:53, flu_starting_index:end], dims = 2)[:, 1]
    incidence_data_mean_15 = mean(incidence_data_15[2:53, flu_starting_index:end], dims = 2)[:, 1]

    infected_data_age_groups = cat(
        incidence_data_0,
        incidence_data_3,
        incidence_data_7,
        incidence_data_15,
        dims = 3,
    )

    infected_data_age_groups_mean = cat(
        incidence_data_mean_0,
        incidence_data_mean_3,
        incidence_data_mean_7,
        incidence_data_mean_15,
        dims = 2,
    )

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Jul"]
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

    confidence_arr = zeros(Float64, 52)
    for i = 1:52
        confidence_arr[i] = confidence(incidence_data[i + 1, flu_starting_index:end])
    end
    incidence_plot = plot(
        1:52,
        incidence_data_mean,
        lw = 1.5,
        legend = false,
        color = RGB(0.0, 0.0, 0.0),
        xticks = (ticks, ticklabels),
        ribbon = confidence_arr,
        grid = true,
        fillalpha = .5,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence.pdf"))

    age_groups = ["0-2", "3-6", "7-14", "15+"]
    confidence_arr = zeros(Float64, 52)
    for age_index = eachindex(age_groups)
        for i = 1:52
            confidence_arr[i] = confidence(infected_data_age_groups[i + 1, flu_starting_index:size(infected_data_age_groups, 2), age_index], 2.45)
        end
        incidence_plot = plot(
            1:52,
            infected_data_age_groups_mean[:, age_index],
            lw = 1.5,
            xticks = (ticks, ticklabels),
            margin = 6Plots.mm,
            xrotation = 45,
            grid = true,
            size = (800, 500),
            legend = false,
            color = :black,
            ribbon = confidence_arr,
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
        savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence_$(age_groups[age_index]).pdf"))
    end
end

function plot_incidence_viruses()
    etiology = get_etiology()

    virus_ratio = etiology ./ sum(etiology, dims = 2)

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Number of cases"
    if is_russian
        ylabel_name = "Число выявленных случаев"
    end

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    virus_names = ["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"]
    virus_names_labels = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"]

    for i = 1:size(etiology, 2)
        virus_plot = plot(
            1:52,
            etiology[:, i],
            lw = 1.5,
            legend = false,
            color = "black",
            xticks = (ticks, ticklabels),
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            grid = true,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
        savefig(virus_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "etiology", "$(virus_names[i])_plot.pdf"))
    end

    all_plot = plot(
        1:52,
        [etiology[:, i] for i = 1:size(etiology, 2)],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        label = virus_names_labels,
        xticks = (ticks, ticklabels),
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(all_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "etiology", "all_infections.pdf"))

    Flu_plot = plot(
        1:52,
        [etiology[:, i] for i = 1:2],
        lw = 1.5,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667)],
        label = virus_names[1:2],
        xticks = (ticks, ticklabels),
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(Flu_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "etiology", "flu_infections.pdf"))

    non_Flu_plot = plot(
        1:52,
        [etiology[:, i] for i = 3:size(etiology, 2)],
        lw = 1.5,
        color = [RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        label = virus_names[3:size(etiology, 2)],
        xticks = (ticks, ticklabels),
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(non_Flu_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "etiology", "non_flu_infections.pdf"))

    ylabel_name = "Ratio"
    if is_russian
        ylabel_name = "Доля"
    end

    etiology_plot = plot(
        1:52,
        [virus_ratio[:, i] for i = 1:size(etiology, 2)],
        legend = (0.85, 0.97),
        lw = 1.5,
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        label = virus_names_labels,
        xticks = (ticks, ticklabels),
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(etiology_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "etiology", "etiology.pdf"))
end

function plot_incidence_etiology_bars()
    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ';', Float64, '\n')
    incidence_data_mean = mean(incidence_data[2:53, flu_starting_index:end], dims = 2)[:, 1] ./ population_coef

    confidence_arr = zeros(Float64, 52)
    for i = 1:52
        confidence_arr[i] = confidence(incidence_data[i + 1, flu_starting_index:end] ./ population_coef)
    end

    etiology = get_etiology()

    infected_data_1 = etiology[:, 1] .* incidence_data_mean
    infected_data_2 = etiology[:, 2] .* incidence_data_mean
    infected_data_3 = etiology[:, 3] .* incidence_data_mean
    infected_data_4 = etiology[:, 4] .* incidence_data_mean
    infected_data_5 = etiology[:, 5] .* incidence_data_mean
    infected_data_6 = etiology[:, 6] .* incidence_data_mean
    infected_data_7 = etiology[:, 7] .* incidence_data_mean
    infected_data_viruses = cat(
        vec(infected_data_1),
        vec(infected_data_2),
        vec(infected_data_3),
        vec(infected_data_4),
        vec(infected_data_5),
        vec(infected_data_6),
        vec(infected_data_7),
        dims = 2)

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    virus_names_labels = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"]
    if is_russian
        virus_names_labels = ["Грипп A" "Грипп B" "Риновирус" "РСВ" "Аденовирус" "Парагрипп" "Коронавирус"]
    end

    incidence_plot = groupedbar(
        infected_data_viruses,
        bar_position = :stack,
        markerstrokecolor = :black,
        markercolor = :black,
        grid = false,
        color = cat(RGB(0.933, 0.4, 0.467), RGB(0.267, 0.467, 0.667), RGB(0.133, 0.533, 0.2), RGB(0.667, 0.2, 0.467), RGB(0.8, 0.733, 0.267), RGB(0.5, 0.5, 0.5), RGB(0.4, 0.8, 0.933), dims = 2),
        label = virus_names_labels,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        margin = 5Plots.mm,
        size = (800, 500),
        xticks = (ticks, ticklabels),
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "etiology", "incidence_etiology_bars.pdf"))
end

function plot_temperature()
    temperature_data = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "temperature.csv"))))[1, :]
    temperature_data_rearranged = Float64[]
    append!(temperature_data_rearranged, temperature_data[213:end])
    append!(temperature_data_rearranged, temperature_data[1:212])

    ticks = range(1, stop = 365, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Air temperature, °C"
    if is_russian
        ylabel_name = "Температура воздуха, °C"
    end

    temperature_plot = plot(
        1:365,
        temperature_data_rearranged,
        lw = 1.5,
        color = RGB(0.0, 0.0, 0.0),
        xticks = (ticks, ticklabels),
        grid = true,
        legend = false,
        right_margin = 14Plots.mm,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "temperature.pdf"))
end

function incidence_temperature_corr()
    temperature_data = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "temperature.csv"))))[1, :]
    temperature_data_rearranged = Float64[]
    append!(temperature_data_rearranged, temperature_data[213:end])
    append!(temperature_data_rearranged, temperature_data[1:212])

    temperature_data_weekly = zeros(Float64, 52)
    for i = 1:52
        for j = 1:7
            temperature_data_weekly[i] += temperature_data_rearranged[(i - 1) * 7 + j]
        end
        temperature_data_weekly[i] /= 7
    end

    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ';', Float64, '\n')
    incidence_data_mean = mean(incidence_data[2:53, flu_starting_index:end], dims = 2)[:, 1] ./ population_coef

    println(cor(temperature_data_weekly, incidence_data_mean))
end

plot_incidence_time_series()
plot_incidence_time_series_all()
plot_incidence()

plot_incidence_viruses()
plot_incidence_etiology_bars()

plot_temperature()
incidence_temperature_corr()
