# mpiexecjl -n 6 julia --sysimage sys_project.so model/world_mpi.jl

using PackageCompiler
using Plots
using Distributions
using MPI

create_sysimage([:Plots, :Distributions, :MPI], sysimage_path="sys_project.so")
# create_sysimage(:Plots; sysimage_path="sys_project.so", precompile_execution_file="main.jl")

