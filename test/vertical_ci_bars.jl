@testset "vertical_ci_bars" begin
    v = vertical_ci_bars()
    @test T.vbars([v]) == v
    @test T.vbars([v, v]) == v
    @test T.vbars([]) == nothing

    @test T.quantile2symbol(0.05) == Symbol("5.0%")

    v = vertical_ci_bars(; lower_quantile=0.1, upper_quantile=0.9)
    df = T.parameter_lower_upper(chn, v)
end
