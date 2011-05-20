/*
 * Clignoter la led
 */
 
// Initialisation des variables
int LedInterne = 13;
int delai = 200;

// Setup
void setup(){
  pinMode(LedInterne, OUTPUT);
}

// Loop
void loop(){
  digitalWrite(LedInterne, HIGH);
  delay(delai);
  digitalWrite(LedInterne, LOW);
  delay(delai);
}
