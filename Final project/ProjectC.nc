#include "Project.h"
#include "Timer.h"
#include "printf.h" 


module ProjectC @safe() {

  uses {

  /****** INTERFACES *****/

 interface Boot; 

    // interfaces for communication

    interface SplitControl;

    interface Packet;

    interface AMSend;

    interface Receive;

 // interface for timer

 // timer of 1s to send messages

 interface Timer<TMilli> as timer;

    interface Leds;

  }

} implementation {

  uint8_t arr_dim = 10;
  uint8_t mem_array[10];
  uint8_t counter_array[10];
  uint8_t prev_array[10];

  message_t packet;

  // boolean that tells the mote whether or not to check if it received message for the past 2*500 ms
  bool doControl = FALSE;
  void sendReq();
  void didReceiveTen();
  void resetNodes();
  void checkReceivedNodes();

  //***************** Send request function ********************//

  void sendReq() {

    my_msg_t* sendMessage ;

    sendMessage = (my_msg_t*)call AMSend.getPayload(&packet, sizeof(my_msg_t));

    if (sendMessage == NULL) { return; }

    sendMessage->node_id = (uint8_t)TOS_NODE_ID;

    if( call AMSend.send(AM_BROADCAST_ADDR, &packet,sizeof(my_msg_t)) == SUCCESS ){}
    else {}

  }      

   // check if we received consecutive messages from the same nodes in the past 1000 milliseconds
   // if the number in mem1 is NOT equal to the last message we received in prev1 then we did not receive consecutive messages from the node in mem1
  void checkReceivedNodes(){
    uint8_t index = 0;

    for(index = 0; index < arr_dim; index++){
      if(mem_array[index] != prev_array[index]){
        mem_array[index] = 0;
        prev_array[index] = 0;
      }
    }
  }
  // every second resets the past memory (a.k.a. memory containing the nodes which sent a message in the past 1 second)
  void resetNodes(){
    uint8_t index = 0;
    for(index = 0; index < arr_dim; index++){
        prev_array[index] = 0;
    }
  }  

  void didReceiveTen(){
    bool risk = FALSE;
    uint8_t index = 0;
    for(index = 0; index < arr_dim; index++){
      if(counter_array[index] >= 10){
        printf("You were too close to node %u for more than 5 seconds", mem_array[index]);
        printfflush();
        mem_array[index] = 0;
        prev_array[index] = 0;
        counter_array[index] = 0;
        risk = TRUE;
      }
    }

    if(risk){				
      call Leds.led0On();
      call Leds.led1On();
      call Leds.led2On();		
    } else {
      call Leds.led0Off();
      call Leds.led1Off();
      call Leds.led2Off();
    }
  }

  //***************** Boot interface ********************//

  event void Boot.booted() {

   call SplitControl.start();

  }

  //***************** SplitControl interface ********************//

  event void SplitControl.startDone(error_t err){

    if(err == SUCCESS) {
      call timer.startPeriodic( 500 );
    } else {
      call SplitControl.start();
    }

  }

  event void SplitControl.stopDone(error_t err){}

  //***************** MilliTimer interface ********************//

  event void timer.fired() {
 // send a message in broadcast with your node_id


	 sendReq();
	 didReceiveTen();
	 if(doControl){

	  // check if we received consecutive messages from the same nodes in the past 1000 milliseconds
	  checkReceivedNodes(); 
	  // reset latest nodes to all 0s
	  resetNodes();

	  doControl = FALSE;
	 } else {
	  doControl = TRUE;
	 }
	
  }

  //********************* AMSend interface ****************//

  event void AMSend.sendDone(message_t* buf,error_t err) {
  if (&packet == buf && err == SUCCESS) {} 
  else {}

  }

  //***************************** Receive interface *****************//

  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {

    if (len != sizeof(my_msg_t)) {
      return buf;
    
    } else {

      my_msg_t* mess = (my_msg_t*)payload;
      uint8_t rec_node = mess->node_id;
      bool fin = FALSE;
      uint8_t index = 0;
      /*
        WE FIRST CHECK TO SEE IF WE HAVE ALREADY RECEIVED A MESSAGE FROM NODE WITH ID `REC_NODE`
      */
      for(index = 0; index < arr_dim; index++){
        if(mem_array[index] == rec_node){
          prev_array[index] = rec_node;
          counter_array[index] = counter_array[index] + 1;
          fin = TRUE;
        }
      }

      if(fin){
        return buf;
      }

      /*
        IF WE DO NOT FIND A SLOT IN MEMORY WITH THE SAME VALUE AS THE NODE WE RECEIVED
        THEN WE SEARCH TO FIND IF THERE IS A FREE SLOT WHERE TO INITIALIZE AND SAVE THE REC_NODE ID
      */
      for(index = 0; index < arr_dim; index++){
        if(mem_array[index] == 0){
          mem_array[index] = rec_node;
          prev_array[index] = rec_node;
          counter_array[index] = 1;
          // Here should be a previous setter.
          return buf;
        }
      }


      return buf;

    }


  }

}