using DelimitedFiles
using Plots
using Statistics
using LaTeXStrings

include("../../data/etiology.jl")

default(legendfontsize = 14, guidefont = (20, :black), tickfont = (14, :black))

function plot_contacts_inside_collective()
    contacts_inside_collective_data = readdlm(
        joinpath(@__DIR__, "..", "..", "..", "output", "tables", "contacts_inside_collective_data.csv"), ',', Float64)

    collective_sizes = readdlm(
        joinpath(@__DIR__, "..", "..", "..", "output", "tables", "collective_sizes.csv"), ',', Int)

    contacts_inside_collective = Array{Float64, 2}(undef, 52, 5)
    for i = 1:52
        for j = 1:5
            contacts_inside_collective[i, j] = sum(contacts_inside_collective_data[(i - 1) * 7 + 1:(i - 1) * 7 + 7, j])
        end
    end

    contacts_inside_collective[:, 1] ./= collective_sizes[1]
    contacts_inside_collective[:, 2] ./= collective_sizes[2]
    contacts_inside_collective[:, 3] ./= collective_sizes[3]
    contacts_inside_collective[:, 4] ./= collective_sizes[4]
    contacts_inside_collective[:, 5] ./= 10072668

    ticks = range(1, stop = 52, length = 13)
    ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    contacts_inside_collective_plot = plot(
        1:52,
        [contacts_inside_collective[:, i] ./ 7 for i = 1:5],
        lw = 3,
        xticks = (ticks, ticklabels),
        title = "Weekly average number of contacts",
        ylim = (0, 49),
        label = ["Kindergarten" "School" "College" "Workplace" "Household"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Num of contacts}",
        xlabel = "Month",
        ylabel = "Num of contacts",
    )
    savefig(
        contacts_inside_collective_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts_inside_collective.pdf"))
end

function plot_infected_inside_collective()
    infected_inside_collective_data = readdlm(
        joinpath(@__DIR__, "..", "..", "..", "output", "tables", "infected_inside_collective_data.csv"), ',', Float64)

    collective_sizes = readdlm(
        joinpath(@__DIR__, "..", "..", "..", "output", "tables", "collective_sizes.csv"), ',', Int)

    infected_inside_collective = Array{Float64, 2}(undef, 52, 5)
    for i = 1:52
        for j = 1:5
            infected_inside_collective[i, j] = sum(infected_inside_collective_data[(i - 1) * 7 + 1:(i - 1) * 7 + 7, j])
        end
    end

    infected_inside_collective[:, 1] ./= collective_sizes[1]
    infected_inside_collective[:, 2] ./= collective_sizes[2]
    infected_inside_collective[:, 3] ./= collective_sizes[3]
    infected_inside_collective[:, 4] ./= collective_sizes[4]
    infected_inside_collective[:, 5] ./= 10072668

    println(mean(infected_inside_collective[:, 1]))
    println(mean(infected_inside_collective[:, 2]))
    println(mean(infected_inside_collective[:, 3]))
    println(mean(infected_inside_collective[:, 4]))
    println(mean(infected_inside_collective[:, 5]))

    # ticks = range(1, stop = 52, length = 13)
    # ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    yticks = [0.0, 0.025, 0.05, 0.075, 0.1]
    yticklabels = ["0.0", "0.025", "0.05", "0.075", "0.1"]
    infected_inside_collective_plot = plot(
        1:52,
        [infected_inside_collective[:, i] for i = 1:5],
        lw = 3,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        ylims = (0.0, 0.125),
        legend = (0.77, 0.95),
        label = ["Kindergarten" "School" "College" "Workplace" "Household"],
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Proportion}",
        xlabel = "Month",
        ylabel = "Proportion",
    )
    savefig(
        infected_inside_collective_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "infected_inside_collective.pdf"))
end

plot_contacts_inside_collective()
plot_infected_inside_collective()
