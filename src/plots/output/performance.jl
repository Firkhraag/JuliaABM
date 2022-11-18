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
    v = [0.7424240360316214, 0.7202259373358402, 0.6932226020101293, 0.6784047573049448, 0.6738306633624289, 0.658307, 0.658307]

    ticks = [1, 2, 3, 4, 5, 6, 7]
    ticklabels = ["1", "100 LHS", "SM", "100 LHS", "SM", "100 LHS", "SM"]

    xlabel_name = "Шаг"
    if !is_russian
        xlabel_name = "Step"
    end
    ylabel_name = L"nMAE"

    duration_plot = plot(
        1:7,
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
