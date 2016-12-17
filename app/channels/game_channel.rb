class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "player_#{uuid}"
    ActionModels::Seek.create(uuid)
  end

  def unsubscribed
    ActionModels::Seek.remove(uuid)
    ActionModels::Game.forfeit(uuid)
  end

  def play_word(data)
    ActionModels::Game.play_word(uuid, data['word'])
  end
end
