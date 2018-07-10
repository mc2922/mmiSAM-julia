struct Point4DOF <: IncrementalInference.InferenceVariable
  dims::Int
  labels::Vector{String}
  Point4() = new(5, String["Point4";]) #x,y,̇x, ̇y,t
end

mutable struct Point4Point4 <: IncrementalInference.FunctorPairwise where {T <: Distribution}
  z::T
  Point4Point4{T}() where {T <: Distribution} = new{T}()
  Point4Point4(z1::T) where {T <: Distribution} = new{T}(z1)
  Point4Point4(mean::Vector{Float64}, cov::Array{Float64,2}) where {T <: Distribution} = new{Distributions.MvNormal}(MvNormal(mean, cov))
end
getSample(p4p4::Point4Point4, N::Int=1) = (rand(s.z,N), )
function (p4p4::Point4Point4)(res::Array{Float64},
      idx::Int,
      meas::Tuple,
      xi::Array{Float64,5},
      xj::Array{Float64,5}  )
  Z = meas[1][1,idx]
  Xi, Xj = xj[:,idx],xj[:,idx]
  dt = Xj[5] - Xi[5] #implies Xj occured after Xi- potential issue?
  res = z - (Xj - (Xi+dt*[1 1 0 0]*Xi))
  nothing
end
