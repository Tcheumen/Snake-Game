"""
    mutable struct Area

A structure to represent an area in the game.

# Fields
- `margin::Int`: The margin of the area.
- `width::Int`: The width of the area.
- `height::Int`: The height of the area.
- `unitSize::Int`: The size of each unit in the area.
- `units::Int`: The total number of units in the area.

# Constructor
- `Area(margin::Int)`: Initializes an `Area` object with a given margin.
"""
mutable struct Area 
    margin::Int 
    width::Int 
    height::Int 
    unitSize::Int 
    units::Int 
    Area(margin::Int) = (x = new(); x.margin = margin; x)
end 

"""
    Area() -> Area

Create a new `Area` object with default values.

# Returns
- `Area`: A new `Area` object.
"""
function Area()
    area = Area(50)
    area.unitSize = 25
    area.width = windowWidth - 2*area.margin
    area.height = windowHeight - 2*area.margin
    area.units = (area.width*area.height) / area.unitSize * area.unitSize
    return area
end

"""
    AreaToJSON(area::Area) -> String

Convert an `Area` object to a JSON string.

# Arguments
- `area::Area`: The area object to be converted.

# Returns
- `String`: A JSON string representing the area.
"""
function AreaToJSON(area::Area) 
    return JSON.json(AreaToDict(area))
end 

"""
    DictToArea(dict::Dict) -> Area

Convert a dictionary to an `Area` object.

# Arguments
- `dict::Dict`: The dictionary to be converted.

# Returns
- `Area`: An `Area` object created from the dictionary.
"""
function DictToArea(dict::Dict)
    area = Area() 
    area.margin = dict["margin"]
    area.width = dict["width"]
    area.height = dict["height"]
    area.unitSize = dict["unitSize"]
    area.units = dict["units"]
    return area
end 


function AreaToDict(area::Area) 
    return Dict(
        "margin" => area.margin,
        "width" => area.width,
        "height" => area.height,
        "unitSize" => area.unitSize,
        "units" => area.units
    )
end


function moveArea(area::Area, x::Int, y::Int)
    if x == y 
        area.margin = x
    end
end
