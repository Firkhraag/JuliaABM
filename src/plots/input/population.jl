using DelimitedFiles
using Plots
using Statistics
using StatsPlots
using LaTeXStrings
using CategoricalArrays

# default(legendfontsize = 9, guidefont = (14, :black), tickfont = (9, :black))
default(legendfontsize = 11, guidefont = (14, :black), tickfont = (11, :black))

function workplace_sizes_distribution()
    workplaces_num_people1 = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "workplaces_num_people1.csv"), ',', Int, '\n'))
    workplaces_num_people2 = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "workplaces_num_people2.csv"), ',', Int, '\n'))
    workplaces_num_people3 = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "workplaces_num_people3.csv"), ',', Int, '\n'))
    workplaces_num_people4 = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "workplaces_num_people4.csv"), ',', Int, '\n'))

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
    savefig(workplace_size_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "workplace_size_distribution.pdf"))
end

function age_distribution_groups()
    num_people_data_vec = [433175, 420460, 399159, 495506, 869700, 924829, 892794, 831873, 757411,
        818571, 833850, 697220, 640330, 358392, 503280, 281946, 230579, 136843]
    age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "age_groups_nums.csv"), ',', Int, '\n')

    num_people_model_vec = zeros(Int, 18)
    for i = 1:18
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 1, 1]
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 2, 1]
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 3, 1]
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 4, 1]
        num_people_model_vec[i] += age_groups_nums[(i - 1) * 5 + 5, 1]
    end
    # num_people_data = reshape(num_people_model_vec, length(num_people_model_vec), 1)

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

    # xticks = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
    # xticklabels = ["0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85-89"]

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
        # color = reshape(palette(:auto)[1:16], (1,16)),
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        # xlabel = "Age",
        # ylabel = "Num",
        xlabel = "Возраст",
        ylabel = "Число",
        grid = false,
        # xticks = (xticks, xticklabels),
        yticks = (yticks, yticklabels),
    )
    savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "age_distribution_groups.pdf"))

    # num_people_data_vecs = [
    #     [3681, 10862, 136140, 174283, 167371, 181407, 182310, 341499],
    #     [112432, 34063, 201960, 356412, 301265, 381884, 394116, 515879],
    #     [358332, 75387, 336866, 558165, 494945, 541491, 361521, 318805],
    #     [442011, 83579, 295152, 445478, 404316, 399842, 252920, 216230],
    #     [467367, 67980, 249236, 468202, 358952, 322412, 250161, 213446]]
    # for i = 1:5
    #     age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "age_groups_nums_$(i).csv"), ',', Int, '\n')
    #     num_people_data_vec = zeros(Int, 8)
    #     for i = 1:15
    #         num_people_data_vec[1] += age_groups_nums[i]
    #     end
    #     for i = 16:18
    #         num_people_data_vec[2] += age_groups_nums[i]
    #     end
    #     for i = 19:25
    #         num_people_data_vec[3] += age_groups_nums[i]
    #     end
    #     for i = 26:35
    #         num_people_data_vec[4] += age_groups_nums[i]
    #     end
    #     for i = 36:45
    #         num_people_data_vec[5] += age_groups_nums[i]
    #     end
    #     for i = 46:55
    #         num_people_data_vec[6] += age_groups_nums[i]
    #     end
    #     for i = 56:65
    #         num_people_data_vec[7] += age_groups_nums[i]
    #     end
    #     for i = 66:90
    #         num_people_data_vec[8] += age_groups_nums[i]
    #     end
    #     num_people_data = reshape(num_people_data_vec, length(num_people_data_vec), 1)
    
    #     labels = CategoricalArray(string.(collect(0:7)))
    #     levels!(labels, string.(collect(0:7)))
    
    #     xticks = [0, 1, 2, 3, 4, 5, 6, 7]
    #     xticklabels = ["0-14", "15-17", "18-24", "25-34", "35-44", "45-54", "55-64", "65+"]
    
    #     age_distribution_plot = groupedbar(
    #         collect(0:7),
    #         num_people_data,
    #         legend = false,
    #         linewidth = 0.6,
    #         # title = "Age distribution with size of household $(i)",
    #         # xlabel = L"\textrm{\sffamily Virus}",
    #         # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
    #         # xlabel = "Age",
    #         # ylabel = "Num",
    #         xlabel = "Возраст",
    #         ylabel = "Число",
    #         grid = false,
    #         xticks = (xticks, xticklabels),
    #     )
    #     savefig(age_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "age_distribution_model_$(i).pdf"))
    # end
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
        # ylabel = L"\textrm{\sffamily Num}"
        # xlabel = "Age",
        # ylabel = "Num",
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
    # num_households_data = reshape(num_households_data_vec, length(num_households_data_vec), 1)

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
        # group = legend,
        # color=:dodgerblue,
        # title = "Household size distribution",
        yticks = (yticks, yticklabels),
        color = reshape([:coral2, :dodgerblue], (1, 2)),
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}"
        # xlabel = "Size",
        # ylabel = "Num",
        xlabel = "Размер",
        ylabel = "Число",
        grid = false
    )
    savefig(household_size_distribution_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "population", "household_size_distribution.pdf"))
end

age_distribution_groups()
age_distribution()
# household_size_distribution()
