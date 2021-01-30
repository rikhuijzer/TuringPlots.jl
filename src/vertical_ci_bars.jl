
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

vbars(elements) = first(filter(is_vbars, collect(elements)))

"""
    vertical_bars_elements(elements::Tuple, vbars::VerticalCIBars)


"""
function vertical_bars_elements(elements::Tuple)
    elements = collect(elements)
    settings = vbars(elements)
    filter!(!is_vbars, elements)

# TODO: Use Gadfly add_element or something to avoid overriding user settings.

    elements = [
        elements;
        Gadfly.Stat.density();
        Gadfly.Geom.polygon(fill=true, preserve_order=true);
        Gadfly.Theme(alphas=[0.7]);
        Gadfly.Guide.xlabel("")
    ]
    Tuple(elements)
end
