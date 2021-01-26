module TuringPlots

import Gadfly

include("data.jl")

function example_plot()
    df = example_data()
    Gadfly.plot(df, x = :U, y = :V, color = :class)
end

write_svg(path, p) = Gadfly.draw(Gadfly.SVG(path), p)

end # module
