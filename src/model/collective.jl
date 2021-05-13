# Группа
struct Group
    # Агенты
    agent_ids::Vector{Int}

    function Group(agent_ids::Vector{Int} = Int[])
        new(agent_ids)
    end
end

# Kindergarten => 1
# School => 2
# University   => 3
# Workplace  => 4

# Коллектив
struct Collective
    # Идентификатор
    id::Int
    # Среднее время проводимое агентами
    mean_time_spent::Float64
    # Среднеквадратическое отклонение времени проводимого агентами
    time_spent_sd::Float64
    # Группы
    groups::Vector{Vector{Group}}

    function Collective(
        id::Int,
        mean_time_spent::Float64,
        time_spent_sd::Float64,
        groups::Vector{Vector{Group}}
    )
        new(id, mean_time_spent, time_spent_sd, groups)
    end
end
