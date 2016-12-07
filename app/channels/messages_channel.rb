# app/channels/messages_channel.rb
class MessagesChannel < ApplicationCable::Channel
  def subscribed
    puts 'SUBSCRIBED'
    stream_from "room_#{params[:room]}"
#    ActionCable.server.broadcast("room_1", "OOOOOOOOH YEAH")
#    ActionCable.server.broadcast 'room_1', message: '<p>Test à la ROOM 1</p>'
  end

   def receive(data)
     # ActionCable.server.broadcast("chat_#{params[:room]}", data)
     message = data['message'].to_s
     sent_by = data['sent_by'].to_s
     ActionCable.server.broadcast 'room_1', message: message + "de" + sent_by
   end
end
