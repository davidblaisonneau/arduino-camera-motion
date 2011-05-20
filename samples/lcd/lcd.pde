#include <LiquidCrystal.h> //include LiquidCrystal library

// Initialisation des variables
LiquidCrystal lcd = LiquidCrystal(12,11,2,3,4,5,6,7,8,9,10); //create a LiquidCrystal object to control an LCD
int LedInterne = 13;
int delai = 1000;

void setup()
{

  
  // set up the LCD's number of columns and rows:
  lcd.begin(16,2);
  
  //Print message
  lcd.print("Salut la compagnie");
  
  delay(1000);
  
}

void loop() {
  // scroll 13 positions (string length) to the left
  // to move it offscreen left:
  for (int positionCounter = 0; positionCounter < 19; positionCounter++) {
    // scroll one position left:
    lcd.scrollDisplayLeft();
    // wait a bit:
    delay(250);
  }
  
    // scroll 29 positions (string length + display length) to the right
  // to move it offscreen right:
  for (int positionCounter = 0; positionCounter < 35; positionCounter++) {
    // scroll one position right:
    lcd.scrollDisplayRight();
    // wait a bit:
    delay(250);
  }
 
    // scroll 16 positions (display length + string length) to the left
    // to move it back to center:
  for (int positionCounter = 0; positionCounter < 16; positionCounter++) {
    // scroll one position left:
    lcd.scrollDisplayLeft();
    // wait a bit:
    delay(250);
  }

}
