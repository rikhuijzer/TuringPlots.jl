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

function vertical_ribbon_aes(geom, aes, data, k, xs, ys)
    new_aes = Gadfly.Aesthetics()
    new_aes.x = float.(xs)
    new_aes.ymin = float.(repeat([0], length(xs)))
    new_aes.ymax = float.(ys)
    new_aes
end

function Gadfly.Geom.render(geom::DensityCI, theme::Gadfly.Theme, aes::Gadfly.Aesthetics)
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

    ribbon_aes = vertical_ribbon_aes(geom, aes, data, k, xs, ys)
    theme.alphas = [0.6]
    ribbon = Gadfly.Geom.render(Gadfly.Geom.ribbon(), theme, ribbon_aes)

    w = Gadfly.w
    h = Gadfly.h
    box = Gadfly.BoundingBox(0.0w, 0.0h, 1.0w, 1.0h)


    size_ctx = Gadfly.context(minwidth = 200, 
        minheight = 100, units = Gadfly.UnitBox())

    ctx = Gadfly.compose(ribbon, lower, upper)
    inch = Gadfly.inch
    @show ctx.box
    @show ctx.clip
    @show ctx.minwidth
    ctx
end
