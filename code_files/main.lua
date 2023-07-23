push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'
require 'Game_para'

WINDOW_WIDTH = 1000
WINDOW_HEIGHT = 700

VIRTUAL_WIDTH = 400
VIRTUAL_HEIGHT = 200

PADDLE_SPEED = 200

function love.load()
    
    love.window.setTitle('Pong')
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest','nearest')

    fonts = {
        ['small_font'] = love.graphics.newFont('font.ttf',8),
        ['score_font'] = love.graphics.newFont('font.ttf',20),
        ['large_font'] = love.graphics.newFont('font.ttf',15)
    }

    sounds = {
        ['background_music'] = love.audio.newSource('/sounds/background.wav','static'),
        ['paddle_hit'] = love.audio.newSource('/sounds/paddle_hit.wav','static'),
        ['wall_hit'] = love.audio.newSource('/sounds/wall_hit.wav','static'),
        ['score'] = love.audio.newSource('/sounds/score.wav','static'),
    }

    sounds['background_music']:setLooping(true)
    sounds['background_music']:play()

    config = {fullscreen = false, resizable = true, vsync = true}
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,config)

    player1 = Paddle(10, 30, 5, 20,PADDLE_SPEED)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 30 - 20, 5, 20,PADDLE_SPEED)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
    game_para = Game_para('mode_select',0,0,0,0,0,1)
end

function love.resize(w,h)
    push:resize(w,h)
end

function love.keypressed(key)
    if key == 'escape' then
        if game_para.gameState == 'mode_select' then 
            love.event.quit()
        else
            game_para.gameState = 'mode_select'
            game_para.player1Score = 0
            game_para.player2Score = 0
            player1.height = 20
            game_para.AI_reaction_range = 0
            sounds['background_music']:play()
        end
    elseif key == 'return' then
        if game_para.gameState == 'serve' then
            sounds['background_music']:stop()
            game_para.gameState = 'play'
        elseif game_para.gameState == 'done' then
            game_para.gameState = 'serve'
        end
    end

    if game_para.gameState == 'mode_select' then
        if key == '1' then
            game_para.game_mode = 1
            game_para.gameState = 'serve'
        elseif key == '2' then
            game_para.game_mode = 2
            game_para.gameState = 'diff_select'
        elseif key == '3' then
            game_para.game_mode = 3
            game_para.gameState = 'serve'
        end 
    end

    if game_para.gameState == 'diff_select' then
        if key == 'e' then
            player1.height = 35
            game_para.AI_reaction_range = VIRTUAL_WIDTH/2 + 100
            game_para.gameState = 'serve'
        elseif key == 'h' then
            player1.height = 25
            game_para.AI_reaction_range = VIRTUAL_WIDTH/2 
            game_para.gameState = 'serve'
        elseif key == 'i' then
            game_para.AI_reaction_range  = 0
            game_para.gameState = 'serve'
        end 
    end
end

function love.update(dt)    
    if game_para.gameState == 'serve' then
        ball:reset()
        ball.dy = math.random(-50, 50)
        if game_para.servingPlayer == 1 then
            ball.dx = math.random(150,200)
        else
            ball.dx = -math.random(150, 200)
        end
    elseif game_para.gameState == 'play' then
        ball:update(dt)

        if game_para.game_mode == 1 or game_para.game_mode == 2 then
            if love.keyboard.isDown('w') then
                player1:update(dt,'UP')
            elseif love.keyboard.isDown('s') then
                player1:update(dt,'DOWN')
            end
        end


        if game_para.game_mode == 1 then
            if love.keyboard.isDown('up') then
                player2:update(dt,'UP')
            elseif love.keyboard.isDown('down') then
                player2:update(dt,'DOWN')
            end
        end

        if game_para.game_mode == 2 or game_para.game_mode == 3 then
            if ball.x >= game_para.AI_reaction_range then
                if ((ball.y+ball.height) < player2.y) then
                    player2:update(dt,'UP')
                elseif (player2.y+player2.height) < ball.y then
                    player2:update(dt,'DOWN')
                end
            end
        end

        if game_para.game_mode == 3 then
            if (ball.y+ball.height) < player1.y then
                player1:update(dt,'UP')
            elseif (player1.y+player1.height) < ball.y then
                player1:update(dt,'DOWN')
            end
        end


        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
            sounds['paddle_hit']:play()
        elseif ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
            sounds['paddle_hit']:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        elseif ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.x < 0 then
            game_para.servingPlayer = 1
            game_para.player2Score = game_para.player2Score + 1
            sounds['score']:play()
            if game_para.player2Score == 10 then
                game_para.gameState = 'done'
                game_para.winningPlayer = 2
                game_para.servingPlayer = 1
            else
                game_para.gameState = 'serve'
            end
        elseif ball.x > VIRTUAL_WIDTH then
            game_para.servingPlayer = 2
            game_para.player1Score = game_para.player1Score + 1
            sounds['score']:play()
            if game_para.player1Score == 10 then
                game_para.winningPlayer = 1
                game_para.servingPlayer = 2
                game_para.gameState = 'done'
    
            else
                game_para.gameState = 'serve'
            end
        end
    elseif game_para.gameState == 'done' then
        game_para.player1Score = 0
        game_para.player2Score = 0
        sounds['background_music']:play()
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(38/255, 38/255, 37/255,255/255)

    if game_para.gameState == 'mode_select' or game_para.gameState == 'diff_select' then
        love.graphics.setFont(fonts['large_font'])
        love.graphics.printf('Welcome to pong!',0,15,VIRTUAL_WIDTH,'center')
    end

    if game_para.gameState == 'mode_select' then
        show_main_menu()
    elseif game_para.gameState == 'diff_select' then
        show_sub_menu()
    elseif game_para.gameState == 'play' then
        love.graphics.rectangle('fill', VIRTUAL_WIDTH/2 - 1, 0, 2, VIRTUAL_HEIGHT)
    elseif game_para.gameState == 'serve' then
        love.graphics.printf('Player ' .. tostring(game_para.servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve', 0, 25, VIRTUAL_WIDTH, 'center')
    elseif game_para.gameState == 'done' then
        love.graphics.printf('Player ' .. tostring(game_para.winningPlayer) .. ' wins!',0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end
    
    if game_para.gameState ~= 'mode_select' and game_para.gameState ~= 'diff_select' then
        player1:render()
        player2:render()
        ball:render()
        displayScore()
    end
    
    displayFPS()

    push:apply('end')
end

function show_main_menu()
    love.graphics.setFont(fonts['small_font'])
    love.graphics.printf('Choose the game mode-', 50, 55, VIRTUAL_WIDTH, 'left')
    love.graphics.printf('( 1 ) --> Player Vs. Player (2-player)', 50, 65, VIRTUAL_WIDTH, 'left')
    love.graphics.printf('( 2 ) --> Player Vs. Computer (single-player)', 50, 75, VIRTUAL_WIDTH, 'left')
    love.graphics.printf('( 3 ) --> Computer Vs. Computer (spectating)', 50, 85, VIRTUAL_WIDTH, 'left')
    love.graphics.printf('How to play-', 50, 105, VIRTUAL_WIDTH, 'left')
    love.graphics.printf('--->First player to score 10 points win', 50, 115, VIRTUAL_WIDTH, 'left')
    love.graphics.printf('--->Player1 (Left side) controls = W - s', 50, 125, VIRTUAL_WIDTH, 'left')
    love.graphics.printf('--->Player2 (Right side) controls = UP arrow - DOWN arrow', 50, 135, VIRTUAL_WIDTH, 'left')
    love.graphics.printf('-By Zala Harshpalsinh', 50, 155, VIRTUAL_WIDTH, 'center')
end

function show_sub_menu()
    love.graphics.setFont(fonts['small_font'])
    love.graphics.printf('Select the difficulty',50,35,VIRTUAL_WIDTH,'left')
    love.graphics.printf('( E ) --> Easy',50,45,VIRTUAL_WIDTH,'left')
    love.graphics.printf('( H ) --> Hard',50,55,VIRTUAL_WIDTH,'left')
    love.graphics.printf('( I ) --> Impossible',50,65,VIRTUAL_WIDTH,'left')
end

function displayFPS()
    love.graphics.setFont(fonts['small_font'])
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
    love.graphics.setFont(fonts['score_font'])
    love.graphics.print(tostring(game_para.player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(game_para.player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end
