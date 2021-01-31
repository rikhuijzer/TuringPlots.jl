push!(LOAD_PATH,"../src/")

using Documenter
using TuringPlots

T = TuringPlots

name = "TuringPlots.jl"

makedocs(
    sitename = name,
    pages = [
        "TuringPlots" => "index.md",
        "Library" => "library.md"
    ],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true")
)

deploydocs(repo = "github.com/rikhuijzer/$name.git", devbranch = "main")
