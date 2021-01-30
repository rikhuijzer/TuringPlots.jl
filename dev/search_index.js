var documenterSearchIndex = {"docs":
[{"location":"#TuringPlots","page":"TuringPlots","title":"TuringPlots","text":"","category":"section"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"using Markdown\nusing TuringPlots\nT = TuringPlots\n\n# This is meant to circumvent a Documenter.jl eval issue, see\n# https://github.com/JuliaDocs/Documenter.jl/issues/1514. \ninclude(\"../src/build.jl\")","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"This package defines plotting functions for Chains objects, such as","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"chn","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"These objects are typically created with sample from Turing.jl. The plots in this package are based on Gadfly.jl.","category":"page"},{"location":"#Parameters-and-chains","page":"TuringPlots","title":"Parameters and chains","text":"","category":"section"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"To plot individual parameters, use plot. This extends Gadfly, so you can pass Gadfly elements like Geom.density and Guide.ylabel:","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"using Gadfly\nusing TuringPlots\n\nfilename = \"turingplot.svg\" # hide\nT.write_svg(filename, # hide\nplot(chn, x = :parameter, color = :parameter, Geom.density, Guide.ylabel(\"Density\"))\n) # hide\nMarkdown.parse(\"![Density plot for θ]($filename)\") # hide","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"To show only one parameter, use filter:","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filename = \"first-filter.svg\" # hide\nT.write_svg(filename, # hide\nplot(chn, x = :parameter, filter = ([:parameter] => ==(:α)), \n    Geom.density, Guide.ylabel(\"Density\"))\n) # hide\nMarkdown.parse(\"![Density plot for θ]($filename)\") # hide","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"This works because the Chains object is converted to a DataFrame of the shape","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"parameter chain id value\nα 1 1 ...\nα 1 2 ...\n... ... ... ...\nα 2 1 ...\nα 2 2 ...\n... ... ... ...\nθ 1 1 ...\nθ 1 2 ...\n... ... ... ...\nθ 2 1 ...\nθ 2 2 ...","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"and the filter is applied to this DataFrame via filter. See the DataFrames.jl documentation for details. So, to plot only parameter :α, use","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filter = ([:parameter] => ==(:α))","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"To plot only the first chain, use ","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filter = ([:chain] => i -> i == 1)","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"Or, for the first two chains","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filter = ([:chain] => i -> i < 3)","category":"page"},{"location":"#All-parameters","page":"TuringPlots","title":"All parameters","text":"","category":"section"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"To plot, for all parameters, the sample values per iteration and the densities, use plot_parameters:","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filename = \"summary.svg\" # hide\nT.write_svg(filename, # hide\nplot_parameters(chn)\n; w=8inch, h=6inch) # hide\nMarkdown.parse(\"![Density plot all parameters]($filename)\") # hide","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"The same filtering as above works here too. Showing only the first 300 samples and 2 chains:","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filename = \"summary-filter.svg\" # hide\nT.write_svg(filename, # hide\nplot_parameters(chn, filter = ([:id, :chain] => (i, c) -> i <= 300 && c <= 2))\n; w=8inch, h=6inch) # hide\nMarkdown.parse(\"![Density plot all parameters]($filename)\") # hide","category":"page"},{"location":"#Central-credible-intervals","page":"TuringPlots","title":"Central credible intervals","text":"","category":"section"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"Showing vertical lines for the 90% central credible interval is possible by using ","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filename = \"ci.svg\" # hide\nT.write_svg(filename, # hide\nplot(chn, x = :parameter, vertical_ci_bars(; lower_quantile=0.05, upper_quantile=0.95))\n) # hide\nMarkdown.parse(\"![Vertical central credible intervals]($filename)\") # hide","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filename = \"ci-two-parameters.svg\" # hide\nT.write_svg(filename, # hide\nplot(chn, x = :parameter, color = :parameter, vertical_ci_bars())\n) # hide\nMarkdown.parse(\"![Vertical central credible intervals]($filename)\") # hide","category":"page"}]
}