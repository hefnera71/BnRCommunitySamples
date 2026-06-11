// Copyright (c) 2026 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details

#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif

#include <AsHttp.h>
#include <string.h>
#include "WsQRlib.h"
#include "html_qrcode.h"

#ifdef __cplusplus
	};
#endif

#define _MAX_DATA_SIZE 256

char web[128000];
char uri[256];
httpResponseHeader_t respheader;

void QRCodeWebservice(struct QRCodeWebservice* inst)
{

	if (inst->enable == 1 && inst->last == 0)
	{
		inst->status = 0xFFFF;
		inst->wsStep = 1;
		memset(&web, 0, sizeof(web));
		memset(&respheader, 0, sizeof(respheader));
	}
	
	if (inst->enable == 0 && inst->last == 1)
	{
		inst->status = 0xFFFE;
		inst->wsStep = 9;
	}
	
	switch (inst->wsStep)
	{

		case 1:
			
			if (inst->pDataString > 0 && strlen((char*)inst->pDataString) < _MAX_DATA_SIZE)
			{
				strcpy(web, _html_begin);
				strcat(web, _html_qrcode_js);
				strcat(web, _html_proceed);
				strcat(web, (char*)inst->pDataString);
				strcat(web, _html_end);
			
				strcpy(respheader.contentType, "text/html");
			
				inst->wsStep = 2;
			}
			else
			{
				// error!
				inst->wsStep = 0;
				if (inst->pDataString == 0)
				{
					inst->status = 55555;
				}
				else
				{
					inst->status = 55556;
				}
			}
			break;
				
	
		case 2:
			if (strlen(inst->webserviceName) == 0)
				inst->wssService.pServiceName = (UDINT)"GetTOTPQR.cgi";
			else
				inst->wssService.pServiceName = (UDINT)&inst->webserviceName;
			inst->wssService.pUri = (UDINT)&uri;
			inst->wssService.uriSize = sizeof(uri);
			inst->wssService.pRequestHeader = 0;
			inst->wssService.pRequestData = 0;
			inst->wssService.requestDataSize = 0;
			inst->wssService.pResponseHeader = (UDINT)&respheader;
			inst->wssService.pResponseData = (UDINT)&web;
			inst->wssService.responseDataLen = strlen(web);
			inst->wssService.pStatistics = 0;
			inst->wssService.pStruct = 0;
			inst->wssService.option = httpOPTION_HTTP_11 | httpOPTION_SERVICE_TYPE_NAME;
			
			inst->wssService.send = 0;
			inst->wssService.abort = 0;
			inst->wssService.enable = 1;
		
			inst->wsStep = 3;
			break;
		
		case 3:
			// todo: EXTENDED ERROR HANDLING
			switch (inst->wssService.phase)
			{
				case 3: // httpPHASE_RECEIVED
					inst->wssService.pResponseData = (UDINT)&web;
					inst->wssService.responseDataLen = strlen(web);
					inst->wssService.send = 1;
					break;
			
				default:
					inst->wssService.send = 0;
					break;
			}
			// copy ws status to status 
			inst->status = inst->wssService.status;
			break;

		case 9:
			inst->wssService.enable = 0;
			inst->wsStep = 0;
			break;
	}
	
	// call FB
	httpsService(&inst->wssService);
	inst->wsPhase = inst->wssService.phase;
	
	// store state for edge detection
	inst->last = inst->enable;

	
}



