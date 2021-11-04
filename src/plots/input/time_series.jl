using DelimitedFiles
using Plots
using Statistics
using StatsPlots
using LaTeXStrings
using CategoricalArrays

include("../../data/temperature.jl")
include("../../data/etiology.jl")

# default(legendfontsize = 10, guidefont = (14, :black), tickfont = (10, :black))
default(legendfontsize = 9, guidefont = (14, :black), tickfont = (9, :black))

function plot_temperature()
    temperature_data = get_air_temperature()
    temperature_data_rearranged = Float64[]
    append!(temperature_data_rearranged, temperature_data[213:end])
    append!(temperature_data_rearranged, temperature_data[1:212])

    ticks = range(1, stop = 365, length = 7)
    ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    temperature_plot = plot(
        1:365,
        temperature_data_rearranged,
        lw = 3,
        legend = false,
        color = "orange",
        xticks = (ticks, ticklabels),
        grid = false,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Temperature, °C}",
        xlabel = "Месяц",
        ylabel = "Температура, °C",
    )
    savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "temperature.pdf"))
end

function plot_incidence()
    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    incidence_data_mean = mean(incidence_data[39:45, 2:53], dims = 1)[1, :] ./ 10072

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    incidence_plot = plot(
        1:52,
        incidence_data_mean,
        lw = 3,
        legend = false,
        color = "red",
        xticks = (ticks, ticklabels),
        grid = false,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Num of cases per 1000 people}",
        xlabel = "Месяц",
        ylabel = "Число случаев на 1000 ч.",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence.pdf"))
end

function plot_incidence_age_groups()
    incidence_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    incidence_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    incidence_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    incidence_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    incidence_data_mean_0 = mean(incidence_data_0[2:53, 21:27], dims = 2)[:, 1] ./ 10072
    incidence_data_mean_3 = mean(incidence_data_3[2:53, 21:27], dims = 2)[:, 1] ./ 10072
    incidence_data_mean_7 = mean(incidence_data_7[2:53, 21:27], dims = 2)[:, 1] ./ 10072
    incidence_data_mean_15 = mean(incidence_data_15[2:53, 21:27], dims = 2)[:, 1] ./ 10072

    incidence_plot = plot(1:52, incidence_data_mean_0, title = "Incidence", lw = 3, legend = false)
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence0-2.pdf"))

    incidence_plot = plot(1:52, incidence_data_mean_3, title = "Incidence", lw = 3, legend = false)
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence3-6.pdf"))

    incidence_plot = plot(1:52, incidence_data_mean_7, title = "Incidence", lw = 3, legend = false)
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence7-14.pdf"))

    incidence_plot = plot(1:52, incidence_data_mean_15, title = "Incidence", lw = 3, legend = false)
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence15+.pdf"))
end

function plot_etiology()
    etiology_data = get_random_infection_probabilities()
    etiology_data[:, 2] = etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data[:, 3] = etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data[:, 4] = etiology_data[:, 4] .- etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data[:, 5] = etiology_data[:, 5] .- etiology_data[:, 4] .- etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data[:, 6] = etiology_data[:, 6] .- etiology_data[:, 5] .- etiology_data[:, 4] .- etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data = [etiology_data (1 .- etiology_data[:, 6] .- etiology_data[:, 5] .- etiology_data[:, 4] .- etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1])]

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    etiology_plot = plot(
        1:52,
        [etiology_data[:, i] for i in 1:7],
        legend = (0.85, 0.97),
        lw = 3,
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        xticks = (ticks, ticklabels),
        ylim = (0, 0.85),
        grid = false,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Ratio}",
        xlabel = "Месяц",
        ylabel = "Доля",
    )
    savefig(etiology_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "etiology.pdf"))
end

plot_temperature()
plot_incidence()
plot_incidence_age_groups()
plot_etiology()
