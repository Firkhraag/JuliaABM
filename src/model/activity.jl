struct Activity
    # Id агентов
    agent_ids::Vector{Int}
    # Координаты
    x::Float64
    y::Float64

    function Workplace(agent_ids::Vector{Int}, x::Float64, y::Float64)
        new(agent_ids, x, y)
    end
end
