(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

ACTION ActionGetStrModData: 
	brsstrcat(ADR(sLogString), ADR(' ver:'));
	brsstrcat(ADR(sLogString), ADR(refModuleChangeRuntimeInfo.MOInfo_info.sVersion));
	brsstrcat(ADR(sLogString), ADR(' size:'));
	brsitoa(refModuleChangeRuntimeInfo.MOInfo_info.uSize, ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(' compiled:'));
	brsitoa(refModuleChangeRuntimeInfo.MOInfo_info.tRtcDT.day, ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR('.'));
	brsitoa(refModuleChangeRuntimeInfo.MOInfo_info.tRtcDT.month, ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR('.'));
	brsitoa(refModuleChangeRuntimeInfo.MOInfo_info.tRtcDT.year, ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR('_'));
	brsitoa(refModuleChangeRuntimeInfo.MOInfo_info.tRtcDT.hour, ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR('.'));
	brsitoa(refModuleChangeRuntimeInfo.MOInfo_info.tRtcDT.minute, ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR('.'));
	brsitoa(refModuleChangeRuntimeInfo.MOInfo_info.tRtcDT.second, ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(sTmpString));

	brsstrcat(ADR(sLogString), ADR(' ( typ:'));
	brsitoa(ModuleToCheck.Info.MOList_info.type, ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(' imgidx:'));
	brsitoa(imgidx, ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(' cntidx:'));
	brsitoa(cntidx, ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(') '));
END_ACTION

ACTION ActionGetModBaseData:
	sLogString := '';
	brsstrcpy(ADR(sLogString), ADR(ModuleToCheck.Info.MOList_info.name));
	(*
	brsstrcat(ADR(sLogString), ADR(' ( typ:'));
	brsitoa(ModuleToCheck.Info.MOList_info.type, ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(' imgidx:'));
	brsitoa(imgidx, ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(' cntidx:'));
	brsitoa(cntidx, ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(sTmpString));
	brsstrcat(ADR(sLogString), ADR(') '));
	*)
END_ACTION

ACTION ActionWriteModDataToLogger:
	// synchronous FB -> this is the reason why I can trust the FB has finished already after one call !!
	ArEventLogWrite_0.Ident := ArEventLogGetIdent_0.Ident;
	ArEventLogWrite_0.OriginRecordID := 0;
	ArEventLogWrite_0.AddDataSize := brsstrlen(ADR(sLogString)) + 1;
	ArEventLogWrite_0.AddDataFormat := arEVENTLOG_ADDFORMAT_TEXT;
	ArEventLogWrite_0.AddData := ADR(sLogString);
	ArEventLogWrite_0.TimeStamp := 0;
	// synchronous FB -> this is the reason why I can trust the FB has finished already after one call !!
	ArEventLogWrite_0(Execute := TRUE);
	IF ArEventLogWrite_0.Error = TRUE THEN
		status := rtmodmon_STATUS_ERR_AREVLOGWRITE;
		statusInfo1 := ArEventLogWrite_0.StatusID;
		statusInfo2 := cntidx;
	END_IF	
	ArEventLogWrite_0(Execute := FALSE);
END_ACTION