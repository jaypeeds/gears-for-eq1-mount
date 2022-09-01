/*Example sketch to control a stepper motor with A4988 stepper motor driver, AccelStepper library and Arduino: continuous rotation. More info: https://www.makerguides.com */

// Include the AccelStepper library:
#include <AccelStepper.h>

// Define stepper motor connections and motor interface type. Motor interface type must be set to 1 when using a driver:
#define DIR_PIN 2
#define STEP_PIN 3
#define STEPS_PER_REV 200
#define MICRO_STEPS 16

// Create a new instance of the AccelStepper class:
AccelStepper stepper = AccelStepper(AccelStepper::DRIVER, STEP_PIN, DIR_PIN);

// returns speed: steps per second, from revolutions per minute
int rpmToSpeed(float rpm) {
  return (int)(rpm * STEPS_PER_REV * MICRO_STEPS / 60.0);
}

void setup() {
  // Set the maximum speed in steps per second:
  stepper.setMaxSpeed(1000);
}

void loop() {
  // Set the speed in steps per second:
  stepper.setSpeed(rpmToSpeed(1.0));
  // Step the motor with a constant speed as set by setSpeed():
  stepper.runSpeed();
}
