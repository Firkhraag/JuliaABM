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
    # num_years = 1

    school_class_closure_period = 0
    # school_class_closure_period = 7
    school_class_closure_threshold = 0.2
    # school_class_closure_threshold = 1.0

    with_global_warming = false
    # with_global_warming = true

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

    # random_infection_probabilities = [0.000115, 6.7e-5, 4.9e-5, 7.0e-7]

    # MAE = 776.722131175678
    # RMSE = 1446.952317448403
    # nMAE = 0.44730605917617017
    # S_square = 3.048384989059306e9

    # MAE: 776.9342096399236
    # RMSE: 1438.5003122266721
    # nMAE: 0.4474281929203629
    # S_square: 3.012876263890196e9

    # MAE: 790.720796480595
    # RMSE: 1491.5262959851384
    # nMAE: 0.4553677424473687
    # S_square: 3.239091406991653e9

    # MAE: 787.808043843811
    # RMSE: 1473.363179696689
    # nMAE: 0.4536903190149467
    # S_square: 3.1606834303203254e9

    # MAE: 790.8494426813821
    # RMSE: 1470.723544655989
    # nMAE: 0.4554418284335823
    # S_square: 3.1493683964367733e9

    # MAE: 784.2127307752023
    # RMSE: 1464.2016310264898
    # nMAE: 0.45161981624996217
    # S_square: 3.1214986221337223e9

    # MAE: 790.6249734560037
    # RMSE: 1486.212934715746
    # nMAE: 0.45531255898112266
    # S_square: 3.2160548599326644e9

    # MAE: 784.1516083409904
    # RMSE: 1468.3793920871715
    # nMAE: 0.45158461648665266
    # S_square: 3.13933698493876e9

    # duration_parameter = 3.5197278911564607
    # susceptibility_parameters = [2.9858585858585855, 3.4123067408781673, 3.671511028653889, 4.94879406307978, 3.9835435992578914, 3.7442754071325477, 4.85515769944341]
    # temperature_parameters = [-0.7224056895485462, -0.9126984126984126, -0.28362110904968046, -0.05555555555555556, -0.1604607297464439, -0.15031787260358692, -0.4090290661719232]
    # random_infection_probabilities = [0.0029833333333333335, 0.002011111111111111, 0.0010033333333333333, 1.988888888888889e-5]
    # immune_memory_susceptibility_levels = [0.8223376623376625, 0.7409523809523808, 0.7325479282622139, 0.8144897959183673, 0.6539002267573694, 0.6857328385899814, 0.8413852813852813]
    # mean_immunity_durations = [257.85961657390226, 302.09956709956714, 104.94990723562151, 44.672232529375364, 105.39455782312926, 133.25561739847456, 130.09420737992173]

    # duration_parameter = 3.5197278911564607
    # susceptibility_parameters = [2.9858585858585855, 3.4123067408781673, 3.671511028653889, 4.94879406307978, 3.9835435992578914, 3.7442754071325477, 4.85515769944341]
    # temperature_parameters = [-0.9224056895485462, -0.9126984126984126, -0.28362110904968046, -0.55555555555555556, -0.1604607297464439, -0.15031787260358692, -0.4090290661719232]
    # random_infection_probabilities = [0.0029833333333333335, 0.002011111111111111, 0.0010033333333333333, 1.988888888888889e-5]
    # immune_memory_susceptibility_levels = [0.7723376623376625, 0.7409523809523808, 0.7325479282622139, 0.8144897959183673, 0.6539002267573694, 0.6857328385899814, 0.8413852813852813]
    # mean_immunity_durations = [257.85961657390226, 302.09956709956714, 104.94990723562151, 44.672232529375364, 105.39455782312926, 133.25561739847456, 130.09420737992173]

    # FluA + -
    # FluB + -
    # AdV 0.1
    # CoV + - 130.09420737992173 - 
    # PIV + -
    # RV +
    # RSV 0.2

    # FluA -
    # FluB -
    # AdV 0.15
    # CoV ---
    # PIV 133 -> 153 -0.15 - -0.25
    # RV 99 -> 150
    # RSV 4.7 -> 4.6
    # duration_parameter = 3.5197278911564607
    # susceptibility_parameters = [3.0258585858585855, 3.2123067408781673, 3.571511028653889, 4.64879406307978, 3.6835435992578914, 3.7442754071325477, 4.85515769944341]
    # temperature_parameters = [-0.9524056895485462, -0.9526984126984126, -0.05362110904968046, -0.40555555555555556, -0.1604607297464439, -0.25031787260358692, -0.4090290661719232]
    # random_infection_probabilities = [0.0015833333333333335, 0.001011111111111111, 0.0005033333333333333, 1.088888888888889e-5]
    # immune_memory_susceptibility_levels = [0.8023376623376625, 0.809523809523808, 0.905479282622139, 0.8644897959183673, 0.849002267573694, 0.8557328385899814, 0.8413852813852813]
    # mean_immunity_durations = [300.85961657390226, 302.09956709956714, 150.00990723562151, 64.672232529375364, 105.39455782312926, 153.25561739847456, 160.09420737992173]


    # MAE = 6361.932005494506
    # RMSE = 13286.249184413893
    # nMAE = 0.8508760965981269
    # S_square = 7.71058655161e11
    # duration_parameter = 3.5370748299319708
    # susceptibility_parameters = [3.073817769532055, 3.1827149041434732, 3.6072253143681747, 4.602875695732841, 3.719257884972177, 3.7575407132549965, 4.843933209647492]
    # temperature_parameters = [-0.9653061224489796, -0.9673469387755101, -0.07709049680478251, -0.4392290249433107, -0.1880117501546072, -0.23093011750154607, -0.4345392702535558]
    # random_infection_probabilities = [0.0015946428571428574, 0.0010014126984126983, 0.0005061068027210884, 1.0891111111111112e-5]
    # immune_memory_susceptibility_levels = [0.8066233766233768, 0.7938095238095223, 0.8554792826221389, 0.8459183673469387, 0.8147165532879797, 0.811447124304267, 0.8099567099567099]
    # mean_immunity_durations = [304.22696351267774, 303.6301793444651, 151.94868274582558, 65.99876314162026, 100.59863945578232, 157.23520923520925, 162.03298289012582]




    # duration_parameter = 3.2773964131106976
    # susceptibility_parameters = [3.1125850340136045, 3.376571840857553, 3.5534219748505502, 5.038146773861062, 3.9956957328385956, 3.9007689136260537, 4.6524469181612]
    # temperature_parameters = [-0.729115646258503, -0.945928674500103, -0.19397979797979797, -0.12122626262626261, -0.13760977118119966, -0.16354195011337874, -0.20555555555555546]
    # random_infection_probabilities = [0.00011640445269016696, 6.788884766027622e-5, 4.9130447330447355e-5, 6.997670583384872e-7]
    # mean_immunity_durations = [254.75613275613273, 298.2230467944754, 106.60214388785818, 43.368377654091915, 90.5388579674294, 119.93980622552051, 117.15357658214805]
    # immune_memory_susceptibility_levels = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    # immune_memory_susceptibility_levels = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]

    # duration_parameter = 3.5370748299319708
    # susceptibility_parameters = [3.073817769532055, 3.1827149041434732, 3.6072253143681747, 4.602875695732841, 3.719257884972177, 3.7575407132549965, 4.843933209647492]
    # temperature_parameters = [-0.9653061224489796, -0.9673469387755101, -0.07709049680478251, -0.4392290249433107, -0.1880117501546072, -0.23093011750154607, -0.4345392702535558]
    # random_infection_probabilities = [0.0015946428571428574, 0.0010014126984126983, 0.0005061068027210884, 1.0891111111111112e-5]
    # immune_memory_susceptibility_levels = [0.8066233766233768, 0.7938095238095223, 0.8554792826221389, 0.8459183673469387, 0.8147165532879797, 0.811447124304267, 0.8099567099567099]
    # mean_immunity_durations = [304.22696351267774, 303.6301793444651, 151.94868274582558, 65.99876314162026, 100.59863945578232, 157.23520923520925, 162.03298289012582]

    # duration_parameter = 3.5574829931972767
    # susceptibility_parameters = [3.0044300144300142, 3.215367965367963, 3.5827355184498075, 4.56410018552876, 3.7682374768089115, 3.726928468357037, 4.811280148423003]
    # temperature_parameters = [-0.9561224489795918, -0.9816326530612245, -0.09749866007008864, -0.45147392290249433, -0.1982158317872602, -0.25133828076685216, -0.4467841682127395]
    # random_infection_probabilities = [0.001573882812146725, 0.0010050920663433886, 0.0005075294877038477, 1.071400059706604e-5]
    # immune_memory_susceptibility_levels = [0.78417439703154, 0.8223809523809509, 0.8146629560915266, 0.8214285714285713, 0.7555328798185919, 0.7767532467532466, 0.9017934446505875]
    # mean_immunity_durations = [303.6147186147186, 308.11997526283244, 147.6629684601113, 64.97835497835496, 101.61904761904763, 160.29643372500516, 156.3186971758401]


    # MAE = 6571.27358058608
    # RMSE = 14334.982278444082
    # nMAE = 0.8453981938847971
    # nMAE_general = 0.3649560107297748
    # nMAE_0_2 = 0.6973600701626105
    # nMAE_3_6 = 0.4742691981723836
    # nMAE_7_14 = 0.4088317851983279
    # nMAE_15 = 0.3296031725527682
    # nMAE_FluA = 0.6387520286003925
    # nMAE_FluB = 0.6176622685796029
    # nMAE_RV = 0.4408954234385801
    # nMAE_RSV = 0.5822662181910151
    # nMAE_AdV = 0.48951016314832324
    # nMAE_PIV = 0.4036254725067902
    # nMAE_CoV = 0.4892696751046994
    # averaged_nMAE = 5.937001486385269
    # S_square = 8.97587819521e11
    duration_parameter = 3.5064625850340114
    susceptibility_parameters = [2.9758585858585858, 3.2378169449597998, 3.574572253143685, 4.580426716141004, 3.7784415584415645, 3.7983570397856083, 4.772504638218921]
    temperature_parameters = [-0.9479591836734693, -0.9734693877551021, -0.0607639661925376, -0.4392290249433107, -0.18597093382807656, -0.220726035868893, -0.48147804576375985]
    random_infection_probabilities = [0.001584873162447195, 0.0010001701708950636, 0.0005044479486163928, 1.090386337294646e-5]
    immune_memory_susceptibility_levels = [0.8433580705009278, 0.7958503401360529, 0.8677241805813226, 0.8663265306122448, 0.7310430839002245, 0.8522634508348793, 0.8915893630179345]
    mean_immunity_durations = [308.92084106369816, 304.85466914038346, 147.45888682745826, 62.733457019171276, 99.37414965986396, 158.4596990311276, 162.2370645227789]


    # MAE: 4239.586767399267
    # RMSE: 9906.025863955409
    # nMAE: 0.8426950365195615
    # S_square: 4.28628993887e11
    # immune_memory_susceptibility_levels = [0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6]


    # MAE = 6069.343406593406
    # RMSE = 12787.321483935426
    # nMAE = 0.8478329259277678
    # S_square = 7.14236100324e11
    # duration_parameter = 3.554421768707481
    # susceptibility_parameters = [3.023817769532055, 3.232714904143473, 3.577633477633481, 4.603896103896107, 3.7651762523191157, 3.7748876520305066, 4.816382189239329]
    # temperature_parameters = [-0.9183673469387754, -0.9857142857142857, -0.09647825190682333, -0.46678004535147394, -0.22168521954236228, -0.21154236239950525, -0.451886209029066]
    # random_infection_probabilities = [0.001583903425655977, 0.001004886987366375, 0.0005033180509509926, 1.0817762811791385e-5]
    # immune_memory_susceptibility_levels = [0.8056029684601115, 0.8070748299319713, 0.825887445887445, 0.8653061224489795, 0.7667573696145102, 0.8226716141001854, 0.8538342609771181]
    # mean_immunity_durations = [304.12492269635123, 308.6301793444651, 151.642560296846, 62.63141620284475, 98.45578231292518, 155.29643372500516, 160.91053391053399]


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

    # Only FluA
    # viruses = Virus[
    #     # FluA
    #     Virus(1.4, 0.67, 1, 7,  4.8, 2.04, 1, 28,  8.0, 3.4, 1, 28,  4.6, 3.5, 2.3,  0.38, 0.47, 0.57,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
    #     # FluB
    #     Virus(0.6, 0.19, 1, 7,  3.7, 3.0, 1, 28,  6.1, 4.8, 1, 28,  0.0, 0.0, 0.0,  0.38, 0.47, 0.57,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
    #     # RV
    #     Virus(1.9, 1.11, 1, 7,  10.1, 7.0, 1, 28,  11.4, 7.7, 1, 28,  0.0, 0.0, 0.0,  0.19, 0.24, 0.29,  mean_immunity_durations[3], mean_immunity_durations[3] * 0.33),
    #     # RSV
    #     Virus(4.4, 1.0, 1, 7,  6.5, 2.7, 1, 28,  6.7, 2.8, 1, 28,  0.0, 0.0, 0.0,  0.24, 0.3, 0.36,  mean_immunity_durations[4], mean_immunity_durations[4] * 0.33),
    #     # AdV
    #     Virus(5.6, 1.3, 1, 7,  8.0, 5.6, 1, 28,  9.0, 6.3, 1, 28,  0.0, 0.0, 0.0,  0.15, 0.19, 0.23,  mean_immunity_durations[5], mean_immunity_durations[5] * 0.33),
    #     # PIV
    #     Virus(2.6, 0.85, 1, 7,  7.0, 2.9, 1, 28,  8.0, 3.4, 1, 28,  0.0, 0.0, 0.0,  0.16, 0.2, 0.24,  mean_immunity_durations[6], mean_immunity_durations[6] * 0.33),
    #     # CoV
    #     Virus(3.2, 0.44, 1, 7,  6.5, 4.5, 1, 28,  7.5, 5.2, 1, 28,  0.0, 0.0, 0.0,  0.21, 0.26, 0.32,  mean_immunity_durations[7], mean_immunity_durations[7] * 0.33)]

    # Replace CoV with COVID
    # viruses = Virus[
    #     # FluA
    #     Virus(1.4, 0.67, 1, 7,  4.8, 2.04, 1, 28,  8.0, 3.4, 1, 28,  4.6, 3.5, 2.3,  0.38, 0.47, 0.57,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
    #     # FluB
    #     Virus(0.6, 0.19, 1, 7,  3.7, 3.0, 1, 28,  6.1, 4.8, 1, 28,  4.7, 3.5, 2.4,  0.38, 0.47, 0.57,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
    #     # RV
    #     Virus(1.9, 1.11, 1, 7,  10.1, 7.0, 1, 28,  11.4, 7.7, 1, 28,  3.5, 2.6, 1.8,  0.19, 0.24, 0.29,  mean_immunity_durations[3], mean_immunity_durations[3] * 0.33),
    #     # RSV
    #     Virus(4.4, 1.0, 1, 7,  6.5, 2.7, 1, 28,  6.7, 2.8, 1, 28,  6.0, 4.5, 3.0,  0.24, 0.3, 0.36,  mean_immunity_durations[4], mean_immunity_durations[4] * 0.33),
    #     # AdV
    #     Virus(5.6, 1.3, 1, 7,  8.0, 5.6, 1, 28,  9.0, 6.3, 1, 28,  4.1, 3.1, 2.1,  0.15, 0.19, 0.23,  mean_immunity_durations[5], mean_immunity_durations[5] * 0.33),
    #     # PIV
    #     Virus(2.6, 0.85, 1, 7,  7.0, 2.9, 1, 28,  8.0, 3.4, 1, 28,  4.8, 3.6, 2.4,  0.16, 0.2, 0.24,  mean_immunity_durations[6], mean_immunity_durations[6] * 0.33),
    #     # CoV
    #     Virus(5.2, 3.7, 1, 10,  20.0, 5.2, 1, 35,  20.0, 5.2, 1, 35,  6.0, 6.0, 6.0,  0.1, 0.4, 0.8,  180.0, 180.0 * 0.33)]

    # Only COVID
    # viruses = Virus[
    #     # FluA
    #     Virus(1.4, 0.67, 1, 7,  4.8, 2.04, 1, 28,  8.0, 3.4, 1, 28,  0.0, 0.0, 0.0,  0.38, 0.47, 0.57,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
    #     # FluB
    #     Virus(0.6, 0.19, 1, 7,  3.7, 3.0, 1, 28,  6.1, 4.8, 1, 28,  0.0, 0.0, 0.0,  0.38, 0.47, 0.57,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
    #     # RV
    #     Virus(1.9, 1.11, 1, 7,  10.1, 7.0, 1, 28,  11.4, 7.7, 1, 28,  0.0, 0.0, 0.0,  0.19, 0.24, 0.29,  mean_immunity_durations[3], mean_immunity_durations[3] * 0.33),
    #     # RSV
    #     Virus(4.4, 1.0, 1, 7,  6.5, 2.7, 1, 28,  6.7, 2.8, 1, 28,  0.0, 0.0, 0.0,  0.24, 0.3, 0.36,  mean_immunity_durations[4], mean_immunity_durations[4] * 0.33),
    #     # AdV
    #     Virus(5.6, 1.3, 1, 7,  8.0, 5.6, 1, 28,  9.0, 6.3, 1, 28,  0.0, 0.0, 0.0,  0.15, 0.19, 0.23,  mean_immunity_durations[5], mean_immunity_durations[5] * 0.33),
    #     # PIV
    #     Virus(2.6, 0.85, 1, 7,  7.0, 2.9, 1, 28,  8.0, 3.4, 1, 28,  0.0, 0.0, 0.0,  0.16, 0.2, 0.24,  mean_immunity_durations[6], mean_immunity_durations[6] * 0.33),
    #     # CoV
    #     Virus(5.2, 3.7, 1, 10,  20.0, 5.2, 1, 35,  20.0, 5.2, 1, 35,  6.0, 6.0, 6.0,  0.1, 0.4, 0.8,  180.0, 180.0 * 0.33)]

    # Only COVID
    # viruses = Virus[
    #     # FluA
    #     Virus(1.4, 0.67, 1, 7,  4.8, 2.04, 1, 28,  8.0, 3.4, 1, 28,  0.0, 0.0, 0.0,  0.38, 0.47, 0.57,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
    #     # FluB
    #     Virus(0.6, 0.19, 1, 7,  3.7, 3.0, 1, 28,  6.1, 4.8, 1, 28,  0.0, 0.0, 0.0,  0.38, 0.47, 0.57,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
    #     # RV
    #     Virus(1.9, 1.11, 1, 7,  10.1, 7.0, 1, 28,  11.4, 7.7, 1, 28,  0.0, 0.0, 0.0,  0.19, 0.24, 0.29,  mean_immunity_durations[3], mean_immunity_durations[3] * 0.33),
    #     # RSV
    #     Virus(4.4, 1.0, 1, 7,  6.5, 2.7, 1, 28,  6.7, 2.8, 1, 28,  0.0, 0.0, 0.0,  0.24, 0.3, 0.36,  mean_immunity_durations[4], mean_immunity_durations[4] * 0.33),
    #     # AdV
    #     Virus(5.6, 1.3, 1, 7,  8.0, 5.6, 1, 28,  9.0, 6.3, 1, 28,  0.0, 0.0, 0.0,  0.15, 0.19, 0.23,  mean_immunity_durations[5], mean_immunity_durations[5] * 0.33),
    #     # PIV
    #     Virus(2.6, 0.85, 1, 7,  7.0, 2.9, 1, 28,  8.0, 3.4, 1, 28,  0.0, 0.0, 0.0,  0.16, 0.2, 0.24,  mean_immunity_durations[6], mean_immunity_durations[6] * 0.33),
    #     # CoV
    #     Virus(5.2, 3.7, 1, 10,  8.0, 2.0, 1, 35,  20.0, 5.2, 1, 35,  6.0, 6.0, 6.0,  0.1, 0.4, 0.8,  180.0, 180.0 * 0.33)]

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

    infected_data_0 = infected_data_0_all[2:53, 24:26]
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
    infected_data_3 = infected_data_3_all[2:53, 24:26]
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
    infected_data_7 = infected_data_7_all[2:53, 24:26]
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
    infected_data_15 = infected_data_15_all[2:53, 24:26]
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

    num_all_infected_age_groups_viruses = cat(
        infected_data_0_viruses_prev,
        infected_data_3_viruses_prev,
        infected_data_7_viruses_prev,
        infected_data_15_viruses_prev,
        dims = 3,
    )

    for virus_id = 1:length(viruses)
        num_all_infected_age_groups_viruses[:, virus_id, 1] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[1]) * (1 - isolation_probabilities_day_2[1]) * (1 - isolation_probabilities_day_3[1]))
        num_all_infected_age_groups_viruses[:, virus_id, 2] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[2]) * (1 - isolation_probabilities_day_2[2]) * (1 - isolation_probabilities_day_3[2]))
        num_all_infected_age_groups_viruses[:, virus_id, 3] ./= viruses[virus_id].symptomatic_probability_teenager * (1 - (1 - isolation_probabilities_day_1[3]) * (1 - isolation_probabilities_day_2[3]) * (1 - isolation_probabilities_day_3[3]))
        num_all_infected_age_groups_viruses[:, virus_id, 4] ./= viruses[virus_id].symptomatic_probability_adult * (1 - (1 - isolation_probabilities_day_1[4]) * (1 - isolation_probabilities_day_2[4]) * (1 - isolation_probabilities_day_3[4]))
    end

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, households, viruses, num_all_infected_age_groups_viruses, isolation_probabilities_day_1,
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

    @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
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
        immune_memory_susceptibility_levels[7], school_class_closure_period, school_class_closure_threshold)

    # for k = 1:7
    #     println("Virus: $(k)")
    #     age_dist = sum(num_infected_age_groups_viruses[:, k, :], dims = 1)[1, :]
    #     println(age_dist ./ sum(age_dist))
    # end

    if with_global_warming
        save(joinpath(@__DIR__, "..", "output", "tables", "results_warming_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses,
            "activities_cases", activities_infections,
            "rt", rt)
    elseif school_class_closure_period == 0
        save(joinpath(@__DIR__, "..", "output", "tables", "results_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses,
            "activities_cases", activities_infections,
            "rt", rt)
    elseif school_class_closure_threshold > 0.99
        save(joinpath(@__DIR__, "..", "output", "tables", "results_class_quarantine_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses,
            "activities_cases", activities_infections,
            "rt", rt,
            "num_schools_closed", num_schools_closed)
    else
        save(joinpath(@__DIR__, "..", "output", "tables", "results_quarantine_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses,
            "activities_cases", activities_infections,
            "rt", rt,
            "num_schools_closed", num_schools_closed)
    end

    incidence_arr_mean = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]

    infected_data = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    infected_data_mean = vec(transpose(infected_data[42:44, 2:53]))

    nMAE_general = sum(abs.(incidence_arr_mean - infected_data_mean)) / sum(infected_data_mean)
    println("General nMAE: $(nMAE_general)")

    # ------------------
    incidence_arr_mean = sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :]

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_mean = cat(
        vec(infected_data_0[2:53, 24:26]),
        vec(infected_data_3[2:53, 24:26]),
        vec(infected_data_7[2:53, 24:26]),
        vec(infected_data_15[2:53, 24:26]),
        dims = 2,
    )

    nMAE_0_2 = sum(abs.(incidence_arr_mean[:, 1] - infected_data_mean[:, 1])) / sum(infected_data_mean[:, 1])
    println("0-2 nMAE: $(nMAE_0_2)")

    nMAE_3_6 = sum(abs.(incidence_arr_mean[:, 2] - infected_data_mean[:, 2])) / sum(infected_data_mean[:, 2])
    println("3-6 nMAE: $(nMAE_3_6)")

    nMAE_7_14 = sum(abs.(incidence_arr_mean[:, 3] - infected_data_mean[:, 3])) / sum(infected_data_mean[:, 3])
    println("7-14 nMAE: $(nMAE_7_14)")

    nMAE_15 = sum(abs.(incidence_arr_mean[:, 4] - infected_data_mean[:, 4])) / sum(infected_data_mean[:, 4])
    println("15+ nMAE: $(nMAE_15)")

    # ------------------

    incidence_arr_mean = sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1]

    infected_data = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    infected_data = transpose(infected_data[42:44, 2:53])

    etiology = get_etiology()

    infected_data_1 = etiology[:, 1] .* infected_data
    infected_data_2 = etiology[:, 2] .* infected_data
    infected_data_3 = etiology[:, 3] .* infected_data
    infected_data_4 = etiology[:, 4] .* infected_data
    infected_data_5 = etiology[:, 5] .* infected_data
    infected_data_6 = etiology[:, 6] .* infected_data
    infected_data_7 = etiology[:, 7] .* infected_data
    infected_data_viruses_mean = cat(
        vec(infected_data_1),
        vec(infected_data_2),
        vec(infected_data_3),
        vec(infected_data_4),
        vec(infected_data_5),
        vec(infected_data_6),
        vec(infected_data_7),
        dims = 2)

    nMAE_FluA = sum(abs.(incidence_arr_mean[:, 1] - infected_data_viruses_mean[:, 1])) / sum(infected_data_viruses_mean[:, 1])
    println("FluA nMAE: $(nMAE_FluA)")

    nMAE_FluB = sum(abs.(incidence_arr_mean[:, 2] - infected_data_viruses_mean[:, 2])) / sum(infected_data_viruses_mean[:, 2])
    println("FluB nMAE: $(nMAE_FluB)")

    nMAE_RV = sum(abs.(incidence_arr_mean[:, 3] - infected_data_viruses_mean[:, 3])) / sum(infected_data_viruses_mean[:, 3])
    println("RV nMAE: $(nMAE_RV)")

    nMAE_RSV = sum(abs.(incidence_arr_mean[:, 4] - infected_data_viruses_mean[:, 4])) / sum(infected_data_viruses_mean[:, 4])
    println("RSV nMAE: $(nMAE_RSV)")

    nMAE_AdV = sum(abs.(incidence_arr_mean[:, 5] - infected_data_viruses_mean[:, 5])) / sum(infected_data_viruses_mean[:, 5])
    println("AdV nMAE: $(nMAE_AdV)")

    nMAE_PIV = sum(abs.(incidence_arr_mean[:, 6] - infected_data_viruses_mean[:, 6])) / sum(infected_data_viruses_mean[:, 6])
    println("PIV nMAE: $(nMAE_PIV)")

    nMAE_CoV = sum(abs.(incidence_arr_mean[:, 7] - infected_data_viruses_mean[:, 7])) / sum(infected_data_viruses_mean[:, 7])
    println("CoV nMAE: $(nMAE_CoV)")

    averaged_nMAE = nMAE_FluA + nMAE_FluB + nMAE_RV + nMAE_RSV + nMAE_AdV + nMAE_PIV + nMAE_CoV + nMAE_general + nMAE_0_2 + nMAE_3_6 + nMAE_7_14 + nMAE_15
    println("Averaged nMAE: $(averaged_nMAE / 12)")


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

    MAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / (size(observed_num_infected_age_groups_viruses)[1] * size(observed_num_infected_age_groups_viruses)[2] * size(observed_num_infected_age_groups_viruses)[3])
    RMSE = sqrt(sum((observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses).^2)) / sqrt((size(observed_num_infected_age_groups_viruses)[1] * size(observed_num_infected_age_groups_viruses)[2] * size(observed_num_infected_age_groups_viruses)[3]))
    nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    S_square = sum((observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses).^2)

    println("MAE: ", MAE)
    println("RMSE: ", RMSE)
    println("nMAE: ", nMAE)
    println("S_square: ", S_square)
end

main()
