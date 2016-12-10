class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "player_#{uuid}"
    ActionModels::Seek.create(uuid)
  end

  def unsubscribed
    ActionModels::Seek.remove(uuid)
    ActionModels::Game.forfeit(uuid)
  end

  def make_move(data)
    ActionModels::Game.play_word(uuid, data)
  end
end
