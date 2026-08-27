
TYPE
	uuidgenInternal_typ : 	STRUCT 
		enable_last : {REDUND_UNREPLICABLE} BOOL; (*internal*)
		getnext_last : {REDUND_UNREPLICABLE} BOOL; (*internal*)
		step : {REDUND_UNREPLICABLE} USINT; (*internal*)
		ethstat_0 : {REDUND_UNREPLICABLE} EthStat; (*internal*)
		run_count : {REDUND_UNREPLICABLE} USINT; (*internal*)
		start_val : {REDUND_UNREPLICABLE} UDINT; (*internal*)
		internal_error : {REDUND_UNREPLICABLE} UINT; (*internal*)
		internal_status : {REDUND_UNREPLICABLE} UINT; (*internal*)
		ton_0 : {REDUND_UNREPLICABLE} TON; (*internal*)
		stat : {REDUND_UNREPLICABLE} ethSTATISTICS_typ; (*internal*)
	END_STRUCT;
END_TYPE
