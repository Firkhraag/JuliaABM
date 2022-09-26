# Детский сад, школа, колледж, университет
mutable struct School
    # Группы
    groups::Vector{Vector{Vector{Int64}}}
    teacher_ids::Vector{Int}
    # Id района
    district_id::Int
    # Координаты
    x::Float64
    y::Float64
    quarantine_period::Int
    quarantine_period_groups::Vector{Int}

    function School(
        type::Int,
        district_id::Int,
        x::Float64,
        y::Float64,
    )
        if type == 1
            new(Vector{Vector{Int64}}[Vector{Int64}[Int[]] for _ in 1:5], Int[], district_id, x, y, 0, [0 for _ in 1:5])
        elseif type == 2
            new(Vector{Vector{Int64}}[Vector{Int64}[Int[]] for _ in 1:11], Int[], district_id, x, y, 0, [0 for _ in 1:11])
        else
            new(Vector{Vector{Int64}}[Vector{Int64}[Int[]] for _ in 1:6], Int[], district_id, x, y, 0, [0 for _ in 1:6])
        end
    end
end