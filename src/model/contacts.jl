function simulate_contacts_evaluation(
    thread_id::Int,
    rng::MersenneTwister,
    start_agent_id::Int,
    end_agent_id::Int,
    agents::Vector{Agent},
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
                        dur = get_contact_duration_gamma(other_contact_duration_shapes[2], other_contact_duration_scales[2], rng)
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

function run_simulation_evaluation(
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    agents::Vector{Agent},
    kindergartens::Vector{School},
    schools::Vector{School},
    colleges::Vector{School},
    mean_household_contact_durations::Vector{Float64},
    household_contact_duration_sds::Vector{Float64},
    other_contact_duration_shapes::Vector{Float64},
    other_contact_duration_scales::Vector{Float64},
    is_holiday::Bool,
)
    contacts_num_matrix_by_age_threads = zeros(Int, num_threads, 90, 90)
    contacts_dur_matrix_by_age_threads = zeros(Float64, num_threads, 90, 90)
    contacts_num_matrix_by_age_activities_threads = zeros(Int, num_threads, 90, 90, 5)
    contacts_dur_matrix_by_age_activities_threads = zeros(Float64, num_threads, 90, 90, 5)

    # Выходные, праздники
    is_work_holiday = is_holiday
    is_kindergarten_holiday = is_holiday
    is_school_holiday = is_holiday
    is_college_holiday = is_holiday

    @threads for thread_id in 1:num_threads
        simulate_contacts_evaluation(
            thread_id,
            thread_rng[thread_id],
            start_agent_ids[thread_id],
            end_agent_ids[thread_id],
            agents,
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

    contacts_num_matrix_by_age = sum(contacts_num_matrix_by_age_threads, dims=1)[1, :, :]
    contacts_dur_matrix_by_age = sum(contacts_dur_matrix_by_age_threads, dims=1)[1, :, :]
    contacts_num_matrix_by_age_activities = sum(contacts_num_matrix_by_age_activities_threads, dims=1)[1, :, :, :]
    contacts_dur_matrix_by_age_activities = sum(contacts_dur_matrix_by_age_activities_threads, dims=1)[1, :, :, :]

    println("All contacts: $(sum(contacts_num_matrix_by_age))")
    for i = 1:5
        println("Activity $(i): $(sum(contacts_num_matrix_by_age_activities[:, :, i]))")
    end

    if is_holiday
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_counts_holiday.csv"), contacts_num_matrix_by_age, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_durations_holiday.csv"), contacts_dur_matrix_by_age, ',')
        for i = 1:5
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
        for i = 1:5
            writedlm(
                joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_counts_activity_$(i).csv"),
                contacts_num_matrix_by_age_activities[:, :, i], ',')
            writedlm(
                joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_durations_activity_$(i).csv"),
                contacts_dur_matrix_by_age_activities[:, :, i], ',')
        end
    end
    
end
