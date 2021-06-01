#include "Project.h"
#include "Timer.h"
#include "printf.h" 

#define mem_length 5 

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

  uint8_t mem1=0;
  uint8_t counter1=0;
  uint8_t prev1=0;

  uint8_t mem2=0;
  uint8_t counter2=0;
  uint8_t prev2=0;
  
  uint8_t mem3=0;
  uint8_t counter3=0;
  uint8_t prev3=0;
  
  uint8_t mem4=0;
  uint8_t counter4=0;
  uint8_t prev4=0;
  
  uint8_t mem5=0;
  uint8_t counter5=0;
  uint8_t prev5=0;

  message_t packet;

  // boolean that tells the mote whether or not to check if it received message for the past 500 ms
  bool doControl = FALSE;
  void sendReq();
  void didReceiveTen();
  void resetNodes();
  void checkReceivedNodes();

  //***************** Send request function ********************//

  void sendReq() {

    my_msg_t* sendMessage ;

    sendMessage = (my_msg_t*)call AMSend.getPayload(&packet, sizeof(my_msg_t));

      if (sendMessage == NULL) {

      return;

      }

      sendMessage->node_id = (uint8_t)TOS_NODE_ID;

      //sendMessage->counter = counter;

      if(call AMSend.send(AM_BROADCAST_ADDR, &packet,sizeof(my_msg_t)) == SUCCESS){
        //printf("Sent message with node id %u\n", sendMessage->node_id);

        //printfflush();

        //debug to show that we are sending a message

      } else {
      
      }

  }      

   // check if we received consecutive messages from the same nodes in the past 1000 milliseconds
   // if the number in mem1 is NOT equal to the last message we received in prev1 then we did not receive consecutive messages from the node in mem1
  void checkReceivedNodes(){
    bool areEqual1, areEqual2, areEqual3, areEqual4, areEqual5;
    
    areEqual1 = (mem1 == prev1);
    areEqual2 = (mem2 == prev2);
    areEqual3 = (mem3 == prev3);
    areEqual4 = (mem4 == prev4);
    areEqual5 = (mem5 == prev5);

    if(!areEqual1){
      mem1 = 0;
      prev1 = 0;
    }
    if(!areEqual2){
      mem2 = 0;
      prev2 = 0;
    }
    if(!areEqual3){
      mem3 = 0;
      prev3 = 0;
    }
    if(!areEqual4){
      mem4 = 0;
      prev4 = 0;
    }
    if(!areEqual5){
      mem5 = 0;
      prev5 = 0;
    }
  }
  // every second resets the past memory (a.k.a. memory containing the nodes which sent a message in the past 1 second)
  void resetNodes(){
    prev1 = 0;
    prev2 = 0;
    prev3 = 0;
    prev4 = 0;
    prev5 = 0;
  }  

  void didReceiveTen(){
    bool risk = FALSE;
    if(counter1>=10){
      printf("Node #%u close to node #%u \n", TOS_NODE_ID ,mem1 );
      printfflush();
      mem1=0;
      prev1=0;
      counter1=0;
      risk = TRUE;
    }
    if(counter2>=10){
      printf("Node #%u close to node #%u \n", TOS_NODE_ID ,mem2 );
      printfflush();
      mem2=0;
      prev2=0;
      counter2=0;
      risk = TRUE;
    }
    if(counter3>=10){
      printf("Node #%u close to node #%u \n", TOS_NODE_ID ,mem3 );
      printfflush();
      mem3=0;
      prev3=0;
      counter3=0;
      risk = TRUE;
    }
    if(counter4>=10){
      printf("Node #%u close to node #%u \n", TOS_NODE_ID ,mem4);
      printfflush();
      mem4=0;
      prev4=0;
      counter4=0;
      risk = TRUE;
    }
    if(counter5>=10){
      printf("Node #%u close to node #%u \n", TOS_NODE_ID ,mem5 );
      printfflush();
      mem5=0;
      prev5=0;
      counter5=0;
      risk = TRUE;
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

  if (&packet == buf && err == SUCCESS) {

 // debug for success

  } else {

  //printf("IM HAVING PROBLEMS SENDING MSG");

    //printfflush();

    // dbg for error

    }

  }

  //***************************** Receive interface *****************//

  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {

    if (len != sizeof(my_msg_t)) {
      return buf;
    
    } else {

      my_msg_t* mess = (my_msg_t*)payload;
      uint8_t rec_node = mess->node_id;
      bool fin = FALSE;

      if(mem1 == rec_node){
        prev1 = rec_node;
        counter1 = counter1 + 1;
        fin = TRUE;
      } else if(mem2 == rec_node){
        prev2 = rec_node;
        counter2 = counter2 + 1;
        fin = TRUE;
      } else if(mem3 == rec_node){
        prev3 = rec_node;
        counter3 = counter3 + 1;
        fin = TRUE;
      } else if(mem4 == rec_node){
        prev4 = rec_node;
        counter4 = counter4 + 1;
        fin = TRUE;
      } else if(mem5 == rec_node){
        prev5 = rec_node;
        counter5 = counter5 + 1;
        fin = TRUE;
      }
      if(fin){
        return buf;
      }
      if(mem1 == 0){
        counter1 = 1;
        mem1 = rec_node;
        return buf;
      }
      if(mem2 == 0){
        counter2 = 1;
        mem2 = rec_node;
        return buf;
      }
      if(mem3 == 0){
        counter3 = 1;
        mem3 = rec_node;
        return buf;
      }
      if(mem4 == 0){
        counter4 = 1;
        mem4 = rec_node;
        return buf;
      }
      if(mem5 == 0){
        counter5 = 1;
        mem5 = rec_node;
      }

      return buf;

    }


  }

}