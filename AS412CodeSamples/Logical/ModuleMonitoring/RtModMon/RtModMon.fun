
{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK ModuleMonitoring (*Check binary modules if address has changed (because of download / reload), and creates logger entries in $$arlogusr if address or binary has changed*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		enable : {REDUND_UNREPLICABLE} BOOL; (*enables the function block*)
		logAllModules : {REDUND_UNREPLICABLE} BOOL; (*false = only tasks and libs are monitored, true = every module is monitored. ATTENTION: if true, this needs a much bigger array and computing time, please increase MOD_IMAGE_MAXIDX and rebuild!!*)
		logNewModules : {REDUND_UNREPLICABLE} BOOL; (*if true, also logger entries are generated if binaries are seen "the first time"*)
		resetCountersFlags : {REDUND_UNREPLICABLE} BOOL; (*reset "changed flags" inside ModuleOverview, counter and status outputs -> resets with positive edge, has to be set to FALSE also by application!*)
	END_VAR
	VAR_OUTPUT
		differenceCounter : {REDUND_UNREPLICABLE} UINT; (*overall number of changes detected since last resetCounterFlags*)
		ModuleOverview : {REDUND_UNREPLICABLE} ARRAY[0..rtmodmon_MOD_IMAGE_MAXIDX] OF ModuleInfoOverview_typ; (*Structure with binary overview -> see comments inside the type file*)
		lastImageIdx : {REDUND_UNREPLICABLE} UINT; (*highest index used inside the ModuleOverview structure*)
		checkComplete : {REDUND_UNREPLICABLE} BOOL; (*gets true FOR ONE CYCLE, if all modules out of image are checked*)
		status : {REDUND_UNREPLICABLE} UINT; (*FB status information*)
		statusInfo1 : {REDUND_UNREPLICABLE} DINT; (*FB extended status information - internal FB error code*)
		statusInfo2 : {REDUND_UNREPLICABLE} UINT; (*FB extended status information - cntidx value*)
	END_VAR
	VAR
		ArEventLogGetIdent_0 : {REDUND_UNREPLICABLE} ArEventLogGetIdent; (*INTERNAL*)
		ArEventLogWrite_0 : {REDUND_UNREPLICABLE} ArEventLogWrite; (*INTERNAL*)
		DTGetTime_0 : {REDUND_UNREPLICABLE} DTGetTime; (*INTERNAL*)
		MO_info_0 : {REDUND_UNREPLICABLE} MO_info; (*INTERNAL*)
		ModuleToCheck : {REDUND_UNREPLICABLE} ModuleChangeCheck_typ; (*INTERNAL module monitoring structure*)
		ModuleImage : {REDUND_UNREPLICABLE} ARRAY[0..rtmodmon_MOD_IMAGE_MAXIDX] OF ModuleChangeCheck_typ; (*INTERNAL module monitoring struct array*)
		refModuleChangeRuntimeInfo : REFERENCE TO ModuleRuntimeInfo_typ; (*INTERNAL pointer for reading module information*)
		index : {REDUND_UNREPLICABLE} UINT; (*INTERNAL*)
		prev_index : {REDUND_UNREPLICABLE} UINT; (*INTERNAL*)
		sLogString : {REDUND_UNREPLICABLE} STRING[255]; (*INTERNAL*)
		sTmpString : {REDUND_UNREPLICABLE} STRING[50]; (*INTERNAL*)
		bFoundOrNew : {REDUND_UNREPLICABLE} BOOL; (*INTERNAL*)
		sTmpModuleName : {REDUND_UNREPLICABLE} STRING[10]; (*INTERNAL*)
		sTmpModuleVersion : {REDUND_UNREPLICABLE} STRING[10]; (*INTERNAL*)
		kk : {REDUND_UNREPLICABLE} UINT; (*INTERNAL*)
		cntidx : {REDUND_UNREPLICABLE} UINT; (*INTERNAL*)
		imgidx : {REDUND_UNREPLICABLE} UINT; (*INTERNAL*)
		zzEdge00000 : {REDUND_UNREPLICABLE} BOOL; (*INTERNAL*)
		zzEdge00001 : {REDUND_UNREPLICABLE} BOOL; (*INTERNAL*)
	END_VAR
END_FUNCTION_BLOCK
