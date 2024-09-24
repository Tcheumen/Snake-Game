
# Snake Game with Julia and QML

## Introduction

This document describes the Snake Game implementation using Julia and QML.

## Installation

To run this game application, follow these steps:

1. **Install Julia**: Download and install the Julia programming language.

2. **Install Required Packages**: Run the Julia REPL from the project folder and install the necessary packages:
    ```julia
    using Pkg
    Pkg.add("QML")
    Pkg.add("JSON")
    Pkg.add("Random")
    ```

3. **Run the Application**: After installing the packages, execute `main.jl` located in the `src` folder. You can run it from the command line:
    ```cmd
    julia src/main.jl
    ```
    Or from the Julia REPL:
    ```julia
    include("src/main.jl")
    ```

## Structure of the Project

The project follows the standard structure of a Julia application. We have added some folders to fit the needs of the application. Julia does not have built-in support for OOP, so the code is organized into `mutable struct` and `function` declarations. We attempt to mimic an MVC model by grouping related composite types and functions within the same file to create a kind of controller and model. However, it is not a true MVC architecture.

The view of the application uses QML. Views created with QML are not written in Julia. Some mechanisms are used to create the interconnection between Julia and QML.

## Execution Flow

1. **Import Packages**: 
    ```julia
    using QML
    using Observables
    using Random
    using JSON
    ```

2. **Define Constants and Initialize Random Generator**:
    ```julia
    # Define window size
    const windowHeight = 600
    const windowWidth = 900

    # Create a random number generator.
    randomGenerator = MersenneTwister()
    ```

3. **Include App Files**: Include the necessary files in `main.jl`:
    ```julia
    # Includes needed files
    include("models/Game.jl")
    include("models/Area.jl")
    include("models/Apple.jl")
    include("models/Snake.jl")
    include("utils/helpers.jl")
    include("controller.jl")

    # Create the models and load the game data.
    area = Area()
    apple = Apple(area)
    snake = Snake(area)
    resetSnake(snake, area)
    game = getData()

    # Define the game as a prop and send to the QML view
    props = JSON.json(Dict(
        "snake" => SnakeToJSON(snake),
        "apple" => AppleToJSON(apple),
        "game" => JSON.json(game)
    ))
    ```

4. **Connection Mechanisms**:

    - **Callable Functions**: Register functions that will be called from the QML file:
        ```julia
        # Registers functions that will be called from the QML view
        qmlfunction("moveApple", moveApple)
        qmlfunction("setSnake", setSnake)
        qmlfunction("setGameOver", setGameOver)
        qmlfunction("resetSnake", resetSnake)
        ```
      In the QML view:
        ```JS
        import org.julialang
        .
        .
        .
        Julia.moveApple()
        ```

    - **Property Mapping**: Pass arguments from Julia to the QML view:
        ```julia
        loadqml("src/view.qml", props=props, areaWidth=area.width, areaHeight=area.height, bestScore=game["bestScore"])
        ```

    - **Signals**: Synchronize the Julia code with the main view. Events are emitted from Julia and handled on the QML side. The typical cycle is:
        - At initialization, send initial parameters to the view using property mapping.
        - When updates occur in the view, call a Julia function by executing a registered function.
        - The registered function performs and emits an event with updates to the view through signals.

## The Game Process

The view is divided into three components: `gameStart`, `gamePlay`, and `gameOver`, each corresponding to a particular game state. The initial view is `gameStart`.

### Game Start

In the `gameStart` component, display the best score sent as input. This score may change during the game. After the round ends, display the updated best score if it has changed; otherwise, display the initial best score:
```JS
Component.onCompleted: {
    bestScoreElement.text = gameData["bestScore"] == undefined ? "BEST SCORE : " + bestScore : "BEST SCORE : " + gameData["bestScore"]
}
```
Listen for keyboard input and load the `gamePlay` component if the user presses the `Enter` or `Return` keys:
```JS
Keys.onPressed: (event) => {
    if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
        stackView.push(gamePlay)
    }
}
```

### Game Play

In the `gamePlay` component, use a `Timer` element to repeat the movement of the snake. Start the timer and generate the first position for the apple when the component loads:
```JS
Component.onCompleted: {
    appleRef = appleElement
    timerRef = timer
    timer.start()
    Julia.moveApple()
}
```
Update the snake and send the information back to Julia on each timer trigger. Check if the snake has eaten an apple. Implement the `snakeEat` function here for simplicity and efficiency:
```js
Timer {
    id: timer
    interval: 400 
    repeat: true
    onTriggered: {
        // Snake eats apple.
        if(snake["tailX"] != undefined){
            if(snake["tailX"][0] == apple["x"] && snake["tailY"][0] == apple["y"]){
                snake["tails"] = snake["tails"] + 1
                snake["tailX"].push(0);
                snake["tailY"].push(0);
                snake["snakeIMG"].push("");
                currentScore = currentScore + 1
                Julia.moveApple()
            }
        } 
        // Set the snake.
        Julia.setSnake(JSON.stringify(snake))
    }
}
```
The timer runs every 400ms (0.4s). The snake state is sent to Julia, updated, and sent back through a signal. The signal is handled in the view within the `JuliaSignals` block. When the snake dies, emit a `snakeDied` signal and move to the `gameOver` component:
```JS
signal snakeDied()
onSnakeDied: function(input) {
    timerRef.repeat = false
    Julia.resetSnake(JSON.stringify(snake))
    Julia.setGameOver(currentScore)
    stackView.push(gameOver)
}
```

### Game Over

The `gameOver` component displays the best score and the score of the current play.

