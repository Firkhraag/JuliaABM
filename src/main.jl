using Base.Threads
using Random
using DelimitedFiles
using Distributions
using DataFrames
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
include("model/connections.jl")

include("data/district_households.jl")
include("data/district_people.jl")
include("data/district_people_households.jl")
include("data/district_nums.jl")
include("data/temperature.jl")
include("data/etiology.jl")

include("util/moving_avg.jl")
include("util/stats.jl")
include("util/reset.jl")

function main()
    println("Initialization...")

    # Random seed number
    run_num = 0
    is_rt_run = true
    try
        run_num = parse(Int64, ARGS[1])
    catch
        run_num = 0
    end

    num_years = 3
    # num_years = 2
    # num_years = 1

    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # CHANGE
    school_class_closure_period = 0
    # school_class_closure_period = 7
    school_class_closure_threshold = 0.2
    # # school_class_closure_threshold = 1.0
    # 0.2  0.1  0.3  0.2_14  0.1_14

    with_global_warming = false
    # with_global_warming = true
    # ["+4 °С" "+3 °С" "+2 °С" "+1 °С"]

    is_herd_immunity_test = false
    # is_herd_immunity_test = true
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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
    # num_barabasi_albert_attachments = 6
    num_barabasi_albert_attachments = 5
    # num_barabasi_albert_attachments = 4

    # 4, 6, 9, 11

    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # duration_parameter = 3.2773964131106976
    # susceptibility_parameters = [3.1125850340136045, 3.376571840857553, 3.5534219748505502, 5.038146773861062, 3.9956957328385956, 3.9007689136260537, 4.6524469181612]
    # temperature_parameters = [-0.729115646258503, -0.945928674500103, -0.19397979797979797, -0.12122626262626261, -0.13760977118119966, -0.16354195011337874, -0.20555555555555546]
    # random_infection_probabilities = [0.00011640445269016696, 6.788884766027622e-5, 4.9130447330447355e-5, 6.997670583384872e-7]
    # mean_immunity_durations = [254.75613275613273, 298.2230467944754, 106.60214388785818, 43.368377654091915, 90.5388579674294, 119.93980622552051, 117.15357658214805]
    # immune_memory_susceptibility_levels = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    # immune_memory_susceptibility_levels = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]

    # 0.566982580791615
    # duration_parameter = 0.26733668341708544
    # susceptibility_parameters = [3.0307005776255167, 3.1607934669677986, 3.4273238632802836, 4.3725990337370515, 3.67390987352247, 3.8281846882573243, 4.746937978511825]
    # temperature_parameters = [-0.95, -0.8874797488598941, -0.05, -0.11936936936936937, -0.11488698235671589, -0.17735457724319717, -0.31083867585078234]
    # immune_memory_susceptibility_levels = [0.9381002876402393, 0.95, 0.9278778778778778, 0.8938438438438437, 0.9185685685685685, 0.8678178178178176, 0.9288288288288288]  
    # mean_immunity_durations = [346.6586428571901, 313.6876979491992, 143.00214714069438, 94.5655000618681, 113.27047767241473, 139.89128281137963, 161.06429368899117]  
    
    # 0.30088106
    # duration_parameter = 0.22087203695243898
    # susceptibility_parameters = [3.049892496817436, 3.040591446765778, 3.585909721866142, 4.500881862019878, 3.8466371462497424, 3.8756594357320724, 4.598453130026978]
    # temperature_parameters = [-0.9272727272727272, -0.8238433852235304, -0.03131313131313131, -0.12575757575757576, -0.04923041670015022, -0.16624346613208604, -0.4118487768608833]
    # immune_memory_susceptibility_levels = [0.9506255401654918, 1.0, 0.9543425243425242, 0.9550559650559649, 0.8613968513968513, 0.9175147875147873, 0.9666666666666667]
    # mean_immunity_durations = [365.90106709961435, 315.75840501990626, 130.9314400699873, 97.74731824368628, 103.42199282392987, 132.66906058915743, 172.22590985060734]
    
    # 0.5075304
    # duration_parameter = 0.2286529818247781
    # susceptibility_parameters = [3.399210897636838, 3.1728061892540365, 3.7133670840132975, 4.514159400580939, 4.132141960907326, 3.7028924058603057, 4.457680493723987]
    # temperature_parameters = [-0.9241494329553035, -0.8347287566159064, -0.041427618412274846, -0.15887460327086744, -0.04316210807204804, -0.08524131655088377, -0.37262734304305184]
    # immune_memory_susceptibility_levels = [0.92319580586451, 0.9437958639092727, 0.9450300200133421, 0.8788314113130655, 0.8489225419245432, 0.9259385851980914, 0.9468312208138758]
    # mean_immunity_durations = [350.21990592145517, 326.01561352928286, 132.7672767557239, 102.63690793647811, 112.97772358046116, 136.8702452172934, 157.89042693607172]

    # 0.3531766
    # duration_parameter = 0.20289612980694707
    # susceptibility_parameters = [3.3556372884051493, 3.4308390958428427, 3.524601289872367, 5.122774626583979, 3.9804060509040897, 3.692488052060438, 4.297332872928732]
    # temperature_parameters = [-0.9651825912956478, -0.8263292241025659, -0.05190322433944243, -0.15170211368310416, -0.09229614807403702, -0.0806428375349592, -0.2878461189662795]
    # immune_memory_susceptibility_levels = [0.8583717870262958, 0.9245493959100761, 0.9735786074855609, 0.9133816908454226, 0.9810354080489148, 0.9978989494747373, 0.9993996998499249]
    # mean_immunity_durations = [353.00921713422764, 341.1116877218633, 145.98255148428032, 105.65991090365264, 96.68751447364362, 140.33284197479972, 174.0615751580085] 

    # 0.500932
    # duration_parameter = 0.25349642995702204
    # susceptibility_parameters = [3.1660424910064493, 3.2144308917407916, 3.1861320552550585, 5.045836157349362, 3.8972644801186975, 3.8360598379533846, 4.335051732358446]
    # temperature_parameters = [-0.9552938085204219, -0.9040931060435365, -0.06683341670835417, -0.16418335430341433, -0.02981490745372685, -0.0629089706014925, -0.3277410664400163]
    # immune_memory_susceptibility_levels = [0.8732042032344, 0.9173708066154289, 0.88821092364364, 0.9114557278639318, 0.9770885442721361, 0.8750180846178843, 0.8813906953476738]
    # mean_immunity_durations = [364.56349427279696, 315.67396886243347, 127.43827934821226, 94.75946067854007, 95.80207175228294, 162.02868989876168, 173.65637255670785] 

    # 0.5252182067055252
    # duration_parameter = 0.23913925136772746
    # susceptibility_parameters = [3.150034487004448, 2.9160817171534976, 3.463270624539701, 4.523775126834105, 3.841036366061668, 3.7310073116902527, 4.557362887936236]
    # temperature_parameters = [-0.9942971485742872, -0.9644822411205602, -0.044774660057301394, -0.14472362443848188, -0.056478239119559785, -0.10127815519378863, -0.38106772977168213]
    # immune_memory_susceptibility_levels = [0.8665008515585619, 0.9123561780890445, 0.8668002182909635, 0.952576288144072, 0.969604692691236, 0.8545078294903204, 0.8988744372186093]
    # mean_immunity_durations = [372.97419962547326, 321.6369503531789, 119.33422732219925, 95.38977583611886, 113.4208811569853, 162.68902006384425, 161.50029451768836] 
    
    # nMAE = 0.5192907671087287
    # duration_parameter = 0.2506700167504188
    # susceptibility_parameters = [3.070094517019456, 3.1092783154526473, 3.4303541663105865, 4.646336407474424, 3.9415866411992377, 3.825154385227022, 4.622695554269402]
    # temperature_parameters = [-0.9095959595959595, -0.8748534862336315, -0.08181818181818182, -0.13434343434343435, -0.02121212121212121, -0.12331417320279311, -0.37599019100229747]
    # immune_memory_susceptibility_levels = [0.8971911967311483, 0.9196969696969696, 0.9254545454545454, 0.9608135408135406, 0.9170534170534169, 0.891151151151151, 0.9524242424242424]
    # mean_immunity_durations = [356.9111681097154, 324.2432535047547, 134.46679360534083, 98.65640915277719, 101.19977060170766, 145.29532321542004, 165.35722298192047]
    
    # nMAE = 0.5146137805717983
    duration_parameter = 0.23703365311405514
    susceptibility_parameters = [3.0731248200497587, 3.0315005376748694, 3.4960107319671523, 4.558457619595636, 3.9627987624113588, 3.751417011489648, 4.552998584572433]
    temperature_parameters = [-0.8747474747474746, -0.9177827791629244, -0.051010101010101006, -0.16313131313131315, -0.003030303030303022, -0.08442528431390421, -0.35326291827502476]
    immune_memory_susceptibility_levels = [0.8944639240038756, 0.9430303030303029, 0.9336363636363636, 0.9363636363636363, 0.8876594776594775, 0.8817572117572116, 0.946060606060606]
    mean_immunity_durations = [357.979797979798, 326.2129504744517, 133.30517744372466, 99.91903541540344, 105.99775039968745, 148.27512119521802, 162.6804553051528]
    random_infection_probabilities = [0.00138, 0.00077, 0.0004, 9.2e-6]

    # duration_parameter = 0.23703365311405514
    # susceptibility_parameters = [3.0731248200497587, 3.0315005376748694, 3.4960107319671523, 4.558457619595636, 3.9627987624113588, 3.751417011489648, 4.552998584572433]
    # temperature_parameters = [-0.8747474747474746, -0.9177827791629244, -0.051010101010101006, -0.16313131313131315, -0.003030303030303022, -0.08442528431390421, -0.35326291827502476]
    # immune_memory_susceptibility_levels = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]
    # mean_immunity_durations = [357.979797979798, 326.2129504744517, 133.30517744372466, 99.91903541540344, 105.99775039968745, 148.27512119521802, 162.6804553051528]
    # random_infection_probabilities = [0.00138, 0.00077, 0.0004, 9.2e-6]

    # CHANGE THE INDEX OF OUTPUT FILE!!!!!!!!!!
    # surrogate_index = 99
    # surrogate_index = 10
    # surrogate_index = 1006
    surrogate_index = 0
    # ------------------------

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
    temperature = get_air_temperature(with_global_warming)

    agents = Array{Agent, 1}(undef, num_agents)

    # With seed
    thread_rng = [MersenneTwister(i + run_num * num_threads) for i = 1:num_threads]

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

    # shop_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "shops.csv")))
    # # Массив для хранения продовольственных магазинов
    # shops = Array{PublicSpace, 1}(undef, num_shops)
    # for i in 1:size(shop_coords_df, 1)
    #     shops[i] = PublicSpace(
    #         shop_coords_df[i, :dist],
    #         shop_coords_df[i, :x],
    #         shop_coords_df[i, :y],
    #         ceil(Int, rand(Gamma(shop_capacity_shape, shop_capacity_scale))),
    #         shop_num_groups,
    #     )
    # end

    # restaurant_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "restaurants.csv")))
    # # Массив для хранения ресторанов/кафе/столовых
    # restaurants = Array{PublicSpace, 1}(undef, num_restaurants)
    # for i in 1:size(restaurant_coords_df, 1)
    #     restaurants[i] = PublicSpace(
    #         restaurant_coords_df[i, :dist],
    #         restaurant_coords_df[i, :x],
    #         restaurant_coords_df[i, :y],
    #         restaurant_coords_df[i, :seats],
    #         restaurant_num_groups,
    #     )
    # end

    infected_data_0_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_0 = infected_data_0_all[2:53, 24:(23 + num_years)]
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

    # infected_data_3 = infected_data_3[2:53, 21:27]
    infected_data_3 = infected_data_3_all[2:53, 24:(23 + num_years)]
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

    # infected_data_7 = infected_data_7[2:53, 21:27]
    infected_data_7 = infected_data_7_all[2:53, 24:(23 + num_years)]
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

    # infected_data_15 = infected_data_15[2:53, 21:27]
    infected_data_15 = infected_data_15_all[2:53, 24:(23 + num_years)]
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


    infected_data_0_prev = infected_data_0_all[2:53, 23]
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

    # infected_data_3 = infected_data_3[2:53, 21:27]
    infected_data_3_prev = infected_data_3_all[2:53, 23]
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

    # infected_data_7 = infected_data_7[2:53, 21:27]
    infected_data_7_prev = infected_data_7_all[2:53, 23]
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

    # infected_data_15 = infected_data_15[2:53, 21:27]
    infected_data_15_prev = infected_data_15_all[2:53, 23]
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

    # println(num_infected_age_groups_viruses_prev[17, 3, 4] / num_agents_age_groups[4])
    # return

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

    # get_stats(agents, schools, workplaces)
    # return
    # println()

    println("Simulation...")

    # duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    # duration_parameter = mean(duration_parameter_array[burnin:step:end])
    
    # susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    # susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    # susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    # susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    # susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    # susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    # susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))
    # susceptibility_parameters = [
    #     mean(susceptibility_parameter_1_array[burnin:step:end]),
    #     mean(susceptibility_parameter_2_array[burnin:step:end]),
    #     mean(susceptibility_parameter_3_array[burnin:step:end]),
    #     mean(susceptibility_parameter_4_array[burnin:step:end]),
    #     mean(susceptibility_parameter_5_array[burnin:step:end]),
    #     mean(susceptibility_parameter_6_array[burnin:step:end]),
    #     mean(susceptibility_parameter_7_array[burnin:step:end])
    # ]

    # temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    # temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    # temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    # temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    # temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    # temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    # temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))
    # temperature_parameters = -[
    #     mean(temperature_parameter_1_array[burnin:step:end]),
    #     mean(temperature_parameter_2_array[burnin:step:end]),
    #     mean(temperature_parameter_3_array[burnin:step:end]),
    #     mean(temperature_parameter_4_array[burnin:step:end]),
    #     mean(temperature_parameter_5_array[burnin:step:end]),
    #     mean(temperature_parameter_6_array[burnin:step:end]),
    #     mean(temperature_parameter_7_array[burnin:step:end])
    # ]

    # duration_parameter = rand(duration_parameter_array[burnin:step:end])

    # susceptibility_parameters = [
    #     rand(susceptibility_parameter_1_array[burnin:step:end]),
    #     rand(susceptibility_parameter_2_array[burnin:step:end]),
    #     rand(susceptibility_parameter_3_array[burnin:step:end]),
    #     rand(susceptibility_parameter_4_array[burnin:step:end]),
    #     rand(susceptibility_parameter_5_array[burnin:step:end]),
    #     rand(susceptibility_parameter_6_array[burnin:step:end]),
    #     rand(susceptibility_parameter_7_array[burnin:step:end])
    # ]

    # temperature_parameters = -[
    #     rand(temperature_parameter_1_array[burnin:step:end]),
    #     rand(temperature_parameter_2_array[burnin:step:end]),
    #     rand(temperature_parameter_3_array[burnin:step:end]),
    #     rand(temperature_parameter_4_array[burnin:step:end]),
    #     rand(temperature_parameter_5_array[burnin:step:end]),
    #     rand(temperature_parameter_6_array[burnin:step:end]),
    #     rand(temperature_parameter_7_array[burnin:step:end])
    # ]

    # @time @threads for thread_id = 1:num_threads
    #     for agent_id = start_agent_ids[thread_id]:end_agent_ids[thread_id]
    #         agent = agents[agent_id]
    #         if agent.age > 18
    #             agent.FluA_immunity_susceptibility_level = immune_memory_susceptibility_levels[1]
    #             agent.FluB_immunity_susceptibility_level = immune_memory_susceptibility_levels[2]
    #             agent.RV_immunity_susceptibility_level = immune_memory_susceptibility_levels[3]
    #             agent.RSV_immunity_susceptibility_level = immune_memory_susceptibility_levels[4]
    #             agent.AdV_immunity_susceptibility_level = immune_memory_susceptibility_levels[5]
    #             agent.PIV_immunity_susceptibility_level = immune_memory_susceptibility_levels[6]
    #             agent.CoV_immunity_susceptibility_level = immune_memory_susceptibility_levels[7]
    #         end
    #     end
    # end

    @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses_model, activities_infections, rt, num_schools_closed = run_simulation(
        num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
        susceptibility_parameters, temperature_parameters, temperature,
        mean_household_contact_durations, household_contact_duration_sds,
        other_contact_duration_shapes, other_contact_duration_scales,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, random_infection_probabilities,
        recovered_duration_mean, recovered_duration_sd, num_years, is_rt_run,
        immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
        immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
        immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
        immune_memory_susceptibility_levels[7], school_class_closure_period, 
        school_class_closure_threshold, with_global_warming)

    # for k = 1:7
    #     println("Virus: $(k)")
    #     age_dist = sum(num_infected_age_groups_viruses[:, k, :], dims = 1)[1, :]
    #     println(age_dist ./ sum(age_dist))
    # end

    if with_global_warming
        save(joinpath(@__DIR__, "..", "output", "tables", "results_warming_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses_model,
            "activities_cases", activities_infections,
            "rt", rt)
    elseif is_herd_immunity_test
        save(joinpath(@__DIR__, "..", "output", "tables", "results_herd_immunity_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses_model,
            "activities_cases", activities_infections,
            "rt", rt)
    elseif school_class_closure_period == 0
        save(joinpath(@__DIR__, "..", "output", "tables", "results_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses_model,
            "activities_cases", activities_infections,
            "rt", rt)
    elseif school_class_closure_threshold > 0.99
        save(joinpath(@__DIR__, "..", "output", "tables", "results_class_quarantine_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses_model,
            "activities_cases", activities_infections,
            "rt", rt,
            "num_schools_closed", num_schools_closed)        
    else
        save(joinpath(@__DIR__, "..", "output", "tables", "results_quarantine_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses_model,
            "activities_cases", activities_infections,
            "rt", rt,
            "num_schools_closed", num_schools_closed)
    end

    # !!!!!!!!!!!!!!!!!!!!!!!!
    # Surrogate model training
    if surrogate_index != 0
        save(joinpath(@__DIR__, "..", "parameters_labels", "surrogate", "tables", "results_$(surrogate_index).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "duration_parameter", duration_parameter,
            "susceptibility_parameters", susceptibility_parameters,
            "temperature_parameters", temperature_parameters,
            "random_infection_probabilities", random_infection_probabilities,
            "immune_memory_susceptibility_levels", immune_memory_susceptibility_levels,
            "mean_immunity_durations", [viruses[1].mean_immunity_duration, viruses[2].mean_immunity_duration, viruses[3].mean_immunity_duration, viruses[4].mean_immunity_duration, viruses[5].mean_immunity_duration, viruses[6].mean_immunity_duration, viruses[7].mean_immunity_duration])
    end
    # !!!!!!!!!!!!!!!!!!!!!!!!

    nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    println(nMAE)




    # incidence_arr_mean = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]

    # infected_data = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    # infected_data_mean = vec(transpose(infected_data[42:44, 2:53]))

    # nMAE_general = sum(abs.(incidence_arr_mean - infected_data_mean)) / sum(infected_data_mean)
    # println("General nMAE: $(nMAE_general)")

    # # ------------------
    # incidence_arr_mean = sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :]

    # infected_data_0 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    # infected_data_3 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    # infected_data_7 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    # infected_data_15 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    # infected_data_mean = cat(
    #     vec(infected_data_0[2:53, 24:26]),
    #     vec(infected_data_3[2:53, 24:26]),
    #     vec(infected_data_7[2:53, 24:26]),
    #     vec(infected_data_15[2:53, 24:26]),
    #     dims = 2,
    # )

    # nMAE_0_2 = sum(abs.(incidence_arr_mean[:, 1] - infected_data_mean[:, 1])) / sum(infected_data_mean[:, 1])
    # println("0-2 nMAE: $(nMAE_0_2)")

    # nMAE_3_6 = sum(abs.(incidence_arr_mean[:, 2] - infected_data_mean[:, 2])) / sum(infected_data_mean[:, 2])
    # println("3-6 nMAE: $(nMAE_3_6)")

    # nMAE_7_14 = sum(abs.(incidence_arr_mean[:, 3] - infected_data_mean[:, 3])) / sum(infected_data_mean[:, 3])
    # println("7-14 nMAE: $(nMAE_7_14)")

    # nMAE_15 = sum(abs.(incidence_arr_mean[:, 4] - infected_data_mean[:, 4])) / sum(infected_data_mean[:, 4])
    # println("15+ nMAE: $(nMAE_15)")

    # # ------------------

    # incidence_arr_mean = sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1]

    # infected_data = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    # infected_data = transpose(infected_data[42:44, 2:53])

    # etiology = get_etiology()

    # infected_data_1 = etiology[:, 1] .* infected_data
    # infected_data_2 = etiology[:, 2] .* infected_data
    # infected_data_3 = etiology[:, 3] .* infected_data
    # infected_data_4 = etiology[:, 4] .* infected_data
    # infected_data_5 = etiology[:, 5] .* infected_data
    # infected_data_6 = etiology[:, 6] .* infected_data
    # infected_data_7 = etiology[:, 7] .* infected_data
    # infected_data_viruses_mean = cat(
    #     vec(infected_data_1),
    #     vec(infected_data_2),
    #     vec(infected_data_3),
    #     vec(infected_data_4),
    #     vec(infected_data_5),
    #     vec(infected_data_6),
    #     vec(infected_data_7),
    #     dims = 2)

    # nMAE_FluA = sum(abs.(incidence_arr_mean[:, 1] - infected_data_viruses_mean[:, 1])) / sum(infected_data_viruses_mean[:, 1])
    # println("FluA nMAE: $(nMAE_FluA)")

    # nMAE_FluB = sum(abs.(incidence_arr_mean[:, 2] - infected_data_viruses_mean[:, 2])) / sum(infected_data_viruses_mean[:, 2])
    # println("FluB nMAE: $(nMAE_FluB)")

    # nMAE_RV = sum(abs.(incidence_arr_mean[:, 3] - infected_data_viruses_mean[:, 3])) / sum(infected_data_viruses_mean[:, 3])
    # println("RV nMAE: $(nMAE_RV)")

    # nMAE_RSV = sum(abs.(incidence_arr_mean[:, 4] - infected_data_viruses_mean[:, 4])) / sum(infected_data_viruses_mean[:, 4])
    # println("RSV nMAE: $(nMAE_RSV)")

    # nMAE_AdV = sum(abs.(incidence_arr_mean[:, 5] - infected_data_viruses_mean[:, 5])) / sum(infected_data_viruses_mean[:, 5])
    # println("AdV nMAE: $(nMAE_AdV)")

    # nMAE_PIV = sum(abs.(incidence_arr_mean[:, 6] - infected_data_viruses_mean[:, 6])) / sum(infected_data_viruses_mean[:, 6])
    # println("PIV nMAE: $(nMAE_PIV)")

    # nMAE_CoV = sum(abs.(incidence_arr_mean[:, 7] - infected_data_viruses_mean[:, 7])) / sum(infected_data_viruses_mean[:, 7])
    # println("CoV nMAE: $(nMAE_CoV)")

    # averaged_nMAE = nMAE_FluA + nMAE_FluB + nMAE_RV + nMAE_RSV + nMAE_AdV + nMAE_PIV + nMAE_CoV + nMAE_general + nMAE_0_2 + nMAE_3_6 + nMAE_7_14 + nMAE_15
    # println("Averaged nMAE: $(averaged_nMAE / 12)")


    # observed_num_infected_age_groups_viruses_mean = zeros(Float64, 52, 7, 4)
    # for i = 1:num_years
    #     for j = 1:52
    #         for k = 1:7
    #             for z = 1:4
    #                 observed_num_infected_age_groups_viruses_mean[j, k, z] += observed_num_infected_age_groups_viruses[52 * (i - 1) + j, k, z]
    #             end
    #         end
    #     end
    # end
    # for j = 1:52
    #     for k = 1:7
    #         for z = 1:4
    #             observed_num_infected_age_groups_viruses_mean[j, k, z] /= num_years
    #         end
    #     end
    # end

    # MAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / (size(observed_num_infected_age_groups_viruses)[1] * size(observed_num_infected_age_groups_viruses)[2] * size(observed_num_infected_age_groups_viruses)[3])
    # RMSE = sqrt(sum((observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses).^2)) / sqrt((size(observed_num_infected_age_groups_viruses)[1] * size(observed_num_infected_age_groups_viruses)[2] * size(observed_num_infected_age_groups_viruses)[3]))
    # nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    # S_square = sum((observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses).^2)

    # println("MAE: ", MAE)
    # println("RMSE: ", RMSE)
    # println("nMAE: ", nMAE)
    # println("S_square: ", S_square)
end

main()
