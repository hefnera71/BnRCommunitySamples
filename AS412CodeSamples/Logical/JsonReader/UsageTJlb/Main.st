
PROGRAM _INIT
	(* Insert code here *)
	
	// test data - derived from a Tasmota devices response to a 'status 0' request
	sTestString := '{"Status":{"Module":0,"DeviceName":"TasmotaMultimediaPower","FriendlyName":["TasmotaMultimediaPower"],"Topic":"tasmota_AABBCC","ButtonTopic":"0","Power":1,"PowerOnState":3,"LedState":1,"LedMask":"FFFF","SaveData":1,"SaveState":1,"SwitchTopic":"0","SwitchMode":[0,0,0,0,0,0,0,0],"ButtonRetain":0,"SwitchRetain":0,"SensorRetain":0,"PowerRetain":0,"InfoRetain":0,"StateRetain":0},"StatusPRM":{"Baudrate":115200,"SerialConfig":"8N1","GroupTopic":"tasmotas","OtaUrl":"http://ota.tasmota.com/tasmota/release/tasmota.bin.gz","RestartReason":"Exception","Uptime":"159T17:34:01","StartupUTC":"2025-10-26T12:04:45","Sleep":50,"CfgHolder":4617,"BootCount":22,"BCResetTime":"2021-10-06T09:31:03","SaveCount":1465,"SaveAddress":"F9000"},"StatusFWR":{"Version":"9.5.0(tasmota)","BuildDateTime":"2021-06-17T08:26:35","Boot":31,"Core":"2_7_4_9","SDK":"2.2.2-dev(38a443e)","CpuFrequency":80,"Hardware":"ESP8285","CR":"407/699"},"StatusLOG":{"SerialLog":2,"WebLog":2,"MqttLog":0,"SysLog":0,"LogHost":"","LogPort":514,"SSId":["LAN_SOLO",""],"TelePeriod":150,"Resolution":"558180C0","SetOption":["04008009","2805C8000100060000005A0A000000000000","00000080","00006000","00000000"]},"StatusMEM":{"ProgramSize":607,"Free":396,"Heap":22,"ProgramFlashSize":1024,"FlashSize":1024,"FlashChipId":"144051","FlashFrequency":40,"FlashMode":3,"Features":["00000809","8FDAC787","04368001","000000CF","010013C0","C000F981","00004004","00001000","00000020"],"Drivers":"1,2,3,4,5,6,7,8,9,10,12,16,18,19,20,21,22,24,26,27,29,30,35,37,45","Sensors":"1,2,3,4,5,6"},"StatusNET":{"Hostname":"TasmotaMultimediaPower","IPAddress":"192.168.1.107","Gateway":"192.168.1.1","Subnetmask":"255.255.255.0","DNSServer":"192.168.1.1","Mac":"70:03:9F:AA:BB:CC","Webserver":2,"WifiConfig":4,"WifiPower":17.0},"StatusMQT":{"MqttHost":"192.168.1.8","MqttPort":1883,"MqttClientMask":"DVES_%06X","MqttClient":"DVES_AABBCC","MqttUser":"DVES_USER","MqttCount":182,"MAX_PACKET_SIZE":1200,"KEEPALIVE":30,"SOCKET_TIMEOUT":4},"StatusTIM":{"UTC":"2026-04-04T05:38:46","Local":"2026-04-04T06:38:46","StartDST":"2026-03-29T02:00:00","EndDST":"2026-10-25T03:00:00","Timezone":"+01:00","Sunrise":"06:21","Sunset":"19:24"},"StatusPTH":{"PowerDelta":[0,0,0],"PowerLow":0,"PowerHigh":0,"VoltageLow":0,"VoltageHigh":0,"CurrentLow":0,"CurrentHigh":0},"StatusSNS":{"Time":"2026-04-04T06:38:46","ENERGY":{"TotalStartTime":"2021-10-06T09:31:03","Total":1098.989,"Yesterday":0.863,"Today":0.079,"Power":10,"ApparentPower":56,"ReactivePower":55,"Factor":0.18,"Voltage":240,"Current":0.234}},"StatusSTS":{"Time":"2026-04-04T06:38:46","Uptime":"159T17:34:01","UptimeSec":13800841,"Heap":20,"SleepMode":"Dynamic","Sleep":50,"LoadAvg":19,"MqttCount":182,"POWER1":"on","Wifi":{"AP":1,"SSId":"LAN_SOLO","BSSId":"01:23:45:67:89:AB","Channel":6,"Mode":"11n","RSSI":100,"Signal":-22,"LinkCount":79,"Downtime":"0T00:07:39"}},"StatusSTK":{"Exception":29,"Reason":"Exception","EPC":["4000df64","00000000","00000000"],"EXCVADDR":"00000000","DEPC":"00000000","CallChain":["4010149c","402654c3","40265458","402653ff","40264558","40264581","40261fec","4000050c","4026c5b7","4025e359","40262ce3","40000f58","40262756","4026beaf","4026b76f","40249494","40000f49","40000f49","40000e19","40105a7d","40105a83","4010000d","4026a654","4026a605","4010014c","401013d1","401013c0","401012f8","4000050c","4024f6b7","4024fd62"]}}';
	// same as sTeststring, but closing '}' is missing -> to test invalid JSON
	sTestStringWrong := '{"Status":{"Module":0,"DeviceName":"TasmotaMultimediaPower","FriendlyName":["TasmotaMultimediaPower"],"Topic":"tasmota_AABBCC","ButtonTopic":"0","Power":1,"PowerOnState":3,"LedState":1,"LedMask":"FFFF","SaveData":1,"SaveState":1,"SwitchTopic":"0","SwitchMode":[0,0,0,0,0,0,0,0],"ButtonRetain":0,"SwitchRetain":0,"SensorRetain":0,"PowerRetain":0,"InfoRetain":0,"StateRetain":0},"StatusPRM":{"Baudrate":115200,"SerialConfig":"8N1","GroupTopic":"tasmotas","OtaUrl":"http://ota.tasmota.com/tasmota/release/tasmota.bin.gz","RestartReason":"Exception","Uptime":"159T17:34:01","StartupUTC":"2025-10-26T12:04:45","Sleep":50,"CfgHolder":4617,"BootCount":22,"BCResetTime":"2021-10-06T09:31:03","SaveCount":1465,"SaveAddress":"F9000"},"StatusFWR":{"Version":"9.5.0(tasmota)","BuildDateTime":"2021-06-17T08:26:35","Boot":31,"Core":"2_7_4_9","SDK":"2.2.2-dev(38a443e)","CpuFrequency":80,"Hardware":"ESP8285","CR":"407/699"},"StatusLOG":{"SerialLog":2,"WebLog":2,"MqttLog":0,"SysLog":0,"LogHost":"","LogPort":514,"SSId":["LAN_SOLO",""],"TelePeriod":150,"Resolution":"558180C0","SetOption":["04008009","2805C8000100060000005A0A000000000000","00000080","00006000","00000000"]},"StatusMEM":{"ProgramSize":607,"Free":396,"Heap":22,"ProgramFlashSize":1024,"FlashSize":1024,"FlashChipId":"144051","FlashFrequency":40,"FlashMode":3,"Features":["00000809","8FDAC787","04368001","000000CF","010013C0","C000F981","00004004","00001000","00000020"],"Drivers":"1,2,3,4,5,6,7,8,9,10,12,16,18,19,20,21,22,24,26,27,29,30,35,37,45","Sensors":"1,2,3,4,5,6"},"StatusNET":{"Hostname":"TasmotaMultimediaPower","IPAddress":"192.168.1.107","Gateway":"192.168.1.1","Subnetmask":"255.255.255.0","DNSServer":"192.168.1.1","Mac":"70:03:9F:AA:BB:CC","Webserver":2,"WifiConfig":4,"WifiPower":17.0},"StatusMQT":{"MqttHost":"192.168.1.8","MqttPort":1883,"MqttClientMask":"DVES_%06X","MqttClient":"DVES_AABBCC","MqttUser":"DVES_USER","MqttCount":182,"MAX_PACKET_SIZE":1200,"KEEPALIVE":30,"SOCKET_TIMEOUT":4},"StatusTIM":{"UTC":"2026-04-04T05:38:46","Local":"2026-04-04T06:38:46","StartDST":"2026-03-29T02:00:00","EndDST":"2026-10-25T03:00:00","Timezone":"+01:00","Sunrise":"06:21","Sunset":"19:24"},"StatusPTH":{"PowerDelta":[0,0,0],"PowerLow":0,"PowerHigh":0,"VoltageLow":0,"VoltageHigh":0,"CurrentLow":0,"CurrentHigh":0},"StatusSNS":{"Time":"2026-04-04T06:38:46","ENERGY":{"TotalStartTime":"2021-10-06T09:31:03","Total":1098.989,"Yesterday":0.863,"Today":0.079,"Power":10,"ApparentPower":56,"ReactivePower":55,"Factor":0.18,"Voltage":240,"Current":0.234}},"StatusSTS":{"Time":"2026-04-04T06:38:46","Uptime":"159T17:34:01","UptimeSec":13800841,"Heap":20,"SleepMode":"Dynamic","Sleep":50,"LoadAvg":19,"MqttCount":182,"POWER1":"on","Wifi":{"AP":1,"SSId":"LAN_SOLO","BSSId":"01:23:45:67:89:AB","Channel":6,"Mode":"11n","RSSI":100,"Signal":-22,"LinkCount":79,"Downtime":"0T00:07:39"}},"StatusSTK":{"Exception":29,"Reason":"Exception","EPC":["4000df64","00000000","00000000"],"EXCVADDR":"00000000","DEPC":"00000000","CallChain":["4010149c","402654c3","40265458","402653ff","40264558","40264581","40261fec","4000050c","4026c5b7","4025e359","40262ce3","40000f58","40262756","4026beaf","4026b76f","40249494","40000f49","40000f49","40000e19","40105a7d","40105a83","4010000d","4026a654","4026a605","4010014c","401013d1","401013c0","401012f8","4000050c","4024f6b7","4024fd62"]}';
	// same as sTeststring but array of 3 --> has around 9.74kB which is > 8192 byte, as defined by tinyjson_DATA_BUFFER_SIZE as maximum internal buffer
	sTestStringTooBig := '[{"Status":{"Module":0,"DeviceName":"TasmotaMultimediaPower","FriendlyName":["TasmotaMultimediaPower"],"Topic":"tasmota_AABBCC","ButtonTopic":"0","Power":1,"PowerOnState":3,"LedState":1,"LedMask":"FFFF","SaveData":1,"SaveState":1,"SwitchTopic":"0","SwitchMode":[0,0,0,0,0,0,0,0],"ButtonRetain":0,"SwitchRetain":0,"SensorRetain":0,"PowerRetain":0,"InfoRetain":0,"StateRetain":0},"StatusPRM":{"Baudrate":115200,"SerialConfig":"8N1","GroupTopic":"tasmotas","OtaUrl":"http://ota.tasmota.com/tasmota/release/tasmota.bin.gz","RestartReason":"Exception","Uptime":"159T17:34:01","StartupUTC":"2025-10-26T12:04:45","Sleep":50,"CfgHolder":4617,"BootCount":22,"BCResetTime":"2021-10-06T09:31:03","SaveCount":1465,"SaveAddress":"F9000"},"StatusFWR":{"Version":"9.5.0(tasmota)","BuildDateTime":"2021-06-17T08:26:35","Boot":31,"Core":"2_7_4_9","SDK":"2.2.2-dev(38a443e)","CpuFrequency":80,"Hardware":"ESP8285","CR":"407/699"},"StatusLOG":{"SerialLog":2,"WebLog":2,"MqttLog":0,"SysLog":0,"LogHost":"","LogPort":514,"SSId":["LAN_SOLO",""],"TelePeriod":150,"Resolution":"558180C0","SetOption":["04008009","2805C8000100060000005A0A000000000000","00000080","00006000","00000000"]},"StatusMEM":{"ProgramSize":607,"Free":396,"Heap":22,"ProgramFlashSize":1024,"FlashSize":1024,"FlashChipId":"144051","FlashFrequency":40,"FlashMode":3,"Features":["00000809","8FDAC787","04368001","000000CF","010013C0","C000F981","00004004","00001000","00000020"],"Drivers":"1,2,3,4,5,6,7,8,9,10,12,16,18,19,20,21,22,24,26,27,29,30,35,37,45","Sensors":"1,2,3,4,5,6"},"StatusNET":{"Hostname":"TasmotaMultimediaPower","IPAddress":"192.168.1.107","Gateway":"192.168.1.1","Subnetmask":"255.255.255.0","DNSServer":"192.168.1.1","Mac":"70:03:9F:AA:BB:CC","Webserver":2,"WifiConfig":4,"WifiPower":17.0},"StatusMQT":{"MqttHost":"192.168.1.8","MqttPort":1883,"MqttClientMask":"DVES_%06X","MqttClient":"DVES_AABBCC","MqttUser":"DVES_USER","MqttCount":182,"MAX_PACKET_SIZE":1200,"KEEPALIVE":30,"SOCKET_TIMEOUT":4},"StatusTIM":{"UTC":"2026-04-04T05:38:46","Local":"2026-04-04T06:38:46","StartDST":"2026-03-29T02:00:00","EndDST":"2026-10-25T03:00:00","Timezone":"+01:00","Sunrise":"06:21","Sunset":"19:24"},"StatusPTH":{"PowerDelta":[0,0,0],"PowerLow":0,"PowerHigh":0,"VoltageLow":0,"VoltageHigh":0,"CurrentLow":0,"CurrentHigh":0},"StatusSNS":{"Time":"2026-04-04T06:38:46","ENERGY":{"TotalStartTime":"2021-10-06T09:31:03","Total":1098.989,"Yesterday":0.863,"Today":0.079,"Power":10,"ApparentPower":56,"ReactivePower":55,"Factor":0.18,"Voltage":240,"Current":0.234}},"StatusSTS":{"Time":"2026-04-04T06:38:46","Uptime":"159T17:34:01","UptimeSec":13800841,"Heap":20,"SleepMode":"Dynamic","Sleep":50,"LoadAvg":19,"MqttCount":182,"POWER1":"on","Wifi":{"AP":1,"SSId":"LAN_SOLO","BSSId":"01:23:45:67:89:AB","Channel":6,"Mode":"11n","RSSI":100,"Signal":-22,"LinkCount":79,"Downtime":"0T00:07:39"}},"StatusSTK":{"Exception":29,"Reason":"Exception","EPC":["4000df64","00000000","00000000"],"EXCVADDR":"00000000","DEPC":"00000000","CallChain":["4010149c","402654c3","40265458","402653ff","40264558","40264581","40261fec","4000050c","4026c5b7","4025e359","40262ce3","40000f58","40262756","4026beaf","4026b76f","40249494","40000f49","40000f49","40000e19","40105a7d","40105a83","4010000d","4026a654","4026a605","4010014c","401013d1","401013c0","401012f8","4000050c","4024f6b7","4024fd62"]}},{"Status1":{"Module":0,"DeviceName":"TasmotaMultimediaPower","FriendlyName":["TasmotaMultimediaPower"],"Topic":"tasmota_AABBCC","ButtonTopic":"0","Power":1,"PowerOnState":3,"LedState":1,"LedMask":"FFFF","SaveData":1,"SaveState":1,"SwitchTopic":"0","SwitchMode":[0,0,0,0,0,0,0,0],"ButtonRetain":0,"SwitchRetain":0,"SensorRetain":0,"PowerRetain":0,"InfoRetain":0,"StateRetain":0},"StatusPRM":{"Baudrate":115200,"SerialConfig":"8N1","GroupTopic":"tasmotas","OtaUrl":"http://ota.tasmota.com/tasmota/release/tasmota.bin.gz","RestartReason":"Exception","Uptime":"159T17:34:01","StartupUTC":"2025-10-26T12:04:45","Sleep":50,"CfgHolder":4617,"BootCount":22,"BCResetTime":"2021-10-06T09:31:03","SaveCount":1465,"SaveAddress":"F9000"},"StatusFWR":{"Version":"9.5.0(tasmota)","BuildDateTime":"2021-06-17T08:26:35","Boot":31,"Core":"2_7_4_9","SDK":"2.2.2-dev(38a443e)","CpuFrequency":80,"Hardware":"ESP8285","CR":"407/699"},"StatusLOG":{"SerialLog":2,"WebLog":2,"MqttLog":0,"SysLog":0,"LogHost":"","LogPort":514,"SSId":["LAN_SOLO",""],"TelePeriod":150,"Resolution":"558180C0","SetOption":["04008009","2805C8000100060000005A0A000000000000","00000080","00006000","00000000"]},"StatusMEM":{"ProgramSize":607,"Free":396,"Heap":22,"ProgramFlashSize":1024,"FlashSize":1024,"FlashChipId":"144051","FlashFrequency":40,"FlashMode":3,"Features":["00000809","8FDAC787","04368001","000000CF","010013C0","C000F981","00004004","00001000","00000020"],"Drivers":"1,2,3,4,5,6,7,8,9,10,12,16,18,19,20,21,22,24,26,27,29,30,35,37,45","Sensors":"1,2,3,4,5,6"},"StatusNET":{"Hostname":"TasmotaMultimediaPower","IPAddress":"192.168.1.107","Gateway":"192.168.1.1","Subnetmask":"255.255.255.0","DNSServer":"192.168.1.1","Mac":"70:03:9F:AA:BB:CC","Webserver":2,"WifiConfig":4,"WifiPower":17.0},"StatusMQT":{"MqttHost":"192.168.1.8","MqttPort":1883,"MqttClientMask":"DVES_%06X","MqttClient":"DVES_AABBCC","MqttUser":"DVES_USER","MqttCount":182,"MAX_PACKET_SIZE":1200,"KEEPALIVE":30,"SOCKET_TIMEOUT":4},"StatusTIM":{"UTC":"2026-04-04T05:38:46","Local":"2026-04-04T06:38:46","StartDST":"2026-03-29T02:00:00","EndDST":"2026-10-25T03:00:00","Timezone":"+01:00","Sunrise":"06:21","Sunset":"19:24"},"StatusPTH":{"PowerDelta":[0,0,0],"PowerLow":0,"PowerHigh":0,"VoltageLow":0,"VoltageHigh":0,"CurrentLow":0,"CurrentHigh":0},"StatusSNS":{"Time":"2026-04-04T06:38:46","ENERGY":{"TotalStartTime":"2021-10-06T09:31:03","Total":1098.989,"Yesterday":0.863,"Today":0.079,"Power":10,"ApparentPower":56,"ReactivePower":55,"Factor":0.18,"Voltage":240,"Current":0.234}},"StatusSTS":{"Time":"2026-04-04T06:38:46","Uptime":"159T17:34:01","UptimeSec":13800841,"Heap":20,"SleepMode":"Dynamic","Sleep":50,"LoadAvg":19,"MqttCount":182,"POWER1":"on","Wifi":{"AP":1,"SSId":"LAN_SOLO","BSSId":"01:23:45:67:89:AB","Channel":6,"Mode":"11n","RSSI":100,"Signal":-22,"LinkCount":79,"Downtime":"0T00:07:39"}},"StatusSTK":{"Exception":29,"Reason":"Exception","EPC":["4000df64","00000000","00000000"],"EXCVADDR":"00000000","DEPC":"00000000","CallChain":["4010149c","402654c3","40265458","402653ff","40264558","40264581","40261fec","4000050c","4026c5b7","4025e359","40262ce3","40000f58","40262756","4026beaf","4026b76f","40249494","40000f49","40000f49","40000e19","40105a7d","40105a83","4010000d","4026a654","4026a605","4010014c","401013d1","401013c0","401012f8","4000050c","4024f6b7","4024fd62"]}},{"Status2":{"Module":0,"DeviceName":"TasmotaMultimediaPower","FriendlyName":["TasmotaMultimediaPower"],"Topic":"tasmota_AABBCC","ButtonTopic":"0","Power":1,"PowerOnState":3,"LedState":1,"LedMask":"FFFF","SaveData":1,"SaveState":1,"SwitchTopic":"0","SwitchMode":[0,0,0,0,0,0,0,0],"ButtonRetain":0,"SwitchRetain":0,"SensorRetain":0,"PowerRetain":0,"InfoRetain":0,"StateRetain":0},"StatusPRM":{"Baudrate":115200,"SerialConfig":"8N1","GroupTopic":"tasmotas","OtaUrl":"http://ota.tasmota.com/tasmota/release/tasmota.bin.gz","RestartReason":"Exception","Uptime":"159T17:34:01","StartupUTC":"2025-10-26T12:04:45","Sleep":50,"CfgHolder":4617,"BootCount":22,"BCResetTime":"2021-10-06T09:31:03","SaveCount":1465,"SaveAddress":"F9000"},"StatusFWR":{"Version":"9.5.0(tasmota)","BuildDateTime":"2021-06-17T08:26:35","Boot":31,"Core":"2_7_4_9","SDK":"2.2.2-dev(38a443e)","CpuFrequency":80,"Hardware":"ESP8285","CR":"407/699"},"StatusLOG":{"SerialLog":2,"WebLog":2,"MqttLog":0,"SysLog":0,"LogHost":"","LogPort":514,"SSId":["LAN_SOLO",""],"TelePeriod":150,"Resolution":"558180C0","SetOption":["04008009","2805C8000100060000005A0A000000000000","00000080","00006000","00000000"]},"StatusMEM":{"ProgramSize":607,"Free":396,"Heap":22,"ProgramFlashSize":1024,"FlashSize":1024,"FlashChipId":"144051","FlashFrequency":40,"FlashMode":3,"Features":["00000809","8FDAC787","04368001","000000CF","010013C0","C000F981","00004004","00001000","00000020"],"Drivers":"1,2,3,4,5,6,7,8,9,10,12,16,18,19,20,21,22,24,26,27,29,30,35,37,45","Sensors":"1,2,3,4,5,6"},"StatusNET":{"Hostname":"TasmotaMultimediaPower","IPAddress":"192.168.1.107","Gateway":"192.168.1.1","Subnetmask":"255.255.255.0","DNSServer":"192.168.1.1","Mac":"70:03:9F:AA:BB:CC","Webserver":2,"WifiConfig":4,"WifiPower":17.0},"StatusMQT":{"MqttHost":"192.168.1.8","MqttPort":1883,"MqttClientMask":"DVES_%06X","MqttClient":"DVES_AABBCC","MqttUser":"DVES_USER","MqttCount":182,"MAX_PACKET_SIZE":1200,"KEEPALIVE":30,"SOCKET_TIMEOUT":4},"StatusTIM":{"UTC":"2026-04-04T05:38:46","Local":"2026-04-04T06:38:46","StartDST":"2026-03-29T02:00:00","EndDST":"2026-10-25T03:00:00","Timezone":"+01:00","Sunrise":"06:21","Sunset":"19:24"},"StatusPTH":{"PowerDelta":[0,0,0],"PowerLow":0,"PowerHigh":0,"VoltageLow":0,"VoltageHigh":0,"CurrentLow":0,"CurrentHigh":0},"StatusSNS":{"Time":"2026-04-04T06:38:46","ENERGY":{"TotalStartTime":"2021-10-06T09:31:03","Total":1098.989,"Yesterday":0.863,"Today":0.079,"Power":10,"ApparentPower":56,"ReactivePower":55,"Factor":0.18,"Voltage":240,"Current":0.234}},"StatusSTS":{"Time":"2026-04-04T06:38:46","Uptime":"159T17:34:01","UptimeSec":13800841,"Heap":20,"SleepMode":"Dynamic","Sleep":50,"LoadAvg":19,"MqttCount":182,"POWER1":"on","Wifi":{"AP":1,"SSId":"LAN_SOLO","BSSId":"01:23:45:67:89:AB","Channel":6,"Mode":"11n","RSSI":100,"Signal":-22,"LinkCount":79,"Downtime":"0T00:07:39"}},"StatusSTK":{"Exception":29,"Reason":"Exception","EPC":["4000df64","00000000","00000000"],"EXCVADDR":"00000000","DEPC":"00000000","CallChain":["4010149c","402654c3","40265458","402653ff","40264558","40264581","40261fec","4000050c","4026c5b7","4025e359","40262ce3","40000f58","40262756","4026beaf","4026b76f","40249494","40000f49","40000f49","40000e19","40105a7d","40105a83","4010000d","4026a654","4026a605","4010014c","401013d1","401013c0","401012f8","4000050c","4024f6b7","4024fd62"]}}]';
	
	// test json object with array as root
	// TEST --> path and order information invalid, if JSON input string root is array of objects (... work in progress to solve that ...)
	sTestStringRootArray := '[{"Status1":{"element":"1"}},{"Status2":{"element":"2"}},{"Status3":{"element":"3"}},{"Status4":{"element":"4"}},{"Status5":{"element":"5"}}]';
	// TEST --> path and order information invalid, if JSON input string root is array of objects (... work in progress to solve that ...)
	sTestStringArrayOfObjects := '{"Test":[{"Status1":{"element":"1"}},{"Status2":{"element":"2"}},{"Status3":{"element":"3"}},{"Status4":{"element":"4"}},{"Status5":{"element":"5"}}]}';
	// TEST --> single element
	sTestStringSingleElement := '{"Status":"1"}';
	
	// big result array, size [265]
	jValues;
	// small result array, size [32]
	jValuesSmall;
	
	// variable
	strElementName := '';
	 
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	
	CASE testStep OF
	
		1:
			// parse the complete JSON in sTestString
			liResult := TinyJsonDump(ADR(sTestString), ADR(jValues), SIZEOF(jValues), 0);
			
			// if sTestString wasn't changed: should return 204 --> positive result = number of result array elements used
			IF liResult = 205 THEN
				testStep := testStep + 1;
			ELSE
				testStep := 100 - testStep;
			END_IF
		
		2:
			// parse a subelement (object) of sTestString
			liResult := TinyJsonDump(ADR(sTestString), ADR(jValues), SIZEOF(jValues), ADR('StatusSNS:ENERGY'));
			
			// if sTestString wasn't changed: should return 10 --> positive result = number of result array elements used
			IF liResult = 11 THEN
				testStep := testStep + 1;
			ELSE
				testStep := 100 - testStep;
			END_IF
		
		3:
			// parse a WRONG subelement (object) of sTestString
			liResult := TinyJsonDump(ADR(sTestString), ADR(jValues), SIZEOF(jValues), ADR('StatusSNS:Energy'));
			
			// if sTestString wasn't changed: should return tinyjsonERR_JSONELEMENTINVALID --> negative result = error
			IF liResult = tinyjsonERR_JSONELEMENTINVALID THEN
				testStep := testStep + 1;
			ELSE
				testStep := 100 - testStep;
			END_IF
		
		4:
			// check error
			liResult := TinyJsonDump(ADR(sTestString), ADR(jValuesSmall), SIZEOF(jValuesSmall), 0);
			
			// if sTestString wasn't changed: should return tinyjsonERR_DESTARRAYTOOSMALL --> negative result = error
			IF liResult = tinyjsonERR_DESTARRAYTOOSMALL THEN
				testStep := testStep + 1;
			ELSE
				testStep := 100 - testStep;
			END_IF
			
		5:
			// check error
			liResult := TinyJsonDump(ADR(sTestString), ADR(jValues), 0, 0);
			
			// if sTestString wasn't changed: should return tinyjsonERR_PARAMETERINVALID --> negative result = error
			IF liResult = tinyjsonERR_PARAMETERINVALID THEN
				testStep := testStep + 1;
			ELSE
				testStep := 100 - testStep;
			END_IF
		
		6:
			// parse the complete TOO BIG JSON in sTestString
			liResult := TinyJsonDump(ADR(sTestStringTooBig), ADR(jValues), SIZEOF(jValues), 0);
			
			// if sTestStringTooBig wasn't changed: should return tinyjsonERR_JSONINPUTTOOLARGE --> negative result = error
			IF liResult = tinyjsonERR_JSONINPUTTOOLARGE THEN
				testStep := testStep + 1;
			ELSE
				testStep := 100 - testStep;
			END_IF

		7:
			// parse a subelement (single element) of sTestString into a smaller Array
			liResult := TinyJsonDump(ADR(sTestString), ADR(jValuesSmall), SIZEOF(jValuesSmall), ADR('StatusSNS:ENERGY:Current'));
			
			// if sTestString wasn't changed: should return 1 --> positive result = number of result array elements used
			IF liResult = 1 THEN
				IF brsmemcmp(ADR(jValuesSmall[0].key), ADR('Current'), brsstrlen(ADR('Current'))) = 0 AND brsmemcmp(ADR(jValuesSmall[0].value), ADR('0.234'), brsstrlen(ADR('0.234'))) = 0 AND jValuesSmall[0].type = tjJSON_REAL THEN
					testStep := testStep + 1;
				ELSE
					testStep := 51;
				END_IF
			ELSE
				testStep := 100 - testStep;
			END_IF
		
		8:
			// parse a json string where root is array object
			liResult := TinyJsonDump(ADR(sTestStringRootArray), ADR(jValuesSmall), SIZEOF(jValuesSmall), 0);
			// if input string wasn't changed --> should return 16 elements
			IF liResult = 16 THEN
				testStep := testStep + 1;
			ELSE
				testStep := 100 - testStep;
			END_IF
			
		9:
			// parse a json string that contains an array of objects
			liResult := TinyJsonDump(ADR(sTestStringArrayOfObjects), ADR(jValuesSmall), SIZEOF(jValuesSmall), 0);
			// if input string wasn't changed --> should return 17 elements
			IF liResult = 17 THEN
				testStep := testStep + 1;
			ELSE
				testStep := 100 - testStep;
			END_IF

		10:
			// check single object as JSON input string
			liResult := TinyJsonDump(ADR(sTestStringSingleElement), ADR(jValuesSmall), SIZEOF(jValuesSmall), 0);
			// if input string wasn't changed --> should return 2 elements
			IF liResult = 2 THEN
				testStep := testStep + 1;
			ELSE
				testStep := 100 - testStep;
			END_IF

		11:
			// check parsing sub-element of type array
			liResult := TinyJsonDump(ADR(sTestString), ADR(jValuesSmall), SIZEOF(jValuesSmall), ADR('StatusMEM:Features'));
			// if input string wasn't changed --> should return 10 elements
			IF liResult = 10 THEN
				testStep := testStep + 1;
			ELSE
				testStep := 100 - testStep;
			END_IF
			
		12:
			// all tests passed

		
	END_CASE
	
	
	
	
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

