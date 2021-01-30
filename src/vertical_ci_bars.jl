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
            @error "Expected at least one vertical_ci_bars()."
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
        Gadfly.Geom.polygon(fill=true, preserve_order=true);
        Gadfly.Theme(alphas=[0.7]);
        Gadfly.Guide.xlabel("")
    ]
    Tuple(elements)
end
