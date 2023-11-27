# # Домохозяйство
# struct Household
#     # Id агентов
#     agent_ids::Vector{Int}
#     # Id района
#     district_id::Int
#     # Координаты
#     x::Float64
#     y::Float64
#     # Id ближайшего детского сада
#     closest_kindergarten_id::Int
#     # Id ближайшей школы
#     closest_school_id::Int
    
#     # ! Не используется
#     # Id ближайшего магазина
#     closest_shop_id::Int
#     # Id ближайшего ресторана
#     closest_restaurant_id::Int
#     # Id второго ближайшего магазина
#     closest_shop_id2::Int
#     # Id второго ближайшего ресторана
#     closest_restaurant_id2::Int

#     function Household(
#         agent_ids::Vector{Int},
#         district_id::Int,
#         x::Float64,
#         y::Float64,
#         closest_kindergarten_id::Int,
#         closest_school_id::Int,
#         closest_shop_id::Int,
#         closest_restaurant_id::Int,
#         closest_shop_id2::Int,
#         closest_restaurant_id2::Int,
#     )
#         new(agent_ids, district_id, x, y, closest_kindergarten_id,
#             closest_school_id, closest_shop_id, closest_restaurant_id,
#             closest_shop_id2, closest_restaurant_id2)
#     end
# end

# Домохозяйство
mutable struct Household
    # Id домохозяйства
    id::Int
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
    # Id родителя или попечителя в домохозяйстве
    supporter_id::Int
    # Если агенты-дети нуждаются в уходе при болезни
    children_need_supporter_care::Bool

    function Household(
        id::Int,
        agent_ids::Vector{Int},
        district_id::Int,
        x::Float64,
        y::Float64,
        closest_kindergarten_id::Int,
        closest_school_id::Int,
    )
        new(id, agent_ids, district_id, x, y, closest_kindergarten_id,
            closest_school_id, 0, false)
    end
end

