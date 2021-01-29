# TuringPlots

```@setup tutorial
using Markdown
using TuringPlots
T = TuringPlots

# This is meant to circumvent a Documenter.jl eval issue, see
# https://github.com/JuliaDocs/Documenter.jl/issues/1514. 
include("../src/build.jl")
```

This package defines plotting functions for `Chains` objects, such as

```@example tutorial
chn
```

These objects are typically created with `sample` from [Turing.jl](https://github.com/TuringLang/Turing.jl/).
The plots in this package are based on [Gadfly.jl](https://github.com/GiovineItalia/Gadfly.jl).

## Individual parameters

To plot individual parameters, use `plot`.
This is an extension of `Gadfly.plot`, so you can pass Gadfly elements like `Geom.density` and `Guide.ylabel`:

```@example tutorial
using Gadfly
using TuringPlots

filename = "turingplot.svg" # hide
T.write_svg(filename, # hide
plot(chn, x = :θ, Geom.density, Guide.ylabel("Density"))
) # hide
Markdown.parse("![Density plot for θ]($filename)") # hide
```

## All parameters

To plot all the parameters, use `plot_parameters`:

```@example tutorial
filename = "summary.svg" # hide
T.write_svg(filename, # hide
plot_parameters(chn)
; w=8inch, h=6inch) # hide
Markdown.parse("![Density plot all parameters]($filename)") # hide
```

## Central credible intervals

Showing vertical lines for the 90% central credible interval is possible by using 

```@example tutorial
filename = "ci.svg" # hide
T.write_svg(filename, # hide
plot(chn, x = :θ, vertical_ci_bars(; lower_quantile=0.05, upper_quantile=0.95))
) # hide
Markdown.parse("![Vertical central credible intervals]($filename)") # hide
```

This can be used to create plots like the ones created by Ross et al. ([2020](#ross2020)).

## References

```@raw html
<div id="ross2020"></div>
```
Cody T. Ross, Bruce Winterhalder, Richard McElreath. (2020).
Racial Disparities in Police Use of Deadly Force Against Unarmed Individuals Persist After Appropriately Benchmarking Shooting Data on Violent Crime Rates.
<https://doi.org/10.1177/1948550620916071>
