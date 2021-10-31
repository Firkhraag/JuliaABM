# Детский сад, школа, колледж, университет
struct School
    # Группы
    groups::Vector{Vector{Vector{Int64}}}
    # Id района
    district_id::Int
    # Координаты
    x::Float64
    y::Float64

    function School(
        type::Int,
        district_id::Int,
        x::Float64,
        y::Float64,
    )
        if type == 1
            new(Vector{Vector{Int64}}[Vector{Int64}[Int[]] for _ in 1:5], district_id, x, y)
        elseif type == 2
            new(Vector{Vector{Int64}}[Vector{Int64}[Int[]] for _ in 1:11], district_id, x, y)
        else
            new(Vector{Vector{Int64}}[Vector{Int64}[Int[]] for _ in 1:6], district_id, x, y)
        end
    end
end