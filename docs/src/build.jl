# This file is meant to circumvent a Documenter.jl eval issue, see
# https://github.com/JuliaDocs/Documenter.jl/issues/1514. 

using Turing
using TuringPlots
T = TuringPlots

turingplot_code = raw"""
using Turing
using TuringPlots

@model function binom(n, k)
   θ ~ Beta(1, 1)
   k ~ Binomial(n, θ)
   return k, θ
end
chains = sample(binom(9, 6), NUTS(0.65), 1000)
plot(chains, y = :θ)
"""

function turingplot_eval() 
    println("Evaluating turingplot")
    p = eval(Meta.parse("begin $turingplot_code end"))
    T.write_svg("build/turingplot.svg", p)
end

function build()
    turingplot_eval()
end