using RoME, Distributions
using RoMEPlotting, Gadfly

fg = initfg()

t = 4
for i in 0:t
    addNode!(fg, Symbol("l10$i"),DynPoint2(ut=convert(Int64,1e6*i))) #ut expected in microseconds
end

# Prior on first pose
mu = [0;0;1;0]; cov = 0.01*diagm(ones(4));
addFactor!(fg,[:l100;], DynPoint2VelocityPrior(MvNormal(mu, cov)))

# Odo chain
mu = [0;0;1;0]; cov = 0.1*diagm(ones(4));
for i in 0:3
    dp2dp2 = DynPoint2DynPoint2(MvNormal(mu, cov))
    addFactor!(fg, [Symbol("l10$i");Symbol("l10$(i+1)")],dp2dp2)
end


writeGraphPdf(fg)



tree = wipeBuildNewTree!(fg)
inferOverTree!(fg, tree)

pl = plotKDE(fg, :l100, dims=[3;4])
pl = plotKDE(fg, :l103, dims=[1;2])
