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
    # num_years = 1

    # school_class_closure_period = 0
    school_class_closure_period = 7
    school_class_closure_threshold = 0.2
    # school_class_closure_threshold = 1.0

    # with_global_warming = false
    with_global_warming = true

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

    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # duration_parameter = 3.2773964131106976
    # susceptibility_parameters = [3.1125850340136045, 3.376571840857553, 3.5534219748505502, 5.038146773861062, 3.9956957328385956, 3.9007689136260537, 4.6524469181612]
    # temperature_parameters = [-0.729115646258503, -0.945928674500103, -0.19397979797979797, -0.12122626262626261, -0.13760977118119966, -0.16354195011337874, -0.20555555555555546]
    # random_infection_probabilities = [0.00011640445269016696, 6.788884766027622e-5, 4.9130447330447355e-5, 6.997670583384872e-7]
    # mean_immunity_durations = [254.75613275613273, 298.2230467944754, 106.60214388785818, 43.368377654091915, 90.5388579674294, 119.93980622552051, 117.15357658214805]
    # immune_memory_susceptibility_levels = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    # immune_memory_susceptibility_levels = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]

    # MAE = 8102.385989010989
    # RMSE = 16730.329106749414
    # nMAE = 0.8479873742178521
    # nMAE_general = 0.25513686616373477
    # nMAE_0_2 = 0.6545364358790557
    # nMAE_3_6 = 0.3961378251502477
    # nMAE_7_14 = 0.32563074370904216
    # nMAE_15 = 0.3032275815743922
    # nMAE_FluA = 0.6056144791641577
    # nMAE_FluB = 0.5076132194545417
    # nMAE_RV = 0.4352634322160331
    # nMAE_RSV = 0.40660058519171355
    # nMAE_AdV = 0.4001107236423587
    # nMAE_PIV = 0.4842520506463988
    # nMAE_CoV = 0.4982699023670046
    # averaged_nMAE = 0.4393661537632234
    # S_square = 1.222620287704e12

    # General nMAE: 0.2506881832027814
    # 0-2 nMAE: 0.6461553313108865
    # 3-6 nMAE: 0.3888596460345688
    # 7-14 nMAE: 0.323896576158904
    # 15+ nMAE: 0.33122639315886016
    # FluA nMAE: 0.6705909396458998
    # FluB nMAE: 0.502560439240627
    # RV nMAE: 0.4318371312131939
    # RSV nMAE: 0.38739045761831264
    # AdV nMAE: 0.3933432644831207
    # PIV nMAE: 0.46022862820825183
    # CoV nMAE: 0.49548727419467103
    # Averaged nMAE: 0.4401886887058399
    # MAE: 8398.460851648351
    # RMSE: 17296.080309722118
    # nMAE: 0.8476036573284913
    # S_square: 1.306706393343e12

    # duration_parameter = 3.4530208693646935
    # susceptibility_parameters = [2.961469101251183, 3.167287716319191, 3.4916943562222045, 4.6394720291814755, 3.7734951731077695, 3.884105915607123, 4.764410553127257]
    # temperature_parameters = [-0.9186440677966101, -0.8710653753026634, -0.058308068579255024, -0.18910795956800802, -0.15449393624938407, -0.13182946028950876, -0.39406884479523696]
    # random_infection_probabilities = [0.0014940628663457143, 0.0008840743021979316, 0.00038872171014607207, 9.17650342489106e-6]
    # immune_memory_susceptibility_levels = [0.9098056664884753, 0.9358503401360532, 0.970090143915809, 1.0089242476651676, 0.934450209462314, 0.9150099053488884, 1.0415254237288136]
    # mean_immunity_durations = [335.0017819146148, 302.32613230191924, 148.23370522939533, 92.42560506483024, 101.87847342326762, 140.87062950501206, 159.8814782204614]



    # MAE = 8683.582417582418
    # RMSE = 17815.995514189774
    # nMAE = 0.8502453871922001
    # nMAE_general = 0.237919895385082
    # nMAE_0_2 = 0.6396720678457655
    # nMAE_3_6 = 0.3815110550869543
    # nMAE_7_14 = 0.31745977687080806
    # nMAE_15 = 0.32700183429353863
    # nMAE_FluA = 0.6021207767412515
    # nMAE_FluB = 0.5294840476215472
    # nMAE_RV = 0.4327819296216451
    # nMAE_RSV = 0.3609777583463659
    # nMAE_AdV = 0.41331869167554947
    # nMAE_PIV = 0.4626687141502982
    # nMAE_CoV = 0.5004632195849813
    # averaged_nMAE = 0.43378164726864893
    # S_square = 1.386445552834e12

    # General nMAE: 0.2389263428020665
    # 0-2 nMAE: 0.6376920691192086
    # 3-6 nMAE: 0.38131012376167484
    # 7-14 nMAE: 0.3200552604547177
    # 15+ nMAE: 0.32643010308212983
    # FluA nMAE: 0.6027255422174531
    # FluB nMAE: 0.5142322596181319
    # RV nMAE: 0.43699067849472284
    # RSV nMAE: 0.37952346247073987
    # AdV nMAE: 0.4070493760979797
    # PIV nMAE: 0.46584590592825603
    # CoV nMAE: 0.4854604937851724
    # Averaged nMAE: 0.4330201348193545
    # MAE: 8692.579441391941
    # RMSE: 17852.061279780613
    # nMAE: 0.8502270291370108
    # S_square: 1.392064529581e12

    duration_parameter = 3.498939236711632
    susceptibility_parameters = [2.954326244108326, 3.1560632265232726, 3.4743474174466944, 4.6302883557120875, 3.7234951731077697, 3.903493670709164, 4.798084022515011]
    temperature_parameters = [-0.9625216188170184, -0.8475959875475613, -0.05116521143639788, -0.15339367385372232, -0.1106163852289759, -0.16754374600379446, -0.37876272234625735]
    random_infection_probabilities = [0.0014894892045099622, 0.0008773986390997023, 0.00038784906957227476, 9.133430041468102e-6]
    immune_memory_susceptibility_levels = [0.882254646080312, 0.9429931972789103, 0.9956003479974416, 1.0, 0.9599604135439468, 0.9548058237162353, 1.0]
    mean_immunity_durations = [336.9405574248189, 299.775111893756, 144.25411339266063, 87.6296866974833, 102.7968407702064, 139.13593562746104, 161.6161720980124]


    # MAE = 8639.414606227107
    # RMSE = 17175.830856418204
    # nMAE = 0.8505482082370887
    # nMAE_general = 0.2486548195610226
    # nMAE_0_2 = 0.6424705618965266
    # nMAE_3_6 = 0.3902000468839759
    # nMAE_7_14 = 0.32432613555839973
    # nMAE_15 = 0.3268277055829695
    # nMAE_FluA = 0.6018550684027654
    # nMAE_FluB = 0.5583049304509083
    # nMAE_RV = 0.41676345517493973
    # nMAE_RSV = 0.35179163393348056
    # nMAE_AdV = 0.44342727603986637
    # nMAE_PIV = 0.44561201875720674
    # nMAE_CoV = 0.47150893501389346
    # averaged_nMAE = 0.4351452156046629
    # S_square = 1.288600035377e12
    duration_parameter = 3.4509800530381627
    susceptibility_parameters = [2.992081346149142, 3.1081040428498032, 3.5039392541813883, 4.666002641426373, 3.734719662903688, 3.8943099972397763, 4.792981981698685]
    temperature_parameters = [-0.9795918367346939, -0.8486163957108266, -0.08892031347721421, -0.1646181636496407, -0.0932694464534657, -0.16244170518746792, -0.3552933345911553]
    random_infection_probabilities = [0.0014958727296721477, 0.0008696990183892356, 0.00038792822244361605, 9.075647116715957e-6]
    immune_memory_susceptibility_levels = [0.8710301562843936, 0.9664625850340124, 0.9612244897959183, 1.0, 0.9387755102040816, 0.9979591836734694, 0.9857142857142857]
    mean_immunity_durations = [339.8997410982883, 303.7547037304907, 145.98880727021165, 84.46642139136084, 105.14377954571661, 143.93185399480797, 159.67739658780832]


    # MAE = 8367.131868131868
    # RMSE = 17692.943564411304
    # nMAE = 0.8503121662148553
    # nMAE_general = 0.2527112480733252
    # nMAE_0_2 = 0.6557780429643292
    # nMAE_3_6 = 0.405839201701562
    # nMAE_7_14 = 0.337900652029421
    # nMAE_15 = 0.3114757020693931
    # nMAE_FluA = 0.610889973872293
    # nMAE_FluB = 0.4904646331721652
    # nMAE_RV = 0.4483434075326882
    # nMAE_RSV = 0.3370852493256379
    # nMAE_AdV = 0.3719756938248375
    # nMAE_PIV = 0.4570337894830851
    # nMAE_CoV = 0.4871934297628088
    # averaged_nMAE = 0.4305575853176289
    # S_square = 1.36735982062e12
    duration_parameter = 3.5081229101810196
    susceptibility_parameters = [2.9288160400266934, 3.204022410196742, 3.4467963970385314, 4.6762067230590265, 3.7163523159649126, 3.888187548260184, 4.837879940882358]
    temperature_parameters = [-0.9959183673469387, -0.8975959875475613, -0.058308068579255024, -0.10339367385372232, -0.11163679339224122, -0.1379519092691006, -0.34713006928503287]
    random_infection_probabilities = [0.0014794579506836707, 0.0008793683095140078, 0.0003872949994728858, 9.187485035591078e-6]
    immune_memory_susceptibility_levels = [0.8649077073048018, 0.915442176870747, 0.9775510204081632, 0.9530612244897959, 0.9061224489795917, 0.9530612244897959, 0.9081632653061223]
    mean_immunity_durations = [335.614026812574, 302.93837719987846, 139.86635829061981, 87.3235642485037, 101.4703101579615, 141.27879277031818, 158.45290679188997]

    # General nMAE: 0.2529496646269521
    # 0-2 nMAE: 0.6525358977466218
    # 3-6 nMAE: 0.3996343736824615
    # 7-14 nMAE: 0.3313699209544788
    # 15+ nMAE: 0.3104650321647247
    # FluA nMAE: 0.6218986582468308
    # FluB nMAE: 0.5048825254601097
    # RV nMAE: 0.44770732221259674
    # RSV nMAE: 0.3388655167337147
    # AdV nMAE: 0.37477864923706805
    # PIV nMAE: 0.457202191109794
    # CoV nMAE: 0.48248485336257524
    # Averaged nMAE: 0.43123121712816065
    # MAE: 8358.65544871795
    # RMSE: 17560.819993603844
    # nMAE: 0.8500932805283073
    # S_square: 1.347014318167e12
    # duration_parameter = 3.4981229101810196
    # susceptibility_parameters = [2.954326244108326, 3.204022410196742, 3.4467963970385314, 4.6762067230590265, 3.7163523159649126, 3.888187548260184, 4.837879940882358]
    # temperature_parameters = [-0.9659183673469387, -0.8975959875475613, -0.058308068579255024, -0.10339367385372232, -0.11163679339224122, -0.1379519092691006, -0.34713006928503287]
    # random_infection_probabilities = [0.0014794579506836707, 0.0008793683095140078, 0.0003872949994728858, 9.187485035591078e-6]
    # immune_memory_susceptibility_levels = [0.882254646080312, 0.915442176870747, 0.9775510204081632, 0.9530612244897959, 0.9061224489795917, 0.9530612244897959, 0.9081632653061223]
    # mean_immunity_durations = [336.9405574248189, 302.93837719987846, 139.86635829061981, 87.3235642485037, 101.4703101579615, 141.27879277031818, 158.45290679188997]

    # MAE = 8663.269001831502
    # RMSE = 18628.12087132402
    # nMAE = 0.8524129372677983
    # nMAE_general = 0.2403411364977252
    # nMAE_0_2 = 0.6494755262709271
    # nMAE_3_6 = 0.396511351331857
    # nMAE_7_14 = 0.3273033886853395
    # nMAE_15 = 0.31583202004805333
    # nMAE_FluA = 0.5960861433037131
    # nMAE_FluB = 0.5045083619825148
    # nMAE_RV = 0.4543247425811245
    # nMAE_RSV = 0.34443620960421767
    # nMAE_AdV = 0.4120379241126699
    # nMAE_PIV = 0.4534597210854482
    # nMAE_CoV = 0.49009863399381226
    # averaged_nMAE = 0.43203459662478355
    # S_square = 1.515726083275e12
    duration_parameter = 3.4981229101810194
    susceptibility_parameters = [2.991060937985877, 3.2468795530538848, 3.401898437854858, 4.649676110814129, 3.7163523159649126, 3.8596161196887557, 4.856247287821134]
    temperature_parameters = [-0.9306122448979591, -0.9078000691802144, -0.01428571428571429, -0.12176102079249784, -0.16673883420856778, -0.19917639906501897, -0.33896680397891044]
    random_infection_probabilities = [0.0014812661428353913, 0.0008664926507337254, 0.0003871328065857679, 9.304102575238382e-6]
    immune_memory_susceptibility_levels = [0.8659281154680671, 0.9648299319727879, 0.9616326530612245, 0.9726530612244898, 0.9628571428571429, 0.9738775510204082, 0.8885714285714285]
    mean_immunity_durations = [336.32831252685975, 308.6526629141642, 132.1112562498035, 92.83376833013635, 100.85806526000232, 141.48287440297122, 160.4937231184206]


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

    # println(num_all_infected_age_groups_viruses[17, 3, 4] / num_agents_age_groups[4])
    # return

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
