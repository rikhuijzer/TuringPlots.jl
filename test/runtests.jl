using DataFrames
using Test
using Turing
using TuringPlots

T = TuringPlots

const n_samples = 200
const n_chains = 2
@model function binom(n, k)
    α ~ Beta(1, 1)
    θ ~ Beta(α, 1)
    k ~ Binomial(n, θ)
    return k, θ
end
const chn = sample(binom(9, 6), NUTS(0.65), MCMCThreads(), n_samples, n_chains)
const n_parameters = length(T.parameters(chn))
@test n_parameters == 2

@testset "plot_summary" begin
    p = :α
    df = T.chain_values(chn, p, 1)
    @test names(df) == ["chain", "id", "value"]
    @test nrow(df) == n_samples
    @test all(df.chain .== 1)

    df = T.flatten_chains(chn, p)
    @test names(df) == ["parameter", "chain", "id", "value"]
    @test nrow(df) == n_chains * n_samples
    @test unique(df.chain) == 1:n_chains

    df = T.flatten_parameters_chains(chn)
    @test names(df) == ["parameter", "chain", "id", "value"]
    @test nrow(df) == n_parameters * n_chains * n_samples
    @test eltype(df.chain) == Int
    @test unique(df.parameter) == [:α, :θ]

    models = (A = chn, B = chn)
    df = T.flatten_models_parameters_chains(models)
    @test names(df) == ["model", "parameter", "chain", "id", "value"]
    @test nrow(df) == length(models) * n_parameters * n_chains * n_samples
    @test eltype(df.model) == Symbol
    @test unique(df.model) == [:A, :B]
end
