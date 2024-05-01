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

function plot_all()
    num_error_points = 1456
    etiology = get_etiology()
    num_infected_age_groups_viruses = get_incidence(etiology, true, flu_starting_index, true)

    num_mcmc_runs = 200
    
    duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_hypercube", "duration_parameter_array.csv"), ';', Float64, '\n')
    error_array = zeros(Float64, length(duration_parameter_array))

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
            if line_num == 1 || ((abs(susceptibility_parameter_1_array[line_num] - susceptibility_parameter_1_array[line_num - 1]) > 0.0001) && (abs(susceptibility_parameter_2_array[line_num] - susceptibility_parameter_2_array[line_num - 1]) > 0.0001))
                error_array[line_num] = parse.(Float64, line)
            else
                error_array[line_num] = error_array[line_num - 1]
            end
            # error_array[line_num] = parse.(Float64, line)
            line_num += 1
        end
    end

    xlabel_name = "Step"
    ylabel_name = "RMSE"

    error_plot = plot(
        1:num_mcmc_runs,
        moving_average(sqrt.(error_array[1:num_mcmc_runs] / num_error_points), 3),
        lw = 1.5,
        grid = true,
        label = "MCMC LHS",
        color = RGB(0.267, 0.467, 0.667),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # min_argument = argmin(error_array[1:num_mcmc_runs])
    # println(min_argument)
    # println(error_array[min_argument])
    # println("MCMC LHS")
    # println("duration_parameter = $(duration_parameter_array[min_argument])")
    # println("susceptibility_parameters = $([susceptibility_parameter_1_array[min_argument], susceptibility_parameter_2_array[min_argument], susceptibility_parameter_3_array[min_argument], susceptibility_parameter_4_array[min_argument], susceptibility_parameter_5_array[min_argument], susceptibility_parameter_6_array[min_argument], susceptibility_parameter_7_array[min_argument]])")
    # println("temperature_parameters = $(-[temperature_parameter_1_array[min_argument], temperature_parameter_2_array[min_argument], temperature_parameter_3_array[min_argument], temperature_parameter_4_array[min_argument], temperature_parameter_5_array[min_argument], temperature_parameter_6_array[min_argument], temperature_parameter_7_array[min_argument]])")
    # println("mean_immunity_durations = $([mean_immunity_duration_1_array[min_argument], mean_immunity_duration_2_array[min_argument], mean_immunity_duration_3_array[min_argument], mean_immunity_duration_4_array[min_argument], mean_immunity_duration_5_array[min_argument], mean_immunity_duration_6_array[min_argument], mean_immunity_duration_7_array[min_argument]])")
    # println("random_infection_probabilities = $([random_infection_probability_1_array[min_argument], random_infection_probability_2_array[min_argument], random_infection_probability_3_array[min_argument], random_infection_probability_4_array[min_argument]])")
    # println()
    # return

    num_mcmc_runs = 200

    duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_mcmc_manual", "duration_parameter_array.csv"), ';', Float64, '\n')
    error_array = zeros(Float64, length(duration_parameter_array))

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
            if line_num == 1 || ((abs(susceptibility_parameter_1_array[line_num] - susceptibility_parameter_1_array[line_num - 1]) > 0.0001) && (abs(susceptibility_parameter_2_array[line_num] - susceptibility_parameter_2_array[line_num - 1]) > 0.0001))
                error_array[line_num] = parse.(Float64, line)
            else
                error_array[line_num] = error_array[line_num - 1]
            end
            # error_array[line_num] = parse.(Float64, line)
            line_num += 1
        end
    end

    xlabel_name = "Step"
    ylabel_name = "RMSE"

    plot!(
        1:num_mcmc_runs,
        moving_average(sqrt.(error_array[1:num_mcmc_runs] / num_error_points), 3),
        lw = 1.5,
        grid = true,
        label = "MCMC manual",
        color = RGB(0.933, 0.4, 0.467),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # min_argument = argmin(error_array)
    # println(error_array[min_argument])
    # println("MCMC manual")
    # println("duration_parameter = $(duration_parameter_array[min_argument])")
    # println("susceptibility_parameters = $([susceptibility_parameter_1_array[min_argument], susceptibility_parameter_2_array[min_argument], susceptibility_parameter_3_array[min_argument], susceptibility_parameter_4_array[min_argument], susceptibility_parameter_5_array[min_argument], susceptibility_parameter_6_array[min_argument], susceptibility_parameter_7_array[min_argument]])")
    # println("temperature_parameters = $(-[temperature_parameter_1_array[min_argument], temperature_parameter_2_array[min_argument], temperature_parameter_3_array[min_argument], temperature_parameter_4_array[min_argument], temperature_parameter_5_array[min_argument], temperature_parameter_6_array[min_argument], temperature_parameter_7_array[min_argument]])")
    # println("mean_immunity_durations = $([mean_immunity_duration_1_array[min_argument], mean_immunity_duration_2_array[min_argument], mean_immunity_duration_3_array[min_argument], mean_immunity_duration_4_array[min_argument], mean_immunity_duration_5_array[min_argument], mean_immunity_duration_6_array[min_argument], mean_immunity_duration_7_array[min_argument]])")
    # println("random_infection_probabilities = $([random_infection_probability_1_array[min_argument], random_infection_probability_2_array[min_argument], random_infection_probability_3_array[min_argument], random_infection_probability_4_array[min_argument]])")
    # println()
    # return

    # duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "duration_parameter_array.csv"), ';', Float64, '\n')
    # num_metropolis_runs = length(duration_parameter_array)
    # error_array = zeros(Float64, num_metropolis_runs)

    # susceptibility_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_1_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_2_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_3_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_4_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_5_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_6_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "susceptibility_parameter_7_array.csv"), ';', Float64, '\n')

    # temperature_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_1_array.csv"), ';', Float64, '\n')
    # temperature_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_2_array.csv"), ';', Float64, '\n')
    # temperature_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_3_array.csv"), ';', Float64, '\n')
    # temperature_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_4_array.csv"), ';', Float64, '\n')
    # temperature_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_5_array.csv"), ';', Float64, '\n')
    # temperature_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_6_array.csv"), ';', Float64, '\n')
    # temperature_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "temperature_parameter_7_array.csv"), ';', Float64, '\n')

    # mean_immunity_duration_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_1_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_2_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_3_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_4_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_5_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_6_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "mean_immunity_duration_7_array.csv"), ';', Float64, '\n')

    # random_infection_probability_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "random_infection_probability_1_array.csv"), ';', Float64, '\n')
    # random_infection_probability_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "random_infection_probability_2_array.csv"), ';', Float64, '\n')
    # random_infection_probability_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "random_infection_probability_3_array.csv"), ';', Float64, '\n')
    # random_infection_probability_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_hypercube", "random_infection_probability_4_array.csv"), ';', Float64, '\n')

    # open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_metropolis_hypercube.txt"),"r") do datafile
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
    #     end
    # end

    # xlabel_name = "Step"
    # ylabel_name = "RMSE"

    # plot!(
    #     1:250,
    #     moving_average(error_array[1:250], 3),
    #     lw = 1.5,
    #     grid = true,
    #     label = "MA LHS",
    #     color = RGB(0.133, 0.533, 0.2),
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )

    # # min_argument = argmin(error_array[1:250])
    # # println(error_array[min_argument])
    # # println("MA LHS")
    # # println("duration_parameter = $(duration_parameter_array[min_argument])")
    # # println("susceptibility_parameters = $([susceptibility_parameter_1_array[min_argument], susceptibility_parameter_2_array[min_argument], susceptibility_parameter_3_array[min_argument], susceptibility_parameter_4_array[min_argument], susceptibility_parameter_5_array[min_argument], susceptibility_parameter_6_array[min_argument], susceptibility_parameter_7_array[min_argument]])")
    # # println("temperature_parameters = $(-[temperature_parameter_1_array[min_argument], temperature_parameter_2_array[min_argument], temperature_parameter_3_array[min_argument], temperature_parameter_4_array[min_argument], temperature_parameter_5_array[min_argument], temperature_parameter_6_array[min_argument], temperature_parameter_7_array[min_argument]])")
    # # println("mean_immunity_durations = $([mean_immunity_duration_1_array[min_argument], mean_immunity_duration_2_array[min_argument], mean_immunity_duration_3_array[min_argument], mean_immunity_duration_4_array[min_argument], mean_immunity_duration_5_array[min_argument], mean_immunity_duration_6_array[min_argument], mean_immunity_duration_7_array[min_argument]])")
    # # println("random_infection_probabilities = $([random_infection_probability_1_array[min_argument], random_infection_probability_2_array[min_argument], random_infection_probability_3_array[min_argument], random_infection_probability_4_array[min_argument]])")
    # # println()
    # # return

    # duration_parameter_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "duration_parameter_array.csv"), ';', Float64, '\n')
    # num_metropolis_runs = length(duration_parameter_array)
    # error_array = zeros(Float64, num_metropolis_runs)

    # susceptibility_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_1_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_2_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_3_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_4_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_5_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_6_array.csv"), ';', Float64, '\n')
    # susceptibility_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "susceptibility_parameter_7_array.csv"), ';', Float64, '\n')

    # temperature_parameter_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_1_array.csv"), ';', Float64, '\n')
    # temperature_parameter_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_2_array.csv"), ';', Float64, '\n')
    # temperature_parameter_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_3_array.csv"), ';', Float64, '\n')
    # temperature_parameter_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_4_array.csv"), ';', Float64, '\n')
    # temperature_parameter_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_5_array.csv"), ';', Float64, '\n')
    # temperature_parameter_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_6_array.csv"), ';', Float64, '\n')
    # temperature_parameter_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "temperature_parameter_7_array.csv"), ';', Float64, '\n')

    # mean_immunity_duration_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_1_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_2_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_3_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_4_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_5_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_5_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_6_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_6_array.csv"), ';', Float64, '\n')
    # mean_immunity_duration_7_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "mean_immunity_duration_7_array.csv"), ';', Float64, '\n')

    # random_infection_probability_1_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "random_infection_probability_1_array.csv"), ';', Float64, '\n')
    # random_infection_probability_2_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "random_infection_probability_2_array.csv"), ';', Float64, '\n')
    # random_infection_probability_3_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "random_infection_probability_3_array.csv"), ';', Float64, '\n')
    # random_infection_probability_4_array = readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables_metropolis_manual", "random_infection_probability_4_array.csv"), ';', Float64, '\n')

    # open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_metropolis_manual.txt"),"r") do datafile
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
    #     end
    # end

    # xlabel_name = "Step"
    # ylabel_name = "RMSE"

    # plot!(
    #     1:250,
    #     moving_average(error_array[1:250], 3),
    #     lw = 1.5,
    #     grid = true,
    #     label = "MA manual",
    #     color = RGB(0.667, 0.2, 0.467),
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )

    # # min_argument = argmin(error_array[1:250])
    # # println(error_array[min_argument])
    # # println("MA manual")
    # # println("duration_parameter = $(duration_parameter_array[min_argument])")
    # # println("susceptibility_parameters = $([susceptibility_parameter_1_array[min_argument], susceptibility_parameter_2_array[min_argument], susceptibility_parameter_3_array[min_argument], susceptibility_parameter_4_array[min_argument], susceptibility_parameter_5_array[min_argument], susceptibility_parameter_6_array[min_argument], susceptibility_parameter_7_array[min_argument]])")
    # # println("temperature_parameters = $(-[temperature_parameter_1_array[min_argument], temperature_parameter_2_array[min_argument], temperature_parameter_3_array[min_argument], temperature_parameter_4_array[min_argument], temperature_parameter_5_array[min_argument], temperature_parameter_6_array[min_argument], temperature_parameter_7_array[min_argument]])")
    # # println("mean_immunity_durations = $([mean_immunity_duration_1_array[min_argument], mean_immunity_duration_2_array[min_argument], mean_immunity_duration_3_array[min_argument], mean_immunity_duration_4_array[min_argument], mean_immunity_duration_5_array[min_argument], mean_immunity_duration_6_array[min_argument], mean_immunity_duration_7_array[min_argument]])")
    # # println("random_infection_probabilities = $([random_infection_probability_1_array[min_argument], random_infection_probability_2_array[min_argument], random_infection_probability_3_array[min_argument], random_infection_probability_4_array[min_argument]])")
    # # println()
    # # return

    num_surrogate_runs = 200

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_surrogate_runs)
    duration_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    temperature_parameters = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)
    random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_surrogate_runs)

    error_array = zeros(Float64, num_surrogate_runs)

    xlabel_name = "Step"
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
        # error_array[i] = sum(abs.(incidence_arr[i] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        error_array[i] = sum((incidence_arr[i] - num_infected_age_groups_viruses).^2)
    end

    plot!(
        1:num_surrogate_runs,
        moving_average(sqrt.(error_array / num_error_points), 3),
        lw = 1.5,
        grid = true,
        label = "SM LHS",
        color = RGB(0.133, 0.533, 0.2),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # min_argument = argmin(error_array[1:250])
    # println(error_array[min_argument])
    # println("SM")
    # println("duration_parameter = $(duration_parameter[min_argument])")
    # println("susceptibility_parameters = $(susceptibility_parameters[min_argument])")
    # println("temperature_parameters = $(-temperature_parameters[min_argument])")
    # println("mean_immunity_durations = $(mean_immunity_durations[min_argument])")
    # println("random_infection_probabilities = $(random_infection_probabilities[min_argument])")
    # println()
    # return

    num_swarm_runs = 20
    num_particles = 10

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_swarm_runs)
    incidence_arr_temp = Array{Array{Float64, 3}, 1}(undef, num_particles)
    error_array = zeros(Float64, num_swarm_runs * num_particles)

    duration_parameter = Array{Float64, 1}(undef, num_swarm_runs * num_particles)
    susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_swarm_runs * num_particles)
    temperature_parameters = Array{Vector{Float64}, 1}(undef, num_swarm_runs * num_particles)
    mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_swarm_runs * num_particles)
    random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_swarm_runs * num_particles)

    error_arr_temp = zeros(Float64, num_particles)
    duration_parameter_temp = zeros(Float64, num_particles)
    susceptibility_parameters_temp = Array{Vector{Float64}, 1}(undef, num_particles)
    temperature_parameters_temp = Array{Vector{Float64}, 1}(undef, num_particles)
    mean_immunity_durations_temp = Array{Vector{Float64}, 1}(undef, num_particles)
    random_infection_probabilities_temp = Array{Vector{Float64}, 1}(undef, num_particles)

    xlabel_name = "Step"
    ylabel_name = "RMSE"

    for i = 1:num_swarm_runs
        for j = 1:num_particles
            temp = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["observed_cases"]
            error_arr_temp[j] = sum((temp - num_infected_age_groups_viruses).^2)
            
            duration_parameter_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["duration_parameter"]
            susceptibility_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["susceptibility_parameters"]
            temperature_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["temperature_parameters"]
            mean_immunity_durations_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["mean_immunity_durations"]
            random_infection_probabilities_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "swarm", "$(j)", "results_$(i).jld"))["random_infection_probabilities"]
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

    plot!(
        1:(num_swarm_runs * num_particles),
        moving_average(sqrt.(error_array[1:(num_swarm_runs * num_particles)] / num_error_points), 3),
        lw = 1.5,
        grid = true,
        label = "PSO LHS",
        legend = (0.74, 0.98),
        color = RGB(0.667, 0.2, 0.467),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # min_argument = argmin(error_array[1:250])
    # println(error_array[min_argument])
    # println("PSO LHS")
    # println("duration_parameter = $(duration_parameter[min_argument])")
    # println("susceptibility_parameters = $(susceptibility_parameters[min_argument])")
    # println("temperature_parameters = $(temperature_parameters[min_argument])")
    # println("mean_immunity_durations = $(mean_immunity_durations[min_argument])")
    # println("random_infection_probabilities = $(random_infection_probabilities[min_argument])")
    # println()
    # return

    savefig(error_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_all.pdf"))

    # num_ga_runs = 13
    num_ga_runs = 14
    population_size = 10

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_ga_runs)
    incidence_arr_temp = Array{Array{Float64, 3}, 1}(undef, population_size)
    error_array = zeros(Float64, num_ga_runs * population_size)

    duration_parameter = Array{Float64, 1}(undef, num_ga_runs * population_size)
    susceptibility_parameters = Array{Vector{Float64}, 1}(undef, num_ga_runs * population_size)
    temperature_parameters = Array{Vector{Float64}, 1}(undef, num_ga_runs * population_size)
    mean_immunity_durations = Array{Vector{Float64}, 1}(undef, num_ga_runs * population_size)
    random_infection_probabilities = Array{Vector{Float64}, 1}(undef, num_ga_runs * population_size)

    error_arr_temp = zeros(Float64, population_size)
    duration_parameter_temp = zeros(Float64, population_size)
    susceptibility_parameters_temp = Array{Vector{Float64}, 1}(undef, population_size)
    temperature_parameters_temp = Array{Vector{Float64}, 1}(undef, population_size)
    mean_immunity_durations_temp = Array{Vector{Float64}, 1}(undef, population_size)
    random_infection_probabilities_temp = Array{Vector{Float64}, 1}(undef, population_size)

    xlabel_name = "Step"
    ylabel_name = "RMSE"

    for j = 1:10
        temp = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "11", "results_$(j).jld"))["observed_cases"]
        error_arr_temp[j] = sum((temp - num_infected_age_groups_viruses).^2)

        duration_parameter_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "11", "results_$(j).jld"))["duration_parameter"]
        susceptibility_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "11", "results_$(j).jld"))["susceptibility_parameters"]
        temperature_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "11", "results_$(j).jld"))["temperature_parameters"]
        mean_immunity_durations_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "11", "results_$(j).jld"))["mean_immunity_durations"]
        random_infection_probabilities_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "11", "results_$(j).jld"))["random_infection_probabilities"]
    end
    println(error_arr_temp)
    # println(duration_parameter_temp)
    # println(susceptibility_parameters_temp[2])
    # println(susceptibility_parameters_temp[3])
    # println(susceptibility_parameters_temp[6])
    # println(susceptibility_parameters_temp[10])

    # println(temperature_parameters_temp[2])
    # println(temperature_parameters_temp[3])
    # println(temperature_parameters_temp[6])
    # println(temperature_parameters_temp[10])

    # return

    for i = 1:num_ga_runs
        for j = 1:population_size
            temp = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "$(i)", "results_$(j).jld"))["observed_cases"]
            error_arr_temp[j] = sum((temp - num_infected_age_groups_viruses).^2)
            
            duration_parameter_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "$(i)", "results_$(j).jld"))["duration_parameter"]
            susceptibility_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "$(i)", "results_$(j).jld"))["susceptibility_parameters"]
            temperature_parameters_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "$(i)", "results_$(j).jld"))["temperature_parameters"]
            mean_immunity_durations_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "$(i)", "results_$(j).jld"))["mean_immunity_durations"]
            random_infection_probabilities_temp[j] = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "ga", "$(i)", "results_$(j).jld"))["random_infection_probabilities"]
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
    plot!(
        1:(num_ga_runs * population_size),
        moving_average(sqrt.(error_array[1:(num_ga_runs * population_size)] / num_error_points), 3),
        lw = 1.5,
        grid = true,
        label = "GA LHS",
        legend = (0.74, 0.98),
        color = RGB(0.5, 0.5, 0.5),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # min_argument = argmin(error_array[1:250])
    # println(error_array[min_argument])
    # println("PSO LHS")
    # println("duration_parameter = $(duration_parameter[min_argument])")
    # println("susceptibility_parameters = $(susceptibility_parameters[min_argument])")
    # println("temperature_parameters = $(temperature_parameters[min_argument])")
    # println("mean_immunity_durations = $(mean_immunity_durations[min_argument])")
    # println("random_infection_probabilities = $(random_infection_probabilities[min_argument])")
    # println()
    # return

    savefig(error_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_all.pdf"))
end

function plot_all_incidence()
    incidence_arr = Array{Vector{Float64}, 1}(undef, num_years)

    incidence_arr_mean_MCMC_LHS = zeros(Float64, 52)
    incidence_arr_mean_MCMC_manual = zeros(Float64, 52)
    incidence_arr_mean_MA_LHS = zeros(Float64, 52)
    incidence_arr_mean_MA_manual = zeros(Float64, 52)
    incidence_arr_mean_SM_LHS = zeros(Float64, 52)
    incidence_arr_mean_PSO_LHS = zeros(Float64, 52)

    observed_num_infected_age_groups_viruses_MCMC_LHS = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MCMC_LHS.jld"))["observed_cases"] ./ population_coef
    observed_num_infected_age_groups_viruses_MCMC_manual = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MCMC_manual.jld"))["observed_cases"] ./ population_coef
    observed_num_infected_age_groups_viruses_MA_LHS = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MA_LHS.jld"))["observed_cases"] ./ population_coef
    observed_num_infected_age_groups_viruses_MA_manual = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_MA_manual.jld"))["observed_cases"] ./ population_coef
    observed_num_infected_age_groups_viruses_SM_LHS = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_SM_LHS.jld"))["observed_cases"] ./ population_coef
    observed_num_infected_age_groups_viruses_PSO_LHS = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_PSO_LHS.jld"))["observed_cases"] ./ population_coef

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

    for j = 1:num_years
        incidence_arr[j] = sum(sum(observed_num_infected_age_groups_viruses_MA_LHS, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
    end
    for i = 1:52
        for j = 1:num_years
            incidence_arr_mean_MA_LHS[i] += incidence_arr[j][i]
        end
        incidence_arr_mean_MA_LHS[i] /= num_years
    end

    for j = 1:num_years
        incidence_arr[j] = sum(sum(observed_num_infected_age_groups_viruses_MA_manual, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
    end
    for i = 1:52
        for j = 1:num_years
            incidence_arr_mean_MA_manual[i] += incidence_arr[j][i]
        end
        incidence_arr_mean_MA_manual[i] /= num_years
    end

    for j = 1:num_years
        incidence_arr[j] = sum(sum(observed_num_infected_age_groups_viruses_SM_LHS, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
    end
    for i = 1:52
        for j = 1:num_years
            incidence_arr_mean_SM_LHS[i] += incidence_arr[j][i]
        end
        incidence_arr_mean_SM_LHS[i] /= num_years
    end

    for j = 1:num_years
        incidence_arr[j] = sum(sum(observed_num_infected_age_groups_viruses_PSO_LHS, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
    end
    for i = 1:52
        for j = 1:num_years
            incidence_arr_mean_PSO_LHS[i] += incidence_arr[j][i]
        end
        incidence_arr_mean_PSO_LHS[i] /= num_years
    end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ';', Int, '\n') ./ population_coef
    infected_data_mean = mean(infected_data[2:53, flu_starting_index:end], dims = 2)[:, 1]

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["MCMC LHS" "MCMC manual" "MA LHS" "MA manual" "SM LHS" "PSO LHS"]

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    # incidence_plot = plot(
    #     1:52,
    #     [incidence_arr_mean_MCMC_LHS incidence_arr_mean_MCMC_manual incidence_arr_mean_MA_LHS incidence_arr_mean_MA_manual incidence_arr_mean_SM_LHS incidence_arr_mean_PSO_LHS infected_data_mean],
    #     lw = 1.5,
    #     xticks = (ticks, ticklabels),
    #     label = label_names,
    #     grid = true,
    #     legend = (0.75, 0.98),
    #     color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.0, 0.0, 0.0)],
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )
    incidence_plot = plot(
        1:52,
        [incidence_arr_mean_MCMC_LHS incidence_arr_mean_MCMC_manual incidence_arr_mean_MA_LHS incidence_arr_mean_MA_manual incidence_arr_mean_SM_LHS incidence_arr_mean_PSO_LHS infected_data_mean],
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
        label = "Reference",
        grid = true,
        legend = (0.75, 0.98),
        color = :black,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "plot_all_incidence.pdf"))
end

# plot_mcmc_hypercube()
# plot_mcmc_manual()

# plot_metropolis_manual()
# plot_metropolis_hypercube()

# plot_swarm_hypercube()

# plot_surrogate_hypercube()

plot_all()

# plot_all_incidence()
