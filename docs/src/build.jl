# This file is meant to circumvent a Documenter.jl eval issue, see
# https://github.com/JuliaDocs/Documenter.jl/issues/1514. 

using Gadfly
using Turing
using TuringPlots
T = TuringPlots

function demo_chn()
    @model function binom(n, k)
        α ~ Beta(1, 1)
        θ ~ Beta(α, 1)
        k ~ Binomial(n, θ)
        return k, θ
    end
    sample(binom(9, 6), NUTS(0.65), 1000)
end

turingplot_code = raw"""
using Gadfly
using TuringPlots

plot(chn, x = :θ, Geom.density, Guide.ylabel("Density"))
"""

function turingplot_eval() 
    chn = demo_chn()
    p = eval(Meta.parse("begin $turingplot_code end"))
    T.write_svg("docs/build/turingplot.svg", p)
end

function build()
    turingplot_eval()
end
