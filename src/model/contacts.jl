function simulate_contacts_evaluation(
    thread_id::Int,
    rng::MersenneTwister,
    start_agent_id::Int,
    end_agent_id::Int,
    agents::Vector{Agent},
    temp_influences::Array{Float64, 2},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    etiology::Matrix{Float64},
    is_holiday::Bool,
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_university_holiday::Bool,
    is_work_holiday::Bool,
    week_num::Int,
    current_step::Int,
    infected_inside_collective::Array{Int, 3},
    contact_matrix_by_age_threads::Array{Float64, 3},
    contact_duration_matrix_by_age_threads::Array{Float64, 3}
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
        if agent.virus_id != 0 && !agent.is_newly_infected && agent.infectivity > 0.0001
            for agent2_id in agent.household_conn_ids
                agent2 = agents[agent2_id]

                # Проверка восприимчивости агента к вирусу
                if (agent2.virus_id == 0 && agent2.days_immune == 0) &&
                    (agent.virus_id != 1 || !agent2.FluA_immunity) && (agent.virus_id != 2 || !agent2.FluB_immunity) &&
                    (agent.virus_id != 7 || !agent2.CoV_immunity) && (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
                    (agent.virus_id != 4 || agent2.RSV_days_immune == 0) && (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
                    (agent.virus_id != 6 || agent2.PIV_days_immune == 0)

                    agent_at_home = agent.is_isolated || agent.on_parent_leave || agent.collective_id == 0
                    agent2_at_home = agent2.is_isolated || agent2.on_parent_leave || agent2.collective_id == 0

                    # http://ecs.force.com/mbdata/MBQuest2RTanw?rep=KK3Q1806#:~:text=6%20hours%20per%20day%20for%20kindergarten%20and%20elementary%20students.&text=437.5%20hours%20per%20year%20for%20half%2Dday%20kindergarten.
                    # https://nces.ed.gov/surveys/sass/tables/sass0708_035_s1s.asp
                    # Mixing patterns between age groups in social networks
                    # American Time Use Survey Summary. Bls.gov. 2017-06-27. Retrieved 2018-06-06s

                    if is_holiday || (agent_at_home && agent2_at_home)

                        dur = get_contact_duration_normal(12.5, 5.5, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                        make_contact(
                            agent, agent2, dur,
                            current_step, duration_parameter, susceptibility_parameters, temp_influences, rng)
                    elseif ((agent.collective_id == 4 && !agent_at_home) ||
                        (agent2.collective_id == 4 && !agent2_at_home)) && !is_work_holiday

                        dur = get_contact_duration_normal(4.5, 2.0, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                        make_contact(
                            agent, agent2, dur,
                            current_step, duration_parameter, susceptibility_parameters, temp_influences, rng)
                    elseif ((agent.collective_id == 2 && !agent_at_home) ||
                        (agent2.collective_id == 2 && !agent2_at_home)) && !is_school_holiday

                        dur = get_contact_duration_normal(5.86, 2.65, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                        make_contact(
                            agent, agent2, dur,
                            current_step, duration_parameter, susceptibility_parameters, temp_influences, rng)
                    elseif ((agent.collective_id == 1 && !agent_at_home) ||
                        (agent2.collective_id == 1 && !agent2_at_home)) && !is_kindergarten_holiday

                        dur = get_contact_duration_normal(6.5, 2.46, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                        make_contact(
                            agent, agent2, dur,
                            current_step, duration_parameter, susceptibility_parameters, temp_influences, rng)
                    elseif ((agent.collective_id == 3 && !agent_at_home) ||
                        (agent2.collective_id == 3 && !agent2_at_home)) && !is_university_holiday

                        dur = get_contact_duration_normal(10.0, 3.69, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                        make_contact(
                            agent, agent2, dur,
                            current_step, duration_parameter, susceptibility_parameters, temp_influences, rng)
                    end

                    if agent2.is_newly_infected
                        infected_inside_collective[current_step, 5, thread_id] += 1
                    end
                else
                    # Other case
                    agent_at_home = agent.is_isolated || agent.on_parent_leave || agent.collective_id == 0
                    agent2_at_home = agent2.is_isolated || agent2.on_parent_leave || agent2.collective_id == 0

                    if is_holiday || (agent_at_home && agent2_at_home)

                        dur = get_contact_duration_normal(12.5, 5.5, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                    elseif ((agent.collective_id == 4 && !agent_at_home) ||
                        (agent2.collective_id == 4 && !agent2_at_home)) && !is_work_holiday

                        dur = get_contact_duration_normal(4.5, 2.0, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                    elseif ((agent.collective_id == 2 && !agent_at_home) ||
                        (agent2.collective_id == 2 && !agent2_at_home)) && !is_school_holiday

                        dur = get_contact_duration_normal(5.86, 2.65, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                    elseif ((agent.collective_id == 1 && !agent_at_home) ||
                        (agent2.collective_id == 1 && !agent2_at_home)) && !is_kindergarten_holiday

                        dur = get_contact_duration_normal(6.5, 2.46, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                    elseif ((agent.collective_id == 3 && !agent_at_home) ||
                        (agent2.collective_id == 3 && !agent2_at_home)) && !is_university_holiday

                        dur = get_contact_duration_normal(10.0, 3.69, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                    end
                end
            end
            if !is_holiday && agent.group_num != 0 && !agent.is_isolated && !agent.on_parent_leave &&
                ((agent.collective_id == 1 && !is_kindergarten_holiday) ||
                    (agent.collective_id == 2 && !is_school_holiday) ||
                    (agent.collective_id == 3 && !is_university_holiday) ||
                    (agent.collective_id == 4 && !is_work_holiday))
                for agent2_id in agent.collective_conn_ids
                    agent2 = agents[agent2_id]
                    if agent2.virus_id == 0 && agent2.days_immune == 0 && !agent2.is_isolated && !agent2.on_parent_leave &&
                        (agent.virus_id != 1 || !agent2.FluA_immunity) && (agent.virus_id != 2 || !agent2.FluB_immunity) &&
                        (agent.virus_id != 7 || !agent2.CoV_immunity) && (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
                        (agent.virus_id != 4 || agent2.RSV_days_immune == 0) && (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
                        (agent.virus_id != 6 || agent2.PIV_days_immune == 0)
                            
                        if agent.collective_id == 1

                            dur = get_contact_duration_normal(4.5, 2.66, rng)
                            if dur > 0.001
                                contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            end
                            make_contact(
                                agent, agent2, dur,
                                current_step, duration_parameter,
                                susceptibility_parameters, temp_influences, rng)
                        elseif agent.collective_id == 2

                            dur = get_contact_duration_normal(3.783, 2.67, rng)
                            if dur > 0.001
                                contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            end
                            make_contact(
                                agent, agent2, dur,
                                current_step, duration_parameter,
                                susceptibility_parameters, temp_influences, rng)
                        elseif agent.collective_id == 3

                            dur = get_contact_duration_normal(2.5, 1.62, rng)
                            if dur > 0.001
                                contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            end
                            make_contact(
                                agent, agent2, dur,
                                current_step, duration_parameter,
                                susceptibility_parameters, temp_influences, rng)
                        else

                            dur = get_contact_duration_normal(3.07, 2.5, rng)
                            if dur > 0.001
                                contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            end
                            make_contact(
                                agent, agent2, dur,
                                current_step, duration_parameter,
                                susceptibility_parameters, temp_influences, rng)
                        end

                        if agent2.is_newly_infected
                            infected_inside_collective[current_step, agent.collective_id, thread_id] += 1
                        end
                    else
                        # Other cases
                        if agent.collective_id == 1
                            dur = get_contact_duration_normal(4.5, 2.66, rng)
                            if dur > 0.001
                                contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            end
                        elseif agent.collective_id == 2
                            dur = get_contact_duration_normal(3.783, 2.67, rng)
                            if dur > 0.001
                                contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            end
                        elseif agent.collective_id == 3
                            dur = get_contact_duration_normal(2.5, 1.62, rng)
                            if dur > 0.001
                                contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            end
                        else
                            dur = get_contact_duration_normal(3.07, 2.5, rng)
                            if dur > 0.001
                                contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            end
                        end
                    end
                end

                if agent.collective_id == 3
                    for agent2_id in agent.collective_cross_conn_ids
                        agent2 = agents[agent2_id]
                        if agent2.virus_id == 0 && agent2.days_immune == 0 && !agent2.is_isolated && !agent2.on_parent_leave &&
                            (agent.virus_id != 1 || !agent2.FluA_immunity) && (agent.virus_id != 2 || !agent2.FluB_immunity) &&
                            (agent.virus_id != 7 || !agent2.CoV_immunity) && (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
                            (agent.virus_id != 4 || agent2.RSV_days_immune == 0) && (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
                            (agent.virus_id != 6 || agent2.PIV_days_immune == 0)
                                
                            dur = get_contact_duration_gamma(1.0, 1.6, rng)
                            if dur > 0.001
                                contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            end
                            make_contact(
                                agent, agent2, dur,
                                current_step, duration_parameter,
                                susceptibility_parameters, temp_influences, rng)

                            if agent2.is_newly_infected
                                infected_inside_collective[current_step, 3, thread_id] += 1
                            end
                        else
                            # Other
                            dur = get_contact_duration_gamma(1.0, 1.6, rng)
                            if dur > 0.001
                                contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            end
                        end
                    end
                end
            end
        else
            # OTHER

            # contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1

            for agent2_id in agent.household_conn_ids
                agent2 = agents[agent2_id]
                
                agent_at_home = agent.is_isolated || agent.on_parent_leave || agent.collective_id == 0
                agent2_at_home = agent2.is_isolated || agent2.on_parent_leave || agent2.collective_id == 0

                if is_holiday || (agent_at_home && agent2_at_home)

                    dur = get_contact_duration_normal(12.5, 5.5, rng)
                    if dur > 0.001
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    end
                elseif ((agent.collective_id == 4 && !agent_at_home) ||
                    (agent2.collective_id == 4 && !agent2_at_home)) && !is_work_holiday

                    dur = get_contact_duration_normal(4.5, 2.0, rng)
                    if dur > 0.001
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    end
                elseif ((agent.collective_id == 2 && !agent_at_home) ||
                    (agent2.collective_id == 2 && !agent2_at_home)) && !is_school_holiday

                    dur = get_contact_duration_normal(5.86, 2.65, rng)
                    if dur > 0.001
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    end
                elseif ((agent.collective_id == 1 && !agent_at_home) ||
                    (agent2.collective_id == 1 && !agent2_at_home)) && !is_kindergarten_holiday

                    dur = get_contact_duration_normal(6.5, 2.46, rng)
                    if dur > 0.001
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    end
                elseif ((agent.collective_id == 3 && !agent_at_home) ||
                    (agent2.collective_id == 3 && !agent2_at_home)) && !is_university_holiday

                    dur = get_contact_duration_normal(10.0, 3.69, rng)
                    if dur > 0.001
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    end
                end
            end
            if !is_holiday && agent.group_num != 0 && !agent.is_isolated && !agent.on_parent_leave &&
                ((agent.collective_id == 1 && !is_kindergarten_holiday) ||
                    (agent.collective_id == 2 && !is_school_holiday) ||
                    (agent.collective_id == 3 && !is_university_holiday) ||
                    (agent.collective_id == 4 && !is_work_holiday))
                for agent2_id in agent.collective_conn_ids
                    agent2 = agents[agent2_id]
                    
                    if agent.collective_id == 1
                        dur = get_contact_duration_normal(4.5, 2.66, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                    elseif agent.collective_id == 2
                        dur = get_contact_duration_normal(3.783, 2.67, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                    elseif agent.collective_id == 3
                        dur = get_contact_duration_normal(2.5, 1.62, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                    else
                        dur = get_contact_duration_normal(3.07, 2.5, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                    end
                end

                if agent.collective_id == 3
                    for agent2_id in agent.collective_cross_conn_ids
                        agent2 = agents[agent2_id]
                        dur = get_contact_duration_gamma(1.0, 1.6, rng)
                        if dur > 0.001
                            contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        end
                    end
                end
            end
        end
        if agent.virus_id == 0 && agent.days_immune == 0
            if agent.age < 2
                if rand(rng, Float64) < 0.0003
                    infect_randomly(agent, week_num, etiology, rng)
                end
            elseif agent.age < 16
                if rand(rng, Float64) < 0.0002
                    infect_randomly(agent, week_num, etiology, rng)
                end
            else
                if rand(rng, Float64) < 0.0001
                    infect_randomly(agent, week_num, etiology, rng)
                end
            end
        end
    end
end

function simulate_contacts_test(
    thread_id::Int,
    rng::MersenneTwister,
    start_agent_id::Int,
    end_agent_id::Int,
    agents::Vector{Agent},
    temp_influences::Array{Float64, 2},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    etiology::Matrix{Float64},
    is_holiday::Bool,
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_university_holiday::Bool,
    is_work_holiday::Bool,
    week_num::Int,
    current_step::Int,
    infected_inside_collective::Array{Int, 3},
    contact_matrix_by_age_threads::Array{Float64, 3},
    contact_duration_matrix_by_age_threads::Array{Float64, 3}
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
        for agent2_id in agent.household_conn_ids
            agent2 = agents[agent2_id]
            
            agent_at_home = agent.is_isolated || agent.on_parent_leave || agent.collective_id == 0
            agent2_at_home = agent2.is_isolated || agent2.on_parent_leave || agent2.collective_id == 0

            if is_holiday || (agent_at_home && agent2_at_home)

                dur = get_contact_duration_normal(12.5, 5.5, rng)
                if dur > 0.001
                    contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                    contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                end
            elseif ((agent.collective_id == 4 && !agent_at_home) ||
                (agent2.collective_id == 4 && !agent2_at_home)) && !is_work_holiday

                dur = get_contact_duration_normal(4.5, 2.0, rng)
                if dur > 0.001
                    contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                    contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                end
            elseif ((agent.collective_id == 2 && !agent_at_home) ||
                (agent2.collective_id == 2 && !agent2_at_home)) && !is_school_holiday

                dur = get_contact_duration_normal(5.86, 2.65, rng)
                if dur > 0.001
                    contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                    contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                end
            elseif ((agent.collective_id == 1 && !agent_at_home) ||
                (agent2.collective_id == 1 && !agent2_at_home)) && !is_kindergarten_holiday

                dur = get_contact_duration_normal(6.5, 2.46, rng)
                if dur > 0.001
                    contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                    contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                end
            elseif ((agent.collective_id == 3 && !agent_at_home) ||
                (agent2.collective_id == 3 && !agent2_at_home)) && !is_university_holiday

                dur = get_contact_duration_normal(10.0, 3.69, rng)
                if dur > 0.001
                    contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                    contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                end
            end
        end
        if !is_holiday && agent.group_num != 0 && !agent.is_isolated && !agent.on_parent_leave &&
            ((agent.collective_id == 1 && !is_kindergarten_holiday) ||
                (agent.collective_id == 2 && !is_school_holiday) ||
                (agent.collective_id == 3 && !is_university_holiday) ||
                (agent.collective_id == 4 && !is_work_holiday))
            for agent2_id in agent.collective_conn_ids
                agent2 = agents[agent2_id]
                
                if agent.collective_id == 1
                    dur = get_contact_duration_normal(4.5, 2.66, rng)
                    if dur > 0.001
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    end
                elseif agent.collective_id == 2
                    dur = get_contact_duration_normal(3.783, 2.67, rng)
                    if dur > 0.001
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    end
                elseif agent.collective_id == 3
                    dur = get_contact_duration_normal(2.5, 1.62, rng)
                    if dur > 0.001
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    end
                else
                    dur = get_contact_duration_normal(3.07, 2.5, rng)
                    if dur > 0.001
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    end
                end
            end

            if agent.collective_id == 3
                for agent2_id in agent.collective_cross_conn_ids
                    agent2 = agents[agent2_id]
                    dur = get_contact_duration_gamma(1.0, 1.6, rng)
                    if dur > 0.001
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    end
                end
            end
        end
    end
end

function run_simulation_evaluation(
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    agents::Vector{Agent},
    infectivities::Array{Float64, 4},
    temp_influences::Array{Float64, 2},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    etiology::Matrix{Float64}
)
    # День месяца
    day = 1
    # Месяц
    month = 8
    # День недели
    week_day = 1
    # Номер недели
    week_num = 1

    num_viruses = 7

    incidence = Array{Int, 1}(undef, 52)
    etiology_incidence = Array{Int, 2}(undef, 7, 52)
    age_group_incidence = Array{Int, 2}(undef, 4, 52)

    confirmed_daily_new_cases_viruses = zeros(Int, 365, num_viruses, num_threads)
    confirmed_daily_new_cases_age_groups = zeros(Int, 365, 4, num_threads)

    infected_inside_collective = zeros(Int, 365, 5, num_threads)

    contact_matrix_by_age_threads = zeros(Float64, num_threads, 90, 90)
    contact_duration_matrix_by_age_threads = zeros(Float64, num_threads, 90, 90)

    for current_step = 1:365
        println(current_step)
        # Выходные, праздники
        is_holiday = false
        if week_day == 7
            is_holiday = true
        elseif month == 1 && (day == 1 || day == 2 || day == 3 || day == 7)
            is_holiday = true
        elseif month == 5 && (day == 1 || day == 9)
            is_holiday = true
        elseif month == 2 && day == 23
            is_holiday = true
        elseif month == 3 && day == 8
            is_holiday = true
        elseif month == 6 && day == 12
            is_holiday = true
        end

        is_work_holiday = false
        if week_day == 6
            is_work_holiday = true
        end

        is_kindergarten_holiday = is_work_holiday
        if month == 7 || month == 8
            is_kindergarten_holiday = true
        end

        # Каникулы
        # Летние - 01.06.yyyy - 31.08.yyyy
        # Осенние - 05.11.yyyy - 11.11.yyyy
        # Зимние - 28.12.yyyy - 09.03.yyyy
        # Весенние - 22.03.yyyy - 31.03.yyyy
        is_school_holiday = false
        if month == 6 || month == 7 || month == 8
            is_school_holiday = true
        elseif month == 11 && day >= 5 && day <= 11
            is_school_holiday = true
        elseif month == 12 && day >= 28 && day <= 31
            is_school_holiday = true
        elseif month == 1 && day >= 1 && day <= 9
            is_school_holiday = true
        elseif month == 3 && day >= 22 && day <= 31
            is_school_holiday = true
        end

        is_university_holiday = false
        if month == 7 || month == 8
            is_university_holiday = true
        elseif month == 1 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27
            is_university_holiday = true
        elseif month == 6 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27
            is_university_holiday = true
        elseif month == 2 && (day >= 1 && day <= 10)
            is_university_holiday = true
        elseif month == 12 && (day >= 22 && day <= 31)
            is_university_holiday = true
        end

        # contacts_on_current_step = [Int[] for i=1:9897284]

        @threads for thread_id in 1:num_threads
            simulate_contacts_evaluation(
                thread_id,
                thread_rng[thread_id],
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
                temp_influences,
                duration_parameter,
                susceptibility_parameters,
                etiology,
                is_holiday,
                is_kindergarten_holiday,
                is_school_holiday,
                is_university_holiday,
                is_work_holiday,
                week_num,
                current_step,
                infected_inside_collective,
                contact_matrix_by_age_threads,
                contact_duration_matrix_by_age_threads)
        end
        
        @threads for thread_id in 1:num_threads
            update_agent_states(
                thread_id,
                thread_rng[thread_id],
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
                infectivities,
                current_step,
                confirmed_daily_new_cases_viruses,
                confirmed_daily_new_cases_age_groups)
        end

        # Обновление даты
        if week_day == 7

            incidence[week_num] = sum(confirmed_daily_new_cases_viruses[current_step - 6:current_step, :, :])
            for i = 1:7
                etiology_incidence[i, week_num] = sum(confirmed_daily_new_cases_viruses[current_step - 6:current_step, i, :])
            end
            for i = 1:4
                age_group_incidence[i, week_num] = sum(confirmed_daily_new_cases_age_groups[current_step - 6:current_step, i, :])
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

        if ((month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10) && day == 31) ||
            ((month == 4 || month == 6 || month == 9 || month == 11) && day == 30) ||
            (month == 2 && day == 28)
            day = 1
            month += 1
        elseif (month == 12 && day == 31)
            day = 1
            month = 1
        else
            day += 1
        end
    end

    contact_matrix_by_age_threads ./= 365
    contact_duration_matrix_by_age_threads ./= 365

    agent_counts = zeros(90)
    for a in agents
        agent_counts[a.age + 1] += 1
    end

    for i = 1:90
        contact_matrix_by_age_threads[:, i, :] ./= agent_counts[i]
        contact_duration_matrix_by_age_threads[:, i, :] ./= agent_counts[i]
    end

    writedlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "contact_counts.csv"), sum(contact_matrix_by_age_threads, dims=1)[1, :, :], ',')

    writedlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "contact_durations.csv"), sum(contact_duration_matrix_by_age_threads, dims=1)[1, :, :], ',')
end
