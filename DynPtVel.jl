using RoME, Distributions
using RoMEPlotting, Gadfly

vA = Dict{Symbol, Vector{Float64}}()
vA[:l100] = [0.0;0]
vA[:l101] = [1.0;0]
vA[:l102] = [2.0;0]
vA[:l103] = [3.0;0]
vA[:l104] = [4.0;0]

fg = initfg()
