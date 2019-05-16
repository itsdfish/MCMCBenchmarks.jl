using MCMCBenchmarks
using Distributions: MvNormal, logpdf
using ForwardDiff: gradient

# Define the target distribution and its gradient
const D = 10
const target = MvNormal(zeros(D), ones(D))
logπ(θ::AbstractVector{<:Real}) = logpdf(target, θ)
∂logπ∂θ(θ::AbstractVector{<:Real}) = ForwardDiff.gradient(logπ, θ)

# Sampling parameter settings
n_samples = 2000
n_adapts = 2000

# Initial points
θ_init = randn(D)

# Define metric space, Hamiltonian and sampling method
metric = DenseEuclideanMetric(D)
h = Hamiltonian(metric, logπ, ∂logπ∂θ)
prop = AdvancedHMC.NUTS(Leapfrog(find_good_eps(h, θ_init)))
adaptor = StanNUTSAdaptor(n_adapts, Preconditioner(metric),
  NesterovDualAveraging(0.8, prop.integrator.ϵ))

# Sampling
samples = sample(h, prop, θ_init, n_samples, adaptor, n_adapts)