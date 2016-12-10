# game_id => {uids: [a,b], words_player0: {duree_que_ca_a_pris_a_trouver_et_a_ecrire: X, mot: Y}, words_player1: {}, next_player:int, last_letter:str, score_p0, score_p1 last_move_timestamp:int}
# score p (incrementent)

class ActionModels::Game
  def self.start(uuid1, uuid2)
    white, black = [uuid1, uuid2].shuffle

    puts "starting game with " + uuid1 + "and" + uuid2

    ActionCable.server.broadcast "player_#{white}", {action: "game_starts", msg: "white"}
    ActionCable.server.broadcast "player_#{black}", {action: "game_starts", msg: "black"}

    REDIS.set("opponent_for:#{white}", black)
    REDIS.set("opponent_for:#{black}", white)



    game_id = SecureRandom.uuid

    REDIS.rpush("game_#{game_id}_pids",white,black)

    # stocker par uid?
    REDIS.set("game_#{game_id}_p0_score","0")
    REDIS.set("game_#{game_id}_p1_score","0")

    REDIS.set("game_#{game_id}_next_px","0")
    REDIS.set("game_#{game_id}_last_letter",('a'..'z').to_a.sample)
    # REDIS.set("last_move_timestamp","0")

    # REDIS.rpush("game_#{game_id}_words_p0", ..)

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

  def self.play_word(pid, word)
    opponent = opponent_for(pid)

    pids = REDIS.lrange("game_#{game_id}_pids",0,-1)
    if (pids[0] == pid)
      px = "0"
    elsif (pids[1] == pid)
      px = "1"
    else
      raise new Error("Not in the game")
    end

    # @TODO VERIFY IF WORD IS VALID

    if (REDIS.get("game_#{game_id}_next_px") != px)
      raise new Error("Not your turn")
    end
    REDIS.set("game_#{game_id}_next_px", px == "0" ? "1" : "0")

    if (REDIS.get("game_#{game_id}_last_letter") != word[0])
      raise new Error("Not your turn")
    end
    REDIS.set("game_#{game_id}_last_letter", word[-1])


    REDIS.rpush("game_#{game_id}_p#{px}_words",word)

    old_score = REDIS.get("game_#{game_id}_p#{px}_score").to_i
    old_timestamp = REDIS.get("game_#{game_id}_last_move_timestamp").to_i
    points = word.length*3 + (Time.now.to_i - old_timestamp)
    REDIS.set("game_#{game_id}_p#{px}_score",old_score + points)

    if (points > 120)
      puts "The game is done"
    end

    REDIS.set("game_#{game_id}_last_move_timestamp", Time.now.to_i)

    ActionCable.server.broadcast "player_#{opponent}", {action: "opponent_plays", msg: word}
  end
end
