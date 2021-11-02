# julia --sysimage sys_plots.so src/plots/output/results.jl

using PackageCompiler
using Plots

create_sysimage(:Plots, sysimage_path="sys_plots.so")
