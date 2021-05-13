using Distributed

@everywhere function slow(n::Int, digit::Int, taskid::Int, ntasks::Int)
    println("running on worker ", myid())
    total = 0
    # @distributed (+) for
    @time for i in taskid:ntasks:n
        if !(i % digit == 0)
            total += 1. / i
        end
    end
    return total
end

# a = @spawnat :any slow(Int64(1e9), 9, 1, 2)
# b = @spawnat :any slow(Int64(1e9), 9, 2, 2)
# print("total: ", fetch(a) + fetch(b))

r = [@spawnat p slow(Int64(1e9), 9, i, nworkers()) for (i, p) in enumerate(workers())]
print("total: ", sum([fetch(r[i]) for i in 1:nworkers()]))

# args = [(Int64(1e9), 9, i, nworkers()) for i = 1:nworkers()]
# sum(pmap(slow, args))

function slow2(n::Int, digit::Int)
    println("running on worker ", myid())
    total = 0
    @time for i in 1:n
        if !(i % digit == 0)
            total += 1. / i
        end
    end
    return total
end

slow2(Int64(1e9), 9)
