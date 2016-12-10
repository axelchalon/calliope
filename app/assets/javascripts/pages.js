// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// app/assets/javascripts/channels/chatrooms.js

//= require cable
//= require_self
//= require_tree .

this.App = {};

var log = console.log

App.cable = ActionCable.createConsumer();
App.channel = App.cable.subscriptions.create({channel: "GameChannel"}, {
    connected: function() { console.log('Connected. Waiting for opponent.') },
    disconnected: function() { console.log('Disconnected.') },
    received: function(data) {
      switch(data.action) {
        case 'game_starts':
          console.log('Game starts.')
        break;
        case 'opponent_plays':
          console.log('Opponent plays.' + data.msg)
        break;
        case 'opponent_forfeits':
          console.log('Opponent forfiets.')
        break;
      }
    },
    speak: function(message, roomId) {
      console.log('speak', message)
    }
  });

function playWord(word)
{
  App.channel.perform("play_word", word)
}
