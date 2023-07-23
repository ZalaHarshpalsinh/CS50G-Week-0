Game_para = Class{}

function Game_para:init(gameState,game_mode,AI_reaction_range,player1Score,player2Score,winningPlayer,servingPlayer)
    self.gameState = gameState
    self.game_mode = game_mode
    self.AI_reaction_range = AI_reaction_range
    self.player1Score = player1Score
    self.player2Score = player2Score
    self.winningPlayer = winningPlayer
    self.servingPlayer = servingPlayer
end
