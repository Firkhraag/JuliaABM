using DelimitedFiles
using Plots
using Statistics
using StatsPlots
using LaTeXStrings
using CategoricalArrays

default(legendfontsize = 9, guidefont = (12, :black), tickfont = (11, :black))

# const is_russian = false
const is_russian = true

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
        # color = RGB(0.5, 0.5, 0.5),
        color = RGB(0.267, 0.467, 0.667),
        markerstrokecolor = :black,
        markercolor = :black,
        legend = false,
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Incubation period duration, days}",
        xlabel = "Вирус",
        ylabel = "Продолжительность, дней",
    )
    savefig(incubation_periods_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "agent_virus", "incubation_periods.pdf"))
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
        legend = (0.9, 0.98),
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        # color = [RGB(0.33, 0.33, 0.33) RGB(0.66, 0.66, 0.66)],
        markerstrokecolor = :black,
        markercolor = :black,
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Infection period duration, days}",
        xlabel = "Вирус",
        ylabel = "Продолжительность, дней",
    )
    savefig(infection_periods_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "agent_virus", "infection_periods.pdf"))
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
        legend = (0.9, 0.98),
        # color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467) RGB(0.133, 0.533, 0.2)],
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467) RGB(0.5, 0.5, 0.5)],
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Viral load, log(cp/ml)}",
        xlabel = "Вирус",
        ylabel = "Вирусная нагрузка, log(копий/мл)",
    )
    savefig(viral_loads_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "agent_virus", "viral_loads.pdf"))
end

function plot_ig_levels()
    ig_g = zeros(Float64, 14)
    ig_a = zeros(Float64, 14)
    ig_m = zeros(Float64, 14)
    
    ig_g_std = zeros(Float64, 14)
    ig_a_std = zeros(Float64, 14)
    ig_m_std = zeros(Float64, 14)

    legend = repeat(["0-89"], inner = 14)

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
        markerstrokecolor = :black,
        markercolor = :black,
        grid = true,
        color = RGB(0.267, 0.467, 0.667),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        margin = 5Plots.mm,
        legend = false,
        # xlabel = L"\textrm{\sffamily Virus}",
        # ylabel = L"\textrm{\sffamily Infection period duration, days}",
        size = (800, 500),
        xrotation = 45,
        xlabel = "Возраст",
        ylabel = "Уровень иммуноглобулинов, мг/дл",
    )
    savefig(ig_levels_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "agent_virus", "ig_levels.pdf"))
end

# plot_incubation_periods()
# plot_infection_periods()
# plot_mean_viral_loads()
plot_ig_levels()
