using Plots
using DelimitedFiles

default(legendfontsize = 10, guidefont = (14, :black), tickfont = (10, :black))

function main()
    contact_counts1 = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "contact_counts_weekday_summer.csv"), ',', Float64)
    contact_counts2 = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "contact_counts_weekday.csv"), ',', Float64)
    contact_counts3 = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "contact_counts_sunday.csv"), ',', Float64)

    contact_counts1 ./= 2
    contact_counts2 ./= 2
    contact_counts3 ./= 2

    xticks = [0, 20, 40, 60, 80]
    xticklabels = ["0", "20", "40", "60", "80"]

    heatmap_plot1 = heatmap(
        contact_counts1,
        fontfamily = "Times",
        xticks = (xticks, xticklabels),
        title="Contacts on the weekday in summer",
        margin = 6Plots.mm)
    heatmap_plot2 = heatmap(
        contact_counts2,
        fontfamily = "Times",
        xticks = (xticks, xticklabels),
        title="Contacts on the weekday",
        margin = 6Plots.mm)
    heatmap_plot3 = heatmap(
        contact_counts3,
        fontfamily = "Times",
        xticks = (xticks, xticklabels),
        title="Contacts on sunday",
        margin = 4Plots.mm)

    contact_counts1 = log.(contact_counts1)
    contact_counts2 = log.(contact_counts2)
    contact_counts3 = log.(contact_counts3)

    contour_plot1 = contourf(
        contact_counts1,
        fontfamily = "Times",
        xticks = (xticks, xticklabels),
        title="Contacts on the weekday in summer",
        margin = 6Plots.mm,
        linewidth = 0,
        c = :jet)
    contour_plot2 = contourf(
        contact_counts2,
        fontfamily = "Times",
        xticks = (xticks, xticklabels),
        title="Contacts on the weekday",
        margin = 6Plots.mm,
        linewidth = 0,
        c = :jet)
    contour_plot3 = contourf(
        contact_counts3,
        fontfamily = "Times",
        xticks = (xticks, xticklabels),
        title="Contacts on sunday",
        margin = 4Plots.mm,
        linewidth = 0,
        c = :jet)
    
    xlabel!("Age, years")
    ylabel!("Age, years")
    savefig(heatmap_plot1, joinpath(@__DIR__, "..", "..", "output", "plots", "contact_counts_weekday_summer.pdf"))
    savefig(contour_plot1, joinpath(@__DIR__, "..", "..", "output", "plots", "contact_counts_weekday_summer_contour.pdf"))
    savefig(heatmap_plot2, joinpath(@__DIR__, "..", "..", "output", "plots", "contact_counts_weekday.pdf"))
    savefig(contour_plot2, joinpath(@__DIR__, "..", "..", "output", "plots", "contact_counts_weekday_contour.pdf"))
    savefig(heatmap_plot3, joinpath(@__DIR__, "..", "..", "output", "plots", "contact_counts_sunday.pdf"))
    savefig(contour_plot3, joinpath(@__DIR__, "..", "..", "output", "plots", "contact_counts_sunday_contour.pdf"))




    contact_durations = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "contact_durations.csv"), ',', Float64)
	
	contact_durations += transpose(contact_durations)
	contact_durations ./= 2
	
	heatmap_plot = heatmap(contact_durations, fontfamily = "Times", xticks = (xticks, xticklabels), title="Average daily contact durations over a year")
	xlabel!("Age, years")
    ylabel!("Age, years")
    savefig(heatmap_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "contact_durations.pdf"))
end

main()

# function main3()
#     contact_counts = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "contact_counts.csv"), ',', Float64)

#     xticks = [0, 20, 40, 60, 80]
#     xticklabels = ["0", "20", "40", "60", "80"]

#     heatmap_plot = heatmap(contact_counts, fontfamily = "Times", xticks = (xticks, xticklabels), title="Daily contacts over the year", margin = 8Plots.mm)
#     xlabel!("Age, years")
#     ylabel!("Age, years")
#     savefig(heatmap_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "contact_counts.pdf"))
# end

# main3()

# function main2()
#     contact_counts = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "contact_counts.csv"), ',', Float64)

#     xticks = [0, 20, 40, 60]
#     xticklabels = ["25", "45", "65", "85"]
#     yticks = [0, 20, 40, 60]
#     yticklabels = ["25", "45", "65", "85"]

#     heatmap_plot = heatmap(contact_counts[25:89, 25:89], fontfamily = "Times", xticks = (xticks, xticklabels), yticks = (yticks, yticklabels), title="Average daily number of contacts over a year")
#     xlabel!("Age, years")
#     ylabel!("Age, years")
#     savefig(heatmap_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "contact_counts_2.pdf"))

#     # contact_counts = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "contact_counts.csv"), ',', Float64)
#     # for i = 1:24
#     #     contact_counts[i, i] = 0
#     # end

#     # xticks = [0, 20, 40, 60, 80]
#     # xticklabels = ["0", "20", "40", "60", "80"]

#     # heatmap_plot = heatmap(contact_counts, fontfamily = "Times", xticks = (xticks, xticklabels), title="Average daily number of contacts (Year)")
#     # xlabel!("Age, years")
#     # ylabel!("Age, years")
#     # savefig(heatmap_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "contact_counts.pdf"))
# end

# main2()
