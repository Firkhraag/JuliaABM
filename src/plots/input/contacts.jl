using DelimitedFiles
using Plots
using Statistics
using StatsPlots
using LaTeXStrings
using CategoricalArrays

default(legendfontsize = 9, guidefont = (12, :black), tickfont = (11, :black))

function plot_num_contacts()
    kindergarten_contacts = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "kindergarten_contacts.csv"), ',', Float64, '\n')
    labels = collect(7:19)
    ticks = [7, 10, 13, 16, 19]
    ticklabels = ["7", "10", "13", "16", "19"]
    
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
        xlabel = "Число контактов",
        ylabel = "Число агентов, совершающих заданное число контактов",
    )
    savefig(num_contacts_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "contacts", "kindergarten_num_contacts.pdf"))

    school_contacts = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "school_contacts.csv"), ',', Float64, '\n')
    labels = collect(10:25)
    ticks = [10, 13, 16, 19, 22, 25]
    ticklabels = ["10", "13", "16", "19", "22", "25"]

    # yticks = [0.5 * 10^4, 1.0 * 10^5, 1.5 * 10^5]
    # yticklabels = [L"0.5 * 10^4", L"1.0 * 10^5", L"1.5 * 10^5"]

    num_contacts_plot = groupedbar(
        labels,
        school_contacts[10:25, :],
        xticks = (ticks, ticklabels),
        # yticks = (yticks, yticklabels),
        color = RGB(0.5, 0.5, 0.5),
        markerstrokecolor = :black,
        markercolor = :black,
        legend = false,
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = "Число контактов",
        ylabel = "Число агентов",
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
        xlabel = "Число контактов",
        ylabel = "Число агентов",
    )
    savefig(num_contacts_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "contacts", "college_num_contacts.pdf"))

    work_contacts = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "work_contacts.csv"), ',', Float64, '\n')
    labels = collect(10:50)

    println(sum(work_contacts[11:51, 1]))

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

function plot_work_contacts()
    work_contacts = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "work_contacts.csv"), ',', Float64, '\n')
    labels = collect(10:50)

    println(sum(work_contacts[11:51, 1]))

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

# plot_num_contacts()
plot_work_contacts()
