function simulate_contacts_evaluation(
    thread_id::Int,
    rng::MersenneTwister,
    start_agent_id::Int,
    end_agent_id::Int,
    agents::Vector{Agent},
    households::Vector{Household},
    kindergartens::Vector{School},
    schools::Vector{School},
    colleges::Vector{School},
    mean_household_contact_durations::Vector{Float64},
    household_contact_duration_sds::Vector{Float64},
    other_contact_duration_shapes::Vector{Float64},
    other_contact_duration_scales::Vector{Float64},
    is_holiday::Bool,
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_college_holiday::Bool,
    is_work_holiday::Bool,
    contacts_num_matrix_by_age_threads::Array{Int, 3},
    contacts_dur_matrix_by_age_threads::Array{Float64, 3},
    contacts_num_matrix_by_age_activities_threads::Array{Int, 4},
    contacts_dur_matrix_by_age_activities_threads::Array{Float64, 4},
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]

        # --------------------------TBD ZONE-----------------------------------

        # # Агент посещает чужое домохозяйство
        # if agent.visit_household_id != 0
        #     for agent2_id in households[agent.visit_household_id].agent_ids
        #         agent2 = agents[agent2_id]
        #         # Проверка восприимчивости агента к вирусу
        #         if agent2.visit_household_id == 0
        #             dur = 0.0
        #             if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
        #                 (agent.activity_type == 3 && is_college_holiday) ||
        #                 (agent.activity_type == 2 && is_school_holiday) ||
        #                 (agent.activity_type == 1 && is_kindergarten_holiday)) &&
        #                 (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
        #                 (agent2.activity_type == 3 && is_college_holiday) ||
        #                 (agent2.activity_type == 2 && is_school_holiday) ||
        #                 (agent2.activity_type == 1 && is_kindergarten_holiday))

        #                 dur = get_contact_duration_normal(0.95, 0.2, rng)
        #             else
        #                 dur = get_contact_duration_normal(0.42, 0.1, rng)
        #             end
        #             if dur > 0.01
        #                 contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
        #                 contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
        #                 contacts_num_matrix_by_age_threads[thread_id, agent2.age + 1, agent.age + 1] += 1
        #                 contacts_dur_matrix_by_age_threads[thread_id, agent2.age + 1, agent.age + 1] += dur
        #                 contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 6] += 1
        #                 contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 6] += dur
        #                 contacts_num_matrix_by_age_activities_threads[thread_id, agent2.age + 1, agent.age + 1, 6] += 1
        #                 contacts_dur_matrix_by_age_activities_threads[thread_id, agent2.age + 1, agent.age + 1, 6] += dur
        #             end
        #         end
        #     end
        # end

        # -------------------------------------------------------------

        # Контакты в домохозяйстве
        for agent2_id in agent.household_conn_ids
            agent2 = agents[agent2_id]
            if agent2_id != agent_id
                dur = 0.0
                if is_holiday || ((agent.activity_type == 0 ||
                    (agent.activity_type == 4 && is_work_holiday) || (agent.activity_type == 3 && is_college_holiday) ||
                    (agent.activity_type == 2 && is_school_holiday) || (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                    (agent2.activity_type == 0 ||
                    (agent2.activity_type == 4 && is_work_holiday) || (agent2.activity_type == 3 && is_college_holiday) ||
                    (agent2.activity_type == 2 && is_school_holiday) || (agent2.activity_type == 1 && is_kindergarten_holiday)))

                    dur = get_contact_duration_normal(mean_household_contact_durations[5], household_contact_duration_sds[5], rng)
                elseif ((agent.activity_type == 4) ||
                    (agent2.activity_type == 4)) && !is_work_holiday

                    dur = get_contact_duration_normal(mean_household_contact_durations[4], household_contact_duration_sds[4], rng)
                elseif ((agent.activity_type == 2) ||
                    (agent2.activity_type == 2)) && !is_school_holiday

                    dur = get_contact_duration_normal(mean_household_contact_durations[2], household_contact_duration_sds[2], rng)
                elseif ((agent.activity_type == 1) ||
                    (agent2.activity_type == 1)) && !is_kindergarten_holiday
                    
                    dur = get_contact_duration_normal(mean_household_contact_durations[1], household_contact_duration_sds[1], rng)
                else
                    dur = get_contact_duration_normal(mean_household_contact_durations[3], household_contact_duration_sds[3], rng)
                end

                # --------------------------TBD ZONE-----------------------------------

                # if (agent.visit_household_id != 0 || agent2.visit_household_id != 0) &&
                #     (agent.visit_household_id != agent2.visit_household_id)
                    
                #     dur -= 1.25
                # end

                # if agent.restaurant_time != 0 || agent2.restaurant_time != 0
                #     dur -= 0.75
                # end
                # if agent.shopping_time != 0 || agent2.shopping_time != 0
                #     dur -= 0.75
                # end

                # -------------------------------------------------------------

                if dur > 0.01
                    contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                    contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 5] += 1
                    contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 5] += dur
                end
            end
        end
        # Контакты в остальных коллективах
        if agent.attendance &&
            ((agent.activity_type == 1 && !is_kindergarten_holiday) ||
            (agent.activity_type == 2 && !is_school_holiday) ||
            (agent.activity_type == 3 && !is_college_holiday) ||
            (agent.activity_type == 4 && !is_work_holiday))

            for agent2_id in agent.activity_conn_ids
                agent2 = agents[agent2_id]
                if agent2.attendance && agent2_id != agent_id
                    dur = 0.0
                    if agent.activity_type == 1
                        dur = get_contact_duration_gamma(other_contact_duration_shapes[1], other_contact_duration_scales[1], rng)
                    elseif agent.activity_type == 2
                        # if rand(rng, Float64) < 0.4
                        dur = get_contact_duration_gamma(other_contact_duration_shapes[2], other_contact_duration_scales[2], rng)
                        # end
                    elseif agent.activity_type == 3
                        dur = get_contact_duration_gamma(other_contact_duration_shapes[3], other_contact_duration_scales[3], rng)
                    else
                        dur = get_contact_duration_gamma(other_contact_duration_shapes[3], other_contact_duration_scales[3], rng)
                    end

                    if dur > 0.01
                        contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += 1
                        contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += dur
                    end
                end
            end

            if agent.is_teacher
                num_contacts = 0
                if agent.activity_type == 1
                    while num_contacts < school_num_of_teacher_contacts && num_contacts < length(kindergartens[agent.school_id].teacher_ids)
                        teacher_id = rand(kindergartens[agent.school_id].teacher_ids)
                        if teacher_id != agent.id
                            agent2 = agents[teacher_id]
                            dur = get_contact_duration_gamma(other_contact_duration_shapes[5], other_contact_duration_scales[5], rng)
                            if dur > 0.01
                                contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                                contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += 1
                                contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += dur
                            end
                            num_contacts += 1
                        end
                    end
                elseif agent.activity_type == 2
                    while num_contacts < school_num_of_teacher_contacts && num_contacts < length(schools[agent.school_id].teacher_ids)
                        teacher_id = rand(schools[agent.school_id].teacher_ids)
                        if teacher_id != agent.id
                            agent2 = agents[teacher_id]
                            dur = get_contact_duration_gamma(other_contact_duration_shapes[5], other_contact_duration_scales[5], rng)
                            if dur > 0.01
                                contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                                contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += 1
                                contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += dur
                            end
                            num_contacts += 1
                        end
                    end
                elseif agent.activity_type == 3
                    while num_contacts < school_num_of_teacher_contacts && num_contacts < length(colleges[agent.school_id].teacher_ids)
                        teacher_id = rand(colleges[agent.school_id].teacher_ids)
                        if teacher_id != agent.id
                            agent2 = agents[teacher_id]
                            dur = get_contact_duration_gamma(other_contact_duration_shapes[5], other_contact_duration_scales[5], rng)
                            if dur > 0.01
                                contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                                contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += 1
                                contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += dur
                            end
                            num_contacts += 1
                        end
                    end
                end
            end

            # Контакты между университетскими группами
            if agent.activity_type == 3
                for agent2_id in agent.activity_cross_conn_ids
                    agent2 = agents[agent2_id]
                    if agent2.attendance && !agent2.is_teacher && rand(rng, Float64) < 0.25
                        dur = get_contact_duration_gamma(other_contact_duration_shapes[5], other_contact_duration_scales[5], rng)
                        if dur > 0.01
                            contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += 1
                            contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += dur
                        end
                    end
                end
            end
        end
    end
end

# --------------------------TBD ZONE-----------------------------------

# function add_agent_to_public_space_evaluation(
#     agent::Agent,
#     rng::MersenneTwister,
#     agents::Vector{Agent},
#     households::Vector{Household},
#     public_spaces::Vector{PublicSpace},
#     closest_public_space_id1::Int,
#     closest_public_space_id2::Int,
#     is_kindergarten_holiday::Bool,
#     is_school_holiday::Bool,
#     is_college_holiday::Bool,
#     is_work_holiday::Bool,
#     restaurant_visit_time_distribution::MixtureModel,
#     shop_visit_time_distribution::MixtureModel,
#     is_shopping::Bool,
# )
#     space_found = false
#     selected_time = 0
#     for agent2_id in households[agent.household_id].agent_ids
#         agent2 = agents[agent2_id]
#         if is_shopping && agent2.shopping_time != 0 && rand(rng, Float64) < prob_shopping_together
#             selected_time = agent2.shopping_time
#         elseif !is_shopping && agent2.restaurant_time != 0 && rand(rng, Float64) < prob_restaurant_together
#             selected_time = agent2.restaurant_time
#         end
#     end
#     if selected_time == 0
#         if is_shopping
#             selected_time = round(Int, rand(rng, shop_visit_time_distribution))
#             if selected_time > shop_num_groups
#                 selected_time = shop_num_groups
#             end
#         else
#             selected_time = round(Int, rand(rng, restaurant_visit_time_distribution))
#             if selected_time > restaurant_num_groups
#                 selected_time = restaurant_num_groups
#             end
#         end
#         if selected_time < 1
#             selected_time = 1
#         end
#     end
#     # if agent.activity_type == 4 && !is_work_holiday && selected_time < 11
#     #     closest_public_space_id1 = workplace.closest_public_space_id1
#     # end
#     group = public_spaces[closest_public_space_id1].groups[selected_time]
#     if group.num_agents < length(group.agent_ids)
#         group.num_agents += 1
#         group.agent_ids[group.num_agents] = agent.id
#         if is_shopping
#             agent.shopping_time = selected_time
#         else
#             agent.restaurant_time = selected_time
#         end
#         if group.num_agents < length(group.agent_ids)
#             for agent2_id in agent.dependant_ids
#                 agent2 = agents[agent2_id]
#                 if (agent2.needs_supporter_care && length(households[agent.household_id].agent_ids) == length(agent.dependant_ids) + 1) || rand(rng, Float64) < 1 / (2 * length(agent.dependant_ids))
#                     group.num_agents += 1
#                     group.agent_ids[group.num_agents] = agent2_id
#                     if is_shopping
#                         agent2.shopping_time = selected_time
#                     else
#                         agent2.restaurant_time = selected_time
#                     end
#                     if group.num_agents == length(group.agent_ids)
#                         break
#                     end
#                 end
#             end
#         end
#         space_found = true
#     end
#     if !space_found && closest_public_space_id1 != closest_public_space_id2
#         group = public_spaces[closest_public_space_id2].groups[selected_time]
#         if group.num_agents < length(group.agent_ids)
#             group.num_agents += 1
#             group.agent_ids[group.num_agents] = agent.id
#             if is_shopping
#                 agent.shopping_time = selected_time
#             else
#                 agent.restaurant_time = selected_time
#             end
#             if group.num_agents < length(group.agent_ids)
#                 for agent2_id in agent.dependant_ids
#                     agent2 = agents[agent2_id]
#                     if (agent2.needs_supporter_care && length(households[agent.household_id].agent_ids) == length(agent.dependant_ids) + 1) || rand(rng, Float64) < 1 / (2 * length(agent.dependant_ids))
#                         group.num_agents += 1
#                         group.agent_ids[group.num_agents] = agent2_id
#                         if is_shopping
#                             agent2.shopping_time = selected_time
#                         else
#                             agent2.restaurant_time = selected_time
#                         end
#                         if group.num_agents == length(group.agent_ids)
#                             break
#                         end
#                     end
#                 end
#             end
#         end
#     end
# end

# function add_additional_connections_each_step_evaluation(
#     rng::MersenneTwister,
#     start_agent_id::Int,
#     end_agent_id::Int,
#     agents::Vector{Agent},
#     households::Vector{Household},
#     shops::Vector{PublicSpace},
#     restaurants::Vector{PublicSpace},
#     is_kindergarten_holiday::Bool,
#     is_school_holiday::Bool,
#     is_college_holiday::Bool,
#     is_work_holiday::Bool,
#     restaurant_visit_time_distribution::MixtureModel,
#     shop_visit_time_distribution::MixtureModel,
# )
#     for agent_id in start_agent_id:end_agent_id
#         agent = agents[agent_id]
#         agent.visit_household_id = 0
#         agent.shopping_time = 0
#         agent.restaurant_time = 0
#     end
#     for agent_id in start_agent_id:end_agent_id
#         agent = agents[agent_id]
#         if agent.age >= 12
#             if agent.visit_household_id == 0
#                 prob = 0.0
#                 if agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
#                     (agent.activity_type == 3 && is_college_holiday) ||
#                     (agent.activity_type == 2 && is_school_holiday) ||
#                     (agent.activity_type == 1 && is_kindergarten_holiday)

#                     prob = 0.269
#                 else
#                     prob = 0.177
#                 end
#                 if rand(rng, Float64) < prob
#                     if length(agent.friend_ids) > 0
#                         agent_to_visit = agents[rand(rng, agent.friend_ids)]
#                         agent.visit_household_id = agent_to_visit.household_id
#                         for agent2_id in agent.dependant_ids
#                             agent2 = agents[agent2_id]
#                             if (agent2.needs_supporter_care && length(households[agent.household_id].agent_ids) == length(agent.dependant_ids) + 1) || rand(rng, Float64) < 1 / (2 * length(agent.dependant_ids))
#                                 agent2.visit_household_id = agent.visit_household_id
#                             end
#                         end
#                     end
#                 end
#             end

#             prob = 0.0
#             if agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
#                 (agent.activity_type == 3 && is_college_holiday) ||
#                 (agent.activity_type == 2 && is_school_holiday) ||
#                 (agent.activity_type == 1 && is_kindergarten_holiday)

#                 prob = 0.354
#             else
#                 prob = 0.291
#             end
#             if agent.activity_type != 5 && rand(rng, Float64) < prob
#                 add_agent_to_public_space_evaluation(
#                     agent,
#                     rng,
#                     agents,
#                     households,
#                     shops,
#                     households[agent.household_id].closest_shop_id,
#                     households[agent.household_id].closest_shop_id2,
#                     is_kindergarten_holiday,
#                     is_school_holiday,
#                     is_college_holiday,
#                     is_work_holiday,
#                     restaurant_visit_time_distribution,
#                     shop_visit_time_distribution,
#                     true,
#                 )
#             end

#             if agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
#                 (agent.activity_type == 3 && is_college_holiday) ||
#                 (agent.activity_type == 2 && is_school_holiday) ||
#                 (agent.activity_type == 1 && is_kindergarten_holiday)

#                 prob = 0.295
#             else
#                 prob = 0.255
#             end
#             if agent.activity_type != 6 && rand(rng, Float64) < prob
#                 add_agent_to_public_space_evaluation(
#                     agent,
#                     rng,
#                     agents,
#                     households,
#                     restaurants,
#                     households[agent.household_id].closest_restaurant_id,
#                     households[agent.household_id].closest_restaurant_id2,
#                     is_kindergarten_holiday,
#                     is_school_holiday,
#                     is_college_holiday,
#                     is_work_holiday,
#                     restaurant_visit_time_distribution,
#                     shop_visit_time_distribution,
#                     false,
#                 )
#             end
#         end
#     end
# end

# function simulate_public_space_contacts_evaluation(
#     thread_id::Int,
#     rng::MersenneTwister,
#     agents::Vector{Agent},
#     households::Vector{Household},
#     start_public_space_id::Int,
#     end_public_space_id::Int,
#     public_spaces::Vector{PublicSpace},
#     mean_num_contacts_in_public_space::Int,
#     mean_contact_time_weekday::Float64,
#     contact_time_sd_weekday::Float64,
#     mean_contact_time_holiday::Float64,
#     contact_time_sd_holiday::Float64,
#     is_kindergarten_holiday::Bool,
#     is_school_holiday::Bool,
#     is_college_holiday::Bool,
#     is_work_holiday::Bool,
#     contacts_num_matrix_by_age_threads::Array{Int, 3},
#     contacts_dur_matrix_by_age_threads::Array{Float64, 3},
#     contacts_num_matrix_by_age_activities_threads::Array{Int, 4},
#     contacts_dur_matrix_by_age_activities_threads::Array{Float64, 4},
#     is_shopping::Bool,
# )
#     for public_space_id in start_public_space_id:end_public_space_id
#         public_space = public_spaces[public_space_id]
#         for group_id in 1:length(public_space.groups)
#             group = public_space.groups[group_id]
#             for agent_num in 1:group.num_agents
#                 agent_id = group.agent_ids[agent_num]
#                 agent = agents[agent_id]
#                 household_members = 0
#                 for agent2_id in households[agent.household_id].agent_ids
#                     agent2 = agents[agent2_id]
#                     if is_shopping && agent2.shopping_time == agent.shopping_time
#                         household_members += 1
#                     elseif !is_shopping && agent2.restaurant_time == agent.restaurant_time
#                         household_members += 1
#                     end
#                 end
#                 # Контакты посетителей друг с другом
#                 for agent2_num in (agent_num + 1):group.num_agents
#                     agent2_id = group.agent_ids[agent2_num]
#                     agent2 = agents[agent2_id]
#                     if agent2_id in households[agent.household_id].agent_ids || rand(rng, Float64) < ((mean_num_contacts_in_public_space - household_members) / group.num_agents)
#                         dur = 0.0
#                         if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
#                             (agent.activity_type == 3 && is_college_holiday) ||
#                             (agent.activity_type == 2 && is_school_holiday) ||
#                             (agent.activity_type == 1 && is_kindergarten_holiday)) &&
#                             (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
#                             (agent2.activity_type == 3 && is_college_holiday) ||
#                             (agent2.activity_type == 2 && is_school_holiday) ||
#                             (agent2.activity_type == 1 && is_kindergarten_holiday))

#                             dur = get_contact_duration_normal(0.44, 0.1, rng)
#                         else
#                             dur = get_contact_duration_normal(0.28, 0.09, rng)
#                         end
#                         if dur > 0.01
#                             contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
#                             contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
#                             contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, is_shopping ? 7 : 8] += 1
#                             contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, is_shopping ? 7 : 8] += dur
#                             contacts_num_matrix_by_age_threads[thread_id, agent2.age + 1, agent.age + 1] += 1
#                             contacts_dur_matrix_by_age_threads[thread_id, agent2.age + 1, agent.age + 1] += dur
#                             contacts_num_matrix_by_age_activities_threads[thread_id, agent2.age + 1, agent.age + 1, is_shopping ? 7 : 8] += 1
#                             contacts_dur_matrix_by_age_activities_threads[thread_id, agent2.age + 1, agent.age + 1, is_shopping ? 7 : 8] += dur
#                         end
#                     end
#                 end
#                 # Контакты посетителей с персоналом
#                 for agent2_id in public_space.worker_ids
#                     agent2 = agents[agent2_id]
#                     if rand(rng, Float64) < (1 / length(public_space.worker_ids))
#                         dur = 0.0
#                         if agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
#                             (agent.activity_type == 3 && is_college_holiday) ||
#                             (agent.activity_type == 2 && is_school_holiday) ||
#                             (agent.activity_type == 1 && is_kindergarten_holiday)
        
#                             dur = get_contact_duration_normal(0.44, 0.1, rng)
#                         else
#                             dur = get_contact_duration_normal(0.28, 0.09, rng)
#                         end
#                         if dur > 0.01
#                             contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
#                             contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
#                             contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, is_shopping ? 7 : 8] += 1
#                             contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, is_shopping ? 7 : 8] += dur
#                             contacts_num_matrix_by_age_threads[thread_id, agent2.age + 1, agent.age + 1] += 1
#                             contacts_dur_matrix_by_age_threads[thread_id, agent2.age + 1, agent.age + 1] += dur
#                             contacts_num_matrix_by_age_activities_threads[thread_id, agent2.age + 1, agent.age + 1, is_shopping ? 7 : 8] += 1
#                             contacts_dur_matrix_by_age_activities_threads[thread_id, agent2.age + 1, agent.age + 1, is_shopping ? 7 : 8] += dur
#                         end
#                     end
#                 end
#             end
#             # Очистка групп
#             for i = 1:group.num_agents
#                 group.agent_ids[i] = 0
#             end
#             group.num_agents = 0
#         end
#         # Контакты персонала друг с другом
#         for agent_id in public_space.worker_ids
#             agent = agents[agent_id]
#             for agent2_id in public_space.worker_ids
#                 agent2 = agents[agent2_id]
#                 dur = get_contact_duration_gamma(1.81, 1.7, rng)
#                 if dur > 0.01
#                     contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
#                     contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
#                     contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 4] += 1
#                     contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 4] += dur
#                 end
#             end
#         end
#     end
# end

# -------------------------------------------------------------

function run_simulation_evaluation(
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    agents::Vector{Agent},
    households::Vector{Household},
    kindergartens::Vector{School},
    schools::Vector{School},
    colleges::Vector{School},
    # shops::Vector{PublicSpace},
    # restaurants::Vector{PublicSpace},
    mean_household_contact_durations::Vector{Float64},
    household_contact_duration_sds::Vector{Float64},
    other_contact_duration_shapes::Vector{Float64},
    other_contact_duration_scales::Vector{Float64},
    is_holiday::Bool,
)
    contacts_num_matrix_by_age_threads = zeros(Int, num_threads, 90, 90)
    contacts_dur_matrix_by_age_threads = zeros(Float64, num_threads, 90, 90)
    contacts_num_matrix_by_age_activities_threads = zeros(Int, num_threads, 90, 90, 8)
    contacts_dur_matrix_by_age_activities_threads = zeros(Float64, num_threads, 90, 90, 8)

    # Выходные, праздники
    is_work_holiday = is_holiday
    is_kindergarten_holiday = is_holiday
    is_school_holiday = is_holiday
    is_college_holiday = is_holiday

    # --------------------------TBD ZONE-----------------------------------

    # restaurant_visit_time_distribution = MixtureModel(Normal[
    #     Normal(3.0, 0.7),
    #     Normal(8.0, 0.7)], [0.4, 0.6])
    # shop_visit_time_distribution = MixtureModel(Normal[
    #     Normal(4.0, 1.0),
    #     Normal(9.0, 1.0)], [0.4, 0.6])

    # @threads for thread_id in 1:num_threads
    #     add_additional_connections_each_step_evaluation(
    #         thread_rng[thread_id],
    #         start_agent_ids[thread_id],
    #         end_agent_ids[thread_id],
    #         agents,
    #         households,
    #         shops,
    #         restaurants,
    #         is_kindergarten_holiday,
    #         is_school_holiday,
    #         is_college_holiday,
    #         is_work_holiday,
    #         restaurant_visit_time_distribution,
    #         shop_visit_time_distribution,
    #     )
    # end

    # -------------------------------------------------------------

    @threads for thread_id in 1:num_threads
        simulate_contacts_evaluation(
            thread_id,
            thread_rng[thread_id],
            start_agent_ids[thread_id],
            end_agent_ids[thread_id],
            agents,
            households,
            kindergartens,
            schools,
            colleges,
            mean_household_contact_durations,
            household_contact_duration_sds,
            other_contact_duration_shapes,
            other_contact_duration_scales,
            is_holiday,
            is_kindergarten_holiday,
            is_school_holiday,
            is_college_holiday,
            is_work_holiday,
            contacts_num_matrix_by_age_threads,
            contacts_dur_matrix_by_age_threads,
            contacts_num_matrix_by_age_activities_threads,
            contacts_dur_matrix_by_age_activities_threads)
    end

    # --------------------------TBD ZONE-----------------------------------

    # @threads for thread_id in 1:num_threads
    #     simulate_public_space_contacts_evaluation(
    #         thread_id,
    #         thread_rng[thread_id],
    #         agents,
    #         households,
    #         start_shop_ids[thread_id],
    #         end_shop_ids[thread_id],
    #         shops,
    #         shop_num_nearest_agents_as_contact,
    #         0.28,
    #         0.09,
    #         0.44,
    #         0.1,
    #         is_kindergarten_holiday,
    #         is_school_holiday,
    #         is_college_holiday,
    #         is_work_holiday,
    #         contacts_num_matrix_by_age_threads,
    #         contacts_dur_matrix_by_age_threads,
    #         contacts_num_matrix_by_age_activities_threads,
    #         contacts_dur_matrix_by_age_activities_threads,
    #         true,
    #     )

    #     simulate_public_space_contacts_evaluation(
    #         thread_id,
    #         thread_rng[thread_id],
    #         agents,
    #         households,
    #         start_restaurant_ids[thread_id],
    #         end_restaurant_ids[thread_id],
    #         restaurants,
    #         restaurant_num_nearest_agents_as_contact,
    #         0.26,
    #         0.08,
    #         0.38,
    #         0.09,
    #         is_kindergarten_holiday,
    #         is_school_holiday,
    #         is_college_holiday,
    #         is_work_holiday,
    #         contacts_num_matrix_by_age_threads,
    #         contacts_dur_matrix_by_age_threads,
    #         contacts_num_matrix_by_age_activities_threads,
    #         contacts_dur_matrix_by_age_activities_threads,
    #         false,
    #     )
    # end

    # -------------------------------------------------------------

    contacts_num_matrix_by_age = sum(contacts_num_matrix_by_age_threads, dims=1)[1, :, :]
    contacts_dur_matrix_by_age = sum(contacts_dur_matrix_by_age_threads, dims=1)[1, :, :]
    contacts_num_matrix_by_age_activities = sum(contacts_num_matrix_by_age_activities_threads, dims=1)[1, :, :, :]
    contacts_dur_matrix_by_age_activities = sum(contacts_dur_matrix_by_age_activities_threads, dims=1)[1, :, :, :]

    println("All contacts: $(sum(contacts_num_matrix_by_age))")
    for i = 1:8
        println("Activity $(i): $(sum(contacts_num_matrix_by_age_activities[:, :, i]))")
    end

    if is_holiday
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_counts_holiday.csv"), contacts_num_matrix_by_age, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_durations_holiday.csv"), contacts_dur_matrix_by_age, ',')
        for i = 1:8
            writedlm(
                joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_counts_activity_$(i)_holiday.csv"),
                contacts_num_matrix_by_age_activities[:, :, i], ',')
            writedlm(
                joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_durations_activity_$(i)_holiday.csv"),
                contacts_dur_matrix_by_age_activities[:, :, i], ',')
        end
    else
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_counts.csv"), contacts_num_matrix_by_age, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_durations.csv"), contacts_dur_matrix_by_age, ',')
        for i = 1:8
            writedlm(
                joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_counts_activity_$(i).csv"),
                contacts_num_matrix_by_age_activities[:, :, i], ',')
            writedlm(
                joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_durations_activity_$(i).csv"),
                contacts_dur_matrix_by_age_activities[:, :, i], ',')
        end
    end
    
end
