class GameChannel < ApplicationCable::Channel
  def subscribed
    if (params[:guest_name].present?)
      player = Player.find_by(id: uuid)
      player.username = params[:guest_name]
      player.save!
    end

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
