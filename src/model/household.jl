# Домохозяйство
struct Household
    # Id агентов
    agent_ids::Vector{Int}
    # Id района
    district_id::Int
    # Координаты
    x::Float64
    y::Float64
    # Id ближайшего детского сада
    closest_kindergarten_id::Int
    # Id ближайшей школы
    closest_school_id::Int
    # Id ближайшего магазина
    closest_shop_id::Int
    # Id ближайшего ресторана
    closest_restaurant_id::Int

    function Household(
        agent_ids::Vector{Int},
        district_id::Int,
        x::Float64,
        y::Float64,
        closest_kindergarten_id::Int,
        closest_school_id::Int,
        closest_shop_id::Int,
        closest_restaurant_id::Int,
    )
        new(agent_ids, district_id, x, y, closest_kindergarten_id,
            closest_school_id, closest_shop_id, closest_restaurant_id)
    end
end