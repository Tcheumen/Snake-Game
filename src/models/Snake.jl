const LOCAL_PATH = "../resources/"
#

const SNAKE_IMAGES = Dict(
    "HEAD_UP" => "head_up.png",
    "HEAD_DOWN" => "head_down.png",
    "HEAD_LEFT" => "head_left.png",
    "HEAD_RIGHT" => "head_right.png",
    "BODY_LEFT_RIGHT" => "body_left_right.png",
    "BODY_UP_DOWN" => "body_up_down.png",
    "CORNER_LEFT_UP" => "corner_left_up.png",
    "CORNER_LEFT_DOWN" => "corner_left_down.png",
    "CORNER_RIGHT_UP" => "corner_right_up.png",
    "CORNER_RIGHT_DOWN" => "corner_right_down.png",
    "END_UP" => "end_up.png",
    "END_DOWN" => "end_down.png",
    "END_LEFT" => "end_left.png",
    "END_RIGHT" => "end_right.png"
)

mutable struct Snake 
    tailX::Array{Int}
    tailY::Array{Int}
    snakeIMG::Array{String}
    scale::Int 
    tails::Int 
    direction::Int # RIGHT=1 UP=2 LEFT=3 DOWN=4
    serial::String
    Snake() = new()
end

function Snake(area::Area) 
    snake = Snake()
    snake.scale = area.unitSize  
    return snake
end 

function SnakeToDict(snake::Snake)
    return Dict(
        "tailX" => snake.tailX,
        "tailY" => snake.tailY,
        "snakeIMG" => snake.snakeIMG,
        "scale"=>  snake.scale,
        "tails" =>  snake.tails,
        "direction"=> snake.direction,
    )
end 


function SnakeToJSON(snake::Snake)
    return JSON.json(Dict(
        "tailX" => snake.tailX,
        "tailY" => snake.tailY,
        "snakeIMG" => snake.snakeIMG,
        "scale"=>  snake.scale,
        "tails" =>  snake.tails,
        "direction"=> snake.direction,
        "serial" => snake.serial,
    ))
end 

function DictToSnake(dict::Dict)
    snake = Snake() 
    snake.tailX = dict["tailX"]
    snake.tailY = dict["tailY"]
    snake.snakeIMG = dict["snakeIMG"]
    snake.scale = dict["scale"]
    snake.tails = dict["tails"]
    snake.direction = dict["direction"]
    return snake
end 

function serializeSnake(snake::Snake)
    # Convert the Snake object to a dictionary and serialize it as a string
    # Wrap the serialized string with angle brackets
    snake.serial = string("<", serialize(SnakeToDict(snake)),"<")
end 

function deserializeSnake(snakeJSONString::String)
    # Split the string by angle brackets
    # Extract the part inside the brackets and deserialize it to a Snake object
    parts = split(snakeJSONString,"<")
    snake = DictToSnake(deserialize(string(parts[length(parts)-1])))
    return snake;
end

function deserializeSnake(snakeJSONString::Dict{String,Any})
    # Convert the dictionary back to a Snake object
    snake = DictToSnake(snakeJSONString)
    return snake;
end 

function resetSnake(snake::Snake, area::Area)
    snake.tails = 5;
    snake.direction = 1
    snake.tailX = [area.width/2 + snake.scale*(snake.tails - i) for i in 1:snake.tails ]
    snake.tailY = [area.height/2 for _ in 1:snake.tails]
    snake.snakeIMG = ["" for _ in 1:snake.tails]

    for i in 1:snake.tails 
        if i == 1 
            snake.snakeIMG[i] = SNAKE_IMAGES["HEAD_RIGHT"]
        elseif i == snake.tails
            snake.snakeIMG[i] = SNAKE_IMAGES["END_RIGHT"]
        else 
            snake.snakeIMG[i] = SNAKE_IMAGES["BODY_LEFT_RIGHT"]
        end 
    end

    serializeSnake(snake)
    return snake;
end

function getSnakeX(snake::Snake)
    return snake.tailX[1]
end 

function getSnakeY(snake::Snake)
    return snake.tailY[1]
end

function snakeEat(snake::Snake, apple::Apple) 
    if snake.tailX[1] == apple.x && snake.tailY[1] == apple.y 
        snake.tails += 1 
        return true 
    else 
        return false
    end 
end 

function snakeDeath(snake::Snake,area::Area)
    for i in 2:snake.tails
        if snake.tailX[1] == snake.tailX[i] && snake.tailY[1] == snake.tailY[i]
            return true 
        end 
    end 

    if snake.tailX[1] <= area.margin || snake.tailX[1] > area.width || 
       snake.tailY[1] <= area.margin || snake.tailY[1] > area.height
        return true 
    end

    return false
end

function updateSnake(snake::Snake)

    if(snake.tails > length(snake.tailX))
        snake.tailX = [x <= length(snake.tailX) ? snake.tailX[x] : 0 for x in 1:snake.tails ]
        snake.tailY = [x <= length(snake.tailY) ? snake.tailY[x] : 0 for x in 1:snake.tails ]
    end

    for i in 0:(snake.tails-2)
        snake.tailX[snake.tails-i] = snake.tailX[snake.tails-i-1]
        snake.tailY[snake.tails-i] = snake.tailY[snake.tails-i-1]
    end
   
    if snake.direction == 2
        snake.tailY[1] -= snake.scale
        snake.snakeIMG[1] = SNAKE_IMAGES["HEAD_UP"]
    elseif snake.direction == 4
        snake.tailY[1] += snake.scale
        snake.snakeIMG[1] = SNAKE_IMAGES["HEAD_DOWN"]
    elseif snake.direction == 3
        snake.tailX[1] -= snake.scale
        snake.snakeIMG[1] = SNAKE_IMAGES["HEAD_LEFT"]
    elseif snake.direction == 1
        snake.tailX[1] += snake.scale
        snake.snakeIMG[1] = SNAKE_IMAGES["HEAD_RIGHT"]
    end

    for i in 2:snake.tails 
        if i < snake.tails
            if snake.tailX[i-1] != snake.tailX[i+1] && snake.tailY[i-1] != snake.tailY[i+1]

                if snake.tailX[i-1] > snake.tailX[i+1] && snake.tailY[i-1] < snake.tailY[i+1]
                    if snake.tailX[i] == snake.tailX[i-1]
                        snake.snakeIMG[i] = SNAKE_IMAGES["CORNER_RIGHT_UP"]
                    else 
                        snake.snakeIMG[i] = SNAKE_IMAGES["CORNER_LEFT_DOWN"]
                    end 
                end

                if snake.tailX[i-1] < snake.tailX[i+1] && snake.tailY[i-1] > snake.tailY[i+1]
                    if snake.tailX[i] == snake.tailX[i-1]
                        snake.snakeIMG[i] = SNAKE_IMAGES["CORNER_LEFT_DOWN"]
                    else 
                        snake.snakeIMG[i] = SNAKE_IMAGES["CORNER_RIGHT_UP"]
                    end
                end 

                if snake.tailX[i-1] < snake.tailX[i+1] && snake.tailY[i-1] < snake.tailY[i+1]
                    if snake.tailX[i] == snake.tailX[i-1]
                        snake.snakeIMG[i] = SNAKE_IMAGES["CORNER_LEFT_UP"]
                    else 
                        snake.snakeIMG[i] = SNAKE_IMAGES["CORNER_RIGHT_DOWN"]
                    end
                end 

                if snake.tailX[i-1] > snake.tailX[i+1] && snake.tailY[i-1] > snake.tailY[i+1]
                    if snake.tailX[i] == snake.tailX[i-1]
                        snake.snakeIMG[i] = SNAKE_IMAGES["CORNER_RIGHT_DOWN"]
                    else 
                        snake.snakeIMG[i] = SNAKE_IMAGES["CORNER_LEFT_UP"]
                    end
                end
                       
            else 
                if snake.tailX[i-1] == snake.tailX[i] && snake.tailY[i-1] != snake.tailY[i]
                    snake.snakeIMG[i] = SNAKE_IMAGES["BODY_UP_DOWN"]
                elseif snake.tailX[i-1] != snake.tailX[i] && snake.tailY[i-1] == snake.tailY[i]
                    snake.snakeIMG[i] = SNAKE_IMAGES["BODY_LEFT_RIGHT"]
                end 
            end 
        end

        if i == snake.tails
            if snake.tailX[i-1] < snake.tailX[i] && snake.tailY[i-1] == snake.tailY[i]
                snake.snakeIMG[i] = SNAKE_IMAGES["END_LEFT"]
            elseif snake.tailX[i-1] > snake.tailX[i] && snake.tailY[i-1] == snake.tailY[i]
                snake.snakeIMG[i] = SNAKE_IMAGES["END_RIGHT"]
            elseif snake.tailX[i-1] == snake.tailX[i] && snake.tailY[i-1] < snake.tailY[i]
                snake.snakeIMG[i] = SNAKE_IMAGES["END_UP"]
            elseif snake.tailX[i-1] == snake.tailX[i] && snake.tailY[i-1] > snake.tailY[i]
                snake.snakeIMG[i] = SNAKE_IMAGES["END_DOWN"]
            end
        end 
    end 

    serializeSnake(snake)
    return snake;
end 

function moveSnake(snake::Snake, x::Int, y::Int)
    snake.tailX[1] = x 
    snake.tailY[1] = y
end
