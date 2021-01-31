module TuringPlots

import Compose
import Gadfly
import Gadfly: plot
import KernelDensity
import MCMCChains

using DataFrames
using Turing

Chains = MCMCChains.Chains

export 
    plot,
    plot_parameters,
    vertical_ci_bars

include("data.jl")
include("density_ci.jl")
include("vertical_ci_bars.jl")

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
    apply_filter!(df, mapping)

If the user has defined a filter, then apply this to `df`.
"""
function apply_filter!(df, mapping)
    mapping = Dict(mapping)
    if :filter in keys(mapping)
        func = mapping[:filter]
        filter!(func, df)
        delete!(mapping, :filter)
    end
    (df, mapping)
end

"""
    plot(chn::MCMCChains.Chains,
        elements::Gadfly.ElementOrFunctionOrLayers...; mapping...) -> Plot

Plot a chains object by transforming it to a DataFrame.
Settings are passed to Gadfly via `elements` and `mapping`.
"""
function Gadfly.plot(chn::Chains,
        elements::Gadfly.ElementOrFunctionOrLayers...; mapping...)

    if VerticalCIBars in typeof.(elements)
        v = vbars(elements)
        elements = vertical_bars_elements(elements)
        layer = vertical_bars_layer(chn, v)
        elements = tuple(elements..., layer)
    end

    df = flatten_parameters_chains(chn)
    df, mapping = apply_filter!(df, mapping)

    Gadfly.plot(df, elements...; mapping...)
end


"""
    plot_parameters(chn::Chains)

Plot sample value and density for each parameter of `chains`.
The plot is built by creating two `Gadfly.subplot_grid`s and using `Gadfly.hstack`.
"""
function plot_parameters(chn::Chains; mapping...)
    df = flatten_parameters_chains(chn)
    df, mapping = apply_filter!(df, mapping)

    default_elements = [
    ]
    mm = Gadfly.mm
    p1_elements = [
        default_elements;
        Gadfly.Guide.xlabel("Iteration");
        Gadfly.Guide.ylabel("Sample value by Parameter");
        Gadfly.Theme(key_position = :none, line_width=0.1mm)
    ]
    p2_elements = [
        default_elements;
        Gadfly.Guide.xlabel("Sample value");
        Gadfly.Guide.ylabel("Density by Parameter");
        Gadfly.Theme(key_position = :none)
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

inch = Gadfly.inch
write_svg(path, p; w=6inch, h=4inch) = Gadfly.draw(Gadfly.SVG(path, w, h), p)

function test_plot(chn; mapping...)
    df = flatten_parameters_chains(chn)
    df, mapping = apply_filter!(df, mapping)
    subset = filter([:parameter] => ==(:α), df)
    
    data = subset.value
    k, xs, ys = kde_values(data)
    xmin = first(xs)
    ymin = repeat([0.0], length(xs))
    xlower = quantile(data, 0.1)
    ylower = pdf(k, xlower)

    lower_start = xlower - 0.01
    lower_end = xlower + 0.01
    indexes = findall(x -> lower_start <= x && x <= lower_end, xs)
    lower_xmin = xs[indexes]
    lower_xmax = xs[indexes .+ 1]
    lower_ymin = repeat([0], length(indexes))
    lower_ymax = ys[indexes]

    density = Gadfly.layer(x = xs, y = ys, ymin=ymin, ymax = ys, 
        Gadfly.Geom.line, Gadfly.Geom.ribbon,
        Gadfly.Theme(alphas=[0.6]),
        color = repeat([:first], length(xs))
    )
    ci = Gadfly.layer(
        xmin = lower_xmin, xmax = lower_xmax,
        ymin = lower_ymin, ymax = lower_ymax,
        Gadfly.Geom.rect,
        color = repeat([:first], length(lower_xmin))
    )
    other_density = Gadfly.layer(x = xs, y = ys, color=repeat([:second], length(xs)), Gadfly.Geom.line, Gadfly.Stat.density)
    Gadfly.plot(density, ci, other_density)
end

function test_density_subplot(chn; mapping...)
    df = flatten_parameters_chains(chn)
    df, mapping = apply_filter!(df, mapping)

    Gadfly.plot(df, ygroup=:parameter, xgroup =:chain, 
        y = :value, color=:parameter, 
        # Gadfly.Geom.subplot_grid(Gadfly.Geom.point)
        # density_ci(),
        # Gadfly.Geom.density,
        Gadfly.Geom.subplot_grid(density_ci()),
        # Gadfly.Stat.xticks(ticks = collect(0.2:0.2:1.0)),
        # Gadfly.Stat.yticks(ticks = collect(0.2:0.2:1.0)),
        # Gadfly.Coord.cartesian(xmin = 0, xmax = 3)
    )
end

function test_flattened_plot(chn; mapping...)
       
end

end # module
