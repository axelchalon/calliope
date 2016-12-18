
//= require vue
//= require cable
//= require_self
//= require_tree .

this.App = {};

App.cable = ActionCable.createConsumer();


window.onload = () => {
  var MESYEUX = new Vue({
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
      type: '',
      yourTurn: false,
      currentWord: ''
    },
    ready: function() {
    console.log('ready freddy')
  },
  computed: {
    wordsReversed: function() {
        return this.words.reduceRight((acc, e) => (acc.push(e), acc), []);
    }
},
  methods: {
goSolo: function() {
  this.screen = 'game-seeking'
  this.type = 'ai'
  this.go(this.guestName, true)
},
goPublic: function() {
  this.screen = 'game-seeking'
  this.type = 'public'
  this.go(this.guestName, false, "public")
},
goPrivate: function(watchword) {
  this.screen = 'game-seeking'
  this.type = 'private'
  this.go(this.guestName, false, "private", watchword)
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
            if (this.type == 'private')
              this.gameLink = location.protocol+'//'+location.host+location.pathname+"#game"+data.

            console.log('Seeking an opponent. Your player ID is ' + data.pid);
          break;
          case 'game_starts':
            thisVue.screen = 'game-game'
            thisVue.opponentName = data.opponent_name
            thisVue.firstLetter = data.first_letter.toUpperCase()
            console.log('Game starts. You are ' + data.role + '. Opponent name: ' + data.opponent_name + ". First letter: " + data.first_letter)
            thisVue.yourTurn = data.role == 'p0'
          break;
          case 'word_accepted':
            thisVue.myPoints = data.points;
            thisVue.gameError = ''
            thisVue.words.push({word: data.msg, by: "me"})
            thisVue.firstLetter = data.msg.slice(-1).toUpperCase()
            console.log('OK. You now have ' + data.points + ' points');
          break;
          case 'opponent_played':
            thisVue.opponentPoints = data.points;
            thisVue.words.push({word: data.msg, by: "opponent"})
            thisVue.firstLetter = data.msg.slice(-1).toUpperCase()
            thisVue.yourTurn = true
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
            thisVue.yourTurn = true
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
  this.yourTurn = false
  App.channel.perform("play_word", {word: word})
}
}
  });

if ((splits = window.location.href.split("#")) && splits.length > 1)
{
  MESYEUX.goPrivate(splits[1].substr(4));
}

}
