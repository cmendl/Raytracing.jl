
"""
Light ray structure, storing origin and direction of the ray.
The direction needs not be normalized.
"""
struct Ray
    origin::Vector
    direction::Vector
end


"""
    point_at_parameter(ray, t)

Compute point on ray at parameter `t`.
"""
point_at_parameter(ray::Ray, t) = ray.origin + t*ray.direction
