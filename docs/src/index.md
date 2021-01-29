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
This is an extension of `Gadfly.plot`, so you can pass Gadfly elements like `Geom.density` and `Guide.ylabel`:

```@example tutorial
using Gadfly
using TuringPlots

filename = "turingplot.svg" # hide
T.write_svg(filename, # hide
plot(chn, x = :parameter, filter = ([:parameter] => p -> p == :α), 
    Geom.density, Guide.ylabel("Density"))
) # hide
Markdown.parse("![Density plot for θ]($filename)") # hide
```

Basically, the Chains object is converted to a DataFrame of the shape

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

and the filter is applied to this DataFrame via `filter!` (see DataFrames.jl documentation).
So, to plot only parameter `:α`, use
```
filter = ([:parameter] => ==(:α))
```
To plot only the first chain, use 
```
filter = ([:chain] => ==(1))
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
Showing only the first 500 samples:

```@example tutorial
filename = "summary-filter.svg" # hide
T.write_svg(filename, # hide
plot_parameters(chn, filter = ([:id] => i -> i <= 500))
; w=8inch, h=6inch) # hide
Markdown.parse("![Density plot all parameters]($filename)") # hide
```

## Central credible intervals

Showing vertical lines for the 90% central credible interval is possible by using 

```@example tutorial
filename = "ci.svg" # hide
T.write_svg(filename, # hide
plot(chn, x = :parameter, vertical_ci_bars(; lower_quantile=0.05, upper_quantile=0.95))
) # hide
Markdown.parse("![Vertical central credible intervals]($filename)") # hide
```

```@example tutorial
filename = "ci-two-parameters.svg" # hide
T.write_svg(filename, # hide
plot(chn, x = :parameter, color = :parameter, vertical_ci_bars())
) # hide
Markdown.parse("![Vertical central credible intervals]($filename)") # hide
```
