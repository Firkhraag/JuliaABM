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

const is_russian = false
# const is_russian = true

function plot_performance()
    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    duration_parameter = mean(duration_parameter_array[burnin:step:length(duration_parameter_array)])

    # nMAE_values = [1.66, 0.7424240360316214, 0.7202259373358402, 0.6932226020101293, 0.6784047573049448, 0.658307, 0.658307]
    # nMAE_values = [1.66, 0.5424788116516213, 0.5349980458940209, 0.5244722462925852, 0.5189713551481547, 0.5128575932033336, 0.5127395196087101]
    # nMAE_values = [1.664, 0.8410544834403171, 0.823885251834751, 0.8146061205058156, 0.7986840934264225, 0.7824185561594837, 0.7730585349602732, 0.7509996133659516, 0.7451433444820232, 0.7341423618562801, 0.71904399775838, 0.707596092273951, 0.6879681825321108, 0.6772816784161535, 0.6580029533876143, 0.6541755475006543, 0.633537776860235, 0.6196216923338315, 0.6041495353712981, 0.5960590819908353, 0.5861204949052768, 0.5853526858707159, 0.5820711812026059, 0.57953032549554, 0.5773861052965671, 0.5750731176762239, 0.5742814376300275]
    
    # nMAE_values = [1.664, 0.844341073010478, 0.6891394882784254, 0.6124775009090876, 0.5964802510558316, 0.5819206614642499, 0.5675548810778043, 0.5675548810778043]
    nMAE_values_1 = [0.8410544834403171, 0.823885251834751, 0.8146061205058156, 0.7986840934264225, 0.7824185561594837, 0.7730585349602732, 0.7509996133659516, 0.7451433444820232, 0.7341423618562801, 0.71904399775838, 0.707596092273951, 0.6879681825321108, 0.6772816784161535, 0.6580029533876143, 0.6541755475006543, 0.633537776860235, 0.6196216923338315, 0.6041495353712981, 0.5960590819908353, 0.5861204949052768, 0.5853526858707159, 0.5820711812026059, 0.57953032549554, 0.5773861052965671, 0.5750731176762239, 0.5742814376300275]
    nMAE_values_2 = [0.844341073010478, 0.6891394882784254, 0.6124775009090876, 0.5964802510558316, 0.5819206614642499, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043, 0.5675548810778043]

    nMAE_values_1 = [0.8410544834403171, 0.823885251834751, 0.8146061205058156, 0.7986840934264225, 0.7824185561594837, 0.7730585349602732, 0.7509996133659516, 0.7451433444820232, 0.7341423618562801, 0.71904399775838, 0.707596092273951, 0.6879681825321108, 0.6772816784161535, 0.6580029533876143, 0.6541755475006543, 0.633537776860235, 0.6196216923338315, 0.6041495353712981, 0.5960590819908353, 0.5861204949052768, 0.5853526858707159, 0.5820711812026059, 0.57953032549554, 0.5773861052965671, 0.5750731176762239, 0.5732814376300275, 0.5722814376300275]
    nMAE_values_2 = [0.844341073010478, 0.6891394882784254, 0.6124775009090876, 0.5964802510558316, 0.5819206614642499, 0.5675548810778043]

    # println(length(nMAE_values_1))
    # println(length(nMAE_values_2))
    # return

    # 0.844341073010478
    # 0.6891394882784254
    # 0.6124775009090876
    # 0.5964802510558316
    # 0.5819206614642499
    # 0.5675548810778043


    ticks = vec(1:length(nMAE_values_1))
    ticklabels = ["1", "", "3", "", "5", "", "7", "", "9", "", "11", "", "13", "", "15", "", "17", "", "19", "", "21", "", "23", "", "25", "", "27"]
    # ticklabels = ["$(i)" for i = 1:length(nMAE_values_1)]
    # ticks = vec(1:length(nMAE_values))
    # ticklabels = ["$(-2 + i)" for i = 1:length(nMAE_values)]
    # ticklabels = ["-1", "", "1", "", "3", "", "5", "", "7", "", "9", "", "11", "", "13", "", "15", "", "17", "", "19", "", "21", "", "23", "", "25"]
    # ticklabels = ["-1", "", "1", "", "3", "", "5", ""]

    xlabel_name = "Шаг"
    if !is_russian
        xlabel_name = "Step"
    end
    ylabel_name = L"nMAE"

    duration_plot = plot(
        # 1:length(nMAE_values),
        # nMAE_values,
        # 1:length(nMAE_values_1),
        [nMAE_values_1, nMAE_values_2],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = ["old" "new"],
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        grid = false,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        margin = 6Plots.mm,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(duration_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "performance.pdf"))
end

function plot_mcmc_performance()
    metropolis_output_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_metropolis.csv"), ',', Float64, '\n'))

    mean1 = mean(metropolis_output_array[1:100])
    mean2 = mean(metropolis_output_array[101:200])
    mean3 = mean(metropolis_output_array[201:300])
    mean4 = mean(metropolis_output_array[301:400])

    ticks = vec(1:4)
    ticklabels = ["1", "2", "3", "4"]
    # ticklabels = ["$(i)" for i = 1:length(nMAE_values_1)]
    # ticks = vec(1:length(nMAE_values))
    # ticklabels = ["$(-2 + i)" for i = 1:length(nMAE_values)]
    # ticklabels = ["-1", "", "1", "", "3", "", "5", "", "7", "", "9", "", "11", "", "13", "", "15", "", "17", "", "19", "", "21", "", "23", "", "25"]
    # ticklabels = ["-1", "", "1", "", "3", "", "5", ""]

    xlabel_name = "Шаг"
    if !is_russian
        xlabel_name = "Step"
    end
    ylabel_name = L"nMAE"

    duration_plot = plot(
        [mean1, mean2, mean3, mean4],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        grid = false,
        legend = false,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        margin = 6Plots.mm,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(duration_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "performance_mcmc.pdf"))
end

# plot_performance()
plot_mcmc_performance()
