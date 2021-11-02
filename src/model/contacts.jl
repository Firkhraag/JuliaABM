function simulate_contacts_evaluation(
    thread_id::Int,
    rng::MersenneTwister,
    start_agent_id::Int,
    end_agent_id::Int,
    agents::Vector{Agent},
    households::Vector{Household},
    is_holiday::Bool,
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_university_holiday::Bool,
    is_work_holiday::Bool,
    contacts_num_matrix_by_age_threads::Array{Int, 3},
    contacts_dur_matrix_by_age_threads::Array{Float64, 3},
    contacts_num_matrix_by_age_activities_threads::Array{Int, 4},
    contacts_dur_matrix_by_age_activities_threads::Array{Float64, 4},
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
        if agent.visit_household_id != 0
            for agent2_id in households[agent.visit_household_id].agent_ids
                agent2 = agents[agent2_id]
                if agent2_id != agent_id && agent2.visit_household_id == 0
                    if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
                        (agent.activity_type == 3 && is_university_holiday) ||
                        (agent.activity_type == 2 && is_school_holiday) ||
                        (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                        (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
                        (agent2.activity_type == 3 && is_university_holiday) ||
                        (agent2.activity_type == 2 && is_school_holiday) ||
                        (agent2.activity_type == 1 && is_kindergarten_holiday))

                        dur = get_contact_duration_normal(0.95, 0.2, rng)
                        if dur > 0.01
                            contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 8] += 1
                            contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 8] += dur
                        end
                    else
                        dur = get_contact_duration_normal(0.42, 0.1, rng)
                        if dur > 0.01
                            contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 8] += 1
                            contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 8] += dur
                        end
                    end
                end
            end
        elseif agent.supporter_id != 0 &&
            agents[agent.supporter_id].visit_household_id != 0 &&
            (agent.needs_supporter_care || rand(rng, Float64) < 0.5)
            for agent2_id in households[agents[agent.supporter_id].visit_household_id].agent_ids
                agent2 = agents[agent2_id]
                if agent2_id != agent_id && agent2.visit_household_id == 0

                    if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
                        (agent.activity_type == 3 && is_university_holiday) ||
                        (agent.activity_type == 2 && is_school_holiday) ||
                        (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                        (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
                        (agent2.activity_type == 3 && is_university_holiday) ||
                        (agent2.activity_type == 2 && is_school_holiday) ||
                        (agent2.activity_type == 1 && is_kindergarten_holiday))

                        dur = get_contact_duration_normal(0.95, 0.2, rng)
                        if dur > 0.01
                            contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 8] += 1
                            contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 8] += dur
                        end
                    else
                        dur = get_contact_duration_normal(0.42, 0.1, rng)
                        if dur > 0.01
                            contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 8] += 1
                            contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 8] += dur
                        end
                    end
                end
            end
        end
        # Контакты в домохозяйстве
        for agent2_id in agent.household_conn_ids
            agent2 = agents[agent2_id]
            if agent2_id != agent_id
                dur = 0.0
                if is_holiday || ((agent.is_isolated || agent.on_parent_leave || agent.activity_type == 0 ||
                    (agent.activity_type == 4 && is_work_holiday) || (agent.activity_type == 3 && is_university_holiday) ||
                    (agent.activity_type == 2 && is_school_holiday) || (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                    (agent2.is_isolated || agent2.on_parent_leave || agent2.activity_type == 0 ||
                    (agent2.activity_type == 4 && is_work_holiday) || (agent2.activity_type == 3 && is_university_holiday) ||
                    (agent2.activity_type == 2 && is_school_holiday) || (agent2.activity_type == 1 && is_kindergarten_holiday)))

                    dur = get_contact_duration_normal(12.0, 4.0, rng)
                elseif ((agent.activity_type == 4 && !(agent.is_isolated || agent.on_parent_leave)) ||
                    (agent2.activity_type == 4 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_work_holiday

                    dur = get_contact_duration_normal(4.5, 1.5, rng)
                elseif ((agent.activity_type == 2 && !(agent.is_isolated || agent.on_parent_leave)) ||
                    (agent2.activity_type == 2 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_school_holiday

                    dur = get_contact_duration_normal(5.8, 2.0, rng)
                elseif ((agent.activity_type == 1 && !(agent.is_isolated || agent.on_parent_leave)) ||
                    (agent2.activity_type == 1 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_kindergarten_holiday
                    
                    dur = get_contact_duration_normal(6.5, 2.2, rng)
                else
                    dur = get_contact_duration_normal(9.0, 3.0, rng)
                end
                if dur > 0.01
                    contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                    contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 5] += 1
                    contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 5] += dur
                end
            end
        end
        # Контакты в остальных коллективах
        if !agent.is_isolated && !agent.on_parent_leave && agent.attendance &&
            ((agent.activity_type == 1 && !is_kindergarten_holiday) ||
            (agent.activity_type == 2 && !is_school_holiday) ||
            (agent.activity_type == 3 && !is_university_holiday) ||
            (agent.activity_type == 4 && !is_work_holiday))

            for agent2_id in agent.activity_conn_ids
                agent2 = agents[agent2_id]
                if agent2.attendance && agent2_id != agent_id
                    dur = 0.0
                    if agent.activity_type == 1
                        dur = get_contact_duration_gamma(2.5, 1.6, rng)
                    elseif agent.activity_type == 2
                        dur = get_contact_duration_gamma(1.78, 1.95, rng)
                    elseif agent.activity_type == 3
                        dur = get_contact_duration_gamma(2.0, 1.07, rng)
                    else
                        dur = get_contact_duration_gamma(1.81, 1.7, rng)
                    end

                    if dur > 0.01
                        contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += 1
                        contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += dur
                    end
                end
            end

            # Контакты между университетскими группами
            if agent.activity_type == 3
                for agent2_id in agent.activity_cross_conn_ids
                    agent2 = agents[agent2_id]
                    if agent2.attendance && !agent2.is_teacher && rand(rng, Float64) < 0.25
                        dur = get_contact_duration_gamma(1.2, 1.07, rng)
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

function simulate_additional_contacts_evaluation(
    thread_id::Int,
    rng::MersenneTwister,
    agents::Vector{Agent},
    start_shop_id::Int,
    end_shop_id::Int,
    start_restaurant_id::Int,
    end_restaurant_id::Int,
    shops::Vector{Shop},
    restaurants::Vector{Restaurant},
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_university_holiday::Bool,
    is_work_holiday::Bool,
    contacts_num_matrix_by_age_threads::Array{Int, 3},
    contacts_dur_matrix_by_age_threads::Array{Float64, 3},
    contacts_num_matrix_by_age_activities_threads::Array{Int, 4},
    contacts_dur_matrix_by_age_activities_threads::Array{Float64, 4},
)
    for shop_id in start_shop_id:end_shop_id
        shop = shops[shop_id]
        for group_id in 1:length(shop.groups)
            group = shop.groups[group_id]
            for agent_id in group
                if agent_id == 0
                    break
                end
                agent = agents[agent_id]
                for agent2_id in group
                    if agent2_id == 0
                        break
                    end
                    agent2 = agents[agent2_id]
                    if agent2_id != agent_id && rand(rng, Float64) < 0.25
                        if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
                            (agent.activity_type == 3 && is_university_holiday) ||
                            (agent.activity_type == 2 && is_school_holiday) ||
                            (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                            (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
                            (agent2.activity_type == 3 && is_university_holiday) ||
                            (agent2.activity_type == 2 && is_school_holiday) ||
                            (agent2.activity_type == 1 && is_kindergarten_holiday))

                            dur = get_contact_duration_normal(0.44, 0.1, rng)
                            if dur > 0.01
                                contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                                contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 6] += 1
                                contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 6] += dur
                            end
                        else
                            dur = get_contact_duration_normal(0.28, 0.09, rng)
                            if dur > 0.01
                                contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                                contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 6] += 1
                                contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 6] += dur
                            end
                        end
                    end
                end
            end
            for i in 1:length(group)
                if group[i] == 0
                    break
                end
                shops[shop_id].groups[group_id][i] = 0
            end
        end
    end

    for restaurant_id in start_restaurant_ids[thread_id]:end_restaurant_ids[thread_id]
        restaurant = restaurants[restaurant_id]
        for group_id in 1:length(restaurant.groups)
            group = restaurant.groups[group_id]
            for agent_id in group
                if agent_id == 0
                    break
                end
                agent = agents[agent_id]
                for agent2_id in group
                    if agent2_id == 0
                        break
                    end
                    agent2 = agents[agent2_id]
                    if agent2_id != agent_id && rand(rng, Float64) < 0.25
                        if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
                            (agent.activity_type == 3 && is_university_holiday) ||
                            (agent.activity_type == 2 && is_school_holiday) ||
                            (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                            (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
                            (agent2.activity_type == 3 && is_university_holiday) ||
                            (agent2.activity_type == 2 && is_school_holiday) ||
                            (agent2.activity_type == 1 && is_kindergarten_holiday))

                            dur = get_contact_duration_normal(0.38, 0.09, rng)
                            if dur > 0.01
                                contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                                contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 7] += 1
                                contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 7] += dur
                            end
                        else
                            dur = get_contact_duration_normal(0.26, 0.08, rng)
                            if dur > 0.01
                                contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                                contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 7] += 1
                                contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 7] += dur
                            end
                        end
                    end
                end
            end
            for i in 1:length(group)
                if group[i] == 0
                    break
                end
                restaurants[restaurant_id].groups[group_id][i] = 0
            end
        end
    end
end


function run_simulation_evaluation(
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    agents::Vector{Agent},
    households::Vector{Household},
    shops::Vector{Shop},
    restaurants::Vector{Restaurant},
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
    is_university_holiday = is_holiday

    @threads for thread_id in 1:num_threads
        add_additional_connections(
            thread_rng[thread_id],
            start_agent_ids[thread_id],
            end_agent_ids[thread_id],
            agents,
            households,
            shops,
            restaurants,
            is_kindergarten_holiday,
            is_school_holiday,
            is_university_holiday,
            is_work_holiday,
        )
    end

    @threads for thread_id in 1:num_threads
        simulate_contacts_evaluation(
            thread_id,
            thread_rng[thread_id],
            start_agent_ids[thread_id],
            end_agent_ids[thread_id],
            agents,
            households,
            is_holiday,
            is_kindergarten_holiday,
            is_school_holiday,
            is_university_holiday,
            is_work_holiday,
            contacts_num_matrix_by_age_threads,
            contacts_dur_matrix_by_age_threads,
            contacts_num_matrix_by_age_activities_threads,
            contacts_dur_matrix_by_age_activities_threads)
    end

    @threads for thread_id in 1:num_threads
        simulate_additional_contacts_evaluation(
            thread_id,
            thread_rng[thread_id],
            agents,
            start_shop_ids[thread_id],
            end_shop_ids[thread_id],
            start_restaurant_ids[thread_id],
            end_restaurant_ids[thread_id],
            shops,
            restaurants,
            is_kindergarten_holiday,
            is_school_holiday,
            is_university_holiday,
            is_work_holiday,
            contacts_num_matrix_by_age_threads,
            contacts_dur_matrix_by_age_threads,
            contacts_num_matrix_by_age_activities_threads,
            contacts_dur_matrix_by_age_activities_threads)
    end

    contacts_num_matrix_by_age = sum(contacts_num_matrix_by_age_threads, dims=1)[1, :, :]
    contacts_dur_matrix_by_age = sum(contacts_dur_matrix_by_age_threads, dims=1)[1, :, :]
    contacts_num_matrix_by_age_activities = sum(contacts_num_matrix_by_age_activities_threads, dims=1)[1, :, :, :]
    contacts_dur_matrix_by_age_activities = sum(contacts_dur_matrix_by_age_activities_threads, dims=1)[1, :, :, :]

    println(sum(contacts_num_matrix_by_age))
    for i = 1:8
        println(sum(contacts_num_matrix_by_age_activities[:, :, i]))
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
