class ActionModels::Seek
  def self.create(uuid)
    if opponent = REDIS.spop("seeks")
      ActionModels::Game.start(uuid, opponent)
    else
      REDIS.sadd("seeks", uuid)
      ActionModels::Game.notify_seek(uuid)
    end
  end

  def self.remove(uuid)
    REDIS.srem("seeks", uuid)
  end

  def self.clear_all
    REDIS.del("seeks")
  end
end
