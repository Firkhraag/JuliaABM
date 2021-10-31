# Ресторан, кафе, столовая
struct Restaurant
    # Id агентов
    groups::Vector{Vector{Int}}
    # Id района
    district_id::Int
    # Координаты
    x::Float64
    y::Float64

    function Restaurant(district_id::Int, x::Float64, y::Float64, num_seats::Int)
        new([Int[0 for _ in 1:num_seats] for __ in 1:shop_num_groups], district_id, x, y)
    end
end
