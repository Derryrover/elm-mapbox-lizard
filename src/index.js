'use strict';

require("./styles.scss");
const {Elm} = require('./Main');
const {registerCustomElement, registerPorts} = require("elm-mapbox")
// require("random shit")

//elmMapbox.
registerCustomElement({token: 'pk.eyJ1IjoidG9tZGVib2VyMjkxMCIsImEiOiJjamtkcGp5OXQxaG1nM2tudnBvcmQwOTRoIn0.7LDZekdcKh7afE4JaJxPhg'});


var app = Elm.Main.init({
    flags: 6,
    node : document.getElementById('main_elm'),
});
//elmMapbox.
registerPorts(app);

app.ports.toJs.subscribe(data => {
    console.log(data);
})
// Use ES2015 syntax and let Babel compile it for you
var testFn = (inp) => {
    let a = inp + 1;
    return a;
}
