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
Markdown.parse("![Density plot for θ]($filename)") # hide
```
