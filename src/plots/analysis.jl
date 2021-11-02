using DelimitedFiles
using Plots
using Statistics
using LaTeXStrings

include("../data/etiology.jl")
include("../util/burnin.jl")

default(legendfontsize = 18, guidefont = (25, :black), tickfont = (18, :black))

function plot_incidences()
    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    duration_parameter = mean(duration_parameter_array[burnin:step:length(duration_parameter_array)])

    susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))

    susceptibility_parameter_1_array = susceptibility_parameter_1_array[burnin:step:length(susceptibility_parameter_1_array)]
    susceptibility_parameter_2_array = susceptibility_parameter_2_array[burnin:step:length(susceptibility_parameter_2_array)]
    susceptibility_parameter_3_array = susceptibility_parameter_3_array[burnin:step:length(susceptibility_parameter_3_array)]
    susceptibility_parameter_4_array = susceptibility_parameter_4_array[burnin:step:length(susceptibility_parameter_4_array)]
    susceptibility_parameter_5_array = susceptibility_parameter_5_array[burnin:step:length(susceptibility_parameter_5_array)]
    susceptibility_parameter_6_array = susceptibility_parameter_6_array[burnin:step:length(susceptibility_parameter_6_array)]
    susceptibility_parameter_7_array = susceptibility_parameter_7_array[burnin:step:length(susceptibility_parameter_7_array)]

    susceptibility_parameters = [
        mean(susceptibility_parameter_1_array),
        mean(susceptibility_parameter_2_array),
        mean(susceptibility_parameter_3_array),
        mean(susceptibility_parameter_4_array),
        mean(susceptibility_parameter_5_array),
        mean(susceptibility_parameter_6_array),
        mean(susceptibility_parameter_7_array)]

    temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))
 
    temperature_parameter_1_array = temperature_parameter_1_array[burnin:step:length(temperature_parameter_1_array)]
    temperature_parameter_2_array = temperature_parameter_2_array[burnin:step:length(temperature_parameter_2_array)]
    temperature_parameter_3_array = temperature_parameter_3_array[burnin:step:length(temperature_parameter_3_array)]
    temperature_parameter_4_array = temperature_parameter_4_array[burnin:step:length(temperature_parameter_4_array)]
    temperature_parameter_5_array = temperature_parameter_5_array[burnin:step:length(temperature_parameter_5_array)]
    temperature_parameter_6_array = temperature_parameter_6_array[burnin:step:length(temperature_parameter_6_array)]
    temperature_parameter_7_array = temperature_parameter_7_array[burnin:step:length(temperature_parameter_7_array)]

    temperature_parameters = [
        mean(temperature_parameter_1_array),
        mean(temperature_parameter_2_array),
        mean(temperature_parameter_3_array),
        mean(temperature_parameter_4_array),
        mean(temperature_parameter_5_array),
        mean(temperature_parameter_6_array),
        mean(temperature_parameter_7_array)]

    incidence = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data.csv"), ',', Float64)

    d_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_d_-2.csv"), ',', Float64)
    d_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_d_-1.csv"), ',', Float64)
    d_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_d_1.csv"), ',', Float64)
    d_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_d_2.csv"), ',', Float64)

    s1_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s1_-2.csv"), ',', Float64)
    s1_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s1_-1.csv"), ',', Float64)
    s1_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s1_1.csv"), ',', Float64)
    s1_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s1_2.csv"), ',', Float64)

    s2_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s2_-2.csv"), ',', Float64)
    s2_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s2_-1.csv"), ',', Float64)
    s2_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s2_1.csv"), ',', Float64)
    s2_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s2_2.csv"), ',', Float64)

    s3_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s3_-2.csv"), ',', Float64)
    s3_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s3_-1.csv"), ',', Float64)
    s3_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s3_1.csv"), ',', Float64)
    s3_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s3_2.csv"), ',', Float64)

    s4_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s4_-2.csv"), ',', Float64)
    s4_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s4_-1.csv"), ',', Float64)
    s4_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s4_1.csv"), ',', Float64)
    s4_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s4_2.csv"), ',', Float64)

    s5_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s5_-2.csv"), ',', Float64)
    s5_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s5_-1.csv"), ',', Float64)
    s5_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s5_1.csv"), ',', Float64)
    s5_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s5_2.csv"), ',', Float64)

    s6_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s6_-2.csv"), ',', Float64)
    s6_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s6_-1.csv"), ',', Float64)
    s6_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s6_1.csv"), ',', Float64)
    s6_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s6_2.csv"), ',', Float64)

    s7_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s7_-2.csv"), ',', Float64)
    s7_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s7_-1.csv"), ',', Float64)
    s7_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s7_1.csv"), ',', Float64)
    s7_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_s7_2.csv"), ',', Float64)

    t1_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t1_-2.csv"), ',', Float64)
    t1_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t1_-1.csv"), ',', Float64)
    t1_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t1_1.csv"), ',', Float64)
    t1_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t1_2.csv"), ',', Float64)

    t2_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t2_-2.csv"), ',', Float64)
    t2_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t2_-1.csv"), ',', Float64)
    t2_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t2_1.csv"), ',', Float64)
    t2_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t2_2.csv"), ',', Float64)

    t3_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t3_-2.csv"), ',', Float64)
    t3_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t3_-1.csv"), ',', Float64)
    t3_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t3_1.csv"), ',', Float64)
    t3_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t3_2.csv"), ',', Float64)

    t4_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t4_-2.csv"), ',', Float64)
    t4_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t4_-1.csv"), ',', Float64)
    t4_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t4_1.csv"), ',', Float64)
    t4_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t4_2.csv"), ',', Float64)

    t5_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t5_-2.csv"), ',', Float64)
    t5_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t5_-1.csv"), ',', Float64)
    t5_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t5_1.csv"), ',', Float64)
    t5_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t5_2.csv"), ',', Float64)

    t6_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t6_-2.csv"), ',', Float64)
    t6_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t6_-1.csv"), ',', Float64)
    t6_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t6_1.csv"), ',', Float64)
    t6_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t6_2.csv"), ',', Float64)

    t7_minus_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t7_-2.csv"), ',', Float64)
    t7_minus_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t7_-1.csv"), ',', Float64)
    t7_1 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t7_1.csv"), ',', Float64)
    t7_2 = readdlm(joinpath(@__DIR__, "..", "..", "sensitivity", "tables", "infected_data_t7_2.csv"), ',', Float64)

    # ticks = range(1, stop = 52, length = 13)
    # ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    yticks = [2, 6, 10, 14]
    yticklabels = ["2", "6", "10", "14"]
    incidence_plot = plot(
        1:52,
        [d_minus_2 d_minus_1 incidence d_1 d_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        legend = (0.91, 1.0),
        ylims = (0, 17),
        margin = 2Plots.mm,
        label = ["$(round(duration_parameter * 0.8, digits = 2))" "$(round(duration_parameter * 0.9, digits = 2))" "$(round(duration_parameter, digits = 2))" "$(round(duration_parameter * 1.1, digits = 2))" "$(round(duration_parameter * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "d.pdf"))

    incidence_plot = plot(
        1:52,
        [s1_minus_2 s1_minus_1 incidence s1_1 s1_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        label = ["$(round(susceptibility_parameters[1] * 0.8, digits = 2))" "$(round(susceptibility_parameters[1] * 0.9, digits = 2))" "$(round(susceptibility_parameters[1], digits = 2))" "$(round(susceptibility_parameters[1] * 1.1, digits = 2))" "$(round(susceptibility_parameters[1] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "s1.pdf"))

    incidence_plot = plot(
        1:52,
        [s2_minus_2 s2_minus_1 incidence s2_1 s2_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        label = ["$(round(susceptibility_parameters[2] * 0.8, digits = 2))" "$(round(susceptibility_parameters[2] * 0.9, digits = 2))" "$(round(susceptibility_parameters[2], digits = 2))" "$(round(susceptibility_parameters[2] * 1.1, digits = 2))" "$(round(susceptibility_parameters[2] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "s2.pdf"))

    incidence_plot = plot(
        1:52,
        [s3_minus_2 s3_minus_1 incidence s3_1 s3_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(susceptibility_parameters[3] * 0.8, digits = 2))" "$(round(susceptibility_parameters[3] * 0.9, digits = 2))" "$(round(susceptibility_parameters[3], digits = 2))" "$(round(susceptibility_parameters[3] * 1.1, digits = 2))" "$(round(susceptibility_parameters[3] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "s3.pdf"))

    incidence_plot = plot(
        1:52,
        [s4_minus_2 s4_minus_1 incidence s4_1 s4_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.85, 0.95),
        label = ["$(round(susceptibility_parameters[4] * 0.8, digits = 2))" "$(round(susceptibility_parameters[4] * 0.9, digits = 2))" "$(round(susceptibility_parameters[4], digits = 2))" "$(round(susceptibility_parameters[4] * 1.1, digits = 2))" "$(round(susceptibility_parameters[4] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "s4.pdf"))

    incidence_plot = plot(
        1:52,
        [s5_minus_2 s5_minus_1 incidence s5_1 s5_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 1.0),
        ylims = (0, 13),
        label = ["$(round(susceptibility_parameters[5] * 0.8, digits = 2))" "$(round(susceptibility_parameters[5] * 0.9, digits = 2))" "$(round(susceptibility_parameters[5], digits = 2))" "$(round(susceptibility_parameters[5] * 1.1, digits = 2))" "$(round(susceptibility_parameters[5] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "s5.pdf"))

    incidence_plot = plot(
        1:52,
        [s6_minus_2 s6_minus_1 incidence s6_1 s6_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.92, 0.98),
        label = ["$(round(susceptibility_parameters[6] * 0.8, digits = 2))" "$(round(susceptibility_parameters[6] * 0.9, digits = 2))" "$(round(susceptibility_parameters[6], digits = 2))" "$(round(susceptibility_parameters[6] * 1.1, digits = 2))" "$(round(susceptibility_parameters[6] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "s6.pdf"))

    incidence_plot = plot(
        1:52,
        [s7_minus_2 s7_minus_1 incidence s7_1 s7_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(round(susceptibility_parameters[7] * 0.8, digits = 2))" "$(round(susceptibility_parameters[7] * 0.9, digits = 2))" "$(round(susceptibility_parameters[7], digits = 2))" "$(round(susceptibility_parameters[7] * 1.1, digits = 2))" "$(round(susceptibility_parameters[7] * 1.2, digits = 2))"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "s7.pdf"))

    incidence_plot = plot(
        1:52,
        [t1_minus_2 t1_minus_1 incidence t1_1 t1_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[1], digits = 2))" "$(0.75)" "$(1.0)"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "t1.pdf"))

    incidence_plot = plot(
        1:52,
        [t2_minus_2 t2_minus_1 incidence t2_1 t2_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[2], digits = 2))" "$(0.75)" "$(1.0)"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "t2.pdf"))

    incidence_plot = plot(
        1:52,
        [t3_minus_2 t3_minus_1 incidence t3_1 t3_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[3], digits = 2))" "$(0.75)" "$(1.0)"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "t3.pdf"))

    incidence_plot = plot(
        1:52,
        [t4_minus_2 t4_minus_1 incidence t4_1 t4_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[4], digits = 2))" "$(0.75)" "$(1.0)"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "t4.pdf"))

    incidence_plot = plot(
        1:52,
        [t5_minus_2 t5_minus_1 incidence t5_1 t5_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[5], digits = 2))" "$(0.75)" "$(1.0)"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "t5.pdf"))

    incidence_plot = plot(
        1:52,
        [t6_minus_2 t6_minus_1 incidence t6_1 t6_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[6], digits = 2))" "$(0.75)" "$(1.0)"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "t6.pdf"))

    incidence_plot = plot(
        1:52,
        [t7_minus_2 t7_minus_1 incidence t7_1 t7_2],
        lw = 3,
        xticks = (ticks, ticklabels),
        margin = 2Plots.mm,
        legend = (0.91, 0.95),
        label = ["$(0.25)" "$(0.5)" "$(round(temperature_parameters[7], digits = 2))" "$(0.75)" "$(1.0)"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Cases per 1000 people}",
        xlabel = "Month",
        ylabel = "Cases per 1000 people",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "sensitivity", "plots", "t7.pdf"))
end

plot_incidences()
