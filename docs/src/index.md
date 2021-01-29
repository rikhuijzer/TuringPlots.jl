# TuringPlots

```@setup tutorial
using Markdown
using TuringPlots
T = TuringPlots

# This is meant to circumvent a Documenter.jl eval issue, see
# https://github.com/JuliaDocs/Documenter.jl/issues/1514. 
include("../src/build.jl")
```

After training a Turing model, we end up with a chain such as
```@example tutorial
chn
```

This package extends `Gadfly.plot` for `MCMCChains.Chains`.
Therefore, we can pass Gadfly elements, such as, `Geom.density`:

```@example tutorial
using Gadfly
using TuringPlots

filename = "turingplot.svg" # hide
T.write_svg(filename, # hide
plot(chn, x = :θ, Geom.density, Guide.ylabel("Density"))
) # hide
Markdown.parse("![Density plot for θ]($filename)") # hide
```

It is also possible to plot a summary for the parameters:

```@example tutorial
filename = "summary.svg" # hide
T.write_svg(filename, # hide
plot_parameters(chn)
; w=11inch, h=8inch) # hide
Markdown.parse("![Density plot for θ]($filename)") # hide
```
