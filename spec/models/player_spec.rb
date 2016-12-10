require 'rails_helper'

RSpec.describe Player, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  it "a player has games" do
    player = Player.create!({username: "test_user", password: "aaaaaaaa"})
    game = Game.create!({player1: player, player2: player})

    expect(player.games).to eq([game])
  end

end
