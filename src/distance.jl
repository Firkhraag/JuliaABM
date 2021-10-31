using DataFrames
using Base.Threads
using CSV

include("util/haversine.jl")

function main()
    homes_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "homes_base.csv")))
    kindergartens_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "kindergartens.csv")))
    schools_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "schools.csv")))
    shops_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "shops.csv")))
    restaurants_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "restaurants.csv")))

    homes_coords_df[!, "kinder"] .= 1
    homes_coords_df[!, "school"] .= 1
    homes_coords_df[!, "shop"] .= 1
    homes_coords_df[!, "restaurant"] .= 1

    @threads for i in 1:size(homes_coords_df)[1]
        smallest_dist = 999999999
        closest_id = 1
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
        closest_id = 1
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
        closest_id = 1
        shops_coords_district_df = shops_coords_df[shops_coords_df.dist .== homes_coords_df[i, "dist"], :]
        for j in 1:size(shops_coords_district_df)[1]
            dist = get_distance(
                homes_coords_df[i, "x"],
                homes_coords_df[i, "y"],
                shops_coords_district_df[j, "x"],
                shops_coords_district_df[j, "y"])
            if dist < smallest_dist
                smallest_dist = dist
                closest_id = shops_coords_district_df[j, "id"]
            end
        end
        homes_coords_df[i, "shop"] = closest_id

        smallest_dist = 999999999
        closest_id = 1
        restaurants_coords_district_df = restaurants_coords_df[restaurants_coords_df.dist .== homes_coords_df[i, "dist"], :]
        for j in 1:size(restaurants_coords_district_df)[1]
            dist = get_distance(
                homes_coords_df[i, "x"],
                homes_coords_df[i, "y"],
                restaurants_coords_district_df[j, "x"],
                restaurants_coords_district_df[j, "y"])
            if dist < smallest_dist
                smallest_dist = dist
                closest_id = restaurants_coords_district_df[j, "id"]
            end
        end
        homes_coords_df[i, "restaurant"] = closest_id
    end

    CSV.write(joinpath(@__DIR__, "..", "input", "tables", "homes.csv"), homes_coords_df)
end

main()