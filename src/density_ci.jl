export
    density_ci

struct DensityCI <: Gadfly.GeometryElement
  n_samples::Int
  bandwidth::Real
end
DensityCI(; n_samples=256, bandwidth=-Inf) = DensityCI(n_samples, bandwidth)

Gadfly.Stat.input_aesthetics(stat::DensityCIStatistic) = [:x, :color]
Gadfly.Stat.output_aesthetics(stat::DensityCIStatistic) = [:x, :y, :ymin, :ymax, :color]
Gadfly.Stat.default_scales(::DensityCIStatistic) = [Gadfly.Scale.y_continuous()]

density_ci() = DensityCI()

function Gadfly.Stat.apply_statistic(stat::DensityCIStatistic,
        scales::Dict{Symbol, Gadfly.ScaleElement},
        coord::Gadfly.CoordinateElement,
        aes::Gadfly.Aesthetics)
    Gadfly.assert_aesthetics_defined("DensityCIStatistic", aes, :x)
    
    if isnothing(aes.color)
        println("Not implemented")
    else
        groups = Dict()
        for (x, c) in zip(aes.x, Gadfly.cycle(aes.color))
            if !haskey(groups, c)
                groups[c] = Float64[x]
            else
                push!(groups[c], x)
            end
        end

        colors = Array{Gadfly.RGB{Float32}}(undef, 0)
        aes.x = Array{Float64}(undef, 0)
        aes.y = Array{Float64}(undef, 0)
        for (c, xs) in groups
            bandwidth = stat.bandwidth <= 0.0 ? 
                KernelDensity.default_bandwidth(xs) : 
                stat.bandwidth
            k = KernelDensity.kde(xs; bandwidth, npoints=stat.n_samples)
            append!(aes.x, k.x)
            append!(aes.y, k.density)
            for _ in 1:length(k.x)
                push!(colors, c)
            end
        end
        aes.color = Gadfly.discretize_make_ia(colors)

        aes.ymin = repeat([0], length(aes.x))
        aes.ymax = repeat([0], length(aes.x))
    end
    aes.y_label = Gadfly.Scale.identity_formatter
end

Gadfly.Geom.element_aesthetics(::DensityCI) = [:x, :y, :size, :color, :shape, :alpha]

# Awesome, this one is called inside subplot and we can just call other render functions.
# The reason that we only have aes is because this method is very generic.
# Works for subplot, but also for normal plots.
function Gadfly.Geom.render(geom::DensityCI, theme::Gadfly.Theme, aes::Gadfly.Aesthetics)
    data = aes.y
    k, xs, ys = kde_values(data)
    xmin = first(xs)
    ymin = repeat([0.0], length(xs))
    xlower = quantile(data, 0.1)
    ylower = pdf(k, xlower)

    lower_start = xlower - 0.01
    lower_end = xlower + 0.01
    indexes = findall(x -> lower_start <= x && x <= lower_end, xs)
    aes.xmin = float.(xs[indexes])
    aes.xmax = float.(xs[indexes] .+ 0.01)
    # aes.x = float.(indexes)
    aes.ymin = float.(repeat([0], length(indexes)))
    aes.ymax = float.(ys[indexes])
    aes.color = [Gadfly.LCHab(70, 60, 240)] # ["red"]
    # aes.color = repeat([aes.color], length(indexes))

    Gadfly.Geom.render(Gadfly.Geom.rect(), theme, aes)
end
