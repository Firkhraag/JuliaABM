using DelimitedFiles
using Plots
using Statistics
using LaTeXStrings
using Random

include("../../data/temperature.jl")
include("../../model/virus.jl")
include("../../model/agent.jl")
include("../../global/variables.jl")

default(legendfontsize = 9, guidefont = (12, :black), tickfont = (11, :black))

# const is_russian = false
const is_russian = true

function plot_performance()
    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    duration_parameter = mean(duration_parameter_array[burnin:step:length(duration_parameter_array)])
    # duration_parameter = 3.3695943816524907

    # v = [0.7424240360316214, 0.7202259373358402, 0.6932226020101293, 0.6784047573049448, 0.658307, 0.658307]
    v = [0.5424788116516213, 0.5349980458940209, 0.5244722462925852, 0.5189713551481547, 0.5128575932033336, 0.5127395196087101]

    ticks = [1, 2, 3, 4, 5, 6]
    ticklabels = ["1", "100 LHS", "200 LHS", "300 LHS", "400 LHS", "500 LHS"]

    xlabel_name = "Шаг"
    if !is_russian
        xlabel_name = "Step"
    end
    ylabel_name = L"nMAE"

    duration_plot = plot(
        1:6,
        v,
        lw = 1.5,
        xticks = (ticks, ticklabels),
        legend = false,
        color = :black,
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        margin = 6Plots.mm,
        # xlabel = L"\textrm{\sffamily Hours}",
        # ylabel = L"\textrm{\sffamily Contact duration influence (} D_{ijc}\textrm{\sffamily )}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(duration_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "performance.pdf"))
end

plot_performance()
