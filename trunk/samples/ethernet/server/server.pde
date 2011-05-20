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

// telnet defaults to port 23
Server server = Server(23);
String str;

/*
 * Setup
 */
void setup(){
  Serial.begin(115200); 
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
  // if an incoming client connects, there will be bytes available to read:
  Client client = server.available();
  if (client == true) {
    str = client.read();
    if ( str != -1){
      Serial.print(str);
    }
  }
  
}
