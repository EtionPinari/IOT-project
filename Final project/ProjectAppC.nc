/**
 *  Configuration file for wiring of sendAckC module to other common 
 *  components needed for proper functioning
 *
 *  @author Luca Pietro Borsani
 */

#include "Project.h"


configuration sendAckAppC {}

implementation {





/****** COMPONENTS *****/
  components MainC, ProjectC as App, LedsC;
  components new AMSenderC(AM_MY_MSG);
  components new AMReceiverC(AM_MY_MSG);
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  
  //add the other components here

/****** INTERFACES *****/
  //Boot interface
  App.Boot -> MainC.Boot;

  App.Leds -> LedsC;
  /****** Wire the other interfaces down here *****/
  //Send and Receive interfaces
  //Radio Control
  //Interfaces to access package fields
  //Timer interface
  //Fake Sensor read
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.SplitControl -> ActiveMessageC;
  App.timer -> Timer0;
  App.Packet -> AMSenderC;
  App.PacketAcknowledgements -> ActiveMessageC;

}

