/*
  Arduino camera motion
 
 A simple web server that set the angle of a PWM motor
 using an Arduino Wiznet Ethernet shield.

 created 04 Oct 2011
 by David Blaisonneau
 
 */

#include "SPI.h"
#include "Ethernet.h"
#include "WebServer.h"
#include <Servo.h>
 
/*****************************************************************************************************************
 * Configuration
 ****************************************************************************************************************/

// CHANGE THIS TO YOUR OWN UNIQUE VALUE
static uint8_t mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };

// CHANGE THIS TO MATCH YOUR HOST NETWORK
//static uint8_t ip[] = { 10, 193, 11, 249};
static uint8_t ip[] = { 192, 168, 1, 150};

#define PREFIX ""
WebServer webserver(PREFIX, 80);

//
// Pin assigment
//
int pin_ledInterne = 13;
int pin_servo_1 = 10;

/*****************************************************************************************************************
 * Global vars
 ****************************************************************************************************************/

// no-cost stream operator as described at 
// http://sundial.org/arduino/?page_id=119
template<class T>
inline Print &operator <<(Print &obj, T arg)
{ obj.print(arg); return obj; }

Servo myservo;  // create servo object to control a servo
                // a maximum of eight servo objects can be created
                
/*****************************************************************************************************************
 * WEBSERVER FUNCTIONS
 ****************************************************************************************************************/

// commands are functions that get called by the webserver framework
// they can read any posted data from client, and they output to server

void jsonCmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
  if (type == WebServer::POST)
  {
    server.httpFail();
    return;
  }

  server.httpSuccess("application/json");
  
  if (type == WebServer::HEAD)
    return;

  server << "{ to be completed }";
}

void defaultCmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
  server.httpSeeOther(PREFIX "/web");
  return;
}

void webCmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
  P(htmlHead) =
    "<html>"
    "<head>"
    "<title>Arduino Web Server</title>"
    "</head>"
    "<body>";
  server.httpSuccess();
  server.printP(htmlHead);
  server << "<H1>Hello</H1>";
  server << "<form action='" PREFIX "/ws' method='post'>";
  server.radioButton("led", "1", "On", digitalRead(pin_ledInterne));
  server.radioButton("led", "0", "Off", !digitalRead(pin_ledInterne));
  server << "<br/>";
  server << "Servo 1<input type='text' name='servo1' value='" + String(myservo.read()) + "'/></form>";
  server << "<br/>";
  server << "<input type='submit' value='Submit'/></form>";
  server << "</body></html>";
  return;
}

void webServicesCmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
  
  if (type == WebServer::POST)
  {
    bool repeat;
    char name[16], value[16];
    do
    {
      repeat = server.readPOSTparam(name, 16, value, 16);
      if ( String(name) == "led" )          { switchLed(atoi(value)); }
      else if ( String(name) == "servo1" )  { setServoAngle(atoi(value)); }
      Serial.println( String(name) + " = " + String(value));
    } while (repeat);

    server.httpSeeOther(PREFIX "/web");
  }
  
  server.httpSuccess();
  server << "<H1>Hello</H1>";
  return;
}
/*****************************************************************************************************************
 * SETUP
 ****************************************************************************************************************/
 
void setup()
{
  // Webserver
  Ethernet.begin(mac, ip);
  webserver.begin();
  webserver.setDefaultCommand(&defaultCmd);
  webserver.addCommand("json", &jsonCmd);
  webserver.addCommand("web", &webCmd);
  webserver.addCommand("ws", &webServicesCmd);
    
  // Serial init
  Serial.begin(9600);
  Serial.println("Initializing server...");
  // make sure that the default chip select pin is set to
  // output, even if you don't use it:
  pinMode(10, OUTPUT);
  
  // Pin assignment
  pinMode(pin_ledInterne, OUTPUT);
  myservo.attach(pin_servo_1);  // attaches the servo on pin 9 to the servo object
  
}

/*****************************************************************************************************************
 * LOOP
 ****************************************************************************************************************/

void loop()
{
  // process incoming connections one at a time forever
  webserver.processConnection();

  // if you wanted to do other work based on a connecton, it would go here
}

/*****************************************************************************************************************
 * CONTROL FUNCTIONS
 ****************************************************************************************************************/

void switchLed ( int value ){
  
  Serial.println("Switch led to " + String(value));
  if ( value > 0 ){
    digitalWrite(pin_ledInterne, HIGH );
  }else{
    digitalWrite(pin_ledInterne, LOW );
  }
}

int setServoAngle ( int value ) {
  Serial.println("Set servo to " + String(value));
  if ( value > -1 && value < 181 ){
    myservo.write(value);
    return 1;
  }else{
    return 0;
  }
}
