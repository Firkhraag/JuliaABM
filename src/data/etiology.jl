# Распределение вирусов в течение года
function get_etiology()::Matrix{Float64}
    FluA_matrix = Matrix{Float64}(DataFrame(CSV.File(joinpath(@__DIR__, "..", "..", "input", "tables", "fluA.csv"))))
    FluB_matrix = Matrix{Float64}(DataFrame(CSV.File(joinpath(@__DIR__, "..", "..", "input", "tables", "fluB.csv"))))
    RV_matrix = Matrix{Float64}(DataFrame(CSV.File(joinpath(@__DIR__, "..", "..", "input", "tables", "RV.csv"))))
    RSV_matrix = Matrix{Float64}(DataFrame(CSV.File(joinpath(@__DIR__, "..", "..", "input", "tables", "RSV.csv"))))
    AdV_matrix = Matrix{Float64}(DataFrame(CSV.File(joinpath(@__DIR__, "..", "..", "input", "tables", "AdV.csv"))))
    PIV_matrix = Matrix{Float64}(DataFrame(CSV.File(joinpath(@__DIR__, "..", "..", "input", "tables", "PIV.csv"))))
    CoV_matrix = Matrix{Float64}(DataFrame(CSV.File(joinpath(@__DIR__, "..", "..", "input", "tables", "CoV.csv"))))

    # Средняя заболеваемость за год
    FluA_arr = FluA_matrix[1, :]
    for i = 2:size(FluA_matrix, 1)
        FluA_arr += FluA_matrix[i, :]
    end
    FluA_arr ./= size(FluA_matrix, 1)

    FluB_arr = FluB_matrix[1, :]
    for i = 2:size(FluB_matrix, 1)
        FluB_arr += FluB_matrix[i, :]
    end
    FluB_arr ./= size(FluB_matrix, 1)

    RV_arr = RV_matrix[1, :]
    for i = 2:size(RV_matrix, 1)
        RV_arr += RV_matrix[i, :]
    end
    RV_arr ./= size(RV_matrix, 1)

    RSV_arr = RSV_matrix[1, :]
    for i = 2:size(RSV_matrix, 1)
        RSV_arr += RSV_matrix[i, :]
    end
    RSV_arr ./= size(RSV_matrix, 1)

    AdV_arr = AdV_matrix[1, :]
    for i = 2:size(AdV_matrix, 1)
        AdV_arr += AdV_matrix[i, :]
    end
    AdV_arr ./= size(AdV_matrix, 1)

    PIV_arr = PIV_matrix[1, :]
    for i = 2:size(PIV_matrix, 1)
        PIV_arr += PIV_matrix[i, :]
    end
    PIV_arr ./= size(PIV_matrix, 1)

    CoV_arr = CoV_matrix[1, :]
    for i = 2:size(CoV_matrix, 1)
        CoV_arr += CoV_matrix[i, :]
    end
    CoV_arr ./= size(CoV_matrix, 1)

    # Вклад каждой инфекции для каждой недели
    sum_arr = FluA_arr + FluB_arr + RV_arr + RSV_arr + AdV_arr + PIV_arr + CoV_arr
    FluA_ratio = FluA_arr ./ sum_arr
    FluB_ratio = FluB_arr ./ sum_arr
    RV_ratio = RV_arr ./ sum_arr
    RSV_ratio = RSV_arr ./ sum_arr
    AdV_ratio = AdV_arr ./ sum_arr
    PIV_ratio = PIV_arr ./ sum_arr
    CoV_ratio = CoV_arr ./ sum_arr

    # Сглаживание
    FluA_ratio = moving_average(FluA_ratio, 3)
    FluB_ratio = moving_average(FluB_ratio, 3)
    RV_ratio = moving_average(RV_ratio, 3)
    RSV_ratio = moving_average(RSV_ratio, 3)
    AdV_ratio = moving_average(AdV_ratio, 3)
    PIV_ratio = moving_average(PIV_ratio, 3)
    CoV_ratio = moving_average(CoV_ratio, 3)

    return hcat(FluA_ratio, FluB_ratio, RV_ratio, RSV_ratio, AdV_ratio, PIV_ratio, CoV_ratio)
end
