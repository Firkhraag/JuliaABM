### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ 880810b8-cf85-11eb-262c-ed6d761d1528
begin
	using Plots
	using DelimitedFiles
	
	default(legendfontsize = 10, guidefont = (14, :black), tickfont = (10, :black))
	
	contact_counts = readdlm(joinpath(@__DIR__, "..", "..", "output", "tables", "contact_counts.csv"), ',', Float64)
	
	ticks = [0, 20, 40, 60, 80]
    ticklabels = ["0", "20", "40", "60", "80"]
	
	heatmap(contact_counts, fontfamily = "Times", xticks = (ticks, ticklabels))
	xlabel!("Age, years")
    ylabel!("Age, years")
end

# ╔═╡ Cell order:
# ╠═880810b8-cf85-11eb-262c-ed6d761d1528
