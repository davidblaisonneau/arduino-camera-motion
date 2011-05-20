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
byte ip[] = { 10, 193, 11, 230};      
// the router's gateway address:
byte gateway[] = { 10, 193, 11, 1};    
// the subnet:
byte subnet[] = { 255, 255, 255, 0 };
// Google
byte server[] = { 10, 193, 4, 48 }; // Web2000
// Initialize the Ethernet client library
// with the IP address and port of the server
// that you want to connect to (port 80 is default for HTTP):
Client client(server, 80);


/*
 * Setup
 */
void setup(){
  Serial.begin(115200); 
  // initialize the ethernet device
  Ethernet.begin(mac, ip, gateway, subnet);
  
  // give the Ethernet shield a second to initialize:
  delay(1000);
  Serial.println("connecting...");

  // if you get a connection, report back via serial:
  if (client.connect()) {
    Serial.println("connected");
    // Make a HTTP request:
    client.println("GET / HTTP/1.0");
  }
  else {
    // kf you didn't get a connection to the server:
    Serial.println("connection failed");
  }
}

/*
 * Loop
 */
 
void loop()
{
  // if there are incoming bytes available
  // from the server, read them and print them:
  if (client.available()) {
    char c = client.read();
    Serial.print(c);
  }

  // if the server's disconnected, stop the client:
  if (!client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();

    // do nothing forevermore:
    for(;;)
      ;
  }
}
