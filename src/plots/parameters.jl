using DelimitedFiles
using Plots
using Statistics
using LaTeXStrings

include("../util/burnin.jl")

default(legendfontsize = 19, guidefont = (28, :black), tickfont = (19, :black))

function plot_parameters()
    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    
    susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))

    temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))

    duration_parameter_plot = histogram(
        duration_parameter_array[burnin:step:length(duration_parameter_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7,
        # xlabel = L"d",
        # ylabel = L"\textrm{\sffamily Frequency}",
        xlabel = "d",
        ylabel = "Frequency",
    )

    # ticks = range(2.9, stop = 3.5, length = 4)
    # ticklabels = ["2.9" "3.1" "3.3" "3.5"]
    # susceptibility_parameter_1_plot = histogram(susceptibility_parameter_1_array[burnin:step:length(susceptibility_parameter_1_array)], margin = 3Plots.mm,
    #     legend = false, xlabel = L"s_1\textrm{\begin{sffamily} (FluA)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7, xticks = (ticks, ticklabels))

    susceptibility_parameter_1_plot = histogram(
        susceptibility_parameter_1_array[burnin:step:length(susceptibility_parameter_1_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7,
        # xlabel = L"s_1\textrm{\begin{sffamily} (FluA)\end{sffamily}}",
        # ylabel = L"\textrm{\sffamily Frequency}",
        xlabel = "s_1 (FluA)",
        ylabel = "Frequency",
    )


    susceptibility_parameter_2_plot = histogram(
        susceptibility_parameter_2_array[burnin:step:length(susceptibility_parameter_2_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7,
        # xlabel = L"s_2\textrm{\begin{sffamily} (FluB)\end{sffamily}}",
        # ylabel = L"\textrm{\sffamily Frequency}",
        xlabel = "s_2 (FluB)",
        ylabel = "Frequency",
    )
    
    ticks = range(5.1, stop = 5.7, length = 4)
    ticklabels = ["5.1" "5.3" "5.5" "5.7"]
    susceptibility_parameter_3_plot = histogram(
        susceptibility_parameter_3_array[burnin:step:length(susceptibility_parameter_3_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7,
        xticks = (ticks, ticklabels),
        xlabel = "s_3 (RV)",
        ylabel = "Frequency",
    )

    ticks = range(6.4, stop = 7.3, length = 4)
    ticklabels = ["6.4" "6.7" "7.0" "7.3"]
    susceptibility_parameter_4_plot = histogram(
        susceptibility_parameter_4_array[burnin:step:length(susceptibility_parameter_4_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7,
        xticks = (ticks, ticklabels),
        # xlabel = "s_4\textrm{\begin{sffamily} (RSV)\end{sffamily}}",
        # ylabel = "\textrm{\sffamily Frequency}",
        xlabel = "s_4 (RSV)",
        ylabel = "Frequency",
    )

    ticks = range(6.4, stop = 7.4, length = 6)
    ticklabels = ["6.4" "6.6" "6.8" "7.0" "7.2" "7.4"]
    susceptibility_parameter_5_plot = histogram(
        susceptibility_parameter_5_array[burnin:step:length(susceptibility_parameter_5_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7,
        xticks = (ticks, ticklabels),
        # xlabel = L"s_5\textrm{\begin{sffamily} (AdV)\end{sffamily}}",
        # ylabel = L"\textrm{\sffamily Frequency}",
        xlabel = "s_5 (AdV)",
        ylabel = "Frequency",
    )
    
    ticks = range(5.6, stop = 6.6, length = 6)
    ticklabels = ["5.6" "5.8" "6.0" "6.2" "6.4" "6.6"]
    susceptibility_parameter_6_plot = histogram(
        susceptibility_parameter_6_array[burnin:step:length(susceptibility_parameter_6_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7, xticks = (ticks, ticklabels),
        # xlabel = L"s_6\textrm{\begin{sffamily} (PIV)\end{sffamily}}",
        # ylabel = L"\textrm{\sffamily Frequency}",
        xlabel = "s_6 (PIV)",
        ylabel = "Frequency",
    )

    ticks = range(5.6, stop = 6.6, length = 6)
    ticklabels = ["5.6" "5.8" "6.0" "6.2" "6.4" "6.6"]
    susceptibility_parameter_7_plot = histogram(
        susceptibility_parameter_7_array[burnin:step:length(susceptibility_parameter_7_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7,
        xticks = (ticks, ticklabels),
        # xlabel = L"s_7\textrm{\begin{sffamily} (CoV)\end{sffamily}}",
        # ylabel = L"\textrm{\sffamily Frequency}",
        xlabel = "s_7 (CoV)",
        ylabel = "Frequency",
    )

    ticks = range(0.94, stop = 1.0, length = 4)
    ticklabels = ["0.94" "0.96" "0.98" "1.0"]
    temperature_parameter_1_plot = histogram(
        temperature_parameter_1_array[burnin:step:length(temperature_parameter_1_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7,
        xticks = (ticks, ticklabels),
        # xlabel = L"t_1\textrm{\begin{sffamily} (FluA)\end{sffamily}}",
        # ylabel = L"\textrm{\sffamily Frequency}",
        xlabel = "t_1 (FluA)",
        ylabel = "Frequency",
    )

    temperature_parameter_2_plot = histogram(
        temperature_parameter_2_array[burnin:step:length(temperature_parameter_2_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7,
        # xlabel = L"t_2\textrm{\begin{sffamily} (FluB)\end{sffamily}}",
        # ylabel = L"\textrm{\sffamily Frequency}",
        xlabel = "t_2 (FluB)",
        ylabel = "Frequency",
    )

    temperature_parameter_3_plot = histogram(
        temperature_parameter_3_array[burnin:step:length(temperature_parameter_3_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7,
        # xlabel = L"t_3\textrm{\begin{sffamily} (RV)\end{sffamily}}",
        # ylabel = L"\textrm{\sffamily Frequency}",
        xlabel = "t_3 (RV)",
        ylabel = "Frequency",
    )
    
    ticks = range(0.2, stop = 0.45, length = 6)
    ticklabels = ["0.2" "0.25" "0.3" "0.35" "0.4" "0.45"]
    temperature_parameter_4_plot = histogram(
        temperature_parameter_4_array[burnin:step:length(temperature_parameter_4_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7,
        xticks = (ticks, ticklabels),
        # xlabel = L"t_4\textrm{\begin{sffamily} (RSV)\end{sffamily}}",
        # ylabel = L"\textrm{\sffamily Frequency}",
        xlabel = "t_4 (RSV)",
        ylabel = "Frequency",
    )
    
    ticks = range(0.0, stop = 0.16, length = 5)
    ticklabels = ["0.0" "0.04" "0.08" "0.12" "0.16"]
    temperature_parameter_5_plot = histogram(
        temperature_parameter_5_array[burnin:step:length(temperature_parameter_5_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7,
        xticks = (ticks, ticklabels),
        # xlabel = L"t_5\textrm{\begin{sffamily} (AdV)\end{sffamily}}",
        # ylabel = L"\textrm{\sffamily Frequency}",
        xlabel = "t_5 (AdV)",
        ylabel = "Frequency",
    )
    
    ticks = range(0.0, stop = 0.12, length = 4)
    ticklabels = ["0.0" "0.04" "0.08" "0.12"]
    temperature_parameter_6_plot = histogram(
        temperature_parameter_6_array[burnin:step:length(temperature_parameter_6_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7, xticks = (ticks, ticklabels),
        # xlabel = L"t_6\textrm{\begin{sffamily} (PIV)\end{sffamily}}",
        # ylabel = L"\textrm{\sffamily Frequency}", bins = 7, xticks = (ticks, ticklabels),
        xlabel = "t_6 (PIV)",
        ylabel = "Frequency",
    )

    temperature_parameter_7_plot = histogram(
        temperature_parameter_7_array[burnin:step:length(temperature_parameter_7_array)],
        margin = 3Plots.mm,
        legend = false,
        bins = 7,
        # xlabel = L"t_7\textrm{\begin{sffamily} (CoV)\end{sffamily}}",
        # ylabel = L"\textrm{\sffamily Frequency}",
        xlabel = "t_7 (CoV)",
        ylabel = "Frequency",
    )

    savefig(duration_parameter_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "duration_parameter_plot.pdf"))

    savefig(susceptibility_parameter_1_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "susceptibility_parameter_1_plot.pdf"))
    savefig(susceptibility_parameter_2_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "susceptibility_parameter_2_plot.pdf"))
    savefig(susceptibility_parameter_3_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "susceptibility_parameter_3_plot.pdf"))
    savefig(susceptibility_parameter_4_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "susceptibility_parameter_4_plot.pdf"))
    savefig(susceptibility_parameter_5_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "susceptibility_parameter_5_plot.pdf"))
    savefig(susceptibility_parameter_6_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "susceptibility_parameter_6_plot.pdf"))
    savefig(susceptibility_parameter_7_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "susceptibility_parameter_7_plot.pdf"))

    savefig(temperature_parameter_1_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "temperature_parameter_1_plot.pdf"))
    savefig(temperature_parameter_2_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "temperature_parameter_2_plot.pdf"))
    savefig(temperature_parameter_3_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "temperature_parameter_3_plot.pdf"))
    savefig(temperature_parameter_4_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "temperature_parameter_4_plot.pdf"))
    savefig(temperature_parameter_5_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "temperature_parameter_5_plot.pdf"))
    savefig(temperature_parameter_6_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "temperature_parameter_6_plot.pdf"))
    savefig(temperature_parameter_7_plot, joinpath(@__DIR__, "..", "..", "parameters", "plots", "temperature_parameter_7_plot.pdf"))
end

function print_parameters()
    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    
    susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))

    temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "parameters", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))

    duration_parameter_array = duration_parameter_array[burnin:step:length(duration_parameter_array)]
    
    susceptibility_parameter_1_array = susceptibility_parameter_1_array[burnin:step:length(susceptibility_parameter_1_array)]
    susceptibility_parameter_2_array = susceptibility_parameter_2_array[burnin:step:length(susceptibility_parameter_2_array)]
    susceptibility_parameter_3_array = susceptibility_parameter_3_array[burnin:step:length(susceptibility_parameter_3_array)]
    susceptibility_parameter_4_array = susceptibility_parameter_4_array[burnin:step:length(susceptibility_parameter_4_array)]
    susceptibility_parameter_5_array = susceptibility_parameter_5_array[burnin:step:length(susceptibility_parameter_5_array)]
    susceptibility_parameter_6_array = susceptibility_parameter_6_array[burnin:step:length(susceptibility_parameter_6_array)]
    susceptibility_parameter_7_array = susceptibility_parameter_7_array[burnin:step:length(susceptibility_parameter_7_array)]

    temperature_parameter_1_array = temperature_parameter_1_array[burnin:step:length(temperature_parameter_1_array)]
    temperature_parameter_2_array = temperature_parameter_2_array[burnin:step:length(temperature_parameter_2_array)]
    temperature_parameter_3_array = temperature_parameter_3_array[burnin:step:length(temperature_parameter_3_array)]
    temperature_parameter_4_array = temperature_parameter_4_array[burnin:step:length(temperature_parameter_4_array)]
    temperature_parameter_5_array = temperature_parameter_5_array[burnin:step:length(temperature_parameter_5_array)]
    temperature_parameter_6_array = temperature_parameter_6_array[burnin:step:length(temperature_parameter_6_array)]
    temperature_parameter_7_array = temperature_parameter_7_array[burnin:step:length(temperature_parameter_7_array)]

    m1 = mean(duration_parameter_array)

    m2 = mean(susceptibility_parameter_1_array)
    m3 = mean(susceptibility_parameter_2_array)
    m4 = mean(susceptibility_parameter_3_array)
    m5 = mean(susceptibility_parameter_4_array)
    m6 = mean(susceptibility_parameter_5_array)
    m7 = mean(susceptibility_parameter_6_array)
    m8 = mean(susceptibility_parameter_7_array)

    m9 = mean(temperature_parameter_1_array)
    m10 = mean(temperature_parameter_2_array)
    m11 = mean(temperature_parameter_3_array)
    m12 = mean(temperature_parameter_4_array)
    m13 = mean(temperature_parameter_5_array)
    m14 = mean(temperature_parameter_6_array)
    m15 = mean(temperature_parameter_7_array)

    std1 = std(duration_parameter_array)

    std2 = std(susceptibility_parameter_1_array)
    std3 = std(susceptibility_parameter_2_array)
    std4 = std(susceptibility_parameter_3_array)
    std5 = std(susceptibility_parameter_4_array)
    std6 = std(susceptibility_parameter_5_array)
    std7 = std(susceptibility_parameter_6_array)
    std8 = std(susceptibility_parameter_7_array)

    std9 = std(temperature_parameter_1_array)
    std10 = std(temperature_parameter_2_array)
    std11 = std(temperature_parameter_3_array)
    std12 = std(temperature_parameter_4_array)
    std13 = std(temperature_parameter_5_array)
    std14 = std(temperature_parameter_6_array)
    std15 = std(temperature_parameter_7_array)

    denominator = sqrt(length(duration_parameter_array))
    z = 1.96

    println("d: ", round(m1, digits = 2), " (", round(m1 - z * std1 / denominator, digits = 2), "--", round(m1 + z * std1 / denominator, digits = 2), ")")

    println("s1: ", round(m2, digits = 2), " (", round(m2 - z * std2 / denominator, digits = 2), "--", round(m2 + z * std2 / denominator, digits = 2), ")")
    println("s2: ", round(m3, digits = 2), " (", round(m3 - z * std3 / denominator, digits = 2), "--", round(m3 + z * std3 / denominator, digits = 2), ")")
    println("s3: ", round(m4, digits = 2), " (", round(m4 - z * std4 / denominator, digits = 2), "--", round(m4 + z * std4 / denominator, digits = 2), ")")
    println("s4: ", round(m5, digits = 2), " (", round(m5 - z * std5 / denominator, digits = 2), "--", round(m5 + z * std5 / denominator, digits = 2), ")")
    println("s5: ", round(m6, digits = 2), " (", round(m6 - z * std6 / denominator, digits = 2), "--", round(m6 + z * std6 / denominator, digits = 2), ")")
    println("s6: ", round(m7, digits = 2), " (", round(m7 - z * std7 / denominator, digits = 2), "--", round(m7 + z * std7 / denominator, digits = 2), ")")
    println("s7: ", round(m8, digits = 2), " (", round(m8 - z * std8 / denominator, digits = 2), "--", round(m8 + z * std8 / denominator, digits = 2), ")")

    println("t1: ", round(m9, digits = 2), " (", round(max(0.0, m9 - z * std9 / denominator), digits = 2), "--", round(min(1.0, m9 + z * std9 / denominator), digits = 2), ")")
    println("t2: ", round(m10, digits = 2), " (", round(max(0.0, m10 - z * std10 / denominator), digits = 2), "--", round(min(1.0, m10 + z * std10 / denominator), digits = 2), ")")
    println("t3: ", round(m11, digits = 2), " (", round(max(0.0, m11 - z * std11 / denominator), digits = 2), "--", round(min(1.0, m11 + z * std11 / denominator), digits = 2), ")")
    println("t4: ", round(m12, digits = 2), " (", round(max(0.0, m12 - z * std12 / denominator), digits = 2), "--", round(min(1.0, m12 + z * std12 / denominator), digits = 2), ")")
    println("t5: ", round(m13, digits = 2), " (", round(max(0.0, m13 - z * std13 / denominator), digits = 2), "--", round(min(1.0, m13 + z * std13 / denominator), digits = 2), ")")
    println("t6: ", round(m14, digits=3), " (", round(max(0.0, m14 - z * std14 / denominator), digits = 2), "--", round(min(1.0, m14 + z * std14 / denominator), digits = 2), ")")
    println("t7: ", round(m15, digits = 2), " (", round(max(0.0, m15 - z * std15 / denominator), digits = 2), "--", round(min(1.0, m15 + z * std15 / denominator), digits = 2), ")")
end

plot_parameters()
print_parameters()
