using DelimitedFiles
using Plots
using Statistics
using StatsPlots
using LaTeXStrings
using CategoricalArrays
using Distributions

default(legendfontsize = 9, guidefont = (12, :black), tickfont = (11, :black))

const is_russian = false

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
        color = reshape([RGB(0.267, 0.467, 0.667), RGB(0.933, 0.4, 0.467)], (1, 2)),
        margin = 8Plots.mm,
        xrotation = 45,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        # xlabel = L"\textrm{\sffamily Age}",
        # ylabel = L"\textrm{\sffamily Number}"
        # xlabel = "Age",
        # ylabel = "Num",
        xlabel = "Возраст",
        ylabel = "Число",
        grid = true,
        yticks = (yticks, yticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "age_distribution_groups.pdf"))
end

function age_distribution()
    age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "age_nums.csv"), ',', Int, '\n')

    labels = CategoricalArray(string.(collect(0:89)))
    levels!(labels, string.(collect(0:89)))

    xticks = [0, 20, 40, 60, 80]
    xticklabels = ["0", "20", "40", "60", "80"]

    yticks = [5.0 * 10^4, 1.0 * 10^5, 1.5 * 10^5, 2.0 * 10^5]
    yticklabels = ["50000" "100000" "150000" "200000"]

    age_distribution_plot = groupedbar(
        collect(0:89),
        age_groups_nums,
        linewidth = 0.6,
        # color = :grey,
        color = RGB(0.267, 0.467, 0.667),
        legend = false,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        # xlabel = L"\textrm{\sffamily Age}",
        # ylabel = L"\textrm{\sffamily Number}"
        xlabel = "Возраст",
        ylabel = "Число",
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
        color = reshape([RGB(0.267, 0.467, 0.667), RGB(0.933, 0.4, 0.467)], (1, 2)),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        # xlabel = L"\textrm{\sffamily Size}",
        # ylabel = L"\textrm{\sffamily Number}"
        xlabel = "Размер",
        ylabel = "Число",
        grid = true,
    )
    savefig(household_size_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "household_size_distribution.pdf"))


    # num_households_data = [1118631 1056816 922206 575250 236758 148261]

    # labels = CategoricalArray(["1", "2", "3", "4", "5", "6", "7"])
    # levels!(labels, ["1", "2", "3", "4", "5", "6", "7"])
    # legend = repeat(["0-15"], inner = 6)

    # incubation_periods_plot = groupedbar(
    #     labels,
    #     num_households_data,
    #     group = legend,
    #     color = RGB(0.5, 0.5, 0.5),
    #     # color = RGB(0.267, 0.467, 0.667),
    #     markerstrokecolor = :black,
    #     markercolor = :black,
    #     legend = false,
    #     grid = true,
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     # xlabel = L"\textrm{\sffamily Virus}",
    #     # ylabel = L"\textrm{\sffamily Incubation period duration, days}",
    #     xxlabel = "Размер",
    #     ylabel = "Число",
    # )
    # savefig(incubation_periods_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "household_size_distribution.pdf"))
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
        # xticks = (ticks, ticklabels),
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Temperature, °C}",
        xlabel = "Размер фирмы",
        ylabel = "Количество",
    )
    savefig(workplace_size_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "workplace_size_distribution.pdf"))
end

function workplace_sizes_distribution_lognormal()
    firm_min_size = 0
    firm_max_size = 1000
    lognormal = truncated(LogNormal(1.3, 1.7), firm_min_size, firm_max_size)

    yticks = [1e-6, 1e-4, 1e-2, 1.0]

    workplace_size_distribution_plot = plot(
        x -> pdf(lognormal, x),
        lw = 1,
        xaxis=:log,
        yaxis=:log,
        legend = false,
        yticks = yticks,
        # xticks = (ticks, ticklabels),
        grid = true,
        color = :black,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Temperature, °C}",
        margin = 2Plots.mm,
        xlims = (1.0, 1000.0),
        ylims = (1e-6, 1.0),
        xlabel = "Размер фирмы",
        ylabel = "Частота",
    )
    savefig(workplace_size_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "workplace_size_distribution.pdf"))
end

age_distribution_groups()
age_distribution()
household_size_distribution()
# workplace_sizes_distribution()
# workplace_sizes_distribution_lognormal()
