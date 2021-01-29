

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

function create_vertical_ci_bars(elements::Tuple)::Tuple
    elements = collect(elements)
    isvert(element) = typeof(element) == VerticalCIBars
    settings = first(filter(isvert, elements))
    filter!(!isvert, elements)
    elements = [
        elements;
        Gadfly.Geom.density
    ]
    (elements..., )
end
