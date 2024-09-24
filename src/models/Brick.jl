mutable struct Brick 
    x::Int
    y::Int
    scale::Int
    Brick(area::Area) = (x = new(); x.scale = area.unitSize; x)
end

function moveBrick(brick::Brick, x::Int, y::Int)
    brick.x = x
    brick.y = y
end

function BrickToJSON(brick::Brick)
    return JSON.json(Dict(
        "x" => brick.x,
        "y" => brick.y,
        "scale" => brick.scale
    ))
end 
