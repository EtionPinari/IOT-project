/**
 *  Source file for implementation of module sendAckC in which
 *  the node 1 send a request to node 2 until it receives a response.
 *  The reply message contains a reading from the Fake Sensor.
 *
 *  @author Luca Pietro Borsani
 */

#include "Project.h"
#include "Timer.h"
#define REQ 1
#define RESP 2 

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

	// Message received contains in msg_rec[0][x] the node_id and in msg_rec[1][x] the counter of how many messages it received in the past few seconds.(for any x)
  uint8_t message_received[2][10];
  uint8_t latest_nodes[10];
  uint8_t node_id;
  message_t packet;

  void sendReq();
  void resetNodes();
  void checkReceivedNodes();
  
  //***************** Send request function ********************//
  void sendReq() {
	my_msg_t* sendMessage ;

	sendMessage = (my_msg_t*)call AMSend.getPayload(&packet, sizeof(my_msg_t));

	  
	  if (sendMessage == NULL) {
		return;
	  }
	  sendMessage->msg_type = REQ;
	  sendMessage->msg_counter = counter;
	  sendMessage->value = 0;
	  counter = counter + 1 ;

	  
	  if(call AMSend.send(2, &packet,sizeof(my_msg_t)) == SUCCESS){

  	} else {


  	}
 }      
 		// check if we received consecutive messages from the same nodes in the past 500 milliseconds
 	void checkReceivedNodes(){
 		uint8_t index = 0;
 		while(index<10){
 			if(latest_nodes[index] != message_received[0][index]){
 				message_received[0][index] = 0;
 				message_received[1][index] = 0;
 			}
 		index = index + 1;
 		}
 	}
 
 	void resetNodes(){
 		uint8_t index = 0;
 		while(index<10){
 		latest_nodes[index] = -1;
 		index = index + 1;
 		}
 	}  



  //***************** Boot interface ********************//
  event void Boot.booted() {
	dbg("boot","Application booted.\n");
	dbg("boot","Application booted on node %u.\n", TOS_NODE_ID);
  	call SplitControl.start();
  }

  //***************** SplitControl interface ********************//
  event void SplitControl.startDone(error_t err){
    /* Fill it ... */
    if(err == SUCCESS) {
    	dbg("radio", "Radio on!\n");
	if (TOS_NODE_ID == 1){
           // send messages every 1000 ms
           call timer.startPeriodic( 1000 );
    	}
    } else {
	//dbg for error
	dbg("radio", "Something went wrong with the start of one node");
	call SplitControl.start();
    }
  }
  
  event void SplitControl.stopDone(error_t err){
    /* Fill it ... */
    // Here we define the req send back.
  }

  //***************** MilliTimer interface ********************//
  event void timer.fired() {
	// send a message in broadcast with your node_id
	
	// check if we received consecutive messages from the same nodes in the past 500 milliseconds
	checkReceivedNodes(); 
	// reset latest nodes to all -1s
	resetNodes();
  }
  

  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {

	 if (&packet == buf && err == SUCCESS) {


 	} else {
    }
  }

  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
	


	 if (len != sizeof(my_msg_t)) {

	 return buf;
	 }
    else {
          my_msg_t* mess = (my_msg_t*)payload;
    	// HERE WE UPDATE OUR INTERNAL ARRAY BY SCANNING IT AND CHECKING THE VALUES INSIDE OF IT
    	uint8_t index = 0;
    	
    	while(index<10){
    		//check all 10 indexes and if any of them is the matches then update counter
			if(message_received[0][index] == mess->node_id){	
				message_received[1][index] = message_received[1][index] + 1;
				latest_nodes[index] = mess->node_id;
				if(message_received[1][index] == 10){
				//send a message to node red through the socket (idk how)
				}
				//finish computation
				return buf;
			}
			//
			index = index + 1;
			//else if index == 11 then we have to throw an error of memory
    	}
    	index = 0 ;
    	while(index<10){
    		//else if we get to a position which has counter = 0, it means that we can store this new entry in the array
			if(message_received[1][index] == 0){
				message_received[1][index] = 1;
				message_received[0][index] = mess->node_id;
				latest_nodes[index] = mess->node_id;
				//finish computation
				return buf;
			}
    	}


	//throw error for having run out of memory
      return buf;
    }


  }
  
	
}

