function create_population(
    thread_id::Int,
    num_threads::Int,
    district_nums::Vector{Int},
    district_households::Matrix{Int}
)::Int
    num_people = 0
    for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
        for _ in 1:district_households[index, 1]
            # 1P
            num_people += 1
        end
        for _ in 1:district_households[index, 2]
            # PWOP2P0C
            num_people += 2
        end
        for _ in 1:district_households[index, 3]
            # PWOP3P0C
            num_people += 3
        end
        for _ in 1:district_households[index, 4]
            # PWOP3P1C
            num_people += 3
        end
        for _ in 1:district_households[index, 5]
            # PWOP4P0C
            num_people += 4
        end
        for _ in 1:district_households[index, 6]
            # PWOP4P1C
            num_people += 4
        end
        for _ in 1:district_households[index, 7]
            # PWOP4P2C
            num_people += 4
        end
        for _ in 1:district_households[index, 8]
            # PWOP5P0C
            num_people += 5
        end
        for _ in 1:district_households[index, 9]
            # PWOP5P1C
            num_people += 5
        end
        for _ in 1:district_households[index, 10]
            # PWOP5P2C
            num_people += 5
        end
        for _ in 1:district_households[index, 11]
            # PWOP5P3C
            num_people += 5
        end
        for _ in 1:district_households[index, 12]
            # PWOP6P0C
            num_people += 6
        end
        for _ in 1:district_households[index, 13]
            # PWOP6P1C
            num_people += 6
        end
        for _ in 1:district_households[index, 14]
            # PWOP6P2C
            num_people += 6
        end
        for _ in 1:district_households[index, 15]
            # PWOP6P3C
            num_people += 6
        end
        for _ in 1:district_households[index, 16]
            # 2PWOP4P0C
            num_people += 4
        end
        for _ in 1:district_households[index, 17]
            # 2PWOP5P0C
            num_people += 5
        end
        for _ in 1:district_households[index, 18]
            # 2PWOP5P1C
            num_people += 5
        end
        for _ in 1:district_households[index, 19]
            # 2PWOP6P0C
            num_people += 6
        end
        for _ in 1:district_households[index, 20]
            # 2PWOP6P1C
            num_people += 6
        end
        for _ in 1:district_households[index, 21]
            # 2PWOP6P2C
            num_people += 6
        end
        for _ in 1:district_households[index, 22]
            # SMWC2P0C
            num_people += 2
        end
        for _ in 1:district_households[index, 23]
            # SMWC2P1C
            num_people += 2
        end
        for _ in 1:district_households[index, 24]
            # SMWC3P0C
            num_people += 3
        end
        for _ in 1:district_households[index, 25]
            # SMWC3P1C
            num_people += 3
        end
        for _ in 1:district_households[index, 26]
            # SMWC3P2C
            num_people += 3
        end
        for _ in 1:district_households[index, 27]
            # SMWC4P0C
            num_people += 4
        end
        for _ in 1:district_households[index, 28]
            # SMWC4P1C
            num_people += 4
        end
        for _ in 1:district_households[index, 29]
            # SMWC4P2C
            num_people += 4
        end
        for _ in 1:district_households[index, 30]
            # SMWC4P3C
            num_people += 4
        end
        for _ in 1:district_households[index, 31]
            # SFWC2P0C
            num_people += 2
        end
        for _ in 1:district_households[index, 32]
            # SFWC2P1C
            num_people += 2
        end
        for _ in 1:district_households[index, 33]
            # SFWC3P0C
            num_people += 3
        end
        for _ in 1:district_households[index, 34]
            # SFWC3P1C
            num_people += 3
        end
        for _ in 1:district_households[index, 35]
            # SFWC3P2C
            num_people += 3
        end
        for _ in 1:district_households[index, 36]
            # SPWCWP3P0C
            num_people += 3
        end
        for _ in 1:district_households[index, 37]
            # SPWCWP3P1C
            num_people += 3
        end
        for _ in 1:district_households[index, 38]
            # SPWCWP4P0C
            num_people += 4
        end
        for _ in 1:district_households[index, 39]
            # SPWCWP4P1C
            num_people += 4
        end
        for _ in 1:district_households[index, 40]
            # SPWCWP4P2C
            num_people += 4
        end

        for _ in 1:district_households[index, 41]
            # SPWCWPWOP3P0C
            num_people += 3
        end
        for _ in 1:district_households[index, 42]
            # SPWCWPWOP3P1C
            num_people += 3
        end
        for _ in 1:district_households[index, 43]
            # SPWCWPWOP4P0C
            num_people += 4
        end
        for _ in 1:district_households[index, 44]
            # SPWCWPWOP4P1C
            num_people += 4
        end
        for _ in 1:district_households[index, 45]
            # SPWCWPWOP4P2C
            num_people += 4
        end
        for _ in 1:district_households[index, 46]
            # SPWCWPWOP5P0C
            num_people += 5
        end
        for _ in 1:district_households[index, 47]
            # SPWCWPWOP5P1C
            num_people += 5
        end
        for _ in 1:district_households[index, 48]
            # SPWCWPWOP5P2C
            num_people += 5
        end

        for _ in 1:district_households[index, 49]
            # O2P0C
            num_people += 2
        end
        for _ in 1:district_households[index, 50]
            # O2P1C
            num_people += 2
        end
        for _ in 1:district_households[index, 51]
            # O3P0C
            num_people += 3
        end
        for _ in 1:district_households[index, 52]
            # O3P1C
            num_people += 3
        end
        for _ in 1:district_households[index, 53]
            # O3P2C
            num_people += 3
        end
        for _ in 1:district_households[index, 54]
            # O4P0C
            num_people += 4
        end
        for _ in 1:district_households[index, 55]
            # O4P1C
            num_people += 4
        end
        for _ in 1:district_households[index, 56]
            # O4P2C
            num_people += 4
        end
        for _ in 1:district_households[index, 57]
            # O5P0C
            num_people += 5
        end
        for _ in 1:district_households[index, 58]
            # O5P1C
            num_people += 5
        end
        for _ in 1:district_households[index, 59]
            # O5P2C
            num_people += 5
        end
    end
    return num_people
end
