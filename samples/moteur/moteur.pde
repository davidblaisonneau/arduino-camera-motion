/*
 * Tourner un moteur
 */
 
 
/*
 * MotorKnob
 *
 * A stepper motor follows the turns of a potentiometer
 * (or other sensor) on analog input 0.
 *
 * http://www.arduino.cc/en/Reference/Stepper
 * This example code is in the public domain.
 */

#include <Stepper.h>

// change this to the number of steps on your motor
#define STEPS 48

// create an instance of the stepper class, specifying
// the number of steps of the motor and the pins it's
// attached to
Stepper stepper = Stepper(STEPS, 8, 9, 10, 11);

void setup()
{
  // set the speed of the motor
  stepper.setSpeed(10);
}

void loop()
{

  // move a number of steps equal to the change in the
  // sensor reading
  stepper.step(1);
  
  delay(100);

}

