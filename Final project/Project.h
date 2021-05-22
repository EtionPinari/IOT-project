/**
 *  @author Luca Pietro Borsani
 */

#ifndef SENDACK_H
#define SENDACK_H

//payload of the msg
typedef nx_struct my_msg {
 	nx_uint8_t node_id;
} my_msg_t;

#define REQ 1
#define RESP 2 

enum{
AM_MY_MSG = 6,
};

#endif
