function get_distance(x1::Float64, y1::Float64, x2::Float64, y2::Float64)
    R = 6371e3 # meters
    φ1 = y1 * π / 180 # radians
    φ2 = y2 * π / 180;
    Δφ = (y2 - y1) * π / 180;
    Δλ = (x2 - x1) * π / 180;

    a = sin(Δφ / 2) * sin(Δφ / 2) + cos(φ1) * cos(φ2) * sin(Δλ / 2) * sin(Δλ / 2)

    return R * 2 * atan(sqrt(a), sqrt(1 - a)) # meters
end
