using DelimitedFiles
using Statistics
using Plots
using LaTeXStrings

# default(legendfontsize = 14, guidefont = (20, :black), tickfont = (14, :black))
# default(legendfontsize = 9, guidefont = (12, :black), tickfont = (9, :black))
default(legendfontsize = 11, guidefont = (12, :black), tickfont = (11, :black))

is_russian = false

function plot_incidence()
    age_groups = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "age_groups_data.csv"), ',', Float64)
    incidence = sum(age_groups, dims = 2)[:, 1]
    # incidence2 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "deviations", "infected_data2.csv"), ',', Float64)
    # incidence3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "deviations", "infected_data3.csv"), ',', Float64)
    # stds = zeros(Float64, 52)
    # for i = 1:52
    #     stds[i] = std([incidence[i], incidence2[i], incidence3[i]])
    # end

    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    infected_data_mean = mean(infected_data[39:45, 2:53], dims = 1)[1, :] ./ 10072

    ticks = range(1, stop = 52, length = 7)

    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["model" "data"]
    if is_russian
        label_names = ["модель" "данные"]
    end

    xlabel_name = L"\textrm{\sffamily Month}"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = L"\textrm{\sffamily Cases per 1000 people in a week}"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    incidence_plot = plot(
        1:52,
        [incidence infected_data_mean],
        lw = 3,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = !is_russian,
        # yerror = stds,
        # ribbon=stds,fillalpha=.5,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "model_incidence.pdf"))
end

function plot_incidence_etiology()
    etiology = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "etiology_data.csv"), ',', Float64)

    etiology_sum = sum(etiology, dims = 2)
    for i = 1:7
        etiology[:, i] = etiology[:, i] ./ etiology_sum[:, 1]
    end

    ticks = range(1, stop = 52, length = 7)
    
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    xlabel_name = L"\textrm{\sffamily Month}"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = L"\textrm{\sffamily Ratio}"
    if is_russian
        ylabel_name = "Доля"
    end

    yticks = [0.1, 0.3, 0.5, 0.7]
    yticklabels = ["0.1", "0.3", "0.5", "0.7"]
    etiology_incidence_plot = plot(
        1:52,
        [etiology[:, i] for i = 1:7],
        lw = 3,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        legend = (0.5, 0.97),
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        grid = !is_russian,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(etiology_incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "model_etiology.pdf"))
end

function plot_incidence_age_groups()
    age_groups = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "age_groups_data.csv"), ',', Float64)

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_mean_0 = mean(infected_data_0[2:53, 22:27], dims = 2)[:, 1] ./ 10072
    infected_data_mean_3 = mean(infected_data_3[2:53, 22:27], dims = 2)[:, 1] ./ 10072
    infected_data_mean_7 = mean(infected_data_7[2:53, 22:27], dims = 2)[:, 1] ./ 10072
    infected_data_mean_15 = mean(infected_data_15[2:53, 22:27], dims = 2)[:, 1] ./ 10072

    ticks = range(1, stop = 52, length = 7)
    
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["model" "data"]
    if is_russian
        label_names = ["модель" "данные"]
    end

    xlabel_name = L"\textrm{\sffamily Month}"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = L"\textrm{\sffamily Cases per 1000 people in a week}"
    if is_russian
        ylabel_name = "Число случаев на 1000 чел. / неделя"
    end

    incidence_plot = plot(
        1:52,
        [age_groups[:, 1] infected_data_mean_0],
        lw = 3,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = !is_russian,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "incidence0-2.pdf"))

    incidence_plot = plot(
        1:52,
        [age_groups[:, 2] infected_data_mean_3],
        lw = 3,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = !is_russian,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "incidence3-6.pdf"))

    incidence_plot = plot(
        1:52,
        [age_groups[:, 3] infected_data_mean_7],
        lw = 3,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = !is_russian,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "incidence7-14.pdf"))

    incidence_plot = plot(
        1:52,
        [age_groups[:, 4] infected_data_mean_15],
        lw = 3,
        xticks = (ticks, ticklabels),
        label = label_names,
        grid = !is_russian,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "incidence15+.pdf"))
end

function plot_rt()
    rt = readdlm(
        joinpath(@__DIR__, "..", "..", "..", "output", "tables", "rt.csv"), ',', Float64)

    ticks = range(1, stop = 365, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    xlabel_name = L"\textrm{\sffamily Month}"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = L"\textrm{\sffamily R_t}"
    if is_russian
        ylabel_name = "Rt"
    end

    registered_new_cases_plot = plot(
        1:365,
        rt,
        lw = 3,
        xticks = (ticks, ticklabels),
        color = :red,
        grid = !is_russian,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(
        registered_new_cases_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "rt.pdf"))
end

function plot_r0()
    r0 = readdlm(
        joinpath(@__DIR__, "..", "..", "..", "output", "tables", "r0.csv"), ',', Float64)

    r0 = cat(r0[:, 8:12], r0[:, 1:7], dims=2)

    ticks = [1, 3, 5, 7, 9, 11]
    
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["model" "data"]
    if is_russian
        label_names = ["модель" "данные"]
    end

    xlabel_name = L"\textrm{\sffamily Month}"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = L"\textrm{\sffamily R0}"
    if is_russian
        ylabel_name = "R0"
    end

    registered_new_cases_plot = plot(
        1:12,
        [r0[i, :] for i = 1:7],
        lw = 3,
        xticks = (ticks, ticklabels),
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        legend = (0.5, 0.6),
        grid = !is_russian,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(
        registered_new_cases_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "r0.pdf"))
end

plot_incidence()
plot_incidence_etiology()
plot_incidence_age_groups()
# plot_rt()
# plot_r0()
