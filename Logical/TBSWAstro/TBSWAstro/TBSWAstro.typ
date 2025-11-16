(********************************************************************
 * COPYRIGHT -- B&R
 ********************************************************************
 * Library: SunRiset
 * File: SunRiset.typ
 * Author: bur
 * Created: September 07, 2014
 ********************************************************************
 * Data types of library SunRiset
 ********************************************************************)

TYPE
	AstroSunRisetCalcResult_type : 	STRUCT 
		sunrise : AstroSunRiseSetTime_type;
		sunset : AstroSunRiseSetTime_type;
		sunriset_result : INT;
	END_STRUCT;
	AstroSunRiseSetTime_type : 	STRUCT 
		hour : USINT;
		minute : USINT;
	END_STRUCT;
END_TYPE
