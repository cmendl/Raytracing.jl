
"""
    reflect(v, n)

Reflect direction `v` at plane with normal `n`.
"""
function reflect(v, n)
    @assert(abs(norm(n) - 1) < 1e-11, "surface normal must be normalized")
    return v - 2*dot(v, n)*n
end


"""
    refract(v, n, ni_over_nt)

Compute direction of refracted ray according to Snell's law,
or return `nothing` if no solution exists.
"""
function refract(v, n, ni_over_nt)
    @assert(abs(norm(v) - 1) < 1e-11, "input ray direction must be normalized")
    @assert(abs(norm(n) - 1) < 1e-11, "surface normal must be normalized")
    dt = dot(v, n)
    discriminant = 1 - ni_over_nt^2 * (1 - dt^2)
    if discriminant > 0
        return ni_over_nt*(v - n*dt) - sqrt(discriminant)*n
    else
        return nothing
    end
end


"""
    schlick(cosine, ref_idx)

Schlick's approximation of specular reflection coefficient.
"""
function schlick(cosine, ref_idx)
    r0 = ((1 - ref_idx) / (1 + ref_idx))^2
    return r0 + (1 - r0) * (1 - cosine)^5
end


abstract type Material end


"""
Lambertian surface (ideal diffusive reflection),
specified by albedo (reflectance) per color channel.
"""
struct Lambertian <: Material
    albedo::Vector
end

"""
    scatter(lambertian, ray, rec)

Compute scattered ray and color attenuation factors for a ray hitting a lambertian surface.
"""
function scatter(lambertian::Lambertian, ray::Ray, rec::HitRecord)
    scattered = Ray(rec.point, rec.normal + random_in_unit_sphere())
    return (scattered, lambertian.albedo)
end


"""
Metal surface, specified by albedo (reflectance) per color channel
and fuzziness factor (scales random additive permutation of reflected ray).
"""
struct Metal <: Material
    # reflectance per color channel
    albedo::Vector
    # fuzziness factor
    fuzz::Real

    Metal(albedo, fuzz) = new(albedo, min(fuzz, 1))
end

"""
    scatter(metal, ray, rec)

Compute scattered ray and color attenuation factors for a ray hitting a metal surface.
"""
function scatter(metal::Metal, ray::Ray, rec::HitRecord)
    nraydir = unitvector(ray.direction)
    reflected = reflect(nraydir, rec.normal)
    scattered = Ray(rec.point, reflected + metal.fuzz*random_in_unit_sphere())
    if dot(scattered.direction, rec.normal) > 0
        return (scattered, metal.albedo)
    else
        return (nothing, metal.albedo)
    end
end


"""
Dielectric surface, specified by ratio of the indices of refraction.
"""
struct Dielectric <: Material
    ref_idx::Real
end

"""
    scatter(dielectric, ray, rec)

Compute scattered ray and color attenuation factors for a ray hitting a dielectric surface material.
"""
function scatter(dielectric::Dielectric, ray::Ray, rec::HitRecord)
    # normalized ray direction
    nraydir = unitvector(ray.direction)

    reflected = reflect(nraydir, rec.normal)

    cosine = dot(nraydir, rec.normal)
    if cosine > 0
        refracted = refract(nraydir, -rec.normal, dielectric.ref_idx)
    else
        refracted = refract(nraydir, rec.normal, 1 / dielectric.ref_idx)
        cosine = -cosine
    end

    if refracted != nothing
        reflect_prob = schlick(cosine, dielectric.ref_idx)
    else
        reflect_prob = 1
    end

    # randomly choose between reflection or refraction
    if rand() < reflect_prob
        return (Ray(rec.point, reflected), ones(3))
    else
        return (Ray(rec.point, refracted), ones(3))
    end
end
