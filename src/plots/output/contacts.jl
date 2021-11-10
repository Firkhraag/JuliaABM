using Plots
using DelimitedFiles

default(legendfontsize = 10, guidefont = (14, :black), tickfont = (10, :black))

function plot_contacts()
    contact_counts = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_counts.csv"), ',', Float64)
    contact_counts_holiday = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_counts_holiday.csv"), ',', Float64)

    # contact_counts ./= 2
    # contact_counts_holiday ./= 2

    xticks = [0, 20, 40, 60, 80]
    xticklabels = ["0", "20", "40", "60", "80"]

    heatmap_plot = heatmap(
        contact_counts,
        fontfamily = "Times",
        xticks = (xticks, xticklabels),
        title = "Contacts on the weekday",
        margin = 6Plots.mm,
        c = :jet1,
        xlabel = "Age, years",
        ylabel = "Age, years",
        colorbar_title = "Number of contacts",
    )
    heatmap_plot_holiday = heatmap(
        contact_counts_holiday,
        fontfamily = "Times",
        xticks = (xticks, xticklabels),
        title = "Contacts on holiday",
        margin = 6Plots.mm,
        c = :jet1,
        xlabel = "Age, years",
        ylabel = "Age, years",
        colorbar_title = "Number of contacts",
    )

    contact_counts = log.(contact_counts)
    contact_counts_holiday = log.(contact_counts_holiday)

    contour_plot = contourf(
        contact_counts,
        fontfamily = "Times",
        xticks = (xticks, xticklabels),
        title = "Daily number of contacts",
        margin = 6Plots.mm,
        c = :jet1,
        xlabel = "Age, years",
        ylabel = "Age, years",
        colorbar_title = "Number of contacts",
    )
    contour_plot_holiday = contourf(
        contact_counts_holiday,
        fontfamily = "Times",
        xticks = (xticks, xticklabels),
        title = "Daily number of contacts on holiday",
        margin = 6Plots.mm,
        # nlevels = 50,
        # linewidth = 0,
        c = :jet1,
        xlabel = "Age, years",
        ylabel = "Age, years",
        colorbar_title = "Number of contacts",
    )
    
    savefig(heatmap_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", "contact_counts.pdf"))
    savefig(contour_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", "contact_counts_contour.pdf"))
    savefig(heatmap_plot_holiday, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", "contact_counts_holiday.pdf"))
    savefig(contour_plot_holiday, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", "contact_counts_holiday_contour.pdf"))

    contact_durations = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_durations.csv"), ',', Float64)
    contact_durations_holiday = readdlm(joinpath(
        @__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_durations_holiday.csv"), ',', Float64)
	
	contact_durations += transpose(contact_durations)
	contact_durations ./= 2
	contact_durations_holiday += transpose(contact_durations_holiday)
	contact_durations_holiday ./= 2
	
	heatmap_plot = heatmap(
        contact_durations,
        fontfamily = "Times",
        xticks = (xticks, xticklabels),
        title = "Average daily contact durations",
        c = :jet1,
        xlabel = "Age, years",
        ylabel = "Age, years",
        colorbar_title = "hours",
    )
	heatmap_plot_holiday = heatmap(
        contact_durations_holiday,
        fontfamily = "Times",
        xticks = (xticks, xticklabels),
        title = "Average daily contact durations",
        c = :jet1,
        xlabel = "Age, years",
        ylabel = "Age, years",
        colorbar_title = "hours",
    )
    savefig(heatmap_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", "contact_durations.pdf"))
    savefig(heatmap_plot_holiday, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", "contact_durations_holiday.pdf"))

    # -----------------
    for activity_num = 3:7
        contact_counts = readdlm(joinpath(
            @__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_counts_activity_$(activity_num).csv"), ',', Float64)
        if activity_num == 3
            contact_counts += readdlm(joinpath(
                @__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_counts_activity_1.csv"), ',', Float64)
            contact_counts += readdlm(joinpath(
                @__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_counts_activity_2.csv"), ',', Float64)
        elseif activity_num == 7
            contact_counts += readdlm(joinpath(
                @__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_counts_activity_8.csv"), ',', Float64)
        end

        # contact_counts ./= 2

        xticks = [0, 20, 40, 60, 80]
        xticklabels = ["0", "20", "40", "60", "80"]

        plot_title = "Daily number of contacts"
        if activity_num == 3
            plot_title *= " (School)"
        elseif activity_num == 4
            plot_title *= " (Work)"
        elseif activity_num == 5
            plot_title *= " (Household)"
        elseif activity_num == 6
            plot_title *= " (Visiting)"
        elseif activity_num == 7
            plot_title *= " (Public Space)"
        end

        heatmap_plot = heatmap(
            contact_counts,
            fontfamily = "Times",
            xticks = (xticks, xticklabels),
            title = plot_title,
            margin = 6Plots.mm,
            c = :jet1,
            xlabel = "Age, years",
            ylabel = "Age, years",
            colorbar_title = "Number of contacts",
        )

        contact_counts = log.(contact_counts)

        contour_plot = contourf(
            contact_counts,
            fontfamily = "Times",
            xticks = (xticks, xticklabels),
            title = plot_title,
            margin = 6Plots.mm,
            c = :jet1,
            xlabel = "Age, years",
            ylabel = "Age, years",
            colorbar_title = "Number of contacts",
        )

        name_title = "contact_counts_activity_"
        if activity_num == 3
            name_title *= "school"
        elseif activity_num == 4
            name_title *= "work"
        elseif activity_num == 5
            name_title *= "household"
        elseif activity_num == 6
            name_title *= "visiting"
        elseif activity_num == 7
            name_title *= "public"
        end
        
        savefig(heatmap_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", name_title * ".pdf"))
        savefig(contour_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", name_title * "_contour.pdf"))

    #     contact_durations = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_durations_activity_$(i).csv"), ',', Float64)
        
    #     contact_durations += transpose(contact_durations)
    #     contact_durations ./= 2
        
    #     heatmap_plot = heatmap(
    #         contact_durations,
    #         fontfamily = "Times",
    #         xticks = (xticks, xticklabels),
    #         title = "Average daily contact durations",
    #         c = :jet1,
    #         xlabel = "Age, years",
    #         ylabel = "Age, years",
    #         colorbar_title = "hours",
    #     )
    #     savefig(heatmap_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", "contact_durations_activity_$(i).pdf"))
    # end

    # for i = 5:8
    #     contact_counts_holiday = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_counts_activity_$(i)_holiday.csv"), ',', Float64)
    #     contact_counts_holiday ./= 2

    #     xticks = [0, 20, 40, 60, 80]
    #     xticklabels = ["0", "20", "40", "60", "80"]

    #     heatmap_plot_holiday = heatmap(
    #         contact_counts_holiday,
    #         fontfamily = "Times",
    #         xticks = (xticks, xticklabels),
    #         title = "Contacts on holiday",
    #         margin = 6Plots.mm,
    #         c = :jet1,
    #         xlabel = "Age, years",
    #         ylabel = "Age, years",
    #         colorbar_title = "Number of contacts",
    #     )

    #     contact_counts_holiday = log.(contact_counts_holiday)

    #     contour_plot_holiday = contourf(
    #         contact_counts_holiday,
    #         fontfamily = "Times",
    #         xticks = (xticks, xticklabels),
    #         title = "Daily number of contacts on holiday",
    #         margin = 6Plots.mm,
    #         # nlevels = 50,
    #         # linewidth = 0,
    #         c = :jet1,
    #         xlabel = "Age, years",
    #         ylabel = "Age, years",
    #         colorbar_title = "Number of contacts",
    #     )
        
    #     savefig(heatmap_plot_holiday, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", "contact_counts_activity_$(i)_holiday.pdf"))
    #     savefig(contour_plot_holiday, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", "contact_counts_activity_$(i)_holiday_contour.pdf"))

    #     contact_durations_holiday = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_durations_activity_$(i)_holiday.csv"), ',', Float64)
        
    #     contact_durations_holiday += transpose(contact_durations_holiday)
    #     contact_durations_holiday ./= 2
        
    #     heatmap_plot_holiday = heatmap(
    #         contact_durations_holiday,
    #         fontfamily = "Times",
    #         xticks = (xticks, xticklabels),
    #         title = "Average daily contact durations",
    #         c = :jet1,
    #         xlabel = "Age, years",
    #         ylabel = "Age, years",
    #         colorbar_title = "hours",
    #     )
    #     savefig(heatmap_plot_holiday, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", "contact_durations_activity_$(i)_holiday.pdf"))
    end
end

function plot_contacts_grouped()
    age_groups_nums = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "age_groups_nums.csv"), ',', Float64)

    ticks = collect(1:18)
    ticklabels = [
        "0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34",
        "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69",
        "70-74", "75-79", "80-84", "85-89"]

    contact_counts_matrix = readdlm(joinpath(@__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_counts.csv"), ',', Float64)

    contact_counts = zeros(Float64, 18, 18)
    for i = 1:18
        for j = 1:18
            for k = 0:4
                for l = 0:4
                    contact_counts[i, j] += contact_counts_matrix[(i - 1) * 5 + 1 + k, (j - 1) * 5 + 1 + l]
                end
            end
        end
        # num_people = 0
        # for j = 0:4
        #     num_people += age_groups_nums[(i - 1) * 5 + 1 + j]
        # end
        # contact_counts[i, :] ./= num_people
    end

    heatmap_plot = heatmap(
        contact_counts,
        fontfamily = "Times",
        xticks = (ticks, ticklabels),
        yticks = (ticks, ticklabels),
        title = "Daily number of contacts",
        margin = 6Plots.mm,
        c = :jet,
        xlabel = "Age, years",
        ylabel = "Age, years",
        colorbar_title = "Number of contacts",
        size = (1200, 1200),
    )

    contour_plot = contourf(
        contact_counts,
        fontfamily = "Times",
        xticks = (ticks, ticklabels),
        yticks = (ticks, ticklabels),
        title = "Daily number of contacts",
        margin = 6Plots.mm,
        c = :jet,
        xlabel = "Age, years",
        ylabel = "Age, years",
        colorbar_title = "Number of contacts",
        size = (1200, 1200),
    )
    
    savefig(heatmap_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", "contact_counts.pdf"))
    savefig(contour_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", "contact_counts_contour.pdf"))

    for activity_num = 3:7
        contact_counts_matrix = readdlm(joinpath(
            @__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_counts_activity_$(activity_num).csv"), ',', Float64)
        if activity_num == 3
            contact_counts_matrix += readdlm(joinpath(
                @__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_counts_activity_1.csv"), ',', Float64)
            contact_counts_matrix += readdlm(joinpath(
                @__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_counts_activity_2.csv"), ',', Float64)
        elseif activity_num == 7
            contact_counts_matrix += readdlm(joinpath(
                @__DIR__, "..", "..", "..", "output", "tables", "contacts", "contact_counts_activity_8.csv"), ',', Float64)
        end

        contact_counts = zeros(Float64, 18, 18)
        for i = 1:18
            for j = 1:18
                for k = 0:4
                    for l = 0:4
                        contact_counts[i, j] += contact_counts_matrix[(i - 1) * 5 + 1 + k, (j - 1) * 5 + 1 + l]
                    end
                end
            end
            # num_people = 0
            # for j = 0:4
            #     num_people += age_groups_nums[(i - 1) * 5 + 1 + j]
            # end
            # contact_counts[i, :] ./= num_people
        end

        plot_title = "Daily number of contacts"
        if activity_num == 3
            plot_title *= " (School)"
        elseif activity_num == 4
            plot_title *= " (Work)"
        elseif activity_num == 5
            plot_title *= " (Household)"
        elseif activity_num == 6
            plot_title *= " (Visiting)"
        elseif activity_num == 7
            plot_title *= " (Public Space)"
        end

        heatmap_plot = heatmap(
            contact_counts,
            fontfamily = "Times",
            xticks = (ticks, ticklabels),
            yticks = (ticks, ticklabels),
            # colorbar_scale = :log10,
            title = plot_title,
            margin = 6Plots.mm,
            c = :jet,
            # clims = (0.01, 12.5),
            xlabel = "Age, years",
            ylabel = "Age, years",
            colorbar_title = "Number of contacts",
            size = (1200, 1200),
        )

        contour_plot = contourf(
            contact_counts,
            fontfamily = "Times",
            xticks = (ticks, ticklabels),
            yticks = (ticks, ticklabels),
            title = plot_title,
            margin = 6Plots.mm,
            c = :jet,
            xlabel = "Age, years",
            ylabel = "Age, years",
            colorbar_title = "Number of contacts",
            size = (1200, 1200),
        )

        name_title = "contact_counts_activity_"
        if activity_num == 3
            name_title *= "school"
        elseif activity_num == 4
            name_title *= "work"
        elseif activity_num == 5
            name_title *= "household"
        elseif activity_num == 6
            name_title *= "visiting"
        elseif activity_num == 7
            name_title *= "public"
        end
        
        savefig(heatmap_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", name_title * ".pdf"))
        savefig(contour_plot, joinpath(@__DIR__, "..", "..", "..", "output", "plots", "contacts", name_title * "_contour.pdf"))
    end
end

# plot_contacts()
plot_contacts_grouped()
