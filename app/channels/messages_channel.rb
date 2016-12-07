# app/channels/messages_channel.rb
class MessagesChannel < ApplicationCable::Channel
  def subscribed
    puts 'SUBSCRIBED'
    ActionCable.server.broadcast("room_1", "OOOOOOOOH YEAH")
  end
end
