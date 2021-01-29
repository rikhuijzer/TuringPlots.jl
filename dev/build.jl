using Random
using Turing

@model function binom(n, k)
    α ~ Beta(1, 1)
    θ ~ Beta(α, 1)
    k ~ Binomial(n, θ)
    return k, θ
end
Random.seed!(123)
const chn = sample(binom(9, 6), NUTS(0.65), MCMCThreads(), 1000, 3)
