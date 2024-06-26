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
const num_runs = 1
const population_coef = 10072

function plot_mcmc_hypercube()
    duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "duration_parameter_array.csv"), ';', Float64, '\n')
    num_mcmc_runs = length(duration_parameter_array)
    error_array = zeros(Float64, num_mcmc_runs)

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
                error_array[line_num] = parse.(Float64, line)
            else
                error_array[line_num] = error_array[line_num - 1]
            end
            # error_array[line_num] = parse.(Float64, line)
            line_num += 1
        end
    end

    xlabel_name = "Step"
    if is_russian
        xlabel_name = "Шаг"
    end
    ylabel_name = "RMSE"

    error_plot = plot(
        1:num_mcmc_runs,
        moving_average(error_array, 10),
        # error_array,
        lw = 1.5,
        grid = true,
        legend = false,
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(error_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_mcmc_hypercube.pdf"))

    println("plot_mcmc_hypercube")
    println(error_array)
    println()
end

function plot_mcmc_manual()
    duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "duration_parameter_array.csv"), ';', Float64, '\n')
    num_mcmc_runs = length(duration_parameter_array)
    error_array = zeros(Float64, num_mcmc_runs)

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
            # if line_num == 1 || abs(duration_parameter_array[line_num] - duration_parameter_array[line_num - 1]) > 0.0001
            #     error_array[line_num] = parse.(Float64, line)
            # else
            #     error_array[line_num] = error_array[line_num - 1]
            # end
            error_array[line_num] = parse.(Float64, line)
            line_num += 1
        end
    end

    xlabel_name = "Step"
    if is_russian
        xlabel_name = "Шаг"
    end
    ylabel_name = "RMSE"

    error_plot = plot(
        1:num_mcmc_runs,
        moving_average(error_array, 10),
        # error_array,
        lw = 1.5,
        grid = true,
        legend = false,
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(error_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_mcmc_manual.pdf"))

    println("plot_mcmc_manual")
    println(error_array)
    println()
end

function plot_metropolis_manual()
    duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "duration_parameter_array.csv"), ';', Float64, '\n')
    num_metropolis_runs = length(duration_parameter_array)
    error_array = zeros(Float64, num_metropolis_runs)

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
            # if line_num == 1 || abs(duration_parameter_array[line_num] - duration_parameter_array[line_num - 1]) > 0.0001
            #     error_array[line_num] = parse.(Float64, line)
            # else
            #     error_array[line_num] = error_array[line_num - 1]
            # end
            error_array[line_num] = parse.(Float64, line)
            line_num += 1
        end
    end

    xlabel_name = "Step"
    if is_russian
        xlabel_name = "Шаг"
    end
    ylabel_name = "RMSE"

    error_plot = plot(
        1:num_metropolis_runs,
        moving_average(error_array, 10),
        # error_array,
        lw = 1.5,
        grid = true,
        legend = false,
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(error_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_metropolis_manual.pdf"))

    println("plot_metropolis_manual")
    println(error_array)
    println()
end

function plot_metropolis_hypercube()
    duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "duration_parameter_array.csv"), ';', Float64, '\n')
    num_metropolis_runs = length(duration_parameter_array)
    error_array = zeros(Float64, num_metropolis_runs)

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
                error_array[line_num] = parse.(Float64, line)
            else
                error_array[line_num] = error_array[line_num - 1]
            end
            line_num += 1
        end
    end

    xlabel_name = "Step"
    if is_russian
        xlabel_name = "Шаг"
    end
    ylabel_name = "RMSE"

    error_plot = plot(
        1:num_metropolis_runs,
        moving_average(error_array, 10),
        lw = 1.5,
        grid = true,
        legend = false,
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(error_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_metropolis_hypercube.pdf"))

    println("plot_metropolis_hypercube")
    println(error_array)
    println()
end

function plot_swarm_hypercube()
    etiology = get_etiology()
    num_infected_age_groups_viruses = get_incidence(etiology, true, flu_starting_index, true)

    num_swarm_runs = 23
    num_particles = 10

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

    error_array = zeros(Float64, num_swarm_runs + 1)

    xlabel_name = "Step"
    if is_russian
        xlabel_name = "Шаг"
    end
    ylabel_name = "RMSE"

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

    for i = eachindex(error_array)
        # error_array[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        error_array[i] = sum((incidence_arr[i] - num_infected_age_groups_viruses).^2)
    end

    error_plot = plot(
        1:(num_swarm_runs + 1),
        moving_average(error_array, 10),
        lw = 1.5,
        grid = true,
        legend = false,
        # color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        # color = RGB(0.0, 0.0, 0.0),
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
            if j == 2
                println(temperature_parameters[i + 1])
            end
            susceptibility_parameters[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["susceptibility_parameters"]
            temperature_parameters[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["temperature_parameters"]
            mean_immunity_durations[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["mean_immunity_durations"]
            random_infection_probabilities[i + 1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["random_infection_probabilities"]
        end

        for i = eachindex(error_array)
            # error_array[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
            error_array[i] = sum((incidence_arr[i] - num_infected_age_groups_viruses).^2)
        end

        plot!(
            1:(num_swarm_runs + 1),
            moving_average(error_array, 3),
            lw = 1.5,
            grid = true,
            legend = false,
            # color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
            # color = RGB(0.0, 0.0, 0.0),
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
    end

    savefig(error_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_swarm_hypercube.pdf"))
end

function plot_surrogate_hypercube()
    num_surrogate_runs = 200
    # num_surrogate_runs = 153
    # num_surrogate_runs = 100

    etiology = get_etiology()
    num_infected_age_groups_viruses = get_incidence(etiology, true, flu_starting_index, true)

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_surrogate_runs)
    duration_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    temperature_parameters = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)

    error_array = zeros(Float64, num_surrogate_runs)

    xlabel_name = "Step"
    if is_russian
        xlabel_name = "Шаг"
    end
    ylabel_name = "RMSE"

    for i = 1:num_surrogate_runs
        incidence_arr[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate", "results_$(i).jld"))["observed_cases"]
        duration_parameter[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate", "results_$(i).jld"))["duration_parameter"]
        susceptibility_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate", "results_$(i).jld"))["susceptibility_parameters"]
        temperature_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate", "results_$(i).jld"))["temperature_parameters"]
        mean_immunity_durations[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate", "results_$(i).jld"))["mean_immunity_durations"]
        random_infection_probabilities[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate", "results_$(i).jld"))["random_infection_probabilities"]
    end

    for i = eachindex(error_array)
        error_array[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    end

    error_plot = plot(
        1:num_surrogate_runs,
        moving_average(error_array, 10),
        
        lw = 1.5,
        grid = true,
        legend = false,
        color = RGB(0.0, 0.0, 0.0),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    savefig(error_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_surrogate_hypercube.pdf"))

    println("plot_surrogate_hypercube")
    println(error_array)
    println()
end

function optimization_methods()
    num_error_points = 1456
    num_method_runs = 3
    etiology = get_etiology()
    num_infected_age_groups_viruses = get_incidence(etiology, true, flu_starting_index, true)

    minimum_arr = zeros(Float64, num_method_runs)
    minimum_step_arr = zeros(Float64, num_method_runs)

    # num_mcmc_runs = 200
    # error_array = zeros(Float64, num_mcmc_runs)

    # for method_run = 1:num_method_runs
    #     duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "duration_parameter_array.csv"), ';', Float64, '\n')

    #     susceptibility_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "susceptibility_parameter_1_array.csv"), ';', Float64, '\n')
    #     susceptibility_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "susceptibility_parameter_2_array.csv"), ';', Float64, '\n')
    #     susceptibility_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "susceptibility_parameter_3_array.csv"), ';', Float64, '\n')
    #     susceptibility_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "susceptibility_parameter_4_array.csv"), ';', Float64, '\n')
    #     susceptibility_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "susceptibility_parameter_5_array.csv"), ';', Float64, '\n')
    #     susceptibility_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "susceptibility_parameter_6_array.csv"), ';', Float64, '\n')
    #     susceptibility_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "susceptibility_parameter_7_array.csv"), ';', Float64, '\n')

    #     temperature_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "temperature_parameter_1_array.csv"), ';', Float64, '\n')
    #     temperature_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "temperature_parameter_2_array.csv"), ';', Float64, '\n')
    #     temperature_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "temperature_parameter_3_array.csv"), ';', Float64, '\n')
    #     temperature_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "temperature_parameter_4_array.csv"), ';', Float64, '\n')
    #     temperature_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "temperature_parameter_5_array.csv"), ';', Float64, '\n')
    #     temperature_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "temperature_parameter_6_array.csv"), ';', Float64, '\n')
    #     temperature_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "temperature_parameter_7_array.csv"), ';', Float64, '\n')

    #     mean_immunity_duration_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "mean_immunity_duration_1_array.csv"), ';', Float64, '\n')
    #     mean_immunity_duration_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "mean_immunity_duration_2_array.csv"), ';', Float64, '\n')
    #     mean_immunity_duration_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "mean_immunity_duration_3_array.csv"), ';', Float64, '\n')
    #     mean_immunity_duration_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "mean_immunity_duration_4_array.csv"), ';', Float64, '\n')
    #     mean_immunity_duration_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "mean_immunity_duration_5_array.csv"), ';', Float64, '\n')
    #     mean_immunity_duration_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "mean_immunity_duration_6_array.csv"), ';', Float64, '\n')
    #     mean_immunity_duration_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "mean_immunity_duration_7_array.csv"), ';', Float64, '\n')

    #     random_infection_probability_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "random_infection_probability_1_array.csv"), ';', Float64, '\n')
    #     random_infection_probability_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "random_infection_probability_2_array.csv"), ';', Float64, '\n')
    #     random_infection_probability_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "random_infection_probability_3_array.csv"), ';', Float64, '\n')
    #     random_infection_probability_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(method_run)", "random_infection_probability_4_array.csv"), ';', Float64, '\n')

    #     open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_mcmc_hypercube$(method_run).txt"),"r") do datafile
    #         lines = eachline(datafile)
    #         line_num = 1
    #         for line in lines
    #             if line_num == 1 || ((abs(susceptibility_parameter_1_array[line_num] - susceptibility_parameter_1_array[line_num - 1]) > 0.0001) && (abs(susceptibility_parameter_2_array[line_num] - susceptibility_parameter_2_array[line_num - 1]) > 0.0001))
    #                 error_array[line_num] = parse.(Float64, line)
    #             else
    #                 error_array[line_num] = error_array[line_num - 1]
    #             end
    #             # error_array[line_num] = parse.(Float64, line)
    #             line_num += 1
    #             if line_num > num_mcmc_runs
    #                 break
    #             end
    #         end
    #     end

    #     minimum_step_arr[method_run] = argmin(error_array)
    #     minimum_arr[method_run] = minimum(error_array)
    # end

    # # println("MCMC LHS minimum method run = $(argmin(minimum_arr))")
    # # println("MCMC LHS min error = $(sqrt.(minimum(minimum_arr) / num_error_points))")
    # # println("MCMC LHS mean error = $(sqrt.(mean(minimum_arr) / num_error_points))")
    # # println("MCMC LHS min step = $(minimum_step_arr[argmin(minimum_arr)])")
    # # println("MCMC LHS mean step = $(mean(minimum_step_arr))")
    # # return

    # median_arg = 0
    # for i = 1:num_method_runs
    #     if abs(minimum_arr[i] - median(minimum_arr)) < 0.00001
    #         median_arg = i
    #         break
    #     end
    # end
    # median_arg = argmin(minimum_arr)

    # duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "duration_parameter_array.csv"), ';', Float64, '\n')

    # susceptibility_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "susceptibility_parameter_1_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "susceptibility_parameter_2_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "susceptibility_parameter_3_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "susceptibility_parameter_4_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "susceptibility_parameter_5_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "susceptibility_parameter_6_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "susceptibility_parameter_7_array.csv"), ';', Float64, '\n')

    # temperature_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "temperature_parameter_1_array.csv"), ';', Float64, '\n')
    # temperature_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "temperature_parameter_2_array.csv"), ';', Float64, '\n')
    # temperature_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "temperature_parameter_3_array.csv"), ';', Float64, '\n')
    # temperature_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "temperature_parameter_4_array.csv"), ';', Float64, '\n')
    # temperature_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "temperature_parameter_5_array.csv"), ';', Float64, '\n')
    # temperature_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "temperature_parameter_6_array.csv"), ';', Float64, '\n')
    # temperature_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "temperature_parameter_7_array.csv"), ';', Float64, '\n')

    # mean_immunity_duration_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "mean_immunity_duration_1_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "mean_immunity_duration_2_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "mean_immunity_duration_3_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "mean_immunity_duration_4_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "mean_immunity_duration_5_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "mean_immunity_duration_6_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "mean_immunity_duration_7_array.csv"), ';', Float64, '\n')

    # random_infection_probability_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "random_infection_probability_1_array.csv"), ';', Float64, '\n')
    # random_infection_probability_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "random_infection_probability_2_array.csv"), ';', Float64, '\n')
    # random_infection_probability_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "random_infection_probability_3_array.csv"), ';', Float64, '\n')
    # random_infection_probability_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube$(median_arg)", "random_infection_probability_4_array.csv"), ';', Float64, '\n')
    # open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_mcmc_hypercube$(median_arg).txt"),"r") do datafile
    #     lines = eachline(datafile)
    #     line_num = 1
    #     for line in lines
    #         if line_num == 1 || ((abs(susceptibility_parameter_1_array[line_num] - susceptibility_parameter_1_array[line_num - 1]) > 0.0001) && (abs(susceptibility_parameter_2_array[line_num] - susceptibility_parameter_2_array[line_num - 1]) > 0.0001))
    #             error_array[line_num] = parse.(Float64, line)
    #         else
    #             error_array[line_num] = error_array[line_num - 1]
    #         end
    #         # error_array[line_num] = parse.(Float64, line)
    #         line_num += 1
    #         if line_num > num_mcmc_runs
    #             break
    #         end
    #     end
    # end

    # xlabel_name = "Step"
    # if is_russian
    #     xlabel_name = "Шаг"
    # end
    # ylabel_name = "RMSE"

    # error_plot = plot(
    #     1:num_mcmc_runs,
    #     moving_average(sqrt.(error_array[1:num_mcmc_runs] / num_error_points), 3),
    #     lw = 1.5,
    #     grid = true,
    #     label = "MCMC LHS",
    #     color = RGB(0.267, 0.467, 0.667),
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )

    # # min_argument = argmin(error_array[1:num_mcmc_runs])
    # # println(min_argument)
    # # println(sqrt.(error_array[min_argument] / num_error_points))
    # # println("MCMC LHS")
    # # println("duration_parameter = $(duration_parameter_array[min_argument])")
    # # println("susceptibility_parameters = $([susceptibility_parameter_1_array[min_argument], susceptibility_parameter_2_array[min_argument], susceptibility_parameter_3_array[min_argument], susceptibility_parameter_4_array[min_argument], susceptibility_parameter_5_array[min_argument], susceptibility_parameter_6_array[min_argument], susceptibility_parameter_7_array[min_argument]])")
    # # println("temperature_parameters = $(-[temperature_parameter_1_array[min_argument], temperature_parameter_2_array[min_argument], temperature_parameter_3_array[min_argument], temperature_parameter_4_array[min_argument], temperature_parameter_5_array[min_argument], temperature_parameter_6_array[min_argument], temperature_parameter_7_array[min_argument]])")
    # # println("mean_immunity_durations = $([mean_immunity_duration_1_array[min_argument], mean_immunity_duration_2_array[min_argument], mean_immunity_duration_3_array[min_argument], mean_immunity_duration_4_array[min_argument], mean_immunity_duration_5_array[min_argument], mean_immunity_duration_6_array[min_argument], mean_immunity_duration_7_array[min_argument]])")
    # # println("random_infection_probabilities = $([random_infection_probability_1_array[min_argument], random_infection_probability_2_array[min_argument], random_infection_probability_3_array[min_argument], random_infection_probability_4_array[min_argument]])")
    # # println()
    # # return




    # # num_mcmc_runs = 200
    # # error_array = zeros(Float64, num_mcmc_runs)

    # # for method_run = 1:num_method_runs
    # #     duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "duration_parameter_array.csv"), ';', Float64, '\n')

    # #     susceptibility_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "susceptibility_parameter_1_array.csv"), ';', Float64, '\n')
    # #     susceptibility_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "susceptibility_parameter_2_array.csv"), ';', Float64, '\n')
    # #     susceptibility_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "susceptibility_parameter_3_array.csv"), ';', Float64, '\n')
    # #     susceptibility_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "susceptibility_parameter_4_array.csv"), ';', Float64, '\n')
    # #     susceptibility_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "susceptibility_parameter_5_array.csv"), ';', Float64, '\n')
    # #     susceptibility_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "susceptibility_parameter_6_array.csv"), ';', Float64, '\n')
    # #     susceptibility_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "susceptibility_parameter_7_array.csv"), ';', Float64, '\n')

    # #     temperature_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "temperature_parameter_1_array.csv"), ';', Float64, '\n')
    # #     temperature_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "temperature_parameter_2_array.csv"), ';', Float64, '\n')
    # #     temperature_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "temperature_parameter_3_array.csv"), ';', Float64, '\n')
    # #     temperature_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "temperature_parameter_4_array.csv"), ';', Float64, '\n')
    # #     temperature_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "temperature_parameter_5_array.csv"), ';', Float64, '\n')
    # #     temperature_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "temperature_parameter_6_array.csv"), ';', Float64, '\n')
    # #     temperature_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "temperature_parameter_7_array.csv"), ';', Float64, '\n')

    # #     mean_immunity_duration_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "mean_immunity_duration_1_array.csv"), ';', Float64, '\n')
    # #     mean_immunity_duration_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "mean_immunity_duration_2_array.csv"), ';', Float64, '\n')
    # #     mean_immunity_duration_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "mean_immunity_duration_3_array.csv"), ';', Float64, '\n')
    # #     mean_immunity_duration_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "mean_immunity_duration_4_array.csv"), ';', Float64, '\n')
    # #     mean_immunity_duration_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "mean_immunity_duration_5_array.csv"), ';', Float64, '\n')
    # #     mean_immunity_duration_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "mean_immunity_duration_6_array.csv"), ';', Float64, '\n')
    # #     mean_immunity_duration_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "mean_immunity_duration_7_array.csv"), ';', Float64, '\n')

    # #     random_infection_probability_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "random_infection_probability_1_array.csv"), ';', Float64, '\n')
    # #     random_infection_probability_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "random_infection_probability_2_array.csv"), ';', Float64, '\n')
    # #     random_infection_probability_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "random_infection_probability_3_array.csv"), ';', Float64, '\n')
    # #     random_infection_probability_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(method_run)", "random_infection_probability_4_array.csv"), ';', Float64, '\n')

    # #     open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_mcmc_hypercube_lhs_10_$(method_run).txt"),"r") do datafile
    # #         lines = eachline(datafile)
    # #         line_num = 1
    # #         for line in lines
    # #             if line_num == 1 || ((abs(susceptibility_parameter_1_array[line_num] - susceptibility_parameter_1_array[line_num - 1]) > 0.0001) && (abs(susceptibility_parameter_2_array[line_num] - susceptibility_parameter_2_array[line_num - 1]) > 0.0001))
    # #                 error_array[line_num] = parse.(Float64, line)
    # #             else
    # #                 error_array[line_num] = error_array[line_num - 1]
    # #             end
    # #             # error_array[line_num] = parse.(Float64, line)
    # #             line_num += 1
    # #             if line_num > num_mcmc_runs
    # #                 break
    # #             end
    # #         end
    # #     end

    # #     minimum_step_arr[method_run] = argmin(error_array)
    # #     minimum_arr[method_run] = minimum(error_array)
    # # end

    # # # println("MCMC LHS 10 minimum method run = $(median_arg)")
    # # # println("MCMC LHS 10 min error = $(minimum(minimum_arr))")
    # # # println("MCMC LHS 10 mean error = $(mean(minimum_arr))")
    # # # println("MCMC LHS 10 min step = $(minimum(minimum_step_arr))")
    # # # println("MCMC LHS 10 mean step = $(mean(minimum_step_arr))")
    # # # return

    # # median_arg = 0
    # # for i = 1:num_method_runs
    # #     if abs(minimum_arr[i] - median(minimum_arr)) < 0.00001
    # #         median_arg = i
    # #         break
    # #     end
    # # end
    # median_arg = argmin(minimum_arr)

    # # duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "duration_parameter_array.csv"), ';', Float64, '\n')

    # # susceptibility_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "susceptibility_parameter_1_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "susceptibility_parameter_2_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "susceptibility_parameter_3_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "susceptibility_parameter_4_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "susceptibility_parameter_5_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "susceptibility_parameter_6_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "susceptibility_parameter_7_array.csv"), ';', Float64, '\n')

    # # temperature_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "temperature_parameter_1_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "temperature_parameter_2_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "temperature_parameter_3_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "temperature_parameter_4_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "temperature_parameter_5_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "temperature_parameter_6_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "temperature_parameter_7_array.csv"), ';', Float64, '\n')

    # # mean_immunity_duration_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "mean_immunity_duration_1_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "mean_immunity_duration_2_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "mean_immunity_duration_3_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "mean_immunity_duration_4_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "mean_immunity_duration_5_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "mean_immunity_duration_6_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "mean_immunity_duration_7_array.csv"), ';', Float64, '\n')

    # # random_infection_probability_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "random_infection_probability_1_array.csv"), ';', Float64, '\n')
    # # random_infection_probability_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "random_infection_probability_2_array.csv"), ';', Float64, '\n')
    # # random_infection_probability_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "random_infection_probability_3_array.csv"), ';', Float64, '\n')
    # # random_infection_probability_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube_lhs_10_$(median_arg)", "random_infection_probability_4_array.csv"), ';', Float64, '\n')
    # # open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_mcmc_hypercube_lhs_10_$(median_arg).txt"),"r") do datafile
    # #     lines = eachline(datafile)
    # #     line_num = 1
    # #     for line in lines
    # #         if line_num == 1 || ((abs(susceptibility_parameter_1_array[line_num] - susceptibility_parameter_1_array[line_num - 1]) > 0.0001) && (abs(susceptibility_parameter_2_array[line_num] - susceptibility_parameter_2_array[line_num - 1]) > 0.0001))
    # #             error_array[line_num] = parse.(Float64, line)
    # #         else
    # #             error_array[line_num] = error_array[line_num - 1]
    # #         end
    # #         # error_array[line_num] = parse.(Float64, line)
    # #         line_num += 1
    # #         if line_num > num_mcmc_runs
    # #             break
    # #         end
    # #     end
    # # end

    # # xlabel_name = "Step"
    # # ylabel_name = "RMSE"

    # # error_plot = plot(
    # #     1:num_mcmc_runs,
    # #     moving_average(sqrt.(error_array[1:num_mcmc_runs] / num_error_points), 3),
    # #     lw = 1.5,
    # #     grid = true,
    # #     label = "MCMC LHS 10",
    # #     color = RGB(0.5, 0.5, 0.5),
    # #     foreground_color_legend = nothing,
    # #     background_color_legend = nothing,
    # #     xlabel = xlabel_name,
    # #     ylabel = ylabel_name,
    # # )

    # # min_argument = argmin(error_array[1:num_mcmc_runs])
    # # println(min_argument)
    # # println(sqrt.(error_array[min_argument] / num_error_points))
    # # println("MCMC LHS 10")
    # # println("duration_parameter = $(duration_parameter_array[min_argument])")
    # # println("susceptibility_parameters = $([susceptibility_parameter_1_array[min_argument], susceptibility_parameter_2_array[min_argument], susceptibility_parameter_3_array[min_argument], susceptibility_parameter_4_array[min_argument], susceptibility_parameter_5_array[min_argument], susceptibility_parameter_6_array[min_argument], susceptibility_parameter_7_array[min_argument]])")
    # # println("temperature_parameters = $(-[temperature_parameter_1_array[min_argument], temperature_parameter_2_array[min_argument], temperature_parameter_3_array[min_argument], temperature_parameter_4_array[min_argument], temperature_parameter_5_array[min_argument], temperature_parameter_6_array[min_argument], temperature_parameter_7_array[min_argument]])")
    # # println("mean_immunity_durations = $([mean_immunity_duration_1_array[min_argument], mean_immunity_duration_2_array[min_argument], mean_immunity_duration_3_array[min_argument], mean_immunity_duration_4_array[min_argument], mean_immunity_duration_5_array[min_argument], mean_immunity_duration_6_array[min_argument], mean_immunity_duration_7_array[min_argument]])")
    # # println("random_infection_probabilities = $([random_infection_probability_1_array[min_argument], random_infection_probability_2_array[min_argument], random_infection_probability_3_array[min_argument], random_infection_probability_4_array[min_argument]])")
    # # println()
    # # return




    # num_mcmc_runs = 200
    # error_array = zeros(Float64, num_mcmc_runs)

    # for method_run = 1:num_method_runs
    #     duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "duration_parameter_array.csv"), ';', Float64, '\n')

    #     susceptibility_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "susceptibility_parameter_1_array.csv"), ';', Float64, '\n')
    #     susceptibility_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "susceptibility_parameter_2_array.csv"), ';', Float64, '\n')
    #     susceptibility_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "susceptibility_parameter_3_array.csv"), ';', Float64, '\n')
    #     susceptibility_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "susceptibility_parameter_4_array.csv"), ';', Float64, '\n')
    #     susceptibility_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "susceptibility_parameter_5_array.csv"), ';', Float64, '\n')
    #     susceptibility_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "susceptibility_parameter_6_array.csv"), ';', Float64, '\n')
    #     susceptibility_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "susceptibility_parameter_7_array.csv"), ';', Float64, '\n')

    #     temperature_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "temperature_parameter_1_array.csv"), ';', Float64, '\n')
    #     temperature_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "temperature_parameter_2_array.csv"), ';', Float64, '\n')
    #     temperature_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "temperature_parameter_3_array.csv"), ';', Float64, '\n')
    #     temperature_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "temperature_parameter_4_array.csv"), ';', Float64, '\n')
    #     temperature_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "temperature_parameter_5_array.csv"), ';', Float64, '\n')
    #     temperature_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "temperature_parameter_6_array.csv"), ';', Float64, '\n')
    #     temperature_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "temperature_parameter_7_array.csv"), ';', Float64, '\n')

    #     mean_immunity_duration_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "mean_immunity_duration_1_array.csv"), ';', Float64, '\n')
    #     mean_immunity_duration_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "mean_immunity_duration_2_array.csv"), ';', Float64, '\n')
    #     mean_immunity_duration_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "mean_immunity_duration_3_array.csv"), ';', Float64, '\n')
    #     mean_immunity_duration_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "mean_immunity_duration_4_array.csv"), ';', Float64, '\n')
    #     mean_immunity_duration_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "mean_immunity_duration_5_array.csv"), ';', Float64, '\n')
    #     mean_immunity_duration_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "mean_immunity_duration_6_array.csv"), ';', Float64, '\n')
    #     mean_immunity_duration_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "mean_immunity_duration_7_array.csv"), ';', Float64, '\n')

    #     random_infection_probability_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "random_infection_probability_1_array.csv"), ';', Float64, '\n')
    #     random_infection_probability_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "random_infection_probability_2_array.csv"), ';', Float64, '\n')
    #     random_infection_probability_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "random_infection_probability_3_array.csv"), ';', Float64, '\n')
    #     random_infection_probability_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(method_run)", "random_infection_probability_4_array.csv"), ';', Float64, '\n')

    #     open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_mcmc_manual$(method_run).txt"),"r") do datafile
    #         lines = eachline(datafile)
    #         line_num = 1
    #         for line in lines
    #             if line_num == 1 || ((abs(susceptibility_parameter_1_array[line_num] - susceptibility_parameter_1_array[line_num - 1]) > 0.0001) && (abs(susceptibility_parameter_2_array[line_num] - susceptibility_parameter_2_array[line_num - 1]) > 0.0001))
    #                 error_array[line_num] = parse.(Float64, line)
    #             else
    #                 error_array[line_num] = error_array[line_num - 1]
    #             end
    #             # error_array[line_num] = parse.(Float64, line)
    #             line_num += 1
    #             if line_num > num_mcmc_runs
    #                 break
    #             end
    #         end
    #     end

    #     minimum_step_arr[method_run] = argmin(error_array)
    #     minimum_arr[method_run] = minimum(error_array)
    # end

    # # println("MCMC manual minimum method run = $(argmin(minimum_arr))")
    # # println("MCMC manual min error = $(sqrt.(minimum(minimum_arr) / num_error_points))")
    # # println("MCMC manual mean error = $(sqrt.(mean(minimum_arr) / num_error_points))")
    # # println("MCMC manual min step = $(minimum_step_arr[argmin(minimum_arr)])")
    # # println("MCMC manual mean step = $(mean(minimum_step_arr))")
    # # return

    # median_arg = 0
    # for i = 1:num_method_runs
    #     if abs(minimum_arr[i] - median(minimum_arr)) < 0.00001
    #         median_arg = i
    #         break
    #     end
    # end
    # median_arg = argmin(minimum_arr)

    # duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "duration_parameter_array.csv"), ';', Float64, '\n')

    # susceptibility_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "susceptibility_parameter_1_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "susceptibility_parameter_2_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "susceptibility_parameter_3_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "susceptibility_parameter_4_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "susceptibility_parameter_5_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "susceptibility_parameter_6_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "susceptibility_parameter_7_array.csv"), ';', Float64, '\n')

    # temperature_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "temperature_parameter_1_array.csv"), ';', Float64, '\n')
    # temperature_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "temperature_parameter_2_array.csv"), ';', Float64, '\n')
    # temperature_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "temperature_parameter_3_array.csv"), ';', Float64, '\n')
    # temperature_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "temperature_parameter_4_array.csv"), ';', Float64, '\n')
    # temperature_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "temperature_parameter_5_array.csv"), ';', Float64, '\n')
    # temperature_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "temperature_parameter_6_array.csv"), ';', Float64, '\n')
    # temperature_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "temperature_parameter_7_array.csv"), ';', Float64, '\n')

    # mean_immunity_duration_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "mean_immunity_duration_1_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "mean_immunity_duration_2_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "mean_immunity_duration_3_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "mean_immunity_duration_4_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "mean_immunity_duration_5_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "mean_immunity_duration_6_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "mean_immunity_duration_7_array.csv"), ';', Float64, '\n')

    # random_infection_probability_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "random_infection_probability_1_array.csv"), ';', Float64, '\n')
    # random_infection_probability_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "random_infection_probability_2_array.csv"), ';', Float64, '\n')
    # random_infection_probability_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "random_infection_probability_3_array.csv"), ';', Float64, '\n')
    # random_infection_probability_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual$(median_arg)", "random_infection_probability_4_array.csv"), ';', Float64, '\n')

    # open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_mcmc_manual$(median_arg).txt"),"r") do datafile
    #     lines = eachline(datafile)
    #     line_num = 1
    #     for line in lines
    #         if line_num == 1 || ((abs(susceptibility_parameter_1_array[line_num] - susceptibility_parameter_1_array[line_num - 1]) > 0.0001) && (abs(susceptibility_parameter_2_array[line_num] - susceptibility_parameter_2_array[line_num - 1]) > 0.0001))
    #             error_array[line_num] = parse.(Float64, line)
    #         else
    #             error_array[line_num] = error_array[line_num - 1]
    #         end
    #         # error_array[line_num] = parse.(Float64, line)
    #         line_num += 1
    #         if line_num > num_mcmc_runs
    #             break
    #         end
    #     end
    # end

    # xlabel_name = "Step"
    # if is_russian
    #     xlabel_name = "Шаг"
    # end
    # ylabel_name = "RMSE"

    # plot!(
    #     1:num_mcmc_runs,
    #     moving_average(sqrt.(error_array[1:num_mcmc_runs] / num_error_points), 3),
    #     lw = 1.5,
    #     grid = true,
    #     label = "MCMC manual",
    #     color = RGB(0.933, 0.4, 0.467),
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )

    # # min_argument = argmin(error_array[1:num_mcmc_runs])
    # # println(sqrt.(error_array[min_argument] / num_error_points))
    # # println(min_argument)
    # # println("MCMC manual")
    # # println("duration_parameter = $(duration_parameter_array[min_argument])")
    # # println("susceptibility_parameters = $([susceptibility_parameter_1_array[min_argument], susceptibility_parameter_2_array[min_argument], susceptibility_parameter_3_array[min_argument], susceptibility_parameter_4_array[min_argument], susceptibility_parameter_5_array[min_argument], susceptibility_parameter_6_array[min_argument], susceptibility_parameter_7_array[min_argument]])")
    # # println("temperature_parameters = $(-[temperature_parameter_1_array[min_argument], temperature_parameter_2_array[min_argument], temperature_parameter_3_array[min_argument], temperature_parameter_4_array[min_argument], temperature_parameter_5_array[min_argument], temperature_parameter_6_array[min_argument], temperature_parameter_7_array[min_argument]])")
    # # println("mean_immunity_durations = $([mean_immunity_duration_1_array[min_argument], mean_immunity_duration_2_array[min_argument], mean_immunity_duration_3_array[min_argument], mean_immunity_duration_4_array[min_argument], mean_immunity_duration_5_array[min_argument], mean_immunity_duration_6_array[min_argument], mean_immunity_duration_7_array[min_argument]])")
    # # println("random_infection_probabilities = $([random_infection_probability_1_array[min_argument], random_infection_probability_2_array[min_argument], random_infection_probability_3_array[min_argument], random_infection_probability_4_array[min_argument]])")
    # # println()
    # # return

    # # duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "duration_parameter_array.csv"), ';', Float64, '\n')
    # # num_metropolis_runs = length(duration_parameter_array)
    # # error_array = zeros(Float64, num_metropolis_runs)

    # # susceptibility_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_1_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_2_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_3_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_4_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_5_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_6_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_7_array.csv"), ';', Float64, '\n')

    # # temperature_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_1_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_2_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_3_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_4_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_5_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_6_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_7_array.csv"), ';', Float64, '\n')

    # # mean_immunity_duration_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_1_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_2_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_3_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_4_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_5_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_6_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_7_array.csv"), ';', Float64, '\n')

    # # random_infection_probability_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "random_infection_probability_1_array.csv"), ';', Float64, '\n')
    # # random_infection_probability_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "random_infection_probability_2_array.csv"), ';', Float64, '\n')
    # # random_infection_probability_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "random_infection_probability_3_array.csv"), ';', Float64, '\n')
    # # random_infection_probability_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "random_infection_probability_4_array.csv"), ';', Float64, '\n')

    # # open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_metropolis_hypercube.txt"),"r") do datafile
    # #     lines = eachline(datafile)
    # #     line_num = 1
    # #     for line in lines
    # #         if line_num == 1 || ((abs(susceptibility_parameter_1_array[line_num] - susceptibility_parameter_1_array[line_num - 1]) > 0.0001) && (abs(susceptibility_parameter_2_array[line_num] - susceptibility_parameter_2_array[line_num - 1]) > 0.0001))
    # #             error_array[line_num] = parse.(Float64, line)
    # #         else
    # #             error_array[line_num] = error_array[line_num - 1]
    # #         end
    # #         # error_array[line_num] = parse.(Float64, line)
    # #         line_num += 1
    # #     end
    # # end

    # # xlabel_name = "Step"
    # # ylabel_name = "RMSE"

    # # plot!(
    # #     1:250,
    # #     moving_average(error_array[1:250], 3),
    # #     lw = 1.5,
    # #     grid = true,
    # #     label = "MA LHS",
    # #     color = RGB(0.133, 0.533, 0.2),
    # #     foreground_color_legend = nothing,
    # #     background_color_legend = nothing,
    # #     xlabel = xlabel_name,
    # #     ylabel = ylabel_name,
    # # )

    # # # min_argument = argmin(error_array[1:250])
    # # # println(error_array[min_argument])
    # # # println("MA LHS")
    # # # println("duration_parameter = $(duration_parameter_array[min_argument])")
    # # # println("susceptibility_parameters = $([susceptibility_parameter_1_array[min_argument], susceptibility_parameter_2_array[min_argument], susceptibility_parameter_3_array[min_argument], susceptibility_parameter_4_array[min_argument], susceptibility_parameter_5_array[min_argument], susceptibility_parameter_6_array[min_argument], susceptibility_parameter_7_array[min_argument]])")
    # # # println("temperature_parameters = $(-[temperature_parameter_1_array[min_argument], temperature_parameter_2_array[min_argument], temperature_parameter_3_array[min_argument], temperature_parameter_4_array[min_argument], temperature_parameter_5_array[min_argument], temperature_parameter_6_array[min_argument], temperature_parameter_7_array[min_argument]])")
    # # # println("mean_immunity_durations = $([mean_immunity_duration_1_array[min_argument], mean_immunity_duration_2_array[min_argument], mean_immunity_duration_3_array[min_argument], mean_immunity_duration_4_array[min_argument], mean_immunity_duration_5_array[min_argument], mean_immunity_duration_6_array[min_argument], mean_immunity_duration_7_array[min_argument]])")
    # # # println("random_infection_probabilities = $([random_infection_probability_1_array[min_argument], random_infection_probability_2_array[min_argument], random_infection_probability_3_array[min_argument], random_infection_probability_4_array[min_argument]])")
    # # # println()
    # # # return

    # # duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "duration_parameter_array.csv"), ';', Float64, '\n')
    # # num_metropolis_runs = length(duration_parameter_array)
    # # error_array = zeros(Float64, num_metropolis_runs)

    # # susceptibility_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_1_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_2_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_3_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_4_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_5_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_6_array.csv"), ';', Float64, '\n')
    # # susceptibility_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_7_array.csv"), ';', Float64, '\n')

    # # temperature_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_1_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_2_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_3_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_4_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_5_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_6_array.csv"), ';', Float64, '\n')
    # # temperature_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_7_array.csv"), ';', Float64, '\n')

    # # mean_immunity_duration_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_1_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_2_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_3_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_4_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_5_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_6_array.csv"), ';', Float64, '\n')
    # # mean_immunity_duration_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_7_array.csv"), ';', Float64, '\n')

    # # random_infection_probability_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "random_infection_probability_1_array.csv"), ';', Float64, '\n')
    # # random_infection_probability_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "random_infection_probability_2_array.csv"), ';', Float64, '\n')
    # # random_infection_probability_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "random_infection_probability_3_array.csv"), ';', Float64, '\n')
    # # random_infection_probability_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "random_infection_probability_4_array.csv"), ';', Float64, '\n')

    # # open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_metropolis_manual.txt"),"r") do datafile
    # #     lines = eachline(datafile)
    # #     line_num = 1
    # #     for line in lines
    # #         if line_num == 1 || ((abs(susceptibility_parameter_1_array[line_num] - susceptibility_parameter_1_array[line_num - 1]) > 0.0001) && (abs(susceptibility_parameter_2_array[line_num] - susceptibility_parameter_2_array[line_num - 1]) > 0.0001))
    # #             error_array[line_num] = parse.(Float64, line)
    # #         else
    # #             error_array[line_num] = error_array[line_num - 1]
    # #         end
    # #         # error_array[line_num] = parse.(Float64, line)
    # #         line_num += 1
    # #     end
    # # end

    # # xlabel_name = "Step"
    # # ylabel_name = "RMSE"

    # # plot!(
    # #     1:250,
    # #     moving_average(error_array[1:250], 3),
    # #     lw = 1.5,
    # #     grid = true,
    # #     label = "MA manual",
    # #     color = RGB(0.667, 0.2, 0.467),
    # #     foreground_color_legend = nothing,
    # #     background_color_legend = nothing,
    # #     xlabel = xlabel_name,
    # #     ylabel = ylabel_name,
    # # )

    # # # min_argument = argmin(error_array[1:250])
    # # # println(error_array[min_argument])
    # # # println("MA manual")
    # # # println("duration_parameter = $(duration_parameter_array[min_argument])")
    # # # println("susceptibility_parameters = $([susceptibility_parameter_1_array[min_argument], susceptibility_parameter_2_array[min_argument], susceptibility_parameter_3_array[min_argument], susceptibility_parameter_4_array[min_argument], susceptibility_parameter_5_array[min_argument], susceptibility_parameter_6_array[min_argument], susceptibility_parameter_7_array[min_argument]])")
    # # # println("temperature_parameters = $(-[temperature_parameter_1_array[min_argument], temperature_parameter_2_array[min_argument], temperature_parameter_3_array[min_argument], temperature_parameter_4_array[min_argument], temperature_parameter_5_array[min_argument], temperature_parameter_6_array[min_argument], temperature_parameter_7_array[min_argument]])")
    # # # println("mean_immunity_durations = $([mean_immunity_duration_1_array[min_argument], mean_immunity_duration_2_array[min_argument], mean_immunity_duration_3_array[min_argument], mean_immunity_duration_4_array[min_argument], mean_immunity_duration_5_array[min_argument], mean_immunity_duration_6_array[min_argument], mean_immunity_duration_7_array[min_argument]])")
    # # # println("random_infection_probabilities = $([random_infection_probability_1_array[min_argument], random_infection_probability_2_array[min_argument], random_infection_probability_3_array[min_argument], random_infection_probability_4_array[min_argument]])")
    # # # println()
    # # # return

    # num_surrogate_runs = 200

    # incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_surrogate_runs)
    # duration_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    # susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    # temperature_parameters = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    # mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    # random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)

    # error_array = zeros(Float64, num_surrogate_runs)

    # xlabel_name = "Step"
    # if is_russian
    #     xlabel_name = "Шаг"
    # end
    # ylabel_name = "RMSE"

    # for method_run = 1:num_method_runs
    #     for i = 1:num_surrogate_runs
    #         incidence_arr[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate$(method_run)", "results_$(i).jld"))["observed_cases"]
    #         error_array[i] = sum((incidence_arr[i] - num_infected_age_groups_viruses).^2)
    #         duration_parameter[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate$(method_run)", "results_$(i).jld"))["duration_parameter"]
    #         susceptibility_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate$(method_run)", "results_$(i).jld"))["susceptibility_parameters"]
    #         temperature_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate$(method_run)", "results_$(i).jld"))["temperature_parameters"]
    #         mean_immunity_durations[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate$(method_run)", "results_$(i).jld"))["mean_immunity_durations"]
    #         random_infection_probabilities[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate$(method_run)", "results_$(i).jld"))["random_infection_probabilities"]
    #     end
    #     minimum_step_arr[method_run] = argmin(error_array)
    #     minimum_arr[method_run] = minimum(error_array)
    # end

    # # println("SM minimum method run = $(argmin(minimum_arr))")
    # # println("SM min error = $(sqrt.(minimum(minimum_arr) / num_error_points))")
    # # println("SM mean error = $(sqrt.(mean(minimum_arr) / num_error_points))")
    # # println("SM min step = $(minimum_step_arr[argmin(minimum_arr)])")
    # # println("SM mean step = $(mean(minimum_step_arr))")
    # # return

    # median_arg = 0
    # for i = 1:num_method_runs
    #     if abs(minimum_arr[i] - median(minimum_arr)) < 0.00001
    #         median_arg = i
    #         break
    #     end
    # end
    # median_arg = argmin(minimum_arr)

    # for i = 1:num_surrogate_runs
    #     incidence_arr[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate$(median_arg)", "results_$(i).jld"))["observed_cases"]
    #     error_array[i] = sum((incidence_arr[i] - num_infected_age_groups_viruses).^2)
    #     duration_parameter[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate$(median_arg)", "results_$(i).jld"))["duration_parameter"]
    #     susceptibility_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate$(median_arg)", "results_$(i).jld"))["susceptibility_parameters"]
    #     temperature_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate$(median_arg)", "results_$(i).jld"))["temperature_parameters"]
    #     mean_immunity_durations[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate$(median_arg)", "results_$(i).jld"))["mean_immunity_durations"]
    #     random_infection_probabilities[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate$(median_arg)", "results_$(i).jld"))["random_infection_probabilities"]
    # end

    # plot!(
    #     1:num_surrogate_runs,
    #     # moving_average(sqrt.(error_array / num_error_points), 3),
    #     sqrt.(error_array / num_error_points),
    #     lw = 1.5,
    #     grid = true,
    #     label = "SM",
    #     color = RGB(0.133, 0.533, 0.2),
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )

    # # min_argument = argmin(error_array)
    # # println(min_argument)
    # # println(sqrt.(error_array[min_argument] / num_error_points))
    # # println("SM 1000")
    # # println("duration_parameter = $(duration_parameter[min_argument])")
    # # println("susceptibility_parameters = $(susceptibility_parameters[min_argument])")
    # # println("temperature_parameters = $(-temperature_parameters[min_argument])")
    # # println("mean_immunity_durations = $(mean_immunity_durations[min_argument])")
    # # println("random_infection_probabilities = $(random_infection_probabilities[min_argument])")
    # # println()
    # # return





    # # num_surrogate_runs = 200

    # # incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_surrogate_runs)
    # # duration_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    # # susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    # # temperature_parameters = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    # # mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    # # random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)

    # # error_array = zeros(Float64, num_surrogate_runs)

    # # xlabel_name = "Step"
    # # ylabel_name = "RMSE"

    # # for method_run = 1:1
    # #     for i = 1:num_surrogate_runs
    # #         incidence_arr[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate_lhs_10_$(method_run)", "results_$(i).jld"))["observed_cases"]
    # #         error_array[i] = sum((incidence_arr[i] - num_infected_age_groups_viruses).^2)
    # #         duration_parameter[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate_lhs_10_$(method_run)", "results_$(i).jld"))["duration_parameter"]
    # #         susceptibility_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate_lhs_10_$(method_run)", "results_$(i).jld"))["susceptibility_parameters"]
    # #         temperature_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate_lhs_10_$(method_run)", "results_$(i).jld"))["temperature_parameters"]
    # #         mean_immunity_durations[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate_lhs_10_$(method_run)", "results_$(i).jld"))["mean_immunity_durations"]
    # #         random_infection_probabilities[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate_lhs_10_$(method_run)", "results_$(i).jld"))["random_infection_probabilities"]

    # #         if isnan(duration_parameter[i])
    # #             println("duration_parameter")
    # #             println(error_array[i])
    # #             println(method_run)
    # #         end
    # #         for v = 1:7
    # #             if isnan(susceptibility_parameters[i][v])
    # #                 println("susceptibility_parameters")
    # #                 println(error_array[i])
    # #                 println(method_run)
    # #             end
    # #             if isnan(temperature_parameters[i][v])
    # #                 println("temperature_parameters")
    # #                 println(error_array[i])
    # #                 println(method_run)
    # #             end
    # #             if isnan(mean_immunity_durations[i][v])
    # #                 println("mean_immunity_durations")
    # #                 println(error_array[i])
    # #                 println(method_run)
    # #             end
    # #         end
    # #         for a = 1:4
    # #             if isnan(random_infection_probabilities[i][a])
    # #                 println("random_infection_probabilities")
    # #                 println(error_array[i])
    # #                 println(method_run)
    # #             end
    # #         end
    # #     end
    # #     minimum_step_arr[method_run] = argmin(error_array)
    # #     minimum_arr[method_run] = minimum(error_array)
    # # end

    # # # println("SM minimum method run = $(argmin(minimum_arr))")
    # # # println("SM min error = $(minimum(minimum_arr))")
    # # # println("SM mean error = $(mean(minimum_arr))")
    # # # println("SM min step = $(minimum(minimum_step_arr))")
    # # # println("SM mean step = $(mean(minimum_step_arr))")
    # # # return

    # # median_arg = 0
    # # for i = 1:num_method_runs
    # #     if abs(minimum_arr[i] - median(minimum_arr)) < 0.00001
    # #         median_arg = i
    # #         break
    # #     end
    # # end

    # # for i = 1:num_surrogate_runs
    # #     incidence_arr[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate_lhs_10_$(median_arg)", "results_$(i).jld"))["observed_cases"]
    # #     error_array[i] = sum((incidence_arr[i] - num_infected_age_groups_viruses).^2)
    # #     duration_parameter[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate_lhs_10_$(median_arg)", "results_$(i).jld"))["duration_parameter"]
    # #     susceptibility_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate_lhs_10_$(median_arg)", "results_$(i).jld"))["susceptibility_parameters"]
    # #     temperature_parameters[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate_lhs_10_$(median_arg)", "results_$(i).jld"))["temperature_parameters"]
    # #     mean_immunity_durations[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate_lhs_10_$(median_arg)", "results_$(i).jld"))["mean_immunity_durations"]
    # #     random_infection_probabilities[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "surrogate_lhs_10_$(median_arg)", "results_$(i).jld"))["random_infection_probabilities"]
    # # end

    # # plot!(
    # #     1:num_surrogate_runs,
    # #     # moving_average(sqrt.(error_array / num_error_points), 3),
    # #     sqrt.(error_array / num_error_points),
    # #     lw = 1.5,
    # #     grid = true,
    # #     label = "SM 10",
    # #     color = RGB(0.4, 0.8, 0.933),
    # #     foreground_color_legend = nothing,
    # #     background_color_legend = nothing,
    # #     xlabel = xlabel_name,
    # #     ylabel = ylabel_name,
    # # )

    # # min_argument = argmin(error_array)
    # # println(min_argument)
    # # println(sqrt.(error_array[min_argument] / num_error_points))
    # # println("SM 10")
    # # println("duration_parameter = $(duration_parameter[min_argument])")
    # # println("susceptibility_parameters = $(susceptibility_parameters[min_argument])")
    # # println("temperature_parameters = $(-temperature_parameters[min_argument])")
    # # println("mean_immunity_durations = $(mean_immunity_durations[min_argument])")
    # # println("random_infection_probabilities = $(random_infection_probabilities[min_argument])")
    # # println()
    # # return



    # num_swarm_runs = 20
    # num_particles = 10

    # incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_swarm_runs)
    # incidence_arr_temp = Array{Array{Float64, 3}, 1}(undef, num_particles)
    # error_array = zeros(Float64, num_swarm_runs * num_particles)

    # duration_parameter = Array{Float64, 1}(undef, num_swarm_runs * num_particles)
    # susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_swarm_runs * num_particles)
    # temperature_parameters = Array{Vector{Float64}, 1}(undef, num_swarm_runs * num_particles)
    # mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_swarm_runs * num_particles)
    # random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_swarm_runs * num_particles)

    # # error_array = zeros(Float64, num_swarm_runs * num_particles + num_particles)

    # # duration_parameter = Array{Float64, 1}(undef, num_swarm_runs * num_particles + num_particles)
    # # susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_swarm_runs * num_particles + num_particles)
    # # temperature_parameters = Array{Vector{Float64}, 1}(undef, num_swarm_runs * num_particles + num_particles)
    # # mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_swarm_runs * num_particles + num_particles)
    # # random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_swarm_runs * num_particles + num_particles)

    # error_arr_temp = zeros(Float64, num_particles)
    # duration_parameter_temp = zeros(Float64, num_particles)
    # susceptibility_parameters_temp = Array{Vector{Float64}, 1}(undef, num_particles)
    # temperature_parameters_temp = Array{Vector{Float64}, 1}(undef, num_particles)
    # mean_immunity_durations_temp = Array{Vector{Float64}, 1}(undef, num_particles)
    # random_infection_probabilities_temp = Array{Vector{Float64}, 1}(undef, num_particles)

    # xlabel_name = "Step"
    # if is_russian
    #     xlabel_name = "Шаг"
    # end
    # ylabel_name = "RMSE"

    # # for i = 1:num_particles
    # #     temp = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(0)", "results_$(i).jld"))["observed_cases"]
    # #     error_arr_temp[i] = sum((temp - num_infected_age_groups_viruses).^2)
        
    # #     duration_parameter_temp[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(0)", "results_$(i).jld"))["duration_parameter"]
    # #     susceptibility_parameters_temp[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(0)", "results_$(i).jld"))["susceptibility_parameters"]
    # #     temperature_parameters_temp[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(0)", "results_$(i).jld"))["temperature_parameters"]
    # #     mean_immunity_durations_temp[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(0)", "results_$(i).jld"))["mean_immunity_durations"]
    # #     random_infection_probabilities_temp[i] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(0)", "results_$(i).jld"))["random_infection_probabilities"]
    # # end

    # # for i = 1:num_particles
    # #     error_array[i] = minimum(error_arr_temp)
    # #     min_arg = argmin(error_arr_temp)
    # #     duration_parameter[i] = duration_parameter_temp[min_arg]
    # #     susceptibility_parameters[i] = susceptibility_parameters_temp[min_arg]
    # #     temperature_parameters[i] = temperature_parameters_temp[min_arg]
    # #     mean_immunity_durations[i] = mean_immunity_durations_temp[min_arg]
    # #     random_infection_probabilities[i] = random_infection_probabilities_temp[min_arg]
    # # end

    # for method_run = 1:num_method_runs
    #     for i = 1:num_swarm_runs
    #         for j = 1:num_particles
    #             temp = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm$(method_run)", "$(j)", "results_$(i).jld"))["observed_cases"]
    #             error_arr_temp[j] = sum((temp - num_infected_age_groups_viruses).^2)
                
    #             duration_parameter_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm$(method_run)", "$(j)", "results_$(i).jld"))["duration_parameter"]
    #             susceptibility_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm$(method_run)", "$(j)", "results_$(i).jld"))["susceptibility_parameters"]
    #             temperature_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm$(method_run)", "$(j)", "results_$(i).jld"))["temperature_parameters"]
    #             mean_immunity_durations_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm$(method_run)", "$(j)", "results_$(i).jld"))["mean_immunity_durations"]
    #             random_infection_probabilities_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm$(method_run)", "$(j)", "results_$(i).jld"))["random_infection_probabilities"]
    #         end
    #         # for j = 1:num_particles
    #         #     error_array[num_particles + (i - 1) * num_particles + j] = minimum(error_arr_temp)
    #         #     min_arg = argmin(error_arr_temp)
    #         #     duration_parameter[num_particles + (i - 1) * num_particles + j] = duration_parameter_temp[min_arg]
    #         #     susceptibility_parameters[num_particles + (i - 1) * num_particles + j] = susceptibility_parameters_temp[min_arg]
    #         #     temperature_parameters[num_particles + (i - 1) * num_particles + j] = temperature_parameters_temp[min_arg]
    #         #     mean_immunity_durations[num_particles + (i - 1) * num_particles + j] = mean_immunity_durations_temp[min_arg]
    #         #     random_infection_probabilities[num_particles + (i - 1) * num_particles + j] = random_infection_probabilities_temp[min_arg]
    #         # end
    #         for j = 1:num_particles
    #             error_array[(i - 1) * num_particles + j] = minimum(error_arr_temp)
    #             min_arg = argmin(error_arr_temp)
    #             duration_parameter[(i - 1) * num_particles + j] = duration_parameter_temp[min_arg]
    #             susceptibility_parameters[(i - 1) * num_particles + j] = susceptibility_parameters_temp[min_arg]
    #             temperature_parameters[(i - 1) * num_particles + j] = temperature_parameters_temp[min_arg]
    #             mean_immunity_durations[(i - 1) * num_particles + j] = mean_immunity_durations_temp[min_arg]
    #             random_infection_probabilities[(i - 1) * num_particles + j] = random_infection_probabilities_temp[min_arg]
    #         end
    #     end
    #     minimum_step_arr[method_run] = argmin(error_array)
    #     minimum_arr[method_run] = minimum(error_array)
    #     # minimum_arr[method_run] = error_array[1]
    # end

    # # println("PSO minimum method run = $(argmin(minimum_arr))")
    # # println("PSO min error = $(sqrt.(minimum(minimum_arr) / num_error_points))")
    # # println("PSO mean error = $(sqrt.(mean(minimum_arr) / num_error_points))")
    # # println("PSO min step = $(minimum_step_arr[argmin(minimum_arr)])")
    # # println("PSO mean step = $(mean(minimum_step_arr))")
    # # return

    # median_arg = 0
    # for i = 1:num_method_runs
    #     if abs(minimum_arr[i] - median(minimum_arr)) < 0.00001
    #         median_arg = i
    #         break
    #     end
    # end
    # median_arg = argmin(minimum_arr)

    # for i = 1:num_swarm_runs
    #     for j = 1:num_particles
    #         temp = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm$(median_arg)", "$(j)", "results_$(i).jld"))["observed_cases"]
    #         error_arr_temp[j] = sum((temp - num_infected_age_groups_viruses).^2)
            
    #         duration_parameter_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm$(median_arg)", "$(j)", "results_$(i).jld"))["duration_parameter"]
    #         susceptibility_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm$(median_arg)", "$(j)", "results_$(i).jld"))["susceptibility_parameters"]
    #         temperature_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm$(median_arg)", "$(j)", "results_$(i).jld"))["temperature_parameters"]
    #         mean_immunity_durations_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm$(median_arg)", "$(j)", "results_$(i).jld"))["mean_immunity_durations"]
    #         random_infection_probabilities_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm$(median_arg)", "$(j)", "results_$(i).jld"))["random_infection_probabilities"]
    #     end
    #     for j = 1:num_particles
    #         error_array[(i - 1) * num_particles + j] = minimum(error_arr_temp)
    #         min_arg = argmin(error_arr_temp)
    #         duration_parameter[(i - 1) * num_particles + j] = duration_parameter_temp[min_arg]
    #         susceptibility_parameters[(i - 1) * num_particles + j] = susceptibility_parameters_temp[min_arg]
    #         temperature_parameters[(i - 1) * num_particles + j] = temperature_parameters_temp[min_arg]
    #         mean_immunity_durations[(i - 1) * num_particles + j] = mean_immunity_durations_temp[min_arg]
    #         random_infection_probabilities[(i - 1) * num_particles + j] = random_infection_probabilities_temp[min_arg]
    #     end
    # end

    # plot!(
    #     # 1:(num_swarm_runs * num_particles + num_particles),
    #     # moving_average(sqrt.(error_array[1:(num_swarm_runs * num_particles + num_particles)] / num_error_points), 3),
    #     1:(num_swarm_runs * num_particles),
    #     moving_average(sqrt.(error_array[1:(num_swarm_runs * num_particles)] / num_error_points), 3),
    #     lw = 1.5,
    #     grid = true,
    #     label = "PSO",
    #     legend = (0.74, 0.98),
    #     color = RGB(0.667, 0.2, 0.467),
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )

    # # min_argument = argmin(error_array)
    # # println(min_argument)
    # # println(sqrt.(error_array[min_argument] / num_error_points))
    # # println("PSO")
    # # println("duration_parameter = $(duration_parameter[min_argument])")
    # # println("susceptibility_parameters = $(susceptibility_parameters[min_argument])")
    # # println("temperature_parameters = $(temperature_parameters[min_argument])")
    # # println("mean_immunity_durations = $(mean_immunity_durations[min_argument])")
    # # println("random_infection_probabilities = $(random_infection_probabilities[min_argument])")
    # # println()
    # # return

    num_ga_runs = 20
    population_size = 10

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_ga_runs)
    incidence_arr_temp = Array{Array{Float64, 3}, 1}(undef, population_size)
    error_array = zeros(Float64, num_ga_runs * population_size)

    duration_parameter = Array{Float64, 1}(undef, num_ga_runs * population_size)
    susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_ga_runs * population_size)
    temperature_parameters = Array{Vector{Float64}, 1}(undef, num_ga_runs * population_size)
    mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_ga_runs * population_size)
    random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_ga_runs * population_size)

    # error_array = zeros(Float64, num_ga_runs * population_size + population_size)

    # duration_parameter = Array{Float64, 1}(undef, num_ga_runs * population_size + population_size)
    # susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_ga_runs * population_size + population_size)
    # temperature_parameters = Array{Vector{Float64}, 1}(undef, num_ga_runs * population_size + population_size)
    # mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_ga_runs * population_size + population_size)
    # random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_ga_runs * population_size + population_size)

    error_arr_temp = zeros(Float64, population_size)
    duration_parameter_temp = zeros(Float64, population_size)
    susceptibility_parameters_temp = Array{Vector{Float64}, 1}(undef, population_size)
    temperature_parameters_temp = Array{Vector{Float64}, 1}(undef, population_size)
    mean_immunity_durations_temp = Array{Vector{Float64}, 1}(undef, population_size)
    random_infection_probabilities_temp = Array{Vector{Float64}, 1}(undef, population_size)

    xlabel_name = "Step"
    if is_russian
        xlabel_name = "Шаг"
    end
    ylabel_name = "RMSE"

    # Based on terminal
    # error_array[1:10] .= minimum([6.30210518658725e11, 1.0966705128602166e12, 1.6766645068768096e12, 8.9942104205945e11, 5.838094955771829e11, 1.0816500815351372e11, 5.72517658122642e11, 3.7805229226164575e12, 2.0887205875670667e12, 3.656786898287941e11])
    error_array[1:10] .= minimum([1.0816500815351372e11, 3.656786898287941e11, 3.733573365444632e11, 3.9988894791781726e11, 5.2323011537884064e11, 5.72517658122642e11, 5.838094955771829e11, 6.128556882072703e11, 6.30210518658725e11, 6.302696832629246e11])
    error_array[11:20] .= minimum([1.0816500815351372e11, 1.6841997880269012e11, 3.491060454232533e11, 3.656786898287941e11, 3.733573365444632e11, 3.9060909609286523e11, 3.9754062405253375e11, 3.9988894791781726e11, 4.211930249419649e11, 5.2323011537884064e11])
    error_array[21:30] .= minimum([9.488569778184554e10, 1.0816500815351372e11, 1.100396102488978e11, 1.2036985438218098e11, 1.4792404433045035e11, 1.6841997880269012e11, 1.8498859804872583e11, 2.631847345355784e11, 3.491060454232533e11, 3.5857824489398254e11])
    error_array[31:40] .= minimum([6.8479550914017845e10, 9.488569778184554e10, 1.0654656720642271e11, 1.0816500815351372e11, 1.100396102488978e11, 1.2036985438218098e11, 1.2606421804525687e11, 1.4792404433045035e11, 1.668526184837548e11, 1.6841997880269012e11])
    error_array[41:50] .= minimum([6.8086942046581055e10, 6.8479550914017845e10, 8.724877346521268e10, 9.488569778184554e10, 1.0242608801156137e11, 1.0654656720642271e11, 1.0816500815351372e11, 1.0875739966260387e11, 1.100396102488978e11, 1.2036985438218098e11])
    error_array[51:60] .= minimum([6.598850435957584e10, 6.8086942046581055e10, 6.8301748081802864e10, 6.8479550914017845e10, 6.981271236030772e10, 7.328787190444159e10, 8.724877346521268e10, 9.410165448427156e10, 9.488569778184554e10, 1.0164924945013548e11])
    error_array[61:70] .= minimum([2.6165470215455376e10, 2.7243396262421993e10, 3.0423571300297157e10, 5.5738599494616295e10, 6.495731479501268e10, 6.598850435957584e10, 6.6835099532975555e10, 6.762473262794898e10, 6.8086942046581055e10, 6.8301748081802864e10])
    error_array[71:80] .= minimum([2.4939036354050728e10, 2.6165470215455376e10, 2.6466579362125e10, 2.7243396262421993e10, 2.7290921753724407e10, 3.0423571300297157e10, 3.0472129375050934e10, 3.0548328470274376e10, 3.830158631161062e10, 5.559375834181238e10])
    error_array[81:90] .= minimum([1.9771464062399506e10, 2.3426495077744617e10, 2.4325806696264534e10, 2.4461818341261124e10, 2.4939036354050728e10, 2.6165470215455376e10, 2.6353329071440845e10, 2.6466579362125e10, 2.6920934409881176e10, 2.7243396262421993e10])
    error_array[91:100] .= minimum([1.777691512618701e10, 1.9771464062399506e10, 2.0592755075921627e10, 2.3426495077744617e10, 2.3524167410284386e10, 2.4325806696264534e10, 2.4461818341261124e10, 2.4939036354050728e10, 2.5459366384006634e10, 2.6165470215455376e10])
    error_array[101:110] .= minimum([1.510148375894304e10, 1.7718290292893658e10, 1.777691512618701e10, 1.924653072474791e10, 1.9771464062399506e10, 2.016296109062252e10, 2.0592755075921627e10, 2.3257887086155506e10, 2.3426495077744617e10, 2.3524167410284386e10])
    error_array[111:120] .= minimum([1.1441471132533207e10, 1.2884221517821306e10, 1.510148375894304e10, 1.7457098756256214e10, 1.749245561658748e10, 1.7718290292893658e10, 1.777691512618701e10, 1.7854606676610302e10, 1.924653072474791e10, 1.9771464062399506e10])
    error_array[121:130] .= minimum([1.1441471132533207e10, 1.2884221517821306e10, 1.3800548855325788e10, 1.4301470984096207e10, 1.481633457711404e10, 1.510148375894304e10, 1.7184438373015003e10, 1.7457098756256214e10, 1.749245561658748e10, 1.7533005954105415e10])
    error_array[131:140] .= minimum([1.1441471132533207e10, 1.2884221517821306e10, 1.308820572607981e10, 1.3498358776706427e10, 1.3800548855325788e10, 1.4301470984096207e10, 1.481633457711404e10, 1.510148375894304e10, 1.7144064762466187e10, 1.7184438373015003e10])
    error_array[141:150] .= minimum([1.1441471132533207e10, 1.2813528516831972e10, 1.2884221517821306e10, 1.308820572607981e10, 1.3250873123871252e10, 1.3254085446271278e10, 1.330422920892449e10, 1.336008748267909e10, 1.3498358776706427e10, 1.3714906405558125e10])
    error_array[151:160] .= minimum([9.940803418526348e9, 1.1441471132533207e10, 1.2047389701041405e10, 1.2813528516831972e10, 1.2884221517821306e10, 1.289060267394796e10, 1.2962152448423353e10, 1.2991559984724295e10, 1.308820572607981e10, 1.3129962821474245e10])
    error_array[161:170] .= minimum([9.940803418526348e9, 1.0107558639332083e10, 1.1229098009836594e10, 1.1441471132533207e10, 1.2047389701041405e10, 1.2187117155027351e10, 1.2813528516831972e10, 1.2884221517821306e10, 1.289060267394796e10, 1.2962152448423353e10])
    error_array[171:180] .= minimum([9.940803418526348e9, 1.0107558639332083e10, 1.0473484966382938e10, 1.1038693288496357e10, 1.1229098009836594e10, 1.1356773908044268e10, 1.1441471132533207e10, 1.2047389701041405e10, 1.2187117155027351e10, 1.2580084895949009e10])
    error_array[181:190] .= minimum([9.940803418526348e9, 1.0107558639332083e10, 1.0473484966382938e10, 1.0533611664158937e10, 1.058218586527184e10, 1.084823528918084e10, 1.0880285683864504e10, 1.1038693288496357e10, 1.119957792039363e10, 1.1229098009836594e10])
    error_array[191:200] .= 9.223042358989534e9

    minimum_step_arr[1] = argmin(error_array)
    minimum_arr[1] = minimum(error_array)

    # duration_parameter_temp[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "20", "results_$(1).jld"))["duration_parameter"]
    # susceptibility_parameters_temp[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "20", "results_$(1).jld"))["susceptibility_parameters"]
    # temperature_parameters_temp[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "20", "results_$(1).jld"))["temperature_parameters"]
    # mean_immunity_durations_temp[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "20", "results_$(1).jld"))["mean_immunity_durations"]
    # random_infection_probabilities_temp[1] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "20", "results_$(1).jld"))["random_infection_probabilities"]

    # println(duration_parameter_temp[1])
    # println(susceptibility_parameters_temp[1])
    # println(temperature_parameters_temp[1])
    # println(mean_immunity_durations_temp[1])
    # println(random_infection_probabilities_temp[1])

    # 0.1
    # [1.4780767410390072, 6.791460231993848, 4.3324326971968095, 4.488273220963466, 5.0357976276604735, 5.5775535137457375, 3.926215719180812]
    # [-0.78, -0.3512240165328047, -0.0712614184466791, -0.010000000000000009, -0.2070191242631642, -0.2820830210066421, -0.5892266222606137]
    # [154.58424547538954, 282.70343221653434, 80.50441544625477, 151.77744238754525, 243.495255851072, 93.57285276981995, 210.80352028917065]
    # [0.0011505796654931457, 0.0008643362616252045, 0.00030854237718053136, 6.8638947083754706e-6]

    for j = 1:num_method_runs
        for i = 1:population_size
            temp = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga$(j)", "0", "results_$(i).jld"))["observed_cases"]
            error_arr_temp[i] = sum((temp - num_infected_age_groups_viruses).^2)
        end
        error_array[j] = minimum(error_arr_temp[1:population_size])
    end
    println(sqrt(mean(error_array[1:num_method_runs]) / num_error_points))
    return

    for method_run = 2:num_method_runs
        for i = 1:num_ga_runs
            for j = 1:population_size
                temp = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga$(method_run)", "$(i)", "results_$(j).jld"))["observed_cases"]
                error_arr_temp[j] = sum((temp - num_infected_age_groups_viruses).^2)
                
                duration_parameter_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga$(method_run)", "$(i)", "results_$(j).jld"))["duration_parameter"]
                susceptibility_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga$(method_run)", "$(i)", "results_$(j).jld"))["susceptibility_parameters"]
                temperature_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga$(method_run)", "$(i)", "results_$(j).jld"))["temperature_parameters"]
                mean_immunity_durations_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga$(method_run)", "$(i)", "results_$(j).jld"))["mean_immunity_durations"]
                random_infection_probabilities_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga$(method_run)", "$(i)", "results_$(j).jld"))["random_infection_probabilities"]
            end
            for j = 1:num_particles
                error_array[(i - 1) * num_particles + j] = minimum(error_arr_temp)
                min_arg = argmin(error_arr_temp)
                duration_parameter[(i - 1) * num_particles + j] = duration_parameter_temp[min_arg]
                susceptibility_parameters[(i - 1) * num_particles + j] = susceptibility_parameters_temp[min_arg]
                temperature_parameters[(i - 1) * num_particles + j] = temperature_parameters_temp[min_arg]
                mean_immunity_durations[(i - 1) * num_particles + j] = mean_immunity_durations_temp[min_arg]
                random_infection_probabilities[(i - 1) * num_particles + j] = random_infection_probabilities_temp[min_arg]
            end
        end
        minimum_step_arr[method_run] = argmin(error_array)
        minimum_arr[method_run] = minimum(error_array)
        # minimum_arr[method_run] = error_array[1]
    end

    # println("GA minimum method run = $(argmin(minimum_arr))")
    # println("GA min error = $(minimum(minimum_arr))")
    # println("GA mean error = $(mean(minimum_arr))")
    # println("GA min step = $(minimum_step_arr[argmin(minimum_arr)])")
    # println("GA mean step = $(mean(minimum_step_arr))")
    # return

    median_arg = 0
    for i = 1:num_method_runs
        if abs(minimum_arr[i] - median(minimum_arr)) < 0.00001
            median_arg = i
            break
        end
    end
    median_arg = argmin(minimum_arr)

    if median_arg > 1
        for i = 1:num_ga_runs
            for j = 1:population_size
                temp = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga$(median_arg)", "$(i)", "results_$(j).jld"))["observed_cases"]
                error_arr_temp[j] = sum((temp - num_infected_age_groups_viruses).^2)
                
                duration_parameter_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga$(median_arg)", "$(i)", "results_$(j).jld"))["duration_parameter"]
                susceptibility_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga$(median_arg)", "$(i)", "results_$(j).jld"))["susceptibility_parameters"]
                temperature_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga$(median_arg)", "$(i)", "results_$(j).jld"))["temperature_parameters"]
                mean_immunity_durations_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga$(median_arg)", "$(i)", "results_$(j).jld"))["mean_immunity_durations"]
                random_infection_probabilities_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga$(median_arg)", "$(i)", "results_$(j).jld"))["random_infection_probabilities"]
            end
            for j = 1:num_particles
                error_array[(i - 1) * num_particles + j] = minimum(error_arr_temp)
                min_arg = argmin(error_arr_temp)
                duration_parameter[(i - 1) * num_particles + j] = duration_parameter_temp[min_arg]
                susceptibility_parameters[(i - 1) * num_particles + j] = susceptibility_parameters_temp[min_arg]
                temperature_parameters[(i - 1) * num_particles + j] = temperature_parameters_temp[min_arg]
                mean_immunity_durations[(i - 1) * num_particles + j] = mean_immunity_durations_temp[min_arg]
                random_infection_probabilities[(i - 1) * num_particles + j] = random_infection_probabilities_temp[min_arg]
            end
        end
    else
        error_array[1:10] .= minimum([1.0816500815351372e11, 3.656786898287941e11, 3.733573365444632e11, 3.9988894791781726e11, 5.2323011537884064e11, 5.72517658122642e11, 5.838094955771829e11, 6.128556882072703e11, 6.30210518658725e11, 6.302696832629246e11])
        error_array[11:20] .= minimum([1.0816500815351372e11, 1.6841997880269012e11, 3.491060454232533e11, 3.656786898287941e11, 3.733573365444632e11, 3.9060909609286523e11, 3.9754062405253375e11, 3.9988894791781726e11, 4.211930249419649e11, 5.2323011537884064e11])
        error_array[21:30] .= minimum([9.488569778184554e10, 1.0816500815351372e11, 1.100396102488978e11, 1.2036985438218098e11, 1.4792404433045035e11, 1.6841997880269012e11, 1.8498859804872583e11, 2.631847345355784e11, 3.491060454232533e11, 3.5857824489398254e11])
        error_array[31:40] .= minimum([6.8479550914017845e10, 9.488569778184554e10, 1.0654656720642271e11, 1.0816500815351372e11, 1.100396102488978e11, 1.2036985438218098e11, 1.2606421804525687e11, 1.4792404433045035e11, 1.668526184837548e11, 1.6841997880269012e11])
        error_array[41:50] .= minimum([6.8086942046581055e10, 6.8479550914017845e10, 8.724877346521268e10, 9.488569778184554e10, 1.0242608801156137e11, 1.0654656720642271e11, 1.0816500815351372e11, 1.0875739966260387e11, 1.100396102488978e11, 1.2036985438218098e11])
        error_array[51:60] .= minimum([6.598850435957584e10, 6.8086942046581055e10, 6.8301748081802864e10, 6.8479550914017845e10, 6.981271236030772e10, 7.328787190444159e10, 8.724877346521268e10, 9.410165448427156e10, 9.488569778184554e10, 1.0164924945013548e11])
        error_array[61:70] .= minimum([2.6165470215455376e10, 2.7243396262421993e10, 3.0423571300297157e10, 5.5738599494616295e10, 6.495731479501268e10, 6.598850435957584e10, 6.6835099532975555e10, 6.762473262794898e10, 6.8086942046581055e10, 6.8301748081802864e10])
        error_array[71:80] .= minimum([2.4939036354050728e10, 2.6165470215455376e10, 2.6466579362125e10, 2.7243396262421993e10, 2.7290921753724407e10, 3.0423571300297157e10, 3.0472129375050934e10, 3.0548328470274376e10, 3.830158631161062e10, 5.559375834181238e10])
        error_array[81:90] .= minimum([1.9771464062399506e10, 2.3426495077744617e10, 2.4325806696264534e10, 2.4461818341261124e10, 2.4939036354050728e10, 2.6165470215455376e10, 2.6353329071440845e10, 2.6466579362125e10, 2.6920934409881176e10, 2.7243396262421993e10])
        error_array[91:100] .= minimum([1.777691512618701e10, 1.9771464062399506e10, 2.0592755075921627e10, 2.3426495077744617e10, 2.3524167410284386e10, 2.4325806696264534e10, 2.4461818341261124e10, 2.4939036354050728e10, 2.5459366384006634e10, 2.6165470215455376e10])
        error_array[101:110] .= minimum([1.510148375894304e10, 1.7718290292893658e10, 1.777691512618701e10, 1.924653072474791e10, 1.9771464062399506e10, 2.016296109062252e10, 2.0592755075921627e10, 2.3257887086155506e10, 2.3426495077744617e10, 2.3524167410284386e10])
        error_array[111:120] .= minimum([1.1441471132533207e10, 1.2884221517821306e10, 1.510148375894304e10, 1.7457098756256214e10, 1.749245561658748e10, 1.7718290292893658e10, 1.777691512618701e10, 1.7854606676610302e10, 1.924653072474791e10, 1.9771464062399506e10])
        error_array[121:130] .= minimum([1.1441471132533207e10, 1.2884221517821306e10, 1.3800548855325788e10, 1.4301470984096207e10, 1.481633457711404e10, 1.510148375894304e10, 1.7184438373015003e10, 1.7457098756256214e10, 1.749245561658748e10, 1.7533005954105415e10])
        error_array[131:140] .= minimum([1.1441471132533207e10, 1.2884221517821306e10, 1.308820572607981e10, 1.3498358776706427e10, 1.3800548855325788e10, 1.4301470984096207e10, 1.481633457711404e10, 1.510148375894304e10, 1.7144064762466187e10, 1.7184438373015003e10])
        error_array[141:150] .= minimum([1.1441471132533207e10, 1.2813528516831972e10, 1.2884221517821306e10, 1.308820572607981e10, 1.3250873123871252e10, 1.3254085446271278e10, 1.330422920892449e10, 1.336008748267909e10, 1.3498358776706427e10, 1.3714906405558125e10])
        error_array[151:160] .= minimum([9.940803418526348e9, 1.1441471132533207e10, 1.2047389701041405e10, 1.2813528516831972e10, 1.2884221517821306e10, 1.289060267394796e10, 1.2962152448423353e10, 1.2991559984724295e10, 1.308820572607981e10, 1.3129962821474245e10])
        error_array[161:170] .= minimum([9.940803418526348e9, 1.0107558639332083e10, 1.1229098009836594e10, 1.1441471132533207e10, 1.2047389701041405e10, 1.2187117155027351e10, 1.2813528516831972e10, 1.2884221517821306e10, 1.289060267394796e10, 1.2962152448423353e10])
        error_array[171:180] .= minimum([9.940803418526348e9, 1.0107558639332083e10, 1.0473484966382938e10, 1.1038693288496357e10, 1.1229098009836594e10, 1.1356773908044268e10, 1.1441471132533207e10, 1.2047389701041405e10, 1.2187117155027351e10, 1.2580084895949009e10])
        error_array[181:190] .= minimum([9.940803418526348e9, 1.0107558639332083e10, 1.0473484966382938e10, 1.0533611664158937e10, 1.058218586527184e10, 1.084823528918084e10, 1.0880285683864504e10, 1.1038693288496357e10, 1.119957792039363e10, 1.1229098009836594e10])
        error_array[191:200] .= 9.223042358989534e9
    end

    plot!(
        # 1:(num_ga_runs * population_size + population_size),
        # moving_average(sqrt.(error_array[1:(num_ga_runs * population_size + population_size)] / num_error_points), 3),
        1:(num_ga_runs * population_size),
        moving_average(sqrt.(error_array[1:(num_ga_runs * population_size)] / num_error_points), 3),
        lw = 1.5,
        grid = true,
        label = "GA",
        legend = (0.74, 0.98),
        color = RGB(0.8, 0.733, 0.267),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # min_argument = argmin(error_array[1:200])
    # println(min_argument)
    # println(sqrt.(error_array[min_argument] / num_error_points))
    # println("GA")
    # println("duration_parameter = $(duration_parameter[min_argument])")
    # println("susceptibility_parameters = $(susceptibility_parameters[min_argument])")
    # println("temperature_parameters = $(temperature_parameters[min_argument])")
    # println("mean_immunity_durations = $(mean_immunity_durations[min_argument])")
    # println("random_infection_probabilities = $(random_infection_probabilities[min_argument])")
    # println()
    # return

    # !!!!!!!!!!!!!!!!!
    num_method_runs = 2

    num_cgo_runs = 5
    seeds_size = 10

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_cgo_runs)
    incidence_arr_temp = Array{Array{Float64, 3}, 1}(undef, seeds_size)
    error_array = zeros(Float64, num_cgo_runs * seeds_size)
    error_array_final = zeros(Float64, 200)

    duration_parameter = Array{Float64, 1}(undef, num_cgo_runs * seeds_size)
    susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_cgo_runs * seeds_size)
    temperature_parameters = Array{Vector{Float64}, 1}(undef, num_cgo_runs * seeds_size)
    mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_cgo_runs * seeds_size)
    random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_cgo_runs * seeds_size)

    error_arr_temp = zeros(Float64, seeds_size)
    duration_parameter_temp = zeros(Float64, seeds_size)
    susceptibility_parameters_temp = Array{Vector{Float64}, 1}(undef, seeds_size)
    temperature_parameters_temp = Array{Vector{Float64}, 1}(undef, seeds_size)
    mean_immunity_durations_temp = Array{Vector{Float64}, 1}(undef, seeds_size)
    random_infection_probabilities_temp = Array{Vector{Float64}, 1}(undef, seeds_size)

    xlabel_name = "Step"
    if is_russian
        xlabel_name = "Шаг"
    end
    ylabel_name = "RMSE"

    for method_run = 1:num_method_runs
        for i = 1:num_cgo_runs
            for j = 1:seeds_size
                temp = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(method_run)", "$(i)", "results_$(i).jld"))["observed_cases"]
                error_arr_temp[j] = sum((temp - num_infected_age_groups_viruses).^2)
                
                duration_parameter_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(method_run)", "$(i)", "results_$(j).jld"))["duration_parameter"]
                susceptibility_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(method_run)", "$(i)", "results_$(j).jld"))["susceptibility_parameters"]
                temperature_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(method_run)", "$(i)", "results_$(j).jld"))["temperature_parameters"]
                mean_immunity_durations_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(method_run)", "$(i)", "results_$(j).jld"))["mean_immunity_durations"]
                random_infection_probabilities_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(method_run)", "$(i)", "results_$(j).jld"))["random_infection_probabilities"]
            end
            for j = 1:seeds_size
                error_array[(i - 1) * seeds_size + j] = minimum(error_arr_temp)
                min_arg = argmin(error_arr_temp)
                duration_parameter[(i - 1) * seeds_size + j] = duration_parameter_temp[min_arg]
                susceptibility_parameters[(i - 1) * seeds_size + j] = susceptibility_parameters_temp[min_arg]
                temperature_parameters[(i - 1) * seeds_size + j] = temperature_parameters_temp[min_arg]
                mean_immunity_durations[(i - 1) * seeds_size + j] = mean_immunity_durations_temp[min_arg]
                random_infection_probabilities[(i - 1) * seeds_size + j] = random_infection_probabilities_temp[min_arg]
            end
        end
        minimum_step_arr[method_run] = argmin(error_array)
        minimum_arr[method_run] = minimum(error_array)
        # minimum_arr[method_run] = error_array[1]
    end

    # println("CGO minimum method run = $(argmin(minimum_arr))")
    # println("CGO min error = $(sqrt.(minimum(minimum_arr) / num_error_points))")
    # println("CGO mean error = $(sqrt.(mean(minimum_arr) / num_error_points))")
    # println("CGO min step = $(minimum_step_arr[argmin(minimum_arr)])")
    # println("CGO mean step = $(mean(minimum_step_arr))")
    # return

    median_arg = 0
    for i = 1:num_method_runs
        if abs(minimum_arr[i] - median(minimum_arr)) < 0.00001
            median_arg = i
            break
        end
    end
    median_arg = argmin(minimum_arr)

    median_arg = 2

    # for i = 1:num_swarm_runs
    #     for j = 1:num_particles
    #         temp = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(median_arg)", "$(i)", "results_$(j).jld"))["observed_cases"]
    #         error_arr_temp[j] = sum((temp - num_infected_age_groups_viruses).^2)
            
    
    #     end
    #     for j = 1:num_particles
    #         error_array[(i - 1) * num_particles + j] = minimum(error_arr_temp)
    #         min_arg = argmin(error_arr_temp)
    #         duration_parameter[(i - 1) * num_particles + j] = duration_parameter_temp[min_arg]
    #         susceptibility_parameters[(i - 1) * num_particles + j] = susceptibility_parameters_temp[min_arg]
    #         temperature_parameters[(i - 1) * num_particles + j] = temperature_parameters_temp[min_arg]
    #         mean_immunity_durations[(i - 1) * num_particles + j] = mean_immunity_durations_temp[min_arg]
    #         random_infection_probabilities[(i - 1) * num_particles + j] = random_infection_probabilities_temp[min_arg]
    #     end
    # end

    for i = 1:num_cgo_runs
        for j = 1:seeds_size
            println("$(i) and $(j)")
            temp = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(median_arg)", "$(i)", "results_$(j).jld"))["observed_cases"]
            error_arr_temp[j] = sum((temp - num_infected_age_groups_viruses).^2)
            duration_parameter_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(median_arg)", "$(i)", "results_$(j).jld"))["duration_parameter"]
            susceptibility_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(median_arg)", "$(i)", "results_$(j).jld"))["susceptibility_parameters"]
            temperature_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(median_arg)", "$(i)", "results_$(j).jld"))["temperature_parameters"]
            mean_immunity_durations_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(median_arg)", "$(i)", "results_$(j).jld"))["mean_immunity_durations"]
            random_infection_probabilities_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(median_arg)", "$(i)", "results_$(j).jld"))["random_infection_probabilities"]
        end
        for j = 1:seeds_size
            error_array[(i - 1) * seeds_size + j] = minimum(error_arr_temp)
            duration_parameter[(i - 1) * seeds_size + j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(median_arg)", "$(i)", "results_$(j).jld"))["duration_parameter"]
            susceptibility_parameters[(i - 1) * seeds_size + j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(median_arg)", "$(i)", "results_$(j).jld"))["susceptibility_parameters"]
            temperature_parameters[(i - 1) * seeds_size + j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(median_arg)", "$(i)", "results_$(j).jld"))["temperature_parameters"]
            mean_immunity_durations[(i - 1) * seeds_size + j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(median_arg)", "$(i)", "results_$(j).jld"))["mean_immunity_durations"]
            random_infection_probabilities[(i - 1) * seeds_size + j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "cgo$(median_arg)", "$(i)", "results_$(j).jld"))["random_infection_probabilities"]
        end
    end

    for i = 1:5
        for j = 1:40
            error_array_final[(i - 1) * 40 + j] = error_array[i * 10 - 1]
        end
    end
    

    # error_plot = plot(
    #     # 1:(num_swarm_runs * num_particles + num_particles),
    #     # moving_average(sqrt.(error_array[1:(num_swarm_runs * num_particles + num_particles)] / num_error_points), 3),
    #     1:(num_cgo_runs * seeds_size),
    #     moving_average(sqrt.(error_array[1:(num_cgo_runs * seeds_size)] / num_error_points), 3),
    #     lw = 1.5,
    #     grid = true,
    #     label = "CGO",
    #     legend = (0.74, 0.98),
    #     color = RGB(0.4, 0.8, 0.933),
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )
    plot!(
        # 1:(num_swarm_runs * num_particles + num_particles),
        # moving_average(sqrt.(error_array[1:(num_swarm_runs * num_particles + num_particles)] / num_error_points), 3),
        1:200,
        moving_average(sqrt.(error_array_final[1:200] / num_error_points), 3),
        lw = 1.5,
        grid = true,
        label = "CGO",
        legend = (0.74, 0.98),
        color = RGB(0.4, 0.8, 0.933),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # min_argument = argmin(error_array)
    # println(min_argument)
    # println(sqrt.(error_array[min_argument] / num_error_points))
    # println("CGO")
    # println("duration_parameter = $(duration_parameter[min_argument])")
    # println("susceptibility_parameters = $(susceptibility_parameters[min_argument])")
    # println("temperature_parameters = $(temperature_parameters[min_argument])")
    # println("mean_immunity_durations = $(mean_immunity_durations[min_argument])")
    # println("random_infection_probabilities = $(random_infection_probabilities[min_argument])")
    # println()
    # return

    savefig(error_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "optimization_methods.pdf"))
end

function optimization_methods_incidence()
    incidence_arr = Array{Vector{Float64}, 1}(undef, num_years)

    incidence_arr_mean_MCMC_LHS = zeros(Float64, 52)
    incidence_arr_mean_MCMC_manual = zeros(Float64, 52)
    # incidence_arr_mean_MA_LHS = zeros(Float64, 52)
    # incidence_arr_mean_MA_manual = zeros(Float64, 52)
    incidence_arr_mean_SM = zeros(Float64, 52)
    incidence_arr_mean_PSO = zeros(Float64, 52)
    incidence_arr_mean_GA = zeros(Float64, 52)

    observed_num_infected_age_groups_viruses_MCMC_LHS = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MCMC_LHS.jld"))["observed_cases"] ./ population_coef
    observed_num_infected_age_groups_viruses_MCMC_manual = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MCMC_manual.jld"))["observed_cases"] ./ population_coef
    # observed_num_infected_age_groups_viruses_MA_LHS = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MA_LHS.jld"))["observed_cases"] ./ population_coef
    # observed_num_infected_age_groups_viruses_MA_manual = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MA_manual.jld"))["observed_cases"] ./ population_coef
    observed_num_infected_age_groups_viruses_SM = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_SM.jld"))["observed_cases"] ./ population_coef
    observed_num_infected_age_groups_viruses_PSO = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_PSO.jld"))["observed_cases"] ./ population_coef
    observed_num_infected_age_groups_viruses_GA = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_GA.jld"))["observed_cases"] ./ population_coef

    for j = 1:num_years
        incidence_arr[j] = sum(sum(observed_num_infected_age_groups_viruses_MCMC_LHS, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
    end
    for i = 1:52
        for j = 1:num_years
            incidence_arr_mean_MCMC_LHS[i] += incidence_arr[j][i]
        end
        incidence_arr_mean_MCMC_LHS[i] /= num_years
    end

    for j = 1:num_years
        incidence_arr[j] = sum(sum(observed_num_infected_age_groups_viruses_MCMC_manual, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
    end
    for i = 1:52
        for j = 1:num_years
            incidence_arr_mean_MCMC_manual[i] += incidence_arr[j][i]
        end
        incidence_arr_mean_MCMC_manual[i] /= num_years
    end

    # for j = 1:num_years
    #     incidence_arr[j] = sum(sum(observed_num_infected_age_groups_viruses_MA_LHS, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
    # end
    # for i = 1:52
    #     for j = 1:num_years
    #         incidence_arr_mean_MA_LHS[i] += incidence_arr[j][i]
    #     end
    #     incidence_arr_mean_MA_LHS[i] /= num_years
    # end

    # for j = 1:num_years
    #     incidence_arr[j] = sum(sum(observed_num_infected_age_groups_viruses_MA_manual, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
    # end
    # for i = 1:52
    #     for j = 1:num_years
    #         incidence_arr_mean_MA_manual[i] += incidence_arr[j][i]
    #     end
    #     incidence_arr_mean_MA_manual[i] /= num_years
    # end

    for j = 1:num_years
        incidence_arr[j] = sum(sum(observed_num_infected_age_groups_viruses_SM, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
    end
    for i = 1:52
        for j = 1:num_years
            incidence_arr_mean_SM[i] += incidence_arr[j][i]
        end
        incidence_arr_mean_SM[i] /= num_years
    end

    for j = 1:num_years
        incidence_arr[j] = sum(sum(observed_num_infected_age_groups_viruses_PSO, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
    end
    for i = 1:52
        for j = 1:num_years
            incidence_arr_mean_PSO[i] += incidence_arr[j][i]
        end
        incidence_arr_mean_PSO[i] /= num_years
    end

    for j = 1:num_years
        incidence_arr[j] = sum(sum(observed_num_infected_age_groups_viruses_GA, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
    end
    for i = 1:52
        for j = 1:num_years
            incidence_arr_mean_GA[i] += incidence_arr[j][i]
        end
        incidence_arr_mean_GA[i] /= num_years
    end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ';', Int, '\n') ./ population_coef
    infected_data_mean = mean(infected_data[2:53, flu_starting_index:end], dims = 2)[:, 1]

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["MCMC LHS" "MCMC manual" "SM" "PSO" "GA"]

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    ref_label = "Reference"
    if is_russian
        ref_label = "Данные"
    end

    incidence_plot = plot(
        1:52,
        [incidence_arr_mean_MCMC_LHS incidence_arr_mean_MCMC_manual incidence_arr_mean_SM incidence_arr_mean_PSO incidence_arr_mean_GA],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = true,
        legend = (0.75, 0.98),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    plot!(
        1:52,
        infected_data_mean,
        lw = 2.0,
        xticks = (ticks, ticklabels),
        label = ref_label,
        grid = true,
        legend = (0.75, 0.98),
        color = :black,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "optimization_methods_incidence.pdf"))
end

function optimization_methods_incidence_age_groups()
    incidence_arr = Array{Vector{Float64}, 1}(undef, num_years)

    incidence_arr_mean_MCMC_LHS = zeros(Float64, 52, 4)
    incidence_arr_mean_MCMC_manual = zeros(Float64, 52, 4)
    # incidence_arr_mean_MA_LHS = zeros(Float64, 52)
    # incidence_arr_mean_MA_manual = zeros(Float64, 52)
    incidence_arr_mean_SM = zeros(Float64, 52, 4)
    incidence_arr_mean_PSO = zeros(Float64, 52, 4)
    incidence_arr_mean_GA = zeros(Float64, 52, 4)

    observed_num_infected_age_groups_viruses_MCMC_LHS = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MCMC_LHS.jld"))["observed_cases"] ./ population_coef
    observed_num_infected_age_groups_viruses_MCMC_manual = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MCMC_manual.jld"))["observed_cases"] ./ population_coef
    # observed_num_infected_age_groups_viruses_MA_LHS = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MA_LHS.jld"))["observed_cases"] ./ population_coef
    # observed_num_infected_age_groups_viruses_MA_manual = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MA_manual.jld"))["observed_cases"] ./ population_coef
    observed_num_infected_age_groups_viruses_SM = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_SM.jld"))["observed_cases"] ./ population_coef
    observed_num_infected_age_groups_viruses_PSO = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_PSO.jld"))["observed_cases"] ./ population_coef
    observed_num_infected_age_groups_viruses_GA = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_GA.jld"))["observed_cases"] ./ population_coef

    # observed_num_infected_age_groups_viruses_MCMC_LHS = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MCMC_LHS_min.jld"))["observed_cases"] ./ population_coef
    # observed_num_infected_age_groups_viruses_MCMC_manual = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MCMC_manual_min.jld"))["observed_cases"] ./ population_coef
    # # observed_num_infected_age_groups_viruses_MA_LHS = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MA_LHS.jld"))["observed_cases"] ./ population_coef
    # # observed_num_infected_age_groups_viruses_MA_manual = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MA_manual.jld"))["observed_cases"] ./ population_coef
    # observed_num_infected_age_groups_viruses_SM = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_SM_min.jld"))["observed_cases"] ./ population_coef
    # observed_num_infected_age_groups_viruses_PSO = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_PSO_min.jld"))["observed_cases"] ./ population_coef
    # observed_num_infected_age_groups_viruses_GA = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_GA_min.jld"))["observed_cases"] ./ population_coef

    incidence_arr_mean_MCMC_LHS = sum(observed_num_infected_age_groups_viruses_MCMC_LHS, dims = 2)[:, 1, :][1:52, :]
    incidence_arr_mean_MCMC_manual = sum(observed_num_infected_age_groups_viruses_MCMC_manual, dims = 2)[:, 1, :][1:52, :]
    incidence_arr_mean_SM = sum(observed_num_infected_age_groups_viruses_SM, dims = 2)[:, 1, :][1:52, :]
    incidence_arr_mean_PSO = sum(observed_num_infected_age_groups_viruses_PSO, dims = 2)[:, 1, :][1:52, :]
    incidence_arr_mean_GA = sum(observed_num_infected_age_groups_viruses_GA, dims = 2)[:, 1, :][1:52, :]

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ';', Int, '\n') ./ population_coef
    infected_data_0_mean = mean(infected_data_0[2:53, flu_starting_index:end], dims = 2)[:, 1]
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ';', Int, '\n') ./ population_coef
    infected_data_3_mean = mean(infected_data_3[2:53, flu_starting_index:end], dims = 2)[:, 1]
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ';', Int, '\n') ./ population_coef
    infected_data_7_mean = mean(infected_data_7[2:53, flu_starting_index:end], dims = 2)[:, 1]
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ';', Int, '\n') ./ population_coef
    infected_data_15_mean = mean(infected_data_15[2:53, flu_starting_index:end], dims = 2)[:, 1]

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["MCMC LHS" "MCMC manual" "SM" "PSO" "GA"]

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    ref_label = "Reference"
    if is_russian
        ref_label = "Данные"
    end

    incidence_plot = plot(
        1:52,
        [incidence_arr_mean_MCMC_LHS[:, 1] incidence_arr_mean_MCMC_manual[:, 1] incidence_arr_mean_SM[:, 1] incidence_arr_mean_PSO[:, 1] incidence_arr_mean_GA[:, 1]],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = true,
        legend = (0.8, 1.01),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    plot!(
        1:52,
        infected_data_0_mean,
        lw = 2.0,
        xticks = (ticks, ticklabels),
        label = ref_label,
        grid = true,
        legend = (0.8, 1.01),
        color = :black,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "optimization_methods_incidence_0-2.pdf"))

    incidence_plot = plot(
        1:52,
        [incidence_arr_mean_MCMC_LHS[:, 2] incidence_arr_mean_MCMC_manual[:, 2] incidence_arr_mean_SM[:, 2] incidence_arr_mean_PSO[:, 2] incidence_arr_mean_GA[:, 2]],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = true,
        legend = (0.77, 0.98),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    plot!(
        1:52,
        infected_data_3_mean,
        lw = 2.0,
        xticks = (ticks, ticklabels),
        label = ref_label,
        grid = true,
        legend = (0.77, 0.98),
        color = :black,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "optimization_methods_incidence_3-6.pdf"))

    incidence_plot = plot(
        1:52,
        [incidence_arr_mean_MCMC_LHS[:, 3] incidence_arr_mean_MCMC_manual[:, 3] incidence_arr_mean_SM[:, 3] incidence_arr_mean_PSO[:, 3] incidence_arr_mean_GA[:, 3]],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = true,
        legend = (0.77, 0.98),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    plot!(
        1:52,
        infected_data_7_mean,
        lw = 2.0,
        xticks = (ticks, ticklabels),
        label = ref_label,
        grid = true,
        legend = (0.77, 0.98),
        color = :black,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "optimization_methods_incidence_7-14.pdf"))

    incidence_plot = plot(
        1:52,
        [incidence_arr_mean_MCMC_LHS[:, 4] incidence_arr_mean_MCMC_manual[:, 4] incidence_arr_mean_SM[:, 4] incidence_arr_mean_PSO[:, 4] incidence_arr_mean_GA[:, 4]],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = true,
        legend = (0.77, 0.98),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    plot!(
        1:52,
        infected_data_15_mean,
        lw = 2.0,
        xticks = (ticks, ticklabels),
        label = ref_label,
        grid = true,
        legend = (0.77, 0.98),
        color = :black,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "optimization_methods_incidence_15+.pdf"))
end

# plot_mcmc_hypercube()
# plot_mcmc_manual()

# plot_metropolis_manual()
# plot_metropolis_hypercube()

# plot_swarm_hypercube()

# plot_surrogate_hypercube()

optimization_methods()

# optimization_methods_incidence()
# optimization_methods_incidence_age_groups()
