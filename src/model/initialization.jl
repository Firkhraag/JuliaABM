function create_agent(
    agent_id::Int,
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
    household_conn_ids::Vector{Int},
    index::Int,
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_household_index::Int,
    thread_id::Int,
    thread_rng::Vector{MersenneTwister},
    num_of_people_in_kindergarten::Vector{Int},
    num_of_people_in_school::Vector{Int},
    num_of_people_in_university::Vector{Int},
    num_of_people_in_workplace::Vector{Int},
    is_male::Union{Bool, Nothing} = nothing,
    is_child::Bool = false,
    parent_age::Union{Int, Nothing} = nothing,
    is_older::Bool = false,
    is_parent_of_parent::Bool = false
):: Agent
    age_rand_num = rand(thread_rng[thread_id], 1:100)
    sex_random_num = rand(thread_rng[thread_id], 1:100)
    if is_child
        if parent_age < 23
            # M0–4
            return Agent(agent_id, viruses, infectivities, household_conn_ids,
                sex_random_num <= district_people[index, 1], rand(thread_rng[thread_id], 0:(parent_age - 18)),
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            # return Agent(agent_id, viruses, infectivities, household_conn_ids,
            #     sex_random_num <= district_people[index, 1], rand(thread_rng[thread_id], 0:4),
            #     thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            #     num_of_people_in_university, num_of_people_in_workplace)
        elseif parent_age < 28
            # T0-4_0–9
            if (age_rand_num <= district_people[index, 19])
                # M0–4
                Agent(agent_id, viruses, infectivities, household_conn_ids,
                    sex_random_num <= district_people[index, 1], rand(thread_rng[thread_id], 0:4),
                    thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                    num_of_people_in_university, num_of_people_in_workplace)
            else
                # M5–9
                Agent(agent_id, viruses, infectivities, household_conn_ids,
                    sex_random_num <= district_people[index, 2], rand(thread_rng[thread_id], 5:(parent_age - 18)),
                    thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                    num_of_people_in_university, num_of_people_in_workplace)
                # Agent(agent_id, viruses, infectivities, household_conn_ids,
                #     sex_random_num <= district_people[index, 2], rand(thread_rng[thread_id], 5:9),
                #     thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                #     num_of_people_in_university, num_of_people_in_workplace)
            end
        elseif parent_age < 33
            # T0-4_0–14
            if (age_rand_num <= district_people[index, 20])
                # M0–4
                Agent(agent_id, viruses, infectivities, household_conn_ids,
                    sex_random_num <= district_people[index, 1], rand(thread_rng[thread_id], 0:4),
                    thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                    num_of_people_in_university, num_of_people_in_workplace)
            # T0-9_0–14
            elseif (age_rand_num <= district_people[index, 21])
                # M5–9
                Agent(agent_id, viruses, infectivities, household_conn_ids,
                    sex_random_num <= district_people[index, 2], rand(thread_rng[thread_id], 5:9),
                    thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                    num_of_people_in_university, num_of_people_in_workplace)
            else
                # M10–14
                Agent(agent_id, viruses, infectivities, household_conn_ids,
                    sex_random_num <= district_people[index, 3], rand(thread_rng[thread_id], 10:(parent_age - 18)),
                    thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                    num_of_people_in_university, num_of_people_in_workplace)
                # Agent(agent_id, viruses, infectivities, household_conn_ids,
                #     sex_random_num <= district_people[index, 3], rand(thread_rng[thread_id], 10:14),
                #     thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                #     num_of_people_in_university, num_of_people_in_workplace)
            end
        elseif parent_age < 35
            age_group_rand_num = rand(thread_rng[thread_id], 1:100)
            if age_group_rand_num <= district_people_households[1, district_household_index]
                # T0-4_0–14
                if (age_rand_num <= district_people[index, 20])
                    # M0–4
                    Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 1], rand(thread_rng[thread_id], 0:4),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                # T0-9_0–14
                elseif (age_rand_num <= district_people[index, 21])
                    # M5–9
                    Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 2], rand(thread_rng[thread_id], 5:9),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M10–14
                    Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 3], rand(thread_rng[thread_id], 10:14),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            else
                # M15–19
                return Agent(agent_id, viruses, infectivities, household_conn_ids,
                    sex_random_num <= district_people[index, 4], rand(thread_rng[thread_id], 15:(parent_age - 18)),
                    thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                    num_of_people_in_university, num_of_people_in_workplace)
                # return Agent(agent_id, viruses, infectivities, household_conn_ids,
                #     sex_random_num <= district_people[index, 4], rand(thread_rng[thread_id], 15:17),
                #     thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                #     num_of_people_in_university, num_of_people_in_workplace)
            end
        elseif parent_age < 55
            age_group_rand_num = rand(thread_rng[thread_id], 1:100)
            if age_group_rand_num <= district_people_households[1, district_household_index]
                # T0-4_0–14
                if (age_rand_num <= district_people[index, 20])
                    # M0–4
                    Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 1], rand(thread_rng[thread_id], 0:4),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                # T0-9_0–14
                elseif (age_rand_num <= district_people[index, 21])
                    # M5–9
                    Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 2], rand(thread_rng[thread_id], 5:9),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M10–14
                    Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 3], rand(thread_rng[thread_id], 10:14),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            else
                # M15–19
                return Agent(agent_id, viruses, infectivities, household_conn_ids,
                    sex_random_num <= district_people[index, 4], rand(thread_rng[thread_id], 15:17),
                    thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                    num_of_people_in_university, num_of_people_in_workplace)
            end
        elseif parent_age < 60
            age_group_rand_num = rand(thread_rng[thread_id], 1:100)
            if age_group_rand_num <= district_people_households[1, district_household_index]
                # T0-4_0–14
                if (age_rand_num <= district_people[index, 20])
                    # M0–4
                    Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 1], rand(thread_rng[thread_id], (parent_age - 55):4),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                # T0-9_0–14
                elseif (age_rand_num <= district_people[index, 21])
                    # M5–9
                    Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 2], rand(thread_rng[thread_id], 5:9),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M10–14
                    Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 3], rand(thread_rng[thread_id], 10:14),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            else
                # M15–19
                return Agent(agent_id, viruses, infectivities, household_conn_ids,
                    sex_random_num <= district_people[index, 4], rand(thread_rng[thread_id], 15:17),
                    thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                    num_of_people_in_university, num_of_people_in_workplace)
            end
        elseif parent_age < 65
            age_group_rand_num = rand(thread_rng[thread_id], 1:100)
            if age_group_rand_num <= district_people_households[1, district_household_index]
                # T5-9_5–14
                if rand(thread_rng[thread_id], Float64) < 0.5
                    # M5–9
                    Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 2], rand(thread_rng[thread_id], (parent_age - 55):9),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M10–14
                    Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 3], rand(thread_rng[thread_id], 10:14),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            else
                # M15–19
                return Agent(agent_id, viruses, infectivities, household_conn_ids,
                    sex_random_num <= district_people[index, 4], rand(thread_rng[thread_id], 15:17),
                    thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                    num_of_people_in_university, num_of_people_in_workplace)
            end
        elseif parent_age < 70
            age_group_rand_num = rand(thread_rng[thread_id], 1:100)
            if age_group_rand_num <= district_people_households[1, district_household_index]
                # M10–14
                Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 3], rand(thread_rng[thread_id], (parent_age - 55):14),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
            else
                # M15–19
                return Agent(agent_id, viruses, infectivities, household_conn_ids,
                    sex_random_num <= district_people[index, 4], rand(thread_rng[thread_id], 15:17),
                    thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                    num_of_people_in_university, num_of_people_in_workplace)
            end
        elseif parent_age < 73
            return Agent(agent_id, viruses, infectivities, household_conn_ids,
                sex_random_num <= district_people[index, 4], rand(thread_rng[thread_id], (parent_age - 55):17),
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
        else
            # return Agent(agent_id, viruses, infectivities, household_conn_ids,
            #         sex_random_num <= district_people[index, 4], rand(thread_rng[thread_id], 17),
            #         thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            #         num_of_people_in_university, num_of_people_in_workplace)
            age_group_rand_num = rand(thread_rng[thread_id], 1:100)
            if age_group_rand_num <= district_people_households[1, district_household_index]
                # T0-4_0–14
                if (age_rand_num <= district_people[index, 20])
                    # M0–4
                    Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 1], rand(thread_rng[thread_id], 0:4),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                # T0-9_0–14
                elseif (age_rand_num <= district_people[index, 21])
                    # M5–9
                    Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 2], rand(thread_rng[thread_id], 5:9),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M10–14
                    Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 3], rand(thread_rng[thread_id], 10:14),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            else
                # M15–19
                return Agent(agent_id, viruses, infectivities, household_conn_ids,
                    sex_random_num <= district_people[index, 4], rand(thread_rng[thread_id], 15:17),
                    thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                    num_of_people_in_university, num_of_people_in_workplace)
            end
        end
    else
        age_group_rand_num = rand(thread_rng[thread_id], 1:100)
        if is_older
            age_group_rand_num = rand(thread_rng[thread_id], (district_people_households[3, district_household_index] + 1):100)
        elseif parent_age !== nothing
            if parent_age < 45
                age_group_rand_num = 1
            elseif parent_age < 55
                age_group_rand_num = rand(thread_rng[thread_id], 1:district_people_households[3, district_household_index])
            elseif parent_age < 65
                age_group_rand_num = rand(thread_rng[thread_id], 1:district_people_households[4, district_household_index])
            else
                age_group_rand_num = rand(thread_rng[thread_id], 1:district_people_households[5, district_household_index])
            end
        elseif is_parent_of_parent
            if parent_age < 25
                age_group_rand_num = rand(thread_rng[thread_id], (district_people_households[3, district_household_index] + 1):100)
            elseif parent_age < 35
                age_group_rand_num = rand(thread_rng[thread_id], (district_people_households[4, district_household_index] + 1):100)
            elseif parent_age < 45
                age_group_rand_num = rand(thread_rng[thread_id], (district_people_households[5, district_household_index] + 1):100)
            else
                age_group_rand_num = 100
            end
        end
        if age_group_rand_num <= district_people_households[2, district_household_index]
            if rand(thread_rng[thread_id], Float64) < 0.25
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 18:19),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M20–24
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 5], rand(thread_rng[thread_id], 18:19),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 20:24),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M20–24
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 5], rand(thread_rng[thread_id], 20:24),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            end
            # if is_male !== nothing
            #     return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 18:24),
            #         thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            #         num_of_people_in_university, num_of_people_in_workplace)
            # else
            #     # M20–24
            #     return Agent(agent_id, viruses, infectivities, household_conn_ids,
            #         sex_random_num <= district_people[index, 5], rand(thread_rng[thread_id], 18:24),
            #         thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            #         num_of_people_in_university, num_of_people_in_workplace)
            # end
        elseif age_group_rand_num <= district_people_households[3, district_household_index]
            # T25-29_25–34
            if age_rand_num <= district_people[index, 22]
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 25:29),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M25–29
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 6], rand(thread_rng[thread_id], 25:29),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 30:34),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M30–34
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 7], rand(thread_rng[thread_id], 30:34),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            end
        elseif age_group_rand_num <= district_people_households[4, district_household_index]
            # T35-39_35–44
            if age_rand_num <= district_people[index, 23]
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 35:39),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M35–39
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 8], rand(thread_rng[thread_id], 35:39),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 40:44),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M40–44
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 9], rand(thread_rng[thread_id], 40:44),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            end
        elseif age_group_rand_num <= district_people_households[5, district_household_index]
            # T45-49_45–54
            if age_rand_num <= district_people[index, 24]
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 45:49),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M45–49
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 10], rand(thread_rng[thread_id], 45:49),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 50:54),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M50–54
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 11], rand(thread_rng[thread_id], 50:54),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            end
        elseif age_group_rand_num <= district_people_households[6, district_household_index]
            # T55-59_55–64
            if age_rand_num <= district_people[index, 25]
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 55:59),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M55–59
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 12], rand(thread_rng[thread_id], 55:59),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 60:64),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M60–64
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 13], rand(thread_rng[thread_id], 60:64),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            end
        else
            # T65-69_65–89
            if age_rand_num <= district_people[index, 26]
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 65:69),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M65–69
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 14], rand(thread_rng[thread_id], 65:69),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            # T65-74_65–89
            elseif age_rand_num <= district_people[index, 27]
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 70:74),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M70–74
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 15], rand(thread_rng[thread_id], 70:74),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            # T65-79_65–89
            elseif age_rand_num <= district_people[index, 28]
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 75:79),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M75–79
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 16], rand(thread_rng[thread_id], 75:79),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            # T65-84_65–89
            elseif age_rand_num <= district_people[index, 29]
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 80:84),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M80–84
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 17], rand(thread_rng[thread_id], 80:84),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 85:89),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                else
                    # M85–89
                    return Agent(agent_id, viruses, infectivities, household_conn_ids,
                        sex_random_num <= district_people[index, 18], rand(thread_rng[thread_id], 85:89),
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                end
            end
        end
    end
end

function create_spouse(
    agent_id::Int,
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
    household_conn_ids::Vector{Int},
    partner_age::Int,
    thread_id::Int,
    thread_rng::Vector{MersenneTwister},
    num_of_people_in_kindergarten::Vector{Int},
    num_of_people_in_school::Vector{Int},
    num_of_people_in_university::Vector{Int},
    num_of_people_in_workplace::Vector{Int}
)
    rand_num = rand(thread_rng[thread_id], Float64)
    difference = 0
    if rand_num < 0.03
        difference = rand(thread_rng[thread_id], -20:-15)
    elseif rand_num < 0.08
        difference = rand(thread_rng[thread_id], -14:-10)
    elseif rand_num < 0.2
        difference = rand(thread_rng[thread_id], -9:-6)
    elseif rand_num < 0.33
        difference = rand(thread_rng[thread_id], -5:-4)
    elseif rand_num < 0.53
        difference = rand(thread_rng[thread_id], -3:-2)
    elseif rand_num < 0.86
        difference = rand(thread_rng[thread_id], -1:1)
    elseif rand_num < 0.93
        difference = rand(thread_rng[thread_id], 2:3)
    elseif rand_num < 0.96
        difference = rand(thread_rng[thread_id], 4:5)
    elseif rand_num < 0.98
        difference = rand(thread_rng[thread_id], 6:9)
    else
        difference = rand(thread_rng[thread_id], 10:14)
    end

    # spouse_age = partner_age + difference
    spouse_age = partner_age - difference

    while spouse_age < 18 || spouse_age > 89
        rand_num = rand(thread_rng[thread_id], Float64)
        difference = 0
        if rand_num < 0.03
            difference = rand(thread_rng[thread_id], -20:-15)
        elseif rand_num < 0.08
            difference = rand(thread_rng[thread_id], -14:-10)
        elseif rand_num < 0.2
            difference = rand(thread_rng[thread_id], -9:-6)
        elseif rand_num < 0.33
            difference = rand(thread_rng[thread_id], -5:-4)
        elseif rand_num < 0.53
            difference = rand(thread_rng[thread_id], -3:-2)
        elseif rand_num < 0.86
            difference = rand(thread_rng[thread_id], -1:1)
        elseif rand_num < 0.93
            difference = rand(thread_rng[thread_id], 2:3)
        elseif rand_num < 0.96
            difference = rand(thread_rng[thread_id], 4:5)
        elseif rand_num < 0.98
            difference = rand(thread_rng[thread_id], 6:9)
        else
            difference = rand(thread_rng[thread_id], 10:14)
        end
        # spouse_age = partner_age + difference
        spouse_age = partner_age - difference
    end

    # return Agent(agent_id, viruses, infectivities, household_conn_ids, false, spouse_age,
    #     thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
    #     num_of_people_in_university, num_of_people_in_workplace)
    return Agent(agent_id, viruses, infectivities, household_conn_ids, true, spouse_age,
        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
        num_of_people_in_university, num_of_people_in_workplace)
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
    infectivities::Array{Float64, 4},
    household_conn_ids::Vector{Int},
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int,
    thread_id::Int,
    thread_rng::Vector{MersenneTwister},
    num_of_people_in_kindergarten::Vector{Int},
    num_of_people_in_school::Vector{Int},
    num_of_people_in_university::Vector{Int},
    num_of_people_in_workplace::Vector{Int},
    is_old_pair::Bool = false,
)::Vector{Agent}
    agent_female = create_agent(agent_id,
        viruses, infectivities, household_conn_ids, index,
        district_people, district_people_households,
        district_household_index,
        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
        num_of_people_in_university, num_of_people_in_workplace, false, false, nothing, is_old_pair)
    agent_id += 1
    agent_male = create_spouse(
        agent_id, viruses, infectivities, household_conn_ids, agent_female.age,
        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
        num_of_people_in_university, num_of_people_in_workplace)
    agent_id += 1
    if num_of_other_people == 0
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age)
            agent_id += 1
            no_one_at_home = agent_male.collective_id != 0 && agent_female.collective_id != 0
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, child]
            end
            child2 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age + 2)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, child, child2, child3]
        end
        return Agent[agent_male, agent_female]
    elseif num_of_other_people == 1
        agent_other = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age)
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
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age + 2)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other]
    elseif num_of_other_people == 2
        agent_other = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age)
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
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age + 2)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age)
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
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age + 2)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3]
    else
        agent_other = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other4 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age)
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
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, agent_female.age + 2)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4]
    end
end

function create_parent_with_children(
    agent_id::Int,
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
    household_conn_ids::Vector{Int},
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int,
    thread_id::Int,
    thread_rng::Vector{MersenneTwister},
    num_of_people_in_kindergarten::Vector{Int},
    num_of_people_in_school::Vector{Int},
    num_of_people_in_university::Vector{Int},
    num_of_people_in_workplace::Vector{Int},
    is_male_parent::Union{Bool, Nothing},
    with_parent_of_parent::Bool = false,
)::Vector{Agent}
    parent = create_agent(agent_id,
        viruses, infectivities, household_conn_ids, index,
        district_people, district_people_households,
        district_household_index,
        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
        num_of_people_in_university, num_of_people_in_workplace, is_male_parent,
        false, nothing, num_of_other_people > 0)
    agent_id += 1
    if num_of_other_people == 0
        child = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age)
        agent_id += 1
        no_one_at_home = parent.collective_id != 0
        check_parent_leave(no_one_at_home, parent, child)
        if num_of_children == 1
            return Agent[parent, child]
        end
        child2 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age + 1)

        agent_id += 1
        check_parent_leave(no_one_at_home, parent, child2)
        if num_of_children == 2
            return Agent[parent, child, child2]
        end
        child3 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age + 2)
        check_parent_leave(no_one_at_home, parent, child3)
        return Agent[parent, child, child2, child3]
    elseif num_of_other_people == 1
        agent_other = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age)
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
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age + 2)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, child, child2, child3]
        end
        return Agent[parent, agent_other]
    elseif num_of_other_people == 2
        agent_other = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace, nothing,
            false, parent.age)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age)
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
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age + 2)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace, nothing,
            false, parent.age)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace, nothing,
            false, parent.age)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age)
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
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age + 2)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2, agent_other3]
    else
        agent_other = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace, nothing,
            false, parent.age)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace, nothing,
            false, parent.age)
        agent_id += 1
        agent_other4 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace, nothing,
            false, parent.age)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age)
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
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, parent.age + 2)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4]
    end
end

function create_others(
    agent_id::Int,
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
    household_conn_ids::Vector{Int},
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int,
    thread_id::Int,
    thread_rng::Vector{MersenneTwister},
    num_of_people_in_kindergarten::Vector{Int},
    num_of_people_in_school::Vector{Int},
    num_of_people_in_university::Vector{Int},
    num_of_people_in_workplace::Vector{Int}
)::Vector{Agent}
    agent = create_agent(agent_id,
        viruses, infectivities, household_conn_ids, index,
        district_people, district_people_households, district_household_index,
        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
        num_of_people_in_university, num_of_people_in_workplace)
    agent_id += 1
    if num_of_other_people == 0
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
            agent_id += 1
            no_one_at_home = agent.collective_id != 0
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, child]
            end
            child2 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, child, child2, child3]
        end
        return Agent[agent]
    elseif num_of_other_people == 1
        agent_other = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
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
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, child, child2, child3]
        end
        return Agent[agent, agent_other]
    elseif num_of_other_people == 2
        agent_other = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
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
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
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
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2, agent_other3]
    elseif num_of_other_people == 4
        agent_other = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other4 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
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
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3 = create_agent(agent_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4]
    else
        agent_other = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other2 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other3 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other4 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        agent_other5 = create_agent(agent_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            num_of_people_in_university, num_of_people_in_workplace)
        agent_id += 1
        return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, agent_other5]
    end
end

function sample_from_zipf_distribution(
    parameter::Float64, max_size::Int, rng::MersenneTwister
)::Int
    cumulative = 0.0
    rand_num = rand(rng, Float64)
    multiplier = 1 / sum((1:max_size).^(-parameter))
    for i = 1:max_size
        cumulative += i^(-parameter) * multiplier
        if rand_num < cumulative
            return i
        end
    end
    return max_size
end

# Создание графа Барабаши-Альберта
# На вход подаются группа с набором агентов (group) и число минимальных связей, которые должен иметь агент (m)
function generate_barabasi_albert_network(agents::Vector{Agent}, group_ids::Vector{Int}, m::Int, rng::MersenneTwister)
    if size(group_ids, 1) < m
        m = size(group_ids, 1)
    end
    # Связный граф с m вершинами
    for i = 1:m
        for j = (i + 1):m
            push!(agents[group_ids[i]].collective_conn_ids, group_ids[j])
            push!(agents[group_ids[j]].collective_conn_ids, group_ids[i])
        end
    end
    # Сумма связей всех вершин
    degree_sum = m * (m - 1)
    # Добавление новых вершин
    for i = (m + 1):size(group_ids, 1)
        agent = agents[group_ids[i]]
        degree_sum_temp = degree_sum
        for _ = 1:m
            cumulative = 0.0
            rand_num = rand(rng, Float64)
            for j = 1:(i-1)
                if group_ids[j] in agent.collective_conn_ids
                    continue
                end
                agent2 = agents[group_ids[j]]
                cumulative += size(agent2.collective_conn_ids, 1) / degree_sum_temp
                if rand_num < cumulative
                    degree_sum_temp -= size(agent2.collective_conn_ids, 1)
                    push!(agent.collective_conn_ids, agent2.id)
                    push!(agent2.collective_conn_ids, agent.id)
                    break
                end
            end
        end
        degree_sum += 2m
    end
end

function set_connections(
    agents::Vector{Agent},
    start_agent_id::Int,
    end_agent_id::Int,
    num_of_people_in_school::Vector{Int},
    num_of_people_in_university::Vector{Int},
    num_of_people_in_workplace::Vector{Int},
    num_of_groups_in_kindergartens::Int,
    kindergarten_groups_districts::Vector{Vector{Vector{Vector{Int64}}}},
    rng::MersenneTwister,
    thread_id::Int
)
    school_group_nums = ceil.(Int, num_of_people_in_school ./ 22)

    university_group_nums = Array{Int, 1}(undef, 6)
    university_group_nums[1] = ceil(Int, num_of_people_in_university[1] / 15)
    university_group_nums[2:3] = ceil.(Int, num_of_people_in_university[2:3] ./ 14)
    university_group_nums[4] = ceil.(Int, num_of_people_in_university[4] ./ 13)
    university_group_nums[5] = ceil.(Int, num_of_people_in_university[5] ./ 11)
    university_group_nums[6] = ceil.(Int, num_of_people_in_university[6] ./ 10)

    workplaces_num_people = Int[]
    workplace_num_people = num_of_people_in_workplace[1] - num_of_groups_in_kindergartens
    for i = 1:11
        workplace_num_people -= school_group_nums[i]
    end
    for i = 1:6
        workplace_num_people -= university_group_nums[i]
    end

    while num_of_people_in_workplace[1] > 0
        num_people = sample_from_zipf_distribution(1.059, 1995, rng) + 5
        if num_of_people_in_workplace[1] - num_people > 0
            append!(workplaces_num_people, num_people)
        else
            append!(workplaces_num_people, num_of_people_in_workplace[1])
        end
        num_of_people_in_workplace[1] -= num_people
    end

    # if thread_id == 1
    #     writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "workplaces_num_people1.csv"), workplaces_num_people, ',')
    # elseif thread_id == 2
    #     writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "workplaces_num_people2.csv"), workplaces_num_people, ',')
    # elseif thread_id == 3
    #     writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "workplaces_num_people3.csv"), workplaces_num_people, ',')
    # else
    #     writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "workplaces_num_people4.csv"), workplaces_num_people, ',')
    # end

    workplace_weights = workplaces_num_people ./ workplace_num_people

    school_groups = [[Int[] for _ in 1:school_group_nums[j]] for j = 1:11]
    university_groups = [[Int[] for _ in 1:university_group_nums[j]] for j = 1:6]
    workplace_groups = [Int[] for _ in 1:size(workplaces_num_people, 1)]

    school_group_ids = [collect(1:school_group_nums[i]) for i = 1:11]
    university_group_ids = [collect(1:university_group_nums[i]) for i = 1:6]

    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
        if agent.collective_id == 2
            random_num = rand(rng, 1:size(school_group_ids[agent.group_num], 1))
            group_id = school_group_ids[agent.group_num][random_num]
            deleteat!(school_group_ids[agent.group_num], random_num)
            if size(school_group_ids[agent.group_num], 1) == 0
                school_group_ids[agent.group_num] = collect(1:school_group_nums[agent.group_num])
            end
            push!(school_groups[agent.group_num][group_id], agent.id)
            agent.collective_conn_ids = school_groups[agent.group_num][group_id]
        elseif agent.collective_id == 3
            random_num = rand(rng, 1:size(university_group_ids[agent.group_num], 1))
            group_id = university_group_ids[agent.group_num][random_num]
            deleteat!(university_group_ids[agent.group_num], random_num)
            if size(university_group_ids[agent.group_num], 1) == 0
                university_group_ids[agent.group_num] = collect(1:university_group_nums[agent.group_num])
            end
            push!(university_groups[agent.group_num][group_id], agent.id)
            agent.collective_conn_ids = university_groups[agent.group_num][group_id]
        end
    end

    kindergarten_district_num = 1
    kindergarten_group_num = 1
    kindergarten_group_id = 1
    school_group_num = 1
    school_group_id = 1
    university_group_num = 1
    university_group_id = 1
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
        if agent.collective_id == 4
            if kindergarten_district_num < length(kindergarten_groups_districts) + 1 && agent.age >= 18
                agent.collective_id = 1
                agent.group_num = kindergarten_group_num
                agent.is_teacher = true
                push!(kindergarten_groups_districts[kindergarten_district_num][kindergarten_group_num][kindergarten_group_id], agent.id)
                agent.collective_conn_ids = kindergarten_groups_districts[kindergarten_district_num][kindergarten_group_num][kindergarten_group_id]
                kindergarten_group_id += 1
                if kindergarten_group_id > length(kindergarten_groups_districts[kindergarten_district_num][kindergarten_group_num])
                    kindergarten_group_num += 1
                    kindergarten_group_id = 1
                    if kindergarten_group_num > 5
                        kindergarten_district_num += 1
                        kindergarten_group_num = 1
                    end
                end
            elseif school_group_num < 12 && agent.age >= 20
                agent.collective_id = 2
                agent.group_num = school_group_num
                agent.is_teacher = true
                push!(school_groups[school_group_num][school_group_id], agent.id)
                agent.collective_conn_ids = school_groups[school_group_num][school_group_id]
                school_group_id += 1
                if school_group_id > length(school_groups[school_group_num])
                    school_group_num += 1
                    school_group_id = 1
                end
            elseif university_group_num < 7 && agent.age >= 25
                agent.collective_id = 3
                agent.group_num = university_group_num
                agent.is_teacher = true
                push!(university_groups[university_group_num][university_group_id], agent.id)
                agent.collective_conn_ids = university_groups[university_group_num][university_group_id]
                university_group_id += 1
                if university_group_id > length(university_groups[university_group_num])
                    university_group_num += 1
                    university_group_id = 1
                end
            else
                random_num = rand(rng, Float64)
                cumulative = 0.0
                for i in 1:size(workplaces_num_people, 1)
                    cumulative += workplace_weights[i]
                    if random_num < cumulative
                        push!(workplace_groups[i], agent.id)
                        break
                    end
                end
            end
        end
    end

    for i = 1:6
        for j = 1:4:size(university_groups[i], 1)
            if size(university_groups[i], 1) - j >= 4
                group1 = university_groups[i][j]
                group2 = university_groups[i][j + 1]
                group3 = university_groups[i][j + 2]
                group4 = university_groups[i][j + 3]
                connections_for_group1 = vcat(group2, group3, group4)
                connections_for_group2 = vcat(group1, group3, group4)
                connections_for_group3 = vcat(group2, group1, group4)
                connections_for_group4 = vcat(group2, group3, group1)
                for agent_id in group1
                    agent = agents[agent_id]
                    agent.collective_cross_conn_ids = connections_for_group1
                end
                for agent_id in group2
                    agent = agents[agent_id]
                    agent.collective_cross_conn_ids = connections_for_group2
                end
                for agent_id in group3
                    agent = agents[agent_id]
                    agent.collective_cross_conn_ids = connections_for_group3
                end
                for agent_id in group4
                    agent = agents[agent_id]
                    agent.collective_cross_conn_ids = connections_for_group4
                end
            end
        end
    end

    for workplace_group in workplace_groups
        generate_barabasi_albert_network(agents, workplace_group, 6, rng)
    end
end

function create_population(
    thread_id::Int,
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    start_agent_id::Int,
    end_agent_id::Int,
    all_agents::Vector{Agent},
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
    district_households::Matrix{Int},
    district_people::Matrix{Int},
    district_people_households::Matrix{Int},
    district_nums::Vector{Int}
)
    num_of_groups_in_kindergartens_districts = zeros(Int, length(district_nums[thread_id:num_threads:size(district_nums, 1)]))
    kindergarten_groups_districts = Array{Vector{Vector{Vector{Int64}}}, 1}(undef, length(district_nums[thread_id:num_threads:size(district_nums, 1)]))

    num_of_people_in_school = zeros(Int, 11)
    num_of_people_in_university = zeros(Int, 6)
    num_of_people_in_workplace = zeros(Int, 1)

    agent_id = start_agent_id
    for (i, index) in enumerate(district_nums[thread_id:num_threads:size(district_nums, 1)])
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
            # agent = create_agent(
            #     agent_id, viruses, infectivities, household_conn_ids, index, district_people,
            #         district_people_households, index_for_1_people,
            #         thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
            #         num_of_people_in_university, num_of_people_in_workplace)
            if rand(thread_rng[thread_id], Float64) < 0.0123
                agent = create_agent(
                    agent_id, viruses, infectivities, household_conn_ids, index, district_people,
                        district_people_households, index_for_1_people,
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace, nothing, true, 35)
                # agent_id += 1
                all_agents[agent.id] = agent
    
                agent.household_type = "1P"
            else
                agent = create_agent(
                    agent_id, viruses, infectivities, household_conn_ids, index, district_people,
                        district_people_households, index_for_1_people,
                        thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                        num_of_people_in_university, num_of_people_in_workplace)
                # agent_id += 1
                all_agents[agent.id] = agent
    
                agent.household_type = "1P"
            end
            agent_id += 1
            # all_agents[agent.id] = agent

            # agent.household_type = "1P"
        end
        for _ in 1:district_households[index, 2]
            # PWOP2P0C
            new_agent_id = agent_id + 1
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_2_people, 0, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "PWOP2P0C"
            end
        end
        for _ in 1:district_households[index, 3]
            # PWOP3P0C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 0, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "PWOP3P0C"
            end
        end
        for _ in 1:district_households[index, 4]
            # PWOP3P1C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 1, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "PWOP3P1C"
            end
        end
        for _ in 1:district_households[index, 5]
            # PWOP4P0C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 0, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "PWOP4P0C"
            end
        end
        for _ in 1:district_households[index, 6]
            # PWOP4P1C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 1, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "PWOP4P1C"
            end
        end
        for _ in 1:district_households[index, 7]
            # PWOP4P2C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 2, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "PWOP4P2C"
            end
        end
        for _ in 1:district_households[index, 8]
            # PWOP5P0C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 3, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "PWOP5P0C"
            end
        end
        for _ in 1:district_households[index, 9]
            # PWOP5P1C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "PWOP5P1C"
            end
        end
        for _ in 1:district_households[index, 10]
            # PWOP5P2C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 2, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "PWOP5P2C"
            end
        end
        for _ in 1:district_households[index, 11]
            # PWOP5P3C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 3, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "PWOP5P3C"
            end
        end
        for _ in 1:district_households[index, 12]
            # PWOP6P0C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 4, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "PWOP6P0C"
            end
        end
        for _ in 1:district_households[index, 13]
            # PWOP6P1C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 3, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "PWOP6P1C"
            end
        end
        for _ in 1:district_households[index, 14]
            # PWOP6P2C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 2, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "PWOP6P2C"
            end
        end
        for _ in 1:district_households[index, 15]
            # PWOP6P3C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 3, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "PWOP6P3C"
            end
        end
        for _ in 1:district_households[index, 16]
            # 2PWOP4P0C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 0, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id += 2
            agents2 = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 0, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, true)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "2PWOP4P0C"
            end
        end
        for _ in 1:district_households[index, 17]
            # 2PWOP5P0C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id += 3
            agents2 = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, true)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "2PWOP5P0C"
            end
        end
        for _ in 1:district_households[index, 18]
            # 2PWOP5P1C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id += 3
            agents2 = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, true)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "2PWOP5P1C"
            end
        end
        for _ in 1:district_households[index, 19]
            # 2PWOP6P0C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id += 4
            agents2 = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, true)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "2PWOP6P0C"
            end
        end
        for _ in 1:district_households[index, 20]
            # 2PWOP6P1C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id += 4
            agents2 = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, true)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "2PWOP6P1C"
            end
        end
        for _ in 1:district_households[index, 21]
            # 2PWOP6P2C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 2, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id += 4
            agents2 = create_parents_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, true)
            append!(agents, agents2)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "2PWOP6P2C"
            end
        end
        for _ in 1:district_households[index, 22]
            # SMWC2P0C
            new_agent_id = agent_id + 1
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_2_people, 0, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SMWC2P0C"
            end
        end
        for _ in 1:district_households[index, 23]
            # SMWC2P1C
            new_agent_id = agent_id + 1
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_2_people, 1, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SMWC2P1C"
            end
        end
        for _ in 1:district_households[index, 24]
            # SMWC3P0C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SMWC3P0C"
            end
        end
        for _ in 1:district_households[index, 25]
            # SMWC3P1C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SMWC3P1C"
            end
        end
        for _ in 1:district_households[index, 26]
            # SMWC3P2C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 2, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SMWC3P2C"
            end
        end
        for _ in 1:district_households[index, 27]
            # SMWC4P0C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SMWC4P0C"
            end
        end
        for _ in 1:district_households[index, 28]
            # SMWC4P1C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SMWC4P1C"
            end
        end
        for _ in 1:district_households[index, 29]
            # SMWC4P2C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SMWC4P2C"
            end
        end
        for _ in 1:district_households[index, 30]
            # SMWC4P3C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 3, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SMWC4P3C"
            end
        end
        for _ in 1:district_households[index, 31]
            # SFWC2P0C
            new_agent_id = agent_id + 1
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_2_people, 0, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SFWC2P0C"
            end
        end
        for _ in 1:district_households[index, 32]
            # SFWC2P1C
            new_agent_id = agent_id + 1
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_2_people, 1, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SFWC2P1C"
            end
        end
        for _ in 1:district_households[index, 33]
            # SFWC3P0C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SFWC3P0C"
            end
        end
        for _ in 1:district_households[index, 34]
            # SFWC3P1C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SFWC3P1C"
            end
        end
        for _ in 1:district_households[index, 35]
            # SFWC3P2C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 2, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SFWC3P2C"
            end
        end
        for _ in 1:district_households[index, 36]
            # SPWCWP3P0C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SPWCWP3P0C"
            end
        end
        for _ in 1:district_households[index, 37]
            # SPWCWP3P1C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SPWCWP3P1C"
            end
        end
        for _ in 1:district_households[index, 38]
            # SPWCWP4P0C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SPWCWP4P0C"
            end
        end
        for _ in 1:district_households[index, 39]
            # SPWCWP4P1C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SPWCWP4P1C"
            end
        end
        for _ in 1:district_households[index, 40]
            # SPWCWP4P2C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SPWCWP4P2C"
            end
        end

        for _ in 1:district_households[index, 41]
            # SPWCWPWOP3P0C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SPWCWPWOP3P0C"
            end
        end
        for _ in 1:district_households[index, 42]
            # SPWCWPWOP3P1C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SPWCWPWOP3P1C"
            end
        end
        for _ in 1:district_households[index, 43]
            # SPWCWPWOP4P0C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SPWCWPWOP4P0C"
            end
        end
        for _ in 1:district_households[index, 44]
            # SPWCWPWOP4P1C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SPWCWPWOP4P1C"
            end
        end
        for _ in 1:district_households[index, 45]
            # SPWCWPWOP4P2C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SPWCWPWOP4P2C"
            end
        end
        for _ in 1:district_households[index, 46]
            # SPWCWPWOP5P0C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 4, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SPWCWPWOP5P0C"
            end
        end
        for _ in 1:district_households[index, 47]
            # SPWCWPWOP5P1C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 3, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SPWCWPWOP5P1C"
            end
        end
        for _ in 1:district_households[index, 48]
            # SPWCWPWOP5P2C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_parent_with_children(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 2, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace, nothing, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "SPWCWPWOP5P2C"
            end
        end

        for _ in 1:district_households[index, 49]
            # O2P0C
            new_agent_id = agent_id + 1
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_2_people, 0, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O2P0C"
            end
        end
        for _ in 1:district_households[index, 50]
            # O2P1C
            new_agent_id = agent_id + 1
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_2_people, 1, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O2P1C"
            end
        end
        for _ in 1:district_households[index, 51]
            # O3P0C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O3P0C"
            end
        end
        for _ in 1:district_households[index, 52]
            # O3P1C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O3P1C"
            end
        end
        for _ in 1:district_households[index, 53]
            # O3P2C
            new_agent_id = agent_id + 2
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_3_people, 2, 0, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O3P2C"
            end
        end
        for _ in 1:district_households[index, 54]
            # O4P0C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O4P0C"
            end
        end
        for _ in 1:district_households[index, 55]
            # O4P1C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O4P1C"
            end
        end
        for _ in 1:district_households[index, 56]
            # O4P2C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O4P2C"
            end
        end
        for _ in 1:district_households[index, 57]
            # O4P3C
            new_agent_id = agent_id + 3
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_4_people, 3, 1, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O4P3C"
            end
        end
        for _ in 1:district_households[index, 58]
            # O5P0C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 4, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O5P0C"
            end
        end
        for _ in 1:district_households[index, 59]
            # O5P1C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 3, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O5P1C"
            end
        end
        for _ in 1:district_households[index, 60]
            # O5P2C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 2, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O5P2C"
            end
        end
        for _ in 1:district_households[index, 61]
            # O5P3C
            new_agent_id = agent_id + 4
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 3, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O5P3C"
            end
        end
        for _ in 1:district_households[index, 62]
            # O6P0C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 0, 5, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O6P0C"
            end
        end
        for _ in 1:district_households[index, 63]
            # O6P1C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 1, 4, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O6P1C"
            end
        end
        for _ in 1:district_households[index, 64]
            # O6P2C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 2, 3, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O6P2C"
            end
        end
        for _ in 1:district_households[index, 65]
            # O6P3C
            new_agent_id = agent_id + 5
            household_conn_ids = collect(Int, agent_id:new_agent_id)
            agents = create_others(
                agent_id, viruses, infectivities, household_conn_ids, district_people,
                district_people_households, index_for_5_people, 3, 2, index,
                thread_id, thread_rng, num_of_people_in_kindergarten, num_of_people_in_school,
                num_of_people_in_university, num_of_people_in_workplace)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent

                agent.household_type = "O6P3C"
            end
        end

        district_end_agent_id = agent_id - 1

        kindergarten_group_nums = Array{Int, 1}(undef, 6)
        kindergarten_group_nums[1] = ceil(Int, num_of_people_in_kindergarten[1] / 8)
        kindergarten_group_nums[2:3] = ceil.(Int, num_of_people_in_kindergarten[2:3] ./ 12)
        kindergarten_group_nums[4:5] = ceil.(Int, num_of_people_in_kindergarten[4:5] ./ 17)

        for i = 1:5
            num_of_groups_in_kindergartens_districts[i] += kindergarten_group_nums[i]
        end

        kindergarten_groups = [[Int[] for _ in 1:kindergarten_group_nums[j]] for j = 1:5]
        kindergarten_group_ids = [collect(1:kindergarten_group_nums[i]) for i = 1:5]

        kindergarten_groups_districts[i] = kindergarten_groups

        for agent in all_agents[district_start_agent_id:district_end_agent_id]
            if agent.collective_id == 1
                random_num = rand(thread_rng[thread_id], 1:size(kindergarten_group_ids[agent.group_num], 1))
                group_id = kindergarten_group_ids[agent.group_num][random_num]
                deleteat!(kindergarten_group_ids[agent.group_num], random_num)
                if size(kindergarten_group_ids[agent.group_num], 1) == 0
                    kindergarten_group_ids[agent.group_num] = collect(1:kindergarten_group_nums[agent.group_num])
                end
                push!(kindergarten_groups[agent.group_num][group_id], agent.id)
                agent.collective_conn_ids = kindergarten_groups[agent.group_num][group_id]
            end
        end
    end

    set_connections(
        all_agents,
        start_agent_id,
        end_agent_id,
        num_of_people_in_school,
        num_of_people_in_university,
        num_of_people_in_workplace,
        sum(num_of_groups_in_kindergartens_districts),
        kindergarten_groups_districts,
        thread_rng[thread_id],
        thread_id)
end
