module TuringPlots

import Gadfly
import Gadfly: plot
import MCMCChains

using DataFrames
using Turing

Chains = MCMCChains.Chains

export 
    plot,
    plot_parameters

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

function parameters(chn::Chains)
    P = summarize(chn)[:, :parameters]
    if typeof(P) == Symbol
        P = [P]
    end
    return P
end

"""
    n_chains(chn::Chains, parameter)

Number of chains for `chn[parameter]`.
"""
function n_chains(chn::Chains, parameter)
    matrix = chn[parameter].data
    size(matrix)[2]
end

"""
    plot(chn::MCMCChains.Chains,
        elements::ElementOrFunctionOrLayers...; mapping...) -> Plot

Plot a chains object by transforming it to a DataFrame.
Settings are passed to Gadfly via `elements` and `mapping`.
"""
function Gadfly.plot(chn::Chains,
        elements::Gadfly.ElementOrFunctionOrLayers...; mapping...)
    P = parameters(chn)
    values = [chn[p].data[:] for p in P]
    df = DataFrame(Dict(zip(P, values)))
    Gadfly.plot(df, elements...; mapping...)
end

function chain_values(chn, parameter, chain_index)
    values = chn[parameter].data[:, chain_index]
    DataFrame(
        chain = repeat([chain_index], length(values)),
        id = 1:length(values),
        value = values
    )
end

function flatten_chains(chn, parameter)
    n = n_chains(chn, parameter)
    cv = [chain_values(chn, parameter, i) for i in 1:n] 
    df = vcat(cv...)
    df.parameter = repeat([parameter], nrow(df))
    select!(df, :parameter, :chain, :id, :value)
    df
end

function flatten_parameters_chains(chn::Chains)
    params = parameters(chn)
    fc = [flatten_chains(chn, p) for p in params]
    vcat(fc...)
end

"""
    plot_parameters(chn::Chains)

Plot sample value and density for each parameter of `chains`.
The plot is built by creating two `Gadfly.subplot_grid`s and using `Gadfly.hstack`.
"""
function plot_parameters(chn::Chains)
    df = flatten_parameters_chains(chn)
    default_elements = [
        Gadfly.Theme(key_position = :none)
    ]
    p1_elements = [
        default_elements;
        Gadfly.Guide.xlabel("Iteration");
        Gadfly.Guide.ylabel("Sample value by Parameter")
    ]
    p2_elements = [
        default_elements;
        Gadfly.Guide.xlabel("Sample value");
        Gadfly.Guide.ylabel("Density by Parameter")
    ]
    p1 = plot(df, ygroup = :parameter, color = :chain, x = :id, y = :value,
        Gadfly.Geom.subplot_grid(Gadfly.Geom.line),
        p1_elements...
    )
    p2 = plot(df, ygroup = :parameter, color = :chain, x = :value,
        Gadfly.Geom.subplot_grid(Gadfly.Geom.density),
        p2_elements...
    )
    Gadfly.hstack(p1, p2)
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

inch = Gadfly.inch
write_svg(path, p; w=6inch, h=4inch) = Gadfly.draw(Gadfly.SVG(path, w, h), p)

end # module
