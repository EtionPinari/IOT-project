#include "Project.h"
#include "printf.h"
configuration ProjectAppC {}
implementation {
/****** COMPONENTS *****/
  components MainC, ProjectC as App, LedsC;
  components new AMSenderC(AM_MY_MSG);
  components new AMReceiverC(AM_MY_MSG);
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components SerialStartC;
  components PrintfC;
  //add the other components here
/****** INTERFACES *****/
  //Boot interface
  App.Boot -> MainC.Boot;
  App.Leds -> LedsC;
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.SplitControl -> ActiveMessageC;
  App.timer -> Timer0;
  App.Packet -> AMSenderC;
}