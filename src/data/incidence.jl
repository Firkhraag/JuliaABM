# Заболеваемость различными вирусами в различных возрастных группах
function get_incidence(
    etiology::Matrix{Float64},
    is_mean::Bool,
    starting_year_index::Int,
    is_till_end_year_index::Bool,
)::Array{Float64, 3}
    infected_data_0_all = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu0-2.csv"), ';', Int, '\n')
    infected_data_3_all = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu3-6.csv"), ';', Int, '\n')
    infected_data_7_all = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu7-14.csv"), ';', Int, '\n')
    infected_data_15_all = readdlm(joinpath(@__DIR__, "..", "..", "input", "tables", "flu15+.csv"), ';', Int, '\n')

    infected_data_0 = infected_data_0_all[2:53, starting_year_index:end]
    if !is_till_end_year_index
        infected_data_0 = infected_data_0_all[2:53, starting_year_index]
    end
    infected_data_0_1 = etiology[:, 1] .* infected_data_0
    infected_data_0_2 = etiology[:, 2] .* infected_data_0
    infected_data_0_3 = etiology[:, 3] .* infected_data_0
    infected_data_0_4 = etiology[:, 4] .* infected_data_0
    infected_data_0_5 = etiology[:, 5] .* infected_data_0
    infected_data_0_6 = etiology[:, 6] .* infected_data_0
    infected_data_0_7 = etiology[:, 7] .* infected_data_0

    # Если рассматривается временной ряд
    infected_data_0_viruses = cat(
        vec(infected_data_0_1),
        vec(infected_data_0_2),
        vec(infected_data_0_3),
        vec(infected_data_0_4),
        vec(infected_data_0_5),
        vec(infected_data_0_6),
        vec(infected_data_0_7),
        dims = 2)

    # Если рассматривается 1 год
    if is_mean
        infected_data_0_viruses = cat(
            mean(infected_data_0_1, dims = 2)[:, 1],
            mean(infected_data_0_2, dims = 2)[:, 1],
            mean(infected_data_0_3, dims = 2)[:, 1],
            mean(infected_data_0_4, dims = 2)[:, 1],
            mean(infected_data_0_5, dims = 2)[:, 1],
            mean(infected_data_0_6, dims = 2)[:, 1],
            mean(infected_data_0_7, dims = 2)[:, 1],
            dims = 2)
    end

    infected_data_3 = infected_data_3_all[2:53, starting_year_index:end]
    if !is_till_end_year_index
        infected_data_3 = infected_data_3_all[2:53, starting_year_index]
    end
    infected_data_3_1 = etiology[:, 1] .* infected_data_3
    infected_data_3_2 = etiology[:, 2] .* infected_data_3
    infected_data_3_3 = etiology[:, 3] .* infected_data_3
    infected_data_3_4 = etiology[:, 4] .* infected_data_3
    infected_data_3_5 = etiology[:, 5] .* infected_data_3
    infected_data_3_6 = etiology[:, 6] .* infected_data_3
    infected_data_3_7 = etiology[:, 7] .* infected_data_3

    if is_mean
        infected_data_3_viruses = cat(
            vec(infected_data_3_1),
            vec(infected_data_3_2),
            vec(infected_data_3_3),
            vec(infected_data_3_4),
            vec(infected_data_3_5),
            vec(infected_data_3_6),
            vec(infected_data_3_7),
            dims = 2)
    end

    infected_data_3_viruses = cat(
        mean(infected_data_3_1, dims = 2)[:, 1],
        mean(infected_data_3_2, dims = 2)[:, 1],
        mean(infected_data_3_3, dims = 2)[:, 1],
        mean(infected_data_3_4, dims = 2)[:, 1],
        mean(infected_data_3_5, dims = 2)[:, 1],
        mean(infected_data_3_6, dims = 2)[:, 1],
        mean(infected_data_3_7, dims = 2)[:, 1],
        dims = 2)

    infected_data_7 = infected_data_7_all[2:53, starting_year_index:end]
    if !is_till_end_year_index
        infected_data_7 = infected_data_7_all[2:53, starting_year_index]
    end
    infected_data_7_1 = etiology[:, 1] .* infected_data_7
    infected_data_7_2 = etiology[:, 2] .* infected_data_7
    infected_data_7_3 = etiology[:, 3] .* infected_data_7
    infected_data_7_4 = etiology[:, 4] .* infected_data_7
    infected_data_7_5 = etiology[:, 5] .* infected_data_7
    infected_data_7_6 = etiology[:, 6] .* infected_data_7
    infected_data_7_7 = etiology[:, 7] .* infected_data_7

    if is_mean
        infected_data_7_viruses = cat(
            vec(infected_data_7_1),
            vec(infected_data_7_2),
            vec(infected_data_7_3),
            vec(infected_data_7_4),
            vec(infected_data_7_5),
            vec(infected_data_7_6),
            vec(infected_data_7_7),
            dims = 2)
    end

    infected_data_7_viruses = cat(
        mean(infected_data_7_1, dims = 2)[:, 1],
        mean(infected_data_7_2, dims = 2)[:, 1],
        mean(infected_data_7_3, dims = 2)[:, 1],
        mean(infected_data_7_4, dims = 2)[:, 1],
        mean(infected_data_7_5, dims = 2)[:, 1],
        mean(infected_data_7_6, dims = 2)[:, 1],
        mean(infected_data_7_7, dims = 2)[:, 1],
        dims = 2)

    infected_data_15 = infected_data_15_all[2:53, starting_year_index:end]
    if !is_till_end_year_index
        infected_data_15 = infected_data_15_all[2:53, starting_year_index]
    end
    infected_data_15_1 = etiology[:, 1] .* infected_data_15
    infected_data_15_2 = etiology[:, 2] .* infected_data_15
    infected_data_15_3 = etiology[:, 3] .* infected_data_15
    infected_data_15_4 = etiology[:, 4] .* infected_data_15
    infected_data_15_5 = etiology[:, 5] .* infected_data_15
    infected_data_15_6 = etiology[:, 6] .* infected_data_15
    infected_data_15_7 = etiology[:, 7] .* infected_data_15

    if is_mean
        infected_data_15_viruses = cat(
            vec(infected_data_15_1),
            vec(infected_data_15_2),
            vec(infected_data_15_3),
            vec(infected_data_15_4),
            vec(infected_data_15_5),
            vec(infected_data_15_6),
            vec(infected_data_15_7),
            dims = 2)
    end

    infected_data_15_viruses = cat(
        mean(infected_data_15_1, dims = 2)[:, 1],
        mean(infected_data_15_2, dims = 2)[:, 1],
        mean(infected_data_15_3, dims = 2)[:, 1],
        mean(infected_data_15_4, dims = 2)[:, 1],
        mean(infected_data_15_5, dims = 2)[:, 1],
        mean(infected_data_15_6, dims = 2)[:, 1],
        mean(infected_data_15_7, dims = 2)[:, 1],
        dims = 2)

    return cat(
        infected_data_0_viruses,
        infected_data_3_viruses,
        infected_data_7_viruses,
        infected_data_15_viruses,
        dims = 3,
    )
end