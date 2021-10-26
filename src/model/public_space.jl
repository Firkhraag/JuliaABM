# 
struct PublicSpace
    # Id агентов
    agent_ids::Vector{Int}
    # Координаты
    x::Float64
    y::Float64

    function PublicSpace(x::Float64, y::Float64)
        new(Int[], x, y)
    end
end
