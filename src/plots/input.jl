using DelimitedFiles
using Plots
using Statistics

include("../data/temperature.jl")
include("../data/etiology.jl")

function plot_temperature()
    temperature_data = get_air_temperature()
    temperature_data_rearranged = Float64[]
    append!(temperature_data_rearranged, temperature_data[213:end])
    append!(temperature_data_rearranged, temperature_data[1:212])

    ticks = range(1, stop = 365, length = 13)
    ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    temperature_plot = plot(1:365, temperature_data_rearranged,
        lw = 3, legend = false, color = "orange", xticks = (ticks, ticklabels), fontfamily = "Times")
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

    ticks = range(1, stop = 365, length = 13)
    ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    temperature_plot = plot(1:365, temperature_data_rearranged,
        lw = 3, legend = false, color = "orange", xticks = (ticks, ticklabels), fontfamily = "Times")
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
        # legend=:top,
        legend=(0.5, 0.95),
        fontfamily = "Times",
        lw = 3,
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        xticks = (ticks, ticklabels))
    xlabel!("Month")
    ylabel!("Ratio of viruses")
    savefig(etiology_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "etiology.pdf"))
end

scalefontsizes(1.2)

# plot_temperature()
# plot_incidence()
# plot_incidence_age_groups()
plot_etiology()
