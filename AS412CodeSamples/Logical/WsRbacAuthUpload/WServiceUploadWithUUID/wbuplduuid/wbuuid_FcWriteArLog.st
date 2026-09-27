
(*
	Writes one text event to the Automation Runtime event log. The function
	block is executed for the current call and Execute is cleared immediately
	afterward. The return value is TRUE when the event-log function block does
	not report an error.
*)
FUNCTION wbuuid_FcWriteArLog
	// call ArEventLog FBs
	ArEventLogWrite_0.Execute := TRUE;
	ArEventLogWrite_0.Ident := arLogIdent;
	ArEventLogWrite_0.EventID := arLogEvent;
	ArEventLogWrite_0.ObjectID := arLogObjID;
	ArEventLogWrite_0.OriginRecordID := 0;
	ArEventLogWrite_0.TimeStamp := 0;
	ArEventLogWrite_0.AddDataFormat := arEVENTLOG_ADDFORMAT_TEXT;
	ArEventLogWrite_0.AddData := ADR(arLogText);
	ArEventLogWrite_0.AddDataSize := brsstrlen(ADR(arLogText));
	ArEventLogWrite_0();
	IF ArEventLogWrite_0.Error = TRUE THEN
		wbuuid_FcWriteArLog := FALSE;
	ELSE
		wbuuid_FcWriteArLog := TRUE;
	END_IF
	ArEventLogWrite_0.Execute := FALSE;
END_FUNCTION
