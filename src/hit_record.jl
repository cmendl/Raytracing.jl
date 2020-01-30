
"""
Store a "hit record" for a ray intersecting a geometric object.
"""
struct HitRecord
    # intersection point
    point::Vector
    # surface normal at intersection point
    normal::Vector
    # reference to material
    material

    function HitRecord(point, normal, material)
        @assert(abs(norm(normal) - 1) < 1e-11, "hit record normal must be normalized")
        new(point, normal, material)
    end
end
