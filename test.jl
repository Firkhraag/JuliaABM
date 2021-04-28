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

buf = Int[rand(1:10), rand(1:10)]

buf2 = MPI.Reduce(buf, MPI.SUM, 0, comm)
if rank == 0
    println(buf2)
end
MPI.Finalize()