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

@model function binom(n, k)
     θ ~ Beta(1, 1)
     k ~ Binomial(n, θ) 
     return k, θ
end
chains = sample(binom(9, 6), NUTS(0.65), 1000)
```
