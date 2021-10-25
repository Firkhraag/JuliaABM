# Домохозяйство
struct Household
    # Id агентов
    agent_ids::Vector{Int}
    # Координаты
    x::Float64
    y::Float64
    # Id ближайшего детского сада
    closest_kindergarten_id::Int
    # Id ближайшей школы
    closest_school_id::Int

    function Household(
        agent_ids::Vector{Int},
        x::Float64,
        y::Float64,
        closest_kindergarten_id::Float64,
        closest_school_id::Float64,
    )
        new(agent_ids, x, y, trunc(closest_kindergarten_id), trunc(closest_school_id))
    end
end
