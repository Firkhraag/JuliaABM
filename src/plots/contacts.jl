using Plots
using DelimitedFiles

default(legendfontsize = 10, guidefont = (14, :black), tickfont = (10, :black))

function main()
    # contact_counts = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "contact_counts_weekday_summer.csv"), ',', Float64)
    contact_counts = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "contact_counts_weekday.csv"), ',', Float64)
    # contact_counts = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "contact_counts_weekend.csv"), ',', Float64)

    xticks = [0, 20, 40, 60, 80]
    xticklabels = ["0", "20", "40", "60", "80"]

    # heatmap_plot = heatmap(contact_counts, fontfamily = "Times", xticks = (xticks, xticklabels), title="Contacts on the weekday in summer", margin = 8Plots.mm)
    heatmap_plot = heatmap(contact_counts, fontfamily = "Times", xticks = (xticks, xticklabels), title="Contacts on the weekday", margin = 8Plots.mm)
    # heatmap_plot = heatmap(contact_counts, fontfamily = "Times", xticks = (xticks, xticklabels), title="Contacts on the weekend", margin = 4Plots.mm)
    xlabel!("Age, years")
    ylabel!("Age, years")
    # savefig(heatmap_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "contact_counts_weekday_summer.pdf"))
    savefig(heatmap_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "contact_counts_weekday.pdf"))
    # savefig(heatmap_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "contact_counts_weekend.pdf"))




    # contact_durations = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "contact_durations.csv"), ',', Float64)
	
	# contact_durations += transpose(contact_durations)
	# contact_durations ./= 2
	
	# heatmap_plot = heatmap(contact_durations, fontfamily = "Times", xticks = (xticks, xticklabels), title="Average daily contact durations over a year")
	# xlabel!("Age, years")
    # ylabel!("Age, years")
    # savefig(heatmap_plot, joinpath(@__DIR__, "..", "..", "output", "plots", "contact_durations.pdf"))
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
