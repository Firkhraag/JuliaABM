# Ресторан, кафе, столовая
struct Restaurant
    # Id агентов
    groups::Vector{Vector{Int}}
    worker_ids::Vector{Int}
    # Id района
    district_id::Int
    # Координаты
    x::Float64
    y::Float64

    function Restaurant(district_id::Int, x::Float64, y::Float64, num_seats::Int, num_groups::Int)
        new([Int[0 for _ in 1:num_seats] for __ in 1:num_groups], Int[0 for _ in 1:rand(1:6)], district_id, x, y)
    end
end
