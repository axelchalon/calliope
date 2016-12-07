// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// app/assets/javascripts/channels/chatrooms.js

//= require cable
//= require_self
//= require_tree .

this.App = {};

var log = console.log

App.cable = ActionCable.createConsumer();
App.channel = App.cable.subscriptions.create({channel: "MessagesChannel", room: "1"}, {
    connected: function() { console.log('conn') },
    disconnected: function() { console.log('disconn') },
    received: function(data) {
      console.log('received', data)
    },
    speak: function(message, roomId) {
      console.log('speak', message)
    }
  });

setTimeout(() => {
  let maa = Math.random()
  console.log('Sending bonjour de ' + maa)
App.channel.send({ message: "Bonjour !", sent_by: Math.random() })
},2000)
