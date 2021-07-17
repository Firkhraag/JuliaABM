using DelimitedFiles
using Plots
using Statistics
using LaTeXStrings

include("../util/burnin.jl")

default(legendfontsize = 18, guidefont = (26, :black), tickfont = (18, :black))

function plot_parameters()
    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    
    susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))

    temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))

    duration_parameter_plot = histogram(duration_parameter_array[burnin:step:length(duration_parameter_array)],
        legend = false, xlabel = L"d", ylabel = L"\textrm{\sffamily Frequency}", bins = 7)

    ticks = range(2.9, stop = 3.5, length = 4)
    ticklabels = ["2.9" "3.1" "3.3" "3.5"]
    susceptibility_parameter_1_plot = histogram(susceptibility_parameter_1_array[burnin:step:length(susceptibility_parameter_1_array)],
        legend = false, xlabel = L"s_1\textrm{\begin{sffamily} (FluA)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7, xticks = (ticks, ticklabels))

    susceptibility_parameter_2_plot = histogram(susceptibility_parameter_2_array[burnin:step:length(susceptibility_parameter_2_array)],
        legend = false, xlabel = L"s_2\textrm{\begin{sffamily} (FluB)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7)
    
    ticks = range(3.2, stop = 3.8, length = 4)
    ticklabels = ["3.2" "3.4" "3.6" "3.8"]
    susceptibility_parameter_3_plot = histogram(susceptibility_parameter_3_array[burnin:step:length(susceptibility_parameter_3_array)],
        legend = false, xlabel = L"s_3\textrm{\begin{sffamily} (RV)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7, xticks = (ticks, ticklabels))
    
    ticks = range(4.8, stop = 6.0, length = 4)
    ticklabels = ["4.8" "5.2" "5.6" "6.0"]
    susceptibility_parameter_4_plot = histogram(susceptibility_parameter_4_array[burnin:step:length(susceptibility_parameter_4_array)],
        legend = false, xlabel = L"s_4\textrm{\begin{sffamily} (RSV)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7, xticks = (ticks, ticklabels))
    
    susceptibility_parameter_5_plot = histogram(susceptibility_parameter_5_array[burnin:step:length(susceptibility_parameter_5_array)],
        legend = false, xlabel = L"s_5\textrm{\begin{sffamily} (AdV)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7)
    susceptibility_parameter_6_plot = histogram(susceptibility_parameter_6_array[burnin:step:length(susceptibility_parameter_6_array)],
        legend = false, xlabel = L"s_6\textrm{\begin{sffamily} (PIV)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7)
    susceptibility_parameter_7_plot = histogram(susceptibility_parameter_7_array[burnin:step:length(susceptibility_parameter_7_array)],
        legend = false, xlabel = L"s_7\textrm{\begin{sffamily} (CoV)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7)

    temperature_parameter_1_plot = histogram(temperature_parameter_1_array[burnin:step:length(temperature_parameter_1_array)],
        legend = false, xlabel = L"t_1\textrm{\begin{sffamily} (FluA)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7)
    temperature_parameter_2_plot = histogram(temperature_parameter_2_array[burnin:step:length(temperature_parameter_2_array)],
        legend = false, xlabel = L"t_2\textrm{\begin{sffamily} (FluB)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7)
    temperature_parameter_3_plot = histogram(temperature_parameter_3_array[burnin:step:length(temperature_parameter_3_array)],
        legend = false, xlabel = L"t_3\textrm{\begin{sffamily} (RV)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7)
    temperature_parameter_4_plot = histogram(temperature_parameter_4_array[burnin:step:length(temperature_parameter_4_array)],
        legend = false, xlabel = L"t_4\textrm{\begin{sffamily} (RSV)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7)
    temperature_parameter_5_plot = histogram(temperature_parameter_5_array[burnin:step:length(temperature_parameter_5_array)],
        legend = false, xlabel = L"t_5\textrm{\begin{sffamily} (AdV)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7)
    
    ticks = range(0.0, stop = 0.1, length = 6)
    ticklabels = ["0.0" "0.02" "0.04" "0.06" "0.08" "0.1"]
    temperature_parameter_6_plot = histogram(temperature_parameter_6_array[burnin:step:length(temperature_parameter_6_array)],
        legend = false, xlabel = L"t_6\textrm{\begin{sffamily} (PIV)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7, xticks = (ticks, ticklabels))

    temperature_parameter_7_plot = histogram(temperature_parameter_7_array[burnin:step:length(temperature_parameter_7_array)],
        legend = false, xlabel = L"t_7\textrm{\begin{sffamily} (CoV)\end{sffamily}}", ylabel = L"\textrm{\sffamily Frequency}", bins = 7)

    savefig(duration_parameter_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "duration_parameter_plot.pdf"))

    savefig(susceptibility_parameter_1_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "susceptibility_parameter_1_plot.pdf"))
    savefig(susceptibility_parameter_2_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "susceptibility_parameter_2_plot.pdf"))
    savefig(susceptibility_parameter_3_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "susceptibility_parameter_3_plot.pdf"))
    savefig(susceptibility_parameter_4_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "susceptibility_parameter_4_plot.pdf"))
    savefig(susceptibility_parameter_5_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "susceptibility_parameter_5_plot.pdf"))
    savefig(susceptibility_parameter_6_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "susceptibility_parameter_6_plot.pdf"))
    savefig(susceptibility_parameter_7_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "susceptibility_parameter_7_plot.pdf"))

    savefig(temperature_parameter_1_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "temperature_parameter_1_plot.pdf"))
    savefig(temperature_parameter_2_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "temperature_parameter_2_plot.pdf"))
    savefig(temperature_parameter_3_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "temperature_parameter_3_plot.pdf"))
    savefig(temperature_parameter_4_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "temperature_parameter_4_plot.pdf"))
    savefig(temperature_parameter_5_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "temperature_parameter_5_plot.pdf"))
    savefig(temperature_parameter_6_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "temperature_parameter_6_plot.pdf"))
    savefig(temperature_parameter_7_plot, joinpath(@__DIR__, "..", "..", "mcmc", "plots", "temperature_parameter_7_plot.pdf"))
end

function print_parameters()
    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    
    susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))

    temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "mcmc", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))

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

    std1 = mean(duration_parameter_array)

    std2 = mean(susceptibility_parameter_1_array)
    std3 = mean(susceptibility_parameter_2_array)
    std4 = mean(susceptibility_parameter_3_array)
    std5 = mean(susceptibility_parameter_4_array)
    std6 = mean(susceptibility_parameter_5_array)
    std7 = mean(susceptibility_parameter_6_array)
    std8 = mean(susceptibility_parameter_7_array)

    std9 = mean(temperature_parameter_1_array)
    std10 = mean(temperature_parameter_2_array)
    std11 = mean(temperature_parameter_3_array)
    std12 = mean(temperature_parameter_4_array)
    std13 = mean(temperature_parameter_5_array)
    std14 = mean(temperature_parameter_6_array)
    std15 = mean(temperature_parameter_7_array)

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
    println("t6: ", round(m14, digits=3), " (", round(max(0.0, m14 - z * std14 / denominator), digits=3), "--", round(min(1.0, m14 + z * std14 / denominator), digits=3), ")")
    println("t7: ", round(m15, digits = 2), " (", round(max(0.0, m15 - z * std15 / denominator), digits = 2), "--", round(min(1.0, m15 + z * std15 / denominator), digits = 2), ")")
end

plot_parameters()
print_parameters()
