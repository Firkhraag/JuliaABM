using DataFrames
using Base.Threads
using CSV

include("util/haversine.jl")

function main()
    homes_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "homes_base.csv")))
    kindergartens_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "kindergartens.csv")))
    schools_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "schools.csv")))
    shops_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "shops.csv")))
    restaurants_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "restaurants.csv")))

    homes_coords_df[!, "kinder"] .= 0
    homes_coords_df[!, "school"] .= 0
    homes_coords_df[!, "shop"] .= 0
    homes_coords_df[!, "shop2"] .= 0
    homes_coords_df[!, "restaurant"] .= 0
    homes_coords_df[!, "restaurant2"] .= 0

    @threads for i in 1:size(homes_coords_df)[1]
        smallest_dist = 999999999
        closest_id = 0
        kindergartens_coords_district_df = kindergartens_coords_df[kindergartens_coords_df.dist .== homes_coords_df[i, "dist"], :]
        for j in 1:size(kindergartens_coords_district_df)[1]
            dist = get_distance(
                homes_coords_df[i, "x"],
                homes_coords_df[i, "y"],
                kindergartens_coords_district_df[j, "x"],
                kindergartens_coords_district_df[j, "y"])
            if dist < smallest_dist
                smallest_dist = dist
                closest_id = kindergartens_coords_district_df[j, "id"]
            end
        end
        homes_coords_df[i, "kinder"] = closest_id

        smallest_dist = 999999999
        closest_id = 0
        schools_coords_district_df = schools_coords_df[schools_coords_df.dist .== homes_coords_df[i, "dist"], :]
        for j in 1:size(schools_coords_district_df)[1]
            dist = get_distance(
                homes_coords_df[i, "x"],
                homes_coords_df[i, "y"],
                schools_coords_district_df[j, "x"],
                schools_coords_district_df[j, "y"])
            if dist < smallest_dist
                smallest_dist = dist
                closest_id = schools_coords_district_df[j, "id"]
            end
        end
        homes_coords_df[i, "school"] = closest_id

        smallest_dist = 999999999
        closest_id = 0
        closest_id2 = 0
        shops_coords_district_df = shops_coords_df[shops_coords_df.dist .== homes_coords_df[i, "dist"], :]
        for j in 1:size(shops_coords_district_df)[1]
            dist = get_distance(
                homes_coords_df[i, "x"],
                homes_coords_df[i, "y"],
                shops_coords_district_df[j, "x"],
                shops_coords_district_df[j, "y"])
            if dist < smallest_dist
                smallest_dist = dist
                closest_id2 = closest_id
                closest_id = shops_coords_district_df[j, "id"]
            end
        end
        # if closest_id == 0
        #     closest_id = rand(1:size(shops_coords_df, 1))
        # end
        if closest_id2 == 0
            closest_id2 = closest_id
        end
        homes_coords_df[i, "shop"] = closest_id
        homes_coords_df[i, "shop2"] = closest_id2

        smallest_dist = 999999999
        closest_id = 0
        closest_id2 = 0
        restaurants_coords_district_df = restaurants_coords_df[restaurants_coords_df.dist .== homes_coords_df[i, "dist"], :]
        for j in 1:size(restaurants_coords_district_df)[1]
            dist = get_distance(
                homes_coords_df[i, "x"],
                homes_coords_df[i, "y"],
                restaurants_coords_district_df[j, "x"],
                restaurants_coords_district_df[j, "y"])
            if dist < smallest_dist
                smallest_dist = dist
                closest_id2 = closest_id
                closest_id = restaurants_coords_district_df[j, "id"]
            end
        end
        # if closest_id == 0
        #     closest_id = rand(1:size(shops_coords_df, 1))
        # end
        if closest_id2 == 0
            closest_id2 = closest_id
        end
        homes_coords_df[i, "restaurant"] = closest_id
        homes_coords_df[i, "restaurant2"] = closest_id2
    end

    CSV.write(joinpath(@__DIR__, "..", "input", "tables", "space", "homes.csv"), homes_coords_df)
end

main()
