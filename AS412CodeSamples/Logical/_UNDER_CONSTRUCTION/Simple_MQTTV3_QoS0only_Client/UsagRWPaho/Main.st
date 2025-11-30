
PROGRAM _INIT

	
	//
	// setting up the publishing instance
	//
	sPublishContent := 'Hello MQTT world!'; // my mqtt content to publish
	RW_MQTT_ClientPub_0.I_typParameter.sClientID := 'RWTestClientPublish';
	RW_MQTT_ClientPub_0.I_typParameter.sServerUri := 'broker.hivemq.com';
	RW_MQTT_ClientPub_0.I_typParameter.uiPort := 1883;
	RW_MQTT_ClientPub_0.I_typPublish.Topic := 'RWmqtt/TopicTest/myData'; // name of the topic to publish
	RW_MQTT_ClientPub_0.I_typPublish.Buffer := ADR(sPublishContent); // the content to publish
	RW_MQTT_ClientPub_0.I_typPublish.BufferLength := brsstrlen(ADR(sPublishContent)); // the length of the content
	RW_MQTT_ClientPub_0.I_xEnable := TRUE;  // enable the fb -> the client will try to connect to the broker

	//
	// setting up the subscibing instance
	//
	RW_MQTT_ClientSub_0.I_typParameter.sClientID := 'RWTestClientSubscribe';
	RW_MQTT_ClientSub_0.I_typParameter.sServerUri := 'broker.hivemq.com';
	RW_MQTT_ClientSub_0.I_typParameter.uiPort := 1883;
	
	RW_MQTT_ClientSub_0.I_typSubscribe.TopicArrayCount := 1; // how much different topics we want to subscribe? Max. 5 are possible
	RW_MQTT_ClientSub_0.I_typSubscribe.TopicArray[0] := 'RWmqtt/TopicTest/myData'; // name of the topic to subscribe
	RW_MQTT_ClientSub_0.I_typSubscribe.ContentBuffer := ADR(sSubcribeContent); // the storage for received content
	RW_MQTT_ClientSub_0.I_typSubscribe.ContentBufferSize := SIZEOF(sSubcribeContent); // the maximum storage size
	RW_MQTT_ClientSub_0.I_xEnable := TRUE; // enable the fb -> the client will try to connect to the broker
	
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)

	// publishing
	// are we connected?
 	IF RW_MQTT_ClientPub_0.Q_xConnected = TRUE THEN
		// want to publish? set the publish command
		IF bPublish = TRUE THEN
			// update length of content to send
			RW_MQTT_ClientPub_0.I_typPublish.BufferLength := brsstrlen(ADR(sPublishContent));
			// enable publish in fb interface
			// !!! PLEASE NOTE: RW_MQTT_ClientPub_0.I_xPublish is resetted by fb internally !!
			// !!! so don't set it permanently to TURE, this would lead to permanently re-publishing ... I'm pretty sure that's not what you want to achieve!
			RW_MQTT_ClientPub_0.I_xPublish := TRUE;
			// reset my own pbulish trigger
			bPublish := FALSE;
		END_IF
	END_IF
	
	// call the fb
	RW_MQTT_ClientPub_0();

	
	// subscribing
	// are we connected?
	IF RW_MQTT_ClientSub_0.Q_xConnected = TRUE THEN
		IF bSubscribe = TRUE THEN
			RW_MQTT_ClientSub_0.I_xSubscribe := TRUE; // enable the subscription -> the fb 
			// please note - the subscription keeps active until you unsubscribe!
			// unsubscribing from an active subscription can be dine by settting .I_xSubscribe := FALSE ... then you could for example change your subscription settings, and re-enable subscribing
			bSubscribe := FALSE;
		END_IF
	END_IF
	
	// call the fb
	RW_MQTT_ClientSub_0();
	
	// if you've received somethin, you will see
	// RW_MQTT_ClientSub_0.I_typSubscribe.ReceivedTopic
	
	
END_PROGRAM

PROGRAM _EXIT

	RW_MQTT_ClientPub_0( I_xEnable := FALSE );

	RW_MQTT_ClientSub_0( I_xEnable := FALSE );
	
END_PROGRAM

