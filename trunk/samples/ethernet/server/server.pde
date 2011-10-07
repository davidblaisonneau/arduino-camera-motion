#include <Ethernet.h>
#include <SPI.h>

/*******************************************************
 * Play with ethernet shield
 *******************************************************/
 
/*
 * Initialisation des variables
 */

//// Ethernet/IP configuration

// the media access control (ethernet hardware) address for the shield:
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };  
//the IP address for the shield:
//byte ip[] = { 10, 193, 11, 230};    
byte ip[] = { 192, 168, 1, 200};      
// the router's gateway address:
//byte gateway[] = { 10, 193, 11, 1};    
byte gateway[] = { 192, 168, 1, 1};    
// the subnet:
byte subnet[] = { 255, 255, 255, 0 };

// telnet defaults to port 23
Server server = Server(23);
String txtMsg = "";                         // a string for incoming text
boolean gotAMessage = false;

/*
 * Setup
 */
void setup(){
  Serial.begin(9600); 
  // initialize the ethernet device
  Ethernet.begin(mac, ip, gateway, subnet);
  
  // start listening for clients
  server.begin();
  Serial.println(">>>>>>>> START <<<<<<<<<<");
}

/*
 * Loop
 */
 
void loop()
{
  
  // wait for a new client:
  Client client = server.available();
 
  if ( txtMsg != "" ){
    Serial.print("Received: ");
    Serial.println(txtMsg);
    client.println("Message received\n");
    txtMsg = "";
  }
 
  // when the client sends the first byte, say hello:
  if (client) {
    if (!gotAMessage) {
      Serial.println("We have a new client");
      client.println("Hello, client!");
      gotAMessage = true;
    }
   
    // read the bytes incoming from the client
    char thisChar = client.read();
    //client.println(thisChar,HEX);

    while ( int(thisChar) != 10 ){
      txtMsg += thisChar;
      char thisChar = client.read();
    }
    client.println(txtMsg);
  }
}
