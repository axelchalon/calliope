// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// app/assets/javascripts/channels/chatrooms.js

//= require vue
//= require cable
//= require_self
//= require_tree .

this.App = {};

App.cable = ActionCable.createConsumer();

function go(guest_name, play_against_computer = false, type = "public", opponent = false) {
  App.channel = App.cable.subscriptions.create({channel: "GameChannel", guest_name: guest_name}, {
      connected: function() {
        console.log('Connected. Go!');
        App.channel.perform("go", { play_against_computer: play_against_computer, type: type, opponent: opponent });
      },
      disconnected: function() { console.log('Disconnected.') },
      received: function(data) {
        switch(data.action) {
          case 'seeking_opponent':
            console.log('Seeking an opponent. Your player ID is ' + data.pid);
          break;
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
