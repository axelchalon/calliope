class ActionModels::ArrangedSeek
  def self.create(uuid)
    REDIS.sadd("opponent_for_arranged_" + uuid.to_s,0)
    ActionModels::Game.notify_seek(uuid)
  end

  def self.join(uuid, opponent)
    if REDIS.exists("opponent_for_arranged_" + opponent.to_s)
      puts "ARRANGED SEEK WII"
      REDIS.del("opponent_for_arranged_" + opponent.to_s)
      ActionModels::Game.start(uuid, opponent)
    end
  end

  def self.remove(uuid)
    REDIS.del("opponent_for_arranged_" + uuid.to_s)
  end

  def self.clear_all
    REDIS.del("seeks")
  end
end
