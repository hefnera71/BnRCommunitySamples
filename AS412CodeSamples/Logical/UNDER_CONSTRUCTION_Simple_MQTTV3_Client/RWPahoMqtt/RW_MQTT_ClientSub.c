
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

/* TODO: Add your comment here */
void RW_MQTT_ClientSub(struct RW_MQTT_ClientSub* inst)
{
	int i = 0;
	inst->Q_uiState = inst->uiState;
	
	switch(inst->uiState) 
	{
		case 0: 
			if (inst->I_xEnable == 1){
				inst->uiState = 10;
			}
			//inst->I_xSubscribe = 0;
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
			; // !!! this is needed to avoid compile error with GCC 6.3 --> don't think about, just leave it as it is ;-)

			// to check later -- what's about keepAlive and will ?
			//
			MQTTPacket_connectData MQTTPacket_connectData_ = MQTTPacket_connectData_initializer;
			MQTTPacket_connectData_.MQTTVersion = 4;
			MQTTPacket_connectData_.clientID.cstring = (char*)inst->I_typParameter.sClientID;
			MQTTPacket_connectData_.username.cstring = (char*)inst->I_typParameter.sUsername;
			MQTTPacket_connectData_.password.cstring = (char*)inst->I_typParameter.sPassword;
			MQTTPacket_connectData_.cleansession = 1;		

			inst->TcpSend_0.datalen = inst->Q_iPahoFcCallResult = MQTTSerialize_connect(&inst->buffer, sizeof(inst->buffer), &MQTTPacket_connectData_);

			inst->uiState++;
			break; 

		case 31:
			inst->TcpSend_0.enable = 1;
			inst->TcpSend_0.ident = inst->TcpClient_0.ident;
			inst->TcpSend_0.pData = &inst->buffer;

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
			inst->TcpRecv_0.pData = &inst->buffer;
			inst->TcpRecv_0.datamax = sizeof(inst->buffer);
			inst->TcpRecv_0.flags = 0;
			TcpRecv(&inst->TcpRecv_0);
			if (inst->TcpRecv_0.status == ERR_OK) {
				if (inst->TcpRecv_0.recvlen>0) {
					inst->Q_xConnected = inst->Q_iPahoFcCallResult = MQTTDeserialize_connack(
						&inst->Internal.sessionPresent, 
						&inst->Internal.connack_rc, 
						&inst->buffer, 
						inst->TcpRecv_0.recvlen
						);
					inst->uiState = 40;
					//inst->I_xSubscribe = 0;
	
					// setup timer
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
		
		// end of CONNECT
		
		// now we need 
		// subscribe
		// suback
		// .... recv ....
		
		// start subscribe
		case 40:
			if (inst->I_xEnable == 0){
				inst->uiState = 100;			
			}
			else {
				if (inst->I_xSubscribe == 1){

					// do not reset, use for unsubscribe later
					//inst->I_xSubscribe = 0;
					
					MQTTString topicName[rwmqtt_MAXINDEX_SUBSTOPIC+1] = MQTTString_initializer;
					int qos[rwmqtt_MAXINDEX_SUBSTOPIC+1];
					
					int topicCount = inst->I_typSubscribe.TopicArrayCount;
					if (topicCount > rwmqtt_MAXINDEX_SUBSTOPIC+1) topicCount = rwmqtt_MAXINDEX_SUBSTOPIC+1;
					
					for (i = 0; i < topicCount; i++)
					{
						topicName[i].cstring = (char*)inst->I_typSubscribe.TopicArray[i];
						qos[i] = 0;
					}
		
					inst->TcpSend_0.datalen = inst->Q_iPahoFcCallResult = MQTTSerialize_subscribe(
						&inst->buffer, 
						sizeof(inst->buffer), 
						0, 
						4712, 
						topicCount,
						topicName,
						qos
						);
					inst->uiState++;					
				}
				else
				{
					if (callPingTimer(&inst->TON_10ms_0) == 1)
					{
						// do ping
						inst->uiStateNext = inst->uiState;
						inst->uiState = 90;
					}
				}
				
			}
			break;

		// send subscribe request
		case 41:	
			inst->TcpSend_0.enable = 1;
			inst->TcpSend_0.ident = inst->TcpClient_0.ident;
			inst->TcpSend_0.pData = &inst->buffer;

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


		// get subscribe ack 
		case 42:
			if (inst->I_xEnable == 0){
				inst->uiState = 100;
			}
			else {
				inst->TcpRecv_0.enable = 1;
				inst->TcpRecv_0.ident =  inst->TcpClient_0.ident;
				inst->TcpRecv_0.pData = &inst->buffer;
				inst->TcpRecv_0.datamax = sizeof(inst->buffer);
				inst->TcpRecv_0.flags = 0;
				TcpRecv(&inst->TcpRecv_0);
			
				if (inst->TcpRecv_0.status == ERR_OK) {
					if (inst->TcpRecv_0.recvlen>0) {
						unsigned char count;
						unsigned char dup; 
						unsigned short packetid;
						int grantedQoS[1];
	
						inst->Q_iPahoFcCallResult = MQTTDeserialize_suback(
							&packetid,
							1,
							&count,
							grantedQoS,
							&inst->buffer, 
							inst->TcpRecv_0.recvlen
							);						
						inst->uiState = 50;
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

			}

			break;

		// receive subscription data
		case 50:
			if (inst->I_xEnable == 0){
				inst->uiState = 100;
			}
			else
			{
				if (inst->I_xSubscribe == 1)
				{
					inst->TcpRecv_0.enable = 1;
					inst->TcpRecv_0.ident =  inst->TcpClient_0.ident;
					inst->TcpRecv_0.pData = &inst->buffer;
					inst->TcpRecv_0.datamax = sizeof(inst->buffer);
					inst->TcpRecv_0.flags = 0;
					TcpRecv(&inst->TcpRecv_0);
	
					if (inst->TcpRecv_0.status == ERR_OK) {
						if (inst->TcpRecv_0.recvlen>0) {

							unsigned char count;
							unsigned char dup; 
							unsigned char retained; 
							unsigned short packetid;
							unsigned int qos;
							unsigned int payloadLen;
							char* pPayload;
							MQTTString topicName = MQTTString_initializer;

							int result = inst->Q_iPahoFcCallResult = MQTTDeserialize_publish(
								&dup,
								&qos,
								&retained,
								&packetid,
								&topicName,
								&pPayload,
								&payloadLen,
								(char*)inst->buffer,
								inst->TcpRecv_0.recvlen
								);
					
							if (result >= 0)
							{
								inst->I_typSubscribe.ReceiveCount++;
								inst->I_typSubscribe.ReceiveState = 0;
							
								// copy topic
								if (topicName.lenstring.len > 0 && topicName.lenstring.len < sizeof(inst->I_typSubscribe.ReceivedTopic))
								{
									memcpy(inst->I_typSubscribe.ReceivedTopic, topicName.lenstring.data, topicName.lenstring.len);
									memset(inst->I_typSubscribe.ReceivedTopic + topicName.lenstring.len, 0, 1);
								}
								else
								{
									// todo: error handling if buffer too small
									inst->I_typSubscribe.ReceiveState = -1;
								}
							
								// copy payload
								if (payloadLen < inst->I_typSubscribe.ContentBufferSize)
								{
									memcpy(inst->I_typSubscribe.ContentBuffer, pPayload, payloadLen);
									memset(inst->I_typSubscribe.ContentBuffer + payloadLen, 0, 1);
								}
								else
								{
									// todo: error handling if buffer too small
									inst->I_typSubscribe.ReceiveState = -2;
								}
							}
							inst->uiState = 50;
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
							else
							{
								if (callPingTimer(&inst->TON_10ms_0) == 1)
								{
									// do ping
									inst->uiStateNext = inst->uiState;
									inst->uiState = 90;
								}
							}
						}
					}
					break;

				}
				else
				{
					//unsubscribe
					inst->uiState = 60;
					inst->I_typSubscribe.ReceiveCount = 0;
					memset(inst->I_typSubscribe.ReceivedTopic, 0, 1);
				}
			}

			break;

		// prepare unsubscribe packet
		case 60:
			; // !!! this is needed to avoid compile error with GCC 6.3 --> don't think about, just leave it as it is ;-)

			MQTTString topicName[rwmqtt_MAXINDEX_SUBSTOPIC+1] = MQTTString_initializer;
			int qos[rwmqtt_MAXINDEX_SUBSTOPIC+1];
					
			int topicCount = inst->I_typSubscribe.TopicArrayCount;
			if (topicCount > rwmqtt_MAXINDEX_SUBSTOPIC+1) topicCount = rwmqtt_MAXINDEX_SUBSTOPIC+1;
					
			for (i = 0; i < topicCount; i++)
			{
				topicName[i].cstring = (char*)inst->I_typSubscribe.TopicArray[i];
				qos[i] = 0;
			}
			
			inst->TcpSend_0.datalen = inst->Q_iPahoFcCallResult = MQTTSerialize_unsubscribe(
				&inst->buffer, 
				sizeof(inst->buffer), 
				0, 
				4713, 
				topicCount, 
				topicName
				);
			inst->uiState++;					
			break;
		
		// send unsubscribe
		case 61:
			inst->TcpSend_0.enable = 1;
			inst->TcpSend_0.ident = inst->TcpClient_0.ident;
			inst->TcpSend_0.pData = &inst->buffer;

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
		
		// wait for unsubscribe response
		case 62:
			inst->TcpRecv_0.enable = 1;
			inst->TcpRecv_0.ident =  inst->TcpClient_0.ident;
			inst->TcpRecv_0.pData = &inst->buffer;
			inst->TcpRecv_0.datamax = sizeof(inst->buffer);
			inst->TcpRecv_0.flags = 0;
			TcpRecv(&inst->TcpRecv_0);
			if (inst->TcpRecv_0.status == ERR_OK) {
				if (inst->TcpRecv_0.recvlen>0)
				{
					unsigned short packetid;
					int result = inst->Q_iPahoFcCallResult = MQTTDeserialize_unsuback(
						&packetid,
						&inst->buffer, 
						inst->TcpRecv_0.recvlen
						);						
					// back to start subcribe
					inst->uiState = 40;
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

		//  ping
		case 90:
			inst->TcpSend_0.datalen = inst->Q_iPahoFcCallResult = MQTTSerialize_pingreq(		
				&inst->buffer, 
				sizeof(inst->buffer)
				);
			inst->uiState++;
			break; 

		case 91:
			inst->TcpSend_0.enable = 1;
			inst->TcpSend_0.ident = inst->TcpClient_0.ident;
			inst->TcpSend_0.pData = &inst->buffer;

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
			inst->TcpRecv_0.pData = &inst->buffer;
			inst->TcpRecv_0.datamax = sizeof(inst->buffer);
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
						&inst->buffer, 
						inst->TcpRecv_0.recvlen
						);			
					// back to recv
					inst->uiState = inst->uiStateNext;

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
			inst->TcpSend_0.datalen = inst->Q_iPahoFcCallResult = MQTTSerialize_disconnect(
				&inst->buffer, 
				sizeof(inst->buffer)
				);
			inst->Q_xConnected = 0;
			inst->uiState++;
			break; 

		case 101:
			inst->TcpSend_0.enable = 1;
			inst->TcpSend_0.ident = inst->TcpClient_0.ident;
			inst->TcpSend_0.pData = &inst->buffer;

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

int callPingTimer(struct TON_10ms* t)
{
	TON_10ms(t);
	return (int)t->Q;
}

void restartPingTimer(struct TON_10ms* t)
{
	t->IN = 0;
	TON_10ms(t);
	t->IN = 1;
	TON_10ms(t);
}