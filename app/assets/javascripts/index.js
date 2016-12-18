window.onload = () => {
  var employees = new Vue({
    el: '#employees',
    data: {
      employees: [{name: "hello", email: "meal", manager:"jccc+"}]
    },
    ready: function() {
    console.log('ready freddy')
    }
  });
}
