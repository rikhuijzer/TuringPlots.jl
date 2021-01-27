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

```@example
using Turing
using TuringPlots

@model function globe_toss(n, k)
     θ ~ Beta(1, 1)
     k ~ Binomial(n, θ) 
     return k, θ
end
chains = sample(globe_toss(9, 6), NUTS(0.65), 1000)

plot(chains, y = :θ)
```

```@autodocs
Modules = [TuringPlots]
Public = true
```

```@autodocs
Modules = [TuringPlots]
Private = true
```
