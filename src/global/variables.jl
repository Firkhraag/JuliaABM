const num_agents = 10072668
const start_agent_ids = Int[1, 2483024, 4977885, 7516450]
const end_agent_ids = Int[2483023, 4977884, 7516449, 10072668]
const num_households = 3974287
const start_household_ids = Int[1, 994512, 1957295, 2980361]
const end_household_ids = Int[994511, 1957294, 2980360, 3974287]
const num_kindergartens = 1695
const start_kindergarten_ids = Int[1, 435, 891, 1307]
const end_kindergarten_ids = Int[434, 890, 1306, 1695]
const num_schools = 988
const start_school_ids = Int[1, 242, 515, 751]
const end_school_ids = Int[241, 514, 750, 988]
const num_universities = 138
const start_university_ids = Int[1, 50, 94, 123]
const end_university_ids = Int[49, 93, 122, 138]

# Размер групп в образовательных учреждениях
const kindergarten_groups_size_1 = 10
const kindergarten_groups_size_2_3 = 14
const kindergarten_groups_size_4_5 = 18

const school_groups_size = 24

const university_groups_size_1 = 15
const university_groups_size_2_3 = 14
const university_groups_size_4 = 13
const university_groups_size_5 = 11
const university_groups_size_6 = 10

# Параметры, отвечающие за связи на рабочих местах
const zipf_max_size = 994
const barabasi_albert_attachments = 6
