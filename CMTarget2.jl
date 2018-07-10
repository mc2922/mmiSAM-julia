# Pose of a Target with a Curvilinear Motion model

struct CMTarget2 <: IncrementalInference.InferenceVariable
    dims::Int
    labels::Vector{String}
    CMTarget2() = new(7, String["POSE";]) #x1,x2,θ, ̇x1, ̇x2,̇θ, t
end

mutable struct IPose2IPose2{T} <: IncrementalInference.FunctorPairwise where {T <: Distribution}
  z::T
  IPose2IPose2{T}() where {T <: Distribution} = new{T}()
  IPose2IPose2(z1::T) where {T <: Distribution} = new{T}(z1)
  IPose2IPose2(mean::Vector{Float64}, cov::Array{Float64,2}) where {T <: Distribution} = new{Distributions.MvNormal}(MvNormal(mean, cov))
end

function (ip2ip2::IPose2IPose2)(res::Array{Float64},
      idx::Int,
      meas::Tuple,
      wxi::Array{Float64,2},
      wxj::Array{Float64,2}  )
  # res[1] = meas[1][idx] - (X2[1,idx] - X1[1,idx])
  wXjhat = SE2(wxi[:,idx])*SE2(meas[1][:,idx]) #*SE2(pp2.Zij[:,1])*SE2(meas[1][:,idx])
  jXjhat = SE2(wxj[:,idx]) \ wXjhat
  res = se2vee!(jXjhat)
  nothing
end
