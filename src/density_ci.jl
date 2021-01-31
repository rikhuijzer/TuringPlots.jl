export
    density_ci

struct DensityCI <: Gadfly.GeometryElement
    quantiles::Vector{Float64}
    n_samples::Int
    bandwidth::Real
    line_width::Float64
end

function DensityCI(; 
        quantiles=[0.05, 0.95],
        n_samples=256, 
        bandwidth=-Inf,
        line_width=0.01)
    DensityCI(quantiles, n_samples, bandwidth, line_width)
end

density_ci(; kwargs...) = DensityCI(; kwargs...)

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

function vertical_bar_aes(geom, aes, data, k, xs, ys, q::Float64)
    new_aes = Gadfly.Aesthetics()

    x_range_middle = quantile(data, q)
    x_range_min = x_range_middle - geom.line_width / 2
    x_range_max = x_range_middle + geom.line_width / 2
    indexes = findall(x -> x_range_min <= x && x <= x_range_max, xs)
    new_aes.xmin = float.(xs[indexes] .- 0.001)
    new_aes.xmax = float.(xs[indexes] .+ 0.001)
    new_aes.ymin = float.(repeat([0], length(indexes)))
    new_aes.ymax = float.(ys[indexes])
    if !isnothing(aes.color)
        new_aes.color = [first(aes.color)]
    end
    new_aes
end

function ribbon_aes(geom, aes, data, k, xs, ys)
    new_aes = Gadfly.Aesthetics()
    new_aes.x = float.(xs)
    new_aes.ymin = float.(repeat([0], length(xs)))
    new_aes.ymax = float.(ys)
    if !isnothing(aes.color)
        new_aes.color = repeat([first(aes.color)], length(ys))
    end
    new_aes
end

"""
    Gadfly.Geom.render(geom::DensityCI, theme, aes)

We need to do all the rendering manually because `Gadfly.Geom.density` 
is a line element and therefore cannot do a ribbon at the same time.
The way to get that normally would be via `Gadfly.Stat.density` with `Geom.polygon`.
Unfortunately, the polygon doesn't work with subplot_grid.
"""
function Gadfly.Geom.render(geom::DensityCI, theme::Gadfly.Theme, aes::Gadfly.Aesthetics)
    Gadfly.assert_aesthetics_defined("Geom.DensityCI", aes, :y)

    default_aes = Gadfly.Aesthetics()
    # default_aes.color = Gadfly.RGBA{Float32}[theme.default_color]
    default_aes.alpha = Float64[theme.alphas[1]]
    aes = Gadfly.inherit(aes, default_aes)

    # TODO: Split up the data based on color, so that we see multiple densities.
    data = aes.y
    # @show length(data)
    # @show length(aes.color)
    k, xs, ys = kde_values(data)

    rib_aes = ribbon_aes(geom, aes, data, k, xs, ys)
    theme.alphas = [0.6]
    ribbon = Gadfly.Geom.render(Gadfly.Geom.ribbon(), theme, rib_aes)

    bars = []
    for q in geom.quantiles
        bar_aes = vertical_bar_aes(geom, aes, data, k, xs, ys, q)
        bar = Gadfly.Geom.render(Gadfly.Geom.rect(), theme, bar_aes)
        push!(bars, bar)
    end

    aes.x = xs
    aes.y = ys
    line = Gadfly.Geom.render(Gadfly.Geom.line(), theme, aes)

    Gadfly.compose(ribbon, bars..., line)
end
