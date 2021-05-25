using DelimitedFiles
using Plots
using Statistics

function plot_incidence()
    incidence = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "incidence_data.csv"), ',', Float64)
    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    incidence_data_mean = mean(incidence_data[42:45, 2:53], dims = 1)[1, :] ./ 9897

    incidence_plot = plot(1:52, [incidence incidence_data_mean], title = "Incidence", lw = 3, label = ["model" "data"])
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence.pdf"))
end

function plot_incidence_etiology()
    etiology = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "etiology_data.csv"), ',', Float64)

    etiology_incidence_plot = plot(
        1:52,
        [etiology[i, :] for i = 1:7],
        title = "Incidence by etiology",
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(etiology_incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "etiology.pdf"))
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

    incidence_plot = plot(1:52, [age_groups[1, :] incidence_data_mean_0], title = "0–2 age group incidence", lw = 3, label = ["model" "data"])
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence0-2.pdf"))

    incidence_plot = plot(1:52, [age_groups[2, :] incidence_data_mean_3], title = "3–6 age group incidence", lw = 3, label = ["model" "data"])
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence3-6.pdf"))

    incidence_plot = plot(1:52, [age_groups[3, :] incidence_data_mean_7], title = "7–14 age group incidence", lw = 3, label = ["model" "data"])
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence7-14.pdf"))

    incidence_plot = plot(1:52, [age_groups[4, :] incidence_data_mean_15], title = "15+ age group incidence", lw = 3, label = ["model" "data"])
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence15+.pdf"))
end

function plot_daily_new_cases_age_groups()
    daily_new_cases_age_groups_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_age_groups_data.csv"), ',', Int)

    daily_new_cases_age_groups_plot = plot(
        1:365,
        [daily_new_cases_age_groups_data[i, :] for i = 1:7],
        title = "Daily new cases",
        lw = 3,
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
        title = "Daily new recoveries",
        lw = 3,
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
        title = "Daily new cases",
        lw = 3,
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
        title = "Daily new cases",
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Day")
    ylabel!("Num of people")
    savefig(
        daily_new_cases_viruses_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_cases_viruses.pdf"))

    daily_new_cases_plot = plot(
        1:365,
        daily_new_cases_viruses_data[1, :] + daily_new_cases_viruses_data[2, :] + daily_new_cases_viruses_data[3, :] + daily_new_cases_viruses_data[4, :] + daily_new_cases_viruses_data[5, :] + daily_new_cases_viruses_data[6, :] + daily_new_cases_viruses_data[7, :],
        title = "Daily new cases",
        lw = 3,
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
        title = "Daily new recoveries",
        lw = 3,
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
        [daily_new_cases_collectives_data[i, :] for i = 1:4],
        title = "Daily new cases",
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
        title = "Daily new recoveries",
        lw = 3,
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
        title = "Immunity",
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Day")
    ylabel!("Num of people")
    savefig(immunity_viruses_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "immunity_viruses.pdf"))
end

function plot_infected_inside_collective()
    infected_inside_collective_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "infected_inside_collective_data.csv"), ',', Int)

    infected_inside_collective_plot = plot(
        1:365,
        [infected_inside_collective_data[i, :] for i = 1:5],
        title = "Virus transmissions inside collectives",
        lw = 3,
        label = ["Kinder" "School" "Uni" "Work" "Home"])
    xlabel!("Day")
    ylabel!("Num of people")
    savefig(
        infected_inside_collective_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "infected_inside_collective.pdf"))
end

function plot_registered_new_cases()
    registered_new_cases_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "registered_new_cases_data.csv"), ',', Int)

    registered_new_cases_plot = plot(
        1:365,
        registered_new_cases_data,
        title = "Registered new cases",
        lw = 3,
        legend = false)
    xlabel!("Day")
    ylabel!("Num of people")
    savefig(
        registered_new_cases_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "registered_new_cases.pdf"))
end

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
