class ActionModels::ArrangedSeek
  def self.create(uuid)
    REDIS.sadd("seeks", "opponent_for_arranged_" + uuid)
    ActionModels::Game.notify_seek(uuid)
  end

  def self.join(uuid, watchword)
    if opponent = REDIS.spop("opponent_for_arranged_" + watchword)
      ActionModels::Game.start(uuid, opponent)
    end
  end

  def self.remove(uuid)
    REDIS.srem("seeks", uuid)
  end

  def self.clear_all
    REDIS.del("seeks")
  end
end
