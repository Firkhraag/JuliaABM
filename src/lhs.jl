using Base.Threads
using Distributions
using Random
using DelimitedFiles
using DataFrames
using LatinHypercubeSampling
using CSV
using JLD

include("global/variables.jl")

include("model/virus.jl")
include("model/agent.jl")
include("model/group.jl")
include("model/household.jl")
include("model/workplace.jl")
include("model/school.jl")
include("model/public_space.jl")
include("model/initialization.jl")
include("model/simulation.jl")
include("model/contacts.jl")
include("model/connections.jl")

include("data/district_households.jl")
include("data/district_people.jl")
include("data/district_people_households.jl")
include("data/district_nums.jl")
include("data/temperature.jl")
include("data/etiology.jl")

include("util/moving_avg.jl")
include("util/reset.jl")

function multiple_simulations(
    agents::Vector{Agent},
    households::Vector{Household},
    schools::Vector{School},
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    num_runs::Int,
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    etiology::Matrix{Float64},
    temperature::Vector{Float64},
    viruses::Vector{Virus},
    num_infected_age_groups_viruses_prev::Array{Float64, 3},
    mean_household_contact_durations::Vector{Float64},
    household_contact_duration_sds::Vector{Float64},
    other_contact_duration_shapes::Vector{Float64},
    other_contact_duration_scales::Vector{Float64},
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    duration_parameter_default::Float64,
    susceptibility_parameters_default::Vector{Float64},
    temperature_parameters_default::Vector{Float64},
    num_infected_age_groups_viruses::Array{Float64, 3},
    recovered_duration_mean::Float64,
    recovered_duration_sd::Float64,
    random_infection_probabilities_default::Vector{Float64},
    mean_immunity_durations::Vector{Float64},
    num_years::Int,
    immune_memory_susceptibility_levels_default::Vector{Float64},
    surrogate_training::Bool,
    lhs_step::Int,
)
    num_files = 0
    if surrogate_training
        for i in readdir(joinpath(@__DIR__, "..", "surrogate", "tables", "initial"))
            num_files +=1
        end
    else
        for i in readdir(joinpath(@__DIR__, "..", "lhs", "tables", "step$(lhs_step)"))
            num_files +=1
        end
    end

    # num_parameters = 33
    num_parameters = 26

    if duration_parameter_default > 0.95
        duration_parameter_default = 0.95
    end
    if duration_parameter_default < 0.15
        duration_parameter_default = 0.15
    end

    for i = 1:7
        if susceptibility_parameters_default[i] < 1.1
            susceptibility_parameters_default[i] = 1.1
        elseif susceptibility_parameters_default[i] > 7.9
            susceptibility_parameters_default[i] = 7.9
        end

        if temperature_parameters_default[i] < -0.95
            temperature_parameters_default[i] = -0.95
        elseif temperature_parameters_default[i] > -0.05
            temperature_parameters_default[i] = -0.05
        end

        # if immune_memory_susceptibility_levels_default[i] > 0.95
        #     immune_memory_susceptibility_levels_default[i] = 0.95
        # elseif immune_memory_susceptibility_levels_default[i] < 0.05
        #     immune_memory_susceptibility_levels_default[i] = 0.05
        # end

        if mean_immunity_durations[i] > 355.0
            mean_immunity_durations[i] = 355.0
        elseif mean_immunity_durations[i] < 35.0
            mean_immunity_durations[i] = 35.0
        end
    end

    latin_hypercube_plan, _ = LHCoptim(num_runs, num_parameters, 500)

    # points = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "lhs", "tables", "parameters$(lhs_step).csv"), header = false)))

    # points = scaleLHC(latin_hypercube_plan, [
    #     (duration_parameter_default - 0.05, duration_parameter_default + 0.05),
    #     (susceptibility_parameters_default[1] - 0.1, susceptibility_parameters_default[1] + 0.1),
    #     (susceptibility_parameters_default[2] - 0.1, susceptibility_parameters_default[2] + 0.1),
    #     (susceptibility_parameters_default[3] - 0.1, susceptibility_parameters_default[3] + 0.1),
    #     (susceptibility_parameters_default[4] - 0.1, susceptibility_parameters_default[4] + 0.1),
    #     (susceptibility_parameters_default[5] - 0.1, susceptibility_parameters_default[5] + 0.1),
    #     (susceptibility_parameters_default[6] - 0.1, susceptibility_parameters_default[6] + 0.1),
    #     (susceptibility_parameters_default[7] - 0.1, susceptibility_parameters_default[7] + 0.1),
    #     (temperature_parameters_default[1] - 0.05, temperature_parameters_default[1] + 0.05),
    #     (temperature_parameters_default[2] - 0.05, temperature_parameters_default[2] + 0.05),
    #     (temperature_parameters_default[3] - 0.05, temperature_parameters_default[3] + 0.05),
    #     (temperature_parameters_default[4] - 0.05, temperature_parameters_default[4] + 0.05),
    #     (temperature_parameters_default[5] - 0.05, temperature_parameters_default[5] + 0.05),
    #     (temperature_parameters_default[6] - 0.05, temperature_parameters_default[6] + 0.05),
    #     (temperature_parameters_default[7] - 0.05, temperature_parameters_default[7] + 0.05),
    #     (immune_memory_susceptibility_levels_default[1] - 0.03, immune_memory_susceptibility_levels_default[1] + 0.03),
    #     (immune_memory_susceptibility_levels_default[2] - 0.03, immune_memory_susceptibility_levels_default[2] + 0.03),
    #     (immune_memory_susceptibility_levels_default[3] - 0.03, immune_memory_susceptibility_levels_default[3] + 0.03),
    #     (immune_memory_susceptibility_levels_default[4] - 0.03, immune_memory_susceptibility_levels_default[4] + 0.03),
    #     (immune_memory_susceptibility_levels_default[5] - 0.03, immune_memory_susceptibility_levels_default[5] + 0.03),
    #     (immune_memory_susceptibility_levels_default[6] - 0.03, immune_memory_susceptibility_levels_default[6] + 0.03),
    #     (immune_memory_susceptibility_levels_default[7] - 0.03, immune_memory_susceptibility_levels_default[7] + 0.03),
    #     (mean_immunity_durations[1] - 5.0, mean_immunity_durations[1] + 5.0),
    #     (mean_immunity_durations[2] - 5.0, mean_immunity_durations[2] + 5.0),
    #     (mean_immunity_durations[3] - 5.0, mean_immunity_durations[3] + 5.0),
    #     (mean_immunity_durations[4] - 5.0, mean_immunity_durations[4] + 5.0),
    #     (mean_immunity_durations[5] - 5.0, mean_immunity_durations[5] + 5.0),
    #     (mean_immunity_durations[6] - 5.0, mean_immunity_durations[6] + 5.0),
    #     (mean_immunity_durations[7] - 5.0, mean_immunity_durations[7] + 5.0),
    #     (random_infection_probabilities_default[1] - random_infection_probabilities_default[1] * 0.05, random_infection_probabilities_default[1] + random_infection_probabilities_default[1] * 0.05),
    #     (random_infection_probabilities_default[2] - random_infection_probabilities_default[2] * 0.05, random_infection_probabilities_default[2] + random_infection_probabilities_default[2] * 0.05),
    #     (random_infection_probabilities_default[3] - random_infection_probabilities_default[3] * 0.05, random_infection_probabilities_default[3] + random_infection_probabilities_default[3] * 0.05),
    #     (random_infection_probabilities_default[4] - random_infection_probabilities_default[4] * 0.05, random_infection_probabilities_default[4] + random_infection_probabilities_default[4] * 0.05),
    # ])

    points = scaleLHC(latin_hypercube_plan, [
        (duration_parameter_default - 0.05, duration_parameter_default + 0.05),
        (susceptibility_parameters_default[1] - 0.1, susceptibility_parameters_default[1] + 0.1),
        (susceptibility_parameters_default[2] - 0.1, susceptibility_parameters_default[2] + 0.1),
        (susceptibility_parameters_default[3] - 0.1, susceptibility_parameters_default[3] + 0.1),
        (susceptibility_parameters_default[4] - 0.1, susceptibility_parameters_default[4] + 0.1),
        (susceptibility_parameters_default[5] - 0.1, susceptibility_parameters_default[5] + 0.1),
        (susceptibility_parameters_default[6] - 0.1, susceptibility_parameters_default[6] + 0.1),
        (susceptibility_parameters_default[7] - 0.1, susceptibility_parameters_default[7] + 0.1),
        (temperature_parameters_default[1] - 0.05, temperature_parameters_default[1] + 0.05),
        (temperature_parameters_default[2] - 0.05, temperature_parameters_default[2] + 0.05),
        (temperature_parameters_default[3] - 0.05, temperature_parameters_default[3] + 0.05),
        (temperature_parameters_default[4] - 0.05, temperature_parameters_default[4] + 0.05),
        (temperature_parameters_default[5] - 0.05, temperature_parameters_default[5] + 0.05),
        (temperature_parameters_default[6] - 0.05, temperature_parameters_default[6] + 0.05),
        (temperature_parameters_default[7] - 0.05, temperature_parameters_default[7] + 0.05),
        (mean_immunity_durations[1] - 5.0, mean_immunity_durations[1] + 5.0),
        (mean_immunity_durations[2] - 5.0, mean_immunity_durations[2] + 5.0),
        (mean_immunity_durations[3] - 5.0, mean_immunity_durations[3] + 5.0),
        (mean_immunity_durations[4] - 5.0, mean_immunity_durations[4] + 5.0),
        (mean_immunity_durations[5] - 5.0, mean_immunity_durations[5] + 5.0),
        (mean_immunity_durations[6] - 5.0, mean_immunity_durations[6] + 5.0),
        (mean_immunity_durations[7] - 5.0, mean_immunity_durations[7] + 5.0),
        (random_infection_probabilities_default[1] - random_infection_probabilities_default[1] * 0.05, random_infection_probabilities_default[1] + random_infection_probabilities_default[1] * 0.05),
        (random_infection_probabilities_default[2] - random_infection_probabilities_default[2] * 0.05, random_infection_probabilities_default[2] + random_infection_probabilities_default[2] * 0.05),
        (random_infection_probabilities_default[3] - random_infection_probabilities_default[3] * 0.05, random_infection_probabilities_default[3] + random_infection_probabilities_default[3] * 0.05),
        (random_infection_probabilities_default[4] - random_infection_probabilities_default[4] * 0.05, random_infection_probabilities_default[4] + random_infection_probabilities_default[4] * 0.05),
    ])

    if surrogate_training
        points = scaleLHC(latin_hypercube_plan, [
            (0.1, 1.0), # duration_parameter
            (1.0, 7.0), # susceptibility_parameters
            (1.0, 7.0),
            (1.0, 7.0),
            (1.0, 7.0),
            (1.0, 7.0),
            (1.0, 7.0),
            (1.0, 7.0),
            (-1.0, -0.01), # temperature_parameters
            (-1.0, -0.01),
            (-1.0, -0.01),
            (-1.0, -0.01),
            (-1.0, -0.01),
            (-1.0, -0.01),
            (-1.0, -0.01),
            (30, 365), # mean_immunity_durations
            (30, 365),
            (30, 365),
            (30, 365),
            (30, 365),
            (30, 365),
            (30, 365),
            (0.001, 0.002), # random_infection_probabilities
            (0.0005, 0.001),
            (0.0002, 0.0005),
            (0.000005, 0.00001),
        ])

        writedlm(joinpath(@__DIR__, "..", "surrogate", "tables", "parameters.csv"), points, ',')

        # points = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "surrogate", "tables", "parameters.csv"), header = false)))
    else
        writedlm(joinpath(@__DIR__, "..", "lhs", "tables", "parameters$(lhs_step).csv"), points, ',')
    end

    nMAE_min = 1.0e12

    for i = (num_files + 1):num_runs
        println(i)

        # duration_parameter = points[i, 1]
        # susceptibility_parameters = points[i, 2:8]
        # temperature_parameters = points[i, 9:15]
        # immune_memory_susceptibility_levels =  points[i, 16:22]
        # for k = 1:length(viruses)
        #     viruses[k].mean_immunity_duration = points[i, 22 + k]
        #     viruses[k].immunity_duration_sd = points[i, 22 + k] * 0.33
        # end
        # random_infection_probabilities = points[i, 30:33]

        duration_parameter = points[i, 1]
        susceptibility_parameters = points[i, 2:8]
        temperature_parameters = points[i, 9:15]
        immune_memory_susceptibility_levels = immune_memory_susceptibility_levels_default
        for k = 1:length(viruses)
            viruses[k].mean_immunity_duration = points[i, 15 + k]
            viruses[k].immunity_duration_sd = points[i, 15 + k] * 0.33
        end
        random_infection_probabilities = points[i, 23:26]

        @threads for thread_id in 1:num_threads
            reset_agent_states(
                agents,
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                viruses,
                num_infected_age_groups_viruses_prev,
                isolation_probabilities_day_1,
                isolation_probabilities_day_2,
                isolation_probabilities_day_3,
                thread_rng[thread_id],
                immune_memory_susceptibility_levels[1],
                immune_memory_susceptibility_levels[2],
                immune_memory_susceptibility_levels[3],
                immune_memory_susceptibility_levels[4],
                immune_memory_susceptibility_levels[5],
                immune_memory_susceptibility_levels[6],
                immune_memory_susceptibility_levels[7],
            )
        end

        @time observed_num_infected_age_groups_viruses, _, __, ___, ____ = run_simulation(
            num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
            susceptibility_parameters, temperature_parameters, temperature,
            mean_household_contact_durations, household_contact_duration_sds,
            other_contact_duration_shapes, other_contact_duration_scales,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probabilities,
            recovered_duration_mean, recovered_duration_sd, num_years, false,
            immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
            immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
            immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
            immune_memory_susceptibility_levels[7])

        nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    
        if nMAE < nMAE_min
            nMAE_min = nMAE
        end

        println("nMAE_cur = ", nMAE)
        println("nMAE_min = ", nMAE_min)

        open("output/output.txt", "a") do io
            println(io, "nMAE = ", nMAE)
            println(io, "duration_parameter = ", duration_parameter)
            println(io, "susceptibility_parameters = ", susceptibility_parameters)
            println(io, "temperature_parameters = ", temperature_parameters)
            # println(io, "immune_memory_susceptibility_levels = ", immune_memory_susceptibility_levels)
            # println(io, "mean_immunity_durations = ", [points[i, 23], points[i, 24], points[i, 25], points[i, 26], points[i, 27], points[i, 28], points[i, 29]])
            println(io, "mean_immunity_durations = ", [points[i, 16], points[i, 17], points[i, 18], points[i, 19], points[i, 20], points[i, 21], points[i, 22]])
            println(io, "random_infection_probabilities = ", random_infection_probabilities)
            println(io)
        end

        if surrogate_training
            save(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"),
                "observed_cases", observed_num_infected_age_groups_viruses,
                "duration_parameter", duration_parameter,
                "susceptibility_parameters", susceptibility_parameters,
                "temperature_parameters", temperature_parameters,
                # "immune_memory_susceptibility_levels", immune_memory_susceptibility_levels,
                # "mean_immunity_durations", [points[i, 23], points[i, 24], points[i, 25], points[i, 26], points[i, 27], points[i, 28], points[i, 29]],
                "mean_immunity_durations", [points[i, 16], points[i, 17], points[i, 18], points[i, 19], points[i, 20], points[i, 21], points[i, 22]],
                "random_infection_probabilities", random_infection_probabilities)
        else
            save(joinpath(@__DIR__, "..", "lhs", "tables", "step$(lhs_step)", "results_$(i).jld"),
                "observed_cases", observed_num_infected_age_groups_viruses,
                "duration_parameter", duration_parameter,
                "susceptibility_parameters", susceptibility_parameters,
                "temperature_parameters", temperature_parameters,
                # "immune_memory_susceptibility_levels", immune_memory_susceptibility_levels,
                # "mean_immunity_durations", [points[i, 23], points[i, 24], points[i, 25], points[i, 26], points[i, 27], points[i, 28], points[i, 29]],
                "mean_immunity_durations", [points[i, 16], points[i, 17], points[i, 18], points[i, 19], points[i, 20], points[i, 21], points[i, 22]],
                "random_infection_probabilities", random_infection_probabilities)
        end
    end
end

function main()
    println("Initialization...")

    num_runs = 100

    # num_years = 3
    # num_years = 2
    num_years = 1

    surrogate_training = false
    lhs_step = 28

    num_threads = nthreads()

    # Вероятности изолироваться при болезни на 1-й, 2-й и 3-й дни
    isolation_probabilities_day_1 = [0.406, 0.305, 0.204, 0.101]
    isolation_probabilities_day_2 = [0.669, 0.576, 0.499, 0.334]
    isolation_probabilities_day_3 = [0.45, 0.325, 0.376, 0.168]
    # Продолжительность резистентного состояния
    recovered_duration_mean = 6.0
    recovered_duration_sd = 2.0
    # Продолжительности контактов в домохозяйствах
    # Укороченные для различных коллективов и полная: Kinder, School, College, Work, Full
    mean_household_contact_durations = [6.5, 5.8, 9.0, 4.5, 12.0]
    household_contact_duration_sds = [2.2, 2.0, 3.0, 1.5, 4.0]
    # Продолжительности контактов в прочих коллективах
    other_contact_duration_shapes = [2.5, 1.78, 2.0, 1.81, 1.2]
    other_contact_duration_scales = [1.6, 1.95, 1.07, 1.7, 1.07]
    # Параметры, отвечающие за связи на рабочих местах
    firm_min_size = 1
    firm_max_size = 1000
    num_barabasi_albert_attachments = 5

    # nMAE = 0.5127395196087101
    # duration_parameter = 0.23703365311405514
    # susceptibility_parameters = [3.0731248200497587, 3.0315005376748694, 3.4960107319671523, 4.558457619595636, 3.9627987624113588, 3.751417011489648, 4.552998584572433]
    # temperature_parameters = [-0.8747474747474746, -0.9177827791629244, -0.051010101010101006, -0.16313131313131315, -0.003030303030303022, -0.08442528431390421, -0.35326291827502476]
    # immune_memory_susceptibility_levels = [0.8944639240038756, 0.9430303030303029, 0.9336363636363636, 0.9363636363636363, 0.8876594776594775, 0.8817572117572116, 0.946060606060606]
    # mean_immunity_durations = [357.979797979798, 326.2129504744517, 133.30517744372466, 99.91903541540344, 105.99775039968745, 148.27512119521802, 162.6804553051528]
    # random_infection_probabilities = [0.00138, 0.00077, 0.0004, 9.2e-6]

    # nMAE = 0.8410544834403171
    # duration_parameter = 0.1882882882882883
    # susceptibility_parameters = [4.813813813813814, 3.2762762762762763, 2.4774774774774775, 5.2942942942942945, 4.141141141141141, 3.018018018018018, 4.597597597597598]
    # temperature_parameters = [-0.7542342342342342, -0.7879279279279279, -0.11009009009009008, -0.3826126126126126, -0.33009009009009005, -0.998018018018018, -0.06945945945945942]
    # immune_memory_susceptibility_levels = [0.9864864864864865, 0.7007007007007007, 0.7422422422422422, 0.8038038038038038, 0.6131131131131131, 0.6516516516516516, 0.5985985985985987]
    # mean_immunity_durations = [138.3133133133133, 130.26526526526527, 173.52352352352352, 198.67367367367368, 135.96596596596595, 300.2802802802803, 259.034034034034]
    # random_infection_probabilities = [0.0011761761761761762, 0.0008848848848848848, 0.0002921921921921922, 6.0510510510510515e-6]

    # nMAE = 0.823885251834751
    # duration_parameter = 0.20495495495495497
    # susceptibility_parameters = [4.7986622986622995, 3.327791427791428, 2.5572754572754572, 5.196314496314497, 4.083565383565383, 3.0755937755937754, 4.578405678405678]
    # temperature_parameters = [-0.7426180726180726, -0.7874228774228773, -0.16009009009009006, -0.35685503685503683, -0.3053426153426153, -0.9272727272727272, -0.048752388752388714]
    # immune_memory_susceptibility_levels = [0.9666666666666667, 0.7264582764582764, 0.7358786058786059, 0.8338038038038038, 0.6122040222040223, 0.6428637728637728, 0.6043561743561744]
    # mean_immunity_durations = [137.45472745472745, 127.58849758849759, 170.84675584675585, 202.05751205751207, 134.9053599053599, 295.4823004823005, 254.3370643370643]
    # random_infection_probabilities = [0.0011351882185215518, 0.0009023144356477689, 0.0003059163709163709, 6.023546273546274e-6]

    # nMAE = 0.8146061205058156
    # duration_parameter = 0.22768222768222768
    # susceptibility_parameters = [4.747147147147148, 3.2924378924378925, 2.5946491946491945, 5.142779142779144, 3.985585585585585, 3.0685230685230684, 4.601638001638001]
    # temperature_parameters = [-0.7461534261534261, -0.805099645099645, -0.19796887796887794, -0.3694812994812995, -0.3159486759486759, -0.9126262626262626, -0.07777777777777778]
    # immune_memory_susceptibility_levels = [0.9775757575757575, 0.7364582764582764, 0.7489089089089089, 0.8571371371371371, 0.5858403858403859, 0.6152880152880152, 0.5925379925379926]
    # mean_immunity_durations = [133.46482846482846, 130.7703157703158, 172.81645281645282, 203.01710801710803, 137.27909727909727, 294.1186641186641, 255.59969059969058]
    # random_infection_probabilities = [0.0011919476294476295, 0.0008909215766118123, 0.00031966715728584417, 5.789297251797252e-6]

    # nMAE = 0.7986840934264225
    # duration_parameter = 0.25546000546000547
    # susceptibility_parameters = [4.715834015834017, 3.341932841932842, 2.6502047502047503, 5.087223587223589, 3.9562926562926553, 3.1604422604422604, 4.701638001638001]
    # temperature_parameters = [-0.7355473655473654, -0.8106552006552006, -0.2237264537264537, -0.3295823095823096, -0.3013022113022113, -0.8898989898989899, -0.12676767676767675]
    # immune_memory_susceptibility_levels = [0.9593939393939394, 0.7082764582764582, 0.741939211939212, 0.881076531076531, 0.5643252343252344, 0.5852880152880152, 0.5916289016289017]
    # mean_immunity_durations = [129.57593957593957, 130.21476021476025, 168.82655382655383, 203.16862316862318, 135.71344071344072, 295.987350987351, 260.19565019565016]
    # random_infection_probabilities = [0.0011407781605066959, 0.0008967710617107787, 0.00032693231995143155, 5.751286714285452e-6]

    # nMAE = 0.7824185561594837
    # duration_parameter = 0.2660660660660661
    # susceptibility_parameters = [4.64815724815725, 3.2823368823368826, 2.71990171990172, 5.037728637728639, 3.866393666393665, 3.1675129675129674, 4.74103194103194]
    # temperature_parameters = [-0.7077695877695876, -0.7828774228774228, -0.22827190827190824, -0.2866530166530167, -0.318978978978979, -0.8409090909090908, -0.11111111111111109]
    # immune_memory_susceptibility_levels = [0.9781818181818182, 0.7091855491855491, 0.7404240604240605, 0.8747128947128947, 0.5543252343252344, 0.5661971061971061, 0.6052652652652654]
    # mean_immunity_durations = [133.56583856583856, 130.7703157703158, 167.46291746291746, 207.5625625625626, 138.3902083902084, 293.8156338156339, 256.50878150878145]
    # random_infection_probabilities = [0.0011966647673598016, 0.0009234930276910494, 0.0003294090799510636, 6.003994766882843e-6]

    # nMAE = 0.7730585349602732
    # duration_parameter = 0.2716216216216216
    # susceptibility_parameters = [4.665328965328967, 3.3479934479934483, 2.767376467376468, 4.98823368823369, 3.84114114114114, 3.1968058968058966, 4.715779415779415]
    # temperature_parameters = [-0.6709009009009007, -0.7753016653016652, -0.24695877695877694, -0.3023095823095823, -0.36695877695877693, -0.8030303030303029, -0.0813131313131313]
    # immune_memory_susceptibility_levels = [0.9648484848484848, 0.6852461552461552, 0.715878605878606, 0.8798644098644098, 0.5303858403858405, 0.5398334698334697, 0.6013258713258715]
    # mean_immunity_durations = [136.64664664664664, 127.99253799253802, 167.71544271544272, 205.99690599690604, 143.28919828919828, 295.8863408863409, 253.52898352898347]
    # random_infection_probabilities = [0.0011900166297633583, 0.0008773183763064969, 0.0003289099752844711, 6.292065222869647e-6]

    # nMAE = 0.7509996133659516
    # duration_parameter = 0.2973791973791974
    # susceptibility_parameters = [4.567349167349169, 3.3732459732459734, 2.863336063336064, 4.924597324597326, 3.7916461916461905, 3.1634725634725633, 4.783456183456182]
    # temperature_parameters = [-0.6400928200928199, -0.8212612612612612, -0.23534261534261533, -0.2805924105924106, -0.3462517062517062, -0.771212121212121, -0.034343434343434315]
    # immune_memory_susceptibility_levels = [0.9690909090909091, 0.6855491855491855, 0.7052725452725453, 0.8559250159250159, 0.5252343252343253, 0.537106197106197, 0.5864773864773866]
    # mean_immunity_durations = [138.91937391937392, 126.83092183092185, 171.7053417053417, 210.39084539084544, 142.43061243061243, 293.10856310856315, 253.78150878150873]
    # random_infection_probabilities = [0.0012206685732572631, 0.0008875094483545016, 0.00031412563801158324, 6.072796283284795e-6]

    # nMAE = 0.7451433444820232
    # duration_parameter = 0.33222768222768223
    # susceptibility_parameters = [4.521894621894624, 3.4692055692055694, 2.868386568386569, 4.955910455910457, 3.7219492219492207, 3.124078624078624, 4.865274365274363]
    # temperature_parameters = [-0.6416079716079713, -0.8288370188370188, -0.20453453453453452, -0.23665301665301666, -0.33867594867594863, -0.7333333333333331, -0.009090909090909094]
    # immune_memory_susceptibility_levels = [0.9660606060606061, 0.6694885794885794, 0.6922422422422423, 0.8344098644098644, 0.521900991900992, 0.5192274092274091, 0.6013258713258715]
    # mean_immunity_durations = [134.12139412139413, 125.66930566930569, 176.5033215033215, 213.1686231686232, 145.81445081445082, 291.34088634088636, 252.11484211484205]
    # random_infection_probabilities = [0.0012422460480370633, 0.0009031977466840003, 0.00032507244054835055, 6.161741279353108e-6]

    # nMAE = 0.7341423618562801
    # duration_parameter = 0.2943488943488944
    # susceptibility_parameters = [4.4845208845208875, 3.3813267813267815, 2.9441441441441447, 4.894294294294296, 3.660333060333059, 3.1109473109473105, 4.9491127491127465]
    # temperature_parameters = [-0.6451433251433248, -0.801059241059241, -0.1898880698880699, -0.18766311766311766, -0.31796887796887796, -0.6873737373737371, -0.07676767676767676]
    # immune_memory_susceptibility_levels = [0.9618181818181818, 0.6976703976703976, 0.668908908908909, 0.8613795613795614, 0.5161434161434163, 0.5037728637728636, 0.6119319319319321]
    # mean_immunity_durations = [133.66684866684867, 125.61880061880063, 173.62453362453363, 211.29993629993635, 145.35990535990535, 290.1792701792702, 256.71080171080166]
    # random_infection_probabilities = [0.0012541665909222674, 0.0009383221034994893, 0.0003160426505331186, 6.102613458995679e-6]

    # nMAE = 0.71904399775838
    # duration_parameter = 0.31000546000546003
    # susceptibility_parameters = [4.471389571389574, 3.4611247611247613, 2.8502047502047505, 4.889243789243791, 3.675484575484574, 3.063472563472563, 4.9743652743652715]
    # temperature_parameters = [-0.6779716079716077, -0.8167158067158067, -0.19443352443352444, -0.23564291564291562, -0.270999180999181, -0.6424242424242421, -0.10454545454545452]
    # immune_memory_susceptibility_levels = [0.9515151515151514, 0.6973673673673673, 0.6776967876967878, 0.8822886522886523, 0.5091737191737193, 0.48468195468195446, 0.6243561743561745]
    # mean_immunity_durations = [131.39412139412138, 128.80061880061882, 177.91746291746293, 216.19892619892624, 145.9154609154609, 287.5025025025025, 260.19565019565016]
    # random_infection_probabilities = [0.001249732668631128, 0.0009719690072108346, 0.0003213100280420039, 5.8098112980842696e-6]

    # nMAE = 0.707596092273951
    # duration_parameter = 0.35697515697515697
    # susceptibility_parameters = [4.383510783510786, 3.4742560742560746, 2.9461643461643465, 4.934698334698336, 3.6946764946764934, 3.0543816543816535, 4.969314769314766]
    # temperature_parameters = [-0.6784766584766582, -0.7949986349986349, -0.20806988806988808, -0.2624105924105924, -0.2290799890799891, -0.6227272727272724, -0.08383838383838382]
    # immune_memory_susceptibility_levels = [0.9709090909090908, 0.7110037310037309, 0.6986058786058786, 0.9086522886522886, 0.5361434161434163, 0.4595304395304393, 0.6422349622349625]
    # mean_immunity_durations = [133.26280826280825, 132.89152789152791, 178.77604877604878, 211.19892619892624, 143.4407134407134, 287.75502775502775, 259.94312494312493]
    # random_infection_probabilities = [0.0012427897093609552, 0.000974423474400761, 0.0003328317512697727, 5.877299005082218e-6]

    # nMAE = 0.6879681825321108
    # duration_parameter = 0.3685913185913186
    # susceptibility_parameters = [4.435025935025938, 3.5520338520338526, 2.9269724269724273, 4.881162981162983, 3.6067977067977055, 2.988725088725088, 5.014769314769311]
    # temperature_parameters = [-0.7173655473655471, -0.7722713622713622, -0.23786786786786787, -0.22958230958230957, -0.17907998907998912, -0.6050505050505046, -0.06313131313131311]
    # immune_memory_susceptibility_levels = [0.943030303030303, 0.6810037310037309, 0.6843634543634544, 0.8841068341068341, 0.5509919009919012, 0.4683183183183181, 0.6304167804167806]
    # mean_immunity_durations = [138.26280826280825, 135.56829556829558, 178.11948311948314, 211.0474110474111, 144.09727909727906, 289.1186641186641, 259.3875693875694]
    # random_infection_probabilities = [0.0012597368417613319, 0.0009827897365547067, 0.00033972372187687403, 5.6428007114451e-6]

    # nMAE = 0.6772816784161535
    # duration_parameter = 0.358995358995359
    # susceptibility_parameters = [4.361288561288564, 3.5409227409227415, 2.8673764673764675, 4.863991263991266, 3.6017472017472003, 2.933169533169532, 5.108708708708705]
    # temperature_parameters = [-0.7673655473655472, -0.7980289380289379, -0.25352443352443355, -0.22806715806715805, -0.19069615069615073, -0.5702020202020197, -0.0525252525252525]
    # immune_memory_susceptibility_levels = [0.9596969696969697, 0.6891855491855491, 0.7010301210301211, 0.8553189553189553, 0.5694767494767498, 0.47225771225771207, 0.6089016289016291]
    # mean_immunity_durations = [139.3234143234143, 131.982436982437, 176.04877604877606, 213.01710801710806, 143.6427336427336, 292.90654290654294, 255.09464009464008]
    # random_infection_probabilities = [0.001237468766275652, 0.0010279583557599988, 0.000328228020177, 5.577253026413162e-6]

    # nMAE = 0.6580029533876143
    # duration_parameter = 0.33020748020748025
    # susceptibility_parameters = [4.263308763308767, 3.608599508599509, 2.9370734370734373, 4.826617526617529, 3.5340704340704328, 2.936199836199835, 5.166284466284463]
    # temperature_parameters = [-0.7769615069615068, -0.8338875238875239, -0.22978705978705982, -0.2538247338247338, -0.14372645372645376, -0.5363636363636358, -0.051010101010100985]
    # immune_memory_susceptibility_levels = [0.9345454545454545, 0.6658522158522158, 0.6886058786058786, 0.855015925015925, 0.5800828100828104, 0.46710619710619694, 0.5879925379925383]
    # mean_immunity_durations = [142.5052325052325, 128.5985985985986, 171.75584675584676, 211.956501956502, 141.4710164710164, 288.20957320957325, 259.6905996905997]
    # random_infection_probabilities = [0.001195594823174405, 0.0010450909950226654, 0.0003128112495323227, 5.5857034097865155e-6]

    # nMAE = 0.6541755475006543
    # duration_parameter = 0.3226317226317227
    # susceptibility_parameters = [4.197652197652201, 3.6520338520338527, 3.0229320229320233, 4.8417690417690435, 3.5269997269997257, 2.9493311493311483, 5.157193557193554]
    # temperature_parameters = [-0.7764564564564562, -0.799039039039039, -0.20907998907998912, -0.30079443079443074, -0.1381708981708982, -0.49040404040403984, -0.032323232323232295]
    # immune_memory_susceptibility_levels = [0.9493939393939393, 0.6788825188825188, 0.7052725452725453, 0.8838038038038039, 0.5791737191737195, 0.4601365001365, 0.5743561743561746]
    # mean_immunity_durations = [138.81836381836382, 130.0632450632451, 171.6043316043316, 208.37064337064342, 138.39020839020833, 283.31058331058335, 256.1047411047411]
    # random_infection_probabilities = [0.0011974063304822451, 0.0010340066965906069, 0.00032118447994909703, 5.362839485860689e-6]

    # nMAE = 0.633537776860235
    # duration_parameter = 0.35748020748020753
    # susceptibility_parameters = [4.144116844116848, 3.582336882336883, 3.1148512148512153, 4.755910455910458, 3.5057876057876047, 2.930139230139229, 5.09355719355719]
    # temperature_parameters = [-0.8173655473655471, -0.7712612612612612, -0.18635271635271639, -0.28109746109746103, -0.15281736281736286, -0.45959595959595906, -0.04141414141414141]
    # immune_memory_susceptibility_levels = [0.9654545454545455, 0.6985794885794885, 0.7195149695149696, 0.8610765310765311, 0.5928100828100832, 0.4798334698334697, 0.583750113750114]
    # mean_immunity_durations = [134.52543452543452, 126.3763763763764, 167.4124124124124, 207.51205751205757, 142.077077077077, 287.6035126035126, 258.0744380744381]
    # random_infection_probabilities = [0.0012173631026569493, 0.0010825736777941052, 0.00031291154637465063, 5.365547990651528e-6]

    # nMAE = 0.6196216923338315
    # duration_parameter = 0.38929838929838934
    # susceptibility_parameters = [4.135025935025939, 3.6803166803166807, 3.188588588588589, 4.843789243789246, 3.518918918918918, 2.981654381654381, 5.013759213759211]
    # temperature_parameters = [-0.848173628173628, -0.7525743925743924, -0.198978978978979, -0.24523887523887516, -0.17251433251433254, -0.4207070707070702, -0.08080808080808081]
    # immune_memory_susceptibility_levels = [0.952121212121212, 0.6879734279734279, 0.7040604240604241, 0.8716825916825918, 0.6070525070525075, 0.5037728637728636, 0.5870834470834473]
    # mean_immunity_durations = [133.46482846482846, 121.6794066794067, 169.7861497861498, 207.76458276458283, 137.077077077077, 284.92674492674496, 258.83201383201384]
    # random_infection_probabilities = [0.001184777120616132, 0.0010612502568678576, 0.0003146499438545098, 5.606726662958592e-6]

    # nMAE = 0.6041495353712981
    # duration_parameter = 0.40394485394485397
    # susceptibility_parameters = [4.123914823914828, 3.6469833469833475, 3.2017199017199025, 4.804395304395307, 3.5764946764946757, 2.8877149877149866, 4.952143052143049]
    # temperature_parameters = [-0.896153426153426, -0.7207562107562105, -0.23281736281736287, -0.2103903903903903, -0.1548375648375649, -0.3969696969696965, -0.031818181818181815]
    # immune_memory_susceptibility_levels = [0.9593939393939394, 0.693124943124943, 0.7273937573937574, 0.8871371371371373, 0.5976585676585681, 0.5258940758940757, 0.5601137501137503]
    # mean_immunity_durations = [136.54563654563654, 121.93193193193196, 169.63463463463464, 212.76458276458283, 135.91546091546084, 289.82573482573486, 258.0744380744381]
    # random_infection_probabilities = [0.0011973429385620606, 0.0010832256409747173, 0.00030877012167136996, 5.349043770873122e-6]

    # nMAE = 0.5960590819908353
    # duration_parameter = 0.4064701064701065
    # susceptibility_parameters = [4.128965328965333, 3.714660114660115, 3.148184548184549, 4.835708435708438, 3.67043407043407, 2.8543816543816534, 5.040021840021837]
    # temperature_parameters = [-0.9380726180726179, -0.7091400491400489, -0.22322140322140327, -0.18564291564291557, -0.12301938301938306, -0.3782828282828278, -0.0292929292929293]
    # immune_memory_susceptibility_levels = [0.9412121212121212, 0.6885794885794885, 0.7204240604240605, 0.8644098644098646, 0.5828100828100832, 0.5401365001364999, 0.5622349622349624]
    # mean_immunity_durations = [134.07088907088905, 118.24506324506326, 171.90736190736192, 214.43124943124948, 135.56192556192548, 285.83583583583584, 263.0744380744381]
    # random_infection_probabilities = [0.0012535817735551272, 0.001032346860868329, 0.00031703518048378543, 5.146428476521867e-6]

    # nMAE = 0.5861204949052768
    # duration_parameter = 0.404954954954955
    # susceptibility_parameters = [4.119874419874424, 3.7378924378924383, 3.248184548184549, 4.8306579306579325, 3.6472017472017466, 2.901856401856401, 4.9602238602238575]
    # temperature_parameters = [-0.9759514059514058, -0.7490390390390389, -0.18837291837291842, -0.15988533988533982, -0.16392847392847398, -0.33636363636363587, -0.08484848484848485]
    # immune_memory_susceptibility_levels = [0.9287878787878787, 0.707064337064337, 0.718908908908909, 0.8901674401674403, 0.5612949312949317, 0.5477122577122575, 0.5473864773864775]
    # mean_immunity_durations = [130.88907088907087, 122.43698243698246, 173.2709982709983, 215.18882518882523, 139.24879424879416, 289.1186641186641, 265.85221585221586]
    # random_infection_probabilities = [0.001273208558898667, 0.0010161838544607946, 0.0003264821883870901, 4.8995038779008685e-6]

    # nMAE = 0.5853526858707159
    # duration_parameter = 0.3872781872781873
    # susceptibility_parameters = [4.0319956319956365, 3.6782964782964784, 3.233033033033034, 4.866011466011468, 3.688615888615888, 2.908927108927108, 5.021840021840019]
    # temperature_parameters = [-0.9959595959595959, -0.7303521703521701, -0.20705978705978711, -0.1987742287742287, -0.12604968604968608, -0.37626262626262574, -0.11666666666666667]
    # immune_memory_susceptibility_levels = [0.9375757575757575, 0.7043370643370643, 0.688908908908909, 0.8886522886522888, 0.5870525070525074, 0.5746819546819545, 0.5404167804167805]
    # mean_immunity_durations = [127.50523250523248, 121.2753662753663, 176.65483665483669, 214.43124943124948, 135.46091546091537, 286.8459368459369, 268.2259532259532]
    # random_infection_probabilities = [0.001244272000741879, 0.0009797449384675034, 0.0003302746582521927, 5.0999381274513584e-6]

    # nMAE = 0.5820711812026059
    # duration_parameter = 0.37162162162162166
    # susceptibility_parameters = [4.041086541086545, 3.6752661752661755, 3.2279825279825287, 4.941769041769043, 3.602757302757302, 2.9846846846846837, 5.014769314769311]
    # temperature_parameters = [-0.8999999999999999, -0.7359077259077257, -0.21766584766584773, -0.2265520065520065, -0.13362544362544365, -0.3434343434343429, -0.15252525252525254]
    # immune_memory_susceptibility_levels = [0.9633333333333333, 0.7222158522158523, 0.7128483028483029, 0.8956219856219858, 0.5970525070525075, 0.5925607425607424, 0.5182955682955684]
    # mean_immunity_durations = [129.17189917189916, 117.48748748748751, 179.93766493766498, 216.70397670397676, 140.46091546091537, 290.6338156338157, 263.62999362999363]
    # random_infection_probabilities = [0.001199654166371842, 0.0009357058983040651, 0.000322434805253277, 5.2673603387060745e-6]

    # nMAE = 0.57953032549554
    # duration_parameter = 0.38525798525798527
    # susceptibility_parameters = [4.124924924924929, 3.5974883974883975, 3.2229320229320235, 4.924597324597326, 3.5128583128583117, 2.904886704886704, 4.99355719355719]
    # temperature_parameters = [-0.9479797979797979, -0.7253016653016651, -0.1747365547365548, -0.2007944307944307, -0.1684739284739285, -0.3469696969696965, -0.16111111111111115]
    # immune_memory_susceptibility_levels = [0.9624242424242424, 0.7364582764582766, 0.7137573937573938, 0.8813795613795615, 0.6143252343252348, 0.6080152880152879, 0.5234470834470836]
    # mean_immunity_durations = [131.04058604058602, 119.76021476021478, 182.31140231140236, 213.1181181181182, 139.4003094003093, 292.3004823004824, 259.53908453908457]
    # random_infection_probabilities = [0.001259636874690434, 0.0009116043827416876, 0.0003066387567130912, 5.49880495964922e-6]

    # nMAE = 0.5773861052965671
    # duration_parameter = 0.38273273273273273
    # susceptibility_parameters = [4.150177450177454, 3.6005187005187005, 3.3007098007098015, 4.832678132678135, 3.6007371007370996, 2.9624624624624616, 4.929920829920826]
    # temperature_parameters = [-0.9727272727272727, -0.7652006552006549, -0.14493857493857498, -0.2184711984711984, -0.16392847392847396, -0.3292929292929288, -0.1171717171717172]
    # immune_memory_susceptibility_levels = [0.9315151515151514, 0.7082764582764584, 0.7322422422422423, 0.902894712894713, 0.6328100828100833, 0.6216516516516516, 0.5364773864773866]
    # mean_immunity_durations = [130.68705068705066, 116.4773864773865, 184.18008918008923, 209.1282191282192, 144.097279097279, 291.74492674492683, 259.38756938756944]
    # random_infection_probabilities = [0.0012500941710942943, 0.0009378475392145544, 0.0003191830694877177, 5.71820172319078e-6]

    # nMAE = 0.5750731176762239
    # duration_parameter = 0.3357630357630358
    # susceptibility_parameters = [4.104722904722909, 3.546983346983347, 3.2956592956592963, 4.8841932841932865, 3.5269997269997257, 2.9392301392301383, 5.029920829920826]
    # temperature_parameters = [-0.9797979797979798, -0.8121703521703519, -0.1474638274638275, -0.1684711984711984, -0.1563527163527164, -0.3398989898989894, -0.13888888888888892]
    # immune_memory_susceptibility_levels = [0.9572727272727272, 0.6922158522158522, 0.708908908908909, 0.9007735007735009, 0.6088706888706894, 0.6298334698334698, 0.542841022841023]
    # mean_immunity_durations = [125.68705068705066, 114.60869960869964, 185.4427154427155, 207.25953225953234, 143.23869323869314, 295.0277550277551, 257.0138320138321]
    # random_infection_probabilities = [0.0012545136959415974, 0.000943057803321302, 0.00032933889442596324, 5.940576234648199e-6]

    # nMAE = 0.5742814376300275
    # duration_parameter = 0.3453589953589954
    # susceptibility_parameters = [4.030985530985535, 3.5015288015288015, 3.232022932022933, 4.929647829647831, 3.475484575484574, 2.988725088725088, 4.96426426426426]
    # temperature_parameters = [-0.9636363636363636, -0.7813622713622711, -0.18635271635271639, -0.1689762489762489, -0.17301938301938308, -0.36363636363636315, -0.1565656565656566]
    # immune_memory_susceptibility_levels = [0.9660606060606061, 0.7173673673673674, 0.738908908908909, 0.9071371371371373, 0.602507052507053, 0.6155910455910455, 0.518901628901629]
    # mean_immunity_durations = [123.21230321230318, 119.30566930566934, 187.91746291746298, 211.45145145145153, 142.98616798616789, 297.906542906543, 253.933023933024]
    # random_infection_probabilities = [0.0013096362674299405, 0.0009530599315383462, 0.00033815453149898145, 6.189600389939008e-6]






    # Article - continue from PhD point
    duration_parameter = 0.23703365311405514
    susceptibility_parameters = [3.0731248200497587, 3.0315005376748694, 3.4960107319671523, 4.558457619595636, 3.9627987624113588, 3.751417011489648, 4.552998584572433]
    temperature_parameters = [-0.8747474747474746, -0.9177827791629244, -0.051010101010101006, -0.16313131313131315, -0.003030303030303022, -0.08442528431390421, -0.35326291827502476]
    immune_memory_susceptibility_levels = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    mean_immunity_durations = [357.979797979798, 326.2129504744517, 133.30517744372466, 99.91903541540344, 105.99775039968745, 148.27512119521802, 162.6804553051528]
    random_infection_probabilities = [0.00138, 0.00077, 0.0004, 9.2e-6]

    # Article - end
    duration_parameter = 0.22637404671777045
    susceptibility_parameters = [3.095038052808992, 3.0554159364150997, 3.621467164928697, 4.612459518531132, 3.9086201477859595, 3.9490870441188344, 4.61599824854622]
    temperature_parameters = -[0.8846019152491571, 0.9313057237697472, 0.04837343942226003, 0.13610826071131651, 0.048281056835923, 0.07401637656561208, 0.36034078438752476]
    mean_immunity_durations = [358.53571508348136, 326.40686999692815, 128.36635586863198, 86.9285869152992, 110.11396877548141, 166.57369789857893, 153.80184097804894]
    random_infection_probabilities = [0.0013742087365687383, 0.0007810400878682918, 0.00039431021797935243, 9.16649170205853e-6]
    immune_memory_susceptibility_levels = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]





    viruses = Virus[
        # FluA
        Virus(1.4, 0.67, 1, 7,  4.8, 2.04, 1, 28,  8.0, 3.4, 1, 28,  4.6, 3.5, 2.3,  0.38, 0.47, 0.57,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
        # FluB
        Virus(0.6, 0.19, 1, 7,  3.7, 3.0, 1, 28,  6.1, 4.8, 1, 28,  4.7, 3.5, 2.4,  0.38, 0.47, 0.57,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
        # RV
        Virus(1.9, 1.11, 1, 7,  10.1, 7.0, 1, 28,  11.4, 7.7, 1, 28,  3.5, 2.6, 1.8,  0.19, 0.24, 0.29,  mean_immunity_durations[3], mean_immunity_durations[3] * 0.33),
        # RSV
        Virus(4.4, 1.0, 1, 7,  6.5, 2.7, 1, 28,  6.7, 2.8, 1, 28,  6.0, 4.5, 3.0,  0.24, 0.3, 0.36,  mean_immunity_durations[4], mean_immunity_durations[4] * 0.33),
        # AdV
        Virus(5.6, 1.3, 1, 7,  8.0, 5.6, 1, 28,  9.0, 6.3, 1, 28,  4.1, 3.1, 2.1,  0.15, 0.19, 0.23,  mean_immunity_durations[5], mean_immunity_durations[5] * 0.33),
        # PIV
        Virus(2.6, 0.85, 1, 7,  7.0, 2.9, 1, 28,  8.0, 3.4, 1, 28,  4.8, 3.6, 2.4,  0.16, 0.2, 0.24,  mean_immunity_durations[6], mean_immunity_durations[6] * 0.33),
        # CoV
        Virus(3.2, 0.44, 1, 7,  6.5, 4.5, 1, 28,  7.5, 5.2, 1, 28,  4.9, 3.7, 2.5,  0.21, 0.26, 0.32,  mean_immunity_durations[7], mean_immunity_durations[7] * 0.33)]

    # Число домохозяйств каждого типа по районам
    district_households = get_district_households()
    # Число людей в каждой группе по районам
    district_people = get_district_people()
    # Число людей в домохозяйствах по районам
    district_people_households = get_district_people_households()
    # Распределение вирусов в течение года
    etiology = get_etiology()
    # Номера районов для MPI процессов
    district_nums = get_district_nums()
    # Температура воздуха, начиная с 1 января
    temperature = get_air_temperature()

    agents = Array{Agent, 1}(undef, num_agents)

    # With set seed
    thread_rng = [MersenneTwister(i) for i = 1:num_threads]

    homes_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "homes.csv")))
    # Массив для хранения домохозяйств
    households = Array{Household, 1}(undef, num_households)

    kindergarten_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "kindergartens.csv")))
    # Массив для хранения детских садов
    kindergartens = Array{School, 1}(undef, num_kindergartens)
    for i in 1:size(kindergarten_coords_df, 1)
        kindergartens[i] = School(
            1,
            kindergarten_coords_df[i, :dist],
            kindergarten_coords_df[i, :x],
            kindergarten_coords_df[i, :y],
        )
    end

    school_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "schools.csv")))
    # Массив для хранения школ
    schools = Array{School, 1}(undef, num_schools)
    for i in 1:size(school_coords_df, 1)
        schools[i] = School(
            2,
            school_coords_df[i, :dist],
            school_coords_df[i, :x],
            school_coords_df[i, :y],
        )
    end

    college_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "colleges.csv")))
    # Массив для хранения институтов
    colleges = Array{School, 1}(undef, num_colleges)
    for i in 1:size(college_coords_df, 1)
        colleges[i] = School(
            3,
            college_coords_df[i, :dist],
            college_coords_df[i, :x],
            college_coords_df[i, :y],
        )
    end

    # Массив для хранения фирм
    workplaces = Workplace[]
    
    infected_data_0_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_0 = infected_data_0_all[2:53, flu_starting_index:(23 + num_years)]
    infected_data_0_1 = etiology[:, 1] .* infected_data_0
    infected_data_0_2 = etiology[:, 2] .* infected_data_0
    infected_data_0_3 = etiology[:, 3] .* infected_data_0
    infected_data_0_4 = etiology[:, 4] .* infected_data_0
    infected_data_0_5 = etiology[:, 5] .* infected_data_0
    infected_data_0_6 = etiology[:, 6] .* infected_data_0
    infected_data_0_7 = etiology[:, 7] .* infected_data_0
    infected_data_0_viruses = cat(
        vec(infected_data_0_1),
        vec(infected_data_0_2),
        vec(infected_data_0_3),
        vec(infected_data_0_4),
        vec(infected_data_0_5),
        vec(infected_data_0_6),
        vec(infected_data_0_7),
        dims = 2)

    infected_data_3 = infected_data_3_all[2:53, flu_starting_index:(23 + num_years)]
    infected_data_3_1 = etiology[:, 1] .* infected_data_3
    infected_data_3_2 = etiology[:, 2] .* infected_data_3
    infected_data_3_3 = etiology[:, 3] .* infected_data_3
    infected_data_3_4 = etiology[:, 4] .* infected_data_3
    infected_data_3_5 = etiology[:, 5] .* infected_data_3
    infected_data_3_6 = etiology[:, 6] .* infected_data_3
    infected_data_3_7 = etiology[:, 7] .* infected_data_3
    infected_data_3_viruses = cat(
        vec(infected_data_3_1),
        vec(infected_data_3_2),
        vec(infected_data_3_3),
        vec(infected_data_3_4),
        vec(infected_data_3_5),
        vec(infected_data_3_6),
        vec(infected_data_3_7),
        dims = 2)

    infected_data_7 = infected_data_7_all[2:53, flu_starting_index:(23 + num_years)]
    infected_data_7_1 = etiology[:, 1] .* infected_data_7
    infected_data_7_2 = etiology[:, 2] .* infected_data_7
    infected_data_7_3 = etiology[:, 3] .* infected_data_7
    infected_data_7_4 = etiology[:, 4] .* infected_data_7
    infected_data_7_5 = etiology[:, 5] .* infected_data_7
    infected_data_7_6 = etiology[:, 6] .* infected_data_7
    infected_data_7_7 = etiology[:, 7] .* infected_data_7
    infected_data_7_viruses = cat(
        vec(infected_data_7_1),
        vec(infected_data_7_2),
        vec(infected_data_7_3),
        vec(infected_data_7_4),
        vec(infected_data_7_5),
        vec(infected_data_7_6),
        vec(infected_data_7_7),
        dims = 2)

    infected_data_15 = infected_data_15_all[2:53, flu_starting_index:(23 + num_years)]
    infected_data_15_1 = etiology[:, 1] .* infected_data_15
    infected_data_15_2 = etiology[:, 2] .* infected_data_15
    infected_data_15_3 = etiology[:, 3] .* infected_data_15
    infected_data_15_4 = etiology[:, 4] .* infected_data_15
    infected_data_15_5 = etiology[:, 5] .* infected_data_15
    infected_data_15_6 = etiology[:, 6] .* infected_data_15
    infected_data_15_7 = etiology[:, 7] .* infected_data_15
    infected_data_15_viruses = cat(
        vec(infected_data_15_1),
        vec(infected_data_15_2),
        vec(infected_data_15_3),
        vec(infected_data_15_4),
        vec(infected_data_15_5),
        vec(infected_data_15_6),
        vec(infected_data_15_7),
        dims = 2)

    num_infected_age_groups_viruses = cat(
        infected_data_0_viruses,
        infected_data_3_viruses,
        infected_data_7_viruses,
        infected_data_15_viruses,
        dims = 3,
    )


    infected_data_0_prev = infected_data_0_all[2:53, 1]
    infected_data_0_1_prev = etiology[:, 1] .* infected_data_0_prev
    infected_data_0_2_prev = etiology[:, 2] .* infected_data_0_prev
    infected_data_0_3_prev = etiology[:, 3] .* infected_data_0_prev
    infected_data_0_4_prev = etiology[:, 4] .* infected_data_0_prev
    infected_data_0_5_prev = etiology[:, 5] .* infected_data_0_prev
    infected_data_0_6_prev = etiology[:, 6] .* infected_data_0_prev
    infected_data_0_7_prev = etiology[:, 7] .* infected_data_0_prev
    infected_data_0_viruses_prev = cat(
        vec(infected_data_0_1_prev),
        vec(infected_data_0_2_prev),
        vec(infected_data_0_3_prev),
        vec(infected_data_0_4_prev),
        vec(infected_data_0_5_prev),
        vec(infected_data_0_6_prev),
        vec(infected_data_0_7_prev),
        dims = 2)

    infected_data_3_prev = infected_data_3_all[2:53, 1]
    infected_data_3_1_prev = etiology[:, 1] .* infected_data_3_prev
    infected_data_3_2_prev = etiology[:, 2] .* infected_data_3_prev
    infected_data_3_3_prev = etiology[:, 3] .* infected_data_3_prev
    infected_data_3_4_prev = etiology[:, 4] .* infected_data_3_prev
    infected_data_3_5_prev = etiology[:, 5] .* infected_data_3_prev
    infected_data_3_6_prev = etiology[:, 6] .* infected_data_3_prev
    infected_data_3_7_prev = etiology[:, 7] .* infected_data_3_prev
    infected_data_3_viruses_prev = cat(
        vec(infected_data_3_1_prev),
        vec(infected_data_3_2_prev),
        vec(infected_data_3_3_prev),
        vec(infected_data_3_4_prev),
        vec(infected_data_3_5_prev),
        vec(infected_data_3_6_prev),
        vec(infected_data_3_7_prev),
        dims = 2)

    infected_data_7_prev = infected_data_7_all[2:53, 1]
    infected_data_7_1_prev = etiology[:, 1] .* infected_data_7_prev
    infected_data_7_2_prev = etiology[:, 2] .* infected_data_7_prev
    infected_data_7_3_prev = etiology[:, 3] .* infected_data_7_prev
    infected_data_7_4_prev = etiology[:, 4] .* infected_data_7_prev
    infected_data_7_5_prev = etiology[:, 5] .* infected_data_7_prev
    infected_data_7_6_prev = etiology[:, 6] .* infected_data_7_prev
    infected_data_7_7_prev = etiology[:, 7] .* infected_data_7_prev
    infected_data_7_viruses_prev = cat(
        vec(infected_data_7_1_prev),
        vec(infected_data_7_2_prev),
        vec(infected_data_7_3_prev),
        vec(infected_data_7_4_prev),
        vec(infected_data_7_5_prev),
        vec(infected_data_7_6_prev),
        vec(infected_data_7_7_prev),
        dims = 2)

    infected_data_15_prev = infected_data_15_all[2:53, 1]
    infected_data_15_1_prev = etiology[:, 1] .* infected_data_15_prev
    infected_data_15_2_prev = etiology[:, 2] .* infected_data_15_prev
    infected_data_15_3_prev = etiology[:, 3] .* infected_data_15_prev
    infected_data_15_4_prev = etiology[:, 4] .* infected_data_15_prev
    infected_data_15_5_prev = etiology[:, 5] .* infected_data_15_prev
    infected_data_15_6_prev = etiology[:, 6] .* infected_data_15_prev
    infected_data_15_7_prev = etiology[:, 7] .* infected_data_15_prev
    infected_data_15_viruses_prev = cat(
        vec(infected_data_15_1_prev),
        vec(infected_data_15_2_prev),
        vec(infected_data_15_3_prev),
        vec(infected_data_15_4_prev),
        vec(infected_data_15_5_prev),
        vec(infected_data_15_6_prev),
        vec(infected_data_15_7_prev),
        dims = 2)

    num_infected_age_groups_viruses_prev = cat(
        infected_data_0_viruses_prev,
        infected_data_3_viruses_prev,
        infected_data_7_viruses_prev,
        infected_data_15_viruses_prev,
        dims = 3,
    )

    for virus_id = 1:length(viruses)
        num_infected_age_groups_viruses_prev[:, virus_id, 1] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[1]) * (1 - isolation_probabilities_day_2[1]) * (1 - isolation_probabilities_day_3[1]))
        num_infected_age_groups_viruses_prev[:, virus_id, 2] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[2]) * (1 - isolation_probabilities_day_2[2]) * (1 - isolation_probabilities_day_3[2]))
        num_infected_age_groups_viruses_prev[:, virus_id, 3] ./= viruses[virus_id].symptomatic_probability_teenager * (1 - (1 - isolation_probabilities_day_1[3]) * (1 - isolation_probabilities_day_2[3]) * (1 - isolation_probabilities_day_3[3]))
        num_infected_age_groups_viruses_prev[:, virus_id, 4] ./= viruses[virus_id].symptomatic_probability_adult * (1 - (1 - isolation_probabilities_day_1[4]) * (1 - isolation_probabilities_day_2[4]) * (1 - isolation_probabilities_day_3[4]))
    end

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, households, viruses, num_infected_age_groups_viruses_prev, isolation_probabilities_day_1,
            isolation_probabilities_day_2, isolation_probabilities_day_3, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people, district_people_households, district_nums,
            immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
            immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
            immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
            immune_memory_susceptibility_levels[7])
    end

    @time set_connections(
        agents, households, kindergartens, schools, colleges,
        workplaces, thread_rng, num_threads, homes_coords_df,
        firm_min_size, firm_max_size, num_barabasi_albert_attachments)

    println("Simulation...")

    multiple_simulations(
        agents,
        households,
        schools,
        num_threads,
        thread_rng,
        num_runs,
        start_agent_ids,
        end_agent_ids,
        etiology,
        temperature,
        viruses,
        num_infected_age_groups_viruses_prev,
        mean_household_contact_durations,
        household_contact_duration_sds,
        other_contact_duration_shapes,
        other_contact_duration_scales,
        isolation_probabilities_day_1,
        isolation_probabilities_day_2,
        isolation_probabilities_day_3,
        duration_parameter,
        susceptibility_parameters,
        temperature_parameters,
        num_infected_age_groups_viruses,
        recovered_duration_mean,
        recovered_duration_sd,
        random_infection_probabilities,
        mean_immunity_durations,
        num_years,
        immune_memory_susceptibility_levels,
        surrogate_training,
        lhs_step,
    )
end

main()
