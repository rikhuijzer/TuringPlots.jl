# TuringPlots

An example plot:

```@setup tutorial
# Will make the build hang.
using Gadfly: show
```

```@eval
import TuringPlots as T
using Markdown

T.example_plot()
```

This package extends `Gadfly.plot` for `MCMCChains.Chains`.

```@example tutorial
using Turing
```

```@docs
plot(::MCMCChains.Chains)
```
