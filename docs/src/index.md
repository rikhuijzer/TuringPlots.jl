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

```@autodocs
Modules = [TuringPlots]
Public = true
```

```@autodocs
Modules = [TuringPlots]
Private = true
```
