
PROGRAM _INIT
	
	// set up "read logger" function
	ReadEvLogEntries_0.loggerName := CONST_PARAM_NAME_BUFFER;
	ReadEvLogEntries_0.pResultData := ADR(tResultData);
	ReadEvLogEntries_0.resultDataSize := SIZEOF(tResultData);
	ReadEvLogEntries_0.recordIdStart := 0;
	ReadEvLogEntries_0.useReadFilter := FALSE;
	ReadEvLogEntries_0.execute := FALSE;
	ReadEvLogEntries_0.next := FALSE;

	// set up webservice	
	Webservice.pServiceName 	:= ADR('getLogger.cgi'); (* Name of webservice *)
	Webservice.option 			:= httpOPTION_HTTP_11 + httpOPTION_SERVICE_TYPE_NAME;
	Webservice.pRequestData		:= ADR(Request);
	Webservice.pRequestHeader	:= ADR(RequestHeader);
	Webservice.pUri				:= ADR(Uri);
	Webservice.uriSize			:= SIZEOF(Uri);
	Webservice.pResponseHeader	:= ADR(ResponseHeader);
	// this inouts have to be set inside the cyclic code
	//Webservice.pResponseData 	:= ADR(sJsonResponse); // set before fb call
	//Webservice.responseDataLen 	:= 0; // set before fb call
	
	sErrorTrailer := '<html><body><h1>wsLogger error</h1><div>Sorry, a error occured!</div><div>Error number is: ';
	sErrorFooter := '</div></body></html>';
	sErrorContent;
	
END_PROGRAM

PROGRAM _CYCLIC

	
	CASE wsloggerStep OF
	
		stepIDLE:
			// idle
			Webservice.send := FALSE;
			// disable the "read logger" FB
			ReadEvLogEntries_0.execute := FALSE;
				

		stepGETLOGGERMODULES:
			// be aware - I'm calling this function in some kind of endless loop, so high load on PLC, use task class with high tolerance !!

			moPrevIndex := 16#FFFF;
			moStatus := 0;
			pNext := brsstrcpy(ADR(sJsonResponse), ADR('{"error":"0","modules":['));
			
			WHILE moStatus = 0 DO
				moStatus := MO_list(moPrevIndex, ADR(moIndex), ADR(tMoData));
				IF moStatus = 0 THEN
					moPrevIndex := moIndex;
					// if it's a logger module ...
					IF tMoData.type = 83 THEN // 83 are logger modules
						pNext := brsstrcpy(pNext, ADR('"'));
						pNext := brsstrcpy(pNext, ADR(tMoData.name));
						pNext := brsstrcpy(pNext, ADR('",'));
					END_IF
				END_IF
			END_WHILE;
			pNext := brsstrcpy(pNext - 1, ADR(']}')); // -1 to overwrite last comma
			lenJsonResponse := pNext - ADR(sJsonResponse);

			wsloggerStep := stepSENDRESP;
			
			// read logger entries using user lib. "ReadEvLog"
		stepREADLOG:
			// be aware - ReadEvLogEntries runs synchronous, so high load on PLC, use task class with high tolerance !!
			ReadEvLogEntries_0.execute := TRUE;
			IF ReadEvLogEntries_0.done = TRUE THEN
				IF ReadEvLogEntries_0.error = FALSE THEN
					wsloggerStep := stepGENERATERESP;
				ELSE
					// error handling for read logger failed - send webservice answer
					pNext := brsstrcpy(ADR(sJsonResponse), ADR('{"error":"'));
					sTemp := DINT_TO_STRING(ReadEvLogEntries_0.statusID);
					pNext := brsstrcpy(pNext, ADR(sTemp));
					pNext := brsstrcpy(pNext, ADR('","data":[]}'));
					lenJsonResponse := pNext - ADR(sJsonResponse);
					wsloggerStep := stepSENDRESP;
				END_IF
			END_IF
		
			// generate the JSON coded response data that is used by the HTML/JS part
		stepGENERATERESP:
			
			maxResponseMem := SIZEOF(sJsonResponse) - 1024; // keep "some" bytes "free" for at least one dataset to avoid memory problems
			pNext := brsstrcpy(ADR(sJsonResponse),ADR('{"error":'));
			
			IF ReadEvLogEntries_0.numberOfEntriesRead > 0 THEN
				pNext := brsstrcpy(pNext,ADR('"0","module":"'));
				pNext := brsstrcpy(pNext,ADR(sParamNameBuffer));
				pNext := brsstrcpy(pNext,ADR('", "data":['));
				lenJsonResponse := pNext - ADR(sJsonResponse);
				
				FOR ii := UDINT_TO_UINT(ReadEvLogEntries_0.numberOfEntriesRead) TO 1 BY -1 DO // !!! be aware of the size of the result string !!! especially if using "next"
					IF lenJsonResponse < maxResponseMem THEN // check if destination memory has enough size ...
						
						pNext := brsstrcpy(pNext, ADR('{'));
						
						pNext := brsstrcpy(pNext, ADR('"recordID":"'));
						sTemp := UDINT_TO_STRING(tResultData[ii-1].recordID);
						pNext := brsstrcpy(pNext, ADR(sTemp));
						
						pNext := brsstrcpy(pNext, ADR('","originID":"'));
						sTemp := UDINT_TO_STRING(tResultData[ii-1].originID);
						pNext := brsstrcpy(pNext, ADR(sTemp));

						pNext := brsstrcpy(pNext, ADR('","eventDT":"'));
						
						sTemp := DT_TO_STRING(tResultData[ii-1].utcDateTime);
						pNext := brsstrcpy(pNext, ADR(sTemp));
						pNext := brsstrcpy(pNext, ADR('.'));
						sTemp := UDINT_TO_STRING(tResultData[ii-1].timestamp.nsec);
						pNext := brsstrcpy(pNext, ADR(sTemp));

						pNext := brsstrcpy(pNext, ADR('","eventID":"'));
						sTemp := DINT_TO_STRING(tResultData[ii-1].eventID);
						pNext := brsstrcpy(pNext, ADR(sTemp));

						pNext := brsstrcpy(pNext, ADR('","eventSev":"'));
						sTemp := USINT_TO_STRING(tResultData[ii-1].eventInfo.severity);
						pNext := brsstrcpy(pNext, ADR(sTemp));

						pNext := brsstrcpy(pNext, ADR('","objectID":"'));
						pNext := brsstrcpy(pNext, ADR(tResultData[ii-1].objectID));

						pNext := brsstrcpy(pNext, ADR('","addData":"'));
						IF tResultData[ii-1].additionalDataFormat = arEVENTLOG_ADDFORMAT_TEXT THEN
							// it's a pity - we have to search for " and to replace them because of json syntax violations
							FOR jj := 0 TO SIZEOF(tResultData[ii-1].additionalData)-1 DO
								chr ACCESS ADR(tResultData[ii-1].additionalData) + jj;
								IF chr = 0 THEN
									EXIT;
								ELSE
									IF chr = 34 THEN // is there a "
										chr := 39; // replace it with '
									END_IF
								END_IF
							END_FOR
							// DEBUG
							pNext := brsstrcpy(pNext, ADR(tResultData[ii-1].additionalData));
						ELSE
							// no text, nothing to display
							pNext := brsstrcpy(pNext, ADR('-- no text data available --'));
						END_IF
						
						pNext := brsstrcpy(pNext, ADR('"},'));
						lenJsonResponse := pNext - ADR(sJsonResponse);
					ELSE
						// ERROR - NOTE ENOUGH MEMORY TO GENERATE RESPONSE
						EXIT;
						// TODO - e.g. some more error handling here like "send information inside webserive response, that memory was not enough to send all data"
					END_IF
				END_FOR
				pNext := brsstrcpy(pNext - 1, ADR(']}')); // OVERWRITE last comma with closing brackets to meet the json syntax
				lenJsonResponse := pNext - ADR(sJsonResponse);
			ELSE
				// error: no etries in logger were read
				pNext := brsstrcpy(pNext, ADR('"-1","data":[]}')); 
				lenJsonResponse := pNext - ADR(sJsonResponse);
			END_IF

			wsloggerStep := stepSENDRESP;

			// send the webservice reponse data
		stepSENDRESP:
			ResponseHeader.contentType := 'application/json';
			Webservice.pResponseData 	:= ADR(sJsonResponse);
			Webservice.responseDataLen 	:= lenJsonResponse;
			Webservice.send := TRUE;
			wsloggerStep := stepIDLE;

			// send the webservice reponse data
		stepSENDHTML:
			ResponseHeader.contentType := 'text/html';
			Webservice.pResponseData 	:= DatObjInfo_0.pDatObjMem;
			Webservice.responseDataLen 	:= DatObjInfo_0.len;
			Webservice.send := TRUE;
			wsloggerStep := stepIDLE;

		stepSENDERROR:
			ResponseHeader.contentType := 'text/html';
			brsstrcpy(ADR(sErrorContent),ADR(sErrorTrailer));
			sTemp := DINT_TO_STRING(errorNumber);
			brsstrcat(ADR(sErrorContent),ADR(sTemp));
			brsstrcat(ADR(sErrorContent),ADR(sErrorFooter));
			Webservice.pResponseData 	:= ADR(sErrorContent);
			Webservice.responseDataLen 	:= brsstrlen(ADR(sErrorContent));
			Webservice.send := TRUE;
			wsloggerStep := stepIDLE;

	END_CASE
	
	
	// FB call for webservice execution
	Webservice.enable := TRUE;
	Webservice();
	
	// webservice was called
	IF Webservice.status = ERR_OK AND  Webservice.phase = httpPHASE_RECEIVED  THEN
		errorNumber := 0;
		// check if a logger module name was sent by Uri parameter
		httpGetParamUrl_0(enable := TRUE, pSrc := ADR(Uri), pParam := ADR('name'), pValue := ADR(sParamNameBuffer), valueSize := SIZEOF(sParamNameBuffer));
		IF httpGetParamUrl_0.status = 0 THEN
			ReadEvLogEntries_0.loggerName := sParamNameBuffer;
			// so start generating and sending data
			IF wsloggerStep = stepIDLE THEN
				wsloggerStep := stepREADLOG;	
			END_IF
		ELSE
			httpGetParamUrl_1(enable := TRUE, pSrc := ADR(Uri), pParam := ADR('getmodnames'), pValue := ADR(sParamGetModNamesBuffer), valueSize := SIZEOF(sParamGetModNamesBuffer));
			IF httpGetParamUrl_1.status = 0 THEN
				// we do not need the value of getmodnames, if parameter is set means for us "send the response"
				IF wsloggerStep = stepIDLE THEN
					wsloggerStep := stepGETLOGGERMODULES;	
				END_IF
			ELSE
				IF httpGetParamUrl_0.status = httpERR_NOT_FOUND THEN
					// no parameters given - so check if a data module exists with the html and js data
					// get address and len of html + js data object
					DatObjInfo_0(enable := TRUE, pName := ADR('wsLData'));
					IF DatObjInfo_0.status = 0 THEN
						wsloggerStep := stepSENDHTML;	
					ELSE
						// something is wrong with loading the data module, send error response
						errorNumber := UINT_TO_DINT(DatObjInfo_0.status);
						wsloggerStep := stepSENDERROR;	
					END_IF
				ELSE
					// something is wrong with the parameter, send error response
					errorNumber := UINT_TO_DINT(httpGetParamUrl_1.status);
					wsloggerStep := stepSENDERROR;	
				END_IF
			END_IF
		END_IF
	END_IF
	// TODO HERE - some more error handling about webservice !!

	// FB call for reading out logger entries
	ReadEvLogEntries_0();
	
END_PROGRAM

PROGRAM _EXIT

	Webservice.enable := FALSE;
	Webservice();

END_PROGRAM

