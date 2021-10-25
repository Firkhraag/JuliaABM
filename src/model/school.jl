# Детский сад, школа, колледж, университет
struct School
    # Группы
    groups::Vector{Vector{Vector{Int64}}}
    # Координаты
    x::Float64
    y::Float64

    function School(
        type::Int,
        x::Float64,
        y::Float64,
    )
        if type == 1
            new(Vector{Vector{Int64}}[
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]]],
                x, y)
        elseif type == 2
            new(Vector{Vector{Int64}}[
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]]],
                x, y)
        else
            new(Vector{Vector{Int64}}[
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]],
                Vector{Int64}[Int[]]],
                x, y)
        end
    end
end