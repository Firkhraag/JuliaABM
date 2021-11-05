using XLSX
using DataFrames
using CSV

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
    a .= replace.(a, "Хорошёвский район" => "107")
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

function preprocess_universities()
    xf = XLSX.readxlsx("census/places/universities.xlsx")
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
    CSV.write("input/tables/space/universities.csv", df)
end

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

# Don't forget to run partition.jl after applying changes
# preprocess_kindergartens()
# preprocess_schools()
# preprocess_universities()
# preprocess_shops()
# preprocess_restaurants()
