#include <Servo.h>

const int trigPin = 4;
const int echoPin = 3;
const int ledVerte = 5;
const int ledRouge = 6;
const int brocheBuzzer = 11;
const int boutonPin = 2; // Nouvelle broche pour le bouton

long duree;
int distance;
Servo monServo;

// VARIABLES POUR LE BOUTON
bool buzzerAutorise = true;   // État de l'interrupteur logiciel
bool dernierEtatBouton = HIGH; // Pour détecter l'appui

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(ledVerte, OUTPUT);
  pinMode(ledRouge, OUTPUT);
  pinMode(brocheBuzzer, OUTPUT);
  
  // Utilisation de la résistance interne (évite un fil 5V vers le bouton)
  pinMode(boutonPin, INPUT_PULLUP); 

  Serial.begin(9600); 
  monServo.attach(8); 
}

void loop() {
  // Balayage aller de 15 à 165
  for (int i = 15; i <= 165; i++) {  
    faireUnCycle(i);
  }
  // Balayage retour de 165 à 15
  for (int i = 165; i > 15; i--) {  
    faireUnCycle(i);
  }
}

// Fonction regroupant les étapes pour raccourcir la boucle loop
void faireUnCycle(int angleActuel) {
  monServo.write(angleActuel);
  
  // VÉRIFICATION DU BOUTON (Silence Tactique)
  bool etatBouton = digitalRead(boutonPin);
  if (etatBouton == LOW && dernierEtatBouton == HIGH) {
    buzzerAutorise = !buzzerAutorise; // On inverse l'état (ON <-> OFF)
    delay(50); // Petit délai anti-rebond
  }
  dernierEtatBouton = etatBouton;

  delay(20);
  distance = calculerDistance();
  gererAlertes(distance);
  
  // Envoi des données au Mac (Processing)
  Serial.print(angleActuel);
  Serial.print(",");
  Serial.print(distance);
  Serial.print("."); 
}

int calculerDistance() { 
  digitalWrite(trigPin, LOW); 
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH); 
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duree = pulseIn(echoPin, HIGH, 30000); // Timeout pour ne pas bloquer si pas d'écho
  return duree * 0.034 / 2; 
}

void gererAlertes(int dist) {
  if (dist > 0 && dist < 40) {
    digitalWrite(ledVerte, LOW);
    digitalWrite(ledRouge, HIGH);
    
    // On ne fait sonner que si le bouton n'a pas coupé le son
    if (buzzerAutorise) {
      digitalWrite(brocheBuzzer, HIGH);
    } else {
      digitalWrite(brocheBuzzer, LOW);
    }
  } else {
    digitalWrite(ledVerte, HIGH);
    digitalWrite(ledRouge, LOW);
    digitalWrite(brocheBuzzer, LOW);
  }
}