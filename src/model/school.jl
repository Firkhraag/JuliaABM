# Образовательное учреждение: детский сад, школа, вуз (институт)
mutable struct School
    # Группы
    groups::Vector{Vector{Vector{Int64}}}
    # Id учителей
    teacher_ids::Vector{Int}
    # Id района
    district_id::Int
    # Координаты
    x::Float64
    y::Float64
    # Продолжительность карантина для школы
    quarantine_period::Int
    # Продолжительность карантинов по потокам
    quarantine_period_grades::Vector{Int}
    # Продолжительность карантинов по классам
    quarantine_period_groups::Vector{Vector{Int}}
    # Число учащихся в образовательном учреждении
    num_students::Int
    # Число учащихся в образовательном учреждении по параллелям
    num_students_grades::Vector{Int}

    function School(
        # 1 - детсад, 2 - школа, 3 - вуз (институт)
        type::Int,
        # Id района
        district_id::Int,
        # Долгота
        x::Float64,
        # Широта
        y::Float64,
    )
        if type == 1
            # 5 лет
            new(Vector{Vector{Int64}}[Vector{Int64}[Int[]] for _ in 1:5],
                Int[], district_id, x, y, 0, [0 for _ in 1:5],
                [Int[0] for _ in 1:5], 0, [0 for _ in 1:5])
        elseif type == 2
            # 11 лет
            new(Vector{Vector{Int64}}[Vector{Int64}[Int[]] for _ in 1:11],
                Int[], district_id, x, y, 0, [0 for _ in 1:11],
                [Int[0] for _ in 1:11], 0, [0 for _ in 1:11])
        else
            # 6 лет
            new(Vector{Vector{Int64}}[Vector{Int64}[Int[]] for _ in 1:6],
                Int[], district_id, x, y, 0, [0 for _ in 1:6],
                [Int[0] for _ in 1:6], 0, [0 for _ in 1:6])
        end
    end
end