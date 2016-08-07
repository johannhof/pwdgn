let app = Elm.Main.fullscreen();
app.ports.focus.subscribe(function(selector) {
    setTimeout(function() {
        let node = document.querySelector(selector);
        if (node) {
            node.focus();
            node.setSelectionRange(0, node.value.length);
        }
    }, 50);
});

document.body.addEventListener("click", function(ev) {
  let node = ev.target;
  if (node.id === "password") {
    node.setSelectionRange(0, node.value.length);
    document.execCommand("copy");
  }
});

function generateRandom(list) {
  let lower = new Uint16Array(list[0]);
  window.crypto.getRandomValues(lower);

  let upper = new Uint16Array(list[1]);
  window.crypto.getRandomValues(upper);

  let digits = new Uint16Array(list[2]);
  window.crypto.getRandomValues(digits);

  let special = new Uint16Array(list[3]);
  window.crypto.getRandomValues(special);

  app.ports.randomValues.send([
    Array.from(lower).map(subZero),
    Array.from(upper).map(subZero),
    Array.from(digits).map(subZero),
    Array.from(special).map(subZero)
  ]);
}

let subZero = (n) => n / 65536;

app.ports.cryptoRandom.subscribe(function(list) {
  generateRandom(list);
});

// FIXME BIG AND UGLY HACK
// for some reason subscriptions can not trigger when init is run,
// this makes a pasword appear on starting up
setTimeout(function(){
  generateRandom([7,7,5,2]);
}, 10)
