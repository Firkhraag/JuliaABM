using DelimitedFiles
using Plots
using DataFrames
using Statistics
using Distributions
using LaTeXStrings
using JLD
using CSV
using Random

default(legendfontsize = 11, guidefont = (12, :black), tickfont = (11, :black))

function moving_average(A::AbstractArray, m::Int)
    out = similar(A)
    R = CartesianIndices(A)
    Ifirst, Ilast = first(R), last(R)
    I1 = m ÷ 2 * oneunit(Ifirst)
    for I in R
        n, s = 0, zero(eltype(out))
        for J in max(Ifirst, I - I1):min(Ilast, I + I1)
            s += A[J]
            n += 1
        end
        out[I] = s / n
    end
    return out
end

function plot_mcmc_manual()
    β_parameter_array = readdlm(joinpath(@__DIR__, "parameters", "1_parameter_array.csv"), ';', Float64, '\n')
    c_parameter_array = readdlm(joinpath(@__DIR__, "parameters", "2_parameter_array.csv"), ';', Float64, '\n')
    γ_parameter_array = readdlm(joinpath(@__DIR__, "parameters", "3_parameter_array.csv"), ';', Float64, '\n')
    num_mcmc_runs = length(β_parameter_array)
    error_array = zeros(Float64, num_mcmc_runs)

    open(joinpath(@__DIR__, "mcmc.txt"),"r") do datafile
        lines = eachline(datafile)
        line_num = 1
        for line in lines
            if line_num == 1 || abs(β_parameter_array[line_num] - β_parameter_array[line_num - 1]) > 0.0001
                error_array[line_num] = parse.(Float64, line)
            else
                error_array[line_num] = error_array[line_num - 1]
            end
            line_num += 1
        end
    end

    xlabel_name = "Step"
    ylabel_name = "RMSE"

    println(error_array)

    error_plot = plot(
        1:num_mcmc_runs,
        # moving_average(error_array, 10),
        error_array,
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
    savefig(error_plot, joinpath(@__DIR__, "plot_mcmc_manual.pdf"))
end

function plot_mcmc_metropolis_manual()
    β_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis", "1_parameter_array.csv"), ';', Float64, '\n')
    c_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis", "2_parameter_array.csv"), ';', Float64, '\n')
    γ_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis", "3_parameter_array.csv"), ';', Float64, '\n')
    num_mcmc_runs = length(β_parameter_array)
    error_array = zeros(Float64, num_mcmc_runs)

    open(joinpath(@__DIR__, "mcmc_metropolis.txt"),"r") do datafile
        lines = eachline(datafile)
        line_num = 1
        for line in lines
            if line_num == 1 || abs(β_parameter_array[line_num] - β_parameter_array[line_num - 1]) > 0.0001
                error_array[line_num] = parse.(Float64, line)
            else
                error_array[line_num] = error_array[line_num - 1]
            end
            line_num += 1
        end
    end

    xlabel_name = "Step"
    ylabel_name = "RMSE"

    # error_plot = plot(
    #     1:num_mcmc_runs,
    #     moving_average(error_array, 10),
    #     # error_array,
    #     lw = 1.5,
    #     grid = true,
    #     legend = false,
    #     color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )
    error_plot = plot(
        1:500,
        moving_average(error_array[1:500], 10),
        lw = 1.5,
        grid = true,
        legend = false,
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(error_plot, joinpath(@__DIR__, "plot_mcmc_metropolis_manual.pdf"))
end

function plot_swarm_hypercube()
    num_swarm_runs = 50
    num_particles = 20

    error_arr = Array{Float64, 1}(undef, num_swarm_runs + 1)
    β_parameter = Array{Float64, 1}(undef, num_swarm_runs + 1)
    c_parameter = Array{Float64, 1}(undef, num_swarm_runs + 1)
    γ_parameter = Array{Float64, 1}(undef, num_swarm_runs + 1)

    xlabel_name = "Step"
    ylabel_name = "RMSE"

    error_arr[1] = load(joinpath(@__DIR__, "swarm", "0", "results_1.jld"))["error"]
    β_parameter[1] = load(joinpath(@__DIR__, "swarm", "0", "results_1.jld"))["β_parameter"]
    c_parameter[1] = load(joinpath(@__DIR__, "swarm", "0", "results_1.jld"))["c_parameter"]
    γ_parameter[1] = load(joinpath(@__DIR__, "swarm", "0", "results_1.jld"))["γ_parameter"]
    for i = 1:num_swarm_runs
        error_arr[i + 1] = load(joinpath(@__DIR__, "swarm", "1", "results_$(i).jld"))["error"]
        β_parameter[i + 1] = load(joinpath(@__DIR__, "swarm", "1", "results_$(i).jld"))["β_parameter"]
        c_parameter[i + 1] = load(joinpath(@__DIR__, "swarm", "1", "results_$(i).jld"))["c_parameter"]
        γ_parameter[i + 1] = load(joinpath(@__DIR__, "swarm", "1", "results_$(i).jld"))["γ_parameter"]
    end

    error_plot = plot(
        1:(num_swarm_runs + 1),
        moving_average(error_arr, 10),
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
        error_arr[1] = load(joinpath(@__DIR__, "swarm", "0", "results_$(j).jld"))["error"]
        β_parameter[1] = load(joinpath(@__DIR__, "swarm", "0", "results_$(j).jld"))["β_parameter"]
        c_parameter[1] = load(joinpath(@__DIR__, "swarm", "0", "results_$(j).jld"))["c_parameter"]
        γ_parameter[1] = load(joinpath(@__DIR__, "swarm", "0", "results_$(j).jld"))["γ_parameter"]
        for i = 1:num_swarm_runs
            error_arr[i + 1] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["error"]
            β_parameter[i + 1] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["β_parameter"]
            c_parameter[i + 1] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["c_parameter"]
            γ_parameter[i + 1] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["γ_parameter"]
        end

        plot!(
            1:(num_swarm_runs + 1),
            moving_average(error_arr, 10),
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

    savefig(error_plot, joinpath(@__DIR__, "plot_swarm_hypercube.pdf"))
end

function plot_surrogate_hypercube()
    num_surrogate_runs = 200

    error_arr = Array{Float64, 1}(undef, num_surrogate_runs)
    β_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    c_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    γ_parameter = Array{Float64, 1}(undef, num_surrogate_runs)

    xlabel_name = "Step"
    ylabel_name = "RMSE"

    for i = 1:num_surrogate_runs
        error_arr[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["error"]
        β_parameter[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["β_parameter"]
        c_parameter[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["c_parameter"]
        γ_parameter[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["γ_parameter"]
    end

    error_plot = plot(
        1:num_surrogate_runs,
        moving_average(error_arr, 10),
        lw = 1.5,
        grid = true,
        legend = false,
        color = RGB(0.0, 0.0, 0.0),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    savefig(error_plot, joinpath(@__DIR__, "plot_surrogate_hypercube.pdf"))
end

function plot_surrogate_hypercube_NN()
    num_surrogate_runs = 100

    error_arr = Array{Float64, 1}(undef, num_surrogate_runs)
    β_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    c_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    γ_parameter = Array{Float64, 1}(undef, num_surrogate_runs)

    xlabel_name = "Step"
    ylabel_name = "RMSE"

    for i = 1:num_surrogate_runs
        error_arr[i] = load(joinpath(@__DIR__, "surrogate_NN", "results_$(i).jld"))["error"]
        β_parameter[i] = load(joinpath(@__DIR__, "surrogate_NN", "results_$(i).jld"))["β_parameter"]
        c_parameter[i] = load(joinpath(@__DIR__, "surrogate_NN", "results_$(i).jld"))["c_parameter"]
        γ_parameter[i] = load(joinpath(@__DIR__, "surrogate_NN", "results_$(i).jld"))["γ_parameter"]
    end

    open(joinpath(@__DIR__, "..", "..", "..", "parameters", "output_metropolis_manual.txt"),"r") do datafile
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

    error_plot = plot(
        1:num_surrogate_runs,
        moving_average(error_arr, 10),
        lw = 1.5,
        grid = true,
        legend = false,
        color = RGB(0.0, 0.0, 0.0),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    savefig(error_plot, joinpath(@__DIR__, "plot_surrogate_hypercube_NN.pdf"))
end

function optimization_methods()
    num_error_points = 1456

    β_parameter_array = readdlm(joinpath(@__DIR__, "parameters_lhs", "1_parameter_array.csv"), ';', Float64, '\n')
    c_parameter_array = readdlm(joinpath(@__DIR__, "parameters_lhs", "2_parameter_array.csv"), ';', Float64, '\n')
    γ_parameter_array = readdlm(joinpath(@__DIR__, "parameters_lhs", "3_parameter_array.csv"), ';', Float64, '\n')
    I0_parameter_array = readdlm(joinpath(@__DIR__, "parameters_lhs", "4_parameter_array.csv"), ';', Float64, '\n')
    num_mcmc_runs = length(β_parameter_array)
    error_array = zeros(Float64, num_mcmc_runs)

    open(joinpath(@__DIR__, "mcmc_lhs.txt"),"r") do datafile
        lines = eachline(datafile)
        line_num = 1
        for line in lines
            if line_num == 1 || ((abs(β_parameter_array[line_num] - β_parameter_array[line_num - 1]) > 0.0001) && (abs(γ_parameter_array[line_num] - γ_parameter_array[line_num - 1]) > 0.0001))
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
        1:200,
        # moving_average(error_array[1:200], 3),
        error_array[1:200],
        lw = 1.5,
        grid = true,
        label = "MCMC LHS",
        color = RGB(0.267, 0.467, 0.667),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # min_argument = argmin(error_array[1:200])
    # println("MCMC LHS")
    # println(error_array[min_argument])
    # println(min_argument)
    # println(β_parameter_array[min_argument])
    # println(c_parameter_array[min_argument])
    # println(γ_parameter_array[min_argument])
    # println(I0_parameter_array[min_argument])
    # println()
    # return

    β_parameter_array = readdlm(joinpath(@__DIR__, "parameters", "1_parameter_array.csv"), ';', Float64, '\n')
    c_parameter_array = readdlm(joinpath(@__DIR__, "parameters", "2_parameter_array.csv"), ';', Float64, '\n')
    γ_parameter_array = readdlm(joinpath(@__DIR__, "parameters", "3_parameter_array.csv"), ';', Float64, '\n')
    I0_parameter_array = readdlm(joinpath(@__DIR__, "parameters", "4_parameter_array.csv"), ';', Float64, '\n')
    num_mcmc_runs = length(β_parameter_array)
    error_array = zeros(Float64, num_mcmc_runs)

    open(joinpath(@__DIR__, "mcmc.txt"),"r") do datafile
        lines = eachline(datafile)
        line_num = 1
        for line in lines
            if line_num == 1 || ((abs(β_parameter_array[line_num] - β_parameter_array[line_num - 1]) > 0.0001) && (abs(γ_parameter_array[line_num] - γ_parameter_array[line_num - 1]) > 0.0001))
                error_array[line_num] = parse.(Float64, line)
            else
                error_array[line_num] = error_array[line_num - 1]
            end
            line_num += 1
        end
    end

    xlabel_name = "Step"
    ylabel_name = "RMSE"

    plot!(
        1:200,
        moving_average(error_array[1:200], 3),
        # error_array[1:500],
        lw = 1.5,
        grid = true,
        label = "MCMC manual",
        color = RGB(0.933, 0.4, 0.467),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # min_argument = argmin(error_array[1:200])
    # println(error_array[min_argument])
    # println("MCMC manual")
    # println(min_argument)
    # println(β_parameter_array[min_argument])
    # println(c_parameter_array[min_argument])
    # println(γ_parameter_array[min_argument])
    # println(I0_parameter_array[min_argument])
    # println()
    # return

    # β_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "1_parameter_array.csv"), ';', Float64, '\n')
    # c_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "2_parameter_array.csv"), ';', Float64, '\n')
    # γ_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "3_parameter_array.csv"), ';', Float64, '\n')
    # I0_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "4_parameter_array.csv"), ';', Float64, '\n')
    # num_mcmc_runs = length(β_parameter_array)
    # error_array = zeros(Float64, num_mcmc_runs)

    # open(joinpath(@__DIR__, "mcmc_metropolis_lhs.txt"),"r") do datafile
    #     lines = eachline(datafile)
    #     line_num = 1
    #     for line in lines
    #         if line_num == 1 || ((abs(β_parameter_array[line_num] - β_parameter_array[line_num - 1]) > 0.0001) && (abs(γ_parameter_array[line_num] - γ_parameter_array[line_num - 1]) > 0.0001))
    #             error_array[line_num] = parse.(Float64, line)
    #         else
    #             error_array[line_num] = error_array[line_num - 1]
    #         end
    #         line_num += 1
    #     end
    # end

    # xlabel_name = "Step"
    # ylabel_name = "RMSE"

    # plot!(
    #     1:200,
    #     moving_average(error_array[1:200], 3),
    #     # error_array[1:500],
    #     lw = 1.5,
    #     grid = true,
    #     label = "MA LHS",
    #     color = RGB(0.133, 0.533, 0.2),
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )

    # min_argument = argmin(error_array[1:200])
    # println(error_array[min_argument])
    # println("MA LHS")
    # println(minimum(error_array[1:200]))
    # println(min_argument)
    # println(β_parameter_array[min_argument])
    # println(c_parameter_array[min_argument])
    # println(γ_parameter_array[min_argument])
    # println(I0_parameter_array[min_argument])
    # println()
    # return

    # β_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis", "1_parameter_array.csv"), ';', Float64, '\n')
    # c_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis", "2_parameter_array.csv"), ';', Float64, '\n')
    # γ_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis", "3_parameter_array.csv"), ';', Float64, '\n')
    # I0_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis", "4_parameter_array.csv"), ';', Float64, '\n')
    # num_mcmc_runs = length(β_parameter_array)
    # error_array = zeros(Float64, num_mcmc_runs)

    # open(joinpath(@__DIR__, "mcmc_metropolis.txt"),"r") do datafile
    #     lines = eachline(datafile)
    #     line_num = 1
    #     for line in lines
    #         if line_num == 1 || ((abs(β_parameter_array[line_num] - β_parameter_array[line_num - 1]) > 0.0001) && (abs(γ_parameter_array[line_num] - γ_parameter_array[line_num - 1]) > 0.0001))
    #             error_array[line_num] = parse.(Float64, line)
    #         else
    #             error_array[line_num] = error_array[line_num - 1]
    #         end
    #         line_num += 1
    #     end
    # end

    # xlabel_name = "Step"
    # ylabel_name = "RMSE"

    # plot!(
    #     1:200,
    #     moving_average(error_array[1:200], 3),
    #     # error_array[1:500],
    #     lw = 1.5,
    #     grid = true,
    #     label = "MA manual",
    #     color = RGB(0.667, 0.2, 0.467),
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )

    # min_argument = argmin(error_array[1:200])
    # println(error_array[min_argument])
    # println("MA manual")
    # println(minimum(error_array[1:200]))
    # println(min_argument)
    # println(β_parameter_array[min_argument])
    # println(c_parameter_array[min_argument])
    # println(γ_parameter_array[min_argument])
    # println(I0_parameter_array[min_argument])
    # println()
    # return

    num_surrogate_runs = 200

    # error_arr = Array{Float64, 1}(undef, num_surrogate_runs + 1)
    error_arr = Array{Float64, 1}(undef, num_surrogate_runs)
    β_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    c_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    γ_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    I0_parameter = Array{Float64, 1}(undef, num_surrogate_runs)

    # error_arr[1] = 0.18346184538653368

    xlabel_name = "Step"
    ylabel_name = "RMSE"

    for i = 1:num_surrogate_runs
        # error_arr[i + 1] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["error"]
        error_arr[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["error"]
        β_parameter[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["β_parameter"]
        c_parameter[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["c_parameter"]
        γ_parameter[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["γ_parameter"]
        I0_parameter[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["I0_parameter"]
    end

    plot!(
        1:num_surrogate_runs,
        # moving_average(error_arr[1:num_surrogate_runs], 3),
        error_arr[1:num_surrogate_runs],
        lw = 1.5,
        grid = true,
        label = "SM",
        color = RGB(0.133, 0.533, 0.2),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # min_argument = argmin(error_arr[1:200])
    # println(error_arr[min_argument])
    # println(min_argument)
    # println("SM LHS")
    # println(β_parameter[min_argument])
    # println(c_parameter[min_argument])
    # println(γ_parameter[min_argument])
    # println(I0_parameter[min_argument])
    # println()
    # return

    num_swarm_runs = 20
    num_particles = 10

    # error_arr = Array{Float64, 1}(undef, num_swarm_runs * num_particles +  num_particles)
    # β_parameter = Array{Float64, 1}(undef, num_swarm_runs * num_particles +  num_particles)
    # c_parameter = Array{Float64, 1}(undef, num_swarm_runs * num_particles +  num_particles)
    # γ_parameter = Array{Float64, 1}(undef, num_swarm_runs * num_particles +  num_particles)
    # I0_parameter = Array{Float64, 1}(undef, num_swarm_runs * num_particles +  num_particles)
    error_arr = Array{Float64, 1}(undef, num_swarm_runs * num_particles)
    β_parameter = Array{Float64, 1}(undef, num_swarm_runs * num_particles)
    c_parameter = Array{Float64, 1}(undef, num_swarm_runs * num_particles)
    γ_parameter = Array{Float64, 1}(undef, num_swarm_runs * num_particles)
    I0_parameter = Array{Float64, 1}(undef, num_swarm_runs * num_particles)

    error_arr_temp = Array{Float64, 1}(undef, num_particles)
    β_parameter_temp = Array{Float64, 1}(undef, num_particles)
    c_parameter_temp = Array{Float64, 1}(undef, num_particles)
    γ_parameter_temp = Array{Float64, 1}(undef, num_particles)
    I0_parameter_temp = Array{Float64, 1}(undef, num_particles)

    xlabel_name = "Step"
    ylabel_name = "RMSE"

    # error_arr[1] = 0.18346184538653368

    # for j = 1:num_particles
    #     error_arr_temp[j] = load(joinpath(@__DIR__, "lhs", "results_$(j).jld"))["error"]
    #     β_parameter_temp[j] = load(joinpath(@__DIR__, "lhs", "results_$(j).jld"))["β_parameter"]
    #     c_parameter_temp[j] = load(joinpath(@__DIR__, "lhs", "results_$(j).jld"))["c_parameter"]
    #     γ_parameter_temp[j] = load(joinpath(@__DIR__, "lhs", "results_$(j).jld"))["γ_parameter"]
    #     I0_parameter_temp[j] = load(joinpath(@__DIR__, "lhs", "results_$(j).jld"))["I0_parameter"]
    # end
    # for j = 1:num_particles
    #     error_arr[j] = minimum(error_arr_temp)
    #     error_arr[j] += 25.0
    #     β_parameter[j] = β_parameter_temp[argmin(error_arr_temp)]
    #     c_parameter[j] = c_parameter_temp[argmin(error_arr_temp)]
    #     γ_parameter[j] = γ_parameter_temp[argmin(error_arr_temp)]
    #     I0_parameter[j] = I0_parameter_temp[argmin(error_arr_temp)]
    # end

    # println(β_parameter[1])
    # println(c_parameter[1])
    # println(γ_parameter[1])
    # println(I0_parameter[1])
    # return

    # println(error_arr[1])
    # println(error_arr[5])
    # println(error_arr[10])

    for i = 1:num_swarm_runs
        for j = 1:num_particles
            error_arr_temp[j] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["error"]
            β_parameter_temp[j] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["β_parameter"]
            c_parameter_temp[j] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["c_parameter"]
            γ_parameter_temp[j] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["γ_parameter"]
            I0_parameter_temp[j] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["I0_parameter"]
        end
        for j = 1:num_particles
            error_arr[(i - 1) * num_particles + j] = minimum(error_arr_temp)
            β_parameter[(i - 1) * num_particles + j] = β_parameter_temp[argmin(error_arr_temp)]
            c_parameter[(i - 1) * num_particles + j] = c_parameter_temp[argmin(error_arr_temp)]
            γ_parameter[(i - 1) * num_particles + j] = γ_parameter_temp[argmin(error_arr_temp)]
            I0_parameter[(i - 1) * num_particles + j] = I0_parameter_temp[argmin(error_arr_temp)]
            # error_arr[num_particles + (i - 1) * num_particles + j] = minimum(error_arr_temp)
            # β_parameter[num_particles + (i - 1) * num_particles + j] = β_parameter_temp[argmin(error_arr_temp)]
            # c_parameter[num_particles + (i - 1) * num_particles + j] = c_parameter_temp[argmin(error_arr_temp)]
            # γ_parameter[num_particles + (i - 1) * num_particles + j] = γ_parameter_temp[argmin(error_arr_temp)]
            # I0_parameter[num_particles + (i - 1) * num_particles + j] = I0_parameter_temp[argmin(error_arr_temp)]
        end
    end

    plot!(
        1:200,
        moving_average(error_arr[1:200], 3),
        # error_arr[1:(num_swarm_runs * num_particles)],
        lw = 1.5,
        grid = true,
        label = "PSO",
        legend = (0.74, 0.98),
        color = RGB(0.667, 0.2, 0.467),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # println(minimum(error_arr[1:10]))

    # min_argument = argmin(error_arr[1:200])
    # println("PSO")
    # println(error_arr[min_argument])
    # println(min_argument)
    # println(β_parameter[min_argument])
    # println(c_parameter[min_argument])
    # println(γ_parameter[min_argument])
    # println(I0_parameter[min_argument])
    # println()
    # return

    num_ga_runs = 20
    population_size = 10

    # error_arr = Array{Float64, 1}(undef, num_ga_runs + 1)
    # error_arr = Array{Float64, 1}(undef, num_ga_runs * population_size + population_size)
    # β_parameter = Array{Float64, 1}(undef, num_ga_runs * population_size + population_size)
    # c_parameter = Array{Float64, 1}(undef, num_ga_runs * population_size + population_size)
    # γ_parameter = Array{Float64, 1}(undef, num_ga_runs * population_size + population_size)
    # I0_parameter = Array{Float64, 1}(undef, num_ga_runs * population_size + population_size)
    error_arr = Array{Float64, 1}(undef, num_ga_runs * population_size)
    β_parameter = Array{Float64, 1}(undef, num_ga_runs * population_size)
    c_parameter = Array{Float64, 1}(undef, num_ga_runs * population_size)
    γ_parameter = Array{Float64, 1}(undef, num_ga_runs * population_size)
    I0_parameter = Array{Float64, 1}(undef, num_ga_runs * population_size)

    error_arr_temp = Array{Float64, 1}(undef, population_size)
    β_parameter_temp = Array{Float64, 1}(undef, population_size)
    c_parameter_temp = Array{Float64, 1}(undef, population_size)
    γ_parameter_temp = Array{Float64, 1}(undef, population_size)
    I0_parameter_temp = Array{Float64, 1}(undef, population_size)

    # error_arr[1] = 0.18346184538653368

    xlabel_name = "Step"
    ylabel_name = "RMSE"

    # for j = 1:population_size
    #     error_arr_temp[j] = load(joinpath(@__DIR__, "lhs", "results_$(j).jld"))["error"]
    #     β_parameter_temp[j] = load(joinpath(@__DIR__, "lhs", "results_$(j).jld"))["β_parameter"]
    #     c_parameter_temp[j] = load(joinpath(@__DIR__, "lhs", "results_$(j).jld"))["c_parameter"]
    #     γ_parameter_temp[j] = load(joinpath(@__DIR__, "lhs", "results_$(j).jld"))["γ_parameter"]
    #     I0_parameter_temp[j] = load(joinpath(@__DIR__, "lhs", "results_$(j).jld"))["I0_parameter"]
    # end
    # for j = 1:population_size
    #     error_arr[j] = minimum(error_arr_temp)
    #     β_parameter[j] = β_parameter_temp[argmin(error_arr_temp)]
    #     c_parameter[j] = c_parameter_temp[argmin(error_arr_temp)]
    #     γ_parameter[j] = γ_parameter_temp[argmin(error_arr_temp)]
    #     I0_parameter[j] = I0_parameter_temp[argmin(error_arr_temp)]
    # end

    # println(error_arr[1])
    # println(error_arr[5])
    # println(error_arr[10])
    # println(minimum(error_arr[1:10]))
    # return

    for i = 1:num_ga_runs
        for j = 1:population_size
            error_arr_temp[j] = load(joinpath(@__DIR__, "ga", "$(i)", "results_$(j).jld"))["error"]
            β_parameter_temp[j] = load(joinpath(@__DIR__, "ga", "$(i)", "results_$(j).jld"))["β_parameter"]
            c_parameter_temp[j] = load(joinpath(@__DIR__, "ga", "$(i)", "results_$(j).jld"))["c_parameter"]
            γ_parameter_temp[j] = load(joinpath(@__DIR__, "ga", "$(i)", "results_$(j).jld"))["γ_parameter"]
            I0_parameter_temp[j] = load(joinpath(@__DIR__, "ga", "$(i)", "results_$(j).jld"))["I0_parameter"]
        end
        for j = 1:population_size
            error_arr[(i - 1) * population_size + j] = minimum(error_arr_temp)
            β_parameter[(i - 1) * population_size + j] = β_parameter_temp[argmin(error_arr_temp)]
            c_parameter[(i - 1) * population_size + j] = c_parameter_temp[argmin(error_arr_temp)]
            γ_parameter[(i - 1) * population_size + j] = γ_parameter_temp[argmin(error_arr_temp)]
            I0_parameter[(i - 1) * population_size + j] = I0_parameter_temp[argmin(error_arr_temp)]
            # error_arr[population_size + (i - 1) * population_size + j] = minimum(error_arr_temp)
            # β_parameter[population_size + (i - 1) * population_size + j] = β_parameter_temp[argmin(error_arr_temp)]
            # c_parameter[population_size + (i - 1) * population_size + j] = c_parameter_temp[argmin(error_arr_temp)]
            # γ_parameter[population_size + (i - 1) * population_size + j] = γ_parameter_temp[argmin(error_arr_temp)]
            # I0_parameter[population_size + (i - 1) * population_size + j] = I0_parameter_temp[argmin(error_arr_temp)]
        end
    end

    # println(minimum(error_arr[1:10]))
    # return

    plot!(
        1:200,
        moving_average(error_arr[1:200], 3),
        lw = 1.5,
        grid = true,
        label = "GA",
        color = RGB(0.8, 0.733, 0.267),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # min_argument = argmin(error_arr[1:200])
    # println("GA")
    # println(error_arr[min_argument])
    # println(min_argument)
    # println(β_parameter[min_argument])
    # println(c_parameter[min_argument])
    # println(γ_parameter[min_argument])
    # println(I0_parameter[min_argument])
    # println()
    # return

    savefig(error_plot, joinpath(@__DIR__, "optimization_methods.pdf"))
end

# plot_mcmc_manual()
# plot_mcmc_metropolis_manual()
# plot_swarm_hypercube()
# plot_surrogate_hypercube()

optimization_methods()

# plot_surrogate_hypercube_NN()
