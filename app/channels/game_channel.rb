class GameChannel < ApplicationCable::Channel
  def subscribed
    if (params[:guest_name].present?)
      player = Player.find_by(id: uuid)
      player.username = params[:guest_name]
      player.save!
    end

    stream_from "player_#{uuid}"
  end

  def go(data)
    if (data["play_against_computer"].present?)
      ai = Player.create!(username: "Computer", password: rand(100000..999999)) # @TODO add flag ai
      ai.username = "Computer #" + ai.id.to_s
      ai.save!
      ActionModels::Game.start(uuid, ai.id)
    elsif data["type"].present? && data["type"] == 'private'
      if (data["opponent"].present?)
        ActionModels::ArrangedSeek.join(uuid,data["opponent"])
      else
        ActionModels::ArrangedSeek.create(uuid)
      end
    else
      ActionModels::Seek.create(uuid)
    end
  end

  def unsubscribed
    ActionModels::Seek.remove(uuid)
    ActionModels::Game.forfeit(uuid)
  end

  def play_word(data)
    ActionModels::Game.play_word(uuid, data['word'])
  end
end
