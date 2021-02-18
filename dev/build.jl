using Random
using Turing

@model function binom(n, k)
    α ~ Beta(1, 1)
    θ ~ Beta(α, 1)
    k ~ Binomial(n, θ)
    k, θ
end

Random.seed!(123)
chn = sample(binom(9, 6), NUTS(0.65), MCMCThreads(), 1000, 3)

@model function binom2(n, k)
    α ~ Beta(2, 1)
    θ ~ Beta(α, 1)
    k ~ Binomial(n, θ)
    k, θ
end

Random.seed!(123)
chn2 = sample(binom(5, 3), NUTS(0.65), MCMCThreads(), 1000, 3)
