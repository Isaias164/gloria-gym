
$("#linkF").on("click",function() {
    localStorage.setItem('deporte', 'futbol');
});
$("#linkG").on("click",function() {
    localStorage.setItem('deporte', 'gym');
});
$("#linkN").on("click",function() {
    localStorage.setItem('deporte', 'pileta');
});
$("#linkP").on("click",function() {
    localStorage.setItem('deporte', 'paddle');
});
//imagenes que voy a mostrar
var futbol = ["/static/api/img/torneos/futbol/futbol1.PNG","/static/api/img/torneos/futbol/futbol2.PNG","/static/api/img/torneos/futbol/futbol4.PNG","/static/api/img/torneos/futbol/futbol5.PNG"];
var paddle = ["/static/api/img/torneos/paddle/paddle1.PNG","/static/api/img/torneos/paddle/paddle2.PNG","/static/api/img/torneos/paddle/paddle3.PNG"];
var natacion = ["/static/api/img/torneos/natación/natación1.PNG","/static/api/img/torneos/natación/natación2.PNG","/static/api/img/torneos/natación/natación3.PNG","/static/api/img/torneos/natación/natación4.PNG","/static/api/img/torneos/natación/natación5.PNG"];
var gym = ["/static/api/img/torneos/gym/gym1.PNG","/static/api/img/torneos/gym/gym2.PNG","/static/api/img/torneos/gym/gym3.PNG","/static/api/img/torneos/gym/gym4.PNG"];

var f = setInterval(cambiarImagenF, 1000);
var p = setInterval(cambiarImagenP, 1300);
var g = setInterval(cambiarImagenG, 1600);
var n = setInterval(cambiarImagenN, 1900);
//los indices de las imagenes
var pos = 0;
var pos1 = 0;
var pos2 = 0;
var pos3 = 0;
//futbol
$("#compeFutbol").on("mouseout",function (){
    seguir(0);
});
$("#compeFutbol").on("mouseover",function(){
    parar(0);
});
//gym
$("#compeGym").on("mouseout",function (){
    seguir(1);
});
$("#compeGym").on("mouseover",function(){
    parar(1);
});
//natación
$("#compeNatacion").on("mouseout",function (){
    seguir(2);
});
$("#compeNatacion").on("mouseover",function(){
    parar(2);
});
//paddle
$("#compePaddle").on("mouseout",function (){
    seguir(3);
});
$("#compePaddle").on("mouseover",function(){
    parar(3);
});
function seguir(index) {
    if(index === 0){
        let nf = setInterval(cambiarImagenF, 1000);
        f = nf;
    }
    else if(index === 1){
        let nf = setInterval(cambiarImagenG, 1000);
        g = nf;
    }
    else if(index === 2){
        let nf = setInterval(cambiarImagenN, 1000);
        n = nf;
    }
    else{
        let nf = setInterval(cambiarImagenP, 1000);
        p = nf;
    }
}

function parar(index) {
    if(index === 0){
        clearInterval(f);
    }
    else if(index === 1){
        clearInterval(g);
    }
    else if(index === 2){
        clearInterval(n);
    }
    else{
        clearInterval(p);
    }
}

function cambiarImagenF() {
    if (pos < futbol.length) {
        $("#compeFutbol").attr("src",futbol[pos]);
        //alert(futbol[pos]);
        pos += 1;
    }
    else {
        pos = 0;
    }
}

function cambiarImagenP() {
    if (pos1 < paddle.length) {
        $("#compePaddle").attr("src",paddle[pos1]);
        pos1 += 1;
    }
    else {
        pos1 = 0;
    }
}

function cambiarImagenG() {
    if (pos2 < gym.length) {
        $("#compeGym").attr("src",gym[pos2]);
        pos2 += 1;
    }
    else {
        pos2 = 0;
    }
}

function cambiarImagenN() {
    if (pos3 < natacion.length) {
        $("#compeNatacion").attr("src",natacion[pos3]);
        pos3 += 1;
    }
    else {
        pos3 = 0;
    }
}
