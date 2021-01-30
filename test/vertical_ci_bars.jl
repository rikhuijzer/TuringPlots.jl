@testset "vertical_ci_bars" begin
    v = vertical_ci_bars()    
    @test T.vbars([v]) == v
    @test T.vbars([v, v]) == v
end
