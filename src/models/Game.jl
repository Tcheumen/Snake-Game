mutable struct Score 
    player::String 
    value::Int
end 

mutable struct Game
    bestScore::Int 
    scores::Array{Score}
end 

function ScoreToJSON(score::Score)
    return JSON.json(Dict(
        "player" => score.player,
        "value" => score.value,
    ))  
end 


function ScoreToDict(score::Score) 
    return Dict(
        "player" => score.player,
        "value" => score.value,
    )
end 

function GameToJSON(game::Game)
    return JSON.json(Dict(
        "bestScore" => game.bestScore,
        "scores" => JSON.json([ScoreToJSON(x) for x in game.scores]),
    ))
end 
