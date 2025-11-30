
TYPE
	ReadEvLog_Entry_type : 	STRUCT  (*Result variable structure type*)
		isLegacyFormat : BOOL; (*if logger entry has the old format, this bool is set to true*)
		eventID : DINT; (*event id (or error number, if legacy fomrat)*)
		eventInfo : ReadEvLog_Entry_EVID_type; (*decoded event id (severity, facility, code, a.s.o)*)
		utcDateTime : DATE_AND_TIME; (*decoded date and time of the logger entry*)
		timestamp : ArEventLogTimeStampType; (*ArEventLog timestamp (includes the microsecond information)*)
		objectID : STRING[36]; (*producer of the logger entry (who has entered the entry)*)
		additionalData : STRING[255]; (*extra data of the entry, could be readable or binary (if binary, it is NOT decoded!!)*)
		additionalDataFormat : USINT; (*if data format is  1 (=arEVENTLOG_ADDFORMAT_TEXT), the additional data is ASCII coded and should be readable*)
		additionalDataSize : UDINT; (*number of bytes of the additional data*)
		additionalDataComplete : BOOL; (*if true, the additional data were read out completey (depends on the size of .additionalData)*)
		recordID : ArEventLogRecordIDType; (*the ArEventLog record id of this entry*)
		originID : ArEventLogRecordIDType; (*the origin record if, if this entry is has a "parent" id*)
		reservedForDesciption : STRING[255]; (*this string is NOT USED by ReadEvLog -> it could be used to read out the error description by another function which is asynchronous*)
	END_STRUCT;
	ReadEvLog_Counters_type : 	STRUCT  (*counts the number of different entry types within the read data size*)
		error : UDINT;
		warning : UDINT;
		info : UDINT;
		success : UDINT;
	END_STRUCT;
	ReadEvLog_Entry_EVID_type : 	STRUCT  (*decoded event id -> see AS help "32 bit event id"*)
		severity : USINT;
		facility : UINT;
		code : UINT;
		c_bit : USINT;
		r_bit : USINT;
	END_STRUCT;
	ReadEvLog_Filter_type : 	STRUCT  (*read filter configuration*)
		maxNumberOfEntriesRead : UDINT; (*Maximum number of logger entries to read -> HAS TO BE USED WHEN FILTERING IS USED!! Only valid when filtering is active*)
		severity : ReadEvLog_Filter_Severity_type; (*severity filter*)
		eventId : ReadEvLog_Filter_EventId_type; (*event id filter*)
	END_STRUCT;
	ReadEvLog_Filter_Severity_type : 	STRUCT  (*severity filter -> if activated, each severity set tu TRUE matches*)
		useFilter : BOOL; (*use this filter -> different filter are AND connected!!*)
		error : BOOL; (*filter for error*)
		warning : BOOL; (*filter for warning*)
		info : BOOL; (*filter for info*)
		success : BOOL; (*filter for success*)
	END_STRUCT;
	ReadEvLog_Filter_EventId_type : 	STRUCT  (*event id filter -> if activated, everything between smallest and largest matches*)
		useFilter : BOOL; (*use this filter -> different filter are AND connected!!*)
		smallest : DINT; (*lowest event id for filter*)
		largest : DINT; (*highest event id for filter*)
	END_STRUCT;
	ReadEvLog_InternalCtrl_type : 	STRUCT  (*internal*)
		step : ReadEvLog_InternalState_enum;
		identValid : BOOL;
		ident : UDINT;
		recordValid : BOOL;
		RecordID : ArEventLogRecordIDType;
		resultDataArraySize : UDINT;
		arrayIndex : UDINT;
		loopSize : UDINT;
		loopIndex : UDINT;
		tmpEntry : ReadEvLog_Entry_type;
		filteredOk : USINT;
	END_STRUCT;
	ReadEvLog_Internal_type : 	STRUCT  (*internal*)
		FB : ReadEvLog_InternalFB_type;
		Ctrl : ReadEvLog_InternalCtrl_type;
	END_STRUCT;
	ReadEvLog_InternalFB_type : 	STRUCT  (*internal*)
		ArEvGetIdent : ArEventLogGetIdent;
		ArEvGetLatestID : ArEventLogGetLatestRecordID;
		ArEvGetPreviousID : ArEventLogGetPreviousRecordID;
		ArEvLogRead : ArEventLogRead;
		ArEvLogReadOID : ArEventLogReadObjectID;
		ArEvLogReadAddData : ArEventLogReadAddData;
		ArEvLogReadErrNr : ArEventLogReadErrorNumber;
	END_STRUCT;
	ReadEvLog_InternalState_enum : 
		( (*internal*)
		ReadEvLog_IDLE,
		ReadEvLog_RUNNING,
		ReadEvLog_MOREWAIT,
		ReadEvLog_FINISHED,
		ReadEvLog_ERROR,
		ReadEvLog_UNKNOWNSTATE
		);
	ReadEvLog_InternalDescFB_type : 	STRUCT  (*internal*)
		ArEvGetIdent : ArEventLogGetIdent;
		ArEvLogReadDesc : ARRAY[0..9]OF ArEventLogReadDescription;
	END_STRUCT;
	ReadEvLog_InternalDescCtrl_type : 	STRUCT  (*internal*)
		entryArrayStartIndex : UDINT;
		step : ReadEvLog_InternalState_enum;
		loopIndex : UDINT;
		resultDataArraySize : UDINT;
		fbBusyState : BOOL;
		fbReset : BOOL;
		nrOfReadDescInstances : USINT;
	END_STRUCT;
	ReadEvLog_InternalDesc_type : 	STRUCT  (*internal*)
		FB : ReadEvLog_InternalDescFB_type;
		Ctrl : ReadEvLog_InternalDescCtrl_type;
	END_STRUCT;
END_TYPE
