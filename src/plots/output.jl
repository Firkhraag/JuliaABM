using DelimitedFiles
using Plots
using Statistics
using LaTeXStrings

include("../data/etiology.jl")

default(legendfontsize = 14, guidefont = (20, :black), tickfont = (14, :black))

function plot_incidence()
    incidence = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "infected_data.csv"), ',', Float64)
    infected_data = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    infected_data_mean = mean(infected_data[39:45, 2:53], dims = 1)[1, :] ./ 9897

    # ticks = range(1, stop = 52, length = 13)
    # ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    incidence_plot = plot(
        1:52,
        [incidence infected_data_mean],
        lw = 3,
        xticks = (ticks, ticklabels),
        label = ["model" "data"],
        xlabel = L"\textrm{\sffamily Month}",
        ylabel = L"\textrm{\sffamily Cases per 1000 people}")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "model_incidence.pdf"))
end

function plot_incidence_etiology()
    etiology = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "etiology_data.csv"), ',', Float64)

    etiology_sum = sum(etiology, dims = 2)
    for i = 1:7
        etiology[:, i] = etiology[:, i] ./ etiology_sum[:, 1]
    end

    # ticks = range(1, stop = 52, length = 13)
    # ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    yticks = [0.0, 0.2, 0.4, 0.6, 0.8]
    yticklabels = ["0.0", "0.2", "0.4", "0.6", "0.8"]
    etiology_incidence_plot = plot(
        1:52,
        [etiology[:, i] for i = 1:7],
        lw = 3,
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        legend = (0.5, 0.97),
        ylim = (0.0, 0.8),
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        xlabel = L"\textrm{\sffamily Month}",
        ylabel = L"\textrm{\sffamily Ratio}")
    savefig(etiology_incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "model_etiology.pdf"))
end

function plot_incidence_age_groups()
    age_groups = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "age_groups_data.csv"), ',', Float64)

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_mean_0 = mean(infected_data_0[2:53, 22:27], dims = 2)[:, 1] ./ 9897
    infected_data_mean_3 = mean(infected_data_3[2:53, 22:27], dims = 2)[:, 1] ./ 9897
    infected_data_mean_7 = mean(infected_data_7[2:53, 22:27], dims = 2)[:, 1] ./ 9897
    infected_data_mean_15 = mean(infected_data_15[2:53, 22:27], dims = 2)[:, 1] ./ 9897

    # ticks = range(1, stop = 52, length = 13)
    # ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    incidence_plot = plot(
        1:52,
        [age_groups[:, 1] infected_data_mean_0],
        lw = 3,
        xticks = (ticks, ticklabels),
        label = ["model" "data"],
        xlabel = L"\textrm{\sffamily Month}",
        ylabel = L"\textrm{\sffamily Cases per 1000 people}")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence0-2.pdf"))

    incidence_plot = plot(
        1:52,
        [age_groups[:, 2] infected_data_mean_3],
        lw = 3,
        xticks = (ticks, ticklabels),
        label = ["model" "data"],
        xlabel = L"\textrm{\sffamily Month}",
        ylabel = L"\textrm{\sffamily Cases per 1000 people}")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence3-6.pdf"))

    incidence_plot = plot(
        1:52,
        [age_groups[:, 3] infected_data_mean_7],
        lw = 3,
        xticks = (ticks, ticklabels),
        label = ["model" "data"],
        xlabel = L"\textrm{\sffamily Month}",
        ylabel = L"\textrm{\sffamily Cases per 1000 people}")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence7-14.pdf"))

    incidence_plot = plot(
        1:52,
        [age_groups[:, 4] infected_data_mean_15],
        lw = 3,
        xticks = (ticks, ticklabels),
        label = ["model" "data"],
        xlabel = L"\textrm{\sffamily Month}",
        ylabel = L"\textrm{\sffamily Cases per 1000 people}")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence15+.pdf"))
end

function plot_daily_new_cases_age_groups()
    daily_new_cases_age_groups_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_age_groups_data.csv"), ',', Int)

    daily_new_cases_age_groups_plot = plot(
        1:365,
        [daily_new_cases_age_groups_data[i, :] for i = 1:7],
        lw = 3,
        label = ["0-2" "3-6" "7-14" "15-17" "18-24" "25-64" "65+"],
        xlabel = L"\textrm{\sffamily Day}",
        ylabel = L"\textrm{\sffamily Num of people}")
    savefig(
        daily_new_cases_age_groups_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_cases_age_groups.pdf"))
end

function plot_daily_new_recoveries_age_groups()
    daily_new_recoveries_age_groups_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_recoveries_age_groups_data.csv"), ',', Int)

    daily_new_recoveries_age_groups_plot = plot(
        1:365,
        [daily_new_recoveries_age_groups_data[i, :] for i = 1:7],
        lw = 3,
        label = ["0-2" "3-6" "7-14" "15-17" "18-24" "25-64" "65+"],
        xlabel = L"\textrm{\sffamily Day}",
        ylabel = L"\textrm{\sffamily Num of people}")
    savefig(
        daily_new_recoveries_age_groups_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_recoveries_age_groups.pdf"))
end

function plot_daily_new_cases_viruses_asymptomatic()
    daily_new_cases_viruses_asymptomatic_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_viruses_asymptomatic_data.csv"), ',', Int)

    daily_new_cases_viruses_asymptomatic_plot = plot(
        1:365,
        [daily_new_cases_viruses_asymptomatic_data[i, :] for i = 1:7],
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        xlabel = L"\textrm{\sffamily Day}",
        ylabel = L"\textrm{\sffamily Num of people}")
    savefig(
        daily_new_cases_viruses_asymptomatic_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_cases_viruses_asymptomatic.pdf"))
end

function plot_daily_new_cases_viruses()
    daily_new_cases_viruses_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_viruses_data.csv"), ',', Int)

    daily_new_cases_viruses_plot = plot(
        1:365,
        [daily_new_cases_viruses_data[i, :] for i = 1:7],
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        xlabel = L"\textrm{\sffamily Day}",
        ylabel = L"\textrm{\sffamily Num of people}")
    savefig(
        daily_new_cases_viruses_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_cases_viruses.pdf"))

    daily_new_cases_plot = plot(
        1:365,
        daily_new_cases_viruses_data[1, :] + daily_new_cases_viruses_data[2, :] + daily_new_cases_viruses_data[3, :] + daily_new_cases_viruses_data[4, :] + daily_new_cases_viruses_data[5, :] + daily_new_cases_viruses_data[6, :] + daily_new_cases_viruses_data[7, :],
        lw = 3,
        legend = false,
        xlabel = L"\textrm{\sffamily Day}",
        ylabel = L"\textrm{\sffamily Num of people}")
    savefig(daily_new_cases_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_cases_data.pdf"))
end

function plot_daily_new_recoveries_viruses()
    daily_new_recoveries_viruses_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_recoveries_viruses_data.csv"), ',', Int)

    daily_new_recoveries_viruses_plot = plot(
        1:365,
        [daily_new_recoveries_viruses_data[i, :] for i = 1:7],
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        xlabel = L"\textrm{\sffamily Day}",
        ylabel = L"\textrm{\sffamily Num of people}")
    savefig(
        daily_new_recoveries_viruses_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_recoveries_viruses.pdf"))
end

function plot_immunity_viruses()
    immunity_viruses_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "immunity_viruses_data.csv"), ',', Int)

    immunity_viruses_plot = plot(
        1:365,
        [immunity_viruses_data[i, :] for i = 1:7],
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        xlabel = L"\textrm{\sffamily Day}",
        ylabel = L"\textrm{\sffamily Num of people}")
    savefig(immunity_viruses_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "immunity_viruses.pdf"))
end

function plot_registered_new_cases()
    registered_new_cases_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "registered_new_cases_data.csv"), ',', Int)

    registered_new_cases_plot = plot(
        1:365,
        registered_new_cases_data,
        lw = 3,
        legend = false,
        xlabel = L"\textrm{\sffamily Day}",
        ylabel = L"\textrm{\sffamily Num of people}")
    savefig(
        registered_new_cases_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "registered_new_cases.pdf"))
end

function plot_r0()
    r0 = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "r0.csv"), ',', Float64)

    r0 = cat(r0[:, 8:12], r0[:, 1:7], dims=2)

    # ticks = range(1, stop = 12, length = 13)
    # ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    ticks = range(1, stop = 12, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    registered_new_cases_plot = plot(
        1:12,
        [r0[i, :] for i = 1:7],
        lw = 3,
        xticks = (ticks, ticklabels),
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        legend = (0.5, 0.6),
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        xlabel = L"\textrm{\sffamily Month}",
        ylabel = L"\textrm{\sffamily R0}")
    xlabel!("Month")
    ylabel!("R0")
    savefig(
        registered_new_cases_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "r0.pdf"))
end

plot_incidence()
plot_incidence_etiology()
plot_incidence_age_groups()

# plot_daily_new_cases_viruses()

plot_r0()

# plot_daily_new_cases_age_groups()
# plot_daily_new_recoveries_age_groups()

# plot_daily_new_cases_viruses_asymptomatic()
# plot_daily_new_recoveries_viruses()

# plot_immunity_viruses()

# plot_registered_new_cases()
