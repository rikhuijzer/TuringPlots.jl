export
    DensityCIStatistic

struct DensityCIStatistic <: Gadfly.StatisticElement
  n_samples::Int
  bandwidth::Real
end
DensityCIStatistic(; n_samples=256, bandwidth=-Inf) = DensityCIStatistic(n_samples, bandwidth)

Gadfly.Stat.input_aesthetics(stat::DensityCIStatistic) = [:x, :color]
Gadfly.Stat.output_aesthetics(stat::DensityCIStatistic) = [:x, :y, :color]
Gadfly.Stat.default_scales(::DensityCIStatistic) = [Gadfly.Scale.y_continuous()]

density_ci = Gadfly.Geom.LineGeometry(DensityCIStatistic())

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
            window = stat.bandwidth <= 0.0 ? KernelDensity.default_bandwidth(xs) : stat.bandwidth
            f = KernelDensity.kde(xs, bandwidth=window, npoints=stat.n_samples)
            append!(aes.x, f.x)
            append!(aes.y, f.density)
            for _ in 1:length(f.x)
                push!(colors, c)
            end
        end
        aes.color = Gadfly.discretize_make_ia(colors)
    end
end
