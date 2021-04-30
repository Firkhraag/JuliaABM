function tt(i::Int)
    return i, i+ 1;
end

println([x  for x in tt.([1, 3])])

b = Array{Float64,4}(undef, 1, 3, 2, 4)
b[1, 1, 1, 1] = 8.9
println(b[1, 1, 1, 4])

