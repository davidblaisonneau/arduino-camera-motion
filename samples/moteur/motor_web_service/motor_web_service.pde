/*
  Web  Server
 
 A simple web server that set the angle of a PWM motor
 using an Arduino Wiznet Ethernet shield.
 
 Circuit:
 * Ethernet shield attached to pins 10, 11, 12, 13
 * PWM output to pin 9
 
 created 04 Oct 2011
 by David Blaisonneau
 
 inspired by Web server from David A. Mellis and Tom Igoe
 
 */

#include <SPI.h>
#include <Ethernet.h>
#include <Servo.h>
 
Servo myservo;  // create servo object to control a servo
                // a maximum of eight servo objects can be created
 

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xEF };
//byte ip[] = { 10 ,193 ,11 , 249 };
byte ip[] = { 192, 168, 1 ,151 };

String paramName = "servo1";
int LedInterne = 13;
int delai = 1000;
String readString;

// Initialize the Ethernet server library
// with the IP address and port you want to use
// (port 80 is default for HTTP):
Server server(80);

void setup()
{
  // start the Ethernet connection and the server:
  Ethernet.begin(mac, ip);
  Serial.begin(9600);
  Serial.print("Initializing server...");
  // make sure that the default chip select pin is set to
  // output, even if you don't use it:
  pinMode(10, OUTPUT);       
  server.begin();
  pinMode(LedInterne, OUTPUT);
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
}

void loop()
{
  // listen for incoming clients
  Client client = server.available();
  if (client) {
    Serial.print("New client\n");
    readString = "";
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        if (readString.length() < 100){
          readString += c; //replaces readString.append(c);
        }        
        Serial.print(c);
        
        if (c == '\r') {
          Serial.print ( "\nAnalyse "+ readString + "\n" );
          String params = analyseURL ( readString );
          if ( params == "" ){
            sendHTTPResponse ( client, "204 No Content", "No parameters" );
            break;
          }
          String value = getParamValue ( params + "&", paramName  );
          Serial.print ( paramName +" = "+ value + "\n" );
          if ( setServoAngle(stringToInt(value)) ){
            sendHTTPResponse ( client, "200 OK", "Done" );
            break;
          }else{
            sendHTTPResponse ( client, "400 Bad Request", "Bad "+ paramName +" value" );
            break;
          }
        }
      }
    }
    // give the web browser time to receive the data
    delay(1);
    // close the connection:
    client.stop();
  }
}

void sendHTTPResponse ( Client client, String error, String message ){
  client.println("HTTP/1.1 "+ error);
  client.println("Content-Type: text");
  client.println();

  // output the value of each analog input pin
  client.print(message);
}

String analyseURL ( String request ){
  int params_index = request.indexOf("?");
  if ( params_index < 0 ){
    return "";
  }else{
    request = request.substring( params_index+1 );
    int params_end_index = request.indexOf(" ");
    return request.substring( 0, params_end_index );
  }
}

String getParamValue ( String request, String param ){
  int param_index = request.indexOf( param + "=");
  int param_end_index = request.indexOf( "&" , param_index );
  //Serial.print(request + "\n");
  //Serial.print("From " + String(param_index + param.length() + 1) + " to " + String(param_end_index) + "\n");
  if ( param_index < 0 && param_index < 0  ) {
    return "";
  }else{
    return request.substring( param_index + param.length() + 1, param_end_index );
  }
}

void switchLed ( int value ){
  if ( value > 0 ){
    digitalWrite(LedInterne, HIGH );
  }else{
    digitalWrite(LedInterne, LOW );
  }
}

int setServoAngle ( int value ) {
  if ( value > -1 && value < 181 ){
    myservo.write(value);
    return 1;
  }else{
    return 0;
  }
}

int stringToInt ( String str ){
  Serial.print("stringToInt("+ str +"["+ str.length() +"])=" );
  char str_as_char[str.length()+1];
  str.toCharArray( str_as_char, str.length()+1  );
  Serial.println( str_as_char );
  return atoi( str_as_char );
}
