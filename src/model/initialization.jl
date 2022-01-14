function get_agent_sex_and_age(
    index::Int,
    district_people::Matrix{Float64},
    district_people_households::Matrix{Float64},
    district_household_index::Int,
    thread_id::Int,
    thread_rng::Vector{MersenneTwister},
    is_male::Union{Bool, Nothing} = nothing,
    is_child::Bool = false,
)::Tuple{Bool, Int}
    age_rand_num = rand(thread_rng[thread_id], Float64)
    sex_random_num = rand(thread_rng[thread_id], Float64)
    if is_child
        age_group_rand_num = rand(thread_rng[thread_id], Float64)
        if age_group_rand_num < district_people_households[1, district_household_index]
            # T0-4_0–14
            if (age_rand_num < district_people[index, 20])
                # M0–4
                sub_age_group_rand_num = rand(thread_rng[thread_id], Float64)
                if sub_age_group_rand_num < 0.22
                    return sex_random_num < district_people[index, 1], 0
                elseif sub_age_group_rand_num < 0.43
                    return sex_random_num < district_people[index, 1], 1
                elseif sub_age_group_rand_num < 0.63
                    return sex_random_num < district_people[index, 1], 2
                elseif sub_age_group_rand_num < 0.82
                    return sex_random_num < district_people[index, 1], 3
                else
                    return sex_random_num < district_people[index, 1], 4
                end
            # T0-9_0–14
            elseif (age_rand_num < district_people[index, 21])
                # M5–9
                return sex_random_num < district_people[index, 2], rand(thread_rng[thread_id], 5:9)
            else
                # M10–14
                return sex_random_num < district_people[index, 3], rand(thread_rng[thread_id], 10:14)
            end
        else
            # M15–19
            sub_age_group_rand_num = rand(thread_rng[thread_id], Float64)
            if sub_age_group_rand_num < 0.36
                return sex_random_num < district_people[index, 4], 17
            elseif sub_age_group_rand_num < 0.69
                return sex_random_num < district_people[index, 4], 16
            else
                return sex_random_num < district_people[index, 4], 15
            end
        end
    else
        age_group_rand_num = rand(thread_rng[thread_id], Float64)
        if age_group_rand_num < district_people_households[2, district_household_index]
            if rand(thread_rng[thread_id], Float64) < 0.2
                # T18–19
                if is_male !== nothing
                    if rand(thread_rng[thread_id], Float64) < 0.66
                        return is_male, 19
                    else
                        return is_male, 18
                    end
                else
                    # M18–19
                    if rand(thread_rng[thread_id], Float64) < 0.66
                        return sex_random_num < district_people[index, 5], 19
                    else
                        return sex_random_num < district_people[index, 5], 18
                    end
                end
            else
                # T20–24
                if is_male !== nothing
                    return is_male, rand(thread_rng[thread_id], 20:24)
                else
                    # M20–24
                    return sex_random_num < district_people[index, 5], rand(thread_rng[thread_id], 20:24)
                end
            end
        elseif age_group_rand_num < district_people_households[3, district_household_index]
            # T25-29_25–34
            if age_rand_num < district_people[index, 22]
                if is_male !== nothing
                    return is_male, rand(thread_rng[thread_id], 25:29)
                else
                    # M25–29
                    return sex_random_num < district_people[index, 6], rand(thread_rng[thread_id], 25:29)
                end
            else
                if is_male !== nothing
                    return is_male, rand(thread_rng[thread_id], 30:34)
                else
                    # M30–34
                    return sex_random_num < district_people[index, 7], rand(thread_rng[thread_id], 30:34)
                end
            end
        elseif age_group_rand_num < district_people_households[4, district_household_index]
            # T35-39_35–44
            if age_rand_num < district_people[index, 23]
                if is_male !== nothing
                    return is_male, rand(thread_rng[thread_id], 35:39)
                else
                    # M35–39
                    return sex_random_num < district_people[index, 8], rand(thread_rng[thread_id], 35:39)
                end
            else
                if is_male !== nothing
                    return is_male, rand(thread_rng[thread_id], 40:44)
                else
                    # M40–44
                    return sex_random_num < district_people[index, 9], rand(thread_rng[thread_id], 40:44)
                end
            end
        elseif age_group_rand_num < district_people_households[5, district_household_index]
            # T45-49_45–54
            if age_rand_num < district_people[index, 24]
                if is_male !== nothing
                    return is_male, rand(thread_rng[thread_id], 45:49)
                else
                    # M45–49
                    return sex_random_num < district_people[index, 10], rand(thread_rng[thread_id], 45:49)
                end
            else
                if is_male !== nothing
                    return is_male, rand(thread_rng[thread_id], 50:54)
                else
                    # M50–54
                    return sex_random_num < district_people[index, 11], rand(thread_rng[thread_id], 50:54)
                end
            end
        elseif age_group_rand_num < district_people_households[6, district_household_index]
            # T55-59_55–64
            if age_rand_num < district_people[index, 25]
                if is_male !== nothing
                    return is_male, rand(thread_rng[thread_id], 55:59)
                else
                    # M55–59
                    return sex_random_num < district_people[index, 12], rand(thread_rng[thread_id], 55:59)
                end
            else
                if is_male !== nothing
                    return is_male, rand(thread_rng[thread_id], 60:64)
                else
                    # M60–64
                    return sex_random_num < district_people[index, 13], rand(thread_rng[thread_id], 60:64)
                end
            end
        else
            # T65-69_65–89
            if age_rand_num < district_people[index, 26]
                if is_male !== nothing
                    return is_male, rand(thread_rng[thread_id], 65:69)
                else
                    # M65–69
                    return sex_random_num < district_people[index, 14], rand(thread_rng[thread_id], 65:69)
                end
            # T65-74_65–89
            elseif age_rand_num < district_people[index, 27]
                if is_male !== nothing
                    return is_male, rand(thread_rng[thread_id], 70:74)
                else
                    # M70–74
                    return sex_random_num < district_people[index, 15], rand(thread_rng[thread_id], 70:74)
                end
            # T65-79_65–89
            elseif age_rand_num < district_people[index, 28]
                if is_male !== nothing
                    return is_male, rand(thread_rng[thread_id], 75:79)
                else
                    # M75–79
                    return sex_random_num < district_people[index, 16], rand(thread_rng[thread_id], 75:79)
                end
            # T65-84_65–89
            elseif age_rand_num < district_people[index, 29]
                if is_male !== nothing
                    return is_male, rand(thread_rng[thread_id], 80:84)
                else
                    # M80–84
                    return sex_random_num < district_people[index, 17], rand(thread_rng[thread_id], 80:84)
                end
            else
                if is_male !== nothing
                    return is_male, rand(thread_rng[thread_id], 85:89)
                else
                    # M85–89
                    return sex_random_num < district_people[index, 18], rand(thread_rng[thread_id], 85:89)
                end
            end
        end
    end
end

function check_parent_leave(no_one_at_home::Bool, adult::Agent, child::Agent)
    if child.age < 12
        child.supporter_id = adult.id
        push!(adult.dependant_ids, child.id)
        if no_one_at_home
            child.needs_supporter_care = true
            if child.age < 4 && child.activity_type == 0
                adult.activity_type = 0
            end
        end
    end
    # child.supporter_id = adult.id
    # push!(adult.dependant_ids, child.id)
    # if child.age < 12 && no_one_at_home
    #     child.needs_supporter_care = true
    #     if child.age < 4 && child.activity_type == 0
    #         adult.activity_type = 0
    #     end
    # end
end

function create_parents_with_children(
    agent_id::Int,
    household_id::Int,
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
    a1_symptomatic_parameters::Vector{Float64},
    a2_symptomatic_parameters::Vector{Float64},
    a3_symptomatic_parameters::Vector{Float64},
    household_conn_ids::Vector{Int},
    district_people::Matrix{Float64},
    district_people_households::Matrix{Float64},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int,
    thread_id::Int,
    thread_rng::Vector{MersenneTwister},
    with_others::Bool = false,
    with_grandparent::Bool = false,
)::Vector{Agent}
    agent_female_sex, agent_female_age = get_agent_sex_and_age(
        index, district_people,
        district_people_households, district_household_index,
        thread_id, thread_rng, false)

    if with_others
        while (agent_female_age > 52 && num_of_children > 0) || (num_of_children == 2 && (agent_female_age < 20 || (agent_female_age < 25 && rand(thread_rng[thread_id], Float64) > agent_female_age / 35))) || (num_of_children == 3 && (agent_female_age < 22 || (agent_female_age < 27 && rand(thread_rng[thread_id], Float64) > agent_female_age / 37)))
            agent_female_sex, agent_female_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, false)
        end
    elseif with_grandparent
        while agent_female_age > 60 || ((agent_female_age < 34 || (agent_female_age == 34 && rand(thread_rng[thread_id]) < 0.5) || (agent_female_age < 40 && rand(thread_rng[thread_id], Float64) > agent_female_age / 50)) && num_of_other_people > 1) || (num_of_children == 2 && (agent_female_age < 20 || (agent_female_age < 25 && rand(thread_rng[thread_id], Float64) > agent_female_age / 35))) || (num_of_children == 3 && (agent_female_age < 22 || (agent_female_age < 27 && rand(thread_rng[thread_id], Float64) > agent_female_age / 37)))
            agent_female_sex, agent_female_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, false)
        end
    else
        while (agent_female_age > 52 && num_of_children > 0) || ((agent_female_age < 34 || (agent_female_age == 34 && rand(thread_rng[thread_id]) < 0.5) || (agent_female_age < 40 && rand(thread_rng[thread_id], Float64) > agent_female_age / 50)) && num_of_other_people > 0) || (num_of_children == 2 && (agent_female_age < 20 || (agent_female_age < 25 && rand(thread_rng[thread_id], Float64) > agent_female_age / 35))) || (num_of_children == 3 && (agent_female_age < 22 || (agent_female_age < 27 && rand(thread_rng[thread_id], Float64) > agent_female_age / 37)))
            agent_female_sex, agent_female_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, false)
        end
    end

    agent_female = Agent(agent_id, household_id, viruses, infectivities,
        a1_symptomatic_parameters, a2_symptomatic_parameters,
        a3_symptomatic_parameters, household_conn_ids, agent_female_sex, agent_female_age,
        thread_id, thread_rng)
    agent_id += 1

    agent_male_sex, agent_male_age = get_agent_sex_and_age(
        index, district_people,
        district_people_households, district_household_index,
        thread_id, thread_rng, true)
    age_diff_rand_num = rand(thread_rng[thread_id], Float64)
    age_diff = abs(agent_male_age - agent_female_age)
    while age_diff > 15 || (age_diff > 10 && age_diff_rand_num > 0.06) || (age_diff > 5 && age_diff_rand_num > 0.14) || (age_diff > 3 && age_diff_rand_num > 0.162) || (age_diff > 1 && age_diff_rand_num > 0.265)
        agent_male_sex, agent_male_age = get_agent_sex_and_age(
            index, district_people,
            district_people_households, district_household_index,
            thread_id, thread_rng, true)
        age_diff_rand_num = rand(thread_rng[thread_id], Float64)
        age_diff = abs(agent_male_age - agent_female_age)
    end
    agent_male = Agent(agent_id, household_id, viruses, infectivities,
        a1_symptomatic_parameters, a2_symptomatic_parameters,
        a3_symptomatic_parameters, household_conn_ids, agent_male_sex, agent_male_age,
        thread_id, thread_rng)
    agent_id += 1
    if num_of_other_people == 0
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child_age > 45) || (agent_female_age - child_age < 16)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child2_age > 45) || (agent_female_age - child2_age < 16)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child3_age > 45) || (agent_female_age - child3_age < 16)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, child, child2, child3]
        end
        return Agent[agent_male, agent_female]
    elseif num_of_other_people == 1
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        if with_others
            # Do nothing
        elseif with_grandparent
            while (agent_other_age - agent_female_age > 45) || (agent_other_age - agent_female_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        else
            while (agent_female_age - agent_other_age > 45) || (agent_female_age - agent_other_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child_age > 45) || (agent_female_age - child_age < 16)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child2_age > 45) || (agent_female_age - child2_age < 16)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child3_age > 45) || (agent_female_age - child3_age < 16)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index,
                    thread_id, thread_rng, nothing, true)
            end
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other]
    elseif num_of_other_people == 2
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        if with_others
            # Do nothing
        elseif with_grandparent
            while (agent_other_age - agent_female_age > 45) || (agent_other_age - agent_female_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        else
            while (agent_female_age - agent_other_age > 45) || (agent_female_age - agent_other_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        if with_others
            # Do nothing
        else
            while (agent_female_age - agent_other2_age > 45) || (agent_female_age - agent_other2_age < 16)
                agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index,
                    thread_id, thread_rng)
            end
        end
        agent_other2 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other2_sex, agent_other2_age,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child_age > 45) || (agent_female_age - child_age < 16)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, agent_other2, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child2_age > 45) || (agent_female_age - child2_age < 16)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child3_age > 45) || (agent_female_age - child3_age < 16)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        if with_others
            # Do nothing
        elseif with_grandparent
            while (agent_other_age - agent_female_age > 45) || (agent_other_age - agent_female_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        else
            while (agent_female_age - agent_other_age > 45) || (agent_female_age - agent_other_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        if with_others
            # Do nothing
        else
            while (agent_female_age - agent_other2_age > 45) || (agent_female_age - agent_other2_age < 16)
                agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index,
                    thread_id, thread_rng)
            end
        end
        agent_other2 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other2_sex, agent_other2_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        if with_others
            # Do nothing
        else
            while (agent_female_age - agent_other3_age > 45) || (agent_female_age - agent_other3_age < 16)
                agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index,
                    thread_id, thread_rng)
            end
        end
        agent_other3 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other3_sex, agent_other3_age,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child_age > 45) || (agent_female_age - child_age < 16)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0 || agent_other3.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child2_age > 45) || (agent_female_age - child2_age < 16)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child3_age > 45) || (agent_female_age - child3_age < 16)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3]
    else
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        if with_others
            # Do nothing
        elseif with_grandparent
            while (agent_other_age - agent_female_age > 45) || (agent_other_age - agent_female_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        else
            while (agent_female_age - agent_other_age > 45) || (agent_female_age - agent_other_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        if with_others
            # Do nothing
        else
            while (agent_female_age - agent_other2_age > 45) || (agent_female_age - agent_other2_age < 16)
                agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other2 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other2_sex, agent_other2_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        if with_others
            # Do nothing
        else
            while (agent_female_age - agent_other3_age > 45) || (agent_female_age - agent_other3_age < 16)
                agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other3 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other3_sex, agent_other3_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other4_sex, agent_other4_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        if with_others
            # Do nothing
        else
            while (agent_female_age - agent_other4_age > 45) || (agent_female_age - agent_other4_age < 16)
                agent_other4_sex, agent_other4_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other4 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other4_sex, agent_other4_age,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child_age > 45) || (agent_female_age - child_age < 16)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0 ||
                agent_other3.activity_type == 0 || agent_other4.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child2_age > 45) || (agent_female_age - child2_age < 16)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child3_age > 45) || (agent_female_age - child3_age < 16)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4]
    end
end

function create_two_pairs_with_children_with_others(
    agent_id::Int,
    household_id::Int,
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
    a1_symptomatic_parameters::Vector{Float64},
    a2_symptomatic_parameters::Vector{Float64},
    a3_symptomatic_parameters::Vector{Float64},
    household_conn_ids::Vector{Int},
    district_people::Matrix{Float64},
    district_people_households::Matrix{Float64},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int,
    thread_id::Int,
    thread_rng::Vector{MersenneTwister},
)::Vector{Agent}
    agent_female_sex, agent_female_age = get_agent_sex_and_age(
        index, district_people,
        district_people_households, district_household_index,
        thread_id, thread_rng, false)
    while agent_female_age > 60 || (num_of_children == 2 && agent_female_age < 20) || (num_of_children == 3 && agent_female_age < 22)
        agent_female_sex, agent_female_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, thread_id, thread_rng, false)
    end
    agent_female = Agent(agent_id, household_id, viruses, infectivities,
        a1_symptomatic_parameters, a2_symptomatic_parameters,
        a3_symptomatic_parameters, household_conn_ids, agent_female_sex, agent_female_age,
        thread_id, thread_rng)

    agent_id += 1
    agent_male_sex, agent_male_age = get_agent_sex_and_age(
        index, district_people,
        district_people_households, district_household_index,
        thread_id, thread_rng, true)
    age_diff_rand_num = rand(thread_rng[thread_id], Float64)
    age_diff = abs(agent_male_age - agent_female_age)
    while age_diff > 15 || (age_diff > 10 && age_diff_rand_num > 0.06) || (age_diff > 5 && age_diff_rand_num > 0.14) || (age_diff > 3 && age_diff_rand_num > 0.162) || (age_diff > 1 && age_diff_rand_num > 0.265)
        agent_male_sex, agent_male_age = get_agent_sex_and_age(
            index, district_people,
            district_people_households, district_household_index,
            thread_id, thread_rng, true)
        age_diff_rand_num = rand(thread_rng[thread_id], Float64)
        age_diff = abs(agent_male_age - agent_female_age)
    end
    agent_male = Agent(agent_id, household_id, viruses, infectivities,
        a1_symptomatic_parameters, a2_symptomatic_parameters,
        a3_symptomatic_parameters, household_conn_ids, agent_male_sex, agent_male_age,
        thread_id, thread_rng)
    agent_id += 1

    agent_female_old_sex, agent_female_old_age = get_agent_sex_and_age(
        index, district_people,
        district_people_households, district_household_index,
        thread_id, thread_rng, false)
    while (agent_female_old_age - agent_female_age > 45) || (agent_female_old_age - agent_female_age < 16)
        agent_female_old_sex, agent_female_old_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, thread_id, thread_rng, false)
    end
    agent_female_old = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_female_old_sex, agent_female_old_age,
            thread_id, thread_rng)

    agent_id += 1
    agent_male_old_sex, agent_male_old_age = get_agent_sex_and_age(
        index, district_people,
        district_people_households, district_household_index,
        thread_id, thread_rng, true)
    age_diff_rand_num = rand(thread_rng[thread_id], Float64)
    age_diff = abs(agent_male_old_age - agent_female_old_age)
    while age_diff > 15 || (age_diff > 10 && age_diff_rand_num > 0.06) || (age_diff > 5 && age_diff_rand_num > 0.14) || (age_diff > 3 && age_diff_rand_num > 0.162) || (age_diff > 1 && age_diff_rand_num > 0.265)
        agent_male_old_sex, agent_male_old_age = get_agent_sex_and_age(
            index, district_people,
            district_people_households, district_household_index,
            thread_id, thread_rng, true)
        age_diff_rand_num = rand(thread_rng[thread_id], Float64)
        age_diff = abs(agent_male_old_age - agent_female_old_age)
    end
    agent_male_old = Agent(agent_id, household_id, viruses, infectivities,
        a1_symptomatic_parameters, a2_symptomatic_parameters,
        a3_symptomatic_parameters, household_conn_ids, agent_male_old_sex, agent_male_old_age,
        thread_id, thread_rng)
    agent_id += 1

    if num_of_other_people == 0
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child_age > 45) || (agent_female_age - child_age < 16)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_male_old, agent_female_old, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child2_age > 45) || (agent_female_age - child2_age < 16)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_male_old, agent_female_old, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child3_age > 45) || (agent_female_age - child3_age < 16)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_male_old, agent_female_old, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_male_old, agent_female_old]
    elseif num_of_other_people == 1
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child_age > 45) || (agent_female_age - child_age < 16)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child2_age > 45) || (agent_female_age - child2_age < 16)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child3_age > 45) || (agent_female_age - child3_age < 16)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other]
    else
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other2 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other2_sex, agent_other2_age,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child_age > 45) || (agent_female_age - child_age < 16)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other, agent_other2, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child2_age > 45) || (agent_female_age - child2_age < 16)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other, agent_other2, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (agent_female_age - child3_age > 45) || (agent_female_age - child3_age < 16)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other, agent_other2]
    end
end

function create_parent_with_children(
    agent_id::Int,
    household_id::Int,
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
    a1_symptomatic_parameters::Vector{Float64},
    a2_symptomatic_parameters::Vector{Float64},
    a3_symptomatic_parameters::Vector{Float64},
    household_conn_ids::Vector{Int},
    district_people::Matrix{Float64},
    district_people_households::Matrix{Float64},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int,
    thread_id::Int,
    thread_rng::Vector{MersenneTwister},
    is_male_parent::Union{Bool, Nothing} = nothing,
    with_others::Bool = false,
    with_grandparent::Bool = false,
)::Vector{Agent}
    parent_sex, parent_age = get_agent_sex_and_age(
        index, district_people, district_people_households,
        district_household_index, thread_id, thread_rng, is_male_parent)
    if with_others
        while parent_age > 60 || (num_of_children == 2 && parent_age < 20) || (num_of_children == 3 && parent_age < 22)
            parent_sex, parent_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, is_male_parent)
        end
    elseif with_grandparent
        while parent_age > 60 || ((parent_age < 34 || (parent_age == 34 && rand(thread_rng[thread_id]) < 0.5) || (parent_age < 40 && rand(thread_rng[thread_id], Float64) > parent_age / 50)) && num_of_other_people > 1) || (num_of_children == 2 && (parent_age < 20 || (parent_age < 25 && rand(thread_rng[thread_id], Float64) > parent_age / 35))) || (num_of_children == 3 && (parent_age < 22 || (parent_age < 27 && rand(thread_rng[thread_id], Float64) > parent_age / 37)))
            parent_sex, parent_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, is_male_parent)
        end
    else
        while (parent_age > 52 && num_of_children > 0) || ((parent_age < 34 || (parent_age == 34 && rand(thread_rng[thread_id]) < 0.5) || (parent_age < 40 && rand(thread_rng[thread_id], Float64) > parent_age / 50)) && num_of_other_people > 0) || (num_of_children == 2 && (parent_age < 20 || (parent_age < 25 && rand(thread_rng[thread_id], Float64) > parent_age / 35))) || (num_of_children == 3 && (parent_age < 22 || (parent_age < 27 && rand(thread_rng[thread_id], Float64) > parent_age / 37)))
            parent_sex, parent_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, is_male_parent)
        end
    end
    parent = Agent(agent_id, household_id, viruses, infectivities,
        a1_symptomatic_parameters, a2_symptomatic_parameters,
        a3_symptomatic_parameters, household_conn_ids, parent_sex, parent_age,
        thread_id, thread_rng)

    agent_id += 1
    if num_of_other_people == 0
        child_sex, child_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, thread_id, thread_rng, nothing, true)
        while (parent_age - child_age > 45) || (parent_age - child_age < 16)
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
        end
        child = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
            thread_id, thread_rng)
        agent_id += 1
        no_one_at_home = parent.activity_type != 0
        check_parent_leave(no_one_at_home, parent, child)
        if num_of_children == 1
            return Agent[parent, child]
        end
        child2_sex, child2_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing, true)
        while (parent_age - child2_age > 45) || (parent_age - child2_age < 16)
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
        end
        child2 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
            thread_id, thread_rng)
        agent_id += 1
        check_parent_leave(no_one_at_home, parent, child2)
        if num_of_children == 2
            return Agent[parent, child, child2]
        end
        child3_sex, child3_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing, true)
        while (parent_age - child3_age > 45) || (parent_age - child3_age < 16)
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
        end
        child3 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
            thread_id, thread_rng)
        check_parent_leave(no_one_at_home, parent, child3)
        return Agent[parent, child, child2, child3]
    elseif num_of_other_people == 1
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng)
        if with_others || with_grandparent
            while (agent_other_age - parent_age > 45) || (agent_other_age - parent_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        else
            while (parent_age - agent_other_age > 45) || (parent_age - agent_other_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (parent_age - child_age > 45) || (parent_age - child_age < 16)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = parent.activity_type != 0
            if agent_other.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (parent_age - child2_age > 45) || (parent_age - child2_age < 16)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (parent_age - child3_age > 45) || (parent_age - child3_age < 16)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, child, child2, child3]
        end
        return Agent[parent, agent_other]
    elseif num_of_other_people == 2
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng)
        if with_others || with_grandparent
            while (agent_other_age - parent_age > 45) || (agent_other_age - parent_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        else
            while (parent_age - agent_other_age > 45) || (parent_age - agent_other_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, thread_id, thread_rng)
        if with_others
            # Do nothing
        else
            while (parent_age - agent_other2_age > 45) || (parent_age - agent_other2_age < 16)
                agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other2 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other2_sex, agent_other2_age,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (parent_age - child_age > 45) || (parent_age - child_age < 16)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = parent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, agent_other2, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (parent_age - child2_age > 45) || (parent_age - child2_age < 16)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (parent_age - child3_age > 45) || (parent_age - child3_age < 16)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng)
        if with_others || with_grandparent
            while (agent_other_age - parent_age > 45) || (agent_other_age - parent_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        else
            while (parent_age - agent_other_age > 45) || (parent_age - agent_other_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, thread_id, thread_rng)
        if with_others
            # Do nothing
        else
            while (parent_age - agent_other2_age > 45) || (parent_age - agent_other2_age < 16)
                agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other2 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other2_sex, agent_other2_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, thread_id, thread_rng)
        if with_others
            # Do nothing
        else
            while (parent_age - agent_other3_age > 45) || (parent_age - agent_other3_age < 16)
                agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other3 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other3_sex, agent_other3_age,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (parent_age - child_age > 45) || (parent_age - child_age < 16)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = parent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0 || agent_other3.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, agent_other2, agent_other3, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (parent_age - child2_age > 45) || (parent_age - child2_age < 16)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (parent_age - child3_age > 45) || (parent_age - child3_age < 16)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2, agent_other3]
    else
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng)
        if with_others || with_grandparent
            while (agent_other_age - parent_age > 45) || (agent_other_age - parent_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        else
            while (parent_age - agent_other_age > 45) || (parent_age - agent_other_age < 16)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, thread_id, thread_rng)
        if with_others
            # Do nothing
        else
            while (parent_age - agent_other2_age > 45) || (parent_age - agent_other2_age < 16)
                agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other2 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other2_sex, agent_other2_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, thread_id, thread_rng)
        if with_others
            # Do nothing
        else
            while (parent_age - agent_other3_age > 45) || (parent_age - agent_other3_age < 16)
                agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other3 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other3_sex, agent_other3_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other4_sex, agent_other4_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, thread_id, thread_rng)
        if with_others
            # Do nothing
        else
            while (parent_age - agent_other4_age > 45) || (parent_age - agent_other4_age < 16)
                agent_other4_sex, agent_other4_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng)
            end
        end
        agent_other4 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other4_sex, agent_other4_age,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (parent_age - child_age > 45) || (parent_age - child_age < 16)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = parent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0 ||
                agent_other3.activity_type == 0 || agent_other4.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (parent_age - child2_age > 45) || (parent_age - child2_age < 16)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            while (parent_age - child3_age > 45) || (parent_age - child3_age < 16)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, thread_id, thread_rng, nothing, true)
            end
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4]
    end
end

function create_others(
    agent_id::Int,
    household_id::Int,
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
    a1_symptomatic_parameters::Vector{Float64},
    a2_symptomatic_parameters::Vector{Float64},
    a3_symptomatic_parameters::Vector{Float64},
    household_conn_ids::Vector{Int},
    district_people::Matrix{Float64},
    district_people_households::Matrix{Float64},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int,
    thread_id::Int,
    thread_rng::Vector{MersenneTwister},
)::Vector{Agent}
    agent_sex, agent_age = get_agent_sex_and_age(
        index, district_people, district_people_households, district_household_index,
        thread_id, thread_rng)
    agent = Agent(agent_id, household_id, viruses, infectivities,
        a1_symptomatic_parameters, a2_symptomatic_parameters,
        a3_symptomatic_parameters, household_conn_ids, agent_sex, agent_age,
        thread_id, thread_rng)
    agent_id += 1
    if num_of_other_people == 0
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = agent.activity_type != 0
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, child, child2, child3]
        end
        return Agent[agent]
    elseif num_of_other_people == 1
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = agent.activity_type != 0
            if agent_other.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, agent_other, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, child, child2, child3]
        end
        return Agent[agent, agent_other]
    elseif num_of_other_people == 2
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other2 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other2_sex, agent_other2_age,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = agent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, agent_other, agent_other2, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other2 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other2_sex, agent_other2_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other3 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other3_sex, agent_other3_age,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = agent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0 ||
                agent_other3.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, agent_other, agent_other2, agent_other3, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2, agent_other3]
    elseif num_of_other_people == 4
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other2 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other2_sex, agent_other2_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other3 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other3_sex, agent_other3_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other4_sex, agent_other4_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other4 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other4_sex, agent_other4_age,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child_sex, child_age,
                thread_id, thread_rng)
            agent_id += 1
            no_one_at_home = agent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0 ||
                agent_other3.activity_type == 0 || agent_other4.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child2 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child2_sex, child2_age,
                thread_id, thread_rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, thread_id, thread_rng, nothing, true)
            child3 = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household_conn_ids, child3_sex, child3_age,
                thread_id, thread_rng)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4]
    else
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other_sex, agent_other_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other2 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other2_sex, agent_other2_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other3 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other3_sex, agent_other3_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other4_sex, agent_other4_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other4 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other4_sex, agent_other4_age,
            thread_id, thread_rng)
        agent_id += 1
        agent_other5_sex, agent_other5_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_other5 = Agent(agent_id, household_id, viruses, infectivities,
            a1_symptomatic_parameters, a2_symptomatic_parameters,
            a3_symptomatic_parameters, household_conn_ids, agent_other5_sex, agent_other5_age,
            thread_id, thread_rng)
        agent_id += 1
        return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, agent_other5]
    end
end

function create_population(
    thread_id::Int,
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    start_agent_id::Int,
    end_agent_id::Int,
    all_agents::Vector{Agent},
    households::Vector{Household},
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
    a1_symptomatic_parameters::Vector{Float64},
    a2_symptomatic_parameters::Vector{Float64},
    a3_symptomatic_parameters::Vector{Float64},
    start_household_id::Int,
    homes_coords_df::DataFrame,
    district_households::Matrix{Int},
    district_people::Matrix{Float64},
    district_people_households::Matrix{Float64},
    district_nums::Vector{Int}
)
    agent_id = start_agent_id
    household_id = start_household_id
    for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
        index_for_1_people::Int = (index - 1) * 5 + 1
        index_for_2_people::Int = index_for_1_people + 1
        index_for_3_people::Int = index_for_2_people + 1
        index_for_4_people::Int = index_for_3_people + 1
        index_for_5_people::Int = index_for_4_people + 1

        homes_coords_district_df = homes_coords_df[homes_coords_df.dist .== index, :]

        for _ in 1:district_households[index, 1]
            # 1P
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                Int[agent_id], index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agent_sex, agent_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                index_for_1_people, thread_id, thread_rng)
            all_agents[agent_id] = Agent(agent_id, household_id, viruses, infectivities,
                a1_symptomatic_parameters, a2_symptomatic_parameters,
                a3_symptomatic_parameters, household.agent_ids, agent_sex, agent_age,
                thread_id, thread_rng)
            agent_id += 1
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 2]
            # PWOP2P0C
            new_agent_id = agent_id + 1
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 0, index,
                    thread_id, thread_rng)
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 0, index,
                    thread_id, thread_rng, false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 0, index,
                    thread_id, thread_rng, true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 3]
            # PWOP3P0C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 1, index,
                    thread_id, thread_rng)
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 1, index,
                    thread_id, thread_rng, false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 1, index,
                    thread_id, thread_rng, true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 4]
            # PWOP3P1C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 1, 0, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 5]
            # PWOP4P0C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 2, index,
                    thread_id, thread_rng)
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 2, index,
                    thread_id, thread_rng, false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 2, index,
                    thread_id, thread_rng, true)
            end 
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 6]
            # PWOP4P1C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 1, index,
                    thread_id, thread_rng)
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 1, index,
                    thread_id, thread_rng, false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 1, index,
                    thread_id, thread_rng, true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 7]
            # PWOP4P2C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 2, 0, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 8]
            # PWOP5P0C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 3, index,
                    thread_id, thread_rng)
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 3, index,
                    thread_id, thread_rng, false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 3, index,
                    thread_id, thread_rng, true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 9]
            # PWOP5P1C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 2, index,
                    thread_id, thread_rng)
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 2, index,
                    thread_id, thread_rng, false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 2, index,
                    thread_id, thread_rng, true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 10]
            # PWOP5P2C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 2, 1, index,
                    thread_id, thread_rng)
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 2, 1, index,
                    thread_id, thread_rng, false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 2, 1, index,
                    thread_id, thread_rng, true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 11]
            # PWOP5P3C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 3, 0, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 12]
            # PWOP6P0C
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 4, index,
                    thread_id, thread_rng)
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 4, index,
                    thread_id, thread_rng, false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 4, index,
                    thread_id, thread_rng, true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 13]
            # PWOP6P1C
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 3, index,
                    thread_id, thread_rng)
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 3, index,
                    thread_id, thread_rng, false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 3, index,
                    thread_id, thread_rng, true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 14]
            # PWOP6P2C
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 2, 2, index,
                    thread_id, thread_rng)
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 2, 2, index,
                    thread_id, thread_rng, false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 2, 2, index,
                    thread_id, thread_rng, true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 15]
            # PWOP6P3C
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 3, 1, index,
                    thread_id, thread_rng)
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 3, 1, index,
                    thread_id, thread_rng, false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                    a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 3, 1, index,
                    thread_id, thread_rng, true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end

        for _ in 1:district_households[index, 16]
            # 2PWOP4P0C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_two_pairs_with_children_with_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 0, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 17]
            # 2PWOP5P0C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_two_pairs_with_children_with_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 1, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 18]
            # 2PWOP5P1C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_two_pairs_with_children_with_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 0, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 19]
            # 2PWOP6P0C
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_two_pairs_with_children_with_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 2, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 20]
            # 2PWOP6P1C
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_two_pairs_with_children_with_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 1, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 21]
            # 2PWOP6P2C
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_two_pairs_with_children_with_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 2, 0, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end

        for _ in 1:district_households[index, 22]
            # SMWC2P0C
            new_agent_id = agent_id + 1
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 0, 1, index,
                thread_id, thread_rng, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 23]
            # SMWC2P1C
            new_agent_id = agent_id + 1
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 1, 0, index,
                thread_id, thread_rng, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 24]
            # SMWC3P0C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, thread_rng, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 25]
            # SMWC3P1C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, thread_rng, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 26]
            # SMWC3P2C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 2, 0, index,
                thread_id, thread_rng, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 27]
            # SMWC4P0C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index,
                thread_id, thread_rng, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 28]
            # SMWC4P1C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index,
                thread_id, thread_rng, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 29]
            # SMWC4P2C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index,
                thread_id, thread_rng, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 30]
            # SMWC4P3C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 3, 0, index,
                thread_id, thread_rng, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 31]
            # SFWC2P0C
            new_agent_id = agent_id + 1
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 0, 1, index,
                thread_id, thread_rng, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 32]
            # SFWC2P1C
            new_agent_id = agent_id + 1
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 1, 0, index,
                thread_id, thread_rng, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 33]
            # SFWC3P0C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, thread_rng, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 34]
            # SFWC3P1C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, thread_rng, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 35]
            # SFWC3P2C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 2, 0, index,
                thread_id, thread_rng, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 36]
            # SPWCWP3P0C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, thread_rng, false, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 37]
            # SPWCWP3P1C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, thread_rng, false, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 38]
            # SPWCWP4P0C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index,
                thread_id, thread_rng, false, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 39]
            # SPWCWP4P1C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index,
                thread_id, thread_rng, false, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 40]
            # SPWCWP4P2C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index,
                thread_id, thread_rng, false, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end

        for _ in 1:district_households[index, 41]
            # SPWCWPWOP3P0C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, thread_rng, true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 42]
            # SPWCWPWOP3P1C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, thread_rng, true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 43]
            # SPWCWPWOP4P0C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index,
                thread_id, thread_rng, true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 44]
            # SPWCWPWOP4P1C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index,
                thread_id, thread_rng, true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 45]
            # SPWCWPWOP4P2C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index,
                thread_id, thread_rng, true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 46]
            # SPWCWPWOP5P0C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 4, index,
                thread_id, thread_rng, true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 47]
            # SPWCWPWOP5P1C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 1, 3, index,
                thread_id, thread_rng, true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 48]
            # SPWCWPWOP5P2C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 2, 2, index,
                thread_id, thread_rng, true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end

        for _ in 1:district_households[index, 49]
            # O2P0C
            new_agent_id = agent_id + 1
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 0, 1, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 50]
            # O2P1C
            new_agent_id = agent_id + 1
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 1, 0, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 51]
            # O3P0C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 52]
            # O3P1C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 53]
            # O3P2C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 2, 0, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 54]
            # O4P0C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 55]
            # O4P1C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 56]
            # O4P2C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 57]
            # O4P3C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 3, 1, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 58]
            # O5P0C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 4, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 59]
            # O5P1C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 1, 3, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 60]
            # O5P2C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 2, 2, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 61]
            # O5P3C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 3, 2, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 62]
            # O6P0C
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 5, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 63]
            # O6P1C
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 1, 4, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 64]
            # O6P2C
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 2, 3, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 65]
            # O6P3C
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, infectivities, a1_symptomatic_parameters,
                a2_symptomatic_parameters, a3_symptomatic_parameters, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 3, 2, index,
                thread_id, thread_rng)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
    end
end
