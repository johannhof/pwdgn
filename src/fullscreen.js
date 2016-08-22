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

app.ports.passwordStrength.subscribe(function(pass) {
  let result = zxcvbn(pass);
  app.ports.strength.send(result.score);
});

document.body.addEventListener("click", function(ev) {
  let node = ev.target;
  if (node.id === "password") {
    node.setSelectionRange(0, node.value.length);
    document.execCommand("copy");
  }
});

let subZero = (n) => n / 65536;

function generateRandom([lower, upper, digits, special]) {
  let random = new Uint16Array(lower + upper + digits + special);
  window.crypto.getRandomValues(random);
  random = Array.from(random).map(subZero);

  app.ports.randomValues.send([
    random.splice(0, lower),
    random.splice(0, upper),
    random.splice(0, digits),
    random.splice(0, special)
  ]);
}

app.ports.cryptoRandom.subscribe(function(list) {
  generateRandom(list);
});

// FIXME BIG AND UGLY HACK
// for some reason subscriptions can not trigger when init is run,
// this makes a password appear on starting up
setTimeout(function(){
  generateRandom([7,7,5,2]);
}, 10)
