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

Gadfly.Geom.element_aesthetics(::DensityCI) = [:y, :size, :color, :shape, :alpha]

function kde_values(data; kargs...)
    k = KernelDensity.kde(data; kargs...)
    d = k.density
    xmin = quantile(d, 0.01)
    xmax = quantile(d, 0.99)
    n_samples = 1600
    step_size = (xmax - xmin) / n_samples
    xs = collect(xmin:step_size:xmax)
    ys = [pdf(k, x) for x in xs]
    (k = k, xs = xs, ys = ys)
end

function vertical_bar_aes(geom, aes, data, k, xs, ys, islowerbound::Bool)
    new_aes = Gadfly.Aesthetics()
    bound_quantile = islowerbound ? geom.lower_bound : geom.upper_bound

    x_range_middle = quantile(data, bound_quantile)
    x_range_min = x_range_middle - geom.line_width / 2
    x_range_max = x_range_middle + geom.line_width / 2
    indexes = findall(x -> x_range_min <= x && x <= x_range_max, xs)
    new_aes.xmin = float.(xs[indexes] .- 0.001)
    new_aes.xmax = float.(xs[indexes] .+ 0.001)
    new_aes.ymin = float.(repeat([0], length(indexes)))
    new_aes.ymax = float.(ys[indexes])
    new_aes.color = [first(aes.color)]
    new_aes
end

function ribbon_aes(geom, aes, data, k, xs, ys)
    new_aes = Gadfly.Aesthetics()
    new_aes.x = float.(xs)
    new_aes.ymin = float.(repeat([0], length(xs)))
    new_aes.ymax = float.(ys)
    new_aes.color = repeat([first(aes.color)], length(ys))
    new_aes
end

function Gadfly.Geom.render(geom::DensityCI, theme::Gadfly.Theme, aes::Gadfly.Aesthetics)
    Gadfly.assert_aesthetics_defined("Geom.DensityCI", aes, :y)

    default_aes = Gadfly.Aesthetics()
    default_aes.color = Gadfly.RGBA{Float32}[theme.default_color]
    default_aes.alpha = Float64[theme.alphas[1]]
    aes = Gadfly.inherit(aes, default_aes)

    data = aes.y
    k, xs, ys = kde_values(data)

    lower_aes = vertical_bar_aes(geom, aes, data, k, xs, ys, true)
    lower = Gadfly.Geom.render(Gadfly.Geom.rect(), theme, lower_aes)

    upper_aes = vertical_bar_aes(geom, aes, data, k, xs, ys, false)
    upper = Gadfly.Geom.render(Gadfly.Geom.rect(), theme, upper_aes)

    rib_aes = ribbon_aes(geom, aes, data, k, xs, ys)
    theme.alphas = [0.6]
    ribbon = Gadfly.Geom.render(Gadfly.Geom.ribbon(), theme, rib_aes)

    w = Gadfly.w
    h = Gadfly.h
    box = Gadfly.BoundingBox(0.0w, 0.0h, 1.0w, 1.0h)

    # box = Gadfly.context(units=Gadfly.UnitBox(0, 0, 100, 0))
    # box = Gadfly.context(0.0w, 0.0h, 1.4w, 1.0h)

    ymax = maximum(ys)
    xmin = quantile(k.density, 0.01)
    xmax = quantile(k.density, 0.99)

# TODO: Add Geom.line
# TODO: Fix the missing param.
    
    # coord = Gadfly.Coord.cartesian(; xmin, xmax, ymax, ymin=0)
    # scales = Dict{Symbol, Gadfly.ScaleElement}()
    # box = Gadfly.Coord.apply_coordinate(coord, [aes], scales)

    ctx = Gadfly.compose(ribbon, lower, upper)
    ctx
end
