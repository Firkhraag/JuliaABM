# Группа
struct Group
    # Агенты
    agent_ids::Vector{Int}
    # Id коллектива
    collective_id::Int

    function Group(agent_ids::Vector{Int} = Int[], collective_id::Int = 0)
        new(agent_ids, collective_id)
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
        id::Int, mean_time_spent::Float64, time_spent_sd::Float64, groups::Vector{Vector{Group}}
    )
        new(id, mean_time_spent, time_spent_sd, groups)
    end
end

function get_kindergarten_group_size(group_num::Int)
    rand_num = rand(1:100)
    if group_num == 1
        if rand_num <= 20
            return 9
        elseif rand_num <= 80
            return 10
        else
            return 11
        end
    elseif group_num == 2 || group_num == 3
        if rand_num <= 20
            return 14
        elseif rand_num <= 80
            return 15
        else
            return 16
        end
    else
        if rand_num <= 20
            return 19
        elseif rand_num <= 80
            return 20
        else
            return 21
        end
    end
end

function get_school_group_size(group_num::Int)
    rand_num = rand(1:100)
    if rand_num <= 20
        return 24
    elseif rand_num <= 80
        return 25
    else
        return 26
    end
end

function get_university_group_size(group_num::Int)
    rand_num = rand(1:100)
    if group_num == 1
        if rand_num <= 20
            return 14
        elseif rand_num <= 80
            return 15
        else
            return 16
        end
    elseif group_num == 2 || group_num == 3
        if rand_num <= 20
            return 13
        elseif rand_num <= 80
            return 14
        else
            return 15
        end
    elseif group_num == 4
        if rand_num <= 20
            return 12
        elseif rand_num <= 80
            return 13
        else
            return 14
        end
    elseif group_num == 5
        if rand_num <= 20
            return 10
        elseif rand_num <= 80
            return 11
        else
            return 12
        end
    else
        if rand_num <= 20
            return 9
        elseif rand_num <= 80
            return 10
        else
            return 11
        end
    end
end

function get_workplace_group_size()
    # zipfDistribution.sample() + (minFirmSize - 1)
    return rand(6:10)
end