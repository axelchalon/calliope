class Game
  def self.start(uuid1, uuid2)
    white, black = [uuid1, uuid2].shuffle

    puts "starting game with " + uuid1 + "and" + uuid2

    ActionCable.server.broadcast "player_#{white}", {action: "game_starts", msg: "white"}
    ActionCable.server.broadcast "player_#{black}", {action: "game_starts", msg: "black"}

    REDIS.set("opponent_for:#{white}", black)
    REDIS.set("opponent_for:#{black}", white)
  end

  def self.forfeit(uuid)
    if winner = opponent_for(uuid)
      ActionCable.server.broadcast "player_#{winner}", {action: "opponent_forfeits"}
    end
  end

  def self.opponent_for(uuid)
    REDIS.get("opponent_for:#{uuid}")
  end

  # def self.make_move(uuid, data)
  #   opponent = opponent_for(uuid)
  #   move_string = "#{data["from"]}-#{data["to"]}"
  #
  #   ActionCable.server.broadcast "player_#{opponent}", {action: "make_move", msg: move_string}
  # end

  def self.play_word(uuid, word)
    opponent = opponent_for(uuid)

    # @TODO VERIFY IF WORD IS VALID

    ActionCable.server.broadcast "player_#{opponent}", {action: "opponent_plays", msg: word}
  end
end
