using QML
using Observables
using Random
using JSON

# Define window size
const windowHeight = 600
const windowWidth = 900
const brickCount = 6
const levelScores = [10,20,30]

# Create a random number generator.
randomGenerator = MersenneTwister() 

# Includes need files
include("models/Game.jl")
include("models/Area.jl")
include("models/Apple.jl")
include("models/Snake.jl")
include("models/Brick.jl")
include("utils/helpers.jl")
include("controller.jl")

# Create the models and load the game data.
area = Area()
apple = Apple(area)
snake = Snake(area)
resetSnake(snake,area)
game = getData()

# Create brick
bricks = [Brick(area) for x in 1:brickCount];

# Define the game as prop and snd to the QML view
props = JSON.json(Dict(
    "snake" => SnakeToJSON(snake),
    "apple" => AppleToJSON(apple),
    "game" => JSON.json(game),
    "levelScores" => JSON.json(levelScores)
))

# Registers function that we be call from the QML view
qmlfunction("moveApple",moveApple)
qmlfunction("moveBricks",moveBricks)
qmlfunction("setSnake",setSnake)
qmlfunction("setGameOver",setGameOver)
qmlfunction("resetSnake",resetSnake)

# Load the QML view with differents params.
loadqml("src/view.qml", props=props, areaWidth=area.width, areaHeight=area.height, bestScore=game["bestScore"])
exec_async()