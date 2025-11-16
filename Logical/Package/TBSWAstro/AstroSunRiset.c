/********************************************************************
 * COPYRIGHT -- B&R
 ********************************************************************
 * Library: SunRiset
 * File: CalcSunRiset.c
 * Author: bur
 * Created: September 07, 2014
 ********************************************************************
 * Implementation of library SunRiset
 ********************************************************************/

#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif

	#include <AsTime.h>
	#include <AsArCfg.h>
	#include <AsBrStr.h>
	#include "sunriset.h"
	#include "TBSWAstro.h"

#ifdef __cplusplus
	};
#endif

/* TODO: Add your comment here */
void AstroSunRiset(struct AstroSunRiset* inst)
{
	double sunrise = 0.0;
	double sunset = 0.0;
	
	if (inst->enable)
	{
		switch (inst->step)
		{
			
			case 0:
				inst->status = 0xFFFF;
				// use current date time of plc or not
				if (inst->pCalcDT == 0)
				{
					inst->UtcGetTime.enable = 1;
					inst->UtcGetTime.pDTStructure = (UDINT)&inst->utcActTime;
					UtcDTStructureGetTime(&inst->UtcGetTime);
					if (inst->UtcGetTime.status != 65535)
					{
						inst->step++;
					}
				}
				else
				{
					brsmemcpy((UDINT)&inst->utcActTime, inst->pCalcDT, sizeof(inst->utcActTime));
					inst->step++;
				}
				break;
			
			case 1:
				// get time information
				inst->Dstinfo.enable = 1;
				inst->Dstinfo.pDTStructure = inst->pCalcDT;
				DstGetInfo(&inst->Dstinfo);
				if (inst->Dstinfo.status != 65535)
				{
					inst->step++;
				}
				break;
					
			case 2:
				switch (inst->type)
				{
					case astroTYPE_DIRECT:
						inst->iResult.sunriset_result = sun_rise_set(inst->utcActTime.year, inst->utcActTime.month, inst->utcActTime.day, inst->longitude, inst->latitude, &sunrise, &sunset);
						break;
					case astroTYPE_CIVIL:
						inst->iResult.sunriset_result = civil_twilight(inst->utcActTime.year, inst->utcActTime.month, inst->utcActTime.day, inst->longitude, inst->latitude, &sunrise, &sunset);
						break;
					case astroTYPE_NAUTICAL:
						inst->iResult.sunriset_result = nautical_twilight(inst->utcActTime.year, inst->utcActTime.month, inst->utcActTime.day, inst->longitude, inst->latitude, &sunrise, &sunset);
						break;
					default:
						inst->iResult.sunriset_result = -32768;
						break;
				}
				
				// wether calcucate local time settings, or not
				if (inst->gmtResult == 0)
				{
					if (inst->Dstinfo.dstState == timDAYLIGHT_SAVING_TIME)
					{
						// e.g.: my code runs in timezone GMT + 1, and it's summer time, so add 2 hours;
						sunrise = sunrise + 2.0; sunset = sunset + 2.0;
					}
					else
					{
						// add only gmt offset
						sunrise = sunrise + 1.0; sunset = sunset + 1.0;					
					}
				}

				// normalize value to "hour : minute"
				inst->iResult.sunrise.hour = (USINT)sunrise;
				inst->iResult.sunset.hour = (USINT)sunset;
				inst->iResult.sunrise.minute = (USINT)((sunrise - (double)inst->iResult.sunrise.hour) * 60.0);
				inst->iResult.sunset.minute = (USINT)((sunset - (double)inst->iResult.sunset.hour) * 60.0);
				
				brsmemcpy((UDINT)(AstroSunRisetCalcResult_type*)inst->pResult, (UDINT)&inst->iResult, sizeof(inst->iResult));
				inst->step = 0;
				inst->status = 0;
				break;
		
			}
		}
		else
		{
			inst->status = 0xFFFE;
			inst->step = 0;
			
		}
		
}

