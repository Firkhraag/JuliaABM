# Фирма
struct Workplace
    # Id агентов
    agent_ids::Vector{Int}
    # ! Координаты никак не используются в модели
    # Долгота
    x::Float64
    # Широта
    y::Float64

    function Workplace(agent_ids::Vector{Int}, x::Float64, y::Float64)
        new(agent_ids, x, y)
    end
end
