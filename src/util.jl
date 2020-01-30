
"""
    unitvector(v)

Normalize input vector `v`.
"""
function unitvector(v)
    n = norm(v)
    if n > 0
        return v / n
    else
        # zero vector
        return v
    end
end


"""
    random_in_unit_disk()

Generate a uniformly random point within the unit disk.
"""
function random_in_unit_disk()
    while true
        p = 2*rand(2) .- 1
        if dot(p, p) < 1
            return p
        end
    end
end


"""
    random_in_unit_sphere()

Generate a uniformly random point within the unit sphere.
"""
function random_in_unit_sphere()
    while true
        p = 2*rand(3) .- 1
        if dot(p, p) < 1
            return p
        end
    end
end
