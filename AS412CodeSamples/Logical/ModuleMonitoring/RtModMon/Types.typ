
TYPE
	ModuleRuntimeInfo_typ : 	STRUCT  (*INTERNAL*)
		index : UINT;
		MOList_info : MO_List_typ;
		MOInfo_info : ModuleRuntimeInfo_VDS_typ;
	END_STRUCT;
	ModuleChangeCheck_typ : 	STRUCT  (*INTERNAL*)
		Info : ModuleRuntimeInfo_typ;
		dtLastCheck : DATE_AND_TIME;
		dtLastChange : DATE_AND_TIME;
		uCountModInfoChanged : UDINT;
		uCountModAddressChanged : UDINT;
		statusMOList : UINT;
		statusMOInfo : UINT;
	END_STRUCT;
	ModuleRuntimeInfo_VDS_typ : 	STRUCT  (*INTERNAL*)
		uSize : UDINT;
		tRtcDT : RTCtime_typ;
		sVersion : STRING[10];
	END_STRUCT;
	ModuleInfoOverview_typ : 	STRUCT  (*FB OUTPUT - ModuleOverview*)
		name : STRING[10]; (*name of the binary module*)
		changedAddr : BOOL; (*if true, module has changed address at least once since last resetCountersFlags*)
		changedBin : BOOL; (*if true, module binary has changed at least once since last resetCountersFlags*)
	END_STRUCT;
END_TYPE
