# function tt(i::Int)
#     return i, i+ 1;
# end

# println([x  for x in tt.([1, 3])])

# b = Array{Float64,4}(undef, 1, 3, 2, 4)
# b[1, 1, 1, 1] = 8.9
# println(b[1, 1, 1, 4])

# a = Array{Vector{Float64}, 1}(fill(undef, 52), 7)
# a = Vector{Float64}[fill(0.0, 52), fill(0.0, 52)]
# a = fill(copy(fill(0.0, 52)), 7)
a = [fill(0.0, 52), fill(0.0, 52), fill(0.0, 52), fill(0.0, 52), fill(0.0, 52), fill(0.0, 52), fill(0.0, 52)]
a[1][1] = 9.0
println(typeof(a))

