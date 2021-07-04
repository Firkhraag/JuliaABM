using DelimitedFiles
using Plots
using Statistics
using StatsPlots
using CategoricalArrays

include("../data/temperature.jl")
include("../data/etiology.jl")

default(legendfontsize = 10, guidefont = (14, :black), tickfont = (10, :black))

function plot_temperature()
    temperature_data = get_air_temperature()
    temperature_data_rearranged = Float64[]
    append!(temperature_data_rearranged, temperature_data[213:end])
    append!(temperature_data_rearranged, temperature_data[1:212])

    ticks = range(1, stop = 365, length = 13)
    ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    temperature_plot = plot(
        1:365,
        temperature_data_rearranged,
        lw = 3,
        legend = false,
        color = "orange",
        xticks = (ticks, ticklabels),
        fontfamily = "Times")
    xlabel!("Month")
    ylabel!("Temperature, °C")
    savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "temperature.pdf"))
end

function plot_incidence()
    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    incidence_data_mean = mean(incidence_data[42:45, 2:53], dims = 1)[1, :] ./ 9897

    ticks = range(1, stop = 52, length = 13)
    ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    incidence_plot = plot(1:52, incidence_data_mean, 
        lw = 3, legend = false, color = "red", xticks = (ticks, ticklabels), fontfamily = "Times")
    xlabel!("Month")
    ylabel!("Num of cases per 1000 people")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "incidence.pdf"))
end

function plot_incidence_age_groups()
    incidence_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    incidence_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    incidence_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    incidence_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    incidence_data_mean_0 = mean(incidence_data_0[2:53, 24:27], dims = 2)[:, 1] ./ 9897
    incidence_data_mean_3 = mean(incidence_data_3[2:53, 24:27], dims = 2)[:, 1] ./ 9897
    incidence_data_mean_7 = mean(incidence_data_7[2:53, 24:27], dims = 2)[:, 1] ./ 9897
    incidence_data_mean_15 = mean(incidence_data_15[2:53, 24:27], dims = 2)[:, 1] ./ 9897

    incidence_plot = plot(1:52, incidence_data_mean_0, title = "Incidence", lw = 3, legend = false)
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "incidence0-2.pdf"))

    incidence_plot = plot(1:52, incidence_data_mean_3, title = "Incidence", lw = 3, legend = false)
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "incidence3-6.pdf"))

    incidence_plot = plot(1:52, incidence_data_mean_7, title = "Incidence", lw = 3, legend = false)
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "incidence7-14.pdf"))

    incidence_plot = plot(1:52, incidence_data_mean_15, title = "Incidence", lw = 3, legend = false)
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "incidence15+.pdf"))
end

function plot_temperature()
    temperature_data = get_air_temperature()
    temperature_data_rearranged = Float64[]
    append!(temperature_data_rearranged, temperature_data[213:end])
    append!(temperature_data_rearranged, temperature_data[1:212])

    yticks = [-5.0, 0.0, 5.0, 10.0, 15.0, 20.0]
    yticklabels = ["-5", "0", "5", "10", "15", "20"]

    ticks = range(1, stop = 365, length = 13)
    ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    temperature_plot = plot(1:365, temperature_data_rearranged,
        lw = 3,
        legend = false,
        color = "orange",
        xticks = (ticks, ticklabels),
        fontfamily = "Times",
        yticks = (yticks, yticklabels))
    xlabel!("Month")
    ylabel!("Temperature, °C")
    savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "temperature.pdf"))
end

function plot_etiology()
    etiology_data = get_random_infection_probabilities()
    etiology_data[:, 2] = etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data[:, 3] = etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data[:, 4] = etiology_data[:, 4] .- etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data[:, 5] = etiology_data[:, 5] .- etiology_data[:, 4] .- etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data[:, 6] = etiology_data[:, 6] .- etiology_data[:, 5] .- etiology_data[:, 4] .- etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data = [etiology_data (1 .- etiology_data[:, 6] .- etiology_data[:, 5] .- etiology_data[:, 4] .- etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1])]

    ticks = range(1, stop = 52, length = 13)
    ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    etiology_plot = plot(
        1:52,
        [etiology_data[:, i] for i in 1:7],
        legend=(0.85, 0.97),
        fontfamily = "Times",
        lw = 3,
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        xticks = (ticks, ticklabels),
        ylim=(0,0.85))
    xlabel!("Month")
    ylabel!("Ratio of viruses")
    savefig(etiology_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "etiology.pdf"))
end

function plot_incubation_periods()
    labels = CategoricalArray(["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"])
    levels!(labels, ["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"])

    mean = [1.4, 1.0, 1.9, 4.4, 5.6, 2.6, 3.2]
    legend = repeat(["0-15"], inner = 7)
    std = [0.3, 0.22, 0.42, 0.968, 1.229, 0.572, 0.704]

    incubation_periods_plot = groupedbar(
        labels,
        mean,
        yerr = std,
        group = legend,
        fontfamily = "Times",
        color=:dodgerblue,
        legend = false)
    xlabel!("Virus")
    ylabel!("Incubation period duration, days")
    savefig(incubation_periods_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "incubation_periods.pdf"))
end

function plot_infection_periods()
    labels = CategoricalArray(repeat(["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"], outer = 3))
    levels!(labels, ["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"])

    yticks = [0.0, 3.0, 6.0, 9.0, 12.0]
    yticklabels = ["0", "3", "6", "9", "12"]

    mean = [4.8, 3.7, 10.1, 7.4, 8.0, 7.0, 7.0, 8.8, 7.8, 11.4, 9.3, 9.0, 8.0, 8.0]
    legend = repeat(["0-15", "16+"], inner = 7)
    std = [1.058, 0.8124, 2.22, 1.63, 1.76, 1.54, 1.54, 1.936, 1.715, 2.5, 2.0, 1.98, 1.76, 1.76]

    infection_periods_plot = groupedbar(
        labels,
        mean,
        yerr = std,
        group = legend,
        fontfamily = "Times",
        yticks = (yticks, yticklabels))
    xlabel!("Virus")
    ylabel!("Infection period duration, days")
    savefig(infection_periods_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "infection_periods.pdf"))
end

function plot_mean_viral_loads()
    labels = CategoricalArray(repeat(["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"], outer = 3))
    levels!(labels, ["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"])

    mean = [4.6, 4.7, 3.5, 6.0, 4.1, 4.8, 4.93, 3.45, 3.525, 2.625, 4.5, 3.075, 3.6, 3.6975, 2.3, 2.35, 1.75, 3.0, 2.05, 2.4, 2.465]

    legend = CategoricalArray(repeat(["0-2", "3-15", "16+"], inner = 7))
    levels!(legend, ["0-2", "3-15", "16+"])

    yticks = [0.0, 2.0, 4.0, 6.0]
    yticklabels = ["0", "2", "4", "6"]

    viral_loads_plot = groupedbar(
        labels,
        mean,
        group = legend,
        ylabel = "Scores",
        fontfamily = "Times",
        yticks = (yticks, yticklabels),
        ylim = (0,7.0))
    xlabel!("Virus")
    ylabel!("Viral load, log(cp/ml)")
    savefig(viral_loads_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "viral_loads.pdf"))
end

function plot_monthly_incidence()
    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    incidence_data = incidence_data[35:45, 2:53]

    println(mean(incidence_data[:, 1]))
    println(std(incidence_data[:, 1]))

    # incidence_plot = histogram(incidence_data[:, 1], bins=:scott, weights=repeat(1:5, outer=2))
    incidence_plot = histogram(incidence_data[:, 1], bins=6)

    # # ticks = range(1, stop = 52, length = 13)
    # # ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    # incidence_plot = plot(1:11, [incidence_data[i, 1] for i in 1:11], 
    #     lw = 3, legend = false, color = "red", fontfamily = "Times")
    xlabel!("Year")
    ylabel!("Num of cases per 1000 people")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "monthly_incidence.pdf"))
end

# plot_monthly_incidence()
# plot_temperature()
plot_incidence()
# plot_incidence_age_groups()
# plot_etiology()
# plot_incubation_periods()
# plot_infection_periods()
# plot_mean_viral_loads()
