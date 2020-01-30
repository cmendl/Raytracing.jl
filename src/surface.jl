
abstract type Surface end


"""
Specify a surface as list of geometric objects.
"""
mutable struct SurfaceAssembly <: Surface
    objects::Array{Surface,1}
end


"""
Geometric sphere surface.
"""
struct Sphere <: Surface
    center::Vector
    radius::Real
    material::Material
end


"""
    hit(sa, ray, tmin, tmax)

Obtain the closest hit record for a ray intersecting the objects stored in a `SurfaceAssembly`.
"""
function hit(sa::SurfaceAssembly, ray::Ray, tmin::Real, tmax::Real)
    # hit record
    rec = nothing
    closest_so_far = tmax
    for obj in sa.objects
        currec, t = hit(obj, ray, tmin, closest_so_far)
        if currec != nothing
            closest_so_far = t;
            rec = currec
        end
    end
    return (rec, closest_so_far)
end


"""
    hit(sphere, ray, tmin, tmax)

Obtain the hit record for a ray intersecting a sphere.
"""
function hit(sphere::Sphere, ray::Ray, tmin::Real, tmax::Real)
    oc = ray.origin - sphere.center
    a = dot(ray.direction, ray.direction)
    b = dot(oc, ray.direction)
    c = dot(oc, oc) - sphere.radius^2;
    discriminant = b^2 - a*c
    if discriminant > 0
        # solutions of the quadratic equation
        t1 = -(b + sign(b)*sqrt(discriminant)) / a
        t2 = c / (a * t1)
        # smaller solution first
        for t in sort([t1, t2])
            if tmin <= t && t < tmax
                point = point_at_parameter(ray, t)
                normal = (point - sphere.center) / sphere.radius
                return (HitRecord(point, normal, sphere.material), t)
            end
        end
    end
    return (nothing, tmax)
end
