
"""
    raycolor(ray, scene, depth)

Trace a single ray and return color of ray as vector of RGB value.

# Arguments:
- `ray::Ray`: to-be traced ray
- `scene::Surface`: geometric scene as surface
- `depth::Integer`: how often the ray is allowed to scatter
"""
function raycolor(ray::Ray, scene::Surface, depth::Integer)
    rec = hit(scene, ray, 0.001, 1e6)[1]
    if rec != nothing
        scattered, attenuation = scatter(rec.material, ray, rec)
        if depth > 0 && scattered != nothing
            # pointwise multiplication between attenuation and
            # return value of recursive function call
            return attenuation .* raycolor(scattered, scene, depth - 1)
        else
            return zeros(3)
        end
    else
        # blue background sky
        unitdir = unitvector(ray.direction)
        t = 0.5*(unitdir[2] + 1)
        return (1 - t)*[1.0, 1.0, 1.0] + t*[0.5, 0.7, 1.0]
    end
end


"""
    renderimage(nx, ny, ns, scene, camera)

Render an image via raytracing; the image is returned as array of RGB values.

# Arguments
- `nx::Integer`: width of rendered image (pixels)
- `ny::Integer`: height of rendered image (pixels)
- `ns::Integer`: number of samples (rays) per pixel
- `scene::Surface`: geometric scene as surface
- `camera::Camera`: camera for generating rays
"""
function renderimage(nx::Integer, ny::Integer, ns::Integer, scene::Surface, camera::Camera)
    # fill image pixels
    img = zeros(RGB{Float32}, (nx, ny))
    for i in 1:nx
        for j in 1:ny
            color = zeros(3)
            for s in 1:ns
                # add a random offset for antialiasing
                u = (i-1 + rand()) / nx
                v = (j-1 + rand()) / ny
                ray = getray(camera, u, v)
                color += raycolor(ray, scene, 50)
            end
            color /= ns

            # take sqrt for gamma correction
            color = sqrt.(color)

            img[i, j] = RGB{Float32}(color[1], color[2], color[3])
        end
    end
    # up-down flip
    img = reverse(img, dims=2)

    return img
end
