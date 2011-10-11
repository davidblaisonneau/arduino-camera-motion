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
#include <SdFat.h>
#include <SdFatUtil.h>
 
/*****************************************************************************************************************
 * Configuration
 ****************************************************************************************************************/

//
// Ethernet config
//

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xEF };
byte ip[] = { 10 ,193 ,11 , 249 };
//byte ip[] = { 192, 168, 1 ,151 };
// Initialize the Ethernet server library
// with the IP address and port you want to use
// (port 80 is default for HTTP):
Server server(80);

//
// Pin assigment
//
int pin_ledInterne = 13;
int pin_servo_1 = 10;

/*****************************************************************************************************************
 * Global vars
 ****************************************************************************************************************/

String readString;

Servo myservo;  // create servo object to control a servo
                // a maximum of eight servo objects can be created
 

// Params to get
int paramQty = 2;
String paramToAnalyse[2] = { "servo1", "LED" };
String paramValues[2];


/*****************************************************************************************************************
 * SETUP
 ****************************************************************************************************************/

void setup()
{
  // start the Ethernet connection and the server:
  Ethernet.begin(mac, ip);       
  server.begin();
  
  // Serial init
  Serial.begin(9600);
  Serial.print("Initializing server...");
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
  // listen for incoming clients
  Client client = server.available();
}

/*****************************************************************************************************************
 * WEBSERVER FUNCTIONS
 ****************************************************************************************************************/

void manageClient ( Client client ){
 
  if (client) {
    Serial.print("New client\n");
    readString = "";
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        if (readString.length() < 128){
          readString += c;
        }
        if (c == '\r') {
          Serial.print ( "\nAnalyse "+ readString + "\n" );
          String params = analyseURL ( readString );
          if ( params == "" ){
            sendHTTPResponse ( client, "204 No Content", "text/html", "No parameters" );
            break;
          }
          
          String returnText = "";
          for( int cpt=0 ; cpt<paramQty ; cpt++ ){
            paramValues[cpt] = getParamValue ( params + "&", paramToAnalyse[cpt]  );
            returnText += paramToAnalyse[cpt] +" = "+ paramValues[cpt] + "\n";
            Serial.print ( paramToAnalyse[cpt] +" = "+ paramValues[cpt] + "\n" );
          }
   
          // Set LED
          switchLed(stringToInt(paramValues[1]));
          // Set servo angle
          if ( setServoAngle(stringToInt(paramValues[0])) ){
            sendHTTPResponse ( client, "200 OK", "text/html", "Done. I get values:\n"+returnText );
            break;
          }else{
            sendHTTPResponse ( client, "400 Bad Request", "text/html", "Bad "+ paramToAnalyse[0] +" value" );
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

String analyseURL ( String request ){
  String ret;
  Serial.print ( "strstr: "+ strstr(request, "GET ")  );
  int params_index = request.indexOf("?");
  if ( params_index < 0 ){
    ret = "";
  }else{
    request = request.substring( params_index+1 );
    int params_end_index = request.indexOf(" ");
    ret = request.substring( 0, params_end_index );
  }
  return ret;
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

int stringToInt ( String str ){
  //Serial.print("stringToInt("+ str +"["+ str.length() +"])=" );
  char str_as_char[str.length()+1];
  str.toCharArray( str_as_char, str.length()+1  );
  //Serial.println( str_as_char );
  return atoi( str_as_char );
}

void sendHTTPResponse ( Client client, String return_code, String type, String message ){
  client.println("HTTP/1.1 "+ return_code);
  client.println("Content-Type: " + type);
  client.println();

  // output the value of each analog input pin
  client.print(message);
}

/*****************************************************************************************************************
 * CONTROL FUNCTIONS
 ****************************************************************************************************************/

void switchLed ( int value ){
  if ( value > 0 ){
    digitalWrite(pin_ledInterne, HIGH );
  }else{
    digitalWrite(pin_ledInterne, LOW );
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
