mutable struct Apple 
    x::Int
    y::Int
    scale::Int
    Apple(area::Area) = (x = new(); x.scale = area.unitSize; x)
end

function moveApple(apple::Apple, x::Int, y::Int)
    apple.x = x
    apple.y = y
end

function AppleToJSON(apple::Apple)
    return JSON.json(Dict(
        "x" => apple.x,
        "y" => apple.y,
        "scale" => apple.scale
    ))
end 
