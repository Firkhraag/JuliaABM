using DelimitedFiles
using Plots

include("../data/temperature.jl")

function plot_temperature()
    temperature_data = get_air_temperature()
    temperature_data_rearranged = Float64[]
    append!(temperature_data_rearranged, temperature_data[213:end])
    append!(temperature_data_rearranged, temperature_data[1:212])

    temperature_plot = plot(1:365, temperature_data_rearranged, title = "Air temperature", lw = 3, legend = false)
    xlabel!("Day")
    ylabel!("°C")
    savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "temperature.pdf"))
end

function plot_incidence()
    incidence_data = get_air_incidence()
    incidence_data_rearranged = Float64[]
    append!(incidence_data_rearranged, incidence_data[213:end])
    append!(incidence_data_rearranged, incidence_data[1:212])

    incidence_plot = plot(1:365, incidence_data_rearranged, title = "Air incidence", lw = 3, legend = false)
    xlabel!("Day")
    ylabel!("°C")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "incidence.pdf"))
end

plot_temperature()
