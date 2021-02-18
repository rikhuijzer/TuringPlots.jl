var documenterSearchIndex = {"docs":
[{"location":"library/#Library","page":"Library","title":"Library","text":"","category":"section"},{"location":"library/","page":"Library","title":"Library","text":"Modules = [TuringPlots]","category":"page"},{"location":"library/#Gadfly.plot-Tuple{MCMCChains.Chains, Vararg{Union{Vector{Gadfly.Layer}, Function, Gadfly.Element, Gadfly.Theme, Type}, N} where N}","page":"Library","title":"Gadfly.plot","text":"plot(chn::MCMCChains.Chains,\n    elements::Gadfly.ElementOrFunctionOrLayers...; mapping...) -> Plot\n\nPlot a chains object by transforming it to a DataFrame. Settings are passed to Gadfly via elements and mapping.\n\n\n\n\n\n","category":"method"},{"location":"library/#Gadfly.plot-Tuple{NamedTuple, Vararg{Union{Vector{Gadfly.Layer}, Function, Gadfly.Element, Gadfly.Theme, Type}, N} where N}","page":"Library","title":"Gadfly.plot","text":"plot(models::NamedTuple,\n    elements::Gadfly.ElementOrFunctionOrLayers...; mapping...) -> Plot\n\nPlot multipleMCMCChains.Chains by transforming the models to a DataFrame, where names(df) == [\"model\", \"parameter\", \"chain\", \"id\", \"value\"].\n\n\n\n\n\n","category":"method"},{"location":"library/#Gadfly.render-Tuple{TuringPlots.DensityCI, Gadfly.Theme, Gadfly.Aesthetics}","page":"Library","title":"Gadfly.render","text":"Gadfly.Geom.render(geom::DensityCI, theme, aes)\n\nWe need to do all the rendering manually because Gadfly.Geom.density  is a line element and therefore cannot do a ribbon at the same time. The way to get that normally would be via Gadfly.Stat.density with Geom.polygon. Unfortunately, the polygon doesn't work with subplot_grid.\n\n\n\n\n\n","category":"method"},{"location":"library/#TuringPlots.apply_filter!-Tuple{Any, Any}","page":"Library","title":"TuringPlots.apply_filter!","text":"apply_filter!(df, mapping)\n\nIf the user has defined a filter, then apply this to df.\n\n\n\n\n\n","category":"method"},{"location":"library/#TuringPlots.n_chains-Tuple{MCMCChains.Chains, Any}","page":"Library","title":"TuringPlots.n_chains","text":"n_chains(chn::Chains, parameter)\n\nNumber of chains for chn[parameter].\n\n\n\n\n\n","category":"method"},{"location":"library/#TuringPlots.nominal_chain!-Tuple{Any}","page":"Library","title":"TuringPlots.nominal_chain!","text":"nominal_chain!(df)\n\nChange the column :chain in df to type String to make it nominal. Otherwise, Gadfly will give it a continuous legend which makes no sense here.\n\n\n\n\n\n","category":"method"},{"location":"library/#TuringPlots.plot_parameters-Tuple{MCMCChains.Chains}","page":"Library","title":"TuringPlots.plot_parameters","text":"plot_parameters(chn::Chains)\n\nPlot sample value and density for each parameter of chains. The plot is built by creating two Gadfly.subplot_grids and using Gadfly.hstack.\n\n\n\n\n\n","category":"method"},{"location":"#TuringPlots","page":"TuringPlots","title":"TuringPlots","text":"","category":"section"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"using Markdown\nusing TuringPlots\nT = TuringPlots\n\n# This is meant to circumvent a Documenter.jl eval issue, see\n# https://github.com/JuliaDocs/Documenter.jl/issues/1514. \ninclude(\"../src/build.jl\")","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"This package defines plotting functions for Chains objects, such as","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"chn","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"These objects are typically created with sample from Turing.jl. The plots in this package are based on Gadfly.jl.","category":"page"},{"location":"#Parameters-and-chains","page":"TuringPlots","title":"Parameters and chains","text":"","category":"section"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"To plot individual parameters, use plot. This extends Gadfly, so you can pass Gadfly elements like Geom.density and Guide.ylabel:","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"using Gadfly\nusing TuringPlots\n\nfilename = \"turingplot.svg\" # hide\nT.write_svg(filename, # hide\nplot(chn, x = :parameter, color = :parameter, Geom.density, Guide.ylabel(\"Density\"))\n) # hide\nMarkdown.parse(\"![Density plot for θ]($filename)\") # hide","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"To show only one parameter, use filter:","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filename = \"first-filter.svg\" # hide\nT.write_svg(filename, # hide\nplot(chn, x = :parameter, filter = ([:parameter] => ==(:α)), \n    Geom.density, Guide.ylabel(\"Density\"))\n) # hide\nMarkdown.parse(\"![Density plot for θ]($filename)\") # hide","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"This works because the Chains object is converted to a DataFrame of the shape","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"parameter chain id value\nα 1 1 ...\nα 1 2 ...\n... ... ... ...\nα 2 1 ...\nα 2 2 ...\n... ... ... ...\nθ 1 1 ...\nθ 1 2 ...\n... ... ... ...\nθ 2 1 ...\nθ 2 2 ...","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"and the filter is applied to this DataFrame via filter. See the DataFrames.jl documentation for details. So, to plot only parameter :α, use","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filter = ([:parameter] => ==(:α))","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"To plot only the first chain, use ","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filter = ([:chain] => i -> i == 1)","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"Or, for the first two chains","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filter = ([:chain] => i -> i < 3)","category":"page"},{"location":"#Sample-values-and-densities","page":"TuringPlots","title":"Sample values and densities","text":"","category":"section"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"To plot, for all parameters, the sample values per iteration and the densities, use plot_parameters:","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filename = \"summary.svg\" # hide\nT.write_svg(filename, # hide\nplot_parameters(chn)\n; w=8inch, h=6inch) # hide\nMarkdown.parse(\"![Density plot all parameters]($filename)\") # hide","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"The same filtering as above works here too. Showing only the first 300 samples and 2 chains:","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filename = \"summary-filter.svg\" # hide\nT.write_svg(filename, # hide\nplot_parameters(chn, filter = ([:id, :chain] => (i, c) -> i <= 300 && c <= 2))\n; w=8inch, h=6inch) # hide\nMarkdown.parse(\"![Density plot all parameters]($filename)\") # hide","category":"page"},{"location":"#Multiple-models","page":"TuringPlots","title":"Multiple models","text":"","category":"section"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"Passing a NamedTuple as the first argument is interpreted as names and MCMCChains.Chains. This can be used to plot multiple models:","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filename = \"multiple-models.svg\" # hide\nmodels = (A = chn, B = chn2)\nT.write_svg(filename, # hide\nplot(models, x = :value,\n    color = :chain,\n    xgroup = :parameter, ygroup = :model,\n    Guide.xlabel(\"Parameter\"),\n    Guide.ylabel(\"Model\"),\n    Geom.subplot_grid(\n      Geom.density,\n      Guide.xlabel(orientation=:horizontal)\n    )\n)\n; w=8inch, h=6inch) # hide\nMarkdown.parse(\"![Density plot all parameters]($filename)\") # hide","category":"page"},{"location":"#Bars-for-quantiles","page":"TuringPlots","title":"Bars for quantiles","text":"","category":"section"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filename = \"density-quantiles.svg\" # hide\nT.write_svg(filename, # hide\nGadfly.plot(chn, y = :value,\n    filter = ([:parameter] => ==(:α)),\n    Gadfly.Guide.title(\"Density with bars showing the central 90 % credible interval\"),\n    Gadfly.Scale.x_continuous(minvalue=0, maxvalue=1.2),\n    Gadfly.Scale.y_continuous(minvalue=0, maxvalue=2.2),\n    Gadfly.Guide.xlabel(\"Sample value\"),\n    Gadfly.Guide.ylabel(\"Density\"),\n    Gadfly.Stat.xticks(ticks = collect(0.2:0.2:1.0)),\n    density_ci(quantiles = [0.05, 0.95])\n)\n) # hide\nMarkdown.parse(\"![Density plot all parameters]($filename)\") # hide","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filename = \"subplot-ci.svg\" # hide\nT.write_svg(filename, # hide\nplot(chn, y = :value,\n    Scale.x_continuous(minvalue=0, maxvalue=1.2),\n    Scale.y_continuous(minvalue=0, maxvalue=2.6),\n    Guide.title(\"Densities with bars showing the central 90% credible interval\"),\n    Guide.xlabel(\"Parameter\"),\n    Guide.ylabel(\"Chain\"),\n    Stat.xticks(ticks = collect(0.2:0.2:1.0)),\n    xgroup = :parameter, ygroup = :chain,\n    Geom.subplot_grid(\n        density_ci(quantiles = [0.05, 0.95]),\n        Guide.xlabel(orientation=:horizontal),\n    )\n)\n; w=8inch, h=6inch) # hide\nMarkdown.parse(\"![Vertical central credible intervals]($filename)\") # hide","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"filename = \"multiple-models-ci.svg\" # hide\nmodels = (A = chn, B = chn2)\nT.write_svg(filename, # hide\nplot(models, y = :value,\n    Scale.x_continuous(minvalue=0, maxvalue=1.2),\n    Scale.y_continuous(minvalue=0, maxvalue=2.6),\n    Guide.title(\"Densities with bars showing the central 90% credible interval\"),\n    xgroup = :parameter, ygroup = :model,\n    Guide.xlabel(\"Parameter\"),\n    Guide.ylabel(\"Model\"),\n    Geom.subplot_grid(\n      density_ci(quantiles = [0.05, 0.95]),\n      Guide.xlabel(orientation=:horizontal)\n    )\n)\n; w=8inch, h=6inch) # hide\nMarkdown.parse(\"![Density plot all parameters]($filename)\") # hide","category":"page"},{"location":"","page":"TuringPlots","title":"TuringPlots","text":"density_ci doesn't support multiple colors yet and the scales have to be manually set.","category":"page"}]
}
