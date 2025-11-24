
PROGRAM _INIT
	(* Insert code here *)

	// storage for broker name
	sBrokerDnsName := 'test.mosquitto.org';
	// storage for ip address
	sBrokerIpAddress := '';
	
	// setup publish instance
	sPubBaseTopic := 'RWmqtt/Test/';
	
	sPubBuffer := DT_TO_STRING(DTGetTime_0.DT1);
	RW_MQTT_Client_Pub.I_typPublish.Buffer         := ADR(sPubBuffer);
	RW_MQTT_Client_Pub.I_typPublish.BufferLength   := brsstrlen(ADR(sPubBuffer));
	RW_MQTT_Client_Pub.I_typPublish.Topic := ''; // the topic is defined later in the test sequence
	
	RW_MQTT_Client_Pub.I_typParameter.sClientID := 'X20_RWmqttPub';
	RW_MQTT_Client_Pub.I_typParameter.sServerUri :=''; 	// here, an ip address is needed !! - the address is determined later
	RW_MQTT_Client_Pub.I_typParameter.uiPort := 1883;				
	RW_MQTT_Client_Pub.I_typParameter.sUsername := '';
	RW_MQTT_Client_Pub.I_typParameter.sPassword := '';


	// setup subscribe instance
	//RW_MQTT_Client_Sub.I_typSubscribe.TopicArrayCount := 1;
	//RW_MQTT_Client_Sub.I_typSubscribe.TopicArray[0] := 'RWmqtt/Test/#';

	RW_MQTT_Client_Sub.I_typSubscribe.TopicArrayCount := 4;
	RW_MQTT_Client_Sub.I_typSubscribe.TopicArray[0] := 'RWmqtt/Test/1';
	RW_MQTT_Client_Sub.I_typSubscribe.TopicArray[1] := 'RWmqtt/Test/3';
	RW_MQTT_Client_Sub.I_typSubscribe.TopicArray[2] := 'RWmqtt/Test/7';
	RW_MQTT_Client_Sub.I_typSubscribe.TopicArray[3] := 'RWmqtt/+/8';
	
	RW_MQTT_Client_Sub.I_typParameter.sClientID := 'X20_RWmqttSub';
	RW_MQTT_Client_Sub.I_typParameter.sServerUri := ''; 	// here, an ip address is needed !! - the address is determined later
	RW_MQTT_Client_Sub.I_typParameter.uiPort := 1883;
	RW_MQTT_Client_Sub.I_typParameter.sUsername := '';
	RW_MQTT_Client_Sub.I_typParameter.sPassword := '';

	RW_MQTT_Client_Sub.I_typSubscribe.ContentBuffer := ADR(sSubBuffer);
	RW_MQTT_Client_Sub.I_typSubscribe.ContentBufferSize := SIZEOF(sSubBuffer);

	// start automatic publishing
	TON_0.PT := T#10s;
	//xPublish := TRUE;
	
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	
	
	CASE testrunStep OF
	
		1: // determine broker IP address first before going on - we need a broker ip address for the mqtt lib to use
			
			// be aware that you have to have DNS client enabled and configured!!!
			HostByName_0(enable := TRUE, pName := ADR(sBrokerDnsName));
			IF HostByName_0.status <> 16#FFFF THEN
				IF HostByName_0.status = 0 THEN
					IF ethInetNtoa(HostByName_0.address, ADR(sBrokerIpAddress)) <> 0 THEN
						// if status <> 0, address cannot be converted, so it's invalid!
						sBrokerIpAddress := '';
						testrunStep := 99;
					ELSE
						// address was converted and is available in sBrokerIpAddress
						RW_MQTT_Client_Sub.I_typParameter.sServerUri := sBrokerIpAddress;
						RW_MQTT_Client_Pub.I_typParameter.sServerUri := sBrokerIpAddress;
						
						// enable functions
						RW_MQTT_Client_Pub.I_xEnable := TRUE;

						RW_MQTT_Client_Sub.I_xEnable := TRUE;
						RW_MQTT_Client_Sub.I_xSubscribe := TRUE;
						
						// start auto publish sequence
						xPublish := TRUE;

						// proceed with mqtt testing routine
						testrunStep := 2;
					END_IF
				ELSE
					// error! Cannot resolve IP address
					testrunStep := 99;
				END_IF
				HostByName_0(enable := FALSE);
			END_IF

	
		2: // stay here "forever" - testing routinge for publish / subscribe
			
			IF RW_MQTT_Client_Pub.Q_xConnected AND xPublish THEN
		
				// create changing test topic
				// only some of these topics are subscribed - this is for test to see, if the sobscriptions are working as expected!!
				iPubTopicCounter := iPubTopicCounter + 1;
				IF iPubTopicCounter > 9 THEN
					iPubTopicCounter := 0;
				END_IF
				sPubSubTopic := USINT_TO_STRING(iPubTopicCounter);
				
				// define the topic
				brsstrcpy(ADR(RW_MQTT_Client_Pub.I_typPublish.Topic), ADR(sPubBaseTopic));
				brsstrcat(ADR(RW_MQTT_Client_Pub.I_typPublish.Topic), ADR(sPubSubTopic));
		
				// create some changing test data content
				DTGetTime_0(enable := 1);
				sPubBuffer := DT_TO_STRING(DTGetTime_0.DT1);
				RW_MQTT_Client_Pub.I_typPublish.Buffer         := ADR(sPubBuffer);
				RW_MQTT_Client_Pub.I_typPublish.BufferLength   := brsstrlen(ADR(sPubBuffer));
				
				// enable publishing
				RW_MQTT_Client_Pub.I_xPublish := RW_MQTT_Client_Pub.I_xEnable;
				xPublish := FALSE;
				
				// start timer until next publish
				TON_0.IN := TRUE;
		
			END_IF	

			// call publishing instance
			RW_MQTT_Client_Pub();
			
			// publishing timer handling
			TON_0();
			IF TON_0.Q THEN
				TON_0(IN := FALSE);
				xPublish := TRUE;
			END_IF
			 
			
		 	// call subsciption instance
			RW_MQTT_Client_Sub();

	END_CASE

	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

