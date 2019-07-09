using Makie, AbstractPlotting

N = 51
x = range(-2, stop = 2, length = N)
y = x
z = (-x .*exp.(-x .^ 2 .- (y') .^ 2)) .* 4
scene = surface(x, y, z)
xm, ym, zm = minimum(scene.limits[])
contour!(scene, x, y, z, levels = 15, linewidth = 2, transformation = (:xy, zm))
wireframe!(scene, x, y, z, overdraw = true, transparency = true, color = (:black, 0.1))
scene
