
TYPE
	WsPingData_type : 	STRUCT 
		szResponse : STRING[8192];
		szRequest : STRING[512];
		szUri : STRING[1024];
		szHost : STRING[128];
		szTimeout : STRING[5];
		szError : STRING[5];
		szErrDesc : STRING[128];
		tRequestHeader : httpRequestHeader_t;
		tResponseHeader : httpResponseHeader_t;
		uiTimeout : UINT;
		szDnsMode : STRING[50];
		udiIpAddr : UDINT;
		szHostnameOrIpAddr : STRING[255];
		szEthStats : STRING[5];
		szResolve : STRING[5];
		szDNS1 : STRING[128];
		szDNS2 : STRING[128];
		szDNS3 : STRING[128];
		szSdmAddress : STRING[128];
		szEthIf : STRING[32];
		szEthIfPRESET : STRING[32];
		tEthStat : ethSTATISTICS_typ;
		uaMacAddr : ARRAY[0..5]OF USINT;
		szBaudrate : STRING[32];
		szMacAddr : STRING[32];
		usI : USINT;
		usLHB : USINT;
		usUHB : USINT;
		usCHR : USINT;
		szTemp32 : STRING[32];
	END_STRUCT;
	WsPing_type : 	STRUCT 
		Control : WsPingControl_type;
		Data : WsPingData_type;
		FB : WsPingFB_type;
	END_STRUCT;
	WsPingControl_type : 	STRUCT 
		eStep : WsPingMainStep_enum;
		eConfigStep : WsPingConfigStep_enum;
		uiStatusInetAton : UINT;
	END_STRUCT;
	WsPingFB_type : 	STRUCT 
		Webservice : httpService;
		GetParamUrl : httpGetParamUrl;
		Ping : IcmpPing;
		GetDnsMode : CfgGetDnsMode;
		GetDnsAddress : CfgGetDnsAddress;
		GetHostByName : HostByName;
		GetHostByAddress : HostByAddress;
		GetEthStat : EthStat;
		GetEthBd : CfgGetEthBaudrate;
		GetEthMac : CfgGetMacAddr;
	END_STRUCT;
	WsPingMainStep_enum : 
		(
		WsPingINIT,
		WsPingIDLE,
		WsPingREAD_ETHSTAT,
		WsPingREAD_ETHBD,
		WsPingREAD_ETHMAC,
		WsPingGET_PARAMETER,
		WsPingGET_DNSMODE,
		WsPingGET_DNSADDR,
		WsPingGET_CONFIG,
		WsPingSEND_HTMLFORM,
		WsPingPREPARE_RESPONSE,
		WsPingSEND_ETHSTATS,
		WsPingSEND_RESPONSE
		);
	WsPingConfigStep_enum : 
		(
		WsPingCFG_CHECK_HOSTNAME,
		WsPingCFG_RESOLVE_HOSTNAME,
		WsPingCFG_GOON
		);
END_TYPE
