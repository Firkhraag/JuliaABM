# Число вирусов
const num_viruses = 7

# Разбиение по потокам, получаемое из preprocess.jl
const district_nums = [60, 55, 75, 41, 34, 96, 59, 50, 69, 48, 49, 87, 91, 76, 57, 11, 6, 12, 81, 86, 102, 73, 15, 88, 3, 44, 68, 1, 16, 84, 105, 13, 89, 90, 18, 93, 51, 52, 95, 66, 74, 4, 63, 53, 26, 78, 64, 23, 5, 22, 46, 79, 24, 8, 58, 17, 77, 7, 33, 101, 29, 45, 62, 71, 30, 37, 31, 72, 83, 10, 85, 25, 2, 82, 36, 67, 65, 19, 20, 106, 35, 39, 9, 21, 43, 14, 40, 70, 100, 103, 28, 104, 47, 97, 32, 107, 27, 80, 98, 61, 56, 99, 42, 94, 92, 54, 38]
const num_agents = 10072668
const num_households = 3974287
const num_kindergartens = 1697
const num_schools = 989
const num_colleges = 138
const num_shops = 11109
const num_restaurants = 12843
const start_agent_ids = Int[1, 2567048, 5106047, 7602201]
const end_agent_ids = Int[2567047, 5106046, 7602200, 10072668]
const start_household_ids = Int[1, 1023472, 2018332, 2985786]
const end_household_ids = Int[1023471, 2018331, 2985785, 3974287]
const start_kindergarten_ids = Int[1, 423, 831, 1274]
const end_kindergarten_ids = Int[422, 830, 1273, 1697]
const start_school_ids = Int[1, 251, 478, 740]
const end_school_ids = Int[250, 477, 739, 989]
const start_college_ids = Int[1, 24, 51, 89]
const end_college_ids = Int[23, 50, 88, 138]
const start_shop_ids = Int[1, 3001, 5602, 8104]
const end_shop_ids = Int[3000, 5601, 8103, 11109]
const start_restaurant_ids = Int[1, 3334, 5986, 8500]
const end_restaurant_ids = Int[3333, 5985, 8499, 12843]

# Примерное число агентов в различных возрастных группах
const num_agents_age_groups = [266648, 304625, 531915, 8969480]

# Начальный столбец данных для работы модели
const flu_starting_index = 3
# Столбец данных для задания уровня иммунитета агентов
const flu_starting_index_immmunity_bias = 2

# Размеры групп в детских садах
# 1-й год
const kindergarten_groups_size_1 = 8
# 2-3 года
const kindergarten_groups_size_2_3 = 13
# 4-5 года
const kindergarten_groups_size_4_5 = 18

# Размеры групп в школах
# 1-4 года
const school_groups_size_1_4 = 20
# 5-8 года
const school_groups_size_5_8 = 22
# 9-11 года
const school_groups_size_9_11 = 24

# Размеры групп в вузах
# 1-й год
const college_groups_size_1 = 15
# 2-3 года
const college_groups_size_2_3 = 14
# 4-й год
const college_groups_size_4 = 13
# 5-й год
const college_groups_size_5 = 11
# 6-й год
const college_groups_size_6 = 10

# Вероятность прогула института
const skip_college_probability = 0.33

# Средняя разница в возрасте между матерью и ребенком
const mean_child_mother_age_difference = 28

# Probabilities from American Time Use Survey 2019
# const weekend_other_household_p = 0.269
# const weekend_other_household_t = 0.95
# const weekend_restaurant_p = 0.295
# const weekend_restaurant_t = 0.38
# const weekend_shopping_p = 0.354
# const weekend_shopping_t = 0.44
# const weekend_outdoor_p = 0.15
# const weekend_outdoor_t = 0.28
# const weekend_other_place_p = 0.402
# const weekend_other_place_t = 1.18

# const weekday_other_household_p = 0.177
# const weekday_other_household_t = 0.42
# const weekday_restaurant_p = 0.255
# const weekday_restaurant_t = 0.26
# const weekday_shopping_p = 0.291
# const weekday_shopping_t = 0.28
# const weekday_outdoor_p = 0.133
# const weekday_outdoor_t = 0.16
# const weekday_other_place_p = 0.483
# const weekday_other_place_t = 1.22

# Среднее число контактов между учителями в школе
const school_num_of_teacher_contacts = 10
