using DelimitedFiles
using Plots
using Statistics

include("../data/etiology.jl")

function plot_incidence()
    incidence = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "incidence_data.csv"), ',', Float64)
    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    incidence_data_mean = mean(incidence_data[42:45, 2:53], dims = 1)[1, :] ./ 9897

    ticks = range(1, stop = 52, length = 13)
    ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    incidence_plot = plot(
        1:52,
        [incidence incidence_data_mean],
        lw = 3,
        xticks = (ticks, ticklabels),
        fontfamily = "Times",
        label = ["model" "data"])
    xlabel!("Week")
    ylabel!("Cases per 1000 people")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence.pdf"))
end

function plot_incidence_etiology()
    etiology = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "etiology_data.csv"), ',', Float64)

    etiology_sum = sum(etiology, dims = 1)
    for i = 1:7
        etiology[i, :] = etiology[i, :] ./ etiology_sum[1, :]
    end

    ticks = range(1, stop = 52, length = 13)
    ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    etiology_incidence_plot = plot(
        1:52,
        [etiology[i, :] for i = 1:7],
        lw = 3,
        fontfamily = "Times",
        xticks = (ticks, ticklabels),
        legend=(0.8, 1.0),
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Month")
    ylabel!("Ratio")
    savefig(etiology_incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "model_etiology.pdf"))
end

function plot_incidence_age_groups()
    age_groups = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "age_groups_data.csv"), ',', Float64)

    incidence_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    incidence_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    incidence_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    incidence_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    incidence_data_mean_0 = mean(incidence_data_0[2:53, 24:27], dims = 2)[:, 1] ./ 9897
    incidence_data_mean_3 = mean(incidence_data_3[2:53, 24:27], dims = 2)[:, 1] ./ 9897
    incidence_data_mean_7 = mean(incidence_data_7[2:53, 24:27], dims = 2)[:, 1] ./ 9897
    incidence_data_mean_15 = mean(incidence_data_15[2:53, 24:27], dims = 2)[:, 1] ./ 9897

    ticks = range(1, stop = 52, length = 13)
    ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    incidence_plot = plot(
        1:52,
        [age_groups[1, :] incidence_data_mean_0],
        lw = 3,
        xticks = (ticks, ticklabels),
        fontfamily = "Times",
        label = ["model" "data"])
    xlabel!("Week")
    ylabel!("Cases per 1000 people")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence0-2.pdf"))

    incidence_plot = plot(
        1:52,
        [age_groups[2, :] incidence_data_mean_3],
        lw = 3,
        fontfamily = "Times",
        xticks = (ticks, ticklabels),
        label = ["model" "data"])
    xlabel!("Week")
    ylabel!("Cases per 1000 people")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence3-6.pdf"))

    incidence_plot = plot(
        1:52,
        [age_groups[3, :] incidence_data_mean_7],
        lw = 3,
        fontfamily = "Times",
        xticks = (ticks, ticklabels),
        label = ["model" "data"])
    xlabel!("Week")
    ylabel!("Cases per 1000 people")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence7-14.pdf"))

    incidence_plot = plot(
        1:52,
        [age_groups[4, :] incidence_data_mean_15],
        lw = 3,
        fontfamily = "Times",
        xticks = (ticks, ticklabels),
        label = ["model" "data"])
    xlabel!("Week")
    ylabel!("Cases per 1000 people")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence15+.pdf"))
end

function plot_daily_new_cases_age_groups()
    daily_new_cases_age_groups_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_age_groups_data.csv"), ',', Int)

    daily_new_cases_age_groups_plot = plot(
        1:365,
        [daily_new_cases_age_groups_data[i, :] for i = 1:7],
        lw = 3,
        fontfamily = "Times",
        label = ["0-2" "3-6" "7-14" "15-17" "18-24" "25-64" "65+"])
    xlabel!("Day")
    ylabel!("Num of people")
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
        fontfamily = "Times",
        label = ["0-2" "3-6" "7-14" "15-17" "18-24" "25-64" "65+"])
    xlabel!("Day")
    ylabel!("Num of people")
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
        fontfamily = "Times",
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Day")
    ylabel!("Num of people")
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
        fontfamily = "Times",
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Day")
    ylabel!("Num of people")
    savefig(
        daily_new_cases_viruses_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_cases_viruses.pdf"))

    daily_new_cases_plot = plot(
        1:365,
        daily_new_cases_viruses_data[1, :] + daily_new_cases_viruses_data[2, :] + daily_new_cases_viruses_data[3, :] + daily_new_cases_viruses_data[4, :] + daily_new_cases_viruses_data[5, :] + daily_new_cases_viruses_data[6, :] + daily_new_cases_viruses_data[7, :],
        lw = 3,
        fontfamily = "Times",
        legend = false)
    xlabel!("Day")
    ylabel!("Num of people")
    savefig(daily_new_cases_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_cases_data.pdf"))
end

function plot_daily_new_recoveries_viruses()
    daily_new_recoveries_viruses_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_recoveries_viruses_data.csv"), ',', Int)

    daily_new_recoveries_viruses_plot = plot(
        1:365,
        [daily_new_recoveries_viruses_data[i, :] for i = 1:7],
        lw = 3,
        fontfamily = "Times",
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Day")
    ylabel!("Num of people")
    savefig(
        daily_new_recoveries_viruses_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_recoveries_viruses.pdf"))
end

function plot_daily_new_cases_collectives()
    daily_new_cases_collectives_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_collectives_data.csv"), ',', Int)

    daily_new_cases_collectives_plot = plot(
        1:365,
        fontfamily = "Times",
        [daily_new_cases_collectives_data[i, :] for i = 1:4],
        lw = 3,
        label = ["Kinder" "School" "Uni" "Work"])
    xlabel!("Day")
    ylabel!("Num of people")
    savefig(
        daily_new_cases_collectives_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_cases_collectives.pdf"))
end

function plot_daily_new_recoveries_collectives()
    daily_new_recoveries_collectives_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_recoveries_collectives_data.csv"), ',', Int)

    daily_new_recoveries_collectives_plot = plot(
        1:365,
        [daily_new_recoveries_collectives_data[i, :] for i = 1:4],
        lw = 3,
        fontfamily = "Times",
        label = ["Kinder" "School" "Uni" "Work"])
    xlabel!("Day")
    ylabel!("Num of people")
    savefig(
        daily_new_recoveries_collectives_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_recoveries_collectives.pdf"))
end

function plot_immunity_viruses()
    immunity_viruses_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "immunity_viruses_data.csv"), ',', Int)

    immunity_viruses_plot = plot(
        1:365,
        [immunity_viruses_data[i, :] for i = 1:7],
        lw = 3,
        fontfamily = "Times",
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Day")
    ylabel!("Num of people")
    savefig(immunity_viruses_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "immunity_viruses.pdf"))
end

function plot_infected_inside_collective()
    infected_inside_collective_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "infected_inside_collective_data.csv"), ',', Float64)

    collective_sizes = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "collective_sizes.csv"), ',', Int)

    infected_inside_collective = Array{Float64, 2}(undef, 52, 5)
    for i = 1:52
        for j = 1:5
            infected_inside_collective[i, j] = sum(infected_inside_collective_data[(i - 1) * 7 + 1:(i - 1) * 7 + 7, j])
        end
    end

    infected_inside_collective[:, 1] ./= collective_sizes[1]
    infected_inside_collective[:, 2] ./= collective_sizes[2]
    infected_inside_collective[:, 3] ./= collective_sizes[3]
    infected_inside_collective[:, 4] ./= collective_sizes[4]
    infected_inside_collective[:, 5] ./= 9897284

    ticks = range(1, stop = 52, length = 13)
    ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    infected_inside_collective_plot = plot(
        1:52,
        [infected_inside_collective[:, i] for i = 1:5],
        lw = 3,
        xticks = (ticks, ticklabels),
        fontfamily = "Times",
        label = ["Kindergarten" "School" "University" "Workplace" "Household"])
    xlabel!("Month")
    ylabel!("Ratio")
    savefig(
        infected_inside_collective_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "infected_inside_collective.pdf"))
end

function plot_registered_new_cases()
    registered_new_cases_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "registered_new_cases_data.csv"), ',', Int)

    registered_new_cases_plot = plot(
        1:365,
        registered_new_cases_data,
        lw = 3,
        fontfamily = "Times",
        legend = false)
    xlabel!("Day")
    ylabel!("Num of people")
    savefig(
        registered_new_cases_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "registered_new_cases.pdf"))
end

# function RSS()
#     incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
#     incidence_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
#     incidence_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
#     incidence_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
#     incidence_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

#     incidence_data_mean = mean(incidence_data[42:45, 2:53], dims = 1)[1, :]
#     incidence_data_mean_0 = mean(incidence_data_0[2:53, 24:27], dims = 2)[:, 1]
#     incidence_data_mean_3 = mean(incidence_data_3[2:53, 24:27], dims = 2)[:, 1]
#     incidence_data_mean_7 = mean(incidence_data_7[2:53, 24:27], dims = 2)[:, 1]
#     incidence_data_mean_15 = mean(incidence_data_15[2:53, 24:27], dims = 2)[:, 1]

#     incidence = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "incidence_data.csv"), ',', Float64)
#     etiology_incidence = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "etiology_data.csv"), ',', Float64)
#     age_group_incidence = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "age_groups_data.csv"), ',', Float64)

#     S = 1 / 3 * sum((incidence - incidence_data_mean).^2)

#     S1 = 1 / 12 * sum((age_group_incidence[1, :] - incidence_data_mean_0).^2)
#     S2 = 1 / 12 * sum((age_group_incidence[2, :] - incidence_data_mean_3).^2)
#     S3 = 1 / 12 * sum((age_group_incidence[3, :] - incidence_data_mean_7).^2)
#     S4 = 1 / 12 * sum((age_group_incidence[4, :] - incidence_data_mean_15).^2)

#     println("S: ", S)
#     println("S1: ", S1)
#     println("S2: ", S2)
#     println("S3: ", S3)
#     println("S4: ", S4)

#     S += S1 + S2 + S3 + S4

#     etiology_data = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "etiology_ratio.csv"), ',', Float64, '\n')

#     etiology_sum = sum(etiology_incidence, dims = 1)[1, :]
#     for i = 1:7
#         etiology_incidence[i, :] = etiology_incidence[i, :] ./ etiology_sum
#         S += 1 / 21 * sum((etiology_data[i, :] .* incidence .- etiology_incidence[i, :] .* incidence).^ 2)
#         # S += 1 / 21 * sum(abs.(etiology_data[i, :] .* incidence .- etiology_model[i, :] .* incidence))
#     end
#     println(S)
# end

scalefontsizes(1.2)

# RSS()

plot_incidence()
plot_incidence_etiology()
plot_incidence_age_groups()

plot_daily_new_cases_viruses()
plot_infected_inside_collective()

# plot_daily_new_cases_age_groups()
# plot_daily_new_recoveries_age_groups()

# plot_daily_new_cases_viruses_asymptomatic()
# plot_daily_new_recoveries_viruses()

# plot_daily_new_cases_collectives()
# plot_daily_new_recoveries_collectives()

# plot_immunity_viruses()

# plot_registered_new_cases()
