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

## All parameters

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

## Bars for quantiles

```@example tutorial
filename = "subplot-ci.svg" # hide
T.write_svg(filename, # hide
Gadfly.plot(chn, y = :value,
    Gadfly.Scale.x_continuous(minvalue=0, maxvalue=1.4),
    Gadfly.Scale.y_continuous(minvalue=0, maxvalue=2.6),
    Gadfly.Guide.title("Density with bars for the central 90% credible interval"),
    Gadfly.Guide.xlabel("Parameter"),
    Gadfly.Guide.ylabel("Chain"),
    Gadfly.Stat.xticks(ticks = collect(0.2:0.2:1.0)),
    xgroup = :parameter, ygroup = :chain,
    Gadfly.Geom.subplot_grid(
        density_ci(quantiles = [0.05, 0.95]),
        Gadfly.Guide.xlabel(orientation=:horizontal),
    )
; w=8inch, h=10inch)
) # hide
Markdown.parse("![Vertical central credible intervals]($filename)") # hide
```
