# Магазин
struct Shop
    # Id агентов
    groups::Vector{Vector{Int}}
    # Id района
    district_id::Int
    # Координаты
    x::Float64
    y::Float64

    function Shop(district_id::Int, x::Float64, y::Float64, capacity::Int)
        new([Int[0 for _ in 1:capacity] for __ in 1:shop_num_groups], district_id, x, y)
    end
end
