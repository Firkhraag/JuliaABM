function create_agent(
    agent_id::Int,
    household_id::Int,
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
    household_conn_ids::Vector{Int},
    index::Int,
    district_people::Matrix{Float64},
    district_people_households::Matrix{Float64},
    district_household_index::Int,
    thread_id::Int,
    thread_rng::Vector{MersenneTwister},
    is_male::Union{Bool, Nothing} = nothing,
    is_child::Bool = false,
    parent_age::Union{Int, Nothing} = nothing,
    is_older::Bool = false,
    is_parent_of_parent::Bool = false
):: Agent
    age_rand_num = rand(thread_rng[thread_id], Float64)
    sex_random_num = rand(thread_rng[thread_id], Float64)
    if is_child
        if parent_age < 21
            # M0–4
            return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                sex_random_num < district_people[index, 1], rand(thread_rng[thread_id], 0:(parent_age - 16)),
                thread_id, thread_rng)
        elseif parent_age < 26
            # T0-4_0–9
            if age_rand_num < (district_people[index, 19] * 32 / parent_age)
                # M0–4
                sub_age_rand_num = rand(thread_rng[thread_id], Float64)
                if sub_age_rand_num < (0.2 * parent_age / 25)
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 4,
                        thread_id, thread_rng)
                elseif sub_age_rand_num < (0.4 * parent_age / 25)
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 3,
                        thread_id, thread_rng)
                elseif sub_age_rand_num < (0.6 * parent_age / 25)
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 2,
                        thread_id, thread_rng)
                elseif sub_age_rand_num < (0.8 * parent_age / 25)
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 1,
                        thread_id, thread_rng)
                else
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 0,
                        thread_id, thread_rng)
                end
                # Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                #     sex_random_num < district_people[index, 1], rand(thread_rng[thread_id], 0:4),
                #     thread_id, thread_rng)
            else
                # M5–9
                Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    sex_random_num < district_people[index, 2], rand(thread_rng[thread_id], 5:(parent_age - 16)),
                    thread_id, thread_rng)
            end
        elseif parent_age < 31
            # T0-4_0–14
            if age_rand_num < (district_people[index, 20] * 32 / parent_age)
                # M0–4
                sub_age_rand_num = rand(thread_rng[thread_id], Float64)
                if sub_age_rand_num < (0.2 * parent_age / 30)
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 4,
                        thread_id, thread_rng)
                elseif sub_age_rand_num < (0.4 * parent_age / 30)
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 3,
                        thread_id, thread_rng)
                elseif sub_age_rand_num < (0.6 * parent_age / 30)
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 2,
                        thread_id, thread_rng)
                elseif sub_age_rand_num < (0.8 * parent_age / 30)
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 1,
                        thread_id, thread_rng)
                else
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 0,
                        thread_id, thread_rng)
                end
                # Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                #     sex_random_num < district_people[index, 1], rand(thread_rng[thread_id], 0:4),
                #     thread_id, thread_rng)
            # T0-9_0–14
            elseif age_rand_num < (district_people[index, 21]  * 32 / parent_age)
                # M5–9
                sub_age_rand_num = rand(thread_rng[thread_id], Float64)
                if sub_age_rand_num < (0.2 * parent_age / 30)
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 9,
                        thread_id, thread_rng)
                elseif sub_age_rand_num < (0.4 * parent_age / 30)
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 8,
                        thread_id, thread_rng)
                elseif sub_age_rand_num < (0.6 * parent_age / 30)
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 7,
                        thread_id, thread_rng)
                elseif sub_age_rand_num < (0.8 * parent_age / 30)
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 6,
                        thread_id, thread_rng)
                else
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 5,
                        thread_id, thread_rng)
                end
                # Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                #     sex_random_num < district_people[index, 2], rand(thread_rng[thread_id], 5:9),
                #     thread_id, thread_rng)
            else
                # M10–14
                Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    sex_random_num < district_people[index, 3], rand(thread_rng[thread_id], 10:(parent_age - 16)),
                    thread_id, thread_rng)
            end
        elseif parent_age < 33
            age_group_rand_num = rand(thread_rng[thread_id], Float64)
            if age_group_rand_num < (district_people_households[1, district_household_index] * 32 / parent_age)
                # T0-4_0–14
                if age_rand_num < (district_people[index, 20] * 32 / parent_age)
                    # M0–4
                    Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 1], rand(thread_rng[thread_id], 0:4),
                        thread_id, thread_rng)
                # T0-9_0–14
                elseif age_rand_num < (district_people[index, 21] * 32 / parent_age)
                    # M5–9
                    Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 2], rand(thread_rng[thread_id], 5:9),
                        thread_id, thread_rng)
                else
                    # M10–14
                    Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 3], rand(thread_rng[thread_id], 10:14),
                        thread_id, thread_rng)
                end
            else
                # M15–19
                return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    sex_random_num < district_people[index, 4], rand(thread_rng[thread_id], 15:(parent_age - 16)),
                    thread_id, thread_rng)
            end
        elseif parent_age < 50
            age_group_rand_num = rand(thread_rng[thread_id], Float64)
            if age_group_rand_num < district_people_households[1, district_household_index]
                # T0-4_0–14
                if (age_rand_num < district_people[index, 20])
                    # M0–4
                    Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 1], rand(thread_rng[thread_id], 0:4),
                        thread_id, thread_rng)
                # T0-9_0–14
                elseif (age_rand_num < district_people[index, 21])
                    # M5–9
                    Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 2], rand(thread_rng[thread_id], 5:9),
                        thread_id, thread_rng)
                else
                    # M10–14
                    Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 3], rand(thread_rng[thread_id], 10:14),
                        thread_id, thread_rng)
                end
            else
                # if rand(thread_rng[thread_id], Float64) < 0.39
                #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                #         sex_random_num < district_people[index, 4], 17,
                #         thread_id, thread_rng)
                # elseif rand(thread_rng[thread_id], Float64) < 0.72
                #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                #         sex_random_num < district_people[index, 4], 16,
                #         thread_id, thread_rng)
                # else
                #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                #         sex_random_num < district_people[index, 4], 15,
                #         thread_id, thread_rng)
                # end
                # M15–19
                return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    sex_random_num < district_people[index, 4], rand(thread_rng[thread_id], 15:17),
                    thread_id, thread_rng)
            end


        else
            age_group_rand_num = rand(thread_rng[thread_id], Float64)
            if age_group_rand_num < (district_people_households[1, district_household_index] * 50 / parent_age)
                # T0-4_0–14
                if age_rand_num < (district_people[index, 20] * 50 / parent_age)
                    # M0–4
                    sub_age_rand_num = rand(thread_rng[thread_id], Float64)
                    if sub_age_rand_num < 0.16
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 0,
                            thread_id, thread_rng)
                    elseif sub_age_rand_num < 0.34
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 1,
                            thread_id, thread_rng)
                    elseif sub_age_rand_num < 0.54
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 2,
                            thread_id, thread_rng)
                    elseif sub_age_rand_num < 0.76
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 3,
                            thread_id, thread_rng)
                    else
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 4,
                            thread_id, thread_rng)
                    end


                    # sub_age_rand_num = rand(thread_rng[thread_id], Float64)
                    # if sub_age_rand_num < (0.2 * 50 / parent_age)
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 0,
                    #         thread_id, thread_rng)
                    # elseif sub_age_rand_num < (0.4 * 50 / parent_age)
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 1,
                    #         thread_id, thread_rng)
                    # elseif sub_age_rand_num < (0.6 * 50 / parent_age)
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 2,
                    #         thread_id, thread_rng)
                    # elseif sub_age_rand_num < (0.8 * 50 / parent_age)
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 3,
                    #         thread_id, thread_rng)
                    # else
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 4,
                    #         thread_id, thread_rng)
                    # end


                    # Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #     sex_random_num < district_people[index, 1], rand(thread_rng[thread_id], 0:4),
                    #     thread_id, thread_rng)
                # T0-9_0–14
                elseif age_rand_num < (district_people[index, 21] * 50 / parent_age)
                    # M5–9
                    sub_age_rand_num = rand(thread_rng[thread_id], Float64)
                    if sub_age_rand_num < 0.16
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 5,
                            thread_id, thread_rng)
                    elseif sub_age_rand_num < 0.34
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 6,
                            thread_id, thread_rng)
                    elseif sub_age_rand_num < 0.54
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 7,
                            thread_id, thread_rng)
                    elseif sub_age_rand_num < 0.76
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 8,
                            thread_id, thread_rng)
                    else
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 9,
                            thread_id, thread_rng)
                    end

                    # sub_age_rand_num = rand(thread_rng[thread_id], Float64)
                    # if sub_age_rand_num < (0.2 * 50 / parent_age)
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 5,
                    #         thread_id, thread_rng)
                    # elseif sub_age_rand_num < (0.4 * 50 / parent_age)
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 6,
                    #         thread_id, thread_rng)
                    # elseif sub_age_rand_num < (0.6 * 50 / parent_age)
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 7,
                    #         thread_id, thread_rng)
                    # elseif sub_age_rand_num < (0.8 * 50 / parent_age)
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 8,
                    #         thread_id, thread_rng)
                    # else
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 9,
                    #         thread_id, thread_rng)
                    # end
                    # Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #     sex_random_num < district_people[index, 2], rand(thread_rng[thread_id], 5:9),
                    #     thread_id, thread_rng)
                else
                    # M10–14
                    sub_age_rand_num = rand(thread_rng[thread_id], Float64)
                    if sub_age_rand_num < 0.16
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 10,
                            thread_id, thread_rng)
                    elseif sub_age_rand_num < 0.34
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 11,
                            thread_id, thread_rng)
                    elseif sub_age_rand_num < 0.54
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 12,
                            thread_id, thread_rng)
                    elseif sub_age_rand_num < 0.76
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 13,
                            thread_id, thread_rng)
                    else
                        return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                            sex_random_num < district_people[index, 4], 14,
                            thread_id, thread_rng)
                    end

                    # sub_age_rand_num = rand(thread_rng[thread_id], Float64)
                    # if sub_age_rand_num < (0.2 * 50 / parent_age)
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 10,
                    #         thread_id, thread_rng)
                    # elseif sub_age_rand_num < (0.4 * 50 / parent_age)
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 11,
                    #         thread_id, thread_rng)
                    # elseif sub_age_rand_num < (0.6 * 50 / parent_age)
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 12,
                    #         thread_id, thread_rng)
                    # elseif sub_age_rand_num < (0.8 * 50 / parent_age)
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 13,
                    #         thread_id, thread_rng)
                    # else
                    #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #         sex_random_num < district_people[index, 4], 14,
                    #         thread_id, thread_rng)
                    # end

                    # Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                    #     sex_random_num < district_people[index, 3], rand(thread_rng[thread_id], 10:14),
                    #     thread_id, thread_rng)
                end
            else
                # M15–19
                sub_age_rand_num = rand(thread_rng[thread_id], Float64)
                if sub_age_rand_num < 0.2933
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 15,
                        thread_id, thread_rng)
                elseif sub_age_rand_num < 0.6266
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 16,
                        thread_id, thread_rng)
                else
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 4], 17,
                        thread_id, thread_rng)
                end

                # sub_age_rand_num = rand(thread_rng[thread_id], Float64)
                # if sub_age_rand_num < (0.33 * 50 / parent_age)
                #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                #         sex_random_num < district_people[index, 4], 15,
                #         thread_id, thread_rng)
                # elseif sub_age_rand_num < (0.66 * 50 / parent_age)
                #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                #         sex_random_num < district_people[index, 4], 16,
                #         thread_id, thread_rng)
                # else
                #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                #         sex_random_num < district_people[index, 4], 17,
                #         thread_id, thread_rng)
                # end

                # return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                #     sex_random_num < district_people[index, 4], rand(thread_rng[thread_id], 15:17),
                #     thread_id, thread_rng)
            end
        end


        # elseif parent_age < 60
        #     age_group_rand_num = rand(thread_rng[thread_id], Float64)
        #     if age_group_rand_num < district_people_households[1, district_household_index]
        #         # T0-4_0–14
        #         if (age_rand_num < district_people[index, 20])
        #             # M0–4
        #             Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
        #                 sex_random_num < district_people[index, 1], rand(thread_rng[thread_id], (parent_age - 55):4),
        #                 thread_id, thread_rng)
        #         # T0-9_0–14
        #         elseif (age_rand_num < district_people[index, 21])
        #             # M5–9
        #             Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
        #                 sex_random_num < district_people[index, 2], rand(thread_rng[thread_id], 5:9),
        #                 thread_id, thread_rng)
        #         else
        #             # M10–14
        #             Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
        #                 sex_random_num < district_people[index, 3], rand(thread_rng[thread_id], 10:14),
        #                 thread_id, thread_rng)
        #         end
        #     else
        #         # M15–19
        #         return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
        #             sex_random_num < district_people[index, 4], rand(thread_rng[thread_id], 15:17),
        #             thread_id, thread_rng)
        #     end
        # elseif parent_age < 65
        #     age_group_rand_num = rand(thread_rng[thread_id], Float64)
        #     if age_group_rand_num < district_people_households[1, district_household_index]
        #         # T5-9_5–14
        #         if rand(thread_rng[thread_id], Float64) < 0.5
        #             # M5–9
        #             Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
        #                 sex_random_num < district_people[index, 2], rand(thread_rng[thread_id], (parent_age - 55):9),
        #                 thread_id, thread_rng)
        #         else
        #             # M10–14
        #             Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
        #                 sex_random_num < district_people[index, 3], rand(thread_rng[thread_id], 10:14),
        #                 thread_id, thread_rng)
        #         end
        #     else
        #         # M15–19
        #         return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
        #             sex_random_num < district_people[index, 4], rand(thread_rng[thread_id], 15:17),
        #             thread_id, thread_rng)
        #     end
        # elseif parent_age < 70
        #     age_group_rand_num = rand(thread_rng[thread_id], Float64)
        #     if age_group_rand_num < district_people_households[1, district_household_index]
        #         # M10–14
        #         Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
        #                 sex_random_num < district_people[index, 3], rand(thread_rng[thread_id], (parent_age - 55):14),
        #                 thread_id, thread_rng)
        #     else
        #         # M15–19
        #         return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
        #             sex_random_num < district_people[index, 4], rand(thread_rng[thread_id], 15:17),
        #             thread_id, thread_rng)
        #     end
        # elseif parent_age < 73
        #     return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
        #         sex_random_num < district_people[index, 4], rand(thread_rng[thread_id], (parent_age - 55):17),
        #         thread_id, thread_rng)
        # else
        #     age_group_rand_num = rand(thread_rng[thread_id], Float64)
        #     if age_group_rand_num < district_people_households[1, district_household_index]
        #         # T0-4_0–14
        #         if (age_rand_num < district_people[index, 20])
        #             # M0–4
        #             Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
        #                 sex_random_num < district_people[index, 1], rand(thread_rng[thread_id], 0:4),
        #                 thread_id, thread_rng)
        #         # T0-9_0–14
        #         elseif (age_rand_num < district_people[index, 21])
        #             # M5–9
        #             Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
        #                 sex_random_num < district_people[index, 2], rand(thread_rng[thread_id], 5:9),
        #                 thread_id, thread_rng)
        #         else
        #             # M10–14
        #             Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
        #                 sex_random_num < district_people[index, 3], rand(thread_rng[thread_id], 10:14),
        #                 thread_id, thread_rng)
        #         end
        #     else
        #         # M15–19
        #         return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
        #             sex_random_num < district_people[index, 4], rand(thread_rng[thread_id], 15:17),
        #             thread_id, thread_rng)
        #     end
        # end
    else
        # age_group_rand_num = 0.0
        # if is_older
        #     age_group_rand_num = rand(thread_rng[thread_id], Uniform(district_people_households[3, district_household_index], 1.0))
        # elseif parent_age !== nothing
        #     if parent_age < 40
        #         age_group_rand_num = 0.001
        #     elseif parent_age < 50
        #         age_group_rand_num = rand(thread_rng[thread_id], Uniform(0.0, district_people_households[3, district_household_index]))
        #     elseif parent_age < 60
        #         age_group_rand_num = rand(thread_rng[thread_id], Uniform(0.0, district_people_households[4, district_household_index]))
        #     else
        #         age_group_rand_num = rand(thread_rng[thread_id], Uniform(0.0, district_people_households[5, district_household_index]))
        #     end
        # elseif is_parent_of_parent
        #     if parent_age < 25
        #         age_group_rand_num = rand(thread_rng[thread_id], Uniform(district_people_households[3, district_household_index], 1.0))
        #     elseif parent_age < 35
        #         age_group_rand_num = rand(thread_rng[thread_id], Uniform(district_people_households[4, district_household_index], 1.0))
        #     elseif parent_age < 45
        #         age_group_rand_num = rand(thread_rng[thread_id], Uniform(district_people_households[5, district_household_index], 1.0))
        #     else
        #         age_group_rand_num = 0.999
        #     end
        # else
        #     age_group_rand_num = rand(thread_rng[thread_id], Float64)
        # end
        age_group_rand_num = 0.0
        if is_older
            age_group_rand_num = rand(thread_rng[thread_id], Uniform(district_people_households[3, district_household_index], 1.0))
        elseif parent_age !== nothing
            if parent_age < 40
                age_group_rand_num = 0.001
            elseif parent_age < 50
                age_group_rand_num = rand(thread_rng[thread_id], Uniform(0.0, district_people_households[3, district_household_index]))
            elseif parent_age < 60
                age_group_rand_num = rand(thread_rng[thread_id], Uniform(0.0, district_people_households[4, district_household_index]))
            else
                age_group_rand_num = rand(thread_rng[thread_id], Uniform(0.0, district_people_households[5, district_household_index]))
            end
        elseif is_parent_of_parent
            if parent_age < 25
                age_group_rand_num = rand(thread_rng[thread_id], Uniform(district_people_households[3, district_household_index], 1.0))
            elseif parent_age < 35
                age_group_rand_num = rand(thread_rng[thread_id], Uniform(district_people_households[4, district_household_index], 1.0))
            elseif parent_age < 45
                age_group_rand_num = rand(thread_rng[thread_id], Uniform(district_people_households[5, district_household_index], 1.0))
            else
                age_group_rand_num = 0.999
            end
        else
            age_group_rand_num = rand(thread_rng[thread_id], Float64)
        end

        if age_group_rand_num < district_people_households[2, district_household_index]
            if rand(thread_rng[thread_id], Float64) < 0.25
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 18:19),
                        thread_id, thread_rng)
                else
                    # M20–24
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 5], rand(thread_rng[thread_id], 18:19),
                        thread_id, thread_rng)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 20:24),
                        thread_id, thread_rng)
                else
                    # M20–24
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 5], rand(thread_rng[thread_id], 20:24),
                        thread_id, thread_rng)
                end
            end
        elseif age_group_rand_num < district_people_households[3, district_household_index]
            # T25-29_25–34
            if age_rand_num < district_people[index, 22]
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 25:29),
                        thread_id, thread_rng)
                else
                    # M25–29
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 6], rand(thread_rng[thread_id], 25:29),
                        thread_id, thread_rng)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 30:34),
                        thread_id, thread_rng)
                else
                    # M30–34
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 7], rand(thread_rng[thread_id], 30:34),
                        thread_id, thread_rng)
                end
            end
        elseif age_group_rand_num < district_people_households[4, district_household_index]
            # T35-39_35–44
            if age_rand_num < district_people[index, 23]
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 35:39),
                        thread_id, thread_rng)
                else
                    # M35–39
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 8], rand(thread_rng[thread_id], 35:39),
                        thread_id, thread_rng)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 40:44),
                        thread_id, thread_rng)
                else
                    # M40–44
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 9], rand(thread_rng[thread_id], 40:44),
                        thread_id, thread_rng)
                end
            end
        elseif age_group_rand_num < district_people_households[5, district_household_index]
            # T45-49_45–54
            if age_rand_num < district_people[index, 24]
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 45:49),
                        thread_id, thread_rng)
                else
                    # M45–49
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 10], rand(thread_rng[thread_id], 45:49),
                        thread_id, thread_rng)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 50:54),
                        thread_id, thread_rng)
                else
                    # M50–54
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 11], rand(thread_rng[thread_id], 50:54),
                        thread_id, thread_rng)
                end
            end
        elseif age_group_rand_num < district_people_households[6, district_household_index]
            # T55-59_55–64
            if age_rand_num < district_people[index, 25]
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 55:59),
                        thread_id, thread_rng)
                else
                    # M55–59
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 12], rand(thread_rng[thread_id], 55:59),
                        thread_id, thread_rng)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 60:64),
                        thread_id, thread_rng)
                else
                    # M60–64
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 13], rand(thread_rng[thread_id], 60:64),
                        thread_id, thread_rng)
                end
            end
        else
            # T65-69_65–89
            if age_rand_num < district_people[index, 26]
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 65:69),
                        thread_id, thread_rng)
                else
                    # M65–69
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 14], rand(thread_rng[thread_id], 65:69),
                        thread_id, thread_rng)
                end
            # T65-74_65–89
            elseif age_rand_num < district_people[index, 27]
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 70:74),
                        thread_id, thread_rng)
                else
                    # M70–74
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 15], rand(thread_rng[thread_id], 70:74),
                        thread_id, thread_rng)
                end
            # T65-79_65–89
            elseif age_rand_num < district_people[index, 28]
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 75:79),
                        thread_id, thread_rng)
                else
                    # M75–79
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 16], rand(thread_rng[thread_id], 75:79),
                        thread_id, thread_rng)
                end
            # T65-84_65–89
            elseif age_rand_num < district_people[index, 29]
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 80:84),
                        thread_id, thread_rng)
                else
                    # M80–84
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 17], rand(thread_rng[thread_id], 80:84),
                        thread_id, thread_rng)
                end
            else
                if is_male !== nothing
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, is_male, rand(thread_rng[thread_id], 85:89),
                        thread_id, thread_rng)
                else
                    # M85–89
                    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids,
                        sex_random_num < district_people[index, 18], rand(thread_rng[thread_id], 85:89),
                        thread_id, thread_rng)
                end
            end
        end
    end
end

function create_spouse(
    agent_id::Int,
    household_id::Int,
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
    household_conn_ids::Vector{Int},
    partner_age::Int,
    thread_id::Int,
    thread_rng::Vector{MersenneTwister},
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
        spouse_age = partner_age - difference
    end

    return Agent(agent_id, household_id, viruses, infectivities, household_conn_ids, true, spouse_age,
        thread_id, thread_rng)
end

function check_parent_leave(no_one_at_home::Bool, adult::Agent, child::Agent)
    if child.age <= 13
        child.supporter_id = adult.id
        push!(adult.dependant_ids, child.id)
        if no_one_at_home
            child.needs_supporter_care = true
            if child.age <= 3 && child.activity_type == 0
                adult.activity_type = 0
            end
        end
    end
end

function create_parents_with_children(
    agent_id::Int,
    household_id::Int,
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
    household_conn_ids::Vector{Int},
    district_people::Matrix{Float64},
    district_people_households::Matrix{Float64},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int,
    thread_id::Int,
    thread_rng::Vector{MersenneTwister},
    is_old_pair::Bool = false,
)::Vector{Agent}
    agent_female = create_agent(
        agent_id, household_id, viruses,
        infectivities, household_conn_ids, index,
        district_people, district_people_households,
        district_household_index, thread_id, thread_rng,
        false, false, nothing, is_old_pair)
    agent_id += 1
    agent_male = create_spouse(
        agent_id, household_id, viruses, infectivities,
        household_conn_ids, agent_female.age, thread_id, thread_rng)
    agent_id += 1
    if num_of_other_people == 0
        if num_of_children > 0
            child = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, child]
            end
            child2 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, child, child2]
            end
            child3 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age + 2)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, child, child2, child3]
        end
        return Agent[agent_male, agent_female]
    elseif num_of_other_people == 1
        agent_other = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, child]
            end
            child2 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, child, child2]
            end
            child3 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age + 2)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other]
    elseif num_of_other_people == 2
        agent_other = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, agent_other2, child]
            end
            child2 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, child, child2]
            end
            child3 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age + 2)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other3 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0 || agent_other3.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child]
            end
            child2 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age + 2)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3]
    else
        agent_other = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other3 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other4 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age)
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
            child2 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, agent_female.age + 2)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4]
    end
end

function create_parent_with_children(
    agent_id::Int,
    household_id::Int,
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
    household_conn_ids::Vector{Int},
    district_people::Matrix{Float64},
    district_people_households::Matrix{Float64},
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int,
    thread_id::Int,
    thread_rng::Vector{MersenneTwister},
    is_male_parent::Union{Bool, Nothing},
    with_parent_of_parent::Bool = false,
)::Vector{Agent}
    parent = create_agent(agent_id, household_id,
        viruses, infectivities, household_conn_ids, index,
        district_people, district_people_households,
        district_household_index,
        thread_id, thread_rng, is_male_parent,
        false, nothing, num_of_other_people > 0)
    agent_id += 1
    if num_of_other_people == 0
        child = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing, true, parent.age)
        agent_id += 1
        no_one_at_home = parent.activity_type != 0
        check_parent_leave(no_one_at_home, parent, child)
        if num_of_children == 1
            return Agent[parent, child]
        end
        child2 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing, true, parent.age + 1)

        agent_id += 1
        check_parent_leave(no_one_at_home, parent, child2)
        if num_of_children == 2
            return Agent[parent, child, child2]
        end
        child3 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing, true, parent.age + 2)
        check_parent_leave(no_one_at_home, parent, child3)
        return Agent[parent, child, child2, child3]
    elseif num_of_other_people == 1
        agent_other = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, parent.age)
            agent_id += 1
            no_one_at_home = parent.activity_type != 0
            if agent_other.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, child]
            end
            child2 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, parent.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, child, child2]
            end
            child3 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, parent.age + 2)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, child, child2, child3]
        end
        return Agent[parent, agent_other]
    elseif num_of_other_people == 2
        agent_other = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        agent_other2 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing,
            false, parent.age)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, parent.age)
            agent_id += 1
            no_one_at_home = parent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, agent_other2, child]
            end
            child2 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, parent.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, child, child2]
            end
            child3 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, parent.age + 2)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        agent_other2 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing,
            false, parent.age)
        agent_id += 1
        agent_other3 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing,
            false, parent.age)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, parent.age)
            agent_id += 1
            no_one_at_home = parent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0 || agent_other3.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, agent_other2, agent_other3, child]
            end
            child2 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, parent.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, parent.age + 2)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2, agent_other3]
    else
        agent_other = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing, false,
            parent.age, false, with_parent_of_parent)
        agent_id += 1
        agent_other2 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing,
            false, parent.age)
        agent_id += 1
        agent_other3 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing,
            false, parent.age)
        agent_id += 1
        agent_other4 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households,
            district_household_index,
            thread_id, thread_rng, nothing,
            false, parent.age)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, parent.age)
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
            child2 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, parent.age + 1)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, parent.age + 2)
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
    agent = create_agent(agent_id, household_id,
        viruses, infectivities, household_conn_ids, index,
        district_people, district_people_households, district_household_index,
        thread_id, thread_rng)
    agent_id += 1
    if num_of_other_people == 0
        if num_of_children > 0
            child = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
            agent_id += 1
            no_one_at_home = agent.activity_type != 0
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, child]
            end
            child2 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, child, child2]
            end
            child3 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, child, child2, child3]
        end
        return Agent[agent]
    elseif num_of_other_people == 1
        agent_other = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
            agent_id += 1
            no_one_at_home = agent.activity_type != 0
            if agent_other.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, agent_other, child]
            end
            child2 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, child, child2]
            end
            child3 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, child, child2, child3]
        end
        return Agent[agent, agent_other]
    elseif num_of_other_people == 2
        agent_other = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
            agent_id += 1
            no_one_at_home = agent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, agent_other, agent_other2, child]
            end
            child2 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, child, child2]
            end
            child3 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other3 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
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
            child2 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2, agent_other3]
    elseif num_of_other_people == 4
        agent_other = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other3 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other4 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        if num_of_children > 0
            child = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
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
            child2 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3 = create_agent(
                agent_id, household_id,
                viruses, infectivities, household_conn_ids, index,
                district_people, district_people_households,
                district_household_index,
                thread_id, thread_rng, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4]
    else
        agent_other = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other2 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other3 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other4 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
            thread_id, thread_rng)
        agent_id += 1
        agent_other5 = create_agent(
            agent_id, household_id,
            viruses, infectivities, household_conn_ids, index,
            district_people, district_people_households, district_household_index,
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
    kindergartens::Vector{School},
    schools::Vector{School},
    viruses::Vector{Virus},
    infectivities::Array{Float64, 4},
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
            is_child = rand(thread_rng[thread_id], Float64) < 0.0123
            agent = create_agent(
                    agent_id, household_id, viruses, infectivities, household.agent_ids, index, district_people,
                    district_people_households, index_for_1_people, thread_id,
                    thread_rng, nothing, is_child, is_child ? 70 : nothing)
            all_agents[agent.id] = agent
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 0, 0, index,
                thread_id, thread_rng)
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 0, 1, index,
                thread_id, thread_rng)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 1, 0, index,
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 2, index,
                thread_id, thread_rng)
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 1, index,
                thread_id, thread_rng)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 3, index,
                thread_id, thread_rng)
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 1, 2, index,
                thread_id, thread_rng)
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 2, 1, index,
                thread_id, thread_rng)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 4, index,
                thread_id, thread_rng)
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 1, 3, index,
                thread_id, thread_rng)
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 2, 2, index,
                thread_id, thread_rng)
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 3, 1, index,
                thread_id, thread_rng)
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 0, index,
                thread_id, thread_rng)
            agent_id += 2
            agents2 = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 0, index,
                thread_id, thread_rng, true)
            append!(agents, agents2)
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 1, index,
                thread_id, thread_rng)
            agent_id += 3
            agents2 = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 0, index,
                thread_id, thread_rng, true)
            append!(agents, agents2)
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 1, 0, index,
                thread_id, thread_rng)
            agent_id += 3
            agents2 = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 0, index,
                thread_id, thread_rng, true)
            append!(agents, agents2)
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 2, index,
                thread_id, thread_rng)
            agent_id += 4
            agents2 = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 0, index,
                thread_id, thread_rng, true)
            append!(agents, agents2)
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 1, 1, index,
                thread_id, thread_rng)
            agent_id += 4
            agents2 = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 0, index,
                thread_id, thread_rng, true)
            append!(agents, agents2)
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
            agents = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 2, 0, index,
                thread_id, thread_rng)
            agent_id += 4
            agents2 = create_parents_with_children(
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 0, index,
                thread_id, thread_rng, true)
            append!(agents, agents2)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, thread_rng, nothing, true)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, thread_rng, nothing, true)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index,
                thread_id, thread_rng, nothing, true)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index,
                thread_id, thread_rng, nothing, true)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index,
                thread_id, thread_rng, nothing, true)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index,
                thread_id, thread_rng, nothing, true)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index,
                thread_id, thread_rng, nothing, true)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index,
                thread_id, thread_rng, nothing, true)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index,
                thread_id, thread_rng, nothing, true)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index,
                thread_id, thread_rng, nothing, true)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 4, index,
                thread_id, thread_rng, nothing, true)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 1, 3, index,
                thread_id, thread_rng, nothing, true)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 2, 2, index,
                thread_id, thread_rng, nothing, true)
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
                agent_id, household_id, viruses, infectivities, household.agent_ids, district_people,
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
