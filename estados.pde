int estado=0;


int duracionPantalla = 5000;  // Duración en milisegundos (5 segundos
int tiempoInicioPantalla =0;

void dibujar() { 
  if (estado == 0) {
    pantallaInicio();
    println(frameCount);
    if (estado== 0 & frameCount > 50 & frameCount<100) {
      estado=1;
    }
    player.play();
  }
  if (estado == 1) {
    pantallaInstrucciones();
  }
  if (estado == 2) {
    pantallaJuego();
    player.pause();
    player1.play();
  }
  if (estado == 3) {
    pantallaGanaste();
    juegoTerminado = true;
    player1.pause();
    win.play();
  }
  if (estado == 4) {
    pantallaPerdiste();
    juegoTerminado = false;
    player1.pause();
    lose.play();
  }
}









void pantallaInicio() { 
  if (pantallaInicial) {
    background(0); // Fondo negro
    image (inicio, 0, 0);

    if (millis() > duracionPantallaInicial) {
      pantallaInicial = false;
    }
  }
}


void pantallaInstrucciones() {
  background(0); // Fondo negro
  image(instrucciones, 0, 0, 1200, 600);
  if (blobFueDetectado()) {
    estado=2;
  }
}
void pantallaPerdiste() {

  image (perdiste, 590, 300);
}

void pantallaJuego() {
  image(fondo, 650, 300);
  mostrarPlanetas();
  mostrarContadores();
  receptor.actualizar(mensajes);
  if (millis() - tiempoAnterior >= 1000) {
    tiempoRestante--;
    tiempoAnterior = millis();
  }

  receptor.actualizar(mensajes);

  if (!juegoTerminado) {
    if (blobFueDetectado()) {
      println("Hay movimiento");
      VelY = max(VelY - 2, -maxYVelocity);
    } else {
      println("No hay movimiento");
      VelY += gravity;
    }
    float boxY = posY + VelY;
    box.setPosition(box.getX() + VelX, boxY);

    float halfBoxWidth = box.getWidth() / 2;
    float halfBoxHeight = box.getHeight() / 2;
    float maxX = width - halfBoxWidth;
    float maxY = height - halfBoxHeight;

    if (box.getX() < halfBoxWidth) {
      box.setPosition(halfBoxWidth, boxY);
    } else if (box.getX() > maxX) {
      box.setPosition(maxX, boxY);
    }
    float distanciaMinima = 30; // Ajusta según tu preferencia

    for (FBox staticDiamond : staticDiamonds) {
      float DiamanteRadio = staticDiamond.getWidth() / 2;
      float distancia;
      //if (DiamanteRadio < 60) {
      //  //reboteSound.rewind();
      // // reboteSound.play();
      //  distanciaMinima = 15;
      //  distancia = dist(box.getX(), box.getY(), staticDiamond.getX() - 10, staticDiamond.getY());
      //} else {
      //  //reboteSound.rewind();
      //  //reboteSound.play();
      //  distanciaMinima=30;
      //  distancia = dist(box.getX(), box.getY(), staticDiamond.getX() - 40, staticDiamond.getY());
      //}
      distancia = dist(box.getX()+10, box.getY(), staticDiamond.getX(), staticDiamond.getY());
      if (distancia < DiamanteRadio + box.getWidth() / 2) {
        // Pinky acaba de colisionar con una caja estática, reproduce el sonido
        reboteSound.rewind();
        reboteSound.play();
        //colisionConCajaEstatica = true;

        // Calcular el vector de dirección desde la caja principal al diamante
        float dx = staticDiamond.getX() - box.getX();
        float dy = staticDiamond.getY() - box.getY();

        // Normalizar el vector de dirección
        float distanciaTotal = sqrt(dx * dx + dy * dy);
        dx /= distanciaTotal;
        dy /= distanciaTotal;
        if (DiamanteRadio < 60) {
          // Aplicar una fuerza de rebote en la dirección opuesta
          float fuerzaRebote = 80; // Ajusta según tu preferencia
          box.addForce(-dx * fuerzaRebote, -dy * fuerzaRebote);
        } else if (DiamanteRadio > 60) {
          // Aplicar una fuerza de rebote en la dirección opuesta
          float fuerzaRebote = 80; // Ajusta según tu preferencia
          box.addForce(-dx * fuerzaRebote, -dy * fuerzaRebote);
        }
      }
    }
    // Restablecer la variable cuando no haya colisiones
    if (!colisionConCajaEstatica) {
      colisionConCajaEstatica = false;
    }
    for (int i = estrellas.size() - 1; i >= 0; i--) {
      FBox estrellaBox = estrellas.get(i);
      float estrellaX = estrellaBox.getX();
      float estrellaY = estrellaBox.getY();
      float estrellaRadio = estrellaBox.getWidth() / 2;
      float distancia = dist(box.getX(), box.getY(), estrellaX, estrellaY);

      if (distancia < estrellaRadio + box.getWidth() / 2) {
        estrellaSound.rewind();
        estrellaSound.play();
        estrellasRecolectadas++;
        estrellas.remove(i);  // Elimina la estrella de la lista
      } else {
        image(estrella, estrellaX - estrellaRadio, estrellaY - estrellaRadio, estrellaBox.getWidth(), estrellaBox.getHeight());
      }
    } 

    if (box.getY() > height) {
      reposicionarPinky();
    }
    noStroke();
    noFill();
    drawSquare(box);

    Pinky.resize(100, 100);
    imageMode(CENTER);
    image(Pinky, box.getX(), box.getY(), box.getWidth(), box.getHeight());

    for (FBox staticDiamond : staticDiamonds) {
      noFill();
      drawDiamond(staticDiamond);
    }

    for (FBox estrellaBox : estrellas) {
      float estrellaX = estrellaBox.getX();
      float estrellaY = estrellaBox.getY();
      float estrellaRadio = estrellaBox.getWidth() / 2;
      float distancia = dist(box.getX(), box.getY(), estrellaX, estrellaY);

      if (distancia < estrellaRadio + box.getWidth() / 2) {
        estrellasRecolectadas++;
        estrellaSound.play();
        reposicionarEstrella(estrellaBox);
      }

      image(estrella, estrellaX - estrellaRadio, estrellaY - estrellaRadio, estrellaBox.getWidth(), estrellaBox.getHeight());
    }

    image(tierraImg, 1190, height / 2 - 25, 600, 450); // Posición (1000, altura/2) y tamaño 200x200

    float distanciaTierra = dist(box.getX(), box.getY(), 1225 - 25, height / 2 - 25);
    if (distanciaTierra < 25 + box.getWidth() / 2) {
      if (estrellasRecolectadas >= 8) {
        estado = 3;
      }
    }

    if (tiempoRestante == 0 || distanciaTierra < 15 + box.getWidth() / 2 && estrellasRecolectadas < 8 ) {
      estado = 4;
    }
  }
}

void pantallaGanaste() {
  image (ganaste, 590, 300);
}
