# import Pkg
# Pkg.instantiate()

using PackageCompiler

create_app(joinpath(@__DIR__, ".."), "build"; executables = ["webapp" => "julia_main"], incremental=true)
# PackageCompiler.create_sysimage(["OhMyREPL"]; sysimage_path="OMR-sysimage.so", 
#                                 precompile_statements_file="ohmyrepl_precompile.jl")
