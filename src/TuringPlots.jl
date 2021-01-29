module TuringPlots

import Gadfly
import Gadfly: plot
import MCMCChains

using DataFrames
using Turing

export plot

include("data.jl")

function example_plot()
    df = example_data()
    Gadfly.plot(df, x = :U, y = :V, color = :class)
end

function example_chains()
    @model function globe_toss(n, k)
         θ ~ Beta(1, 1)
         k ~ Binomial(n, θ) 
         return k, θ
    end
    chains = sample(globe_toss(9, 6), NUTS(0.65), 1000)
end

# Create subplot from two layers to see what happens.
# If this works, I can just make layers.
# Okay, so creating layers doesn't work. 
# We need to go more low-level with elements or something.
function subplot_two_layers()
    l1 = Gadfly.layer(x = :U, y = :V) 
    l2 = Gadfly.layer(x = :V, y = :U)
    p = Gadfly.plot(example_data(), 
        y = [1],
        Gadfly.Geom.subplot_grid(example_data(), l1, l2, Gadfly.Geom.point)
    )
    write_svg("plot.svg", p)
end

function subplot_elements()
    subplot = Gadfly.Geom.subplot_grid(Gadfly.Geom.point)
    e1 = 1
    e2 = 2
    p = Gadfly.plot(example_data(),
        xgroup = :class, x = :U, y = :V,
        subplot
    )
    write_svg("plot.svg", p)
end

"""
    plot(chains::MCMCChains.Chains,
        elements::ElementOrFunctionOrLayers...; mapping...) -> Plot

Plot a chains object. 
This method makes the parameters of the chains object available to Gadfly.
"""
function Gadfly.plot(chains::MCMCChains.Chains,
        elements::Gadfly.ElementOrFunctionOrLayers...; mapping...)
    parameters = summarize(chains)[:, :parameters]
    if typeof(parameters) == Symbol
        parameters = [parameters]
    end
    values = [chains[p].data[:] for p in parameters]
    df = DataFrame(Dict(zip(parameters, values)))
    Gadfly.plot(df, elements...; mapping...)
end

"""
    vertical_ci_bars(chains)

This plot shows stacked posterior distributions with central 90% credible intervals.
Horizontally, multiple chains are stacked from different models.
Vertically, parameters are stacked.
"""
function vertical_ci_bars()
    
    1 
end

write_svg(path, p) = Gadfly.draw(Gadfly.SVG(path), p)

end # module
