require 'rails_helper'
require 'redis_spec_helper'

RSpec.describe ActionModels::Game do

  pending "test ai and guest cases"

  it "creates a game without fuss" do
    player1 = Player.create!(username: "testUser1", password:"aaaaaa")
    player2 = Player.create!(username: "testUser2", password:"aaaaaa")

    ActionModels::Game.start(player1.id, player2.id)

    game_for_player1 = REDIS.get("game_for:#{player1.id}")
    game_for_player2 = REDIS.get("game_for:#{player2.id}")

    expect(game_for_player1).to_not be_nil
    expect(game_for_player2).to_not be_nil
  end

  it "stores a game correctly" do

    player1 = Player.create!(username: "testUser1", password:"aaaaaa")
    player2 = Player.create!(username: "testUser2", password:"aaaaaa")

    ActionModels::Game.start(player1.id, player2.id)

    game_for_player1 = REDIS.get("game_for:#{player1.id}")
    game_for_player2 = REDIS.get("game_for:#{player2.id}")

    pids = REDIS.lrange("game_#{game_for_player1}_pids",0,-1) # Get all player ids
    puts "PIDS : #{pids.inspect}"
    if (pids[0] == player1.id)
      player1_px = "0"
    elsif (pids[1] == player1.id)
      player1_px = "1"
    end

    ActionModels::Game.listenToHim(game_for_player1, player1.id, player2.id, player1_px)

    game = ::Game.last

    expect(game).not_to be_nil
    expect(game.player1_id).to equal(player1.id)
    expect(game.player1_score).to equal(0)
    expect(game.player2_id).to equal(player2.id)
    expect(game.player2_score).to equal(0)
  end

  it "stores words" do
    player1 = Player.create!(username: "testUser1", password:"aaaaaa")
    player2 = Player.create!(username: "testUser2", password:"aaaaaa")

    ActionModels::Game.start(player1.id, player2.id)

    game_id = REDIS.get("game_for:#{player1.id}")

    pids = REDIS.lrange("game_#{game_id}_pids",0,-1) # Get all player ids
    if (pids[0] == player1.id)
      player1_px = "0"
    elsif (pids[1] == player1.id)
      player1_px = "1"
    end

    words = [
      "yolo",
      "orangoutan",
      "niktamere",
      "euhnonmerci",
      "iranien",
      "nounours",
      "saperlipopette"
    ]



    REDIS.rpush("game_#{game_id}_p0_words",words[0])
    REDIS.rpush("game_#{game_id}_p1_words",words[1])
    REDIS.rpush("game_#{game_id}_p0_words",words[2])
    REDIS.rpush("game_#{game_id}_p1_words",words[3])
    REDIS.rpush("game_#{game_id}_p0_words",words[4])



    ActionModels::Game.listenToHim(game_id, player1.id, player2.id, player1_px)

    game = ::Game.last
    expect(game).not_to be_nil

  end

end
