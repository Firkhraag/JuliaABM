using Base.Threads
using Random
using Distributions
using DataFrames
using CSV
using XLSX

include("util/haversine.jl")

# Предобработка названий районов Москвы
function process_districts(a::Matrix{String})
    a .= replace.(a, "Академический район" => "66")
    a .= replace.(a, "Алексеевский район" => "31")
    a .= replace.(a, "Алтуфьевский район" => "32")
    a .= replace.(a, "район Арбат" => "92")
    a .= replace.(a, "район Аэропорт" => "19")
    a .= replace.(a, "Бабушкинский район" => "33")
    a .= replace.(a, "Басманный район" => "93")
    a .= replace.(a, "район Беговой" => "94")
    a .= replace.(a, "Бескудниковский район" => "20")
    a .= replace.(a, "район Бибирево" => "34")
    a .= replace.(a, "район Бирюлёво Восточное" => "76")
    a .= replace.(a, "район Бирюлёво Западное" => "77")
    a .= replace.(a, "район Богородское" => "95")
    a .= replace.(a, "район Братеево" => "78")
    a .= replace.(a, "Бутырский район" => "35")
    a .= replace.(a, "район Вешняки" => "1")
    a .= replace.(a, "Войковский район" => "21")
    a .= replace.(a, "район Восточное Дегунино" => "22")
    a .= replace.(a, "район Восточное Измайлово" => "2")
    a .= replace.(a, "район Выхино-Жулебино" => "55")
    a .= replace.(a, "Гагаринский район" => "67")
    a .= replace.(a, "Головинский район" => "23")
    a .= replace.(a, "район Гольяново" => "96")
    a .= replace.(a, "Даниловский район" => "79")
    a .= replace.(a, "Дмитровский район" => "24")
    a .= replace.(a, "Донской район" => "80")
    a .= replace.(a, "район Дорогомилово" => "9")
    a .= replace.(a, "район Замоскворечье" => "97")
    a .= replace.(a, "район Западное Дегунино" => "25")
    a .= replace.(a, "район Зюзино" => "68")
    a .= replace.(a, "район Зябликово" => "81")
    a .= replace.(a, "район Ивановское" => "3")
    a .= replace.(a, "район Измайлово" => "4")
    a .= replace.(a, "район Капотня" => "56")
    a .= replace.(a, "район Коньково" => "69")
    a .= replace.(a, "район Коптево" => "26")
    a .= replace.(a, "район Котловка" => "70")
    a .= replace.(a, "Красносельский район" => "98")
    a .= replace.(a, "район Крылатское" => "10")
    a .= replace.(a, "район Кузьминки" => "57")
    a .= replace.(a, "район Кунцево" => "11")
    a .= replace.(a, "район Левобережный" => "27")
    a .= replace.(a, "район Лефортово" => "58")
    a .= replace.(a, "район Лианозово" => "36")
    a .= replace.(a, "Ломоносовский район" => "71")
    a .= replace.(a, "Лосиноостровский район" => "37")
    a .= replace.(a, "район Люблино" => "59")
    a .= replace.(a, "район Марфино" => "38")
    a .= replace.(a, "район Марьина Роща" => "39")
    a .= replace.(a, "район Марьино" => "60")
    a .= replace.(a, "район Метрогородок" => "99")
    a .= replace.(a, "Мещанский район" => "100")
    a .= replace.(a, "Можайский район" => "12")
    a .= replace.(a, "район Москворечье-Сабурово" => "82")
    a .= replace.(a, "район Нагатино-Садовники" => "83")
    a .= replace.(a, "район Нагатинский Затон" => "84")
    a .= replace.(a, "Нагорный район" => "85")
    a .= replace.(a, "Нижегородский район" => "61")
    a .= replace.(a, "район Новогиреево" => "5")
    a .= replace.(a, "Обручевский район" => "72")
    a .= replace.(a, "район Орехово-Борисово Северное" => "86")
    a .= replace.(a, "район Орехово-Борисово Южное" => "87")
    a .= replace.(a, "Останкинский район" => "40")
    a .= replace.(a, "район Отрадное" => "41")
    a .= replace.(a, "район Очаково-Матвеевское" => "13")
    a .= replace.(a, "район Перово" => "6")
    a .= replace.(a, "район Печатники" => "62")
    a .= replace.(a, "район Покровское-Стрешнево" => "47")
    a .= replace.(a, "район Преображенское" => "101")
    a .= replace.(a, "Пресненский район" => "102")
    a .= replace.(a, "район Проспект Вернадского" => "14")
    a .= replace.(a, "район Раменки" => "15")
    a .= replace.(a, "район Ростокино" => "42")
    a .= replace.(a, "Рязанский район" => "63")
    a .= replace.(a, "Савёловский район" => "103")
    a .= replace.(a, "район Свиблово" => "43")
    a .= replace.(a, "район Северное Измайлово" => "7")
    a .= replace.(a, "район Северное Медведково" => "44")
    a .= replace.(a, "район Северное Тушино" => "48")
    a .= replace.(a, "район Соколиная Гора" => "8")
    a .= replace.(a, "район Сокольники" => "104")
    a .= replace.(a, "район Сокол" => "28")
    a .= replace.(a, "район Строгино" => "49")
    a .= replace.(a, "Таганский район" => "105")
    a .= replace.(a, "Тверской район" => "106")
    a .= replace.(a, "Тимирязевский район" => "29")
    a .= replace.(a, "район Текстильщики" => "64")
    a .= replace.(a, "район Тёплый Стан" => "73")
    a .= replace.(a, "район Тропарёво-Никулино" => "16")
    a .= replace.(a, "район Филёвский Парк" => "17")
    a .= replace.(a, "район Фили-Давыдково" => "18")
    a .= replace.(a, "район Хамовники" => "53")
    a .= replace.(a, "район Ховрино" => "30")
    a .= replace.(a, "район Хорошёво-Мнёвники" => "50")
    a .= replace.(a, "Хорошёвский район" => "num_districts")
    a .= replace.(a, "район Царицыно" => "88")
    a .= replace.(a, "район Черёмушки" => "74")
    a .= replace.(a, "район Чертаново Северное" => "89")
    a .= replace.(a, "район Чертаново Центральное" => "90")
    a .= replace.(a, "район Чертаново Южное" => "91")
    a .= replace.(a, "район Щукино" => "51")
    a .= replace.(a, "район Южное Медведково" => "45")
    a .= replace.(a, "район Южное Тушино" => "52")
    a .= replace.(a, "Южнопортовый район" => "65")
    a .= replace.(a, "район Якиманка" => "54")
    a .= replace.(a, "Ярославский район" => "46")
    a .= replace.(a, "район Ясенево" => "75")
end

# Для получения координат детских садов
function preprocess_kindergartens()
    xf = XLSX.readxlsx("census/places/kindergartens.xlsx")
    sh = xf["data"]

    a = string.(sh["A2:A1928"])
    process_districts(a)

    b = string.(sh["B2:C1928"])
    b[:, 1] .= replace.(b[:, 1], "," => ".")
    b[:, 2] .= replace.(b[:, 2], "," => ".")

    m = hcat(a, b)
    df = DataFrame(m, ["dist", "x", "y"])

    df = filter(row -> row.dist != "missing", df)
    df = filter(row -> length(row.dist) < 4, df)

    insertcols!(df, 1, :id => 1:nrow(df))
    CSV.write("input/tables/space/kindergartens.csv", df)
end

# Для получения координат школ
function preprocess_schools()
    xf = XLSX.readxlsx("census/places/schools.xlsx")
    sh = xf["data"]

    a = string.(sh["A2:A1232"])
    process_districts(a)

    b = string.(sh["B2:C1232"])
    b[:, 1] .= replace.(b[:, 1], "," => ".")
    b[:, 2] .= replace.(b[:, 2], "," => ".")

    m = hcat(a, b)
    df = DataFrame(m, ["dist", "x", "y"])

    df = filter(row -> row.dist != "missing", df)
    df = filter(row -> length(row.dist) < 4, df)

    insertcols!(df, 1, :id => 1:nrow(df))
    CSV.write("input/tables/space/schools.csv", df)
end

# Для получения координат вузов
function preprocess_colleges()
    xf = XLSX.readxlsx("census/places/colleges.xlsx")
    sh = xf["data"]

    a = string.(sh["A2:A140"])
    process_districts(a)

    b = string.(sh["B2:C140"])
    b[:, 1] .= replace.(b[:, 1], "," => ".")
    b[:, 2] .= replace.(b[:, 2], "," => ".")

    m = hcat(a, b)
    df = DataFrame(m, ["dist", "x", "y"])

    df = filter(row -> row.dist != "missing", df)
    df = filter(row -> length(row.dist) < 4, df)

    insertcols!(df, 1, :id => 1:nrow(df))
    CSV.write("input/tables/space/colleges.csv", df)
end

# Для получения координат магазинов
function preprocess_shops()
    xf = XLSX.readxlsx("census/places/shops.xlsx")
    sh = xf["data"]

    a = string.(sh["A2:A42853"])
    process_districts(a)

    b = string.(sh["B2:D42853"])
    b[:, 1] .= replace.(b[:, 1], "," => ".")
    b[:, 2] .= replace.(b[:, 2], "," => ".")

    m = hcat(a, b)
    df = DataFrame(m, ["dist", "x", "y", "type"])

    df = filter(row -> row.type == "реализация продовольственных товаров", df)
    df = filter(row -> row.dist != "missing", df)
    df = filter(row -> length(row.dist) < 4, df)

    insertcols!(df, 1, :id => 1:nrow(df))
    CSV.write("input/tables/space/shops.csv", df[:, ["id", "dist", "x", "y"]])
end

# Для получения координат ресторанов / кафе
function preprocess_restaurants()
    xf = XLSX.readxlsx("census/places/catering.xlsx")
    sh = xf["data"]

    a = string.(sh["A2:A17382"])
    process_districts(a)

    b = string.(sh["B2:D17382"])
    b[:, 1] .= replace.(b[:, 1], "," => ".")
    b[:, 2] .= replace.(b[:, 2], "," => ".")

    m = hcat(a, b)
    df = DataFrame(m, ["dist", "seats", "x", "y"])

    df = filter(row -> row.seats != "0", df)
    df = filter(row -> row.seats != "missing", df)
    df = filter(row -> row.dist != "missing", df)
    df = filter(row -> length(row.dist) < 4, df)

    insertcols!(df, 1, :id => 1:nrow(df))
    CSV.write("input/tables/space/restaurants.csv", df)
end

# Для получения координат парикмахерских
function preprocess_hair_salons()
    xf = XLSX.readxlsx("census/places/services.xlsx")
    sh = xf["data"]

    a = string.(sh["A2:A12580"])

    process_districts(a)

    b = string.(sh["B2:D12580"])
    b[:, 1] .= replace.(b[:, 1], "," => ".")
    b[:, 2] .= replace.(b[:, 2], "," => ".")

    m = hcat(a, b)
    df = DataFrame(m, ["dist", "x", "y", "type"])

    df = filter(row -> row.dist != "missing", df)
    df = filter(row -> length(row.dist) < 4, df)
    println(size(df))
    df = filter(row -> row.type == "парикмахерские и косметические услуги", df)
    println(size(df))

    insertcols!(df, 1, :id => 1:nrow(df))
    CSV.write("input/tables/space/hair_salons.csv", df[:, ["dist", "x", "y"]])
end

# Число агентов и домохозяйств
function get_num_of_people_and_households(
    # Id потока
    thread_id::Int,
    # Число потоков
    num_threads::Int,
    
    district_nums::Vector{Int},
    district_households::Matrix{Int}
)::Tuple{Int, Int}
    num_agents = 0
    num_households = 0
    people_num_arr = [1, 2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 4, 5, 5, 6, 6, 6, 2, 2, 3, 3, 3, 4, 4, 4, 4, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 3, 3, 4, 4, 4, 5, 5, 5, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6]
    for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
        for i = 1:size(district_households, 2)
            for _ in 1:district_households[index, i]
                num_agents += people_num_arr[i]
                num_households += 1
            end
        end
    end
    return num_agents, num_households
end

function find_distances()
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
        if closest_id2 == 0
            closest_id2 = closest_id
        end
        homes_coords_df[i, "restaurant"] = closest_id
        homes_coords_df[i, "restaurant2"] = closest_id2
    end

    CSV.write(joinpath(@__DIR__, "..", "input", "tables", "space", "homes.csv"), homes_coords_df)
end

function get_district_nums(
    num_threads::Int,
    district_households::Matrix{Int},
)::Vector{Int}
    num_districts = size(district_households, 1)
    num_people_districts = Dict(zip(vec(1:num_districts), zeros(Int, num_districts)))
    people_num_arr = [1, 2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 4, 5, 5, 6, 6, 6, 2, 2, 3, 3, 3, 4, 4, 4, 4, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 3, 3, 4, 4, 4, 5, 5, 5, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6]
    for district_id in 1:num_districts
        for i = 1:size(district_households, 2)
            for _ in 1:district_households[district_id, i]
                num_people_districts[district_id] += people_num_arr[i]
            end
        end
    end
    sorted = sort(collect(num_people_districts), by=x->x[2], rev = true)
    # println(sorted)
    if num_threads == 1
        return [sorted[i].first for i = 1:num_districts]
    end
    districts_threads = Int[]
    i = 1
    forward = true
    while i < num_districts
        append!(districts_threads, sorted[i].first)
        if i % num_threads == 0 && forward
            forward = !forward
            i += num_threads
        elseif (i - 1) % num_threads == 0 && !forward
            forward = !forward
            i += num_threads
        else
            if forward
                i += 1
            else
                i -= 1
            end
        end
    end

    curr_index = num_districts
    while length(districts_threads) < num_districts
        append!(districts_threads, sorted[curr_index].first)
        curr_index -= 1
    end
    return districts_threads
end

function get_num_of_people_and_households(
    thread_id::Int,
    num_threads::Int,
    district_nums::Vector{Int},
    district_households::Matrix{Int}
)::Tuple{Int, Int}
    num_agents = 0
    num_households = 0
    people_num_arr = [1, 2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 4, 5, 5, 6, 6, 6, 2, 2, 3, 3, 3, 4, 4, 4, 4, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 3, 3, 4, 4, 4, 5, 5, 5, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6]
    for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
        for i = 1:size(district_households, 2)
            for _ in 1:district_households[index, i]
                num_agents += people_num_arr[i]
                num_households += 1
            end
        end
    end
    return num_agents, num_households
end

function main()
    # Число домохозяйств каждого типа по районам
    district_households = Matrix(DataFrame(CSV.File("./input/tables/district_households.csv")))
    num_threads = nthreads()
    district_nums = get_district_nums(num_threads, district_households)

    println("const district_nums = $(district_nums)")

    kindergarten_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "kindergartens.csv")))
    school_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "schools.csv")))
    college_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "colleges.csv")))
    shop_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "shops.csv")))
    restaurant_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "restaurants.csv")))

    num_kindergartens = zeros(Int, num_threads)
    @threads for thread_id in 1:num_threads
        for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
            kindergartens_coords_district_df = kindergarten_coords_df[kindergarten_coords_df.dist .== index, :]
            num_kindergartens[thread_id] += size(kindergartens_coords_district_df)[1]
        end
    end

    num_schools = zeros(Int, num_threads)
    @threads for thread_id in 1:num_threads
        for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
            schools_coords_district_df = school_coords_df[school_coords_df.dist .== index, :]
            num_schools[thread_id] += size(schools_coords_district_df)[1]
        end
    end

    num_colleges = zeros(Int, num_threads)
    @threads for thread_id in 1:num_threads
        for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
            colleges_coords_district_df = college_coords_df[college_coords_df.dist .== index, :]
            num_colleges[thread_id] += size(colleges_coords_district_df)[1]
        end
    end

    num_shops = zeros(Int, num_threads)
    @threads for thread_id in 1:num_threads
        for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
            shops_coords_district_df = shop_coords_df[shop_coords_df.dist .== index, :]
            num_shops[thread_id] += size(shops_coords_district_df)[1]
        end
    end

    num_restaurants = zeros(Int, num_threads)
    @threads for thread_id in 1:num_threads
        for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
            restaurants_coords_district_df = restaurant_coords_df[restaurant_coords_df.dist .== index, :]
            num_restaurants[thread_id] += size(restaurants_coords_district_df)[1]
        end
    end

    num_agents = Array{Int, 1}(undef, num_threads)
    num_households = Array{Int, 1}(undef, num_threads)
    @threads for thread_id in 1:num_threads
        num_agents[thread_id], num_households[thread_id] = get_num_of_people_and_households(
            thread_id, num_threads, district_nums, district_households)
    end

    println("const num_agents = $(sum(num_agents))")
    println("const num_households = $(sum(num_households))")
    println("const num_kindergartens = $(size(kindergarten_coords_df)[1])")
    println("const num_schools = $(size(school_coords_df)[1])")
    println("const num_colleges = $(size(college_coords_df)[1])")
    println("const num_shops = $(size(shop_coords_df)[1])")
    println("const num_restaurants = $(size(restaurant_coords_df)[1])")

    if num_threads > 1
        print("const start_agent_ids = Int[1, ")
        sum_entities = 1
        for thread_id in 2:(num_threads - 1)
            sum_entities += num_agents[thread_id - 1]
            print("$(sum_entities), ")
        end
        sum_entities += num_agents[num_threads - 1]
        println("$(sum_entities)]")
        print("const end_agent_ids = Int[")
        sum_entities = 0
        for thread_id in 1:(num_threads - 1)
            sum_entities += num_agents[thread_id]
            print("$(sum_entities), ")
        end
        sum_entities += num_agents[num_threads]
        println("$(sum_entities)]")

        print("const start_household_ids = Int[1, ")
        sum_entities = 1
        for thread_id in 2:(num_threads - 1)
            sum_entities += num_households[thread_id - 1]
            print("$(sum_entities), ")
        end
        sum_entities += num_households[num_threads - 1]
        println("$(sum_entities)]")
        print("const end_household_ids = Int[")
        sum_entities = 0
        for thread_id in 1:(num_threads - 1)
            sum_entities += num_households[thread_id]
            print("$(sum_entities), ")
        end
        sum_entities += num_households[num_threads]
        println("$(sum_entities)]")

        print("const start_kindergarten_ids = Int[1, ")
        sum_entities = 1
        for thread_id in 2:(num_threads - 1)
            sum_entities += num_kindergartens[thread_id - 1]
            print("$(sum_entities), ")
        end
        sum_entities += num_kindergartens[num_threads - 1]
        println("$(sum_entities)]")
        print("const end_kindergarten_ids = Int[")
        sum_entities = 0
        for thread_id in 1:(num_threads - 1)
            sum_entities += num_kindergartens[thread_id]
            print("$(sum_entities), ")
        end
        sum_entities += num_kindergartens[num_threads]
        println("$(sum_entities)]")

        print("const start_school_ids = Int[1, ")
        sum_entities = 1
        for thread_id in 2:(num_threads - 1)
            sum_entities += num_schools[thread_id - 1]
            print("$(sum_entities), ")
        end
        sum_entities += num_schools[num_threads - 1]
        println("$(sum_entities)]")
        print("const end_school_ids = Int[")
        sum_entities = 0
        for thread_id in 1:(num_threads - 1)
            sum_entities += num_schools[thread_id]
            print("$(sum_entities), ")
        end
        sum_entities += num_schools[num_threads]
        println("$(sum_entities)]")

        print("const start_college_ids = Int[1, ")
        sum_entities = 1
        for thread_id in 2:(num_threads - 1)
            sum_entities += num_colleges[thread_id - 1]
            print("$(sum_entities), ")
        end
        sum_entities += num_colleges[num_threads - 1]
        println("$(sum_entities)]")
        print("const end_college_ids = Int[")
        sum_entities = 0
        for thread_id in 1:(num_threads - 1)
            sum_entities += num_colleges[thread_id]
            print("$(sum_entities), ")
        end
        sum_entities += num_colleges[num_threads]
        println("$(sum_entities)]")

        print("const start_shop_ids = Int[1, ")
        sum_entities = 1
        for thread_id in 2:(num_threads - 1)
            sum_entities += num_shops[thread_id - 1]
            print("$(sum_entities), ")
        end
        sum_entities += num_shops[num_threads - 1]
        println("$(sum_entities)]")
        print("const end_shop_ids = Int[")
        sum_entities = 0
        for thread_id in 1:(num_threads - 1)
            sum_entities += num_shops[thread_id]
            print("$(sum_entities), ")
        end
        sum_entities += num_shops[num_threads]
        println("$(sum_entities)]")

        print("const start_restaurant_ids = Int[1, ")
        sum_entities = 1
        for thread_id in 2:(num_threads - 1)
            sum_entities += num_restaurants[thread_id - 1]
            print("$(sum_entities), ")
        end
        sum_entities += num_restaurants[num_threads - 1]
        println("$(sum_entities)]")
        print("const end_restaurant_ids = Int[")
        sum_entities = 0
        for thread_id in 1:(num_threads - 1)
            sum_entities += num_restaurants[thread_id]
            print("$(sum_entities), ")
        end
        sum_entities += num_restaurants[num_threads]
        println("$(sum_entities)]")
    end
end

# preprocess_kindergartens()
# preprocess_schools()
# preprocess_colleges()
# preprocess_shops()
# preprocess_restaurants()

# find_distances()

main()
