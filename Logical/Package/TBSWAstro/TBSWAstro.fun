(********************************************************************
 * COPYRIGHT -- B&R
 ********************************************************************
 * Library: SunRiset
 * File: SunRiset.fun
 * Author: bur
 * Created: September 07, 2014
 ********************************************************************
 * Functions and function blocks of library SunRiset
 ********************************************************************)

FUNCTION_BLOCK AstroSunRiset (*calculates sunrise / sunset*) (*$GROUP=User*)
	VAR_INPUT
		enable : BOOL; (*enable function block*)
		longitude : REAL; (*longitude of position to calc for, set as REAL value (e.g. see google maps)*)
		latitude : REAL; (*latitude of position to calc for, set as REAL value (e.g. see google maps)*)
		type : USINT; (*type of calculation: direct or civil or nautical sunrise / sunset*)
		pCalcDT : UDINT; (*if NULL(set to 0), actual date time is used (if set, set date you want to calc for  as pointer to DTStructure) type*)
		gmtResult : BOOL; (*if FALSE, timezone and daylight saving time settings are included in result*)
		pResult : UDINT; (*pointer to result variable of type "AstroSunRisetCalcResult_type"*)
	END_VAR
	VAR_OUTPUT
		status : UINT; (*65535 =  busy*)
	END_VAR
	VAR
		step : USINT;
		UtcGetTime : UtcDTStructureGetTime;
		utcActTime : DTStructure;
		Dstinfo : DstGetInfo;
		tSunRiset : AstroSunRisetCalcResult_type;
		iResult : AstroSunRisetCalcResult_type;
	END_VAR
END_FUNCTION_BLOCK
