using DelimitedFiles
using Plots

function main()
    # Data
    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "incidence_data.csv"), ',', Float64)
    etiologies_data = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "etiologies_data.csv"), ',', Float64)
    age_groups_data = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "age_groups_data.csv"), ',', Float64)

    daily_new_cases_age_groups_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_age_groups_data.csv"), ',', Int)
    daily_new_recoveries_age_groups_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_recoveries_age_groups_data.csv"), ',', Int)

    daily_new_cases_viruses_asymptomatic_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_viruses_asymptomatic_data.csv"), ',', Int)
    daily_new_cases_viruses_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_viruses_data.csv"), ',', Int)
    daily_new_recoveries_viruses_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_recoveries_viruses_data.csv"), ',', Int)

    daily_new_cases_collectives_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_collectives_data.csv"), ',', Int)
    daily_new_recoveries_collectives_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_recoveries_collectives_data.csv"), ',', Int)

    immunity_viruses_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "immunity_viruses_data.csv"), ',', Int)
    infected_inside_collective_data = readdlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "infected_inside_collective_data.csv"), ',', Int)

    # Plots

    incidence_plot = plot(1:52, incidence_data, title = "Incidence", lw = 3, legend = false)
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "incidence.pdf"))

    etiologies_incidence_plot = plot(
        1:52,
        [etiologies_data[i, :] for i = 1:7],
        title = "Incidence by etiology",
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(etiologies_incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "etiologies.pdf"))

    age_groups_incidence_plot = plot(
        1:52,
        [age_groups_data[i, :] for i = 1:4],
        title = "Incidence by age",
        lw = 3,
        label = ["0-2" "3-6" "7-14" "15+"])
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(age_groups_incidence_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "age_groups.pdf"))

    # ----------------------
    daily_new_cases_age_groups_plot = plot(
        1:365,
        [daily_new_cases_age_groups_data[i, :] for i = 1:7],
        title = "Daily new cases",
        lw = 3,
        label = ["0-2" "3-6" "7-14" "15-17" "18-24" "25-64" "65+"])
    xlabel!("Day")
    ylabel!("Incidence")
    savefig(
        daily_new_cases_age_groups_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_cases_age_groups.pdf"))

    daily_new_recoveries_age_groups_plot = plot(
        1:365,
        [daily_new_recoveries_age_groups_data[i, :] for i = 1:7],
        title = "Daily new recoveries",
        lw = 3,
        label = ["0-2" "3-6" "7-14" "15-17" "18-24" "25-64" "65+"])
    xlabel!("Day")
    ylabel!("Incidence")
    savefig(
        daily_new_recoveries_age_groups_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_recoveries_age_groups.pdf"))

    daily_new_cases_viruses_plot = plot(
        1:365,
        [daily_new_cases_viruses_data[i, :] for i = 1:7],
        title = "Daily new cases",
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Day")
    ylabel!("Incidence")
    savefig(daily_new_cases_viruses_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_cases_viruses.pdf"))

    daily_new_cases_viruses_asymptomatic_plot = plot(
        1:365,
        [daily_new_cases_viruses_asymptomatic_data[i, :] for i = 1:7],
        title = "Daily new cases",
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Day")
    ylabel!("Incidence")
    savefig(
        daily_new_cases_viruses_asymptomatic_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_cases_viruses_asymptomatic.pdf"))

    daily_new_cases_plot = plot(
        1:365,
        daily_new_cases_viruses_data[1, :] + daily_new_cases_viruses_data[2, :] + daily_new_cases_viruses_data[3, :] + daily_new_cases_viruses_data[4, :] + daily_new_cases_viruses_data[5, :] + daily_new_cases_viruses_data[6, :] + daily_new_cases_viruses_data[7, :],
        title = "Daily new cases",
        lw = 3,
        legend = false)
    xlabel!("Day")
    ylabel!("Incidence")
    savefig(daily_new_cases_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_cases_data.pdf"))

    daily_new_recoveries_viruses_plot = plot(
        1:365,
        [daily_new_recoveries_viruses_data[i, :] for i = 1:7],
        title = "Daily new recoveries",
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Day")
    ylabel!("Incidence")
    savefig(
        daily_new_recoveries_viruses_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_recoveries_viruses.pdf"))

    daily_new_cases_collectives_plot = plot(
        1:365,
        [daily_new_cases_collectives_data[i, :] for i = 1:4],
        title = "Daily new cases",
        lw = 3,
        label = ["Kinder" "School" "Uni" "Work"])
    xlabel!("Day")
    ylabel!("Incidence")
    savefig(
        daily_new_cases_collectives_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_cases_collectives.pdf"))

    daily_new_recoveries_collectives_plot = plot(
        1:365,
        [daily_new_recoveries_collectives_data[i, :] for i = 1:4],
        title = "Daily new recoveries",
        lw = 3,
        label = ["Kinder" "School" "Uni" "Work"])
    xlabel!("Day")
    ylabel!("Incidence")
    savefig(
        daily_new_recoveries_collectives_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "daily_new_recoveries_collectives.pdf"))

    immunity_viruses_plot = plot(
        1:365,
        [immunity_viruses_data[i, :] for i = 1:7],
        title = "Immunity",
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Day")
    ylabel!("Incidence")
    savefig(immunity_viruses_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "immunity_viruses.pdf"))

    infected_inside_collective_plot = plot(
        1:365,
        [infected_inside_collective_data[i, :] for i = 1:5],
        title = "Virus transmissions inside collectives",
        lw = 3,
        label = ["Kinder" "School" "Uni" "Work" "Home"])
    xlabel!("Day")
    ylabel!("Incidence")
    savefig(
        infected_inside_collective_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "infected_inside_collective.pdf"))
end

main()