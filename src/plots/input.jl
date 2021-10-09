using DelimitedFiles
using Plots
using Statistics
using StatsPlots
using LaTeXStrings
using CategoricalArrays

include("../data/temperature.jl")
include("../data/etiology.jl")

# default(legendfontsize = 10, guidefont = (14, :black), tickfont = (10, :black))
# default(legendfontsize = 9, guidefont = (12, :black), tickfont = (9, :black))
default(legendfontsize = 9, guidefont = (14, :black), tickfont = (9, :black))
# default(legendfontsize = 12, guidefont = (17, :black), tickfont = (12, :black))

function workplace_sizes_distribution()
    workplaces_num_people1 = vec(readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "workplaces_num_people1.csv"), ',', Int, '\n'))
    workplaces_num_people2 = vec(readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "workplaces_num_people2.csv"), ',', Int, '\n'))
    workplaces_num_people3 = vec(readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "workplaces_num_people3.csv"), ',', Int, '\n'))
    workplaces_num_people4 = vec(readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "workplaces_num_people4.csv"), ',', Int, '\n'))

    workplaces_num_people = append!(workplaces_num_people1, workplaces_num_people2)
    workplaces_num_people = append!(workplaces_num_people, workplaces_num_people3)
    workplaces_num_people = append!(workplaces_num_people, workplaces_num_people4)
    workplaces_num_people = sort(workplaces_num_people)
    workplace_size_distribution = [(i, count(==(i), workplaces_num_people)) for i in unique(workplaces_num_people)]

    println(length(workplace_size_distribution))

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

    savefig(workplace_size_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "workplace_size_distribution_plot.pdf"))
end

function age_distribution_groups()

    num_people_data_vec = [482706, 464029, 438403, 541724, 963365, 1028257, 975748, 902265, 825823, 906344, 922120, 759863, 682891, 381686, 538020, 300376, 244526, 143476]
    # num_people_data = reshape(num_people_data_vec, length(num_people_data_vec), 1)

    age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums.csv"), ',', Int, '\n')

    num_people_model_vec = zeros(Int, 18)
    for i = 1:18
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 1, 1]
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 2, 1]
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 3, 1]
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 4, 1]
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 5, 1]
    end
    # num_people_data = reshape(num_people_model_vec, length(num_people_model_vec), 1)

    num_people_data = append!(num_people_data_vec, num_people_model_vec)

    legend = repeat(["data", "model"], inner = 18)

    labels = CategoricalArray(repeat(["0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85-89"], outer = 3))
    levels!(labels, ["0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85-89"])

    # xticks = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
    # xticklabels = ["0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85-89"]

    yticks = [2.5 * 10^5, 5.0 * 10^5, 7.5 * 10^5, 1.0 * 10^6]
    yticklabels = ["250000" "500000" "750000" "1000000"]

    age_distribution_plot = groupedbar(
        labels,
        num_people_data,
        group = legend,
        linewidth = 0.6,
        title = "Age distribution",
        size = (1000, 500),
        color = reshape([:coral2, :dodgerblue], (1, 2)),
        margin = 6Plots.mm,
        # color = reshape(palette(:auto)[1:16], (1,16)),
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        # xticks = (xticks, xticklabels),
        yticks = (yticks, yticklabels),
    )

    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_groups.pdf"))
end

function age_distribution_model()
    age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums.csv"), ',', Int, '\n')

    num_people_data_vec = zeros(Int, 18)
    for i = 1:18
        num_people_data_vec[i] += age_groups_nums[(i - 1) * 5 + 1, 1]
        num_people_data_vec[i] += age_groups_nums[(i - 1) * 5 + 2, 1]
        num_people_data_vec[i] += age_groups_nums[(i - 1) * 5 + 3, 1]
        num_people_data_vec[i] += age_groups_nums[(i - 1) * 5 + 4, 1]
        num_people_data_vec[i] += age_groups_nums[(i - 1) * 5 + 5, 1]
    end
    num_people_data = reshape(num_people_data_vec, length(num_people_data_vec), 1)

    labels = CategoricalArray(string.(collect(0:17)))
    levels!(labels, string.(collect(0:17)))

    xticks = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
    xticklabels = ["0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85-89"]

    age_distribution_plot = groupedbar(
        collect(0:17),
        num_people_data,
        legend = false,
        linewidth = 0.6,
        title = "Data",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )

    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_model.pdf"))

    # ---------------------------------------------------------------

    age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_1.csv"), ',', Int, '\n')
    num_people_data_vec = zeros(Int, 8)
    for i = 1:15
        num_people_data_vec[1] += age_groups_nums[i]
    end
    for i = 16:18
        num_people_data_vec[2] += age_groups_nums[i]
    end
    for i = 19:25
        num_people_data_vec[3] += age_groups_nums[i]
    end
    for i = 26:35
        num_people_data_vec[4] += age_groups_nums[i]
    end
    for i = 36:45
        num_people_data_vec[5] += age_groups_nums[i]
    end
    for i = 46:55
        num_people_data_vec[6] += age_groups_nums[i]
    end
    for i = 56:65
        num_people_data_vec[7] += age_groups_nums[i]
    end
    for i = 66:90
        num_people_data_vec[8] += age_groups_nums[i]
    end
    num_people_data = reshape(num_people_data_vec, length(num_people_data_vec), 1)

    labels = CategoricalArray(string.(collect(0:7)))
    levels!(labels, string.(collect(0:7)))

    xticks = [0, 1, 2, 3, 4, 5, 6, 7]
    xticklabels = ["0-14", "15-17", "18-24", "25-34", "35-44", "45-54", "55-64", "65+"]

    age_distribution_plot = groupedbar(
        collect(0:7),
        num_people_data,
        legend = false,
        linewidth = 0.6,
        title = "Model 1",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_model_1.pdf"))

    age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_2.csv"), ',', Int, '\n')
    num_people_data_vec = zeros(Int, 8)
    for i = 1:15
        num_people_data_vec[1] += age_groups_nums[i]
    end
    for i = 16:18
        num_people_data_vec[2] += age_groups_nums[i]
    end
    for i = 19:25
        num_people_data_vec[3] += age_groups_nums[i]
    end
    for i = 26:35
        num_people_data_vec[4] += age_groups_nums[i]
    end
    for i = 36:45
        num_people_data_vec[5] += age_groups_nums[i]
    end
    for i = 46:55
        num_people_data_vec[6] += age_groups_nums[i]
    end
    for i = 56:65
        num_people_data_vec[7] += age_groups_nums[i]
    end
    for i = 66:90
        num_people_data_vec[8] += age_groups_nums[i]
    end
    num_people_data = reshape(num_people_data_vec, length(num_people_data_vec), 1)

    age_distribution_plot = groupedbar(
        collect(0:7),
        num_people_data,
        legend = false,
        linewidth = 0.6,
        title = "Model 2",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_model_2.pdf"))

    age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_3.csv"), ',', Int, '\n')
    num_people_data_vec = zeros(Int, 8)
    for i = 1:15
        num_people_data_vec[1] += age_groups_nums[i]
    end
    for i = 16:18
        num_people_data_vec[2] += age_groups_nums[i]
    end
    for i = 19:25
        num_people_data_vec[3] += age_groups_nums[i]
    end
    for i = 26:35
        num_people_data_vec[4] += age_groups_nums[i]
    end
    for i = 36:45
        num_people_data_vec[5] += age_groups_nums[i]
    end
    for i = 46:55
        num_people_data_vec[6] += age_groups_nums[i]
    end
    for i = 56:65
        num_people_data_vec[7] += age_groups_nums[i]
    end
    for i = 66:90
        num_people_data_vec[8] += age_groups_nums[i]
    end
    num_people_data = reshape(num_people_data_vec, length(num_people_data_vec), 1)

    age_distribution_plot = groupedbar(
        collect(0:7),
        num_people_data,
        legend = false,
        linewidth = 0.6,
        title = "Model 3",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_model_3.pdf"))

    age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_4.csv"), ',', Int, '\n')
    num_people_data_vec = zeros(Int, 8)
    for i = 1:15
        num_people_data_vec[1] += age_groups_nums[i]
    end
    for i = 16:18
        num_people_data_vec[2] += age_groups_nums[i]
    end
    for i = 19:25
        num_people_data_vec[3] += age_groups_nums[i]
    end
    for i = 26:35
        num_people_data_vec[4] += age_groups_nums[i]
    end
    for i = 36:45
        num_people_data_vec[5] += age_groups_nums[i]
    end
    for i = 46:55
        num_people_data_vec[6] += age_groups_nums[i]
    end
    for i = 56:65
        num_people_data_vec[7] += age_groups_nums[i]
    end
    for i = 66:90
        num_people_data_vec[8] += age_groups_nums[i]
    end
    num_people_data = reshape(num_people_data_vec, length(num_people_data_vec), 1)

    age_distribution_plot = groupedbar(
        collect(0:7),
        num_people_data,
        legend = false,
        linewidth = 0.6,
        title = "Model 4",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_model_4.pdf"))

    age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_5.csv"), ',', Int, '\n')
    num_people_data_vec = zeros(Int, 8)
    for i = 1:15
        num_people_data_vec[1] += age_groups_nums[i]
    end
    for i = 16:18
        num_people_data_vec[2] += age_groups_nums[i]
    end
    for i = 19:25
        num_people_data_vec[3] += age_groups_nums[i]
    end
    for i = 26:35
        num_people_data_vec[4] += age_groups_nums[i]
    end
    for i = 36:45
        num_people_data_vec[5] += age_groups_nums[i]
    end
    for i = 46:55
        num_people_data_vec[6] += age_groups_nums[i]
    end
    for i = 56:65
        num_people_data_vec[7] += age_groups_nums[i]
    end
    for i = 66:90
        num_people_data_vec[8] += age_groups_nums[i]
    end
    num_people_data = reshape(num_people_data_vec, length(num_people_data_vec), 1)

    age_distribution_plot = groupedbar(
        collect(0:7),
        num_people_data,
        legend = false,
        linewidth = 0.6,
        title = "Model 5+",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_model_5+.pdf"))
end

function age_distribution_data()
    num_people_data_vec = [482706, 464029, 438403, 541724, 963365, 1028257, 975748, 902265, 825823, 906344, 922120, 759863, 682891, 381686, 538020, 300376, 244526, 143476]
    num_people_data = reshape(num_people_data_vec, length(num_people_data_vec), 1)

    labels = CategoricalArray(string.(collect(0:17)))
    levels!(labels, string.(collect(0:17)))

    xticks = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
    xticklabels = ["0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85-89"]

    age_distribution_plot = groupedbar(
        collect(0:17),
        num_people_data,
        legend = false,
        linewidth = 0.6,
        title = "Data",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_data.pdf"))

    num_people_data_vec = [3681, 10862, 136140, 174283, 167371, 181407, 182310, 341499]
    num_people_data = reshape(num_people_data_vec, length(num_people_data_vec), 1)

    labels = CategoricalArray(string.(collect(0:7)))
    levels!(labels, string.(collect(0:7)))

    xticks = [0, 1, 2, 3, 4, 5, 6, 7]
    xticklabels = ["0-14", "15-17", "18-24", "25-34", "35-44", "45-54", "55-64", "65+"]

    age_distribution_plot = groupedbar(
        collect(0:7),
        num_people_data,
        legend = false,
        linewidth = 0.6,
        title = "Data 1",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_data_1.pdf"))

    num_people_data_vec = [112432, 34063, 201960, 356412, 301265, 381884, 394116, 515879]
    num_people_data = reshape(num_people_data_vec, length(num_people_data_vec), 1)

    age_distribution_plot = groupedbar(
        collect(0:7),
        num_people_data,
        legend = false,
        linewidth = 0.6,
        title = "Data 2",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_data_2.pdf"))

    num_people_data_vec = [358332, 75387, 336866, 558165, 494945, 541491, 361521, 318805]
    num_people_data = reshape(num_people_data_vec, length(num_people_data_vec), 1)

    age_distribution_plot = groupedbar(
        collect(0:7),
        num_people_data,
        legend = false,
        linewidth = 0.6,
        title = "Data 3",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_data_3.pdf"))

    num_people_data_vec = [442011, 83579, 295152, 445478, 404316, 399842, 252920, 216230]
    num_people_data = reshape(num_people_data_vec, length(num_people_data_vec), 1)

    age_distribution_plot = groupedbar(
        collect(0:7),
        num_people_data,
        legend = false,
        linewidth = 0.6,
        title = "Data 4",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_data_4.pdf"))

    num_people_data_vec = [467367, 67980, 249236, 468202, 358952, 322412, 250161, 213446]
    num_people_data = reshape(num_people_data_vec, length(num_people_data_vec), 1)

    age_distribution_plot = groupedbar(
        collect(0:7),
        num_people_data,
        legend = false,
        linewidth = 0.6,
        title = "Data 5+",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_data_5+.pdf"))
end

function age_distribution()
    age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums.csv"), ',', Int, '\n')
    age_groups_nums_P1 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_P1.csv"), ',', Int, '\n')
    age_groups_nums_PWOP2P0C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP2P0C.csv"), ',', Int, '\n')
    age_groups_nums_PWOP3P0C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP3P0C.csv"), ',', Int, '\n')
    age_groups_nums_PWOP3P1C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP3P1C.csv"), ',', Int, '\n')
    age_groups_nums_PWOP4P0C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP4P0C.csv"), ',', Int, '\n')
    age_groups_nums_PWOP4P1C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP4P1C.csv"), ',', Int, '\n')
    age_groups_nums_PWOP4P2C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP4P2C.csv"), ',', Int, '\n')
    age_groups_nums_PWOP5P0C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP5P0C.csv"), ',', Int, '\n')
    age_groups_nums_PWOP5P1C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP5P1C.csv"), ',', Int, '\n')
    age_groups_nums_PWOP5P2C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP5P2C.csv"), ',', Int, '\n')
    age_groups_nums_PWOP5P3C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP5P3C.csv"), ',', Int, '\n')
    age_groups_nums_PWOP6P0C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP6P0C.csv"), ',', Int, '\n')
    age_groups_nums_PWOP6P1C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP6P1C.csv"), ',', Int, '\n')
    age_groups_nums_PWOP6P2C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP6P2C.csv"), ',', Int, '\n')
    age_groups_nums_PWOP6P3C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP6P3C.csv"), ',', Int, '\n')
    age_groups_nums_2PWOP4P0C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_2PWOP4P0C.csv"), ',', Int, '\n')
    age_groups_nums_2PWOP5P0C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_2PWOP5P0C.csv"), ',', Int, '\n')
    age_groups_nums_2PWOP5P1C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_2PWOP5P1C.csv"), ',', Int, '\n')
    age_groups_nums_2PWOP6P0C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_2PWOP6P0C.csv"), ',', Int, '\n')
    age_groups_nums_2PWOP6P1C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_2PWOP6P1C.csv"), ',', Int, '\n')
    age_groups_nums_2PWOP6P2C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_2PWOP6P2C.csv"), ',', Int, '\n')

    age_groups_nums_O2P0C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O2P0C.csv"), ',', Int, '\n')
    age_groups_nums_O2P1C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O2P1C.csv"), ',', Int, '\n')
    age_groups_nums_O3P0C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O3P0C.csv"), ',', Int, '\n')
    age_groups_nums_O3P1C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O3P1C.csv"), ',', Int, '\n')
    age_groups_nums_O3P2C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O3P2C.csv"), ',', Int, '\n')
    age_groups_nums_O4P0C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O4P0C.csv"), ',', Int, '\n')
    age_groups_nums_O4P1C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O4P1C.csv"), ',', Int, '\n')
    age_groups_nums_O4P2C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O4P2C.csv"), ',', Int, '\n')
    age_groups_nums_O5P0C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O5P0C.csv"), ',', Int, '\n')
    age_groups_nums_O5P1C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O5P1C.csv"), ',', Int, '\n')
    age_groups_nums_O5P2C = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O5P2C.csv"), ',', Int, '\n')

    age_groups_nums_PWOP = age_groups_nums_PWOP2P0C + age_groups_nums_PWOP3P0C + age_groups_nums_PWOP3P1C + age_groups_nums_PWOP4P0C +
        age_groups_nums_PWOP4P1C + age_groups_nums_PWOP4P2C + age_groups_nums_PWOP5P0C + age_groups_nums_PWOP5P1C + age_groups_nums_PWOP5P2C +
        age_groups_nums_PWOP5P3C + age_groups_nums_PWOP6P0C + age_groups_nums_2PWOP6P1C + age_groups_nums_2PWOP6P2C
    age_groups_nums_O = age_groups_nums_O2P0C + age_groups_nums_O2P1C + age_groups_nums_O3P0C + age_groups_nums_O3P1C +
        age_groups_nums_O3P2C + age_groups_nums_O4P0C + age_groups_nums_O4P1C + age_groups_nums_O4P2C + age_groups_nums_O5P0C +
        age_groups_nums_O5P1C + age_groups_nums_O5P2C

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
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        ylim = (0, 200000),
        xticks = (xticks, xticklabels),
        yticks = (yticks, yticklabels),
    )
    age_distribution_P1_plot = groupedbar(
        collect(0:89),
        age_groups_nums_P1,
        legend = false,
        linewidth = 0.6,
        title = "P1",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_PWOP2P0C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP2P0C,
        legend = false,
        linewidth = 0.6,
        title = "PWOP2P0C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_PWOP3P0C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP3P0C,
        legend = false,
        linewidth = 0.6,
        title = "PWOP3P0C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_PWOP3P1C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP3P1C,
        legend = false,
        linewidth = 0.6,
        title = "PWOP3P1C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_PWOP4P0C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP4P0C,
        legend = false,
        linewidth = 0.6,
        title = "PWOP4P0C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_PWOP4P1C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP4P1C,
        legend = false,
        linewidth = 0.6,
        title = "PWOP4P1C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_PWOP4P2C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP4P2C,
        legend = false,
        linewidth = 0.6,
        title = "PWOP4P2C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_PWOP5P0C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP5P0C,
        legend = false,
        linewidth = 0.6,
        title = "PWOP5P0C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_PWOP5P1C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP5P1C,
        legend = false,
        linewidth = 0.6,
        title = "PWOP5P1C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_PWOP5P2C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP5P2C,
        legend = false,
        linewidth = 0.6,
        title = "PWOP5P2C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_PWOP5P3C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP5P3C,
        legend = false,
        linewidth = 0.6,
        title = "PWOP5P3C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_PWOP6P0C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP6P0C,
        legend = false,
        linewidth = 0.6,
        title = "PWOP6P0C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_PWOP6P1C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP6P1C,
        legend = false,
        linewidth = 0.6,
        title = "PWOP6P1C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_PWOP6P2C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP6P2C,
        legend = false,
        linewidth = 0.6,
        title = "PWOP6P2C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_PWOP6P3C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP6P3C,
        legend = false,
        linewidth = 0.6,
        title = "PWOP6P3C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_2PWOP4P0C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_2PWOP4P0C,
        legend = false,
        linewidth = 0.6,
        title = "2PWOP4P0C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_2PWOP5P0C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_2PWOP5P0C,
        legend = false,
        linewidth = 0.6,
        title = "2PWOP5P0C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_2PWOP5P1C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_2PWOP5P1C,
        legend = false,
        linewidth = 0.6,
        title = "2PWOP5P1C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_2PWOP6P0C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_2PWOP6P0C,
        legend = false,
        linewidth = 0.6,
        title = "2PWOP6P0C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_2PWOP6P1C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_2PWOP6P1C,
        legend = false,
        linewidth = 0.6,
        title = "2PWOP6P1C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_2PWOP6P2C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_2PWOP6P2C,
        legend = false,
        linewidth = 0.6,
        title = "2PWOP6P2C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_O2P0C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_O2P0C,
        legend = false,
        linewidth = 0.6,
        title = "O2P0C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_O2P1C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_O2P1C,
        legend = false,
        linewidth = 0.6,
        title = "O2P1C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_O3P0C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_O3P0C,
        legend = false,
        linewidth = 0.6,
        title = "O3P0C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_O3P1C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_O3P1C,
        legend = false,
        linewidth = 0.6,
        title = "O3P1C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_O3P2C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_O3P2C,
        legend = false,
        linewidth = 0.6,
        title = "O3P2C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_O4P0C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_O4P0C,
        legend = false,
        linewidth = 0.6,
        title = "O4P0C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_O4P1C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_O4P1C,
        legend = false,
        linewidth = 0.6,
        title = "O4P1C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_O4P2C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_O4P2C,
        legend = false,
        linewidth = 0.6,
        title = "O4P2C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_O5P0C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_O5P0C,
        legend = false,
        linewidth = 0.6,
        title = "O5P0C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_O5P1C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_O5P1C,
        legend = false,
        linewidth = 0.6,
        title = "O5P1C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_O5P2C_plot = groupedbar(
        collect(0:89),
        age_groups_nums_O5P2C,
        legend = false,
        linewidth = 0.6,
        title = "O5P2C",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )

    age_distribution_PWOP_plot = groupedbar(
        collect(0:89),
        age_groups_nums_PWOP,
        legend = false,
        linewidth = 0.6,
        title = "PWOP",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )
    age_distribution_O_plot = groupedbar(
        collect(0:89),
        age_groups_nums_O,
        legend = false,
        linewidth = 0.6,
        title = "O",
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Age",
        ylabel = "Num",
        grid = false,
        xticks = (xticks, xticklabels),
    )

    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution.pdf"))
    savefig(age_distribution_P1_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_P1.pdf"))
    savefig(age_distribution_PWOP2P0C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP2P0C.pdf"))
    savefig(age_distribution_PWOP3P0C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP3P0C.pdf"))
    savefig(age_distribution_PWOP3P1C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP3P1C.pdf"))
    savefig(age_distribution_PWOP4P0C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP4P0C.pdf"))
    savefig(age_distribution_PWOP4P1C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP4P1C.pdf"))
    savefig(age_distribution_PWOP4P2C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP4P2C.pdf"))
    savefig(age_distribution_PWOP5P0C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP5P0C.pdf"))
    savefig(age_distribution_PWOP5P1C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP5P1C.pdf"))
    savefig(age_distribution_PWOP5P2C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP5P2C.pdf"))
    savefig(age_distribution_PWOP5P3C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP5P3C.pdf"))
    savefig(age_distribution_PWOP6P0C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP6P0C.pdf"))
    savefig(age_distribution_PWOP6P1C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP6P1C.pdf"))
    savefig(age_distribution_PWOP6P2C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP6P2C.pdf"))
    savefig(age_distribution_PWOP6P3C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP6P3C.pdf"))
    savefig(age_distribution_2PWOP4P0C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_2PWOP4P0C.pdf"))
    savefig(age_distribution_2PWOP5P0C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_2PWOP5P0C.pdf"))
    savefig(age_distribution_2PWOP5P1C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_2PWOP5P1C.pdf"))
    savefig(age_distribution_2PWOP6P0C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_2PWOP6P0C.pdf"))
    savefig(age_distribution_2PWOP6P1C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_2PWOP6P1C.pdf"))
    savefig(age_distribution_2PWOP6P2C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_2PWOP6P2C.pdf"))

    savefig(age_distribution_O2P0C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_O2P0C.pdf"))
    savefig(age_distribution_O2P1C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_O2P1C.pdf"))
    savefig(age_distribution_O3P0C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_O3P0C.pdf"))
    savefig(age_distribution_O3P1C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_O3P1C.pdf"))
    savefig(age_distribution_O3P2C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_O3P2C.pdf"))
    savefig(age_distribution_O4P0C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_O4P0C.pdf"))
    savefig(age_distribution_O4P1C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_O4P1C.pdf"))
    savefig(age_distribution_O4P2C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_O4P2C.pdf"))
    savefig(age_distribution_O5P0C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_O5P0C.pdf"))
    savefig(age_distribution_O5P1C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_O5P1C.pdf"))
    savefig(age_distribution_O5P2C_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_O5P2C.pdf"))

    savefig(age_distribution_PWOP_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_PWOP.pdf"))
    savefig(age_distribution_O_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age", "age_distribution_O.pdf"))

    # age_distribution = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age_distribution.csv"), ',', Int, '\n')

    # # ticks = range(1, stop = 365, length = 13)
    # # ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    # age_distribution_plot = plot(
    #     age_distribution,
    #     lw = 3,
    #     legend = false,
    #     # xlabel = L"\textrm{\sffamily Age}",
    #     # ylabel = L"\textrm{\sffamily Num}",
    #     xlabel = L"\textrm{\sffamily Age}",
    #     ylabel = L"\textrm{\sffamily Num}",
    #     kind="bar")
    # savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "age_distribution.pdf"))
end

function household_size_distribution()
    household_size_distribution = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "household_size_distribution.csv"), ',', Int, '\n')

    num_households_data_vec = [1197839, 1149095, 1015265, 634953, 257772, 161163]
    # num_households_data = reshape(num_households_data_vec, length(num_households_data_vec), 1)

    num_households_data = append!(num_households_data_vec, vec(household_size_distribution))

    labels = CategoricalArray(repeat(["1", "2", "3", "4", "5", "6"], outer = 3))
    levels!(labels, ["1", "2", "3", "4", "5", "6"])

    legend = repeat(["data", "model"], inner = 6)

    yticks = [2.5 * 10^5, 5.0 * 10^5, 7.5 * 10^5, 1.0 * 10^6]
    yticklabels = ["250000" "500000" "750000" "1000000"]

    household_size_distribution_plot = groupedbar(
        labels,
        num_households_data,
        group = legend,
        # group = legend,
        # color=:dodgerblue,
        title = "Household size distribution",
        yticks = (yticks, yticklabels),
        color = reshape([:coral2, :dodgerblue], (1, 2)),
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        xlabel = "Size",
        ylabel = "Num",
        grid = false
    )
    savefig(household_size_distribution_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "household_size_distribution.pdf"))
end

function plot_temperature()
    temperature_data = get_air_temperature()
    temperature_data_rearranged = Float64[]
    append!(temperature_data_rearranged, temperature_data[213:end])
    append!(temperature_data_rearranged, temperature_data[1:212])

    ticks = range(1, stop = 365, length = 7)
    ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    temperature_plot = plot(
        1:365,
        temperature_data_rearranged,
        lw = 3,
        legend = false,
        color = "orange",
        xticks = (ticks, ticklabels),
        grid = false,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Temperature, °C}",
        xlabel = "Месяц",
        ylabel = "Температура, °C",
    )
    savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "temperature.pdf"))
end

function plot_incidence()
    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    incidence_data_mean = mean(incidence_data[39:45, 2:53], dims = 1)[1, :] ./ 10072

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    incidence_plot = plot(
        1:52,
        incidence_data_mean,
        lw = 3,
        legend = false,
        color = "red",
        xticks = (ticks, ticklabels),
        grid = false,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Num of cases per 1000 people}",
        xlabel = "Месяц",
        ylabel = "Число случаев на 1000 ч.",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "incidence.pdf"))
end

function plot_incidence_age_groups()
    incidence_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    incidence_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    incidence_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    incidence_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    incidence_data_mean_0 = mean(incidence_data_0[2:53, 21:27], dims = 2)[:, 1] ./ 10072
    incidence_data_mean_3 = mean(incidence_data_3[2:53, 21:27], dims = 2)[:, 1] ./ 10072
    incidence_data_mean_7 = mean(incidence_data_7[2:53, 21:27], dims = 2)[:, 1] ./ 10072
    incidence_data_mean_15 = mean(incidence_data_15[2:53, 21:27], dims = 2)[:, 1] ./ 10072

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

function plot_etiology()
    etiology_data = get_random_infection_probabilities()
    etiology_data[:, 2] = etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data[:, 3] = etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data[:, 4] = etiology_data[:, 4] .- etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data[:, 5] = etiology_data[:, 5] .- etiology_data[:, 4] .- etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data[:, 6] = etiology_data[:, 6] .- etiology_data[:, 5] .- etiology_data[:, 4] .- etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1]
    etiology_data = [etiology_data (1 .- etiology_data[:, 6] .- etiology_data[:, 5] .- etiology_data[:, 4] .- etiology_data[:, 3] .- etiology_data[:, 2] .- etiology_data[:, 1])]

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    etiology_plot = plot(
        1:52,
        [etiology_data[:, i] for i in 1:7],
        legend = (0.85, 0.97),
        lw = 3,
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        xticks = (ticks, ticklabels),
        ylim = (0, 0.85),
        grid = false,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Ratio}",
        xlabel = "Месяц",
        ylabel = "Доля",
    )
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
        color=:dodgerblue,
        markerstrokecolor = :black,
        markercolor = :black,
        legend = false,
        grid = false,
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}",
        xlabel = "Вирус",
        ylabel = "Продолжительность, дней",
    )
    savefig(incubation_periods_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "incubation_periods.pdf"))
end

function plot_infection_periods()
    labels = CategoricalArray(repeat(["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"], outer = 3))
    levels!(labels, ["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"])

    yticks = [0.0, 3.0, 6.0, 9.0, 12.0]
    yticklabels = ["0", "3", "6", "9", "12"]

    mean = [4.8, 3.7, 10.1, 7.4, 8.0, 7.0, 6.5, 8.8, 7.8, 11.4, 9.3, 9.0, 8.0, 7.5]
    legend = repeat(["0-15", "16+"], inner = 7)
    std = [1.058, 0.8124, 2.22, 1.63, 1.76, 1.54, 1.54, 1.936, 1.715, 2.5, 2.0, 1.98, 1.76, 1.76]

    infection_periods_plot = groupedbar(
        labels,
        mean,
        yerr = std,
        group = legend,
        yticks = (yticks, yticklabels),
        markerstrokecolor = :black,
        markercolor = :black,
        grid = false,
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Infection period duration, days}",
        xlabel = "Вирус",
        ylabel = "Продолжительность, дней",
    )
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
        yticks = (yticks, yticklabels),
        ylim = (0, 7.0),
        grid = false,
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Viral load, log(cp/ml)}",
        xlabel = "Вирус",
        ylabel = "Вирусная нагрузка, log(копий/мл)",
    )
    savefig(viral_loads_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "viral_loads.pdf"))
end

function plot_ig_levels()

    # labels = CategoricalArray(["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"])
    # levels!(labels, ["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"])

    # mean = [1.4, 1.0, 1.9, 4.4, 5.6, 2.6, 3.2]
    # legend = repeat(["0-15"], inner = 7)
    # std = [0.3, 0.22, 0.42, 0.968, 1.229, 0.572, 0.704]

    # incubation_periods_plot = groupedbar(
    #     labels,
    #     mean,
    #     yerr = std,
    #     group = legend,
    #     color=:dodgerblue,
    #     markerstrokecolor = :black,
    #     markercolor = :black,
    #     legend = false,
    #     grid = false,
    #     # xlabel = L"\textrm{\sffamily Virus}",
    #     # ylabel = L"\textrm{\sffamily Incubation period duration, days}",
    #     xlabel = "Вирус",
    #     ylabel = "Продолжительность, дней",
    # )
    # savefig(incubation_periods_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "ig_levels.pdf"))

    ig_g = zeros(Float64, 14)
    ig_a = zeros(Float64, 14)
    ig_m = zeros(Float64, 14)
    
    ig_g_std = zeros(Float64, 14)
    ig_a_std = zeros(Float64, 14)
    ig_m_std = zeros(Float64, 14)

    legend = repeat(["0-89"], inner = 14)

    # ig_g[1] = 953
    # ig_g_std[1] = 262.19

    # ig_a[1] = 6.79
    # ig_a_std[1] = 0.45

    # ig_m[1] = 20.38
    # ig_m_std[1] = 8.87

    ig_g[1], ig_g_std[1] = 953, 262.19
    ig_a[1], ig_a_std[1] = 6.79, 0.45
    ig_m[1], ig_m_std[1] = 20.38, 8.87

    ig_g[2], ig_g_std[2] = 429.5, 145.59
    ig_a[2], ig_a_std[2] = 10.53, 5.16
    ig_m[2], ig_m_std[2] = 36.66, 13.55

    ig_g[3], ig_g_std[3] = 482.43, 236.8
    ig_a[3], ig_a_std[3] = 19.86, 9.77
    ig_m[3], ig_m_std[3] = 75.44, 29.73

    ig_g[4], ig_g_std[4] = 568.97, 186.62
    ig_a[4], ig_a_std[4] = 29.41, 12.37
    ig_m[4], ig_m_std[4] = 81.05, 35.76

    ig_g[5], ig_g_std[5] = 761.7, 238.61
    ig_a[5], ig_a_std[5] = 37.62, 17.1
    ig_m[5], ig_m_std[5] = 122.57, 41.63

    ig_g[6], ig_g_std[6] = 811.5, 249.14
    ig_a[6], ig_a_std[6] = 59.77, 24.52
    ig_m[6], ig_m_std[6] = 111.31, 40.55

    ig_g[7], ig_g_std[7] = 839.87, 164.19
    ig_a[7], ig_a_std[7] = 68.98, 34.05
    ig_m[7], ig_m_std[7] = 121.79, 39.24

    ig_g[8], ig_g_std[8] = 1014.93, 255.53
    ig_a[8], ig_a_std[8] = 106.9, 49.66
    ig_m[8], ig_m_std[8] = 114.73, 41.27

    ig_g[9], ig_g_std[9] = 1055.43, 322.27
    ig_a[9], ig_a_std[9] = 115.99, 47.05
    ig_m[9], ig_m_std[9] = 113.18, 43.68

    ig_g[10], ig_g_std[10] = 1142.07, 203.83
    ig_a[10], ig_a_std[10] = 120.90, 47.51
    ig_m[10], ig_m_std[10] = 125.78, 39.31

    ig_g[11], ig_g_std[11] = 1322.77, 341.89
    ig_a[11], ig_a_std[11] = 201.84, 89.92
    ig_m[11], ig_m_std[11] = 142.54, 64.32

    ig_g[12], ig_g_std[12] = (1250 + 1180) / 2, (214.29 + 193.8) / 2
    ig_a[12], ig_a_std[12] = (226.5 + 233.5) / 2, (65.56 + 63) / 2
    ig_m[12], ig_m_std[12] = (139 + 140.5) / 2, (41.84 + 41) / 2

    ig_g[13], ig_g_std[13] = (1105 + 1155) / 2, (232.1 + 216.84) / 2
    ig_a[13], ig_a_std[13] = (231.5 + 243) / 2, (78.32 + 68.37) / 2
    ig_m[13], ig_m_std[13] = (101 + 102.5) / 2, (36.2 + 35.97) / 2

    ig_g[14], ig_g_std[14] = (1065 + 895) / 2, (242.3 + 165.8) / 2
    ig_a[14], ig_a_std[14] = (277 + 226.5) / 2, (95.92 + 70.15) / 2
    ig_m[14], ig_m_std[14] = (113.5 + 116) / 2, (39 + 39.3) / 2

    ig_levels = ig_g + ig_a + ig_m
    stds = ig_g_std + ig_a_std + ig_m_std
    labels = CategoricalArray(["0м", "1-2м", "3-5м", "6-11м", "1", "2", "3-5", "6-8", "9-11", "12-16", "17-18", "19-60", "61-70", "71+"])
    levels!(labels, ["0м", "1-2м", "3-5м", "6-11м", "1", "2", "3-5", "6-8", "9-11", "12-16", "17-18", "19-60", "61-70", "71+"])

    ig_levels_plot = groupedbar(
        labels,
        ig_levels,
        yerr = stds,
        group = legend,
        # yticks = (yticks, yticklabels),
        markerstrokecolor = :black,
        markercolor = :black,
        # barwidth = 1.5,
        grid = false,
        legend = false,
        # tickfont = (7, :black),
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Infection period duration, days}",
        size = (800, 500),
        xlabel = "Возраст",
        ylabel = "Уровень иммуноглобулина, мг/дл",
    )
    savefig(ig_levels_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "ig_levels.pdf"))
end

function plot_monthly_incidence()
    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    incidence_data = incidence_data[35:45, 2:53]

    println(mean(incidence_data[:, 1]))
    println(std(incidence_data[:, 1]))

    # incidence_plot = histogram(incidence_data[:, 1], bins=:scott, weights=repeat(1:5, outer=2))
    incidence_plot = histogram(
        incidence_data[:, 1],
        bins=6,
        # xlabel = L"\textrm{\sffamily Year}",
        # ylabel = L"\textrm{\sffamily Num of cases per 1000 people}",
        xlabel = "Year",
        ylabel = "Num of cases per 1000 people",
    )

    # # ticks = range(1, stop = 52, length = 13)
    # # ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    # incidence_plot = plot(1:11, [incidence_data[i, 1] for i in 1:11], 
    #     lw = 3, legend = false, color = "red", fontfamily = "Times")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "monthly_incidence.pdf"))
end

# workplace_sizes_distribution()

# plot_ig_levels()

# plot_monthly_incidence()

# plot_temperature()
# plot_incidence()

# plot_incidence_age_groups()

# age_distribution()
age_distribution_groups()
household_size_distribution()

# plot_etiology()
# plot_incubation_periods()
# plot_infection_periods()
# plot_mean_viral_loads()
