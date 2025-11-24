
TYPE
	typRW_MQTT_Subscribe : 	STRUCT 
		TopicArray : ARRAY[0..rwmqtt_MAXINDEX_SUBSTOPIC]OF STRING[255]; (*topic names to subscribe*)
		TopicArrayCount : USINT; (*number of topics to use out of the TopicArray (no empty topics are allowed inside the chossen area)*)
		ReceiveCount : UINT; (*number of received topics, can be used as "new topic arrived signal"*)
		ReceiveState : INT; (*internal state*)
		ReceivedTopic : STRING[255]; (*name of topic received*)
		ContentBuffer : UDINT; (*address of the buffer where content should be copied to*)
		ContentBufferSize : UDINT; (*size of the buffer*)
	END_STRUCT;
	typRW_MQTT_Publish : 	STRUCT 
		Topic : STRING[80]; (*topic names to publish*)
		Buffer : UDINT; (*address of the buffer with the topic content*)
		BufferLength : UDINT; (*length of the content data*)
	END_STRUCT;
	typRW_MQTT_Internal : 	STRUCT 
		connack_rc : USINT;
		sessionPresent : USINT;
		errorstate : UINT;
		errornumber : UINT;
	END_STRUCT;
	typRW_MQTT_Param : 	STRUCT 
		sClientID : STRING[80];
		sUsername : STRING[80];
		sPassword : STRING[80];
		sServerUri : STRING[80];
		uiPort : UINT;
	END_STRUCT;
END_TYPE
