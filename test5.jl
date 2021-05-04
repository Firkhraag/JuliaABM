# N = 2000
# k = 1
# s = 1.0

# zipf_law = k^(-s) / sum((1:N).^(-s))

# println(zipf_law)

struct Group
    c::Int
    function Group(c::Int)
        new(c)
    end
end

groups = Group[]

struct T1
    a::Int
    tt1::Vector{T1}

    function T1(a::Int)
        new(a, T1[])
    end
end

function main1()

    arr = T1[]

    for i = 1:10000
        t = T1(i)
        if i > 1
            for j = 1:(i - 1)
                push!(t.tt1, arr[j])
            end
        end
        push!(arr, t)
    end

end

struct T2
    id::Int
    a::Int
    tt1::Vector{Int}
    group::Group

    function T2(a::Int, group::Group)
        new(a, a, Int[], group)
    end
end

struct T22
    id::Int
    a::Int
    tt1::Vector{Int}
    group_id::Int

    function T22(a::Int, group_id::Int)
        new(a, a, Int[], group_id)
    end
end

function main2()

    arr = T2[]

    for i = 1:10000
        t = T2(i, Group(i))
        if i > 1
            for j = 1:(i - 1)
                push!(t.tt1, arr[j].id)
            end
        end
        push!(arr, t)
    end

end

function main22()

    arr = T22[]

    k = 1
    for i = 1:10000
        g = Group(k)
        k += 1
        push!(groups, g)
        t = T22(i, g.c)
        if i > 1
            for j = 1:(i - 1)
                push!(t.tt1, arr[j].id)
            end
        end
        push!(arr, t)
    end

end

@time main2()
@time main22()
