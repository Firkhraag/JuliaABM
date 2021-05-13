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

function get_kindergarten_group_size(group_num::Int)
    rand_num = rand(Float64)
    if group_num == 1
        if rand_num < 0.2
            return 9
        elseif rand_num < 0.8
            return 10
        else
            return 11
        end
    elseif group_num == 2 || group_num == 3
        if rand_num < 0.2
            return 14
        elseif rand_num < 0.8
            return 15
        else
            return 16
        end
    else
        if rand_num < 0.2
            return 19
        elseif rand_num < 0.8
            return 20
        else
            return 21
        end
    end
end

function get_school_group_size(group_num::Int)
    rand_num = rand(Float64)
    if rand_num < 0.2
        return 24
    elseif rand_num < 0.8
        return 25
    else
        return 26
    end
end

function get_university_group_size(group_num::Int)
    rand_num = rand(Float64)
    if group_num == 1
        if rand_num < 0.2
            return 14
        elseif rand_num < 0.8
            return 15
        else
            return 16
        end
    elseif group_num == 2 || group_num == 3
        if rand_num < 0.2
            return 13
        elseif rand_num < 0.8
            return 14
        else
            return 15
        end
    elseif group_num == 4
        if rand_num < 0.2
            return 12
        elseif rand_num < 0.8
            return 13
        else
            return 14
        end
    elseif group_num == 5
        if rand_num < 0.2
            return 10
        elseif rand_num < 0.8
            return 11
        else
            return 12
        end
    else
        if rand_num < 0.2
            return 9
        elseif rand_num < 0.8
            return 10
        else
            return 11
        end
    end
end

function sample_from_zipf_distribution(
    s::Float64, N::Int
)::Int
    cumulative = 0.0
    rand_num = rand(Float64)
    multiplier = 1 / sum((1:N).^(-s))
    for i = 1:N
        cumulative += i^(-s) * multiplier
        if rand_num < cumulative
            return i
        end
    end
    return N
end

function get_workplace_group_size(
    min_workplace_size::Int, max_workplace_size::Int
)::Int
    return sample_from_zipf_distribution(1.059, max_workplace_size) + min_workplace_size
end

function add_agent_to_group(
    agent::Agent,
    collective::Collective,
    group_num::Int,
    group_sizes::Vector{Int},
    get_group_size
)
    if size(collective.groups[group_num], 1) == 0
        group = Group()
        push!(collective.groups[group_num], group)
    end
    length = size(collective.groups[group_num], 1)
    last_group = collective.groups[group_num][length]
    if size(last_group.agent_ids, 1) == group_sizes[group_num]
        last_group = Group()
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
        for _ = 1:m
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
        group = Group()
        push!(workplace.groups[1], group)
    end
    length = size(workplace.groups[1], 1)
    last_group = workplace.groups[1][length]
    if size(last_group.agent_ids, 1) == group_size
        generate_barabasi_albert_network(all_agents, last_group, min_workplace_size)
        last_group = Group()
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
    collectives::Vector{Collective},
    district_households::Matrix{Int},
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_nums::Vector{Int}
)
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
    for index in district_nums[(comm_rank + 1):comm_size:size(district_nums, 1)]
    # for index in district_nums[(comm_rank + 1):comm_size:80]
    # for index in district_nums[(comm_rank + 1):comm_size:56]
    # for index in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
    # for index in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
    # for index in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        index_for_1_people::Int = (index - 1) * 5 + 1
        index_for_2_people::Int = index_for_1_people + 1
        index_for_3_people::Int = index_for_2_people + 1
        index_for_4_people::Int = index_for_3_people + 1
        index_for_5_people::Int = index_for_4_people + 1
        for _ in 1:district_households[index, 1]
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
        for _ in 1:district_households[index, 2]
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
        for _ in 1:district_households[index, 3]
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
        for _ in 1:district_households[index, 4]
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
        for _ in 1:district_households[index, 5]
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
        for _ in 1:district_households[index, 6]
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
        for _ in 1:district_households[index, 7]
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
        for _ in 1:district_households[index, 8]
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
        for _ in 1:district_households[index, 9]
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
        for _ in 1:district_households[index, 10]
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
        for _ in 1:district_households[index, 11]
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
        for _ in 1:district_households[index, 12]
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
        for _ in 1:district_households[index, 13]
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
        for _ in 1:district_households[index, 14]
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
        for _ in 1:district_households[index, 15]
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
        for _ in 1:district_households[index, 16]
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
        for _ in 1:district_households[index, 17]
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
        for _ in 1:district_households[index, 18]
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
        for _ in 1:district_households[index, 19]
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
        for _ in 1:district_households[index, 20]
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
        for _ in 1:district_households[index, 21]
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
        for _ in 1:district_households[index, 22]
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
        for _ in 1:district_households[index, 23]
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
        for _ in 1:district_households[index, 24]
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
        for _ in 1:district_households[index, 25]
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
        for _ in 1:district_households[index, 26]
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
        for _ in 1:district_households[index, 27]
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
        for _ in 1:district_households[index, 28]
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
        for _ in 1:district_households[index, 29]
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
        for _ in 1:district_households[index, 30]
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
        for _ in 1:district_households[index, 31]
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
        for _ in 1:district_households[index, 32]
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
        for _ in 1:district_households[index, 33]
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
        for _ in 1:district_households[index, 34]
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
        for _ in 1:district_households[index, 35]
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
        for _ in 1:district_households[index, 36]
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
        for _ in 1:district_households[index, 37]
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
        for _ in 1:district_households[index, 38]
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
        for _ in 1:district_households[index, 39]
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
        for _ in 1:district_households[index, 40]
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

        for _ in 1:district_households[index, 41]
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
        for _ in 1:district_households[index, 42]
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
        for _ in 1:district_households[index, 43]
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
        for _ in 1:district_households[index, 44]
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
        for _ in 1:district_households[index, 45]
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
        for _ in 1:district_households[index, 46]
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
        for _ in 1:district_households[index, 47]
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
        for _ in 1:district_households[index, 48]
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

        for _ in 1:district_households[index, 49]
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
        for _ in 1:district_households[index, 50]
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
        for _ in 1:district_households[index, 51]
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
        for _ in 1:district_households[index, 52]
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
        for _ in 1:district_households[index, 53]
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
        for _ in 1:district_households[index, 54]
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
        for _ in 1:district_households[index, 55]
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
        for _ in 1:district_households[index, 56]
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
        for _ in 1:district_households[index, 57]
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
        for _ in 1:district_households[index, 58]
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
        for _ in 1:district_households[index, 59]
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
