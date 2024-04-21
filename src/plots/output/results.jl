using DelimitedFiles
using Statistics
using StatsPlots
using Plots
using LaTeXStrings
using JLD
using CSV
using DataFrames
using Distributions

include("../../../server/lib/util/moving_avg.jl")
include("../../../server/lib/data/etiology.jl")
include("../../../server/lib/data/incidence.jl")
include("../../../server/lib/global/variables.jl")

default(legendfontsize = 9, guidefont = (12, :black), tickfont = (11, :black))

const is_russian = false
const num_years = 1
const num_runs = 1
const population_coef = 10072

function confidence(x::Vector{Float64}, tstar::Float64 = 2.35)
    SE = std(x) / sqrt(length(x))
    return tstar * SE
end

function plot_incidence_methods()
    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"] ./ population_coef
        if type == 2
            isolation_probabilities_day_1 = [0.406, 0.305, 0.204, 0.101]
            isolation_probabilities_day_2 = [0.669, 0.576, 0.499, 0.334]
            isolation_probabilities_day_3 = [0.45, 0.325, 0.376, 0.168]
            symptomatic_probability_child = [0.38, 0.38, 0.19, 0.24, 0.15, 0.16, 0.21]
            symptomatic_probability_teenager= [0.47, 0.47, 0.24, 0.3, 0.19, 0.2, 0.26]
            symptomatic_probability_adult = [0.57, 0.57, 0.29, 0.36, 0.23, 0.24, 0.32]
            for virus_id in 1:num_viruses
                observed_num_infected_age_groups_viruses[:, virus_id, 1] ./= symptomatic_probability_child[virus_id] * (1 - (1 - isolation_probabilities_day_1[1]) * (1 - isolation_probabilities_day_2[1]) * (1 - isolation_probabilities_day_3[1]))
                observed_num_infected_age_groups_viruses[:, virus_id, 2] ./= symptomatic_probability_child[virus_id] * (1 - (1 - isolation_probabilities_day_1[2]) * (1 - isolation_probabilities_day_2[2]) * (1 - isolation_probabilities_day_3[2]))
                observed_num_infected_age_groups_viruses[:, virus_id, 3] ./= symptomatic_probability_teenager[virus_id] * (1 - (1 - isolation_probabilities_day_1[3]) * (1 - isolation_probabilities_day_2[3]) * (1 - isolation_probabilities_day_3[3]))
                observed_num_infected_age_groups_viruses[:, virus_id, 4] ./= symptomatic_probability_adult[virus_id] * (1 - (1 - isolation_probabilities_day_1[4]) * (1 - isolation_probabilities_day_2[4]) * (1 - isolation_probabilities_day_3[4]))
            end
        end
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    confidence_model = zeros(Float64, 52)
    for i = 1:52
        confidence_model[i] = confidence([incidence_arr[k, j][i] for j = 1:num_years for k = 1:num_runs], 4.27)
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean[i] += incidence_arr[k, j][i]
            end
        end
        incidence_arr_mean[i] /= num_runs * num_years
    end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ';', Int, '\n') ./ population_coef
    infected_data_mean = mean(infected_data[2:53, flu_starting_index:end], dims = 2)[:, 1]

    confidence_data = zeros(Float64, 52)
    for i = 1:52
        confidence_data[i] = confidence(infected_data[i + 1, flu_starting_index:end], 2.45)
    end

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["model" "data"]
    if is_russian
        label_names = ["модель" "данные"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    nMAE = sum(abs.(incidence_arr_mean - infected_data_mean)) / sum(infected_data_mean)
    println("Incidence nMAE = $(nMAE)")

    ribbon = nothing
    if num_years > 1
        ribbon = [confidence_model confidence_data]
    end
    incidence_plot = plot(
        1:52,
        [incidence_arr_mean infected_data_mean],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = true,
        legend = (0.9, 0.98),
        ylim = (0.0, maximum([maximum(incidence_arr_mean) + maximum(confidence_model), maximum(infected_data_mean) + maximum(confidence_data)])),
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        # ribbon = ribbon,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "model_incidence_quarantine.pdf" : with_global_warming ? "model_incidence_warming.pdf" : "model_incidence.pdf"))
end

function plot_incidence(
    # 1 - выявленная заболеваемость, 2 - вся заболеваемость
    type::Int = 1,
    with_quarantine::Bool = false,
    with_global_warming::Bool = false,
)
    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ population_coef
        if type == 2
            isolation_probabilities_day_1 = [0.406, 0.305, 0.204, 0.101]
            isolation_probabilities_day_2 = [0.669, 0.576, 0.499, 0.334]
            isolation_probabilities_day_3 = [0.45, 0.325, 0.376, 0.168]
            symptomatic_probability_child = [0.38, 0.38, 0.19, 0.24, 0.15, 0.16, 0.21]
            symptomatic_probability_teenager= [0.47, 0.47, 0.24, 0.3, 0.19, 0.2, 0.26]
            symptomatic_probability_adult = [0.57, 0.57, 0.29, 0.36, 0.23, 0.24, 0.32]
            for virus_id in 1:num_viruses
                observed_num_infected_age_groups_viruses[:, virus_id, 1] ./= symptomatic_probability_child[virus_id] * (1 - (1 - isolation_probabilities_day_1[1]) * (1 - isolation_probabilities_day_2[1]) * (1 - isolation_probabilities_day_3[1]))
                observed_num_infected_age_groups_viruses[:, virus_id, 2] ./= symptomatic_probability_child[virus_id] * (1 - (1 - isolation_probabilities_day_1[2]) * (1 - isolation_probabilities_day_2[2]) * (1 - isolation_probabilities_day_3[2]))
                observed_num_infected_age_groups_viruses[:, virus_id, 3] ./= symptomatic_probability_teenager[virus_id] * (1 - (1 - isolation_probabilities_day_1[3]) * (1 - isolation_probabilities_day_2[3]) * (1 - isolation_probabilities_day_3[3]))
                observed_num_infected_age_groups_viruses[:, virus_id, 4] ./= symptomatic_probability_adult[virus_id] * (1 - (1 - isolation_probabilities_day_1[4]) * (1 - isolation_probabilities_day_2[4]) * (1 - isolation_probabilities_day_3[4]))
            end
        end
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    confidence_model = zeros(Float64, 52)
    for i = 1:52
        confidence_model[i] = confidence([incidence_arr[k, j][i] for j = 1:num_years for k = 1:num_runs], 4.27)
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean[i] += incidence_arr[k, j][i]
            end
        end
        incidence_arr_mean[i] /= num_runs * num_years
    end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ';', Int, '\n') ./ population_coef
    infected_data_mean = mean(infected_data[2:53, flu_starting_index:end], dims = 2)[:, 1]

    confidence_data = zeros(Float64, 52)
    for i = 1:52
        confidence_data[i] = confidence(infected_data[i + 1, flu_starting_index:end], 2.45)
    end

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["model" "data"]
    if is_russian
        label_names = ["модель" "данные"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    nMAE = sum(abs.(incidence_arr_mean - infected_data_mean)) / sum(infected_data_mean)
    println("Incidence nMAE = $(nMAE)")

    ribbon = nothing
    if num_years > 1
        ribbon = [confidence_model confidence_data]
    end
    incidence_plot = plot(
        1:52,
        [incidence_arr_mean infected_data_mean],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = true,
        legend = (0.9, 0.98),
        ylim = (0.0, maximum([maximum(incidence_arr_mean) + maximum(confidence_model), maximum(infected_data_mean) + maximum(confidence_data)])),
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        # ribbon = ribbon,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "model_incidence_quarantine.pdf" : with_global_warming ? "model_incidence_warming.pdf" : "model_incidence.pdf"))
end

function plot_incidence_age_groups(
    with_quarantine::Bool = false,
    with_global_warming::Bool = false,
)
    incidence_arr = Array{Matrix{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52, 4)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ population_coef
        for j = 1:num_years
            incidence_arr[i, j] = sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :][(52 * (j - 1) + 1):(52 * (j - 1) + 52), :]
        end
    end

    for i = 1:52
        for k = 1:4
            for j = 1:num_runs
                for z = 1:num_years
                    incidence_arr_mean[i, k] += incidence_arr[j, z][i, k]
                end
            end
            incidence_arr_mean[i, k] /= num_runs * num_years
        end
    end

    confidence_model = zeros(Float64, 52, 4)
    for i = 1:52
        for k = 1:4
            confidence_model[i, k] = confidence([incidence_arr[j, z][i, k] for j = 1:num_runs for z = 1:num_years], 4.27)
        end
    end

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ';', Int, '\n') ./ population_coef
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ';', Int, '\n') ./ population_coef
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ';', Int, '\n') ./ population_coef
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ';', Int, '\n') ./ population_coef

    infected_data_mean = cat(
        mean(infected_data_0[2:53, flu_starting_index:end], dims = 2)[:, 1],
        mean(infected_data_3[2:53, flu_starting_index:end], dims = 2)[:, 1],
        mean(infected_data_7[2:53, flu_starting_index:end], dims = 2)[:, 1],
        mean(infected_data_15[2:53, flu_starting_index:end], dims = 2)[:, 1],
        dims = 2,
    )

    confidence_data = zeros(Float64, 52, 4)
    for i = 1:52
        confidence_data[i, 1] = confidence(infected_data_0[i + 1, flu_starting_index:end], 2.45)
        confidence_data[i, 2] = confidence(infected_data_3[i + 1, flu_starting_index:end], 2.45)
        confidence_data[i, 3] = confidence(infected_data_7[i + 1, flu_starting_index:end], 2.45)
        confidence_data[i, 4] = confidence(infected_data_15[i + 1, flu_starting_index:end], 2.45)
    end

    ticks = range(1, stop = 52, length = 7)

    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["model" "data"]
    if is_russian
        label_names = ["модель" "данные"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    age_groups = ["0-2", "3-6", "7-14", "15+"]
    for i = 1:4
        nMAE = sum(abs.(incidence_arr_mean[:, i] - infected_data_mean[:, i])) / sum(infected_data_mean[:, i])
        println("$(age_groups[i]) nMAE = $(nMAE)")

        ribbon = nothing
        if num_years > 1
            ribbon = [confidence_model[:, i] confidence_data[:, i]]
        end

        incidence_plot = plot(
            1:52,
            [incidence_arr_mean[:, i] infected_data_mean[:, i]],
            lw = 1.5,
            xticks = (ticks, ticklabels),
            label = label_names,
            grid = true,
            legend = (0.9, 0.98),
            ylim = (0.0, maximum([maximum(incidence_arr_mean[:, i]) + maximum(confidence_model[:, i]), maximum(infected_data_mean[:, i]) + maximum(confidence_data[:, i])])),
            color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
            # ribbon = ribbon,
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
        savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "incidence$(age_groups[i])_quarantine.pdf" : with_global_warming ? "incidence$(age_groups[i])_warming.pdf" : "incidence$(age_groups[i]).pdf"))
    end
end

function plot_incidence_viruses(
    with_quarantine::Bool = false,
    with_global_warming::Bool = false,
)
    incidence_arr = Array{Matrix{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52, 7)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ population_coef
        for j = 1:num_years
            incidence_arr[i, j] = sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52), :]
        end
    end

    for i = 1:52
        for k = 1:num_viruses
            for j = 1:num_runs
                for z = 1:num_years
                    incidence_arr_mean[i, k] += incidence_arr[j, z][i, k]
                end
            end
            incidence_arr_mean[i, k] /= num_runs * num_years
        end
    end

    confidence_model = zeros(Float64, 52, 7)
    for i = 1:52
        for k = 1:num_viruses
            confidence_model[i, k] = confidence([incidence_arr[j, z][i, k] for j = 1:num_runs for z = 1:num_years], 4.27)
        end
    end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ';', Int, '\n') ./ population_coef

    infected_data = infected_data[2:53, flu_starting_index:end]
    etiology = get_etiology()

    infected_data_1 = etiology[:, 1] .* infected_data
    infected_data_2 = etiology[:, 2] .* infected_data
    infected_data_3 = etiology[:, 3] .* infected_data
    infected_data_4 = etiology[:, 4] .* infected_data
    infected_data_5 = etiology[:, 5] .* infected_data
    infected_data_6 = etiology[:, 6] .* infected_data
    infected_data_7 = etiology[:, 7] .* infected_data
    infected_data_viruses_conf = cat(
        infected_data_1,
        infected_data_2,
        infected_data_3,
        infected_data_4,
        infected_data_5,
        infected_data_6,
        infected_data_7,
        dims = 3)
        infected_data_viruses_mean = cat(
        mean(infected_data_1, dims = 2)[:, 1],
        mean(infected_data_2, dims = 2)[:, 1],
        mean(infected_data_3, dims = 2)[:, 1],
        mean(infected_data_4, dims = 2)[:, 1],
        mean(infected_data_5, dims = 2)[:, 1],
        mean(infected_data_6, dims = 2)[:, 1],
        mean(infected_data_7, dims = 2)[:, 1],
        dims = 2)


    infected_data_viruses_confidence = zeros(Float64, 52, 7)
    for i = 1:52
        for j = 1:num_viruses
            infected_data_viruses_confidence[i, j] = confidence(infected_data_viruses_conf[i, :, j], 2.45)
        end
    end

    ticks = range(1, stop = 52, length = 7)

    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["model" "data"]
    if is_russian
        label_names = ["модель" "данные"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    viruses = ["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"]
    for i in 1:num_viruses
        nMAE = sum(abs.(incidence_arr_mean[:, i] - infected_data_viruses_mean[:, i])) / sum(infected_data_viruses_mean[:, i])
        println("$(viruses[i]) nMAE = $(nMAE)")

        ribbon = nothing
        if num_years > 1
            ribbon = [confidence_model[:, i] infected_data_viruses_confidence[:, i]]
        end

        incidence_plot = plot(
            1:52,
            [incidence_arr_mean[:, i] infected_data_viruses_mean[:, i]],
            lw = 1.5,
            xticks = (ticks, ticklabels),
            label = label_names,
            ylim = (0.0, maximum([maximum(incidence_arr_mean[:, i]) + maximum(confidence_model[:, i]), maximum(infected_data_viruses_mean[:, i]) + maximum(infected_data_viruses_confidence[:, i])])),
            grid = true,
            legend = (0.9, 0.98),
            color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
            ribbon = ribbon,
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
        savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "incidence$(viruses[i])_quarantine.pdf" : with_global_warming ? "incidence$(viruses[i])_warming.pdf" : "incidence$(viruses[i]).pdf"))
    end
end

function plot_incidence_viruses_together(
    with_quarantine::Bool = false,
    with_global_warming::Bool = false,
)
    incidence_arr = Array{Matrix{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52, 7)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ population_coef
        for j = 1:num_years
            incidence_arr[i, j] = sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52), :]
        end
    end

    for i = 1:52
        for k = 1:num_viruses
            for j = 1:num_runs
                for z = 1:num_years
                    incidence_arr_mean[i, k] += incidence_arr[j, z][i, k]
                end
            end
            incidence_arr_mean[i, k] /= num_runs * num_years
        end
    end

    confidence_model = zeros(Float64, 52, 7)
    for i = 1:52
        for k = 1:num_viruses
            confidence_model[i, k] = confidence([incidence_arr[j, z][i, k] for j = 1:num_runs for z = 1:num_years], 4.27)
        end
    end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ';', Int, '\n') ./ population_coef

    infected_data = infected_data[2:53, flu_starting_index:end]

    ticks = range(1, stop = 52, length = 7)

    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    incidence_plot = plot(
        1:52,
        [incidence_arr_mean[:, i] for i = 1:num_viruses],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        grid = true,
        legend = (0.9, 0.98),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "incidence_viruses_together.pdf"))
end

function plot_incidence_age_groups_viruses_together(
    with_quarantine::Bool = false,
    with_global_warming::Bool = false,
)
    incidence_arr = Array{Array{Float64, 3}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52, 7, 4)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ population_coef
        for j = 1:num_years
            incidence_arr[i, j] = observed_num_infected_age_groups_viruses[(52 * (j - 1) + 1):(52 * (j - 1) + 52), :, :]
        end
    end

    for i = 1:52
        for k = 1:num_viruses
            for m = 1:4
                for j = 1:num_runs
                    for z = 1:num_years
                        incidence_arr_mean[i, k, m] += incidence_arr[j, z][i, k, m]
                    end
                end
                incidence_arr_mean[i, k, m] /= num_runs * num_years
            end
        end
    end

    confidence_model = zeros(Float64, 52, 7, 4)
    for i = 1:52
        for k = 1:num_viruses
            for m = 1:4
                confidence_model[i, k, m] = confidence([incidence_arr[j, z][i, k, m] for j = 1:num_runs for z = 1:num_years], 2.45)
            end
        end
    end

    etiology = get_etiology()

    ticks = range(1, stop = 52, length = 7)

    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    age_groups = ["0", "3", "7", "15"]
    for i in 1:4
        incidence_plot = plot(
            1:52,
            [incidence_arr_mean[:, j, i] for j = 1:num_viruses],
            lw = 1.5,
            xticks = (ticks, ticklabels),
            label = label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
            grid = true,
            legend = (0.9, 0.98),
            ylim = (0.0, maximum(incidence_arr_mean[:, 1, i]) + maximum(confidence_model[:, 1, i])),
            color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
            ribbon = [confidence_model[:, 1, i] confidence_model[:, 2, i] confidence_model[:, 3, i] confidence_model[:, 4, i] confidence_model[:, 5, i] confidence_model[:, 6, i] confidence_model[:, 7, i]],
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
        savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "incidence_$(age_groups[i])_viruses.pdf"))
    end
end

function plot_rt(
    with_quarantine::Bool = false,
    with_global_warming::Bool = false,
)
    rt_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    rt_arr_mean = zeros(Float64, 365)

    for i = 1:num_runs
        rt = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["rt"]
        for j = 1:num_years
            rt_arr[i, j] = moving_average(rt, 20)[(365 * (j - 1) + 1):(365 * (j - 1) + 365)]
        end
    end

    rt_arr_mean = zeros(Float64, 365)
    for i = 1:365
        for j = 1:num_runs
            for z = 1:num_years
                rt_arr_mean[i] += rt_arr[j, z][i]
            end
        end
        rt_arr_mean[i] /= num_runs * num_years
    end

    confidence_model = zeros(Float64, 365)
    for i = 1:365
        confidence_model[i] = confidence([rt_arr[k, j][i] for j = 1:num_years for k = 1:num_runs], 4.27)
    end

    ticks = range(1, stop = 365, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = L"R_t"
    
    yticks = [0.6, 0.8, 1.0, 1.2]
    yticklabels = ["0.6", "0.8", "1.0", "1.2"]

    rt_plot = plot(
        1:365,
        rt_arr_mean,
        lw = 1.5,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        legend = false,
        color = RGB(0.0, 0.0, 0.0),
        grid = true,
        ribbon = confidence_model,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(
        rt_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "rt_quarantine.pdf" : with_global_warming ? "rt_warming.pdf" : "rt.pdf"))
end

function plot_infection_activities(
    with_quarantine::Bool = false,
    with_global_warming::Bool = false,
)
    num_activities = 5

    activity_sizes = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "activity_sizes.csv"), ';', Int, '\n')

    activities_cases_arr = Array{Matrix{Float64}, 2}(undef, num_runs, num_years)
    activities_cases_arr_mean = zeros(Float64, 365, num_activities)

    for i = 1:num_runs
        activities_cases = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["activities_cases"]
        for j = 1:num_years
            activities_cases_arr[i, j] = activities_cases[(365 * (j - 1) + 1):(365 * (j - 1) + 365), :]
        end
    end

    activities_cases_arr_mean = zeros(Float64, 365, num_activities)
    for i = 1:365
        for k = 1:num_activities
            for j = 1:num_runs
                for z = 1:num_years
                    activities_cases_arr_mean[i, k] += activities_cases_arr[j, z][i, k]
                end
            end
            activities_cases_arr_mean[i, k] /= num_runs * num_years
        end
    end

    for i = 1:num_activities
        activities_cases_arr_mean[:, i] ./= activity_sizes[i]
        activities_cases_arr_mean[:, i] .*= 100
    end

    confidence_model = zeros(Float64, num_activities)
    for i = 1:num_activities
        confidence_model[i] = confidence(activities_cases_arr_mean[:, i], 1.96)
    end

    xlabel_name = "Activity"
    if is_russian
        xlabel_name = "Коллектив"
    end

    ylabel_name = "Ratio, %"
    if is_russian
        ylabel_name = "Доля, %"
    end

    ticks = [1, 2, 3, 4, 5]
    ticklabels = ["Daycare" "School" "College" "Work" "Home"]
    if is_russian
        ticklabels = ["Детсад" "Школа" "Вуз" "Работа" "Дом"]
    end

    yticks = [0.0, 0.4, 0.8, 1.2]
    yticklabels = ["0.0", "0.4", "0.8", "1.2"]

    mean_values = [mean(activities_cases_arr_mean[:, i]) for i = 1:num_activities]

    activities_cases_plot = bar(
        [1, 2, 3, 4, 5],
        mean_values,
        grid = true,
        legend = false,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        yerr = confidence_model,
        color = RGB(0.5, 0.5, 0.5),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(activities_cases_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "activities_cases_quarantine.pdf" : with_global_warming ? "activities_cases_warming.pdf" : "activities_cases.pdf"))
end

function plot_incidence_time_series(
    with_quarantine::Bool = false,
    with_global_warming::Bool = false,
)
    incidence_arr = Array{Vector{Float64}, 1}(undef, num_runs)
    incidence_arr_mean = zeros(Float64, 52 * num_years)
    
    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ population_coef
        incidence_arr[i] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]
    end

    for i = 1:(52 * num_years)
        for k = 1:num_runs
            incidence_arr_mean[i] += incidence_arr[k][i]
        end
        incidence_arr_mean[i] /= num_runs
    end    

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ';', Int, '\n') ./ population_coef
    infected_data = vec(infected_data[2:53, flu_starting_index:(flu_starting_index + num_years - 1)])

    ticks = range(1, stop = (52.14285 * num_years), length = 19)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["model" "data"]
    if is_russian
        label_names = ["модель" "данные"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    incidence_plot = plot(
        1:(52 * num_years),
        [incidence_arr_mean infected_data],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        margin = 6Plots.mm,
        xrotation = 45,
        grid = true,
        legend = (0.9, 0.98),
        size = (800, 500),
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "model_incidence_quarantine_time_series.pdf" : with_global_warming ? "model_incidence_warming_time_series.pdf" : "model_incidence_time_series.pdf"))
end

function plot_incidence_age_groups_time_series(
    with_quarantine::Bool = false,
    with_global_warming::Bool = false,
)
    incidence_arr = Array{Matrix{Float64}, 1}(undef, num_runs)
    incidence_arr_mean = zeros(Float64, 52 * num_years, 4)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ population_coef
        incidence_arr[i] = sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :]
    end

    for i = 1:(52 * num_years)
        for k = 1:4
            for j = 1:num_runs
                incidence_arr_mean[i, k] += incidence_arr[j][i, k]
            end
            incidence_arr_mean[i, k] /= num_runs
        end
    end

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ';', Int, '\n') ./ population_coef
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ';', Int, '\n') ./ population_coef
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ';', Int, '\n') ./ population_coef
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ';', Int, '\n') ./ population_coef

    infected_data_mean = cat(
        vec(infected_data_0[2:53, flu_starting_index:(flu_starting_index + num_years - 1)]),
        vec(infected_data_3[2:53, flu_starting_index:(flu_starting_index + num_years - 1)]),
        vec(infected_data_7[2:53, flu_starting_index:(flu_starting_index + num_years - 1)]),
        vec(infected_data_15[2:53, flu_starting_index:(flu_starting_index + num_years - 1)]),
        dims = 2,
    )

    ticks = range(1, stop = (52.14285 * num_years), length = 19)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["model" "data"]
    if is_russian
        label_names = ["модель" "данные"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    age_groups = ["0-2", "3-6", "7-14", "15+"]
    for i = 1:4
        incidence_plot = plot(
            1:(52 * num_years),
            [incidence_arr_mean[:, i] infected_data_mean[:, i]],
            lw = 1.5,
            xticks = (ticks, ticklabels),
            label = label_names,
            margin = 6Plots.mm,
            xrotation = 45,
            grid = true,
            size = (800, 500),
            legend = (0.9, 0.98),
            color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
        savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "incidence$(age_groups[i])_quarantine_time_series.pdf" : with_global_warming ? "incidence$(age_groups[i])_warming_time_series.pdf" : "incidence$(age_groups[i])_time_series.pdf"))
    end
end

function plot_incidence_viruses_time_series(
    with_quarantine::Bool = false,
    with_global_warming::Bool = false,
)
    incidence_arr = Array{Matrix{Float64}, 1}(undef, num_runs)
    incidence_arr_mean = zeros(Float64, (52 * num_years), 7)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["observed_cases"] ./ population_coef
        incidence_arr[i] = sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1]
    end

    for i = 1:(52 * num_years)
        for k = 1:num_viruses
            for j = 1:num_runs
                incidence_arr_mean[i, k] += incidence_arr[j][i, k]
            end
            incidence_arr_mean[i, k] /= num_runs
        end
    end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ';', Int, '\n') ./ population_coef
    infected_data = infected_data[2:53, flu_starting_index:(flu_starting_index + num_years - 1)]
    
    etiology = get_etiology()

    infected_data_1 = etiology[:, 1] .* infected_data
    infected_data_2 = etiology[:, 2] .* infected_data
    infected_data_3 = etiology[:, 3] .* infected_data
    infected_data_4 = etiology[:, 4] .* infected_data
    infected_data_5 = etiology[:, 5] .* infected_data
    infected_data_6 = etiology[:, 6] .* infected_data
    infected_data_7 = etiology[:, 7] .* infected_data
    infected_data_viruses = cat(
        vec(infected_data_1),
        vec(infected_data_2),
        vec(infected_data_3),
        vec(infected_data_4),
        vec(infected_data_5),
        vec(infected_data_6),
        vec(infected_data_7),
        dims = 2)

    ticks = range(1, stop = (52.14285 * num_years), length = 19)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["model" "data"]
    if is_russian
        label_names = ["модель" "данные"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    viruses = ["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"]
    for i in 1:num_viruses
        nMAE = sum(abs.(incidence_arr_mean[:, i] - infected_data_viruses[:, i])) / sum(infected_data_viruses[:, i])
        println("$(viruses[i]) nMAE = $(nMAE)")
    end

    viruses = ["FluA", "FluB", "RV", "RSV", "AdV", "PIV", "CoV"]
    for i in 1:num_viruses
        incidence_plot = plot(
            1:(52 * num_years),
            [incidence_arr_mean[:, i] infected_data_viruses[:, i]],
            lw = 1.5,
            xticks = (ticks, ticklabels),
            label = label_names,
            margin = 6Plots.mm,
            xrotation = 45,
            grid = true,
            size = (800, 500),
            legend = (0.9, 0.98),
            color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
            foreground_color_legend = nothing,
            background_color_legend = nothing,
            xlabel = xlabel_name,
            ylabel = ylabel_name,
        )
        savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "incidence$(viruses[i])_quarantine_time_series.pdf" : with_global_warming ? "incidence$(viruses[i])_warming_time_series.pdf" : "incidence$(viruses[i])_time_series.pdf"))
    end
end

function plot_rt_time_series()
    rt_arr = Array{Vector{Float64}, 1}(undef, num_runs)
    rt_arr_mean = zeros(Float64, (365 * num_years))

    for i = 1:num_runs
        rt = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))["rt"]
        rt_arr[i] = moving_average(rt, 20)
    end

    rt_arr_mean = zeros(Float64, (365 * num_years))
    for i = 1:(365 * num_years)
        for j = 1:num_runs
            rt_arr_mean[i] += rt_arr[j][i]
        end
        rt_arr_mean[i] /= num_runs
    end

    ticks = range(1, stop = (365 * num_years), length = 19)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = L"R_t"
    
    rt_plot = plot(
        1:(365 * num_years),
        rt_arr_mean,
        lw = 1.5,
        xticks = (ticks, ticklabels),
        margin = 6Plots.mm,
        xrotation = 45,
        legend = false,
        color = RGB(0.0, 0.0, 0.0),
        grid = true,
        size = (800, 500),
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(
        rt_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", with_quarantine ? "rt_quarantine_time_series.pdf" : with_global_warming ? "rt_warming_time_series.pdf" : "rt_time_series.pdf"))
end

function plot_incidence_quarantine()
    num_runs_quarantine = 3
    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs_quarantine + 1, num_years)

    observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_1.jld"))["observed_cases"] ./ population_coef
    for j = 1:num_years
        incidence_arr[1, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
    end

    for i = 1:num_runs_quarantine
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_quarantine_$(i).jld"))["observed_cases"] ./ population_coef
        for j = 1:num_years
            incidence_arr[i + 1, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ';', Int, '\n') ./ population_coef
    infected_data = infected_data[2:53, flu_starting_index:end]

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["base" "20%" "10%" "30%"]
    if is_russian
        label_names = ["без карантина" "порог 0.2, 7 дней" "порог 0.1, 7 дней" "порог 0.3, 7 дней" "порог 0.2, 14 дней" "порог 0.1, 14 дней"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    incidence_arr_mean = Array{Vector{Float64}, 1}(undef, num_runs_quarantine + 1)
    for i = 1:num_runs_quarantine + 1
        incidence_arr_mean[i] = zeros(Float64, 52)
        for j = 1:52
            for k = 1:num_years
                incidence_arr_mean[i][j] += incidence_arr[i, k][j]
            end
        end
        incidence_arr_mean[i] /= num_years
    end

    confidence_model_1 = zeros(Float64, 52)
    for i = 1:52
        confidence_model_1[i] = confidence([incidence_arr[1, j][i] for j = 1:num_years], 2.9)
    end
    confidence_model_2 = zeros(Float64, 52)
    for i = 1:52
        confidence_model_2[i] = confidence([incidence_arr[2, j][i] for j = 1:num_years], 2.9)
    end
    confidence_model_3 = zeros(Float64, 52)
    for i = 1:52
        confidence_model_3[i] = confidence([incidence_arr[3, j][i] for j = 1:num_years], 2.9)
    end
    confidence_model_4 = zeros(Float64, 52)
    for i = 1:52
        confidence_model_4[i] = confidence([incidence_arr[4, j][i] for j = 1:num_years], 2.9)
    end

    incidence_plot = plot(
        1:52,
        [incidence_arr_mean[i][1:52] for i = 1:(num_runs_quarantine + 1)],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        margin = 4Plots.mm,
        grid = true,
        legend = (0.68, 0.98),
        ylim = (0.0, maximum(incidence_arr_mean[1]) + maximum(confidence_model_1)),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        # ribbon = [confidence_model_1 confidence_model_2 confidence_model_3 confidence_model_4],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "model_incidence_quarantine.pdf"))
end

function plot_incidence_warming()
    num_runs_warming = 4
    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs_warming + 1, num_years)

    observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_1.jld"))["observed_cases"] ./ population_coef
    for j = 1:num_years
        incidence_arr[1, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
    end

    for i = 1:num_runs_warming
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_warming_$(i).jld"))["observed_cases"] ./ population_coef
        for j = 1:num_years
            incidence_arr[i + 1, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["+0 °С" "+1 °С" "+2 °С" "+3 °С" "+4 °С"]
    if is_russian
        label_names = ["+0 °С" "+1 °С" "+2 °С" "+3 °С" "+4 °С"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    # println("Ratio of the max number of infected")
    # println(1 - maximum(incidence_arr[2]) / maximum(incidence_arr[1]))
    # println(1 - maximum(incidence_arr[3]) / maximum(incidence_arr[1]))
    # println(1 - maximum(incidence_arr[4]) / maximum(incidence_arr[1]))
    # println(1 - maximum(incidence_arr[5]) / maximum(incidence_arr[1]))

    # println("Max pos")
    # println(argmax(incidence_arr[1]))
    # println(argmax(incidence_arr[2]))
    # println(argmax(incidence_arr[3]))
    # println(argmax(incidence_arr[4]))
    # println(argmax(incidence_arr[5]))

    incidence_arr_mean = Array{Vector{Float64}, 1}(undef, num_runs_warming + 1)
    for i = 1:num_runs_warming + 1
        incidence_arr_mean[i] = zeros(Float64, 52)
        for j = 1:52
            for k = 1:num_years
                incidence_arr_mean[i][j] += incidence_arr[i, k][j]
            end
        end
        incidence_arr_mean[i] /= num_years
    end

    incidence_plot = plot(
        1:52,
        [incidence_arr_mean[i] for i = 1:(num_runs_warming + 1)],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        margin = 4Plots.mm,
        grid = true,
        legend = (0.75, 0.98),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "model_incidence_warming.pdf"))
end

function plot_school_closures()
    num_runs_quarantine = 3
    num_schools_closed = Array{Vector{Float64}, 2}(undef, num_runs_quarantine + 1, num_years)
    
    for i = 1:num_years
        num_schools_closed[1, i] = zeros(Float64, 365)
    end
    for i = 1:num_runs_quarantine
        num_schools_closed_temp = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_quarantine_$(i).jld"))["num_schools_closed"][1:(365 * num_years)]
        for j = 1:num_years
            num_schools_closed[i + 1, j] = num_schools_closed_temp[(365 * (j - 1) + 1):(365 * (j - 1) + 365)]
        end
    end

    ticks = range(1, stop = 365, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Number of school closures"
    if is_russian
        ylabel_name = "Число закрытий"
    end

    label_names = ["базовый" "порог 0.2" "порог 0.1" "порог 0.3"]
    if is_russian
        label_names = ["base" "20%" "10%" "30%"]
    end

    label_names = ["base" "20%" "10%" "30%"]

    num_schools_closed_mean = zeros(Float64, num_runs_quarantine + 1, 365)
    for i = 1:(num_runs_quarantine + 1)
        for j = 1:num_years
            num_schools_closed[i, j] = moving_average(num_schools_closed[i, j], 10)
        end

        for j = 1:365
            num_schools_closed_mean[i, j] = mean([num_schools_closed[i, j][j] for j = 1:num_years])
        end
    end

    closures_plot = plot(
        1:365,
        [num_schools_closed[i, 1] for i = 1:(num_runs_quarantine + 1)],
        lw = 1.5,
        label = label_names,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        xticks = (ticks, ticklabels),
        grid = true,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )

    savefig(closures_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "num_closures_time_series.pdf"))
end

function plot_warming_temperatures()
    num_runs_temp = 4

    # temperature_data_rearranged = Array{Vector{Float64}, 1}(undef, num_runs_temp + 1)
    
    # temperature_data = Matrix(DataFrame(CSV.File("./input/tables/temperature.csv")))
    # temperature_data_rearranged[1] = Float64[]
    # append!(temperature_data_rearranged[1], temperature_data[213:365])
    # append!(temperature_data_rearranged[1], temperature_data[1:212])

    # # append!(temperature_data_rearranged[1], temperature_data[578:730])
    # # append!(temperature_data_rearranged[1], temperature_data[366:577])

    # # append!(temperature_data_rearranged[1], temperature_data[943:1095])
    # # append!(temperature_data_rearranged[1], temperature_data[731:942])

    # for i = 1:num_runs_temp
    #     temperature_data = Matrix(DataFrame(CSV.File("./input/tables/temperature.csv"))) .+ i

    #     temperature_data_rearranged[i + 1] = Float64[]
    #     append!(temperature_data_rearranged[i + 1], temperature_data[213:365])
    #     append!(temperature_data_rearranged[i + 1], temperature_data[1:212])

    #     # append!(temperature_data_rearranged[i + 1], temperature_data[578:730])
    #     # append!(temperature_data_rearranged[i + 1], temperature_data[366:577])

    #     # append!(temperature_data_rearranged[i + 1], temperature_data[943:1095])
    #     # append!(temperature_data_rearranged[i + 1], temperature_data[731:942])
    # end
    
    global_warming_temps = [1.0, 2.0, 3.0, 4.0]

    temperature_data = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "temperature.csv"))))[1, :]
    temperature = copy(temperature_data[213:365])
    append!(temperature, temperature_data[1:212])

    temperature_1 = copy(temperature)
    temperature_2 = copy(temperature)
    temperature_3 = copy(temperature)
    temperature_4 = copy(temperature)

    for i = 1:length(temperature)
        temperature_1[i] += rand(Normal(global_warming_temps[1], 0.25))
    end
    for i = 1:length(temperature)
        temperature_2[i] += rand(Normal(global_warming_temps[2], 0.25))
    end
    for i = 1:length(temperature)
        temperature_3[i] += rand(Normal(global_warming_temps[3], 0.25))
    end
    for i = 1:length(temperature)
        temperature_4[i] += rand(Normal(global_warming_temps[4], 0.25))
    end

    ticks = range(1, stop = 365, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["+0 °С" "+1 °С" "+2 °С" "+3 °С" "+4 °С"]

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Temperature, °C"
    if is_russian
        ylabel_name = "Температура, °C"
    end

    temperature_plot = plot(
        1:365,
        [temperature temperature_1 temperature_2 temperature_3 temperature_4],
        lw = 1.5,
        label = label_names,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        xticks = (ticks, ticklabels),
        grid = true,
        margin = 6Plots.mm,
        legend = (0.51, 0.91),
        xlabel = xlabel_name,
        ylabel = ylabel_name,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )

    savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "temperature.pdf"))
end

function print_scenario_statistics(quarantine_index::Int, warming_index::Int)
    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_$(i).jld"))["observed_cases"]
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean[i] += incidence_arr[k, j][i]
            end
        end
        incidence_arr_mean[i] /= num_runs * num_years
    end

    max_value = maximum(incidence_arr_mean)
    all_number_observed_infections = sum(incidence_arr_mean)
    pos = argmax(incidence_arr_mean)

    incidence_arr_mean = zeros(Float64, 52)
    for i = 1:1
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_quarantine_$(quarantine_index).jld"))["observed_cases"]
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean[i] += incidence_arr[k, j][i]
            end
        end
        incidence_arr_mean[i] /= num_runs * num_years
    end

    max_value_quarantine = maximum(incidence_arr_mean)
    all_number_observed_infections_quarantine = sum(incidence_arr_mean)
    pos_quarantine = argmax(incidence_arr_mean)

    incidence_arr_mean = zeros(Float64, 52)
    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_warming_$(warming_index).jld"))["observed_cases"]
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean[i] += incidence_arr[k, j][i]
            end
        end
        incidence_arr_mean[i] /= num_runs * num_years
    end

    max_value_warming = maximum(incidence_arr_mean)
    all_number_observed_infections_warming = sum(incidence_arr_mean)
    pos_warming = argmax(incidence_arr_mean)

    println("Ratio of the max number of infected - quaranteen: $(1 - max_value_quarantine / max_value)")
    println("Ratio of the number of observed infections - quaranteen: $(1 - all_number_observed_infections_quarantine / all_number_observed_infections)")
    println("Ratio of the max number of infected - warming: $(1 - max_value_warming / max_value)")
    println("Ratio of the number of observed infections - warming: $(1 - all_number_observed_infections_warming / all_number_observed_infections)")
    println("Max pos: $(pos)")
    println("Max pos quaranteen: $(pos_quarantine)")
    println("Max pos warming: $(pos_warming)")
end

function plot_incidence_preferential_attachment(
    type::String = "observed_cases",
    with_quarantine::Bool = false,
    with_global_warming::Bool = false,
)
    incidence_arr = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", with_quarantine ? "results_quarantine_$(i).jld" : with_global_warming ? "results_warming_$(i).jld" : "results_$(i).jld"))[type] ./ population_coef
        for j = 1:num_years
            incidence_arr[i, j] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    confidence_model = zeros(Float64, 52)
    for i = 1:52
        confidence_model[i] = confidence([incidence_arr[k, j][i] for j = 1:num_years for k = 1:num_runs], 2.45)
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean[i] += incidence_arr[k, j][i]
            end
        end
        incidence_arr_mean[i] /= num_runs * num_years
    end

    incidence_arr_2 = Array{Vector{Float64}, 2}(undef, num_runs, num_years)
    incidence_arr_mean_2 = zeros(Float64, 52)

    for i = 1:num_runs
        observed_num_infected_age_groups_viruses_2 = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_0.jld"))[type] ./ population_coef
        for j = 1:num_years
            incidence_arr_2[i, j] = sum(sum(observed_num_infected_age_groups_viruses_2, dims = 3)[:, :, 1], dims = 2)[:, 1][(52 * (j - 1) + 1):(52 * (j - 1) + 52)]
        end
    end

    confidence_model_2 = zeros(Float64, 52)
    for i = 1:52
        confidence_model_2[i] = confidence([incidence_arr_2[k, j][i] for j = 1:num_years for k = 1:num_runs])
    end

    for i = 1:52
        for j = 1:num_years
            for k = 1:num_runs
                incidence_arr_mean_2[i] += incidence_arr_2[k, j][i]
            end
        end
        incidence_arr_mean_2[i] /= num_runs * num_years
    end

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["model" "data"]
    if is_russian
        label_names = ["с предп. соед." "без предп. соед."]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    incidence_plot = plot(
        1:52,
        [incidence_arr_mean incidence_arr_mean_2],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = true,
        legend = (0.78, 0.98),
        color = [RGB(0.267, 0.467, 0.667) RGB(0.933, 0.4, 0.467)],
        ribbon = [confidence_model confidence_model_2],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots","model_incidence_preferential_attachment.pdf"))
end

function plot_incidence_with_without_recovered()
    incidence_arr = Array{Vector{Float64}, 1}(undef, 2)

    observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_0.jld"))["observed_cases"] ./ population_coef
    incidence_arr[1] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]

    observed_num_infected_age_groups_viruses = load(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "results_1.jld"))["observed_cases"] ./ population_coef
    incidence_arr[2] = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["with recovered" "without recovered"]
    if is_russian
        label_names = ["резист." "без резист."]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Weekly incidence rate per 1000"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    incidence_arr_mean = Array{Vector{Float64}, 1}(undef, 2)
    for i = 1:2
        incidence_arr_mean[i] = zeros(Float64, 52)
        for j = 1:52
            for k = 1:num_years
                incidence_arr_mean[i][j] += incidence_arr[i][52 * (k - 1) + j]
            end
        end
        incidence_arr_mean[i] /= num_years
    end

    incidence_plot = plot(
        1:52,
        [incidence_arr_mean[i][1:52] for i = 2:-1:1],
        lw = 1.5,
        xticks = (ticks, ticklabels),
        label = label_names,
        margin = 4Plots.mm,
        grid = true,
        legend = (0.75, 0.98),
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667)],
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "model_incidence_recovered.pdf"))
end

plot_incidence()
plot_incidence_age_groups()
# plot_incidence_viruses()
# plot_incidence_viruses_together()
# plot_incidence_age_groups_viruses_together()
# plot_rt()
# plot_infection_activities()

# plot_incidence_time_series()
# plot_incidence_age_groups_time_series()
# plot_incidence_viruses_time_series()

# plot_incidence_preferential_attachment()
# plot_incidence_with_without_recovered()

# plot_incidence_quarantine()
# plot_incidence_warming()

# plot_school_closures()
# plot_warming_temperatures()

# ["порог 0.2, 7 дней" "порог 0.1, 7 дней" "порог 0.3, 7 дней" "порог 0.2, 14 дней" "порог 0.1, 14 дней"]
# ["+4 °С" "+3 °С" "+2 °С" "+1 °С"]

# println()
# print_scenario_statistics(1, 1)
# println()
# print_scenario_statistics(2, 2)
# println()
# print_scenario_statistics(3, 3)
# println()
# print_scenario_statistics(4, 4)
# println()
# print_scenario_statistics(5, 4)
