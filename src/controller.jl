"""
    getData() -> Dict{String, Any}

Retrieve and parse the data from the "data.json" file.

# Returns
- `Dict{String, Any}`: The parsed data from the JSON file.
"""
function getData()
    content = open("data.json", "r") do file
        read(file, String)
    end
    return JSON.parse(content)
end 

"""
    saveScore(value::Int32) -> Score

Save a new score to the "data.json" file and update the best score.

# Arguments
- `value::Int32`: The score value to be saved.

# Returns
- `Score`: The newly created score object.
"""
function saveScore(value::Int32)
    data = getData()
    score = Score(string("Player ", length(data["scores"]) + 1), value)
    data["scores"] = vcat(data["scores"], [ScoreToDict(score)])
    data["bestScore"] = maximum([x["value"] for x in data["scores"]])

    open("data.json", "w") do file
        write(file, JSON.json(data))
    end

    return score
end

"""
    setGameOver(score::Int32)

Handle the game over scenario by saving the score and emitting a game over event.

# Arguments
- `score::Int32`: The final score to be saved.
"""
function setGameOver(score::Int32)
    score = saveScore(score)
    data = getData()
    input = Dict(
        "bestScore" => data["bestScore"],
        "player" => score.player,
        "score" => score.value
    )
    @emit gameOver(JSON.json(input))
end 

"""
    moveApple()

Move the apple to a new random position within the game area and emit an appleChanged event.
"""
function moveApple()
    min::Int = area.margin / area.unitSize + 1
    maxWidth::Int = area.width / area.unitSize - 1
    maxHeight::Int = area.height / area.unitSize - 1

    x::Int = rand(randomGenerator, min:maxWidth) * area.unitSize
    y::Int = rand(randomGenerator, min:maxHeight) * area.unitSize

    moveApple(apple, x, y)
    @emit appleChanged(AppleToJSON(apple))
end 

"""
    setSnake(snakeJSONString::Any)

Update the snake based on the provided JSON string and emit the snakeChanged event if the snake is not dead.

# Arguments
- `snakeJSONString::Any`: The JSON string representing the snake's state.
"""
function setSnake(snakeJSONString::Any)
    snake = deserializeSnake(JSON.parse(snakeJSONString))
    if snakeDeath(snake, area)
        @emit snakeDied()
    else
        updateSnake(snake)
        @emit snakeChanged(SnakeToJSON(snake))
    end
end 

"""
    resetSnake(snakeJSONString::Any)

Reset the snake to its initial state based on the provided JSON string and emit the snakeChanged event.

# Arguments
- `snakeJSONString::Any`: The JSON string representing the snake's state.
"""
function resetSnake(snakeJSONString::Any)
    area = Area()
    snake = deserializeSnake(JSON.parse(snakeJSONString))
    resetSnake(snake, area)
    @emit snakeChanged(SnakeToJSON(snake))
end 

function moveBricks()
    min::Int = area.margin / area.unitSize + 1
    maxWidth::Int = area.width / area.unitSize - 1
    maxHeight::Int = area.height / area.unitSize - 1

    for brick in bricks
        x::Int = rand(randomGenerator, min:maxWidth) * area.unitSize
        y::Int = rand(randomGenerator, min:maxHeight) * area.unitSize
        moveBrick(brick, x, y)
    end 

    #return [BrickToJSON(brick) for brick in bricks]
   @emit bricksChanged(JSON.json([BrickToJSON(brick) for brick in bricks]))
end 