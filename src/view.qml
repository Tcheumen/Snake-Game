import QtQuick
import QtQuick.Controls
import org.julialang

ApplicationWindow {
    visible: true
    width: 900
    height: 600
    title: "Snake Game"

    property var appleRef
    property var timerRef
    property var bricksRepeaterRef
    property var level : 0
    property var speed : 400
    property var levelScores: JSON.parse(JSON.parse(props)["levelScores"])
    property var snakeWalk: false 
    property var timerStarted : false

    property var snake : JSON.parse(props)["snake"]
    property var apple : JSON.parse(props)["apple"]
    property var bricks : []
    property var currentScore : 0
    property var gameData : JSON.parse(props)["game"]
    
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: gameStart
        focus: true
    }

    Component {
        id: gameStart
        Rectangle {
            width: parent.width
            height: parent.height
            color: "#f0f0f0"

            Image {
                source: "../resources/images/bg-game.png"
                anchors.fill: parent
                fillMode: Image.Stretch
                z: 0
            }

            Image {
                source: "../resources/images/game-title.png"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -50
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenterOffset: 80
                text: "PRESS ENTER BUTTON ON KEYBOARD TO START GAME"
                color: "black"
                font.pixelSize: 20
                z: 1
            }

            Text {
                id: bestScoreElement
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenterOffset: 110
                color: "black"
                text: ""
                font.pixelSize: 15
                z: 1
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenterOffset: 150
                text: "CHOOSE THE LEVEL"
                color: "black"
                font.pixelSize: 15
                z: 1
            }


            Image {
                source: "../resources/images/whole-snake.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenterOffset: 175 + level*20
                anchors.horizontalCenterOffset: -50
                height: 10
                width: 30
            }

            Text {
                id: levelEasyElement
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenterOffset: 175
                color: level == 0 ? "green" : "black";
                text: "EASY"
                font.pixelSize: 15
                z: 1
            }
            Text {
                id: levelMediumElement
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenterOffset: 195
                color: level == 1 ? "green" : "black";
                text: "MEDIUM"
                font.pixelSize: 15
                z: 1
            }

            Text {
                id: levelHardElement
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenterOffset: 215
                color: level == 2 ? "green" : "black";
                text: "HARD"
                font.pixelSize: 15
                z: 1
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 50
                text: "Copyrights 2024, All rights reserved."
                color: "black"
                font.pixelSize: 20
                z: 1
            }

            Keys.onPressed: (event) => {
                if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {

                    // looks from bricks
                    if(level != 2){
                        bricks = [];
                    }
                
                    // Ajust spped
                    if(level > 0)
                      speed = 200
                    else 
                      speed = 400

                    // Initialisation
                    currentScore = 0;
                    snakeWalk = true;
                    stackView.push(gamePlay);
                }

                if(event.key == Qt.Key_Up){
                    if(level > 0){
                        level = level - 1
                    }
                }

                if(event.key == Qt.Key_Down){
                    if(level < 2){
                        level = level + 1
                    }
                }
            }

            Component.onCompleted : {
                bestScoreElement.text = gameData["bestScore"] == undefined ? "BEST SCORE : " + bestScore : "BEST SCORE : " + gameData["bestScore"]
            }
        }
    }

    Component {
        id: gameCongratulations
        Rectangle {
            width: parent.width
            height: parent.height
            color: "#f0f0f0"
            focus: true

              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top 
                anchors.topMargin:10
                text: "SCORE : " + currentScore + "/" + levelScores[level]
                color: "black"
                font.pixelSize: 30
                z: 1
            }

            Image {
                source: "../resources/images/bg-game.png"
                anchors.fill: parent
                fillMode: Image.Stretch
                z: 0
            }

            Image {
                source: "../resources/images/sand.jpg"
                anchors.centerIn: parent
                width: areaWidth
                height: areaHeight
                z: 1
            }

            Text {
                anchors.centerIn: parent
                text: "CONGRATULATIONS."
                color: "black"
                font.pixelSize: 25
                z: 1
            }
            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 30
                text: "You have reach the highest score of this level."
                color: "black"
                font.pixelSize: 20
                z: 1
                visible: level != 2
            }
            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 60
                text: "Press [Enter] to continue to the next Level or [Space] to return to the start Page"
                color: "black"
                font.pixelSize: 20
                z: 1
                visible: level != 2
            }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 30
                text: "You have finished the game."
                color: "black"
                font.pixelSize: 20
                z: 1
                visible: level == 2
            }
            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 60
                text: "Press [Space] to return to the start Page."
                color: "black"
                font.pixelSize: 20
                z: 1
                visible: level == 2
            }


            Keys.onPressed: (event) => {
                if(level < 2){
                    if(event.key == Qt.Key_Return || event.key == Qt.Key_Enter){
                        level = level + 1
                        snakeWalk = true;
                        // Ajust spped
                        if(level > 0)
                            speed = 200
                        else 
                            speed = 400

                        // looks from bricks
                        if(level != 2){
                            bricks = [];
                        }else{
                            // moveBricks otherwise
                            Julia.moveBricks()
                        }
                        stackView.push(gamePlay)
                    }
                }
                  

                    if(event.key == Qt.Key_Space){
                        Julia.setGameOver(currentScore)
                        stackView.push(gameStart)
                    }
            }
        }
    }

    Component {
        id: gamePlay
        Rectangle {
            width: parent.width
            height: parent.height
            color: "#f0f0f0"
            focus: true

            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top 
                anchors.topMargin:10
                text: "SCORE : " + currentScore + "/" + levelScores[level]
                color: "black"
                font.pixelSize: 30
                z: 1
            }

            Image {
                source: "../resources/images/bg-game.png"
                anchors.fill: parent
                fillMode: Image.Stretch
                z: 0
            }

            Image {
                source: "../resources/images/sand.jpg"
                anchors.centerIn: parent
                width: areaWidth
                height: areaHeight
                z: 1
            }

            Image {
                id: appleElement
                source: "../resources/images/apple.png"
                x: 0
                y: 0
                width: apple["scale"]
                height: apple["scale"]
                z: 1
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 50
                text: "Copyrights 2024, All rights reserved."
                color: "black"
                font.pixelSize: 20
                z: 1
            }

            Text {
                anchors.centerIn:parent
                text: "PAUSE"
                font.pixelSize: 30
                z: 2
                visible: !snakeWalk
            }

            Repeater {
                model: bricks.length;
                id: bricksRepeater
                Image {
                    source: "../resources/images/brick.png"
                    x: bricks[index]["x"]
                    y: bricks[index]["y"]
                    width: bricks[index]["scale"]
                    height: bricks[index]["scale"]
                    z: 1
                }
            }

            Repeater {
                model: snake["tails"]
                Image {
                    source: "../resources/images/"+(snake["snakeIMG"][index])
                    x: snake["tailX"][index]
                    y: snake["tailY"][index]
                    width: snake["scale"]
                    height: snake["scale"]
                    z: 1
                }
            }

            Timer {
                id: timer
                interval: speed
                repeat: true
                onTriggered: {
                    if(snakeWalk){
                        if(snake["tailX"] != undefined  ){
                            // Snake Eat apple.
                            if(snake["tailX"][0] == apple["x"] && snake["tailY"][0] == apple["y"]){
                                snake["tails"] = snake["tails"] + 1
                                snake["tailX"].push(0);
                                snake["tailY"].push(0);
                                snake["snakeIMG"].push("");
                                currentScore = currentScore + 1

                                // check to show congralutations
                                if(currentScore >= levelScores[level]){
                                    snakeWalk = false
                                    Julia.resetSnake(JSON.stringify(snake))
                                    stackView.push(gameCongratulations)
                                }
                                Julia.moveApple()
                            }
                            // Snake Hit a brick
                            for(var i =0; i<bricks.length; i++){
                                if(snake["tailX"][0] == bricks[i]["x"] && snake["tailY"][0] == bricks[i]["y"]){
                                    snakeWalk = false
                                    Julia.resetSnake(JSON.stringify(snake))
                                    Julia.setGameOver(currentScore)
                                    Julia.moveApple()
                                    stackView.push(gameOver)
                                }
                            }
                        } 
                        // Set the snake.
                        Julia.setSnake(JSON.stringify(snake))
                    }                   
                }
            }

            Keys.onPressed: (event) => {

                if(snakeWalk){
                    if(event.key == Qt.Key_Right){
                        snake["direction"] = 1
                    }

                    if(event.key == Qt.Key_Up){
                        snake["direction"] = 2
                    }
                    
                    if(event.key == Qt.Key_Left){
                        snake["direction"] = 3
                    }

                    if(event.key == Qt.Key_Down){
                        snake["direction"] = 4
                    }
                }
                
                if(event.key == Qt.Key_Space){
                    snakeWalk = !snakeWalk
                }
            }

            Component.onCompleted: {
                appleRef = appleElement
                bricksRepeaterRef = bricksRepeater

                if(!timerStarted){
                    timer.start()
                    timerStarted = true
                }

                Julia.moveApple()
                if(level == 2) {
                    Julia.moveBricks()
                }               
            }          
        }
    }

    Component {
        id: gameOver
        Rectangle {
            width: parent.width
            height: parent.height
            color: "#f0f0f0"
            focus: true

           Image {
                source: "../resources/images/bg-game.png"
                anchors.fill: parent
                fillMode: Image.Stretch
                z: 0
            }

            Image {
                source: "../resources/images/game-title.png"
                anchors.centerIn: parent
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenterOffset: 100
                text: "GAME OVER"
                color: "black"
                font.pixelSize: 30
                z: 1
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenterOffset: 130
                text: "PRESS SPACE TO REPLAY OR ENTER TO RETURN TO THE START PAGE"
                color: "black"
                font.pixelSize: 20
                z: 1
            }

            Text {
                id: bestScoreElement
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenterOffset: 170
                color: "black"
                text: ""
                font.pixelSize: 20
                z: 1
            }

           Text {
                id: playerScoreElement
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenterOffset: 200
                color: "black"
                text: ""
                font.pixelSize: 20
                z: 1
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 50
                text: "Copyrights 2024, All rights reserved."
                color: "black"
                font.pixelSize: 20
                z: 1
            }
           
            Keys.onPressed: (event) => {
                // Press Enter.
                if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
                    stackView.push(gameStart)
                }

                if(event.key == Qt.Key_Space){
                    stackView.push(gamePlay)
                }
            }

            Component.onCompleted: {
                bestScoreElement.text = "BEST SCORE : " + gameData["bestScore"]
                playerScoreElement.text = gameData["player"] + " : "+gameData["score"]
            }  
        }
    }
    
    JuliaSignals {
        signal appleChanged(var input)
        onAppleChanged: function(input) {
            apple = JSON.parse(input)
            appleRef.x = apple["x"]
            appleRef.y = apple["y"]
        }
        signal snakeChanged(var input)
        onSnakeChanged: function(input) {
            var data = JSON.parse(input)
            for(var i=0; i < data["snakeIMG"].length; i++){
                data["snakeIMG"][i] = data["snakeIMG"][i].replace(/[\\'"]/g, '');
            }
            snake = data
        }

        signal snakeDied()
        onSnakeDied: function(input) {
            snakeWalk = false;
            Julia.resetSnake(JSON.stringify(snake))
            Julia.setGameOver(currentScore)
            Julia.moveApple()
            stackView.push(gameOver)
            // Reset the score.
            currentScore = 0;
            // Reset content.
            // bricks = [];
        }

        signal gameOver(var input)
        onGameOver: function(input) {
            gameData = JSON.parse(input)
        }

        signal bricksChanged(var input)
        onBricksChanged: function(input) {
            var items = JSON.parse(input)
            for(var i=0; i < items.length; i++){
                items[i] = JSON.parse(items[i])
            }
            bricks = items;
        }
    }

    
}
