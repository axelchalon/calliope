class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "player_#{uuid}"
    ActionModels::Seek.create(uuid)
    @toasterette = "toasterette youpyoup" + SecureRandom.uuid
    puts "INIT toasterette" + @toasterette
  end

  def unsubscribed
    ActionModels::Seek.remove(uuid)
    ActionModels::Game.forfeit(uuid)
  end

  def play_word(data)
    puts "WAP"
    puts @toasterette
    puts "WBP"
    ActionModels::Game.play_word(uuid, data['word'])
  end
end
