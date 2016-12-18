require 'rails_helper'

RSpec.describe Game, type: :model do
  it "belongs to a player 1" do
    player1 = Player.create
    game = Game.create

    game.player1 = player1

    expect(game.player1).to eq(player1)
  end
end
