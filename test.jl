# # mpiexecjl -n 3 julia -t 2 test.jl

# using MPI
# MPI.Init()

# comm = MPI.COMM_WORLD
# print("Hello world, I am rank $(MPI.Comm_rank(comm)) of $(MPI.Comm_size(comm))\n")
# MPI.Barrier(comm)

using MPI

MPI.Init()
comm=MPI.COMM_WORLD
size=MPI.Comm_size(comm)
rank=MPI.Comm_rank(comm)

# buf = Int[rand(1:10), rand(1:10)]

# # Custom reduction operator
# function custom_reducer(
#     arr1::Array{Int, 2}, arr2::Array{Int, 2}
# )::Array{Int, 2}
#     for i = 1:size(arr1, 1)
#         for j = 1:size(arr1[i], 1)
#             arr1[i, j] += arr2[i, j]
#         end
#     end
#     return arr1
# end

# function custom_reducer(
#     arr1::Array{Int, 2}, arr2::Array{Int, 2}
# )::Array{Int, 2}
#     for i = 1:size(arr1, 1)
#         for j = 1:size(arr1[i], 1)
#             arr1[i, j] += arr2[i, j]
#         end
#     end
#     return arr1
# end

function main()
    # buf::Vector{Vector{Int}} = [[rand(1:10), rand(1:10)], [rand(1:10), rand(1:10)]]
    # buf = Array{Int, 2}(undef, 4, 5)
    # buf[1, 1] = rank + 1
    buf = rand(1:5)
    println(buf)
    buf3 = MPI.Allreduce(buf, MPI.SUM, comm)
    println(buf)
    println(buf3)
end

main()

MPI.Finalize()