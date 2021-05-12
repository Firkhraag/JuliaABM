using DelimitedFiles
using Distributions
using Random
using MPI

include("agent.jl")
include("../data/district_households.jl")
include("../data/district_people.jl")
include("../data/district_people_households.jl")
include("../data/district_nums.jl")
include("../data/temperature.jl")
include("../data/etiology.jl")

function create_agent(
    agent_id::Int,
    viruses::Vector{Virus},
    viral_loads::Array{Float64, 4},
    household::Group,
    index::Int,
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_household_index::Int,
    is_male::Union{Bool, Nothing} = nothing,
    is_child::Bool = false,
    parent_age::Union{Int, Nothing} = nothing,
    is_older::Bool = false,
    is_parent_of_parent::Bool = false
):: Agent
    age_rand_num = rand(1:100)
    sex_random_num = rand(1:100)
    if is_child
        if parent_age < 23
            # M0–4
            return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 1], rand(0:(parent_age - 18)))
        elseif parent_age < 28
            # T0-4_0–9
            if (age_rand_num <= district_people[index, 19])
                # M0–4
                Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 1], rand(0:4))
            else
                # M5–9
                Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 2], rand(5:(parent_age - 18)))
            end
        elseif parent_age < 33
            # T0-4_0–14
            if (age_rand_num <= district_people[index, 20])
                # M0–4
                Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 1], rand(0:4))
            # T0-9_0–14
            elseif (age_rand_num <= district_people[index, 21])
                # M5–9
                Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 2], rand(5:9))
            else
                # M10–14
                Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 3], rand(10:(parent_age - 18)))
            end
        elseif parent_age < 35
            age_group_rand_num = rand(1:100)
            if age_group_rand_num <= district_people_households[1, district_household_index]
                # T0-4_0–14
                if (age_rand_num <= district_people[index, 20])
                    # M0–4
                    Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 1], rand(0:4))
                # T0-9_0–14
                elseif (age_rand_num <= district_people[index, 21])
                    # M5–9
                    Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 2], rand(5:9))
                else
                    # M10–14
                    Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 3], rand(10:14))
                end
            else
                # M15–19
                return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 4], rand(15:(parent_age - 18)))
            end
        else
            age_group_rand_num = rand(1:100)
            if age_group_rand_num <= district_people_households[1, district_household_index]
                # T0-4_0–14
                if (age_rand_num <= district_people[index, 20])
                    # M0–4
                    Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 1], rand(0:4))
                # T0-9_0–14
                elseif (age_rand_num <= district_people[index, 21])
                    # M5–9
                    Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 2], rand(5:9))
                else
                    # M10–14
                    Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 3], rand(10:14))
                end
            else
                # M15–19
                return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 4], rand(15:17))
            end
        end
    else
        age_group_rand_num = rand(1:100)
        if is_older
            age_group_rand_num = rand((district_people_households[3, district_household_index] + 1):100)
        elseif parent_age !== nothing
            if parent_age < 45
                age_group_rand_num = 1
            elseif parent_age < 55
                age_group_rand_num = rand(1:district_people_households[3, district_household_index])
            elseif parent_age < 65
                age_group_rand_num = rand(1:district_people_households[4, district_household_index])
            else
                age_group_rand_num = rand(1:district_people_households[5, district_household_index])
            end
        elseif is_parent_of_parent
            if parent_age < 25
                age_group_rand_num = rand((district_people_households[3, district_household_index] + 1):100)
            elseif parent_age < 35
                age_group_rand_num = rand((district_people_households[4, district_household_index] + 1):100)
            elseif parent_age < 45
                age_group_rand_num = rand((district_people_households[5, district_household_index] + 1):100)
            else
                age_group_rand_num = 100
            end
        end
        if age_group_rand_num <= district_people_households[2, district_household_index]
            if is_male !== nothing
                return Agent(agent_id, viruses, viral_loads, household, is_male, rand(18:24))
            else
                # M20–24
                return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 5], rand(18:24))
            end
        elseif age_group_rand_num <= district_people_households[3, district_household_index]
            # T25-29_25–34
            if age_rand_num <= district_people[index, 22]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household, is_male, rand(25:29))
                else
                    # M25–29
                    return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 6], rand(25:29))
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household, is_male, rand(30:34))
                else
                    # M30–34
                    return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 7], rand(30:34))
                end
            end
        elseif age_group_rand_num <= district_people_households[4, district_household_index]
            # T35-39_35–44
            if age_rand_num <= district_people[index, 23]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household, is_male, rand(35:39))
                else
                    # M35–39
                    return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 8], rand(35:39))
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household, is_male, rand(40:44))
                else
                    # M40–44
                    return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 9], rand(40:44))
                end
            end
        elseif age_group_rand_num <= district_people_households[5, district_household_index]
            # T45-49_45–54
            if age_rand_num <= district_people[index, 24]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household, is_male, rand(45:49))
                else
                    # M45–49
                    return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 10], rand(45:49))
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household, is_male, rand(50:54))
                else
                    # M50–54
                    return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 11], rand(50:54))
                end
            end
        elseif age_group_rand_num <= district_people_households[6, district_household_index]
            # T55-59_55–64
            if age_rand_num <= district_people[index, 25]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household, is_male, rand(55:59))
                else
                    # M55–59
                    return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 12], rand(55:59))
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household, is_male, rand(60:64))
                else
                    # M60–64
                    return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 13], rand(60:64))
                end
            end
        else
            # T65-69_65–89
            if age_rand_num <= district_people[index, 26]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household, is_male, rand(65:69))
                else
                    # M65–69
                    return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 14], rand(65:69))
                end
            # T65-74_65–89
            elseif age_rand_num <= district_people[index, 27]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household, is_male, rand(70:74))
                else
                    # M70–74
                    return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 15], rand(70:74))
                end
            # T65-79_65–89
            elseif age_rand_num <= district_people[index, 28]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household, is_male, rand(75:79))
                else
                    # M75–79
                    return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 16], rand(75:79))
                end
            # T65-84_65–89
            elseif age_rand_num <= district_people[index, 29]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household, is_male, rand(80:84))
                else
                    # M80–84
                    return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 17], rand(80:84))
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household, is_male, rand(85:89))
                else
                    # M85–89
                    return Agent(agent_id, viruses, viral_loads, household, sex_random_num <= district_people[index, 18], rand(85:89))
                end
            end
        end
    end
end

function create_spouse(
    agent_id::Int,
    viruses::Vector{Virus},
    viral_loads::Array{Float64, 4},
    household::Group,
    partner_age::Int
)
    rand_num = rand(Float64)
    difference = 0
    if rand_num < 0.03
        difference = rand(-20:-15)
    elseif rand_num < 0.08
        difference = rand(-14:-10)
    elseif rand_num < 0.2
        difference = rand(-9:-6)
    elseif rand_num < 0.33
        difference = rand(-5:-4)
    elseif rand_num < 0.53
        difference = rand(-3:-2)
    elseif rand_num < 0.86
        difference = rand(-1:1)
    elseif rand_num < 0.93
        difference = rand(2:3)
    elseif rand_num < 0.96
        difference = rand(4:5)
    elseif rand_num < 0.98
        difference = rand(6:9)
    else
        difference = rand(10:14)
    end

    spouse_age = partner_age + difference
    if spouse_age < 18
        spouse_age = 18
    elseif spouse_age > 89
        spouse_age = 89
    end
    return Agent(agent_id, viruses, viral_loads, household, false, spouse_age)
end

function check_parent_leave(no_one_at_home::Bool, adult::Agent, child::Agent)
    if no_one_at_home && child.age < 14
        push!(adult.dependant_ids, child.id)
        child.supporter_id = adult.id
        if child.age < 3 && child.collective_id == 0
            adult.collective_id = 0
        end
    end
end

function create_parents_with_children(
    agent_id::Int,
    viruses::Vector{Virus},
    viral_loads::Array{Float64, 4},
    household::Group,
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int
)::Vector{Agent}
    agent_male = create_agent(agent_id,
        viruses, viral_loads, household, index,
        district_people, district_people_households,
        district_household_index, true)
    agent_id += 1
    agent_female = create_spouse(
        agent_id, viruses, viral_loads, household, agent_male.age)
    agent_id += 1
    if num_of_other_people == 0
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            agent_id += 1
            no_one_at_home = agent_male.collective_id != 0 && agent_female.collective_id != 0
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, child, child2, child3]
        end
        return Agent[agent_male, agent_female]
    elseif num_of_other_people == 1
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            agent_id += 1
            no_one_at_home = agent_male.collective_id != 0 && agent_female.collective_id != 0
            if agent_other.collective_id == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other]
    elseif num_of_other_people == 2
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            agent_id += 1
            no_one_at_home = agent_male.collective_id != 0 && agent_female.collective_id != 0
            if agent_other.collective_id == 0 || agent_other2.collective_id == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, agent_other2, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            agent_id += 1
            no_one_at_home = agent_male.collective_id != 0 && agent_female.collective_id != 0
            if agent_other.collective_id == 0 || agent_other2.collective_id == 0 || agent_other3.collective_id == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3]
    else
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        agent_other4 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            agent_id += 1
            no_one_at_home = agent_male.collective_id != 0 && agent_female.collective_id != 0
            if agent_other.collective_id == 0 || agent_other2.collective_id == 0 ||
                agent_other3.collective_id == 0 || agent_other4.collective_id == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, agent_female.age)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4]
    end
end

function create_parent_with_children(
    agent_id::Int,
    viruses::Vector{Virus},
    viral_loads::Array{Float64, 4},
    household::Group,
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int,
    is_male_parent::Union{Bool, Nothing},
    with_parent_of_parent::Bool = false
)::Vector{Agent}
    parent = create_agent(agent_id,
        viruses, viral_loads, household, index,
        district_people, district_people_households,
        district_household_index, is_male_parent,
        false, nothing, num_of_other_people > 0)
    agent_id += 1
    if num_of_other_people == 0
        child = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households,
            district_household_index, nothing, true, parent.age)
        agent_id += 1
        no_one_at_home = parent.collective_id != 0
        check_parent_leave(no_one_at_home, parent, child)
        if num_of_children == 1
            return Agent[parent, child]
        end
        child2 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households,
            district_household_index, nothing, true, parent.age)
        agent_id += 1
        check_parent_leave(no_one_at_home, parent, child2)
        if num_of_children == 2
            return Agent[parent, child, child2]
        end
        child3 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households,
            district_household_index, nothing, true, parent.age)
        check_parent_leave(no_one_at_home, parent, child3)
        return Agent[parent, child, child2, child3]
    elseif num_of_other_people == 1
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households,
            district_household_index, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, parent.age)
            agent_id += 1
            no_one_at_home = parent.collective_id != 0
            if agent_other.collective_id == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, parent.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, parent.age)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, child, child2, child3]
        end
        return Agent[parent, agent_other]
    elseif num_of_other_people == 2
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households,
            district_household_index, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households,
            district_household_index, nothing,
            false, parent.age)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, parent.age)
            agent_id += 1
            no_one_at_home = parent.collective_id != 0
            if agent_other.collective_id == 0 || agent_other2.collective_id == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, agent_other2, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, parent.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, parent.age)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households,
            district_household_index, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households,
            district_household_index, nothing,
            false, parent.age)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households,
            district_household_index, nothing,
            false, parent.age)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, parent.age)
            agent_id += 1
            no_one_at_home = parent.collective_id != 0
            if agent_other.collective_id == 0 || agent_other2.collective_id == 0 || agent_other3.collective_id == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, agent_other2, agent_other3, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, parent.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, parent.age)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2, agent_other3]
    else
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households,
            district_household_index, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households,
            district_household_index, nothing,
            false, parent.age)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households,
            district_household_index, nothing,
            false, parent.age)
        agent_id += 1
        agent_other4 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households,
            district_household_index, nothing,
            false, parent.age)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, parent.age)
            agent_id += 1
            no_one_at_home = parent.collective_id != 0
            if agent_other.collective_id == 0 || agent_other2.collective_id == 0 ||
                agent_other3.collective_id == 0 || agent_other4.collective_id == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, parent.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, parent.age)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4]
    end
end

function create_others(
    agent_id::Int,
    viruses::Vector{Virus},
    viral_loads::Array{Float64, 4},
    household::Group,
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int
)::Vector{Agent}
    agent = create_agent(agent_id,
        viruses, viral_loads, household, index,
        district_people, district_people_households, district_household_index)
    agent_id += 1
    if num_of_other_people == 0
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            agent_id += 1
            no_one_at_home = agent.collective_id != 0
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, child, child2, child3]
        end
        return Agent[agent]
    elseif num_of_other_people == 1
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            agent_id += 1
            no_one_at_home = agent.collective_id != 0
            if agent_other.collective_id == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, agent_other, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, child, child2, child3]
        end
        return Agent[agent, agent_other]
    elseif num_of_other_people == 2
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            agent_id += 1
            no_one_at_home = agent.collective_id != 0
            if agent_other.collective_id == 0 || agent_other2.collective_id == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, agent_other, agent_other2, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            agent_id += 1
            no_one_at_home = agent.collective_id != 0
            if agent_other.collective_id == 0 || agent_other2.collective_id == 0 ||
                agent_other3.collective_id == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, agent_other, agent_other2, agent_other3, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2, agent_other3]
    else
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        agent_other4 = create_agent(agent_id,
            viruses, viral_loads, household, index,
            district_people, district_people_households, district_household_index)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            agent_id += 1
            no_one_at_home = agent.collective_id != 0
            if agent_other.collective_id == 0 || agent_other2.collective_id == 0 ||
                agent_other3.collective_id == 0 || agent_other4.collective_id == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household, index,
                district_people, district_people_households,
                district_household_index, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4]
    end
end

function add_agent_to_group(
    agent::Agent,
    collective::Collective,
    group_num::Int,
    group_sizes::Vector{Int},
    get_group_size
)
    if size(collective.groups[group_num], 1) == 0
        group = Group(Int[], collective.id)
        push!(collective.groups[group_num], group)
    end
    length = size(collective.groups[group_num], 1)
    last_group = collective.groups[group_num][length]
    if size(last_group.agent_ids, 1) == group_sizes[group_num]
        last_group = Group(Int[], collective.id)
        push!(collective.groups[group_num], last_group)
        group_sizes[group_num] = get_group_size(group_num)
        length += 1
    end
    push!(last_group.agent_ids, agent.id)
    agent.group_num = group_num
    agent.group_id = length
end

function add_agent_to_kindergarten(
    agent::Agent,
    kindergarten::Collective,
    group_sizes::Vector{Int}
)
    group_num = 1
    if agent.age == 1
        group_num = 2
    elseif agent.age == 2
        group_num = rand(2:3)
    elseif agent.age == 3
        group_num = rand(3:4)
    elseif agent.age == 4
        group_num = rand(4:5)
    elseif agent.age == 5
        group_num = rand(5:6)
    elseif agent.age == 6
        group_num = 6
    end
    add_agent_to_group(agent, kindergarten, group_num, group_sizes, get_kindergarten_group_size)
end

function add_agent_to_school(
    agent::Agent,
    school::Collective,
    group_sizes::Vector{Int}
)
    group_num = 1
    if agent.age == 8
        group_num = 2
    elseif agent.age == 9
        group_num = rand(2:3)
    elseif agent.age == 10
        group_num = rand(3:4)
    elseif agent.age == 11
        group_num = rand(4:5)
    elseif agent.age == 12
        group_num = rand(5:6)
    elseif agent.age == 13
        group_num = rand(6:7)
    elseif agent.age == 14
        group_num = rand(7:8)
    elseif agent.age == 15
        group_num = rand(8:9)
    elseif agent.age == 16
        group_num = rand(9:10)
    elseif agent.age == 17
        group_num = rand(10:11)
    elseif agent.age == 18
        group_num = 11
    end
    add_agent_to_group(agent, school, group_num, group_sizes, get_school_group_size)
end

function add_agent_to_university(
    agent::Agent,
    university::Collective,
    group_sizes::Vector{Int}
)
    group_num = 1
    if agent.age == 19
        group_num = rand(1:2)
    elseif agent.age == 20
        group_num = rand(2:3)
    elseif agent.age == 21
        group_num = rand(3:4)
    elseif agent.age == 22
        group_num = rand(4:5)
    elseif agent.age == 23
        group_num = rand(5:6)
    elseif agent.age == 24
        group_num = 6
    end
    add_agent_to_group(agent, university, group_num, group_sizes, get_university_group_size)
end

# Создание графа Барабаши-Альберта
# На вход подаются группа с набором агентов (group) и число минимальных связей, которые должен иметь агент (m)
function generate_barabasi_albert_network(all_agents::Vector{Agent}, group::Group, m::Int)
    # Связный граф с m вершинами
    for i = 1:m
        for j = 1:m
            if i != j
                push!(all_agents[group.agent_ids[i]].work_conn_ids, all_agents[group.agent_ids[j]].id)
            end
        end
    end
    # Сумма связей всех вершин
    degree_sum = m * (m - 1)
    # Добавление новых вершин
    for i = (m + 1):size(group.agent_ids, 1)
        agent = all_agents[group.agent_ids[i]]
        degree_sum_temp = degree_sum
        for k = 1:m
            cumulative = 0.0
            rand_num = rand(Float64)
            for j = 1:(i-1)
                if group.agent_ids[j] in agent.work_conn_ids
                    continue
                end
                agent2 = all_agents[group.agent_ids[j]]
                cumulative += size(agent2.work_conn_ids, 1) / degree_sum_temp
                if rand_num < cumulative
                    degree_sum_temp -= size(agent2.work_conn_ids, 1)
                    push!(agent.work_conn_ids, agent2.id)
                    push!(agent2.work_conn_ids, agent.id)
                    break
                end
            end
        end
        degree_sum += 2m
    end
end

function add_agent_to_workplace(
    all_agents::Vector{Agent},
    agent::Agent,
    workplace::Collective,
    group_size::Int,
    min_workplace_size::Int,
    max_workplace_size::Int
)
    if size(workplace.groups[1], 1) == 0
        group = Group(Int[], workplace.id)
        push!(workplace.groups[1], group)
    end
    length = size(workplace.groups[1], 1)
    last_group = workplace.groups[1][length]
    if size(last_group.agent_ids, 1) == group_size
        generate_barabasi_albert_network(all_agents, last_group, min_workplace_size)
        last_group = Group(Int[], workplace.id)
        push!(workplace.groups[1], last_group)
        group_size = get_workplace_group_size(min_workplace_size, max_workplace_size)
        length += 1
    end
    push!(last_group.agent_ids, agent.id)
    agent.group_num = 1
    agent.group_id = length
end

function add_agents_to_collectives(
    all_agents::Vector{Agent},
    agents::Vector{Agent},
    collectives::Vector{Collective},
    kindergarten_group_sizes::Vector{Int},
    school_group_sizes::Vector{Int},
    university_group_sizes::Vector{Int},
    workplace_group_size::Int,
    min_workplace_size::Int,
    max_workplace_size::Int
)
    append!(all_agents, agents)
    for agent in agents
        if agent.collective_id == 1
            add_agent_to_kindergarten(agent, collectives[1], kindergarten_group_sizes)
        elseif agent.collective_id == 2
            add_agent_to_school(agent, collectives[2], school_group_sizes)
        elseif agent.collective_id == 3
            add_agent_to_university(agent, collectives[3], university_group_sizes)
        elseif agent.collective_id == 4
            add_agent_to_workplace(
                all_agents, agent, collectives[4], workplace_group_size, min_workplace_size, max_workplace_size)
        end
    end
end

function create_population(
    comm_rank::Int,
    comm_size::Int,
    all_agents::Vector{Agent},
    viruses::Vector{Virus},
    viral_loads::Array{Float64, 4},
    collectives::Vector{Collective}
)
    # Число домохозяйств каждого типа по районам
    district_households = get_district_households()
    # Число людей в каждой группе по районам
    district_people = get_district_people()
    # Число людей в домохозяйствах по районам
    district_people_households = get_district_people_households()
    # Номера районов для MPI процессов
    district_nums = get_district_nums()
    
    kindergarten_group_sizes = Int[
        get_kindergarten_group_size(1),
        get_kindergarten_group_size(2),
        get_kindergarten_group_size(3),
        get_kindergarten_group_size(4),
        get_kindergarten_group_size(5),
        get_kindergarten_group_size(6)]
    school_group_sizes = Int[
        get_school_group_size(1),
        get_school_group_size(2),
        get_school_group_size(3),
        get_school_group_size(4),
        get_school_group_size(5),
        get_school_group_size(6),
        get_school_group_size(7),
        get_school_group_size(8),
        get_school_group_size(9),
        get_school_group_size(10),
        get_school_group_size(11)]
    university_group_sizes = Int[
        get_university_group_size(1),
        get_university_group_size(2),
        get_university_group_size(3),
        get_university_group_size(4),
        get_university_group_size(5),
        get_university_group_size(6)]
    min_workplace_size = 6
    max_workplace_size = 2000
    workplace_group_size = get_workplace_group_size(min_workplace_size, max_workplace_size)

    agent_id = 1
    # for index in district_nums[(comm_rank + 1):comm_size:107]
    for index in district_nums[(comm_rank + 1):comm_size:60]
    # for index in district_nums[(comm_rank + 1):comm_size:56]
    # for index in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
    # for index in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
    # for index in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    # for index in [1]
        index_for_1_people::Int = (index - 1) * 5 + 1
        index_for_2_people::Int = index_for_1_people + 1
        index_for_3_people::Int = index_for_2_people + 1
        index_for_4_people::Int = index_for_3_people + 1
        index_for_5_people::Int = index_for_4_people + 1
        for i in 1:district_households[index, 1]
            # 1P
            household = Group([agent_id])
            agents = Agent[create_agent(
                agent_id, viruses, viral_loads, household, index, district_people, district_people_households, index_for_1_people)]
            agent_id += 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 2]
            # PWOP2P0C
            new_agent_id = agent_id + 1
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_2_people, 0, 0, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 3]
            # PWOP3P0C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 0, 1, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 4]
            # PWOP3P1C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 1, 0, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 5]
            # PWOP4P0C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 0, 2, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 6]
            # PWOP4P1C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 1, 1, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 7]
            # PWOP4P2C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 2, 0, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 8]
            # PWOP5P0C
            new_agent_id = agent_id + 4
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 0, 3, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 9]
            # PWOP5P1C
            new_agent_id = agent_id + 4
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 1, 2, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 10]
            # PWOP5P2C
            new_agent_id = agent_id + 4
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 2, 1, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 11]
            # PWOP5P3C
            new_agent_id = agent_id + 4
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 3, 0, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 12]
            # PWOP6P0C
            new_agent_id = agent_id + 5
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 0, 4, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 13]
            # PWOP6P1C
            new_agent_id = agent_id + 5
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 1, 3, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 14]
            # PWOP6P2C
            new_agent_id = agent_id + 5
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 2, 2, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 15]
            # PWOP6P3C
            new_agent_id = agent_id + 5
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 3, 1, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 16]
            # 2PWOP4P0C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 0, 0, index)
            agent_id += 2
            agents2 = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 0, 0, index)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 17]
            # 2PWOP5P0C
            new_agent_id = agent_id + 4
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 0, 1, index)
            agent_id += 3
            agents2 = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 0, 0, index)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 18]
            # 2PWOP5P1C
            new_agent_id = agent_id + 4
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 1, 0, index)
            agent_id += 3
            agents2 = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 0, 0, index)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 19]
            # 2PWOP6P0C
            new_agent_id = agent_id + 5
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 0, 1, index)
            agent_id += 3
            agents2 = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 0, 1, index)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 20]
            # 2PWOP6P1C
            new_agent_id = agent_id + 5
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 1, 0, index)
            agent_id += 3
            agents2 = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 0, 1, index)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 21]
            # 2PWOP6P2C
            new_agent_id = agent_id + 5
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 1, 0, index)
            agent_id += 3
            agents2 = create_parents_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 1, 0, index)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 22]
            # SMWC2P0C
            new_agent_id = agent_id + 1
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_2_people, 0, 1, index, false)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 23]
            # SMWC2P1C
            new_agent_id = agent_id + 1
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_2_people, 1, 0, index, false)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 24]
            # SMWC3P0C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 0, 2, index, false)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 25]
            # SMWC3P1C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 1, 1, index, false)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 26]
            # SMWC3P2C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 2, 0, index, false)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 27]
            # SMWC4P0C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 0, 3, index, false)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 28]
            # SMWC4P1C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 1, 2, index, false)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 29]
            # SMWC4P2C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 2, 1, index, false)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 30]
            # SMWC4P3C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 3, 0, index, false)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 31]
            # SFWC2P0C
            new_agent_id = agent_id + 1
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_2_people, 0, 1, index, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 32]
            # SFWC2P1C
            new_agent_id = agent_id + 1
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_2_people, 1, 0, index, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 33]
            # SFWC3P0C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 0, 2, index, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 34]
            # SFWC3P1C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 1, 1, index, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 35]
            # SFWC3P2C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 2, 0, index, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 36]
            # SPWCWP3P0C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 0, 2, index, nothing, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 37]
            # SPWCWP3P1C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 1, 1, index, nothing, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 38]
            # SPWCWP4P0C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 0, 3, index, nothing, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 39]
            # SPWCWP4P1C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 1, 2, index, nothing, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 40]
            # SPWCWP4P2C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 2, 1, index, nothing, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end

        for i in 1:district_households[index, 41]
            # SPWCWPWOP3P0C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 0, 2, index, nothing, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 42]
            # SPWCWPWOP3P1C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 1, 1, index, nothing, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 43]
            # SPWCWPWOP4P0C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 0, 3, index, nothing, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 44]
            # SPWCWPWOP4P1C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 1, 2, index, nothing, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 45]
            # SPWCWPWOP4P2C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 2, 1, index, nothing, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 46]
            # SPWCWPWOP5P0C
            new_agent_id = agent_id + 4
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 0, 4, index, nothing, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 47]
            # SPWCWPWOP5P1C
            new_agent_id = agent_id + 4
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 1, 3, index, nothing, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 48]
            # SPWCWPWOP5P2C
            new_agent_id = agent_id + 4
            household = Group(collect(agent_id:new_agent_id))
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 2, 2, index, nothing, true)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end

        for i in 1:district_households[index, 49]
            # O2P0C
            new_agent_id = agent_id + 1
            household = Group(collect(agent_id:new_agent_id))
            agents = create_others(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_2_people, 0, 1, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 50]
            # O2P1C
            new_agent_id = agent_id + 1
            household = Group(collect(agent_id:new_agent_id))
            agents = create_others(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_2_people, 1, 0, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 51]
            # O3P0C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_others(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 0, 2, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 52]
            # O3P1C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_others(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 1, 1, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 53]
            # O3P2C
            new_agent_id = agent_id + 2
            household = Group(collect(agent_id:new_agent_id))
            agents = create_others(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_3_people, 2, 0, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 54]
            # O4P0C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_others(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 0, 3, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 55]
            # O4P1C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_others(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 1, 2, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 56]
            # O4P2C
            new_agent_id = agent_id + 3
            household = Group(collect(agent_id:new_agent_id))
            agents = create_others(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_4_people, 2, 1, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 57]
            # O5P0C
            new_agent_id = agent_id + 4
            household = Group(collect(agent_id:new_agent_id))
            agents = create_others(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 0, 4, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 58]
            # O5P1C
            new_agent_id = agent_id + 4
            household = Group(collect(agent_id:new_agent_id))
            agents = create_others(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 1, 3, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
        for i in 1:district_households[index, 59]
            # O5P2C
            new_agent_id = agent_id + 4
            household = Group(collect(agent_id:new_agent_id))
            agents = create_others(
                agent_id, viruses, viral_loads, household, district_people, district_people_households, index_for_5_people, 2, 2, index)
            agent_id = new_agent_id + 1
            add_agents_to_collectives(
                all_agents, agents, collectives, kindergarten_group_sizes,
                school_group_sizes, university_group_sizes, workplace_group_size,
                min_workplace_size, max_workplace_size)
        end
    end

    last_work_group = collectives[4].groups[1][size(collectives[4].groups[1], 1)]
    if size(last_work_group.agent_ids, 1) >= min_workplace_size
        generate_barabasi_albert_network(all_agents, last_work_group, min_workplace_size)
    else
        generate_barabasi_albert_network(all_agents, last_work_group, size(last_work_group.agent_ids, 1))
    end
end

function get_contact_duration(mean::Float64, sd::Float64)
    return rand(truncated(Normal(mean, sd), 0.0, Inf))
end

function get_contact_duration_gamma(shape::Float64, scale::Float64)
    return rand(Gamma(shape, scale))
end

function make_contact(
    infected_agent::Agent,
    susceptible_agent::Agent,
    contact_duration::Float64,
    step::Int,
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    temp_influences::Array{Float64, 2}
)
    # Влияние продолжительности контакта на вероятность инфицирования
    duration_influence = 1 / (1 + exp(-contact_duration + duration_parameter))
            
    # Влияние температуры воздуха на вероятность инфицирования
    temperature_influence = temp_influences[infected_agent.virus_id, step]

    # Влияние восприимчивости агента на вероятность инфицирования
    susceptibility_influence = 2 / (1 + exp(susceptibility_parameters[infected_agent.virus_id] * susceptible_agent.ig_level))

    # Влияние силы инфекции на вероятность инфицирования
    infectivity_influence = infected_agent.viral_load

    # Вероятность инфицирования
    infection_probability = infectivity_influence * susceptibility_influence *
        temperature_influence * duration_influence

    rand_num = rand(Float64)

    # println("Virus: $(infected_agent.virus_id); Dur: $duration_influence; Temp: $temperature_influence; Susc: $susceptibility_influence; Inf: $infectivity_influence; Prob: $infection_probability")

    if rand_num < infection_probability
        susceptible_agent.virus_id = infected_agent.virus_id
        susceptible_agent.is_newly_infected = true
    end
end

function infect_randomly(
    viruses::Vector{Virus},
    agent::Agent,
    week_num::Int,
    etiology::Matrix{Float64},
)
    rand_num = rand(Float64)
    if rand_num < etiology[week_num, 1]
        if agent.immunity_days[1] == 0
            agent.virus_id = viruses[1].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 2]
        if agent.immunity_days[2] == 0
            agent.virus_id = viruses[2].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 3]
        if agent.immunity_days[3] == 0
            agent.virus_id = viruses[3].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 4]
        if agent.immunity_days[4] == 0
            agent.virus_id = viruses[4].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 5]
        if agent.immunity_days[5] == 0
            agent.virus_id = viruses[5].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 6]
        if agent.immunity_days[6] == 0
            agent.virus_id = viruses[6].id
            agent.is_newly_infected = true
        end
    else
        if agent.immunity_days[7] == 0
            agent.virus_id = viruses[7].id
            agent.is_newly_infected = true
        end
    end
end

function run_simulation(
    comm_rank::Int,
    comm::MPI.Comm,
    all_agents::Vector{Agent},
    viruses::Vector{Virus},
    viral_loads::Array{Float64, 4},
    collectives::Vector{Collective},
    temp_influences::Array{Float64, 2},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    immunity_durations::Vector{Int}
)
    # Вероятность случайного инфицирования
    etiology = get_random_infection_probabilities()

    # День месяца
    day = 1
    # Месяц
    month = 8
    # День недели
    week_day = 1
    # Номер недели
    week_num = 1

    # DEBUG
    max_step = 365

    incidence = Array{Int, 1}(undef, 52)
    etiology_incidence = Array{Int, 2}(undef, 7, 52)
    age_groups_incidence = Array{Int, 2}(undef, 4, 52)
    collectives_incidence = Array{Int, 2}(undef, 5, 52)

    weekly_new_infections_num = 0
    etiology_weekly_new_infections_num = Int[0, 0, 0, 0, 0, 0, 0]
    age_groups_weekly_new_infections_num = Int[0, 0, 0, 0]
    collectives_weekly_new_infections_num = Int[0, 0, 0, 0, 0]

    # daily_new_cases = zeros(Int, 7, 11, 365)
    new_infections_num = zeros(Int, 365)
    # daily_new_recoveries = zeros(Int, 7, 11, 365)

    daily_new_cases_age_groups = zeros(Int, 7, 365)
    daily_new_recoveries_age_groups = zeros(Int, 7, 365)

    daily_new_cases_viruses_asymptomatic = zeros(Int, 7, 365)
    daily_new_cases_viruses = zeros(Int, 7, 365)
    daily_new_recoveries_viruses = zeros(Int, 7, 365)

    daily_new_cases_collectives = zeros(Int, 4, 365)
    daily_new_recoveries_collectives = zeros(Int, 4, 365)

    immunity_viruses = zeros(Int, 7, 365)

    infected_inside_collective = zeros(Int, 5, 365)

    for step = 1:max_step

        if comm_rank == 0
            println("Step: $step")
        end

        # Выходные, праздники
        is_holiday = false
        if (week_day == 7)
            is_holiday = true
        elseif (month == 1 && (day == 1 || day == 2 || day == 3 || day == 7))
            is_holiday = true
        elseif (month == 5 && (day == 1 || day == 9))
            is_holiday = true
        elseif (month == 2 && day == 23)
            is_holiday = true
        elseif (month == 3 && day == 8)
            is_holiday = true
        elseif (month == 6 && day == 12)
            is_holiday = true
        end

        is_work_holiday = false
        if (week_day == 6)
            is_work_holiday = true
        end

        is_kindergarten_holiday = is_work_holiday
        if (month == 7 || month == 8)
            is_kindergarten_holiday = true
        end

        # Каникулы
        # Летние - 01.06.yyyy - 31.08.yyyy
        # Осенние - 05.11.yyyy - 11.11.yyyy
        # Зимние - 28.12.yyyy - 09.03.yyyy
        # Весенние - 22.03.yyyy - 31.03.yyyy
        is_school_holiday = false
        if (month == 6 || month == 7 || month == 8)
            is_school_holiday = true
        elseif (month == 11 && (day >= 5 && day <= 11))
            is_school_holiday = true
        elseif (month == 12 && (day >= 28 && day <= 31))
            is_school_holiday = true
        elseif (month == 1 && (day >= 1 && day <= 9))
            is_school_holiday = true
        elseif (month == 3 && (day >= 22 && day <= 31))
            is_school_holiday = true
        end

        is_university_holiday = false
        if (month == 7 || month == 8)
            is_university_holiday = true
        elseif (month == 1 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27)
            is_university_holiday = true
        elseif (month == 6 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27)
            is_university_holiday = true
        elseif ((month == 2) && (day >= 1 && day <= 10))
            is_university_holiday = true
        elseif (month == 12 && (day >= 22 && day <= 31))
            is_university_holiday = true
        end
        
        for agent in all_agents
            if agent.virus_id != 0 && !agent.is_newly_infected && agent.viral_load > 0.0001
                for agent2_id in agent.household.agent_ids
                    agent2 = all_agents[agent2_id]
                    # Проверка восприимчивости агента к вирусу
                    if agent2.virus_id == 0 && agent2.days_immune == 0 &&
                            agent2.immunity_days[agent.virus_id] == 0
                        agent_at_home = agent.is_isolated || agent.on_parent_leave || agent.collective_id == 0
                        agent2_at_home = agent2.is_isolated || agent2.on_parent_leave || agent2.collective_id == 0
                        # if is_holiday || (agent_at_home && agent2_at_home)
                        #     make_contact(
                        #         agent, agent2, get_contact_duration(12.5, 5.5),
                        #         step, duration_parameter, susceptibility_parameters, temp_influences)
                        # elseif ((agent.collective_id == 4 && !agent_at_home) ||
                        #     (agent2.collective_id == 4 && !agent2_at_home)) && !is_work_holiday
                        #     make_contact(
                        #         agent, agent2, get_contact_duration(4.5, 2.25),
                        #         step, duration_parameter, susceptibility_parameters, temp_influences)
                        # elseif ((agent.collective_id == 2 && !agent_at_home) ||
                        #     (agent2.collective_id == 2 && !agent2_at_home)) && !is_school_holiday
                        #     make_contact(
                        #         agent, agent2, get_contact_duration(6.1, 2.46),
                        #         step, duration_parameter, susceptibility_parameters, temp_influences)
                        # elseif ((agent.collective_id == 1 && !agent_at_home) ||
                        #     (agent2.collective_id == 1 && !agent2_at_home)) && !is_kindergarten_holiday
                        #     make_contact(
                        #         agent, agent2, get_contact_duration(7.0, 2.65),
                        #         step, duration_parameter, susceptibility_parameters, temp_influences)
                        # elseif ((agent.collective_id == 3 && !agent_at_home) ||
                        #     (agent2.collective_id == 3 && !agent2_at_home)) && !is_university_holiday
                        #     make_contact(
                        #         agent, agent2, get_contact_duration(10.0, 3.69),
                        #         step, duration_parameter, susceptibility_parameters, temp_influences)
                        # end

                        if is_holiday || (agent_at_home && agent2_at_home)
                            make_contact(
                                agent, agent2, get_contact_duration(12.5, 5.5),
                                step, duration_parameter, susceptibility_parameters, temp_influences)
                        elseif ((agent.collective_id == 1 && !agent_at_home) ||
                            (agent2.collective_id == 1 && !agent2_at_home)) && !is_kindergarten_holiday
                            make_contact(
                                agent, agent2, get_contact_duration(5.0, 2.05),
                                step, duration_parameter, susceptibility_parameters, temp_influences)
                        elseif ((agent.collective_id == 4 && !agent_at_home) ||
                            (agent2.collective_id == 4 && !agent2_at_home)) && !is_work_holiday
                            make_contact(
                                agent, agent2, get_contact_duration(5.5, 2.25),
                                step, duration_parameter, susceptibility_parameters, temp_influences)
                        elseif ((agent.collective_id == 2 && !agent_at_home) ||
                            (agent2.collective_id == 2 && !agent2_at_home)) && !is_school_holiday
                            make_contact(
                                agent, agent2, get_contact_duration(6.0, 2.46),
                                step, duration_parameter, susceptibility_parameters, temp_influences)
                        elseif ((agent.collective_id == 3 && !agent_at_home) ||
                            (agent2.collective_id == 3 && !agent2_at_home)) && !is_university_holiday
                            make_contact(
                                agent, agent2, get_contact_duration(7.0, 3.69),
                                step, duration_parameter, susceptibility_parameters, temp_influences)
                        end
                        if agent2.virus_id != 0
                            infected_inside_collective[5, step] += 1
                        end
                    end
                end
                if !is_holiday && agent.group_num != 0 && !agent.is_isolated && !agent.on_parent_leave &&
                    ((agent.collective_id == 1 && !is_kindergarten_holiday) ||
                        (agent.collective_id == 2 && !is_school_holiday) ||
                        (agent.collective_id == 3 && !is_university_holiday) ||
                        (agent.collective_id == 4 && !is_work_holiday))
                    if agent.collective_id == 4
                        for agent2_id in agent.work_conn_ids
                            agent2 = all_agents[agent2_id]
                            # Проверка восприимчивости агента к вирусу
                            if agent2.virus_id == 0 && agent2.days_immune == 0 &&
                                    agent2.immunity_days[agent.virus_id] == 0 &&
                                        !agent2.is_isolated && !agent2.on_parent_leave
                                    make_contact(
                                        agent, agent2, get_contact_duration(
                                            collectives[4].mean_time_spent,
                                            collectives[4].time_spent_sd),
                                        step, duration_parameter,
                                        susceptibility_parameters, temp_influences)
                                    if agent2.virus_id != 0
                                        infected_inside_collective[agent.collective_id, step] += 1
                                    end
                            end
                        end
                    else
                        if agent.collective_id != 2|| agent.group_num != 1 || !is_work_holiday
                            group = collectives[agent.collective_id].groups[agent.group_num][agent.group_id]
                            for agent2_id in group.agent_ids
                                agent2 = all_agents[agent2_id]
                                # Проверка восприимчивости агента к вирусу
                                if agent2.virus_id == 0 && agent2.days_immune == 0 &&
                                        agent2.immunity_days[agent.virus_id] == 0 &&
                                            !agent2.is_isolated && !agent2.on_parent_leave
                                        make_contact(
                                            agent, agent2, get_contact_duration(
                                                collectives[group.collective_id].mean_time_spent,
                                                collectives[group.collective_id].time_spent_sd),
                                            step, duration_parameter,
                                            susceptibility_parameters, temp_influences)
                                    if agent2.virus_id != 0
                                        infected_inside_collective[agent.collective_id, step] += 1
                                    end
                                end
                            end
                        end
                    end
                end
            elseif agent.virus_id == 0 && agent.days_immune == 0
                if agent.age < 16
                    if rand(Float64) < 0.0002
                        infect_randomly(viruses, agent, week_num, etiology)
                    end
                else
                    if rand(Float64) < 0.0001
                        infect_randomly(viruses, agent, week_num, etiology)
                    end
                end
            end
        end

        # new_infections_num = 0
        for agent in all_agents
            if agent.days_immune != 0
                if agent.days_immune == 14
                    # Переход из резистентного состояния в восприимчивое
                    agent.days_immune = 0
                else
                    agent.days_immune += 1
                end
            end
            for k = 1:size(agent.immunity_days, 1)
                immunity_days = agent.immunity_days[k]
                if immunity_days > 0
                    if immunity_days == immunity_durations[k]
                        agent.immunity_days[k] = 0
                    else
                        agent.immunity_days[k] += 1
                        immunity_viruses[k, step] += 1
                    end
                end
            end

            if agent.virus_id != 0 && !agent.is_newly_infected
                if agent.days_infected == agent.infection_period

                    daily_new_recoveries_viruses[agent.virus_id, step] += 1
                    if agent.age < 3
                        daily_new_recoveries_age_groups[1, step] += 1
                    elseif agent.age < 7
                        daily_new_recoveries_age_groups[2, step] += 1
                    elseif agent.age < 15
                        daily_new_recoveries_age_groups[3, step] += 1
                    elseif agent.age < 18
                        daily_new_recoveries_age_groups[4, step] += 1
                    elseif agent.age < 25
                        daily_new_recoveries_age_groups[5, step] += 1
                    elseif agent.age < 65
                        daily_new_recoveries_age_groups[6, step] += 1
                    else
                        daily_new_recoveries_age_groups[7, step] += 1
                    end
                    if agent.collective_id != 0
                        daily_new_recoveries_collectives[agent.collective_id, step] += 1
                    end

                    agent.immunity_days[agent.virus_id] = 1
                    agent.days_immune = 1
                    agent.virus_id = 0
                    agent.is_isolated = false
    
                    if agent.supporter_id != 0
                        is_support_still_needed = false
                        for dependant_id in all_agents[agent.supporter_id].dependant_ids
                            dependant = all_agents[dependant_id]
                            if dependant.virus_id != 0 && !dependant.is_asymptomatic && (dependant.collective_id == 0 || dependant.is_isolated)
                                is_support_still_needed = true
                            end
                        end
                        if !is_support_still_needed
                            all_agents[agent.supporter_id].on_parent_leave = false
                        end
                    end
                else
                    agent.days_infected += 1
    
                    if !agent.is_asymptomatic && !agent.is_isolated && agent.collective_id != 0 && !agent.on_parent_leave
                        if agent.days_infected == 1
                            rand_num = rand(Float64)
                            if agent.age < 8
                                if rand_num < 0.305
                                    agent.is_isolated = true
                                    new_infections_num[step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    else
                                        age_groups_weekly_new_infections_num[3] += 1
                                    end
                                end
                            elseif agent.age < 18
                                if rand_num < 0.204
                                    agent.is_isolated = true
                                    new_infections_num[step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            else
                                if rand_num < 0.101
                                    agent.is_isolated = true
                                    new_infections_num[step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            end
                        elseif agent.days_infected == 2
                            rand_num = rand(Float64)
                            if agent.age < 8
                                if rand_num < 0.576
                                    agent.is_isolated = true
                                    new_infections_num[step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            elseif agent.age < 18
                                if rand_num < 0.499
                                    agent.is_isolated = true
                                    new_infections_num[step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            else
                                if rand_num < 0.334
                                    agent.is_isolated = true
                                    new_infections_num[step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            end
                        elseif agent.days_infected == 3
                            rand_num = rand(Float64)
                            if agent.age < 8
                                if rand_num < 0.325
                                    agent.is_isolated = true
                                    new_infections_num[step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            elseif agent.age < 18
                                if rand_num < 0.376
                                    agent.is_isolated = true
                                    new_infections_num[step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            else
                                if rand_num < 0.168
                                    agent.is_isolated = true
                                    new_infections_num[step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            end
                        end
                    end
                    
                    agent.viral_load = find_agent_viral_load(
                        agent.age,
                        viral_loads[agent.virus_id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
                        agent.is_asymptomatic && agent.days_infected > 0)
    
                    if agent.supporter_id != 0 && !agent.is_asymptomatic && agent.days_infected > 0 && (agent.is_isolated || agent.collective_id == 0)
                        all_agents[agent.supporter_id].on_parent_leave = true
                    end
                end
            elseif agent.is_newly_infected

                daily_new_cases_viruses[agent.virus_id, step] += 1
                if agent.age < 3
                    daily_new_cases_age_groups[1, step] += 1
                elseif agent.age < 7
                    daily_new_cases_age_groups[2, step] += 1
                elseif agent.age < 15
                    daily_new_cases_age_groups[3, step] += 1
                elseif agent.age < 18
                    daily_new_cases_age_groups[4, step] += 1
                elseif agent.age < 25
                    daily_new_cases_age_groups[5, step] += 1
                elseif agent.age < 65
                    daily_new_cases_age_groups[6, step] += 1
                else
                    daily_new_cases_age_groups[7, step] += 1
                end
                if agent.collective_id != 0
                    daily_new_cases_collectives[agent.collective_id, step] += 1
                end

                agent.incubation_period = get_period_from_erlang(
                    viruses[agent.virus_id].mean_incubation_period,
                    viruses[agent.virus_id].incubation_period_variance,
                    viruses[agent.virus_id].min_incubation_period,
                    viruses[agent.virus_id].max_incubation_period)
                if agent.age < 16
                    agent.infection_period = get_period_from_erlang(
                        viruses[agent.virus_id].mean_infection_period_child,
                        viruses[agent.virus_id].infection_period_variance_child,
                        viruses[agent.virus_id].min_infection_period_child,
                        viruses[agent.virus_id].max_infection_period_child)
                else
                    agent.infection_period = get_period_from_erlang(
                        viruses[agent.virus_id].mean_infection_period_adult,
                        viruses[agent.virus_id].infection_period_variance_adult,
                        viruses[agent.virus_id].min_infection_period_adult,
                        viruses[agent.virus_id].max_infection_period_adult)
                end
                agent.days_infected = 1 - agent.incubation_period
                if rand(Float64) < viruses[agent.virus_id].asymptomatic_probab
                    daily_new_cases_viruses_asymptomatic[agent.virus_id, step] += 1
                    agent.is_asymptomatic = true
                else
                    agent.is_asymptomatic = false
                end
                agent.viral_load = find_agent_viral_load(
                    agent.age,
                    viral_loads[agent.virus_id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
                    agent.is_asymptomatic && agent.days_infected > 0)
                agent.is_newly_infected = false
            end
        end

        weekly_new_infections_num += new_infections_num[step]

        # Обновление даты
        if week_day == 7
            incidence[week_num] = weekly_new_infections_num
            weekly_new_infections_num = 0
            for i = 1:size(etiology_weekly_new_infections_num, 1)
                etiology_incidence[i, week_num] = etiology_weekly_new_infections_num[i]
                etiology_weekly_new_infections_num[i] = 0
            end
            for i = 1:size(age_groups_weekly_new_infections_num, 1)
                age_groups_incidence[i, week_num] = age_groups_weekly_new_infections_num[i]
                age_groups_weekly_new_infections_num[i] = 0
            end

            week_day = 1
            if week_num == 52
                week_num = 1
            else
                week_num += 1
            end
        else
            week_day += 1
        end

        if (month in Int[1, 3, 5, 7, 8, 10] && day == 31) ||
            (month in Int[4, 6, 9, 11] && day == 30) ||
            (month == 2 && day == 28)
            day = 1
            month += 1
            if comm_rank == 0
                println("Month: $month")
            end
        elseif (month == 12 && day == 31)
            day = 1
            month = 1
            if comm_rank == 0
                println("Month: 1")
            end
        else
            day += 1
        end
    end

    num_of_agents = MPI.Allreduce(size(all_agents, 1), MPI.SUM, comm)
    multiplier = 1000 / num_of_agents
    incidence_data = MPI.Reduce(incidence, MPI.SUM, 0, comm)
    etiology_data = MPI.Reduce(etiology_incidence, MPI.SUM, 0, comm)
    age_groups_data = MPI.Reduce(age_groups_incidence, MPI.SUM, 0, comm)

    daily_new_cases_age_groups_data = MPI.Reduce(daily_new_cases_age_groups, MPI.SUM, 0, comm)
    daily_new_recoveries_age_groups_data = MPI.Reduce(daily_new_recoveries_age_groups, MPI.SUM, 0, comm)

    daily_new_cases_viruses_asymptomatic_data = MPI.Reduce(daily_new_cases_viruses_asymptomatic, MPI.SUM, 0, comm)
    daily_new_cases_viruses_data = MPI.Reduce(daily_new_cases_viruses, MPI.SUM, 0, comm)
    daily_new_recoveries_viruses_data = MPI.Reduce(daily_new_recoveries_viruses, MPI.SUM, 0, comm)

    daily_new_cases_collectives_data = MPI.Reduce(daily_new_cases_collectives, MPI.SUM, 0, comm)
    daily_new_recoveries_collectives_data = MPI.Reduce(daily_new_recoveries_collectives, MPI.SUM, 0, comm)

    immunity_viruses_data = MPI.Reduce(immunity_viruses, MPI.SUM, 0, comm)
    infected_inside_collective_data = MPI.Reduce(infected_inside_collective, MPI.SUM, 0, comm)

    if comm_rank == 0
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "incidence_data.csv"), incidence_data .* multiplier, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "etiology_data.csv"), etiology_data .* multiplier, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "age_groups_data.csv"), age_groups_data .* multiplier, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_age_groups_data.csv"), daily_new_cases_age_groups_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_recoveries_age_groups_data.csv"), daily_new_recoveries_age_groups_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_viruses_asymptomatic_data.csv"), daily_new_cases_viruses_asymptomatic_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_viruses_data.csv"), daily_new_cases_viruses_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_recoveries_viruses_data.csv"), daily_new_recoveries_viruses_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_collectives_data.csv"), daily_new_cases_collectives_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_recoveries_collectives_data.csv"), daily_new_recoveries_collectives_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "immunity_viruses_data.csv"), immunity_viruses_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "infected_inside_collective_data.csv"), infected_inside_collective_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "registered_new_cases_data.csv"), new_infections_num, ',')
    end
end

function main()
    MPI.Init()

    comm = MPI.COMM_WORLD
    comm_size = MPI.Comm_size(comm)
    comm_rank = MPI.Comm_rank(comm)

    if comm_rank == 0
        println("Initialization...")
    end
    
    # Вирусы
    viruses = Virus[
        Virus(1, 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 0.16),
        Virus(2, 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 0.16),
        Virus(3, 1.9, 0.175, 1, 7, 10.1, 4.93, 3, 12, 11.4, 6.25, 4, 14, 3.5, 0.3),
        Virus(4, 4.4, 0.937, 1, 7, 7.4, 2.66, 3, 12, 9.3, 4.0, 4, 14, 6.0, 0.3),
        Virus(5, 5.6, 1.51, 1, 7, 8.0, 3.1, 3, 12, 9.0, 3.92, 4, 14, 4.1, 0.3),
        Virus(6, 2.6, 0.327, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.7, 0.3),
        Virus(7, 3.2, 0.496, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.93, 0.3)]
    # viruses = Virus[
    #     Virus(1, 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 0.01),
    #     Virus(2, 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 0.01),
    #     Virus(3, 1.9, 0.175, 1, 7, 10.1, 4.93, 3, 12, 11.4, 6.25, 4, 14, 3.5, 0.9),
    #     Virus(4, 4.4, 0.937, 1, 7, 7.4, 2.66, 3, 12, 9.3, 4.0, 4, 14, 6.0, 0.9),
    #     Virus(5, 5.6, 1.51, 1, 7, 8.0, 3.1, 3, 12, 9.0, 3.92, 4, 14, 4.1, 0.9),
    #     Virus(6, 2.6, 0.327, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.7, 0.9),
    #     Virus(7, 3.2, 0.496, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.93, 0.9)]

    viral_loads = Array{Float64,4}(undef, 7, 7, 13, 21)

    for days_infected in -6:14
        days_infected_index = days_infected + 7
        for infection_period in 2:14
            infection_period_index = infection_period - 1
            for incubation_period in 1:7
                min_days_infected = 1 - incubation_period
                mean_viral_loads = [4.6, 4.7, 3.5, 6.0, 4.1, 4.7, 4.93]
                for i in 1:7
                    if (days_infected >= min_days_infected) && (days_infected <= infection_period)
                        viral_loads[i, incubation_period, infection_period_index, days_infected_index] = get_viral_load(
                            days_infected, incubation_period, infection_period, mean_viral_loads[i])
                    end
                end
            end
        end
    end

    # Коллективы
    collectives = Collective[
        Collective(1, 5.88, 2.52, [Group[], Group[], Group[], Group[], Group[], Group[]]),
        Collective(2, 4.783, 2.67, [Group[], Group[], Group[], Group[], Group[], Group[],
            Group[], Group[], Group[], Group[], Group[]]),
        Collective(3, 2.1, 3.0, [Group[], Group[], Group[], Group[], Group[], Group[]]),
        Collective(4, 3.0, 3.0, [Group[]])]
    # collectives = Collective[
    #     # http://ecs.force.com/mbdata/MBQuest2RTanw?rep=KK3Q1806#:~:text=6%20hours%20per%20day%20for%20kindergarten%20and%20elementary%20students.&text=437.5%20hours%20per%20year%20for%20half%2Dday%20kindergarten.
    #     Collective(1, 5.5, 1.0, [Group[], Group[], Group[], Group[], Group[], Group[]]),
    #     # https://nces.ed.gov/surveys/sass/tables/sass0708_035_s1s.asp
    #     # Mixing patterns between age groups in social networks
    #     Collective(2, 6.64, 1.0, [Group[], Group[], Group[], Group[], Group[], Group[],
    #         Group[], Group[], Group[], Group[], Group[]]),
    #     # 
    #     Collective(3, 2.0, 0.5, [Group[], Group[], Group[], Group[], Group[], Group[]]),
    #     # American Time Use Survey Summary. Bls.gov. 2017-06-27. Retrieved 2018-06-06
    #     Collective(4, 7.9, 1.0, [Group[]])]

    # Параметры
    duration_parameter = 7.05
    temperature_parameters = Float64[-0.8, -0.8, -0.05, -0.64, -0.2, -0.05, -0.8]   
    # temperature_parameters = Float64[-0.8, -0.8, -0.1, -0.64, -0.2, -0.1, -0.8]   
    susceptibility_parameters = Float64[2.61, 2.61, 3.17, 5.11, 4.69, 3.89, 3.77]
    # susceptibility_parameters = Float64[2.1, 2.1, 3.77, 4.89, 4.69, 3.89, 3.77]
    immunity_durations = Int[366, 366, 60, 60, 90, 90, 366]

    # Температура воздуха, начиная с 1 января
    temperature = get_air_temperature()

    # Минимальная температура воздуха
    min_temp = -7.2
    # Max - Min температура
    max_min_temp = 26.6

    temp_influences = Array{Float64,2}(undef, 7, 365)
    year_day = 213
    for step in 1:365
        current_temp = (temperature[year_day] - min_temp) / max_min_temp
        for v in 1:7
            temp_influences[v, step] = temperature_parameters[v] * current_temp + 1.0
        end
        if year_day == 365
            year_day = 1
        else
            year_day += 1
        end
    end

    # Набор агентов
    all_agents = Agent[]

    @time create_population(
        comm_rank, comm_size, all_agents, viruses, viral_loads, collectives)
    MPI.Barrier(comm)

    # println("Stats...")
    # age_groups_nums = Int[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    # collective_nums = Int[0, 0, 0, 0]
    # household_nums = Int[0, 0, 0, 0, 0, 0]
    # mean_ig_level = 0.0
    # num_of_infected = 0
    # mean_num_of_work_conn = 0.0
    # size_work_conn = 0
    # mean_size_work_groups = size(collectives[4].groups[1], 1)
    # mean_size_work_group = 0
    # for agent in all_agents
    #     if agent.age < 3
    #         age_groups_nums[1] += 1
    #     elseif agent.age < 7
    #         age_groups_nums[2] += 1
    #     elseif agent.age < 16
    #         age_groups_nums[3] += 1
    #     elseif agent.age < 18
    #         age_groups_nums[4] += 1
    #     elseif agent.age < 25
    #         age_groups_nums[5] += 1
    #     elseif agent.age < 35
    #         age_groups_nums[6] += 1
    #     elseif agent.age < 45
    #         age_groups_nums[7] += 1
    #     elseif agent.age < 55
    #         age_groups_nums[8] += 1
    #     elseif agent.age < 65
    #         age_groups_nums[9] += 1
    #     elseif agent.age < 75
    #         age_groups_nums[10] += 1
    #     else
    #         age_groups_nums[11] += 1
    #     end

    #     if agent.collective_id == 1
    #         collective_nums[1] += 1
    #     elseif agent.collective_id == 2
    #         collective_nums[2] += 1
    #     elseif agent.collective_id == 3
    #         collective_nums[3] += 1
    #     elseif agent.collective_id == 4
    #         collective_nums[4] += 1
    #     end

    #     household_nums[size(agent.household.agent_ids, 1)] += 1

    #     mean_ig_level += agent.ig_level
    #     if size(agent.work_conn_ids, 1) != 0
    #         mean_num_of_work_conn += size(agent.work_conn_ids, 1)
    #         size_work_conn += 1
    #     end

    #     if agent.virus_id != 0
    #         num_of_infected += 1
    #     end
    # end
    # for group in collectives[4].groups[1]
    #     mean_size_work_group += size(group.agent_ids, 1)
    # end
    # for i = 1:6
    #     household_nums[i] /= i
    # end

    # age_groups_all = MPI.Reduce(age_groups_nums, MPI.SUM, 0, comm)

    # collective_nums_all = MPI.Reduce(collective_nums, MPI.SUM, 0, comm)

    # household_nums_all = MPI.Reduce(household_nums, MPI.SUM, 0, comm)

    # mean_ig_level_all = MPI.Reduce(mean_ig_level, MPI.SUM, 0, comm)
    # size_all = MPI.Reduce(size(all_agents, 1), MPI.SUM, 0, comm)

    # num_of_infected_all = MPI.Reduce(num_of_infected, MPI.SUM, 0, comm)

    # mean_num_of_work_conn_all = MPI.Reduce(mean_num_of_work_conn, MPI.SUM, 0, comm)
    # size_work_con_all = MPI.Reduce(size_work_conn, MPI.SUM, 0, comm)

    # mean_size_work_groups_all = MPI.Reduce(mean_size_work_groups, MPI.SUM, 0, comm)
    # mean_size_work_group_all = MPI.Reduce(mean_size_work_group, MPI.SUM, 0, comm)

    # println("Age groups: $(age_groups_all)")
    # println("Collectives: $(collective_nums_all)")
    # println("Households: $(household_nums_all)")
    # println("Ig level: $(mean_ig_level_all / size_all)")
    # println("Infected: $(num_of_infected_all)")
    # println("Work conn: $(mean_num_of_work_conn_all / size_work_con_all)")
    # println("Work groups: $(mean_size_work_groups_all)")
    # println("Work group agents: $(mean_size_work_group_all / mean_size_work_groups_all)")
    # MPI.Barrier(comm)

    if comm_rank == 0
        println("Simulation...")
    end
    @time run_simulation(
        comm_rank, comm, all_agents, viruses, viral_loads,
        collectives, temp_influences, duration_parameter,
        susceptibility_parameters, immunity_durations)
    MPI.Barrier(comm)
end

main()
