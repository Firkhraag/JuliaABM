using DelimitedFiles
using Plots
using DataFrames
using Statistics
using Distributions
using LaTeXStrings
using JLD
using CSV
using Random

include("../../../server/lib/util/moving_avg.jl")
include("../../../server/lib/util/regression.jl")
include("../../../server/lib/data/etiology.jl")
include("../../../server/lib/data/incidence.jl")
include("../../../server/lib/global/variables.jl")

default(legendfontsize = 11, guidefont = (12, :black), tickfont = (11, :black))

const is_russian = false
const num_years = 1

function plot_mcmc_hypercube()
    duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "duration_parameter_array.csv"), ';', Float64, '\n')
    num_mcmc_runs = length(duration_parameter_array)
    nMAE_array = zeros(Float64, num_mcmc_runs)

    susceptibility_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "susceptibility_parameter_1_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "susceptibility_parameter_2_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "susceptibility_parameter_3_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "susceptibility_parameter_4_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "susceptibility_parameter_5_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "susceptibility_parameter_6_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "susceptibility_parameter_7_array.csv"), ';', Float64, '\n')

    temperature_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "temperature_parameter_1_array.csv"), ';', Float64, '\n')
    temperature_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "temperature_parameter_2_array.csv"), ';', Float64, '\n')
    temperature_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "temperature_parameter_3_array.csv"), ';', Float64, '\n')
    temperature_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "temperature_parameter_4_array.csv"), ';', Float64, '\n')
    temperature_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "temperature_parameter_5_array.csv"), ';', Float64, '\n')
    temperature_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "temperature_parameter_6_array.csv"), ';', Float64, '\n')
    temperature_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "temperature_parameter_7_array.csv"), ';', Float64, '\n')

    mean_immunity_duration_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "mean_immunity_duration_1_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "mean_immunity_duration_2_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "mean_immunity_duration_3_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "mean_immunity_duration_4_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "mean_immunity_duration_5_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "mean_immunity_duration_6_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "mean_immunity_duration_7_array.csv"), ';', Float64, '\n')

    random_infection_probability_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "random_infection_probability_1_array.csv"), ';', Float64, '\n')
    random_infection_probability_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "random_infection_probability_2_array.csv"), ';', Float64, '\n')
    random_infection_probability_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "random_infection_probability_3_array.csv"), ';', Float64, '\n')
    random_infection_probability_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "random_infection_probability_4_array.csv"), ';', Float64, '\n')

    open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_mcmc_hypercube.txt"),"r") do datafile
        lines = eachline(datafile)
        line_num = 1
        for line in lines
            if line_num == 1 || abs(duration_parameter_array[line_num] - duration_parameter_array[line_num - 1]) > 0.0001
                nMAE_array[line_num] = parse.(Float64, line)
            else
                nMAE_array[line_num] = nMAE_array[line_num - 1]
            end
            # nMAE_array[line_num] = parse.(Float64, line)
            line_num += 1
        end
    end

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    nMAE_plot = plot(
        1:num_mcmc_runs,
        moving_average(nMAE_array, 10),
        # nMAE_array,
        lw = 1.5,
        grid = true,
        legend = false,
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(nMAE_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_mcmc_hypercube.pdf"))

    println("plot_mcmc_hypercube")
    println(nMAE_array)
    println()
end

function plot_mcmc_manual()
    duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "duration_parameter_array.csv"), ';', Float64, '\n')
    num_mcmc_runs = length(duration_parameter_array)
    nMAE_array = zeros(Float64, num_mcmc_runs)

    susceptibility_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "susceptibility_parameter_1_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "susceptibility_parameter_2_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "susceptibility_parameter_3_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "susceptibility_parameter_4_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "susceptibility_parameter_5_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "susceptibility_parameter_6_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "susceptibility_parameter_7_array.csv"), ';', Float64, '\n')

    temperature_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "temperature_parameter_1_array.csv"), ';', Float64, '\n')
    temperature_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "temperature_parameter_2_array.csv"), ';', Float64, '\n')
    temperature_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "temperature_parameter_3_array.csv"), ';', Float64, '\n')
    temperature_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "temperature_parameter_4_array.csv"), ';', Float64, '\n')
    temperature_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "temperature_parameter_5_array.csv"), ';', Float64, '\n')
    temperature_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "temperature_parameter_6_array.csv"), ';', Float64, '\n')
    temperature_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "temperature_parameter_7_array.csv"), ';', Float64, '\n')

    mean_immunity_duration_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "mean_immunity_duration_1_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "mean_immunity_duration_2_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "mean_immunity_duration_3_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "mean_immunity_duration_4_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "mean_immunity_duration_5_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "mean_immunity_duration_6_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "mean_immunity_duration_7_array.csv"), ';', Float64, '\n')

    random_infection_probability_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "random_infection_probability_1_array.csv"), ';', Float64, '\n')
    random_infection_probability_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "random_infection_probability_2_array.csv"), ';', Float64, '\n')
    random_infection_probability_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "random_infection_probability_3_array.csv"), ';', Float64, '\n')
    random_infection_probability_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "random_infection_probability_4_array.csv"), ';', Float64, '\n')

    open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_mcmc_manual.txt"),"r") do datafile
        lines = eachline(datafile)
        line_num = 1
        for line in lines
            if line_num == 1 || abs(duration_parameter_array[line_num] - duration_parameter_array[line_num - 1]) > 0.0001
                nMAE_array[line_num] = parse.(Float64, line)
            else
                nMAE_array[line_num] = nMAE_array[line_num - 1]
            end
            line_num += 1
        end
    end

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    nMAE_plot = plot(
        1:num_mcmc_runs,
        moving_average(nMAE_array, 10),
        # nMAE_array,
        lw = 1.5,
        grid = true,
        legend = false,
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(nMAE_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_mcmc_manual.pdf"))

    println("plot_mcmc_manual")
    println(nMAE_array)
    println()
end

function plot_metropolis_manual()
    duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "duration_parameter_array.csv"), ';', Float64, '\n')
    num_metropolis_runs = length(duration_parameter_array)
    nMAE_array = zeros(Float64, num_metropolis_runs)

    susceptibility_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_1_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_2_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_3_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_4_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_5_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_6_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_7_array.csv"), ';', Float64, '\n')

    temperature_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_1_array.csv"), ';', Float64, '\n')
    temperature_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_2_array.csv"), ';', Float64, '\n')
    temperature_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_3_array.csv"), ';', Float64, '\n')
    temperature_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_4_array.csv"), ';', Float64, '\n')
    temperature_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_5_array.csv"), ';', Float64, '\n')
    temperature_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_6_array.csv"), ';', Float64, '\n')
    temperature_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_7_array.csv"), ';', Float64, '\n')

    mean_immunity_duration_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_1_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_2_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_3_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_4_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_5_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_6_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_7_array.csv"), ';', Float64, '\n')

    random_infection_probability_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "random_infection_probability_1_array.csv"), ';', Float64, '\n')
    random_infection_probability_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "random_infection_probability_2_array.csv"), ';', Float64, '\n')
    random_infection_probability_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "random_infection_probability_3_array.csv"), ';', Float64, '\n')
    random_infection_probability_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "random_infection_probability_4_array.csv"), ';', Float64, '\n')

    open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_metropolis_manual.txt"),"r") do datafile
        lines = eachline(datafile)
        line_num = 1
        for line in lines
            if line_num == 1 || abs(duration_parameter_array[line_num] - duration_parameter_array[line_num - 1]) > 0.0001
                nMAE_array[line_num] = parse.(Float64, line)
            else
                nMAE_array[line_num] = nMAE_array[line_num - 1]
            end
            line_num += 1
        end
    end

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    nMAE_plot = plot(
        1:num_metropolis_runs,
        moving_average(nMAE_array, 10),
        # nMAE_array,
        lw = 1.5,
        grid = true,
        legend = false,
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(nMAE_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_metropolis_manual.pdf"))

    println("plot_metropolis_manual")
    println(nMAE_array)
    println()
end

function plot_metropolis_hypercube()
    duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "duration_parameter_array.csv"), ';', Float64, '\n')
    num_metropolis_runs = length(duration_parameter_array)
    nMAE_array = zeros(Float64, num_metropolis_runs)

    susceptibility_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_1_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_2_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_3_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_4_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_5_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_6_array.csv"), ';', Float64, '\n')
    susceptibility_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_7_array.csv"), ';', Float64, '\n')

    temperature_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_1_array.csv"), ';', Float64, '\n')
    temperature_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_2_array.csv"), ';', Float64, '\n')
    temperature_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_3_array.csv"), ';', Float64, '\n')
    temperature_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_4_array.csv"), ';', Float64, '\n')
    temperature_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_5_array.csv"), ';', Float64, '\n')
    temperature_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_6_array.csv"), ';', Float64, '\n')
    temperature_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_7_array.csv"), ';', Float64, '\n')

    mean_immunity_duration_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_1_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_2_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_3_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_4_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_5_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_6_array.csv"), ';', Float64, '\n')
    mean_immunity_duration_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_7_array.csv"), ';', Float64, '\n')

    random_infection_probability_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "random_infection_probability_1_array.csv"), ';', Float64, '\n')
    random_infection_probability_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "random_infection_probability_2_array.csv"), ';', Float64, '\n')
    random_infection_probability_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "random_infection_probability_3_array.csv"), ';', Float64, '\n')
    random_infection_probability_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "random_infection_probability_4_array.csv"), ';', Float64, '\n')

    open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_metropolis_hypercube.txt"),"r") do datafile
        lines = eachline(datafile)
        line_num = 1
        for line in lines
            if line_num == 1 || abs(duration_parameter_array[line_num] - duration_parameter_array[line_num - 1]) > 0.0001
                nMAE_array[line_num] = parse.(Float64, line)
            else
                nMAE_array[line_num] = nMAE_array[line_num - 1]
            end
            line_num += 1
        end
    end

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    nMAE_plot = plot(
        1:num_metropolis_runs,
        moving_average(nMAE_array, 10),
        lw = 1.5,
        grid = true,
        legend = false,
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(nMAE_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_metropolis_hypercube.pdf"))

    println("plot_metropolis_hypercube")
    println(nMAE_array)
    println()
end

function plot_swarm_hypercube()
    etiology = get_etiology()
    num_infected_age_groups_viruses = get_incidence(etiology, true, flu_starting_index, true)

    num_swarm_runs = 3
    num_particles = 20

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_swarm_runs + 1)
    duration_parameter = Array{Float64, 1}(undef, num_swarm_runs + 1)
    susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_swarm_runs + 1)
    temperature_parameters = Array{Vector{Float64}, 1}(undef, num_swarm_runs + 1)
    mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_swarm_runs + 1)
    random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_swarm_runs + 1)

    duration_parameter_velocity = Array{Float64, 1}(undef, num_swarm_runs)
    susceptibility_parameters_velocity = Array{Vector{Float64}, 1}(undef, num_swarm_runs)
    temperature_parameters_velocity = Array{Vector{Float64}, 1}(undef, num_swarm_runs)
    mean_immunity_durations_velocity = Array{Vector{Float64}, 1}(undef, num_swarm_runs)
    random_infection_probabilities_velocity = Array{Vector{Float64}, 1}(undef, num_swarm_runs)

    nMAE_array = zeros(Float64, num_swarm_runs)

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    for i = 1:num_particles
        incidence_arr[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_$(i).jld"))["observed_cases"]
        duration_parameter[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_$(i).jld"))["duration_parameter"]
        susceptibility_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_$(i).jld"))["susceptibility_parameters"]
        temperature_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_$(i).jld"))["temperature_parameters"]
        mean_immunity_durations[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_$(i).jld"))["mean_immunity_durations"]
        random_infection_probabilities[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_$(i).jld"))["random_infection_probabilities"]
    end
    
    for i = eachindex(nMAE_array)
        nMAE_array[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    end

    nMAE_plot = plot(
        1:num_swarm_runs,
        moving_average(nMAE_array, 10),
        lw = 1.5,
        grid = true,
        legend = false,
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # println("plot_swarm_hypercube")
    # println(nMAE_array)
    # println()






    # -------------------------------------
    # incidence_arr[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_10.jld"))["observed_cases"]
    # duration_parameter[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_10.jld"))["duration_parameter"]
    # susceptibility_parameters[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_10.jld"))["susceptibility_parameters"]
    # temperature_parameters[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_10.jld"))["temperature_parameters"]
    # mean_immunity_durations[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_10.jld"))["mean_immunity_durations"]
    # random_infection_probabilities[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_10.jld"))["random_infection_probabilities"]

    # for i = 1:num_swarm_runs
    #     incidence_arr[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "10", "results_$(i).jld"))["observed_cases"]
    #     duration_parameter[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "10", "results_$(i).jld"))["duration_parameter"]
    #     duration_parameter_velocity[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "10", "results_$(i).jld"))["duration_parameter_velocity"]
    #     susceptibility_parameters[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "10", "results_$(i).jld"))["susceptibility_parameters"]
    #     susceptibility_parameters_velocity[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "10", "results_$(i).jld"))["susceptibility_parameters_velocity"]
    #     temperature_parameters[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "10", "results_$(i).jld"))["temperature_parameters"]
    #     temperature_parameters_velocity[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "10", "results_$(i).jld"))["temperature_parameters_velocity"]
    #     mean_immunity_durations[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "10", "results_$(i).jld"))["mean_immunity_durations"]
    #     mean_immunity_durations_velocity[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "10", "results_$(i).jld"))["mean_immunity_durations_velocity"]
    #     random_infection_probabilities[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "10", "results_$(i).jld"))["random_infection_probabilities"]
    #     random_infection_probabilities_velocity[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "10", "results_$(i).jld"))["random_infection_probabilities_velocity"]
    # end
    
    # for i = eachindex(nMAE_array)
    #     nMAE_array[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    # end



    # println("duration_parameter")
    # println(duration_parameter)
    # println(duration_parameter_velocity)
    # println()
    # println()
    # return

    # println("susceptibility_parameter (FluA)")
    # for i = 1:num_swarm_runs
    #     print(susceptibility_parameters[i][1])
    #     print(" ")
    # end
    # println()

    # println("susceptibility_parameter (FluB)")
    # for i = 1:num_swarm_runs
    #     print(susceptibility_parameters[i][2])
    #     print(" ")
    # end
    # println()

    # println("susceptibility_parameter (RV)")
    # for i = 1:num_swarm_runs
    #     print(susceptibility_parameters[i][3])
    #     print(" ")
    # end
    # println()



    # println("susceptibility_parameter (RSV)")
    # for i = 1:(num_swarm_runs + 1)
    #     print(susceptibility_parameters[i][4])
    #     print(" ")
    # end
    # println()
    # println("susceptibility_parameter_velocity (RSV)")
    # for i = 1:num_swarm_runs
    #     print(susceptibility_parameters_velocity[i][4])
    #     print(" ")
    # end
    # println()



    # println(argmin(nMAE_array))
    # w = 0.5
    # c1 = 2.0
    # c2 = 2.0
    # num_swarm_model_runs = 50

    # curr_run = length(duration_parameter) + 1





    # mean_immunity_durations_particles_velocity = zeros(Float64, num_viruses)

    # mean_immunity_durations_best = mean_immunity_durations[argmin(nMAE_array)]

    # for j = 1:num_viruses
    #     mean_immunity_durations_particles_velocity[j] = w * mean_immunity_durations_velocity[curr_run - 1][j] + c1 * rand(Float64) * (mean_immunity_durations[argmin(nMAE_array)][j] - mean_immunity_durations[curr_run - 1][j]) + c2 * rand(Float64) * (mean_immunity_durations_best[j] - mean_immunity_durations[curr_run - 1][j])
    # end
    # println(mean_immunity_durations_particles_velocity)
    # println(mean_immunity_durations[curr_run - 1] + mean_immunity_durations_particles_velocity)




    # rng = MersenneTwister(1)

    # rand1 = rand(rng, Float64)
    # rand2 = rand(rng, Float64)

    # susceptibility_parameters_particles_velocity = c2 * rand2 * (susceptibility_parameters_best - susceptibility_parameters[1][4])




    # susceptibility_parameters_particles_velocity = w * susceptibility_parameters_velocity[curr_run - 1] + c1 * rand1 * (susceptibility_parameters[argmin(nMAE_array)] - susceptibility_parameters[curr_run - 1]) + c2 * rand2 * (susceptibility_parameters_best - susceptibility_parameters[curr_run - 1])




    # println("susceptibility_parameter (AdV)")
    # for i = 1:num_swarm_runs
    #     print(susceptibility_parameters[i][5])
    #     print(" ")
    # end
    # println()

    # println("susceptibility_parameter (PIV)")
    # for i = 1:num_swarm_runs
    #     print(susceptibility_parameters[i][6])
    #     print(" ")
    # end
    # println()

    # println("susceptibility_parameter (CoV)")
    # for i = 1:num_swarm_runs
    #     print(susceptibility_parameters[i][7])
    #     print(" ")
    # end
    # println()


    # return

    # println("----------------------------")

    # println("temperature_parameter (FluA)")
    # for i = 1:num_swarm_runs
    #     print(temperature_parameters[i][1])
    #     print(" ")
    # end
    # println()

    # println("temperature_parameter (FluB)")
    # for i = 1:num_swarm_runs
    #     print(temperature_parameters[i][2])
    #     print(" ")
    # end
    # println()

    # println("temperature_parameter (RV)")
    # for i = 1:num_swarm_runs
    #     print(temperature_parameters[i][3])
    #     print(" ")
    # end
    # println()

    # println("temperature_parameter (RSV)")
    # for i = 1:num_swarm_runs
    #     print(temperature_parameters[i][4])
    #     print(" ")
    # end
    # println()

    # println("temperature_parameter (AdV)")
    # for i = 1:num_swarm_runs
    #     print(temperature_parameters[i][5])
    #     print(" ")
    # end
    # println()

    # println("temperature_parameter (PIV)")
    # for i = 1:num_swarm_runs
    #     print(temperature_parameters[i][6])
    #     print(" ")
    # end
    # println()

    # println("temperature_parameter (CoV)")
    # for i = 1:num_swarm_runs
    #     print(temperature_parameters[i][7])
    #     print(" ")
    # end
    # println()

    # println("----------------------------")

    # println(argmin(nMAE_array))
    # w = 0.5
    # c1 = 2.0
    # c2 = 2.0
    # num_swarm_model_runs = 1000

    # curr_run = length(duration_parameter) + 1
    # # mean_immunity_durations_particles_velocity = zeros(Float64, num_viruses)

    # # mean_immunity_durations_best = mean_immunity_durations[argmin(nMAE_array)]

    # # for j = 1:num_viruses
    # #     mean_immunity_durations_particles_velocity[j] = w * mean_immunity_durations_velocity[curr_run - 1][j] + c1 * rand(Float64) * (mean_immunity_durations[argmin(nMAE_array)][j] - mean_immunity_durations[curr_run - 1][j]) + c2 * rand(Float64) * (mean_immunity_durations_best[j] - mean_immunity_durations[curr_run - 1][j])
    # # end
    # # println(mean_immunity_durations_particles_velocity)
    # # println(mean_immunity_durations[curr_run - 1] + mean_immunity_durations_particles_velocity)

    # rng = MersenneTwister(1)

    # duration_parameter_particles_velocity = 0.0

    # duration_parameter_best = duration_parameter[argmin(nMAE_array)]

    # println("ok")
    # rand1 = rand(rng, Float64)
    # rand2 = rand(rng, Float64)



    # println(duration_parameter[argmin(nMAE_array)])
    # println(duration_parameter[curr_run - 1])
    # println()

    # println(duration_parameter[argmin(nMAE_array)] - duration_parameter[curr_run - 1])
    # println(duration_parameter_best - duration_parameter[curr_run - 1])
    # println()

    # println(w * duration_parameter_velocity[curr_run - 1])
    # println(c1 * rand1 * (duration_parameter[argmin(nMAE_array)] - duration_parameter[curr_run - 1]))
    # println(c2 * rand2 * (duration_parameter_best - duration_parameter[curr_run - 1]))

    # println()

    # duration_parameter_particles_velocity = w * duration_parameter_velocity[curr_run - 1] + c1 * rand1 * (duration_parameter[argmin(nMAE_array)] - duration_parameter[curr_run - 1]) + c2 * rand2 * (duration_parameter_best - duration_parameter[curr_run - 1])
    # println(duration_parameter_particles_velocity)
    # println(duration_parameter[curr_run - 1] + duration_parameter_particles_velocity)

    # return


    # println("mean_immunity_duration (FluA)")
    # for i = 1:num_swarm_runs
    #     print(mean_immunity_durations[i][1])
    #     print(" ")
    # end
    # println()
    # println("mean_immunity_duration_velocity (FluA)")
    # for i = 1:num_swarm_runs
    #     print(mean_immunity_durations_velocity[i][1])
    #     print(" ")
    # end
    # println()
    # println()

    # println("mean_immunity_duration (FluB)")
    # for i = 1:num_swarm_runs
    #     print(mean_immunity_durations[i][2])
    #     print(" ")
    # end
    # println()
    # println("mean_immunity_duration_velocity (FluB)")
    # for i = 1:num_swarm_runs
    #     print(mean_immunity_durations_velocity[i][2])
    #     print(" ")
    # end
    # println()
    # println()

    # println("mean_immunity_duration (RV)")
    # for i = 1:num_swarm_runs
    #     print(mean_immunity_durations[i][3])
    #     print(" ")
    # end
    # println()
    # println("mean_immunity_duration_velocity (RV)")
    # for i = 1:num_swarm_runs
    #     print(mean_immunity_durations_velocity[i][3])
    #     print(" ")
    # end
    # println()
    # println()

    # println("mean_immunity_duration (RSV)")
    # for i = 1:num_swarm_runs
    #     print(mean_immunity_durations[i][4])
    #     print(" ")
    # end
    # println()
    # println("mean_immunity_duration_velocity (RSV)")
    # for i = 1:num_swarm_runs
    #     print(mean_immunity_durations_velocity[i][4])
    #     print(" ")
    # end
    # println()
    # println()

    # println("mean_immunity_duration (AdV)")
    # for i = 1:num_swarm_runs
    #     print(mean_immunity_durations[i][5])
    #     print(" ")
    # end
    # println()
    # println("mean_immunity_duration_velocity (AdV)")
    # for i = 1:num_swarm_runs
    #     print(mean_immunity_durations_velocity[i][5])
    #     print(" ")
    # end
    # println()
    # println()

    # println("mean_immunity_duration (PIV)")
    # for i = 1:num_swarm_runs
    #     print(mean_immunity_durations[i][6])
    #     print(" ")
    # end
    # println()
    # println("mean_immunity_duration_velocity (PIV)")
    # for i = 1:num_swarm_runs
    #     print(mean_immunity_durations_velocity[i][6])
    #     print(" ")
    # end
    # println()
    # println()

    # println("mean_immunity_duration (CoV)")
    # for i = 1:num_swarm_runs
    #     print(mean_immunity_durations[i][7])
    #     print(" ")
    # end
    # println()
    # println("mean_immunity_duration_velocity (CoV)")
    # for i = 1:num_swarm_runs
    #     print(mean_immunity_durations_velocity[i][7])
    #     print(" ")
    # end
    # println()
    # println("----------------------")


    # # println(argmin(nMAE_array))
    # # w = 0.0
    # # w_min = 0.4
    # # w_max = 0.9
    # # c1 = 2.0
    # # c2 = 2.0
    # # num_swarm_model_runs = 1000

    # # curr_run = length(duration_parameter) + 1
    # # w = (num_swarm_model_runs - curr_run) / num_swarm_model_runs * (w_max - w_min) + w_min
    # # mean_immunity_durations_particles_velocity = zeros(Float64, num_viruses)

    # # mean_immunity_durations_best = mean_immunity_durations[argmin(nMAE_array)]

    # # for j = 1:num_viruses
    # #     mean_immunity_durations_particles_velocity[j] = w * mean_immunity_durations_velocity[curr_run - 1][j] + c1 * rand(Float64) * (mean_immunity_durations[argmin(nMAE_array)][j] - mean_immunity_durations[curr_run - 1][j]) + c2 * rand(Float64) * (mean_immunity_durations_best[j] - mean_immunity_durations[curr_run - 1][j])
    # # end
    # # println(mean_immunity_durations_particles_velocity)
    # # println(mean_immunity_durations[curr_run - 1] + mean_immunity_durations_particles_velocity)





    
    # return

    
    

    

    

    # println("random_infection_probability (0-2)")
    # for i = 1:num_swarm_runs
    #     print(random_infection_probabilities[i][1])
    #     print(" ")
    # end
    # println()

    # println("random_infection_probability (3-6)")
    # for i = 1:num_swarm_runs
    #     print(random_infection_probabilities[i][2])
    #     print(" ")
    # end
    # println()

    # println("random_infection_probability (7-14)")
    # for i = 1:num_swarm_runs
    #     print(random_infection_probabilities[i][3])
    #     print(" ")
    # end
    # println()

    # println("random_infection_probability (15+)")
    # for i = 1:num_swarm_runs
    #     print(random_infection_probabilities[i][4])
    #     print(" ")
    # end
    # println()

    # return

    for j = 1:num_particles
        for i = 1:num_swarm_runs
            incidence_arr[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["observed_cases"]
            duration_parameter[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["duration_parameter"]
            duration_parameter_velocity[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["duration_parameter_velocity"][1]
            susceptibility_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["susceptibility_parameters"]
            temperature_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["temperature_parameters"]
            mean_immunity_durations[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["mean_immunity_durations"]
            random_infection_probabilities[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["random_infection_probabilities"]
        end

        for i = eachindex(nMAE_array)
            nMAE_array[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        end

        plot!(
            1:num_swarm_runs,
            moving_average(nMAE_array, 10),
            lw = 1.5,
            grid = true,
            legend = false,
            color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
    end

    savefig(nMAE_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_swarm_hypercube.pdf"))
end

function plot_surrogate_hypercube()
    num_surrogate_runs = 153

    etiology = get_etiology()
    num_infected_age_groups_viruses = get_incidence(etiology, true, flu_starting_index, true)

    num_swarm_runs = 28
    num_particles = 25

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_surrogate_runs)
    duration_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    temperature_parameters = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)

    nMAE_array = zeros(Float64, num_surrogate_runs)

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    for i = 1:num_surrogate_runs
        incidence_arr[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate", "results_$(i).jld"))["observed_cases"]
        duration_parameter[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate", "results_$(i).jld"))["duration_parameter"]
        susceptibility_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate", "results_$(i).jld"))["susceptibility_parameters"]
        temperature_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate", "results_$(i).jld"))["temperature_parameters"]
        mean_immunity_durations[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate", "results_$(i).jld"))["mean_immunity_durations"]
        random_infection_probabilities[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate", "results_$(i).jld"))["random_infection_probabilities"]
    end

    for i = eachindex(nMAE_array)
        nMAE_array[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    end

    nMAE_plot = plot(
        1:num_surrogate_runs,
        moving_average(nMAE_array, 10),
        lw = 1.5,
        grid = true,
        legend = false,
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    savefig(nMAE_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_surrogate_hypercube.pdf"))

    println("plot_surrogate_hypercube")
    println(nMAE_array)
    println()
end

# plot_mcmc_hypercube()
# plot_mcmc_manual()

# plot_metropolis_manual()
# plot_metropolis_hypercube()

plot_swarm_hypercube()

# plot_surrogate_hypercube()

