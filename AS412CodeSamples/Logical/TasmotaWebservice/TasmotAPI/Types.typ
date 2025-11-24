
TYPE
	tTasmotaAPIHeaders_type : 	STRUCT 
		tResponseHeader : httpResponseHeader_t;
	END_STRUCT;
	tTasmotaAPIParameters_type : 	STRUCT 
		user : STRING[32];
		password : STRING[32];
		cmnd : STRING[32];
	END_STRUCT;
	tTasmotaAPIConfig_type : 	STRUCT 
		Host : STRING[100];
		Port : UINT;
		Uri : STRING[1000];
	END_STRUCT;
	tTasmotaAPI_type : 	STRUCT 
		Config : tTasmotaAPIConfig_type;
		Parameter : tTasmotaAPIParameters_type;
		Header : tTasmotaAPIHeaders_type;
	END_STRUCT;
END_TYPE
