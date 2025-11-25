
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif
#include "RWPahoMqtt.h"
#ifdef __cplusplus
	};
#endif

#include "MQTTPacket/MQTTPacket.h"
#include "MQTTPacket/MQTTConnect.h"

#include <RWPahoMqtt.h>
#include <AsBrStr.h>
USINT buffer[rwmqtt_INTERNAL_BUFFER_SIZE];

/* TODO: Add your comment here */
void RW_MQTT_ClientPub(struct RW_MQTT_ClientPub* inst)
{
	
	inst->Q_uiState = inst->uiState;

	switch(inst->uiState) 
	{
		case 0: 
			if (inst->I_xEnable == 1){
				inst->uiState = 10;
				brsmemset(&buffer, 0, sizeof(buffer));
			}
			inst->I_xPublish = 0;
			break;

		case 10:
			inst->TcpOpen_0.enable = 1 ;
			inst->TcpOpen_0.pIfAddr = 0;
			inst->TcpOpen_0.port = 0;
			inst->TcpOpen_0.options = 0;
			TcpOpen(&inst->TcpOpen_0);

			if (inst->TcpOpen_0.status == ERR_OK) {
				inst->uiState = 20;
			}
			else if (inst->TcpOpen_0.status < ERR_FUB_BUSY) {
				inst->Internal.errorstate = inst->uiState;
				inst->Internal.errornumber = inst->TcpOpen_0.status;
				inst->uiState = 1000;
			}
			break;

		case 20:
			inst->TcpClient_0.enable = 1;
			inst->TcpClient_0.ident = inst->TcpOpen_0.ident;
			inst->TcpClient_0.pServer = inst->I_typParameter.sServerUri;
			inst->TcpClient_0.portserv = inst->I_typParameter.uiPort;
			TcpClient(&inst->TcpClient_0);
			if (inst->TcpClient_0.status == ERR_OK) {
				inst->uiState = 30;
			}
			else if (inst->TcpClient_0.status < ERR_FUB_BUSY) {
				inst->Internal.errorstate = inst->uiState;
				inst->Internal.errornumber = inst->TcpClient_0.status;
				inst->uiState = 1000;
			}
			break;;

		case 30:
			;
			MQTTPacket_connectData MQTTPacket_connectData_ = MQTTPacket_connectData_initializer;
			MQTTPacket_connectData_.MQTTVersion = 4;
			MQTTPacket_connectData_.clientID.cstring = (char*)inst->I_typParameter.sClientID;
			MQTTPacket_connectData_.username.cstring = (char*)inst->I_typParameter.sUsername;
			MQTTPacket_connectData_.password.cstring = (char*)inst->I_typParameter.sPassword;
			MQTTPacket_connectData_.cleansession = 1;		

			inst->TcpSend_0.datalen = inst->Q_iPahoFcCallResult = MQTTSerialize_connect(&buffer, sizeof(buffer), &MQTTPacket_connectData_);

			inst->uiState++;
			break; 

		case 31:
			inst->TcpSend_0.enable = 1;
			inst->TcpSend_0.ident = inst->TcpClient_0.ident;
			inst->TcpSend_0.pData = &buffer;

			inst->TcpSend_0.flags = 0;
			TcpSend(&inst->TcpSend_0);	 

			if (inst->TcpSend_0.status == ERR_OK) {
				inst->uiState++;
			}
			else if (inst->TcpSend_0.status < ERR_FUB_BUSY) {
				inst->Internal.errorstate = inst->uiState;
				inst->Internal.errornumber = inst->TcpSend_0.status;
				inst->uiState = 1000;
			}
		
			break;

		case 32:
			inst->TcpRecv_0.enable = 1;
			inst->TcpRecv_0.ident =  inst->TcpClient_0.ident;
			inst->TcpRecv_0.pData = &buffer;
			inst->TcpRecv_0.datamax = sizeof(buffer);
			inst->TcpRecv_0.flags = 0;
			TcpRecv(&inst->TcpRecv_0);
			if (inst->TcpRecv_0.status == ERR_OK) {
				if (inst->TcpRecv_0.recvlen>0) {
					inst->Q_xConnected = inst->Q_iPahoFcCallResult = MQTTDeserialize_connack(
						&inst->Internal.sessionPresent, 
						&inst->Internal.connack_rc, 
						&buffer, 
						inst->TcpRecv_0.recvlen
						);
					inst->uiState = 40;
					inst->I_xPublish = 0;

					// setup ping timer
					inst->TON_10ms_0.IN = 1;
					inst->TON_10ms_0.PT = 1000;
				}
				else
				{
					// socket closed by peer
					inst->Internal.errorstate = inst->uiState;
					inst->Internal.errornumber = 1;
					inst->uiState = 1000;
				}
			}
			else
			{
				if (inst->TcpRecv_0.status < ERR_FUB_BUSY)
				{
					if (inst->TcpRecv_0.status != tcpERR_NO_DATA)
					{
						inst->Internal.errorstate = inst->uiState;
						inst->Internal.errornumber = inst->TcpRecv_0.status;
						inst->uiState = 1000;
					}
				}
			}
			break;

			break;
		

		case 40:
			if (inst->I_xEnable == 0){
				inst->uiState = 100;			
			}
			else {
				if (inst->I_xPublish == 1){
					inst->I_xPublish = 0;
					// reset timer
					restartPingTimer(&inst->TON_10ms_0);					

					MQTTString topicName = MQTTString_initializer;
					topicName.cstring = inst->I_typPublish.Topic;
		
					inst->TcpSend_0.datalen = inst->Q_iPahoFcCallResult = MQTTSerialize_publish(
						buffer, 
						sizeof(buffer), 
						0, 
						0, 
						0, 
						4711,
						topicName, 
						inst->I_typPublish.Buffer, 
						inst->I_typPublish.BufferLength
						);
					inst->uiState++;					
				}
				else
				{
					if (callPingTimer(&inst->TON_10ms_0) == 1)
					{
						// start ping
						inst->uiState = 90;
					}
				}
			}
			break;


		case 41:	
			inst->TcpSend_0.enable = 1;
			inst->TcpSend_0.ident = inst->TcpClient_0.ident;
			inst->TcpSend_0.pData = &buffer;

			inst->TcpSend_0.flags = 0;
			TcpSend(&inst->TcpSend_0);	 

			if (inst->TcpSend_0.status == ERR_OK) {
				// we do not get reply from test.mosquitto.org - why? not sure by now ...
				// so after successful send, go straight back
				//inst->uiState++;
				inst->uiState = 40;
			}
			else if (inst->TcpSend_0.status < ERR_FUB_BUSY) {
				inst->Internal.errorstate = inst->uiState;
				inst->Internal.errornumber = inst->TcpSend_0.status;
				inst->uiState = 1000;
			}			
		
			break;

		//  ping
		case 90:
			inst->TcpSend_0.datalen = inst->Q_iPahoFcCallResult = MQTTSerialize_pingreq(		
				&buffer, 
				sizeof(buffer)
				);
			inst->uiState++;
			break; 

		case 91:
			inst->TcpSend_0.enable = 1;
			inst->TcpSend_0.ident = inst->TcpClient_0.ident;
			inst->TcpSend_0.pData = &buffer;

			inst->TcpSend_0.flags = 0;
			TcpSend(&inst->TcpSend_0);	 

			if (inst->TcpSend_0.status == ERR_OK) {
				inst->uiState++;
			}
			else if (inst->TcpSend_0.status < ERR_FUB_BUSY) {
				inst->Internal.errorstate = inst->uiState;
				inst->Internal.errornumber = inst->TcpSend_0.status;
				inst->uiState = 1000;
			}			
		
			break;	
		
		case 92:
			inst->TcpRecv_0.enable = 1;
			inst->TcpRecv_0.ident =  inst->TcpClient_0.ident;
			inst->TcpRecv_0.pData = &buffer;
			inst->TcpRecv_0.datamax = sizeof(buffer);
			inst->TcpRecv_0.flags = 0;
			TcpRecv(&inst->TcpRecv_0);
			if (inst->TcpRecv_0.status == ERR_OK) {
				if (inst->TcpRecv_0.recvlen>0)
				{
					unsigned char packettype;
					unsigned char dup;
					unsigned short packetId;
			
					int result = inst->Q_iPahoFcCallResult = MQTTDeserialize_ack(
						&packettype,
						&dup,
						&packetId,
						&buffer, 
						inst->TcpRecv_0.recvlen
						);			
					// back to recv
					inst->uiState = 40;

					// reset timer
					restartPingTimer(&inst->TON_10ms_0);
				}
				else
				{
					// socket closed by peer
					inst->Internal.errorstate = inst->uiState;
					inst->Internal.errornumber = 1;
					inst->uiState = 1000;
				}
			}
			else
			{
				if (inst->TcpRecv_0.status < ERR_FUB_BUSY)
				{
					if (inst->TcpRecv_0.status != tcpERR_NO_DATA)
					{
						inst->Internal.errorstate = inst->uiState;
						inst->Internal.errornumber = inst->TcpRecv_0.status;
						inst->uiState = 1000;
					}
				}
			}
			break;

		// end of ping

		case 100:
			inst->TcpSend_0.datalen = MQTTSerialize_disconnect(
				&buffer, 
				sizeof(buffer)
				);
			inst->Q_xConnected = 0;
			inst->uiState++;
			break; 

		case 101:
			inst->TcpSend_0.enable = 1;
			inst->TcpSend_0.ident = inst->TcpClient_0.ident;
			inst->TcpSend_0.pData = &buffer;

			inst->TcpSend_0.flags = 0;
			TcpSend(&inst->TcpSend_0);	 

			if (inst->TcpSend_0.status == ERR_OK) {
				inst->uiState++;
			}
			else if (inst->TcpSend_0.status < ERR_FUB_BUSY) {
				inst->Internal.errorstate = inst->uiState;
				inst->uiState = 1000;
			}			
		
			break;	

		case 102:
			inst->TcpClose_0.enable = 1;
			inst->TcpClose_0.ident = inst->TcpOpen_0.ident;
			inst->TcpClose_0.how = tcpSHUT_RD | tcpSHUT_WR;
			TcpClose(&inst->TcpClose_0);

			if (inst->TcpClose_0.status < ERR_FUB_BUSY) {
				inst->uiState = 0;
			}
			break;



		case 1000:
		
			inst->uiState = 1010;
			inst->Q_xConnected = 0;
			break;

		case 1010:
			inst->TcpClose_0.enable = 1;
			inst->TcpClose_0.ident = inst->TcpOpen_0.ident;
			inst->TcpClose_0.how = tcpSHUT_RD | tcpSHUT_WR;
			TcpClose(&inst->TcpClose_0);

			if (inst->TcpClose_0.status < ERR_FUB_BUSY) {
				inst->uiState = 0;
			}
			break;
	}
}
