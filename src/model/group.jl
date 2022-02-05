# Группа
mutable struct Group
    # Число агентов
    num_agents::Int
    agent_ids::Vector{Int}

    function Group(num_agents::Int, agent_ids::Vector{Int})
        new(num_agents, agent_ids)
    end
end
