function create_agent(
    agent_id::Int,
    viruses::Vector{Virus},
    viral_loads::Array{Float64, 4},
    household_conn_ids::Vector{Int},
    index::Int,
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_household_index::Int,
    thread_id::Int,
    num_of_people_in_kindergarten::Vector{Int},
    num_of_people_in_school_threads::Matrix{Int},
    num_of_people_in_university_threads::Matrix{Int},
    num_of_people_in_workplace_threads::Vector{Int},
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
            return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                sex_random_num <= district_people[index, 1], rand(0:(parent_age - 18)),
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        elseif parent_age < 28
            # T0-4_0–9
            if (age_rand_num <= district_people[index, 19])
                # M0–4
                Agent(agent_id, viruses, viral_loads, household_conn_ids,
                    sex_random_num <= district_people[index, 1], rand(0:4),
                    thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                    num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            else
                # M5–9
                Agent(agent_id, viruses, viral_loads, household_conn_ids,
                    sex_random_num <= district_people[index, 2], rand(5:(parent_age - 18)),
                    thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                    num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            end
        elseif parent_age < 33
            # T0-4_0–14
            if (age_rand_num <= district_people[index, 20])
                # M0–4
                Agent(agent_id, viruses, viral_loads, household_conn_ids,
                    sex_random_num <= district_people[index, 1], rand(0:4),
                    thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                    num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            # T0-9_0–14
            elseif (age_rand_num <= district_people[index, 21])
                # M5–9
                Agent(agent_id, viruses, viral_loads, household_conn_ids,
                    sex_random_num <= district_people[index, 2], rand(5:9),
                    thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                    num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            else
                # M10–14
                Agent(agent_id, viruses, viral_loads, household_conn_ids,
                    sex_random_num <= district_people[index, 3], rand(10:(parent_age - 18)),
                    thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                    num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            end
        elseif parent_age < 35
            age_group_rand_num = rand(1:100)
            if age_group_rand_num <= district_people_households[1, district_household_index]
                # T0-4_0–14
                if (age_rand_num <= district_people[index, 20])
                    # M0–4
                    Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 1], rand(0:4),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                # T0-9_0–14
                elseif (age_rand_num <= district_people[index, 21])
                    # M5–9
                    Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 2], rand(5:9),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M10–14
                    Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 3], rand(10:14),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            else
                # M15–19
                return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                    sex_random_num <= district_people[index, 4], rand(15:(parent_age - 18)),
                    thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                    num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            end
        else
            age_group_rand_num = rand(1:100)
            if age_group_rand_num <= district_people_households[1, district_household_index]
                # T0-4_0–14
                if (age_rand_num <= district_people[index, 20])
                    # M0–4
                    Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 1], rand(0:4),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                # T0-9_0–14
                elseif (age_rand_num <= district_people[index, 21])
                    # M5–9
                    Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 2], rand(5:9),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M10–14
                    Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 3], rand(10:14),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            else
                # M15–19
                return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                    sex_random_num <= district_people[index, 4], rand(15:17),
                    thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                    num_of_people_in_university_threads, num_of_people_in_workplace_threads)
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
                return Agent(agent_id, viruses, viral_loads, household_conn_ids, is_male, rand(18:24),
                    thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                    num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            else
                # M20–24
                return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                    sex_random_num <= district_people[index, 5], rand(18:24),
                    thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                    num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            end
        elseif age_group_rand_num <= district_people_households[3, district_household_index]
            # T25-29_25–34
            if age_rand_num <= district_people[index, 22]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids, is_male, rand(25:29),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M25–29
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 6], rand(25:29),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids, is_male, rand(30:34),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M30–34
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 7], rand(30:34),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            end
        elseif age_group_rand_num <= district_people_households[4, district_household_index]
            # T35-39_35–44
            if age_rand_num <= district_people[index, 23]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids, is_male, rand(35:39),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M35–39
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 8], rand(35:39),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids, is_male, rand(40:44),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M40–44
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 9], rand(40:44),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            end
        elseif age_group_rand_num <= district_people_households[5, district_household_index]
            # T45-49_45–54
            if age_rand_num <= district_people[index, 24]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids, is_male, rand(45:49),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M45–49
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 10], rand(45:49),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids, is_male, rand(50:54),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M50–54
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 11], rand(50:54),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            end
        elseif age_group_rand_num <= district_people_households[6, district_household_index]
            # T55-59_55–64
            if age_rand_num <= district_people[index, 25]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids, is_male, rand(55:59),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M55–59
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 12], rand(55:59),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids, is_male, rand(60:64),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M60–64
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 13], rand(60:64),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            end
        else
            # T65-69_65–89
            if age_rand_num <= district_people[index, 26]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids, is_male, rand(65:69),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M65–69
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 14], rand(65:69),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            # T65-74_65–89
            elseif age_rand_num <= district_people[index, 27]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids, is_male, rand(70:74),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M70–74
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 15], rand(70:74),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            # T65-79_65–89
            elseif age_rand_num <= district_people[index, 28]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids, is_male, rand(75:79),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M75–79
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 16], rand(75:79),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            # T65-84_65–89
            elseif age_rand_num <= district_people[index, 29]
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids, is_male, rand(80:84),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M80–84
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 17], rand(80:84),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids, is_male, rand(85:89),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                else
                    # M85–89
                    return Agent(agent_id, viruses, viral_loads, household_conn_ids,
                        sex_random_num <= district_people[index, 18], rand(85:89),
                        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
                end
            end
        end
    end
end

function create_spouse(
    agent_id::Int,
    viruses::Vector{Virus},
    viral_loads::Array{Float64, 4},
    household_conn_ids::Vector{Int},
    partner_age::Int,
    thread_id::Int,
    num_of_people_in_kindergarten::Vector{Int},
    num_of_people_in_school_threads::Matrix{Int},
    num_of_people_in_university_threads::Matrix{Int},
    num_of_people_in_workplace_threads::Vector{Int}
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
    return Agent(agent_id, viruses, viral_loads, household_conn_ids, false, spouse_age,
        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
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
    household_conn_ids::Vector{Int},
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int,
    thread_id::Int,
    num_of_people_in_kindergarten::Vector{Int},
    num_of_people_in_school_threads::Matrix{Int},
    num_of_people_in_university_threads::Matrix{Int},
    num_of_people_in_workplace_threads::Vector{Int}
)::Vector{Agent}
    agent_male = create_agent(agent_id,
        viruses, viral_loads, household_conn_ids, index,
        district_people, district_people_households,
        district_household_index,
        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
        num_of_people_in_university_threads, num_of_people_in_workplace_threads, true)
    agent_id += 1
    agent_female = create_spouse(
        agent_id, viruses, viral_loads, household_conn_ids, agent_male.age,
        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
    agent_id += 1
    if num_of_other_people == 0
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
            agent_id += 1
            no_one_at_home = agent_male.collective_id != 0 && agent_female.collective_id != 0
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, child, child2, child3]
        end
        return Agent[agent_male, agent_female]
    elseif num_of_other_people == 1
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
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
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other]
    elseif num_of_other_people == 2
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
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
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
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
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3]
    else
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        agent_other4 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
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
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, agent_female.age)
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
    household_conn_ids::Vector{Int},
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int,
    thread_id::Int,
    num_of_people_in_kindergarten::Vector{Int},
    num_of_people_in_school_threads::Matrix{Int},
    num_of_people_in_university_threads::Matrix{Int},
    num_of_people_in_workplace_threads::Vector{Int},
    is_male_parent::Union{Bool, Nothing},
    with_parent_of_parent::Bool = false,
)::Vector{Agent}
    parent = create_agent(agent_id,
        viruses, viral_loads, household_conn_ids, index,
        district_people, district_people_households,
        district_household_index,
        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
        num_of_people_in_university_threads, num_of_people_in_workplace_threads, is_male_parent,
        false, nothing, num_of_other_people > 0)
    agent_id += 1
    if num_of_other_people == 0
        child = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
        agent_id += 1
        no_one_at_home = parent.collective_id != 0
        check_parent_leave(no_one_at_home, parent, child)
        if num_of_children == 1
            return Agent[parent, child]
        end
        child2 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
        agent_id += 1
        check_parent_leave(no_one_at_home, parent, child2)
        if num_of_children == 2
            return Agent[parent, child, child2]
        end
        child3 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
        check_parent_leave(no_one_at_home, parent, child3)
        return Agent[parent, child, child2, child3]
    elseif num_of_other_people == 1
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
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
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, child, child2, child3]
        end
        return Agent[parent, agent_other]
    elseif num_of_other_people == 2
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing,
            false, parent.age)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
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
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing,
            false, parent.age)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing,
            false, parent.age)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
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
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2, agent_other3]
    else
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing,
            false, parent.age)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing,
            false, parent.age)
        agent_id += 1
        agent_other4 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing,
            false, parent.age)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
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
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, parent.age)
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
    household_conn_ids::Vector{Int},
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int,
    thread_id::Int,
    num_of_people_in_kindergarten::Vector{Int},
    num_of_people_in_school_threads::Matrix{Int},
    num_of_people_in_university_threads::Matrix{Int},
    num_of_people_in_workplace_threads::Vector{Int}
)::Vector{Agent}
    agent = create_agent(agent_id,
        viruses, viral_loads, household_conn_ids, index,
        district_people, district_people_households, district_household_index,
        thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
        num_of_people_in_university_threads, num_of_people_in_workplace_threads)
    agent_id += 1
    if num_of_other_people == 0
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
            agent_id += 1
            no_one_at_home = agent.collective_id != 0
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, child]
            end
            child2 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, child, child2, child3]
        end
        return Agent[agent]
    elseif num_of_other_people == 1
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
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
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, child, child2, child3]
        end
        return Agent[agent, agent_other]
    elseif num_of_other_people == 2
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
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
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
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
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2, agent_other3]
    else
        agent_other = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        agent_other4 = create_agent(agent_id,
            viruses, viral_loads, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
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
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, viral_loads, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4]
    end
end

function create_population(
    thread_id::Int,
    num_threads::Int,
    start_agent_id::Int,
    all_agents::Vector{Agent},
    viruses::Vector{Virus},
    viral_loads::Array{Float64, 4},
    district_households::Matrix{Int},
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_nums::Vector{Int},
    num_of_people_in_school_threads::Matrix{Int},
    num_of_people_in_university_threads::Matrix{Int},
    num_of_people_in_workplace_threads::Vector{Int}
)
    agent_id = start_agent_id
    for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
        # println("Index: $index, agent_id: $agent_id")
        index_for_1_people::Int = (index - 1) * 5 + 1
        index_for_2_people::Int = index_for_1_people + 1
        index_for_3_people::Int = index_for_2_people + 1
        index_for_4_people::Int = index_for_3_people + 1
        index_for_5_people::Int = index_for_4_people + 1

        district_start_agent_id = agent_id

        num_of_people_in_kindergarten = zeros(Int, 6)

        for _ in 1:district_households[index, 1]
            # 1P
            household_conn_ids = Int[agent_id]
            agent = create_agent(
                agent_id, viruses, viral_loads, household_conn_ids, index, district_people,
                    district_people_households, index_for_1_people,
                    thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                    num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id += 1
            all_agents[agent.id] = agent
        end
        for _ in 1:district_households[index, 2]
            # PWOP2P0C
            new_agent_id = agent_id + 1
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_2_people, 0, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 3]
            # PWOP3P0C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 0, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 4]
            # PWOP3P1C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 1, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 5]
            # PWOP4P0C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 0, 2, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 6]
            # PWOP4P1C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 1, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 7]
            # PWOP4P2C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 2, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 8]
            # PWOP5P0C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 3, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 9]
            # PWOP5P1C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 2, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 10]
            # PWOP5P2C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 2, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 11]
            # PWOP5P3C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 3, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 12]
            # PWOP6P0C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 4, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 13]
            # PWOP6P1C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 3, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 14]
            # PWOP6P2C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 2, 2, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 15]
            # PWOP6P3C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 3, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 16]
            # 2PWOP4P0C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 0, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id += 2
            agents2 = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 0, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 17]
            # 2PWOP5P0C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id += 3
            agents2 = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 18]
            # 2PWOP5P1C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id += 3
            agents2 = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 19]
            # 2PWOP6P0C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id += 3
            agents2 = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 20]
            # 2PWOP6P1C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id += 3
            agents2 = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 21]
            # 2PWOP6P2C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id += 3
            agents2 = create_parents_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 22]
            # SMWC2P0C
            new_agent_id = agent_id + 1
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_2_people, 0, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 23]
            # SMWC2P1C
            new_agent_id = agent_id + 1
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_2_people, 1, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 24]
            # SMWC3P0C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 25]
            # SMWC3P1C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 26]
            # SMWC3P2C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 2, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 27]
            # SMWC4P0C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 28]
            # SMWC4P1C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 29]
            # SMWC4P2C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 30]
            # SMWC4P3C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 3, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 31]
            # SFWC2P0C
            new_agent_id = agent_id + 1
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_2_people, 0, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 32]
            # SFWC2P1C
            new_agent_id = agent_id + 1
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_2_people, 1, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 33]
            # SFWC3P0C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 34]
            # SFWC3P1C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 35]
            # SFWC3P2C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 2, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 36]
            # SPWCWP3P0C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 37]
            # SPWCWP3P1C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 38]
            # SPWCWP4P0C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 39]
            # SPWCWP4P1C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 40]
            # SPWCWP4P2C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end

        for _ in 1:district_households[index, 41]
            # SPWCWPWOP3P0C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 42]
            # SPWCWPWOP3P1C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 43]
            # SPWCWPWOP4P0C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 44]
            # SPWCWPWOP4P1C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 45]
            # SPWCWPWOP4P2C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 46]
            # SPWCWPWOP5P0C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 4, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 47]
            # SPWCWPWOP5P1C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 3, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 48]
            # SPWCWPWOP5P2C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 2, 2, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end

        for _ in 1:district_households[index, 49]
            # O2P0C
            new_agent_id = agent_id + 1
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_2_people, 0, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 50]
            # O2P1C
            new_agent_id = agent_id + 1
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_2_people, 1, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 51]
            # O3P0C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 52]
            # O3P1C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 53]
            # O3P2C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 2, 0, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 54]
            # O4P0C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 55]
            # O4P1C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 56]
            # O4P2C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 57]
            # O5P0C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 4, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 58]
            # O5P1C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 3, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        for _ in 1:district_households[index, 59]
            # O5P2C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, viral_loads, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 2, 2, index,
                thread_id, num_of_people_in_kindergarten, num_of_people_in_school_threads,
                num_of_people_in_university_threads, num_of_people_in_workplace_threads)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
        end
        district_end_agent_id = agent_id - 1

        kindergarten_group_nums = Array{Int, 1}(undef, 6)
        kindergarten_group_nums[1] = ceil(Int, num_of_people_in_kindergarten[1] / 10)
        kindergarten_group_nums[2:3] = ceil.(Int, num_of_people_in_kindergarten[2:3] ./ 15)
        kindergarten_group_nums[4:6] = ceil.(Int, num_of_people_in_kindergarten[4:6] ./ 20)

        kindergarten_groups = [[Int[] for _ in 1:kindergarten_group_nums[j]] for j = 1:6]
        kindergarten_group_ids = [collect(1:kindergarten_group_nums[i]) for i = 1:6]

        for agent in all_agents[district_start_agent_id:district_end_agent_id]
            if agent.collective_id == 1
                random_num = rand(1:size(kindergarten_group_ids[agent.group_num], 1))
                agent.group_id = kindergarten_group_ids[agent.group_num][random_num]
                deleteat!(kindergarten_group_ids[agent.group_num], random_num)
                if size(kindergarten_group_ids[agent.group_num], 1) == 0
                    kindergarten_group_ids[agent.group_num] = collect(1:kindergarten_group_nums[agent.group_num])
                end
                push!(kindergarten_groups[agent.group_num][agent.group_id], agent.id)
                agent.collective_conn_ids = kindergarten_groups[agent.group_num][agent.group_id]
            end
        end
    end
end
