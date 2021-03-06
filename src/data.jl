using CategoricalArrays
using DataFrames
using Distributions
using Random

function example_data()
    n = 200
    μ1 = 8
    μ2 = 12
    σ = 2

    d1 = Normal(μ1, σ)
    d2 = Normal(μ2, σ)

    Random.seed!(123)
    classes = CategoricalArray(rand(["A", "B"], n))

    df = DataFrame(
        class = CategoricalArray(classes),
        U = [class == "A" ? rand(d1) : rand(d2) for class in classes],
        V = rand(Normal(100, 10), n)
    )
end
