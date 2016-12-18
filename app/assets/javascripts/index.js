
//= require vue
//= require cable
//= require_self
//= require_tree .

this.App = {};

App.cable = ActionCable.createConsumer();


window.onload = () => {
  var mavue = new Vue({
    el: '#vue-index',
    data: {
      screen: 'home',
      gameLink: false,
      myName: '',
      myPoints: 0,
      opponentName: '',
      opponentPoints: 0,
      firstLetter: '',
      gameError: '',
      words: [],
      currentWord: ''
    },
    ready: function() {
    console.log('ready freddy')
  },
  computed: {
    wordsReversed: function() {
        return this.words.reverse();
    }
},
  methods: {
goSolo: function() {
  this.screen = 'game-seeking'
  this.go(this.guestName, true)
},
go: function(guest_name, play_against_computer = false, type = "public", opponent = false) {
  var thisVue = this;
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
            thisVue.screen = 'game-game'
            thisVue.opponentName = data.opponent_name
            thisVue.firstLetter = data.first_letter
            console.log('Game starts. You are ' + data.role + '. Opponent name: ' + data.opponent_name + ". First letter: " + data.first_letter)
          break;
          case 'word_accepted':
            thisVue.myPoints = data.points;
            thisVue.gameError = ''
            thisVue.words.push({word: data.msg, by: "me"})
            thisVue.firstLetter = data.msg.slice(-1)
            console.log('OK. You now have ' + data.points + ' points');
          break;
          case 'opponent_played':
            thisVue.opponentPoints = data.points;
            thisVue.words.push({word: data.msg, by: "opponent"})
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
            thisVue.gameError = data.short
            console.log('Error:' + data.msg)
          break;
          default:
            console.log('Unknown event',data)
          break;
        }
      },
      speak: function(message, roomId) {
        console.log('speak', message)
      }
    });
},
playWord: function(word) {
  this.currentWord = '';
  App.channel.perform("play_word", {word: word})
}
}
  });
}
