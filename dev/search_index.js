var documenterSearchIndex = {"docs":
[{"location":"#TuringPlots","page":"TuringPlots","title":"TuringPlots","text":"","category":"section"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"using Markdown\nusing TuringPlots\nT = TuringPlots\n\n# This is meant to circumvent a Documenter.jl eval issue, see\n# https://github.com/JuliaDocs/Documenter.jl/issues/1514. \ninclude(\"../src/build.jl\")","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"This package defines plotting functions for Chains objects, such as","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"chn","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"These objects are typically created with sample from Turing.jl. The plots in this package are based on Gadfly.jl.","category":"page"},{"location":"#Individual-parameters","page":"TuringPlots","title":"Individual parameters","text":"","category":"section"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"To plot individual parameters, use plot. This is an extension of Gadfly.plot, so you can pass Gadfly elements like Geom.density and Guide.ylabel:","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"using Gadfly\nusing TuringPlots\n\nfilename = \"turingplot.svg\" # hide\nT.write_svg(filename, # hide\nplot(chn, x = :θ, Geom.density, Guide.ylabel(\"Density\"))\n) # hide\nMarkdown.parse(\"![Density plot for θ]($filename)\") # hide","category":"page"},{"location":"#All-parameters","page":"TuringPlots","title":"All parameters","text":"","category":"section"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"To plot all the parameters, use plot_parameters:","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filename = \"summary.svg\" # hide\nT.write_svg(filename, # hide\nplot_parameters(chn)\n; w=8inch, h=6inch) # hide\nMarkdown.parse(\"![Density plot all parameters]($filename)\") # hide","category":"page"},{"location":"#Central-credible-intervals","page":"TuringPlots","title":"Central credible intervals","text":"","category":"section"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"Showing vertical lines for the 90% central credible interval is possible by using ","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filename = \"ci.svg\" # hide\nT.write_svg(filename, # hide\nplot(chn, x = :θ, vertical_ci_bars(; lower_quantile=0.05, upper_quantile=0.95))\n) # hide\nMarkdown.parse(\"![Vertical central credible intervals]($filename)\") # hide","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"This can be used to create plots like the ones created by Ross et al. (2020).","category":"page"},{"location":"#References","page":"TuringPlots","title":"References","text":"","category":"section"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"<div id=\"ross2020\"></div>","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"Cody T. Ross, Bruce Winterhalder, Richard McElreath. (2020). Racial Disparities in Police Use of Deadly Force Against Unarmed Individuals Persist After Appropriately Benchmarking Shooting Data on Violent Crime Rates. https://doi.org/10.1177/1948550620916071","category":"page"}]
}
