# TuringPlots

An example plot:

```@setup tutorial
include("../src/build.jl")
```

```@eval
import TuringPlots as T
using Markdown # hide

file = "plot.svg" # hide
T.write_svg(file, # hide
T.example_plot()
) # hide
Markdown.parse("![Plot]($file)") # hide
```

This package extends `Gadfly.plot` for `MCMCChains.Chains`.

```@eval
println(turingplot_code)
```

![Turing plot](turingplot.svg)
