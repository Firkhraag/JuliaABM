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

    num_swarm_runs = 42
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

    nMAE_array = zeros(Float64, num_swarm_runs + 1)

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    incidence_arr[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_1.jld"))["observed_cases"]
    duration_parameter[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_1.jld"))["duration_parameter"]
    susceptibility_parameters[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_1.jld"))["susceptibility_parameters"]
    temperature_parameters[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_1.jld"))["temperature_parameters"]
    mean_immunity_durations[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_1.jld"))["mean_immunity_durations"]
    random_infection_probabilities[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_1.jld"))["random_infection_probabilities"]
    for i = 1:num_swarm_runs
        incidence_arr[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "1", "results_$(i).jld"))["observed_cases"]
        duration_parameter[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "1", "results_$(i).jld"))["duration_parameter"]
        susceptibility_parameters[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "1", "results_$(i).jld"))["susceptibility_parameters"]
        temperature_parameters[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "1", "results_$(i).jld"))["temperature_parameters"]
        mean_immunity_durations[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "1", "results_$(i).jld"))["mean_immunity_durations"]
        random_infection_probabilities[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "1", "results_$(i).jld"))["random_infection_probabilities"]
    end

    for i = eachindex(nMAE_array)
        nMAE_array[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    end

    nMAE_plot = plot(
        1:(num_swarm_runs + 1),
        moving_average(nMAE_array, 10),
        lw = 1.5,
        grid = true,
        legend = false,
        # color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        color = RGB(0.0, 0.0, 0.0),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    for j = 2:num_particles
        incidence_arr[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_$(j).jld"))["observed_cases"]
        duration_parameter[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_$(j).jld"))["duration_parameter"]
        susceptibility_parameters[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_$(j).jld"))["susceptibility_parameters"]
        temperature_parameters[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_$(j).jld"))["temperature_parameters"]
        mean_immunity_durations[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_$(j).jld"))["mean_immunity_durations"]
        random_infection_probabilities[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "0", "results_$(j).jld"))["random_infection_probabilities"]
        for i = 1:num_swarm_runs
            incidence_arr[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["observed_cases"]
            duration_parameter[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["duration_parameter"]
            susceptibility_parameters[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["susceptibility_parameters"]
            temperature_parameters[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["temperature_parameters"]
            mean_immunity_durations[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["mean_immunity_durations"]
            random_infection_probabilities[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["random_infection_probabilities"]
        end

        for i = eachindex(nMAE_array)
            nMAE_array[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        end

        plot!(
            1:(num_swarm_runs + 1),
            moving_average(nMAE_array, 10),
            lw = 1.5,
            grid = true,
            legend = false,
            # color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
            color = RGB(0.0, 0.0, 0.0),
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
        color = RGB(0.0, 0.0, 0.0),
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

