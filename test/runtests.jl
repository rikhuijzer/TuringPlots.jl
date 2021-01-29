using DataFrames
using Test
using Turing
using TuringPlots

T = TuringPlots

@testset "vertical-ci-bars" begin
    df = T.example_data()
end

@testset "plot_summary" begin
    n_samples = 200
    n_chains = 2
    @model function binom(n, k)
        α ~ Beta(1, 1)
        θ ~ Beta(α, 1)
        k ~ Binomial(n, θ)
        return k, θ
    end
    chn = sample(binom(9, 6), NUTS(0.65), MCMCThreads(), n_samples, n_chains)
    
    default = [1.0, "a"]
    override = [2.0]
    @test T.filter_elements!(default, override) == ["a"]

    p = :α
    df = T.chain_values(chn, p, 1)
    @test names(df) == ["chain", "value"]
    @test nrow(df) == n_samples
    @test all(df.chain .== 1)

    df = T.flatten_chains(chn, p)
    @test names(df) == ["parameter", "chain", "value"]
    @test nrow(df) == n_chains * n_samples
    @test unique(df.chain) == 1:n_chains

    df = T.flatten_parameters_chains(chn)
    @test names(df) == ["parameter", "chain", "value"]
    n_parameters = 2
    @test nrow(df) == n_parameters * n_chains * n_samples
    @test eltype(df.chain) == Int
    @test unique(df.parameter) == [:α, :θ]
end
