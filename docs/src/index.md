# TuringPlots

An example plot:

```@setup tutorial
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

```@example tutorial
using Turing
```
