# game_id => {uids: [a,b], words_player0: {duree_que_ca_a_pris_a_trouver_et_a_ecrire: X, mot: Y}, words_player1: {}, next_player:int, last_letter:str, score_p0, score_p1 last_move_timestamp:int}
# score p (incrementent)

class ActionModels::Game
  def self.start(uuid1, uuid2)
    p0, p1 = [uuid1, uuid2].shuffle

    # legacy (for disconnect, etc)
    REDIS.set("opponent_for:#{p0}", p1)
    REDIS.set("opponent_for:#{p1}", p0)

    game_id = SecureRandom.uuid
    ActionCable.server.broadcast "player_#{p0}", {action: "game_starts", role: "p0", game_id: game_id}
    ActionCable.server.broadcast "player_#{p1}", {action: "game_starts", role: "p1", game_id: game_id}
    REDIS.rpush("game_#{game_id}_pids",p0)
    REDIS.rpush("game_#{game_id}_pids",p1)
    REDIS.set("game_for:#{p0}", game_id)
    REDIS.set("game_for:#{p1}", game_id)
    puts "starting game with " + p0.to_s + "and" + p1.to_s + "(gid " + game_id.to_s + ")"

    # stocker par uid?
    REDIS.set("game_#{game_id}_p0_score","0")
    REDIS.set("game_#{game_id}_p1_score","0")
    REDIS.set("game_#{game_id}_next_px","0")

    # REDIS.rpush("game_#{game_id}_words_p0", ..)

    update_last_move_timestamp(game_id)
    REDIS.set("game_#{game_id}_last_letter",('a'..'z').to_a.sample)
  end


  def self.forfeit(uuid)
    if winner = opponent_for(uuid)
      ActionCable.server.broadcast "player_#{winner}", {action: "opponent_forfeits"}
      # todo kill guest in table & libérer mémoire
    end
  end

  def self.play_word(pid, word)
    game_id = game_for(pid)
    opponent = opponent_for(pid)

    puts "self.play_worxd"
    puts "PID : #{pid.inspect}"
    puts "Word : #{word}"
    puts "Game_id : #{game_id}"

    pids = REDIS.lrange("game_#{game_id}_pids",0,-1) # Get all player ids
    puts "PIDS : #{pids.inspect}"
    if (pids[0].to_s == pid)
      px = "0"
    elsif (pids[1].to_s == pid)
      px = "1"
    else
      raise "Not in the game"
    end

    # @TODO VERIFY IF WORD IS VALID

    if (REDIS.get("game_#{game_id}_next_px") != px)
      raise "Not your turn"
    end
    REDIS.set("game_#{game_id}_next_px", px == "0" ? "1" : "0")

    if (REDIS.get("game_#{game_id}_last_letter") != word[0])
      raise "Wrong first letter"
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

    update_last_move_timestamp(game_id)

    ActionCable.server.broadcast "player_#{opponent}", {action: "opponent_plays", msg: word}
  end

  # UTL

  def self.turboforfait()
    REDIS.flushall();
  end

  def self.dumpx(game_id)
    wamzou = {
    pids: pids = REDIS.lrange("game_#{game_id}_pids",0,-1), # Get all player ids
    p0_score: p0_score = REDIS.get("game_#{game_id}_p0_score"),
    p1_score: p1_score = REDIS.get("game_#{game_id}_p1_score"),
    next_px: next_px = REDIS.get("game_#{game_id}_next_px"),
    last_letter:last_letter = REDIS.get("game_#{game_id}_last_letter"),
    last_move_timestamp: last_move_timestamp = REDIS.get("game_#{game_id}_last_move_timestamp"),
    p0_words: p0_words = REDIS.lrange("game_#{game_id}_p0_words",0,-1),
    p1_words: p1_words = REDIS.lrange("game_#{game_id}_p0_words",0,-1)
    }
    puts wamzou.inspect
  end

  # UTH

  def self.update_last_move_timestamp(game_id)
    REDIS.set("game_#{game_id}_last_move_timestamp", Time.now.to_i)
  end

  def self.opponent_for(uuid)
    REDIS.get("opponent_for:#{uuid}")
  end

  def self.game_for(uuid)
    REDIS.get("game_for:#{uuid}")
  end
end
