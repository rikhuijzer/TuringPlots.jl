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
    plot_parameters

include("density_ci.jl")

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

end # module
