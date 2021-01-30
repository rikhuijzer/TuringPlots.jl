struct VerticalCIBars <: Gadfly.Element
    lower_quantile::Float64
    upper_quantile::Float64
end

"""
    vertical_ci_bars(; lower_quantile=0.05, upper_quantile=0.95)

This element shows vertical lines for the central credible intervals.
Defaults to `lower_quantile` and `upper_quantile` for central 90% credible intervals.

# Example
```
plot(chn, x = :θ, vertical_ci_bars([0.025, 0.975]))
```
"""
function vertical_ci_bars(; lower_quantile=0.05, upper_quantile=0.95)
    VerticalCIBars(lower_quantile, upper_quantile) 
end

is_vbars(element) = isa(element, VerticalCIBars)

function vbars(elements)
    filtered = filter(is_vbars, collect(elements))
    n = length(filtered)
    try
        return only(filtered)
    catch ArgumentError
        if 1 < n
            @warn "Expected only one vertical_ci_bars(), but got $n; taking only the first."
            return first(filtered)
        else
            return nothing
        end
    end
end

"""
    vertical_bars_elements(elements::Tuple, vbars::VerticalCIBars)

Return `elements` where `::VerticalCIBars` is replaced by Gadfly elements.
"""
function vertical_bars_elements(elements::Tuple)
    elements = collect(elements)
    settings = vbars(elements)
    filter!(!is_vbars, elements)

# TODO: Use Gadfly add_element or something to avoid overriding user settings.

    elements = [
        elements;
        Gadfly.Stat.density();
        Gadfly.Guide.xticks(ticks=[0.01, 0.1, 0.99]);
        Gadfly.Geom.polygon(fill=true, preserve_order=true);
        Gadfly.Theme(alphas=[0.7]);
        Gadfly.Guide.xlabel("Foo")
    ]
    Tuple(elements)
end

quantile2symbol(q::Float64) = Symbol(100 * q, :%)

"""
    parameter_lower_upper(chn::Chains, v::VerticalCIBars)

Returns { :parameter, :lower, :upper } DataFrame.
This combines chains because `MCMCChains.quantile` does that too.
"""
function parameter_lower_upper(chn::Chains, v::VerticalCIBars)
    P = parameters(chn)
    n_parameters = length(P)
    Q = quantile(chn; q=[v.lower_quantile, v.upper_quantile])
    lowers = Q.nt[quantile2symbol(v.lower_quantile)]
    uppers = Q.nt[quantile2symbol(v.upper_quantile)]
    width = 0.004

    DataFrame(
        parameter = P,
        lower_xmin = lowers .- width/2,
        lower_xmax = lowers .+ width/2,
        lower_ymin = repeat([0.01], n_parameters),
        lower_ymax = repeat([0.9], n_parameters)
    )
end

"""
    vertical_bars_layer(chn::Chains, v::VerticalCIBars)

This layer contains the bars (rectangles) and is put on top of the plot.

The benefit of this separate layer is that it can be based on a different DataFrame than
the one used for plotting the distribution.
This way, we can avoid plotting a rectangle for each sample.
"""
function vertical_bars_layer(chn::Chains, v::VerticalCIBars)
    df = parameter_lower_upper(chn, v::VerticalCIBars)
    Gadfly.layer(df, 
        xmin=:lower_xmin, xmax=:lower_xmax,
        ymin=:lower_ymin, ymax=:lower_ymax,
        color = :parameter,
        Gadfly.Geom.rect
    )
end
