# game_id => {uids: [a,b], words_player0: {duree_que_ca_a_pris_a_trouver_et_a_ecrire: X, mot: Y}, words_player1: {}, next_player:int, last_letter:str, score_p0, score_p1 last_move_timestamp:int}
# score p (incrementent)

class ActionModels::Game
  def self.start(uuid1, uuid2)
    p0, p1 = [uuid1, uuid2].shuffle

    # legacy (for disconnect, etc)
    REDIS.set("opponent_for:#{p0}", p1)
    REDIS.set("opponent_for:#{p1}", p0)

    game_id = SecureRandom.uuid
    REDIS.rpush("game_#{game_id}_pids",p0)
    REDIS.rpush("game_#{game_id}_pids",p1)
    REDIS.set("game_for:#{p0}", game_id)
    REDIS.set("game_for:#{p1}", game_id)
    puts "starting game with " + p0.to_s + "and" + p1.to_s + "(gid " + game_id.to_s + ")"

    # stocker par uid?
    REDIS.set("game_#{game_id}_p0_score","0")
    REDIS.set("game_#{game_id}_p1_score","0")
    REDIS.set("game_#{game_id}_next_px","0")

    update_last_move_timestamp(game_id)

    first_letter = ('a'..'z').to_a.sample
    REDIS.set("game_#{game_id}_last_letter",first_letter)

    ActionCable.server.broadcast "player_#{p0}", {action: "game_starts", role: "p0", opponent_name: Player.find_by(id: p1.to_i).username, first_letter: first_letter}
    ActionCable.server.broadcast "player_#{p1}", {action: "game_starts", role: "p1", opponent_name: Player.find_by(id: p0.to_i).username, first_letter: first_letter}

    p0_is_ai = Player.find_by(id: p0).username.starts_with?("Computer") #TODO check if .ai
    p1_is_ai = Player.find_by(id: p1).username.starts_with?("Computer") #TODO check if .ai
    ai_play(p0, first_letter) if p0_is_ai
    ai_play(p1, first_letter) if p1_is_ai
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
    opponent_is_ai = Player.find_by(id: opponent).username.starts_with?("Computer") #TODO check if .ai
    pid = pid.to_s

    # Check if user is in the game
    pids = REDIS.lrange("game_#{game_id}_pids",0,-1) # Get all player ids
    puts "PIDS : #{pids.inspect}"
    if (pids[0] == pid)
      px = "0"
    elsif (pids[1] == pid)
      px = "1"
    else
      ActionCable.server.broadcast "player_#{pid}", {action: "error", msg: "Not in the game", short: "notInGame"}
      return
    end

    # Check ob er dran ist
    if (REDIS.get("game_#{game_id}_next_px") != px)
      ActionCable.server.broadcast "player_#{pid}", {action: "error", msg: "Not your turn", short: "notYourTurn"}
      return
    end

    # Check if word is valid
    if (!ShiritoriService.instance.is_this_word_french?(word))
      ActionCable.server.broadcast "player_#{pid}", {action: "error", msg: "Invalid word.", short: "invalidWord"}
      return
    end

    # Check if word has already been played
    p0_words = REDIS.lrange("game_#{game_id}_p0_words",0,-1)
    p1_words = REDIS.lrange("game_#{game_id}_p1_words",0,-1)
    if (p0_words.include?(word) || p1_words.include?(word))
      ActionCable.server.broadcast "player_#{pid}", {action: "error", msg: "Word has already been played.", short: "alreadyUsed"}
      if opponent_is_ai
        puts "Opponent who failed is AI; playing."
        ai_play(opponent,REDIS.get("game_#{game_id}_last_letter"))
      end
      return
    end

    # Check last letter
    if (REDIS.get("game_#{game_id}_last_letter") != word[0])
      ActionCable.server.broadcast "player_#{pid}", {action: "error", msg: "Wrong first letter", short: "wrongFirstLetter"}
      return
    end

    # OK. Commit the move.
    REDIS.set("game_#{game_id}_next_px", px == "0" ? "1" : "0")
    REDIS.set("game_#{game_id}_last_letter", word[-1])
    REDIS.rpush("game_#{game_id}_p#{px}_words",word)
    update_last_move_timestamp(game_id)

    old_score = REDIS.get("game_#{game_id}_p#{px}_score").to_i
    old_timestamp = REDIS.get("game_#{game_id}_last_move_timestamp").to_i
    plus_points = word.length*3 + (Time.now.to_i - old_timestamp)
    new_points = old_score + plus_points
    REDIS.set("game_#{game_id}_p#{px}_score",new_points)

    ActionCable.server.broadcast "player_#{opponent}", {action: "opponent_played", msg: word, points: new_points}
    ActionCable.server.broadcast "player_#{pid}", {action: "word_accepted", points: new_points, msg: word}

    if (new_points > 120)
      ActionCable.server.broadcast "player_#{pid}", {action: "you_won"}
      ActionCable.server.broadcast "player_#{opponent}", {action: "you_lost"}
      puts "The music is over."
      # @TODO kill game, erase from redis, commit to database analytics
      return
    end

    if opponent_is_ai
      puts "Opponent is AI; playing."
      ai_play(opponent,word[-1])
    end
  end

  def self.ai_play(pid,last_letter)
    puts "AI " + pid.to_s + " serching for word starting with " + last_letter
    ai_word = ShiritoriService.instance.random_word_starting_with(last_letter)
    puts "AI found " + ai_word
    # Thread.new do
      # WARNING: Errors inside this thread do not appear in the console
      # sleep rand(2..6)
      self.play_word(pid,ai_word)
    # end
  end

  def self.notify_seek(pid)
    ActionCable.server.broadcast "player_#{pid}", {action: "seeking_opponent", pid: pid}
  end

  # UTL

  def self.turboforfait()
    REDIS.flushall()
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
    p1_words: p1_words = REDIS.lrange("game_#{game_id}_p1_words",0,-1)
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
