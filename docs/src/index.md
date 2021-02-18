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

## Parameters and chains

To plot individual parameters, use `plot`.
This extends Gadfly, so you can pass Gadfly elements like `Geom.density` and `Guide.ylabel`:

```@example tutorial
using Gadfly
using TuringPlots

filename = "turingplot.svg" # hide
T.write_svg(filename, # hide
plot(chn, x = :parameter, color = :parameter, Geom.density, Guide.ylabel("Density"))
) # hide
Markdown.parse("![Density plot for θ]($filename)") # hide
```

To show only one parameter, use `filter`:

```@example tutorial
filename = "first-filter.svg" # hide
T.write_svg(filename, # hide
plot(chn, x = :parameter, filter = ([:parameter] => ==(:α)), 
    Geom.density, Guide.ylabel("Density"))
) # hide
Markdown.parse("![Density plot for θ]($filename)") # hide
```

This works because the Chains object is converted to a DataFrame of the shape

parameter | chain | id | value 
--- | --- | --- | ---
α | 1 | 1 | ...
α | 1 | 2 | ...
... | ... | ... | ...
α | 2 | 1 | ...
α | 2 | 2 | ...
... | ... | ... | ...
θ | 1 | 1 | ...
θ | 1 | 2 | ...
... | ... | ... | ...
θ | 2 | 1 | ...
θ | 2 | 2 | ...

and the filter is applied to this DataFrame via `filter`.
See the [DataFrames.jl documentation](https://dataframes.juliadata.org/stable/lib/functions/#Base.filter) for details.
So, to plot only parameter `:α`, use
```
filter = ([:parameter] => ==(:α))
```
To plot only the first chain, use 
```
filter = ([:chain] => i -> i == 1)
```
Or, for the first two chains
```
filter = ([:chain] => i -> i < 3)
```

## Sample values and densities

To plot, for all parameters, the sample values per iteration and the densities, use `plot_parameters`:

```@example tutorial
filename = "summary.svg" # hide
T.write_svg(filename, # hide
plot_parameters(chn)
; w=8inch, h=6inch) # hide
Markdown.parse("![Density plot all parameters]($filename)") # hide
```

The same filtering as above works here too.
Showing only the first 300 samples and 2 chains:

```@example tutorial
filename = "summary-filter.svg" # hide
T.write_svg(filename, # hide
plot_parameters(chn, filter = ([:id, :chain] => (i, c) -> i <= 300 && c <= 2))
; w=8inch, h=6inch) # hide
Markdown.parse("![Density plot all parameters]($filename)") # hide
```

## Multiple models

Passing a NamedTuple as the first argument is interpreted as names and MCMCChains.Chains.
This can be used to plot multiple models:

```@example tutorial
filename = "multiple-models.svg" # hide
models = (A = chn, B = chn2)
T.write_svg(filename, # hide
plot(models, x = :value,
    color = :chain,
    xgroup = :parameter, ygroup = :model,
    Guide.xlabel("Parameter"),
    Guide.ylabel("Model"),
    Geom.subplot_grid(
      Geom.density,
      Guide.xlabel(orientation=:horizontal)
    )
)
; w=8inch, h=6inch) # hide
Markdown.parse("![Density plot all parameters]($filename)") # hide
```

## Bars for quantiles

```@example tutorial
filename = "density-quantiles.svg" # hide
T.write_svg(filename, # hide
Gadfly.plot(chn, y = :value,
    filter = ([:parameter] => ==(:α)),
    Gadfly.Guide.title("Density with bars showing the central 90 % credible interval"),
    Gadfly.Scale.x_continuous(minvalue=0, maxvalue=1.2),
    Gadfly.Scale.y_continuous(minvalue=0, maxvalue=2.2),
    Gadfly.Guide.xlabel("Sample value"),
    Gadfly.Guide.ylabel("Density"),
    Gadfly.Stat.xticks(ticks = collect(0.2:0.2:1.0)),
    density_ci(quantiles = [0.05, 0.95])
)
) # hide
Markdown.parse("![Density plot all parameters]($filename)") # hide
```

```@example tutorial
filename = "subplot-ci.svg" # hide
T.write_svg(filename, # hide
plot(chn, y = :value,
    Scale.x_continuous(minvalue=0, maxvalue=1.2),
    Scale.y_continuous(minvalue=0, maxvalue=2.6),
    Guide.title("Densities with bars showing the central 90% credible interval"),
    Guide.xlabel("Parameter"),
    Guide.ylabel("Chain"),
    Stat.xticks(ticks = collect(0.2:0.2:1.0)),
    xgroup = :parameter, ygroup = :chain,
    Geom.subplot_grid(
        density_ci(quantiles = [0.05, 0.95]),
        Guide.xlabel(orientation=:horizontal),
    )
)
; w=8inch, h=6inch) # hide
Markdown.parse("![Vertical central credible intervals]($filename)") # hide
```

```@example tutorial
filename = "multiple-models-ci.svg" # hide
models = (A = chn, B = chn2)
T.write_svg(filename, # hide
plot(models, y = :value,
    Scale.x_continuous(minvalue=0, maxvalue=1.2),
    Scale.y_continuous(minvalue=0, maxvalue=2.6),
    Guide.title("Densities with bars showing the central 90% credible interval"),
    xgroup = :parameter, ygroup = :model,
    Guide.xlabel("Parameter"),
    Guide.ylabel("Model"),
    Geom.subplot_grid(
      density_ci(quantiles = [0.05, 0.95]),
      Guide.xlabel(orientation=:horizontal)
    )
)
; w=8inch, h=6inch) # hide
Markdown.parse("![Density plot all parameters]($filename)") # hide
```

`density_ci` doesn't support multiple colors yet and the scales have to be manually set.
