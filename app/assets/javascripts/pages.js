// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// app/assets/javascripts/channels/chatrooms.js

//= require cable
//= require_self
//= require_tree .

this.App = {};

App.cable = ActionCable.createConsumer();

function go() {
  App.channel = App.cable.subscriptions.create({channel: "GameChannel"}, {
      connected: function() { console.log('Connected. Waiting for opponent.') },
      disconnected: function() { console.log('Disconnected.') },
      received: function(data) {
        switch(data.action) {
          case 'game_starts':
            console.log('Game starts. You are ' + data.role + '. Opponent name: ' + data.opponent_name + ". First letter: " + data.first_letter)
          break;
          case 'word_accepted':
            console.log('OK. You now have ' + data.points + ' points');
          break;
          case 'opponent_played':
            console.log('Opponent plays: ' + data.msg + ' ; now has ' + data.points + ' points');
          break;
          case 'opponent_forfeits':
            console.log('Opponent forfeits.')
          break;
          case 'you_won':
            console.log('You won.')
          break;
          case 'you_lost':
            console.log('You lost.')
          break;
          case 'error':
            console.log('Error:' + data.msg)
          break;
        }
      },
      speak: function(message, roomId) {
        console.log('speak', message)
      }
    });
}

function playWord(word)
{
  App.channel.perform("play_word", {word: word})
}
