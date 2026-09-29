
TYPE
	uuidgensha256Internal_typ : {REDUND_UNREPLICABLE} 	STRUCT 
		enable_last : {REDUND_UNREPLICABLE} BOOL; (*internal*)
		getnext_last : {REDUND_UNREPLICABLE} BOOL; (*internal*)
		step : {REDUND_UNREPLICABLE} USINT; (*internal*)
		run_count : {REDUND_UNREPLICABLE} USINT; (*internal*)
		uuid_count : {REDUND_UNREPLICABLE} UDINT; (*internal - counter for periodic re-seeding*)
		internal_status : {REDUND_UNREPLICABLE} UINT; (*internal*)
		internal_error : {REDUND_UNREPLICABLE} UINT; (*internal*)
		serial : {REDUND_UNREPLICABLE} UDINT; (*internal*)
		ethstat_0 : {REDUND_UNREPLICABLE} EthStat; (*internal*)
		ton_0 : {REDUND_UNREPLICABLE} TON; (*internal*)
		stat : {REDUND_UNREPLICABLE} ethSTATISTICS_typ; (*internal*)
		asiodpstatus_0 : {REDUND_UNREPLICABLE} AsIODPStatus; (*internal*)
		drbg_K : {REDUND_UNREPLICABLE} ARRAY[0..31]OF USINT; (*internal - DRBG secret key*)
		drbg_V : {REDUND_UNREPLICABLE} ARRAY[0..31]OF USINT; (*internal - DRBG counter*)
		drbg_initialized : {REDUND_UNREPLICABLE} BOOL; (*internal - DRBG state valid*)
		bytesRecv : {REDUND_UNREPLICABLE} UDINT; (*internal*)
	END_STRUCT;
END_TYPE
