
TYPE
	uuidgenInternal_typ : {REDUND_UNREPLICABLE} 	STRUCT 
		enable_last : {REDUND_UNREPLICABLE} BOOL; (*internal*)
		getnext_last : {REDUND_UNREPLICABLE} BOOL; (*internal*)
		step : {REDUND_UNREPLICABLE} USINT; (*internal*)
		run_count : {REDUND_UNREPLICABLE} USINT; (*internal*)
		start_val : {REDUND_UNREPLICABLE} UDINT; (*internal*)
		internal_error : {REDUND_UNREPLICABLE} UINT; (*internal*)
		internal_status : {REDUND_UNREPLICABLE} UINT; (*internal*)
		serial : {REDUND_UNREPLICABLE} UDINT; (*internal*)
		s_val : {REDUND_UNREPLICABLE} UDINT; (*internal*)
		ethstat_0 : {REDUND_UNREPLICABLE} EthStat; (*internal*)
		ton_0 : {REDUND_UNREPLICABLE} TON; (*internal*)
		stat : {REDUND_UNREPLICABLE} ethSTATISTICS_typ; (*internal*)
		asiodpstatus_0 : {REDUND_UNREPLICABLE} AsIODPStatus; (*internal*)
	END_STRUCT;
END_TYPE
