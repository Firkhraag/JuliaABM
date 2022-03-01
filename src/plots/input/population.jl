using DelimitedFiles
using Plots
using Statistics
using StatsPlots
using LaTeXStrings
using CategoricalArrays

# default(legendfontsize = 9, guidefont = (14, :black), tickfont = (9, :black))
default(legendfontsize = 11, guidefont = (14, :black), tickfont = (11, :black))

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

    s = 0.0
    for i = 1:18
        s += (num_people_model_vec[i] - num_people_data_vec[i])^2
    end
    # 8.427377045e10
    # 2.9657067362e10
    println(s)

    num_people_data = append!(num_people_data_vec, num_people_model_vec)

    # legend = repeat(["data", "model"], inner = 18)
    legend = repeat(["данные", "модель"], inner = 18)

    labels = CategoricalArray(repeat(["0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85-89"], outer = 3))
    levels!(labels, ["0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85-89"])

    yticks = [2.5 * 10^5, 5.0 * 10^5, 7.5 * 10^5, 1.0 * 10^6]
    yticklabels = ["250000" "500000" "750000" "1000000"]

    age_distribution_plot = groupedbar(
        labels,
        num_people_data,
        group = legend,
        linewidth = 0.6,
        # title = "Age distribution",
        size = (1000, 500),
        color = reshape([:coral2, :dodgerblue], (1, 2)),
        margin = 8Plots.mm,
        xrotation = 45,
        # xlabel = L"\textrm{\sffamily Age}",
        # ylabel = L"\textrm{\sffamily Number}"
        # xlabel = "Age",
        # ylabel = "Num",
        xlabel = "Возраст",
        ylabel = "Число",
        grid = false,
        yticks = (yticks, yticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "age_distribution_groups.pdf"))
end

function age_distribution()
    age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "age_groups_nums.csv"), ',', Int, '\n')

    labels = CategoricalArray(string.(collect(0:89)))
    levels!(labels, string.(collect(0:89)))

    xticks = [0, 20, 40, 60, 80]
    xticklabels = ["0", "20", "40", "60", "80"]

    yticks = [5.0 * 10^4, 1.0 * 10^5, 1.5 * 10^5, 2.0 * 10^5]
    yticklabels = ["50000" "100000" "150000" "200000"]

    age_distribution_plot = groupedbar(
        collect(0:89),
        age_groups_nums,
        legend = false,
        linewidth = 0.6,
        # xlabel = L"\textrm{\sffamily Age}",
        # ylabel = L"\textrm{\sffamily Number}"
        xlabel = "Возраст",
        ylabel = "Число",
        grid = false,
        ylim = (0, 200000),
        xticks = (xticks, xticklabels),
        yticks = (yticks, yticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "age_distribution.pdf"))
end

function household_size_distribution()
    household_size_distribution = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "household_size_distribution.csv"), ',', Int, '\n')

    num_households_data_vec = [1118631, 1056816, 922206, 575250, 236758, 148261]
    num_households_data = append!(num_households_data_vec, vec(household_size_distribution))

    labels = CategoricalArray(repeat(["1", "2", "3", "4", "5", "6"], outer = 3))
    levels!(labels, ["1", "2", "3", "4", "5", "6"])

    # legend = repeat(["data", "model"], inner = 6)
    legend = repeat(["данные", "модель"], inner = 6)

    yticks = [2.5 * 10^5, 5.0 * 10^5, 7.5 * 10^5, 1.0 * 10^6]
    yticklabels = ["250000" "500000" "750000" "1000000"]

    household_size_distribution_plot = groupedbar(
        labels,
        num_households_data,
        group = legend,
        yticks = (yticks, yticklabels),
        color = reshape([:coral2, :dodgerblue], (1, 2)),
        # xlabel = L"\textrm{\sffamily Size}",
        # ylabel = L"\textrm{\sffamily Number}"
        xlabel = "Размер",
        ylabel = "Число",
        grid = false
    )
    savefig(household_size_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "household_size_distribution.pdf"))
end

function workplace_sizes_distribution()
    workplaces_num_people = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "workplaces_num_people.csv"), ',', Int, '\n'))
    workplaces_num_people = sort(workplaces_num_people)
    workplace_size_distribution = [(i, count(==(i), workplaces_num_people)) for i in unique(workplaces_num_people)]

    println(workplace_size_distribution)

    workplace_size_distribution_plot = plot(
        first.(workplace_size_distribution),
        last.(workplace_size_distribution),
        lw = 3,
        legend = false,
        # xticks = (ticks, ticklabels),
        grid = false,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Temperature, °C}",
        xlabel = "Размер фирмы",
        ylabel = "Количество",
    )
    savefig(workplace_size_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "workplace_size_distribution.pdf"))
end

# age_distribution_groups()
# age_distribution()
# household_size_distribution()
workplace_sizes_distribution()
