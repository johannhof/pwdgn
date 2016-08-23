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

app.ports.cryptoRandom.subscribe(function(parameters) {
  chrome.storage.local.set({parameters});
  generateRandom(parameters);
});

// initialize things
setTimeout(function(){
  chrome.storage.local.get("parameters", function(data){
    let parameters = data.parameters ||  [7,7,5,2];
    app.ports.parameters.send(parameters);
    generateRandom(parameters);
  });
}, 10);
