# TuringPlots

An example plot:

```@eval
import TuringPlots as T
using Markdown

p = T.example_plot()
file = "plot.svg"
T.write_svg(file, p)
Markdown.parse("![Plot]($file)")
```

This package extends `Gadfly.plot` for `MCMCChains.Chains`

```@example tutorial
using Turing
using TuringPlots

@model function binom(n, k)
     θ ~ Beta(1, 1)
     k ~ Binomial(n, θ) 
     return k, θ
end
chains = sample(binom(9, 6), NUTS(0.65), 1000)

file = "chains-plot.svg" # hide
T.write_svg(file, # hide
plot(chains, y = :θ)
) # hide
Markdown.parse("![Plot]($file)") # hide
```

```@docs
plot(::MCMCChains.Chains)
```
