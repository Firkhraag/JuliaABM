using DelimitedFiles
using Plots
using Statistics
using StatsPlots
using LaTeXStrings
using CategoricalArrays
using Distributions

default(legendfontsize = 9, guidefont = (12, :black), tickfont = (11, :black))

const is_russian = true

function age_distribution_groups()
    num_people_data_vec = [433175, 420460, 399159, 495506, 869700, 924829, 892794, 831873, 757411,
        818571, 833850, 697220, 640330, 358392, 503280, 281946, 230579, 136843]
    age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "age_nums.csv"), ',', Int, '\n')

    num_people_model_vec = zeros(Int, 18)
    for i = 1:18
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 1, 1]
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 2, 1]
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 3, 1]
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 4, 1]
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 5, 1]
    end

    nMAE = sum(abs.(num_people_model_vec - num_people_data_vec)) / sum(num_people_data_vec)
    println("Age nMAE = $(nMAE)")

    num_people_data = append!(num_people_data_vec, num_people_model_vec)

    legend = repeat(["data", "model"], inner = 18)
    if is_russian
        legend = repeat(["данные", "модель"], inner = 18)
    end

    labels = CategoricalArray(repeat(["0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85-89"], outer = 3))
    levels!(labels, ["0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85-89"])

    yticks = [2.5 * 10^5, 5.0 * 10^5, 7.5 * 10^5, 1.0 * 10^6]
    yticklabels = ["250000" "500000" "750000" "1000000"]

    xlabel_name = "Age"
    if is_russian
        xlabel_name = "Возраст агента"
    end
    ylabel_name = "Number"
    if is_russian
        ylabel_name = "Число агентов"
    end

    age_distribution_plot = groupedbar(
        labels,
        num_people_data,
        group = legend,
        linewidth = 0.6,
        size = (1000, 500),
        color = reshape([RGB(0.267, 0.467, 0.667), RGB(0.933, 0.4, 0.467)], (1, 2)),
        margin = 8Plots.mm,
        xrotation = 45,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
        grid = true,
        yticks = (yticks, yticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "age_distribution_groups.pdf"))
end

function age_distribution()
    age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "age_nums.csv"), ',', Int, '\n')

    labels = CategoricalArray(string.(collect(0:89)))
    levels!(labels, string.(collect(0:89)))

    xticks = [0, 10, 20, 30, 40, 50, 60, 70, 80]
    xticklabels = ["0", "10", "20", "30", "40", "50", "60", "70", "80"]

    yticks = [5.0 * 10^4, 1.0 * 10^5, 1.5 * 10^5, 2.0 * 10^5]
    yticklabels = ["50000" "100000" "150000" "200000"]

    xlabel_name = "Age"
    if is_russian
        xlabel_name = "Возраст"
    end
    ylabel_name = "Number of agents"
    if is_russian
        ylabel_name = "Число агентов"
    end

    age_distribution_plot = groupedbar(
        collect(0:89),
        age_groups_nums,
        linewidth = 0.6,
        color = RGB(0.267, 0.467, 0.667),
        legend = false,
        margin = 8Plots.mm,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
        size=(800,400),
        grid = true,
        ylim = (0, 200000),
        xticks = (xticks, xticklabels),
        yticks = (yticks, yticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "age_distribution.pdf"))
end

function household_size_distribution()
    household_size_distribution = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "household_size_distribution.csv"), ',', Int, '\n')

    num_households_data_vec = [1118631, 1056816, 922206, 575250, 236758, 148261]

    arr = vec(household_size_distribution)
    nMAE = sum(abs.(arr - num_households_data_vec)) / sum(num_households_data_vec)
    println("Household size nMAE = $(nMAE)")

    append!(num_households_data_vec, vec(household_size_distribution))

    labels = CategoricalArray(repeat(["1", "2", "3", "4", "5", "6"], outer = 3))
    levels!(labels, ["1", "2", "3", "4", "5", "6"])

    legend = repeat(["data", "model"], inner = 6)
    if is_russian
        legend = repeat(["данные", "модель"], inner = 6)
    end

    yticks = [2.5 * 10^5, 5.0 * 10^5, 7.5 * 10^5, 1.0 * 10^6]
    yticklabels = ["250000" "500000" "750000" "1000000"]

    xlabel_name = "Size"
    if is_russian
        xlabel_name = "Размер домохозяйств"
    end
    ylabel_name = "Number"
    if is_russian
        ylabel_name = "Число домохозяйств"
    end

    household_size_distribution_plot = groupedbar(
        labels,
        num_households_data_vec,
        group = legend,
        yticks = (yticks, yticklabels),
        color = reshape([RGB(0.267, 0.467, 0.667), RGB(0.933, 0.4, 0.467)], (1, 2)),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
        grid = true,
    )
    savefig(household_size_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "household_size_distribution.pdf"))
end

function workplace_sizes_distribution_lognormal()
    firm_min_size = 1
    firm_max_size = 1000
    lognormal = truncated(LogNormal(1.3, 1.7), firm_min_size, firm_max_size)

    yticks = [1e-6, 1e-4, 1e-2, 1.0]

    xlabel_name = "Size"
    if is_russian
        xlabel_name = "Размер"
    end
    ylabel_name = "Frequency"
    if is_russian
        ylabel_name = "Частота"
    end

    workplace_size_distribution_plot = plot(
        x -> pdf(lognormal, x),
        lw = 1.5,
        xaxis=:log,
        yaxis=:log,
        legend = false,
        yticks = yticks,
        grid = true,
        color = :black,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        margin = 2Plots.mm,
        xlims = (1.0, 1000.0),
        ylims = (1e-6, 1.0),
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(workplace_size_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "workplace_size_distribution.pdf"))
end

age_distribution_groups()
age_distribution()
household_size_distribution()
workplace_sizes_distribution_lognormal()
