window.onload = () => {
  var mavue = new Vue({
    el: '#vue-index',
    data: {
      screen: 'home'
    },
    ready: function() {
    console.log('ready freddy')
    }
  });
}
