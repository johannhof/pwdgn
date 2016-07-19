let app = Elm.Main.fullscreen();
app.ports.focus.subscribe(function(selector) {
    setTimeout(function() {
        let node = document.querySelector(selector);
        if (node) {
            node.setSelectionRange(0, node.value.length);
        }
    }, 50);
});
