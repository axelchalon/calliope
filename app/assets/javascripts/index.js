//= require vue
//= require cable
//= require_self
//= require_tree .
'use strict';
this.App = {};

App.cable = ActionCable.createConsumer();

window.onload = () => {
    var MESYEUX = new Vue({
        el: '#vue-index',
        data: {
            screen: 'home',
            gameLink: false,
            myName: window.guest_username || '',
            myPoints: 0,
            opponentName: '',
            opponentPoints: 0,
            firstLetter: '',
            gameError: '',
            words: [],
            timer: 15,
            type: '',
            yourTurn: false,
            currentWord: '',
            skipTimeout: -1
        },
        ready: function() {},
        computed: {
            wordsReversed: function() {
                return this.words.reduceRight((acc, e) => (acc.push(e), acc), []);
            }
        },
        methods: {
            goSolo: function() {
                this.screen = 'game-seeking'
                this.type = 'ai'
                this.myName = this.myName || "Inconnu"
                this.go(this.myName, true)
            },
            goPublic: function() {
                this.screen = 'game-seeking'
                this.type = 'public'
                this.myName = this.myName || "Inconnu"
                this.go(this.myName, false, "public")
            },
            goPrivate: function(watchword) {
                this.screen = 'game-seeking'
                this.type = 'private'
                this.myName = this.myName || (watchword && "Invité") || "Inconnu"
                this.go(this.myName, false, "private", watchword)
            },
            go: function(guest_name, play_against_computer = false, type = "public", opponent = false) {
                var thisVue = this;
                App.channel = App.cable.subscriptions.create({
                    channel: "GameChannel",
                    guest_name: guest_name
                }, {
                    connected: function() {
                        console.log('Connected. Go!');
                        App.channel.perform("go", {
                            play_against_computer: play_against_computer,
                            type: type,
                            opponent: opponent
                        });
                    },
                    disconnected: function() {
                        console.log('Disconnected.')
                    },
                    received: function(data) {
                        switch (data.action) {
                            case 'seeking_opponent':
                                if (thisVue.type == 'private')
                                    thisVue.gameLink = location.protocol + '//' + location.host + location.pathname + "#game" + data.pid

                                console.log('Seeking an opponent. Your player ID is ' + data.pid);
                                break;
                            case 'game_starts':
                                thisVue.screen = 'game-game'
                                thisVue.opponentName = data.opponent_name
                                thisVue.firstLetter = data.first_letter.toUpperCase()
                                console.log('Game starts. You are ' + data.role + '. Opponent name: ' + data.opponent_name + ". First letter: " + data.first_letter)
                                thisVue.yourTurn = data.role == 'p0'
                                if (thisVue.yourTurn)
                                    thisVue.skipTimeout = setTimeout(() => thisVue.playWord(false), 15000)
                                    thisVue.timerDec();
                                break;
                            case 'word_accepted':
                                thisVue.myPoints = data.points;
                                thisVue.gameError = ''
                                thisVue.words.push({
                                    word: data.msg || 'PASSE',
                                    by: "me"
                                })
                                if (data.msg !== false)
                                    thisVue.firstLetter = data.msg.slice(-1).toUpperCase()
                                thisVue.timer = 15;
                                console.log('OK. You now have ' + data.points + ' points');
                                break;
                            case 'opponent_played':
                                thisVue.opponentPoints = data.points;
                                thisVue.words.push({
                                    word: data.msg || 'PASSE',
                                    by: "opponent"
                                })
                                if (data.msg !== false)
                                    thisVue.firstLetter = data.msg.slice(-1).toUpperCase()
                                thisVue.yourTurn = true
                                thisVue.timer = 15;
                                console.log('Opponent plays: ' + data.msg + ' ; now has ' + data.points + ' points');

                                clearTimeout(thisVue.skipTimeout)
                                thisVue.skipTimeout = setTimeout(() => thisVue.playWord(false), 15000)
                                break;
                            case 'opponent_forfeits':
                                thisVue.screen = 'game-won'
                                console.log('You won.')
                                console.log('Opponent forfeits.')
                                break;
                            case 'you_won':
                                thisVue.screen = 'game-won'
                                console.log('You won.')
                                break;
                            case 'you_lost':
                                thisVue.screen = 'game-lost'
                                console.log('You lost.')
                                break;
                            case 'error':
                                thisVue.gameError = data.short
                                thisVue.yourTurn = true
                                console.log('Error:' + data.msg)
                                break;
                            default:
                                console.log('Unknown event', data)
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
                App.channel.perform("play_word", {
                    word: word
                })
            },
            timerDec: function() {
              this.timer = Math.max(0,this.timer-1);
              // if (this.yourTurn)
                setTimeout(this.timerDec,1000)
            }
        }
    });

    var splits;
    if ((splits = window.location.href.split("#")) && splits.length > 1) {
        MESYEUX.goPrivate(splits[1].substr(4));
    }

}
