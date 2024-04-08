using DelimitedFiles
using Plots
using DataFrames
using Statistics
using Distributions
using LaTeXStrings
using JLD
using CSV
using Random

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
    nMAE_array = zeros(Float64, num_mcmc_runs)

    open(joinpath(@__DIR__, "mcmc.txt"),"r") do datafile
        lines = eachline(datafile)
        line_num = 1
        for line in lines
            if line_num == 1 || abs(β_parameter_array[line_num] - β_parameter_array[line_num - 1]) > 0.0001
                nMAE_array[line_num] = parse.(Float64, line)
            else
                nMAE_array[line_num] = nMAE_array[line_num - 1]
            end
            line_num += 1
        end
    end

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    println(nMAE_array)

    nMAE_plot = plot(
        1:num_mcmc_runs,
        # moving_average(nMAE_array, 10),
        nMAE_array,
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
    savefig(nMAE_plot, joinpath(@__DIR__, "plot_mcmc_manual.pdf"))
end

function plot_mcmc_metropolis_manual()
    β_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis", "1_parameter_array.csv"), ';', Float64, '\n')
    c_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis", "2_parameter_array.csv"), ';', Float64, '\n')
    γ_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis", "3_parameter_array.csv"), ';', Float64, '\n')
    num_mcmc_runs = length(β_parameter_array)
    nMAE_array = zeros(Float64, num_mcmc_runs)

    open(joinpath(@__DIR__, "mcmc_metropolis.txt"),"r") do datafile
        lines = eachline(datafile)
        line_num = 1
        for line in lines
            if line_num == 1 || abs(β_parameter_array[line_num] - β_parameter_array[line_num - 1]) > 0.0001
                nMAE_array[line_num] = parse.(Float64, line)
            else
                nMAE_array[line_num] = nMAE_array[line_num - 1]
            end
            line_num += 1
        end
    end

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    # nMAE_plot = plot(
    #     1:num_mcmc_runs,
    #     moving_average(nMAE_array, 10),
    #     # nMAE_array,
    #     lw = 1.5,
    #     grid = true,
    #     legend = false,
    #     color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )
    nMAE_plot = plot(
        1:800,
        moving_average(nMAE_array[1:800], 10),
        lw = 1.5,
        grid = true,
        legend = false,
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(nMAE_plot, joinpath(@__DIR__, "plot_mcmc_metropolis_manual.pdf"))
end

function plot_swarm_hypercube()
    num_swarm_runs = 50
    num_particles = 20

    nMAE_arr = Array{Float64, 1}(undef, num_swarm_runs + 1)
    β_parameter = Array{Float64, 1}(undef, num_swarm_runs + 1)
    c_parameter = Array{Float64, 1}(undef, num_swarm_runs + 1)
    γ_parameter = Array{Float64, 1}(undef, num_swarm_runs + 1)

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    nMAE_arr[1] = load(joinpath(@__DIR__, "swarm", "0", "results_1.jld"))["nMAE"]
    β_parameter[1] = load(joinpath(@__DIR__, "swarm", "0", "results_1.jld"))["β_parameter"]
    c_parameter[1] = load(joinpath(@__DIR__, "swarm", "0", "results_1.jld"))["c_parameter"]
    γ_parameter[1] = load(joinpath(@__DIR__, "swarm", "0", "results_1.jld"))["γ_parameter"]
    for i = 1:num_swarm_runs
        nMAE_arr[i + 1] = load(joinpath(@__DIR__, "swarm", "1", "results_$(i).jld"))["nMAE"]
        β_parameter[i + 1] = load(joinpath(@__DIR__, "swarm", "1", "results_$(i).jld"))["β_parameter"]
        c_parameter[i + 1] = load(joinpath(@__DIR__, "swarm", "1", "results_$(i).jld"))["c_parameter"]
        γ_parameter[i + 1] = load(joinpath(@__DIR__, "swarm", "1", "results_$(i).jld"))["γ_parameter"]
    end

    nMAE_plot = plot(
        1:(num_swarm_runs + 1),
        moving_average(nMAE_arr, 10),
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
        nMAE_arr[1] = load(joinpath(@__DIR__, "swarm", "0", "results_$(j).jld"))["nMAE"]
        β_parameter[1] = load(joinpath(@__DIR__, "swarm", "0", "results_$(j).jld"))["β_parameter"]
        c_parameter[1] = load(joinpath(@__DIR__, "swarm", "0", "results_$(j).jld"))["c_parameter"]
        γ_parameter[1] = load(joinpath(@__DIR__, "swarm", "0", "results_$(j).jld"))["γ_parameter"]
        for i = 1:num_swarm_runs
            nMAE_arr[i + 1] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["nMAE"]
            β_parameter[i + 1] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["β_parameter"]
            c_parameter[i + 1] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["c_parameter"]
            γ_parameter[i + 1] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["γ_parameter"]
        end

        plot!(
            1:(num_swarm_runs + 1),
            moving_average(nMAE_arr, 10),
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

    savefig(nMAE_plot, joinpath(@__DIR__, "plot_swarm_hypercube.pdf"))
end

function plot_surrogate_hypercube()
    num_surrogate_runs = 250

    nMAE_arr = Array{Float64, 1}(undef, num_surrogate_runs)
    β_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    c_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    γ_parameter = Array{Float64, 1}(undef, num_surrogate_runs)

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    for i = 1:num_surrogate_runs
        nMAE_arr[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["nMAE"]
        β_parameter[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["β_parameter"]
        c_parameter[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["c_parameter"]
        γ_parameter[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["γ_parameter"]
    end

    nMAE_plot = plot(
        1:num_surrogate_runs,
        moving_average(nMAE_arr, 10),
        lw = 1.5,
        grid = true,
        legend = false,
        color = RGB(0.0, 0.0, 0.0),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    savefig(nMAE_plot, joinpath(@__DIR__, "plot_surrogate_hypercube.pdf"))
end

function plot_surrogate_hypercube_NN()
    num_surrogate_runs = 100

    nMAE_arr = Array{Float64, 1}(undef, num_surrogate_runs)
    β_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    c_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    γ_parameter = Array{Float64, 1}(undef, num_surrogate_runs)

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    for i = 1:num_surrogate_runs
        nMAE_arr[i] = load(joinpath(@__DIR__, "surrogate_NN", "results_$(i).jld"))["nMAE"]
        β_parameter[i] = load(joinpath(@__DIR__, "surrogate_NN", "results_$(i).jld"))["β_parameter"]
        c_parameter[i] = load(joinpath(@__DIR__, "surrogate_NN", "results_$(i).jld"))["c_parameter"]
        γ_parameter[i] = load(joinpath(@__DIR__, "surrogate_NN", "results_$(i).jld"))["γ_parameter"]
    end

    nMAE_plot = plot(
        1:num_surrogate_runs,
        moving_average(nMAE_arr, 10),
        lw = 1.5,
        grid = true,
        legend = false,
        color = RGB(0.0, 0.0, 0.0),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    savefig(nMAE_plot, joinpath(@__DIR__, "plot_surrogate_hypercube_NN.pdf"))
end

function plot_all()
    β_parameter_array = readdlm(joinpath(@__DIR__, "parameters", "1_parameter_array.csv"), ';', Float64, '\n')
    c_parameter_array = readdlm(joinpath(@__DIR__, "parameters", "2_parameter_array.csv"), ';', Float64, '\n')
    γ_parameter_array = readdlm(joinpath(@__DIR__, "parameters", "3_parameter_array.csv"), ';', Float64, '\n')
    num_mcmc_runs = length(β_parameter_array)
    nMAE_array = zeros(Float64, num_mcmc_runs)

    open(joinpath(@__DIR__, "mcmc.txt"),"r") do datafile
        lines = eachline(datafile)
        line_num = 1
        for line in lines
            if line_num == 1 || abs(β_parameter_array[line_num] - β_parameter_array[line_num - 1]) > 0.0001
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
        1:200,
        moving_average(nMAE_array[1:200], 10),
        lw = 1.5,
        grid = true,
        label = "MCMC",
        color = RGB(0.267, 0.467, 0.667),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    β_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis", "1_parameter_array.csv"), ';', Float64, '\n')
    c_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis", "2_parameter_array.csv"), ';', Float64, '\n')
    γ_parameter_array = readdlm(joinpath(@__DIR__, "parameters_metropolis", "3_parameter_array.csv"), ';', Float64, '\n')
    num_mcmc_runs = length(β_parameter_array)
    nMAE_array = zeros(Float64, num_mcmc_runs)

    open(joinpath(@__DIR__, "mcmc_metropolis.txt"),"r") do datafile
        lines = eachline(datafile)
        line_num = 1
        for line in lines
            if line_num == 1 || abs(β_parameter_array[line_num] - β_parameter_array[line_num - 1]) > 0.0001
                nMAE_array[line_num] = parse.(Float64, line)
            else
                nMAE_array[line_num] = nMAE_array[line_num - 1]
            end
            line_num += 1
        end
    end

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    plot!(
        1:200,
        moving_average(nMAE_array[1:200], 10),
        lw = 1.5,
        grid = true,
        label = "MH",
        color = RGB(0.933, 0.4, 0.467),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    num_surrogate_runs = 200

    nMAE_arr = Array{Float64, 1}(undef, num_surrogate_runs)
    β_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    c_parameter = Array{Float64, 1}(undef, num_surrogate_runs)
    γ_parameter = Array{Float64, 1}(undef, num_surrogate_runs)

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    for i = 1:num_surrogate_runs
        nMAE_arr[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["nMAE"]
        β_parameter[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["β_parameter"]
        c_parameter[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["c_parameter"]
        γ_parameter[i] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["γ_parameter"]
    end

    plot!(
        1:num_surrogate_runs,
        moving_average(nMAE_arr, 10),
        lw = 1.5,
        grid = true,
        label = "SM",
        color = RGB(0.133, 0.533, 0.2),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # RGB(0.667, 0.2, 0.467)


    num_swarm_runs = 50
    num_particles = 20

    nMAE_arr = Array{Float64, 1}(undef, num_swarm_runs)
    nMAE_arr_temp = Array{Float64, 1}(undef, 20)

    xlabel_name = "Шаг"
    ylabel_name = "nMAE"

    for i = 1:50
        for j = 1:20
            nMAE_arr_temp[j] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["nMAE"]
        end
        nMAE_arr[i] = minimum(nMAE_arr_temp)
    end

    plot!(
        1:50,
        moving_average(nMAE_arr, 10),
        lw = 1.5,
        grid = true,
        label = "PSO_20",
        legend = (0.35, 0.98),
        color = RGB(0.667, 0.2, 0.467),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )

    # nMAE_arr[1] = load(joinpath(@__DIR__, "swarm", "0", "results_1.jld"))["nMAE"]
    # for i = 1:num_swarm_runs
    #     nMAE_arr[i + 1] = load(joinpath(@__DIR__, "swarm", "1", "results_$(i).jld"))["nMAE"]
    # end

    # nMAE_plot = plot(
    #     1:(num_swarm_runs + 1),
    #     moving_average(nMAE_arr, 10),
    #     lw = 1.5,
    #     grid = true,
    #     legend = false,
    #     # color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
    #     color = RGB(0.0, 0.0, 0.0),
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )

    # for j = 2:num_particles
    #     nMAE_arr[1] = load(joinpath(@__DIR__, "swarm", "0", "results_$(j).jld"))["nMAE"]
    #     for i = 1:num_swarm_runs
    #         nMAE_arr[i + 1] = load(joinpath(@__DIR__, "swarm", "$(j)", "results_$(i).jld"))["nMAE"]
    #     end

    #     plot!(
    #         1:(num_swarm_runs + 1),
    #         moving_average(nMAE_arr, 10),
    #         lw = 1.5,
    #         grid = true,
    #         legend = false,
    #         # color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
    #         # color = RGB(0.0, 0.0, 0.0),
    #         foreground_color_legend = nothing,
    #         background_color_legend = nothing,
    #         xlabel = xlabel_name,
    #         ylabel = ylabel_name,
    #     )
    # end

    savefig(nMAE_plot, joinpath(@__DIR__, "all_plot.pdf"))
end

# plot_mcmc_manual()
# plot_mcmc_metropolis_manual()
# plot_swarm_hypercube()
plot_surrogate_hypercube()

plot_all()

# plot_surrogate_hypercube_NN()
