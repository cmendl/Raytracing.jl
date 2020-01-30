
struct Camera
    origin::Vector
    # orthonormal basis
    u::Vector
    v::Vector
    w::Vector
    lensradius::Real
    # focus plane window
    lowerleftcorner::Vector
    horizontal::Vector
    vertical::Vector

    """
        Camera(lookfrom, lookat, vup, vfov, aspect, aperture, focus_dist)

    Initialize camera position, orientation, field of view and aperture.

    # Arguments:
    - lookfrom: camera location within scene
    - lookat: coordinates towards which camera is oriented
    - vup: "up" direction
    - vfov: "field of view" angle, in rad
    - aspect: aspect ratio (width / height) of focus window
    - aperture: aperture (diameter) of camera lense
    - focus_dist: distance of focus plane from camera
    """
    function Camera(lookfrom::Vector, lookat::Vector, vup::Vector, vfov::Real, aspect::Real, aperture::Real, focus_dist::Real)
        # vfov is top to bottom in rad
        half_height = tan(vfov/2)
        half_width = aspect * half_height
        # orthonormal basis
        w = unitvector(lookfrom - lookat)
        u = unitvector(cross(vup, w))
        v = cross(w, u)
        # define the focus plane window
        lowerleftcorner = (lookfrom
            - half_width *focus_dist*u
            - half_height*focus_dist*v
            -             focus_dist*w)

        new(lookfrom, u, v, w, aperture / 2, lowerleftcorner,
            2*half_width *focus_dist*u,
            2*half_height*focus_dist*v)
    end
end


"""
    getray(camera, s, t)

Get a ray originating from a random position on the lens (to imitate
depth of field), targeting the focus window at relative coordinates.

# Arguments:
- `camera::Camera`: camera
- `s::Real`: relative x-coordinate within focus window (real number between 0 and 1)
- `t::Real`: relative y-coordinate within focus window (real number between 0 and 1)
"""
function getray(camera::Camera, s::Real, t::Real)
    rd = camera.lensradius * random_in_unit_disk()
    offset = rd[1]*camera.u + rd[2]*camera.v
    ray_origin = camera.origin + offset
    direction = camera.lowerleftcorner + s*camera.horizontal + t*camera.vertical - ray_origin
    return Ray(ray_origin, direction)
end
