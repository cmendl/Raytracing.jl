module Raytracing

using LinearAlgebra
using Images

include("util.jl")
include("ray.jl")
include("hit_record.jl")
include("material.jl")
include("surface.jl")
include("camera.jl")
include("rendering.jl")

export
    Material,
    Lambertian,
    Metal,
    Dielectric,
    Surface,
    SurfaceAssembly,
    Sphere,
    Camera,
    renderimage


end
