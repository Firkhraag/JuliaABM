using DelimitedFiles
using Plots
using Statistics
using StatsPlots
using LaTeXStrings
using CategoricalArrays

default(legendfontsize = 9, guidefont = (12, :black), tickfont = (11, :black))

const is_russian = false

function plot_num_contacts()
    kindergarten_contacts = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "kindergarten_contacts.csv"), ',', Float64, '\n')
    labels = collect(7:19)
    ticks = [7, 10, 13, 16, 19]
    ticklabels = ["7", "10", "13", "16", "19"]

    xlabel_name = "Number of contacts"
    if is_russian
        xlabel_name = "Число контактов"
    end

    ylabel_name = "Number of agents"
    if is_russian
        ylabel_name = "Число агентов"
    end
    
    num_contacts_plot = groupedbar(
        labels,
        kindergarten_contacts[7:19, :],
        xticks = (ticks, ticklabels),
        color = RGB(0.5, 0.5, 0.5),
        markerstrokecolor = :black,
        markercolor = :black,
        legend = false,
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(num_contacts_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "contacts", "kindergarten_num_contacts.pdf"))

    school_contacts = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "school_contacts.csv"), ',', Float64, '\n')
    labels = collect(10:25)
    ticks = [10, 13, 16, 19, 22, 25]
    ticklabels = ["10", "13", "16", "19", "22", "25"]

    num_contacts_plot = groupedbar(
        labels,
        school_contacts[10:25, :],
        xticks = (ticks, ticklabels),
        color = RGB(0.5, 0.5, 0.5),
        markerstrokecolor = :black,
        markercolor = :black,
        legend = false,
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(num_contacts_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "contacts", "school_num_contacts.pdf"))

    college_contacts = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "college_contacts.csv"), ',', Float64, '\n')
    labels = collect(10:16)
    ticks = [10, 13, 16]
    ticklabels = ["10", "13", "16"]

    num_contacts_plot = groupedbar(
        labels,
        college_contacts[10:16, :],
        xticks = (ticks, ticklabels),
        color = RGB(0.5, 0.5, 0.5),
        markerstrokecolor = :black,
        markercolor = :black,
        legend = false,
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(num_contacts_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "contacts", "college_num_contacts.pdf"))

    work_contacts = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "work_contacts.csv"), ',', Float64, '\n')
    labels = collect(10:50)

    num_contacts_plot = groupedbar(
        labels,
        work_contacts[11:51, :],
        color = RGB(0.5, 0.5, 0.5),
        markerstrokecolor = :black,
        markercolor = :black,
        legend = false,
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = "Степень вершины",
        ylabel = "Число вершин",
    )
    savefig(num_contacts_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "contacts", "work_num_contacts.pdf"))
end

plot_num_contacts()
