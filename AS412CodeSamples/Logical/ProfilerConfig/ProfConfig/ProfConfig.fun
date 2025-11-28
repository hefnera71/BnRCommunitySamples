
{REDUND_UNREPLICABLE} FUNCTION_BLOCK ProfilerConfig_INIT
	VAR_INPUT
		sDevice : {REDUND_UNREPLICABLE} STRING[80]; (*name of the file device where the config file is stored*)
		sFile : {REDUND_UNREPLICABLE} STRING[80]; (*name of the config file - if config file is existing, the values of ProfilerConfigStruct are overwritten!*)
		bExecuteIfFileNotFound : {REDUND_UNREPLICABLE} BOOL; (*configer profiler even if the config file is not found - then the values pf ProfilerConfigStruct are used*)
	END_VAR
	VAR_IN_OUT
		ProfilerConfigStruct : PROFILER_DEFINITION; (*profiler configuration structure of type PROFILER_DEFINITION (part of AsArProf library)*)
	END_VAR
	VAR_OUTPUT
		status : {REDUND_UNREPLICABLE} UINT; (*call status*)
	END_VAR
	VAR
		ArEventLogGetIdent_0 : {REDUND_UNREPLICABLE} ArEventLogGetIdent;
		ArEventLogWrite_0 : {REDUND_UNREPLICABLE} ArEventLogWrite;
		LogDeInstall_0 : {REDUND_UNREPLICABLE} LogDeInstall;
		LogInstall_0 : {REDUND_UNREPLICABLE} LogInstall;
		LogStart_0 : {REDUND_UNREPLICABLE} LogStart;
		LogStateGet_0 : {REDUND_UNREPLICABLE} LogStateGet;
		LogStop_0 : {REDUND_UNREPLICABLE} LogStop;
		ParseForNameValueTuples_0 : {REDUND_UNREPLICABLE} ParseForNameValueTuples;
		ReadFile_INIT_0 : {REDUND_UNREPLICABLE} ReadFile_INIT;
		AdditionalDataString : {REDUND_UNREPLICABLE} STRING[512];
		pStart : {REDUND_UNREPLICABLE} UDINT;
		pNext : {REDUND_UNREPLICABLE} UDINT;
		ProfilerStatus : {REDUND_UNREPLICABLE} STRING[20];
		TaskGroup : {REDUND_UNREPLICABLE} USINT;
		TaskName : {REDUND_UNREPLICABLE} STRING[11];
		uFileBuffer : {REDUND_UNREPLICABLE} ARRAY[0..32767] OF USINT;
		uParamArray : {REDUND_UNREPLICABLE} USINT;
		uParseUnkownParam : {REDUND_UNREPLICABLE} UINT;
		usLibFcs : {REDUND_UNREPLICABLE} ARRAY[0..1024] OF USINT;
		AsMemPartCreate_0 : {REDUND_UNREPLICABLE} AsMemPartCreate;
		AsMemPartAlloc_0 : {REDUND_UNREPLICABLE} AsMemPartAlloc;
		AsMemPartDestroy_0 : {REDUND_UNREPLICABLE} AsMemPartDestroy;
	END_VAR
END_FUNCTION_BLOCK
