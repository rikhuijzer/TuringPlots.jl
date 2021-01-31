export
    density_ci

struct DensityCI <: Gadfly.GeometryElement
    lower_bound::Float64
    upper_bound::Float64
    n_samples::Int
    bandwidth::Real
    line_width::Float64
end
function DensityCI(; 
        lower_bound=0.05,
        upper_bound=0.95,
        n_samples=256, 
        bandwidth=-Inf,
        line_width=0.01)
    DensityCI(lower_bound, upper_bound, n_samples, bandwidth, line_width)
end

density_ci(; kwargs...) = DensityCI(kwargs...)

Gadfly.Geom.element_aesthetics(::DensityCI) = [:x, :y, :size, :color, :shape, :alpha]

function vertical_bar_aes(geom, aes, data, k, xs, ys, islowerbound::Bool)
    new_aes = Gadfly.Aesthetics()
    bound_quantile = islowerbound ? geom.lower_bound : geom.upper_bound

    x_range_middle = quantile(data, bound_quantile)
    x_range_min = x_range_middle - geom.line_width / 2
    x_range_max = x_range_middle + geom.line_width / 2
    indexes = findall(x -> x_range_min <= x && x <= x_range_max, xs)
    new_aes.xmin = float.(xs[indexes])
    new_aes.xmax = float.(xs[indexes] .+ 0.01)
    new_aes.ymin = float.(repeat([0], length(indexes)))
    new_aes.ymax = float.(ys[indexes])
    new_aes.color = [first(aes.color)]
    new_aes
end

# Awesome, this one is called inside subplot and we can just call other render functions.
# The reason that we only have aes is because this method is very generic.
# Works for subplot, but also for normal plots.
function Gadfly.Geom.render(geom::DensityCI, theme::Gadfly.Theme, aes::Gadfly.Aesthetics)
    data = aes.y
    k, xs, ys = kde_values(data)

    lower_aes = vertical_bar_aes(geom, aes, data, k, xs, ys, true)
    lower_ctx = Gadfly.Geom.render(Gadfly.Geom.rect(), theme, lower_aes)

    upper_aes = vertical_bar_aes(geom, aes, data, k, xs, ys, false)
    upper_ctx = Gadfly.Geom.render(Gadfly.Geom.rect(), theme, upper_aes)

    return Gadfly.compose(lower_ctx, upper_ctx)
end
