import fisica.*; //<>//
import oscP5.*;
import processing.core.PImage;
import processing.core.PFont;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.ugens.*;
Minim minim;
AudioPlayer estrellaSound;
AudioPlayer player, player1;
AudioPlayer reboteSound, lose, win;
//boolean playMusic = true; // Controla si se debe reproducir la música de fondo
//boolean musicaIniciada = false;
boolean colisionConCajaEstatica = false;

FWorld world;
FBox box;
int estrellasRecolectadas = 0;
boolean llegoALaTierra = false;
int tiempoRestante = 60; // Tiempo en segundos
int tiempoAnterior;
PImage tierraImg;
PImage inicio; 
PImage ganaste;
PImage perdiste;
PImage fondo;
PImage cajaTiempoImg;
//PImage contador1;
PImage instrucciones; 
// Al inicio del programa
PVector[] posicionesInicialesEstrellas = new PVector[14];
PFont letrita;
float posX = 0;
float VelX = 2; // Velocidad de avance en el eje X (ajusta según lo deseado)
float VelY = 0; // Velocidad de elevación en el eje Y
float maxYVelocity = -5; // Velocidad máxima de elevación en el eje Y
float gravity = 4; // Gravedad (ajusta según lo deseado)
float prevPosX, prevPosY, posY, posZ;
float dampingFactor = 3; // Factor de amortiguación (ajusta según tus preferencias)

// Tamaños personalizados para los diamantes
float[] diamanteSizes = {40, 126, 60, 98, 110, 90, 100, 90, 120, 130, 40, 150, 86, 102};
PImage[] imagenesDiamantes = new PImage[14];
PImage [] estrellasReco = new PImage [9];
// Ubicaciones personalizadas para los diamantes
float[] diamanteX = {200, 450, 100, 920, 60, 380, 820, 110, 700, 550, 750, 1170, 150, 990};
float[] diamanteY = {100, 100, 300, 120, 800, 310, 900, 800, 220, 580, 420, 120, 550, 450};
ArrayList<FBox> staticDiamonds = new ArrayList<FBox>();
ArrayList<FBox> estrellas = new ArrayList<FBox>();
// Inicializa la lista de mensajes
PImage Pinky; // Variable para almacenar la imagen
PImage estrella;
Receptor receptor;
boolean juegoTerminado = false;
PFont fuente;
boolean pantallaInicial = true;
int duracionPantallaInicial = 5 * 1000;
boolean pantallaPerdiste = false;
int duracionPantallaPerdiste = 3 * 1000;

void setup() {
  size(1200, 600);
  Fisica.init(this);
  world = new FWorld();
  world.setEdges();
  mensajes = new ArrayList<OscMessage>();
  osc = new OscP5(this, 12345);
  osc.plug(this, "procesarMensaje", "/mensajes");

  minim = new Minim(this);
  letrita=createFont("aAbstractGroovy.ttf", 20);
  estrellaSound = minim.loadFile("colision.mp3");
  reboteSound = minim.loadFile("rebote.mp3"); // Cargar el sonido de rebote
  player = minim.loadFile("inicio.mp3");
  player1 = minim.loadFile("taylor.mp3");
  win = minim.loadFile("final.mp3");
  lose = minim.loadFile("sad.mp3");
  cajaTiempoImg = loadImage("cajatiempo.png");

  player.loop();
  //musicaIniciada = true;
  Fisica.init(this);

Pinky = loadImage("data/Pinky.png");
  estrella = loadImage("estrella.png");
  tierraImg = loadImage("tierra.png"); // Carga la imagen de la tierra
  inicio= loadImage("inicio.jpg");
  ganaste= loadImage ("ganaste.jpg");
  perdiste= loadImage ("perdiste.jpg");
  fondo= loadImage ("fondo.jpg");
  instrucciones= loadImage ("instrucciones.jpg");

  float deltaY = mouseY - posY;
  deltaY *= dampingFactor;
  deltaY *= dampingFactor;
  posY += deltaY;

  box = new FBox(50, 50);
  box.setPosition(posX, height / 2);
  world.add(box);

  for (int i = 0; i < diamanteSizes.length; i++) {
    float size = diamanteSizes[i];
    float x = diamanteX[i];
    float y = diamanteY[i];

    FBox staticDiamond = new FBox(size, size);
    staticDiamond.setPosition(x, y);
    staticDiamond.setStatic(true);
    staticDiamond.setRestitution(0.8);
    staticDiamond.setRotation(45);
    world.add(staticDiamond);
    staticDiamonds.add(staticDiamond);
  }

  for (int i = 0; i < 14; i++) {
    imagenesDiamantes[i] = loadImage("data/caja" + i + ".png");
  }

    // Cargar imágenes para el hud
  for (int i = 0; i < 9; i++) {
    estrellasReco[i] = loadImage("data/star" + i + ".png");
  }

  receptor = new Receptor();
  tiempoAnterior = millis();
  fuente = createFont("Arial", 64);

  float[] estrellaX = {100, 400, 200, 480, 590, 900, 1000, 1090, 250, 500, 250, 980, 120, 420 };
  float[] estrellaY = {100, 400, 340, 500, 300, 300, 190, 450, 150, 200, 550, 550, 750, 110};

  for (int i = 0; i < 14; i++) {
    FBox estrellaBox = new FBox(40, 35);
    estrellaBox.setPosition(estrellaX[i], estrellaY[i]);
    estrellaBox.setStatic(true);
    world.add(estrellaBox);
    estrellas.add(estrellaBox);

    // Guarda la posición inicial de la estrella
    posicionesInicialesEstrellas[i] = new PVector(estrellaX[i], estrellaY[i]);
  }
}

void draw() {
  world.step();
 receptor.actualizar(mensajes);

  if (!juegoTerminado) {
    if (blobFueDetectado()) {
      println("Hay movimiento");
      VelY = max(VelY - 2, -maxYVelocity);
    } else {
      println("No hay movimiento");
      VelY += gravity;
    }
    

  dibujar();

}
}


void drawSquare(FBox b) {
  float boxX = b.getX();
  float boxY = b.getY();
  float boxWidth = b.getWidth();
  float boxHeight = b.getHeight();
  rectMode(CENTER);
  rect(boxX, boxY, boxWidth, boxHeight);
  rectMode(CORNER);
}

void reposicionarPinky() {
  // Restablecer la posición de Pinky en el eje Y a su posición inicial
  box.setPosition(box.getX(), height / 2);
  VelY = 0;
}

void drawDiamond(FBox b) {
  float boxX = b.getX();
  float boxY = b.getY();
  float boxWidth = b.getWidth();
  float boxHeight = b.getHeight();
  rectMode(CENTER);
  pushMatrix();
  translate(boxX, boxY);
  rotate(PI/4);
  rect(-boxWidth / 2, -boxHeight / 2, boxWidth, boxHeight);
  popMatrix();
}

boolean blobFueDetectado() {
  return receptor.blobs.size() > 0;
}

void mostrarPlanetas() {
  for (int i = 0; i < staticDiamonds.size(); i++) {
    FBox staticDiamond = staticDiamonds.get(i);
    PImage imagenDiamante = imagenesDiamantes[i];
    // Obtener la posición del diamante
    float x = staticDiamond.getX();
    float y = staticDiamond.getY();

    // Dibujar la imagen del diamante en la posición del diamante
    imageMode(CENTER);
    image(imagenDiamante, x - staticDiamond.getWidth()/22, y - staticDiamond.getHeight() /1.6, staticDiamond.getWidth(), staticDiamond.getHeight());
  }
}

void reposicionarEstrella(FBox estrellaBox) {
  float nuevaX = random(width);
  float nuevaY = random(height);
  estrellaBox.setPosition(nuevaX, nuevaY);
}

void mostrarContadores() {
   // Dibujar la imagen de la caja del tiempo debajo del contador de tiempo
  image(cajaTiempoImg, 1110, 40, cajaTiempoImg.width, 50);
 


 // Mostrar el contador de tiempo
  textAlign(CENTER);
  textFont(letrita);
  fill(255);
  textSize(30);
  text(tiempoRestante, 1110, 51);

  // Muestra el contador de estrellas 
  
 //image( contador1, 200, 40, 300, 50);
   image(estrellasReco[estrellasRecolectadas], 200, 40, 300, 50);
 
}

//void verificarFinDelJuego() {
//  if (millis() - tiempoAnterior >= 1000) {
//    tiempoRestante--;
//    tiempoAnterior = millis();
//  }

// else {
//      perderJuego();
//    }
  

//  if (tiempoRestante <= 0) {
//    pantallaPerdiste();
//  }
//}

void reposicionarEstrellas() {
  for (int i = 0; i < estrellas.size(); i++) {
    FBox estrellaBox = estrellas.get(i);
    PVector posicionInicial = posicionesInicialesEstrellas[i];
    estrellaBox.setPosition(posicionInicial.x, posicionInicial.y);
  }
}

void juegoGanado() {
  juegoTerminado = true;
  pantallaPerdiste = false;
  llegoALaTierra = true;
}

void perderJuego() {
  juegoTerminado = true;
  pantallaPerdiste = true;
  tiempoRestante = 0;
}

void reiniciarJuego() {
  box.setPosition(posX, height / 2);
  VelY = 0;
  estrellasRecolectadas = 0;
  tiempoRestante = 60;
  tiempoAnterior = millis();
  llegoALaTierra = false;

//  if (llegoALaTierra && estrellasRecolectadas < 8) {
//    // El jugador llegó a la Tierra sin recolectar las 8 estrellas, por lo que pierde.
//    pantallaPerdiste();
//  }

  reposicionarEstrellas(); // Llama a la función para reposicionar las estrellas

  juegoTerminado = false;
}
