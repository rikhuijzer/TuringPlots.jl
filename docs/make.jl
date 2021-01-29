push!(LOAD_PATH,"../src/")

using Documenter
using TuringPlots

T = TuringPlots

name = "TuringPlots.jl"

makedocs(
    sitename = name,
    pages = [
        "TuringPlots" => "index.md",
    ],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true")
)

include("src/build.jl")
build()

deploydocs(repo = "github.com/rikhuijzer/$name.git", devbranch = "main")
