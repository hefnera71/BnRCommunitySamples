
(*
	FUNCTION:
	* checks binary modules if address has changed (because of download / reload
	* creates logger entries if binaries and / or address have changed
	* outputs an overview of the monitored modules and signals changes 
	** if binary and address has changed = module was transferred after compiling
	** if only address has changed = module was unloaded and reloaded because of the transfer of another module (e.g. only lib was transferred, but all tasks using the were unloaded and reloaded)
	* the deletion of modules isn't monitored!!
	IMPORTANT:
	* if using "logAllModules = FALSE", only modules of typ 17 (=task) and 18 (=library) are monitored -- for most applications this is the usecase needed
	** type 18 (=library) covers User libraries and B&R libraries, we can't distinguish that!
	* if using "logAllModules = TRUE", maybe you have to INCREASE THE BUFFERS by increasing value of constant "rtmodmon_MOD_IMAGE_MAXIDX" and rebuild! 
 	INFO:
	* the FB checks only one module per cycle, because it works with some loops and has to find strings in array - more then one module per cycle is too much load
	
 *)

FUNCTION_BLOCK ModuleMonitoring

	IF EDGEPOS(enable) = TRUE THEN
		status := rtmodmon_STATUS_RUNNING;
		statusInfo1 := 0;
		statusInfo2 := 0;
		cntidx := 0;
		// clear module memory!!
		brsmemset(ADR(ModuleImage), 0, SIZEOF(ModuleImage));
		// synchronous FB -> this is the reason why I can trust the FB has finished already after one call !!
		ArEventLogGetIdent_0(Execute := TRUE, Name := '$$arlogusr');
	END_IF

	IF enable = FALSE THEN
		// fb disabled
		status := rtmodmon_STATUS_STOPPED;
		statusInfo1 := 0;
		statusInfo2 := 0;
	ELSE		
		IF EDGEPOS(resetCountersFlags) = TRUE THEN
			// reset overview image
			FOR kk := 0 TO SIZEOF(ModuleOverview)/SIZEOF(ModuleOverview[0]) -1 DO
				ModuleOverview[kk].changedAddr := ModuleOverview[kk].changedBin := FALSE;
			END_FOR
			// reset counters and status infos
			differenceCounter := 0;
			status := rtmodmon_STATUS_RUNNING;
			statusInfo1 := 0;
			statusInfo2 := 0;
		END_IF

		DTGetTime_0(enable := TRUE);
		IF cntidx = 0 THEN
			prev_index := 16#FFFF;	// needed for first call of MO_list
			checkComplete := FALSE; // reset complete flag
		END_IF

		// read 
		ModuleToCheck.statusMOList := MO_list(prev_index, ADR(index), ADR(ModuleToCheck.Info.MOList_info));
		IF 	ModuleToCheck.statusMOList = 0 THEN
			prev_index := index;
			ModuleToCheck.Info.index := index;
			// only for tasks and libs, or all modules?
			IF (ModuleToCheck.Info.MOList_info.type = 17 OR ModuleToCheck.Info.MOList_info.type = 18) OR logAllModules = TRUE THEN
				brsmemcpy(ADR(sTmpModuleName),ADR(ModuleToCheck.Info.MOList_info.name),SIZEOF(sTmpModuleName));
				MO_info_0(enable := TRUE, pName := ADR(sTmpModuleName), grp := 0);
				ModuleToCheck.statusMOInfo := MO_info_0.status;
				IF ModuleToCheck.statusMOInfo = 0 THEN
					brsmemcpy(ADR(sTmpModuleVersion),ADR(MO_info_0.version),SIZEOF(MO_info_0.version));
					ModuleToCheck.Info.MOInfo_info.sVersion := sTmpModuleVersion;
					ModuleToCheck.Info.MOInfo_info.tRtcDT := MO_info_0.date;
					ModuleToCheck.Info.MOInfo_info.uSize := MO_info_0.size;

					imgidx := 16#FFFF; // information of imgidx is not valid at this point in code
					// module data to string -- here, only needed for wathc / breakpoint debugging!
					ActionGetModBaseData;
					
					// search for module in image
					bFoundOrNew := FALSE;
					FOR imgidx := 0 TO SIZEOF(ModuleImage)/SIZEOF(ModuleImage[0]) - 1 DO
						IF brsmemcmp(ADR(ModuleImage[imgidx].Info.MOList_info.name),ADR(ModuleToCheck.Info.MOList_info.name),SIZEOF(ModuleToCheck.Info.MOList_info.name)) = 0 THEN
							ModuleImage[imgidx].dtLastCheck := DTGetTime_0.DT1;
							// FOUND --> now compare
							IF ModuleImage[imgidx].Info.MOList_info.adress <> ModuleToCheck.Info.MOList_info.adress THEN
								// different address!!!
								ModuleImage[imgidx].uCountModAddressChanged := ModuleImage[imgidx].uCountModAddressChanged + 1;
								ModuleImage[imgidx].dtLastChange := DTGetTime_0.DT1;
								differenceCounter := differenceCounter + 1;
								// module data to string
								ActionGetModBaseData;

								brsstrcat(ADR(sLogString), ADR(' ->addr act:'));
								brsitoa(ModuleToCheck.Info.MOList_info.adress, ADR(sTmpString));
								brsstrcat(ADR(sLogString), ADR(sTmpString));
								brsstrcat(ADR(sLogString), ADR(' last:'));
								brsitoa(ModuleImage[imgidx].Info.MOList_info.adress, ADR(sTmpString));
								brsstrcat(ADR(sLogString), ADR(sTmpString));
								
								ArEventLogWrite_0.ObjectID := 'brmod_addr_change';
								// copy to overview
								ModuleOverview[imgidx].changedAddr := TRUE;

								// now check compile stamp (if module was recompiled and because of that transfered)
								IF brsmemcmp(ADR(ModuleImage[imgidx].Info.MOInfo_info.tRtcDT),ADR(ModuleToCheck.Info.MOInfo_info.tRtcDT),SIZEOF(ModuleToCheck.Info.MOInfo_info.tRtcDT)) <> 0 THEN
									
									// module header was changed
									ModuleImage[imgidx].uCountModInfoChanged := ModuleImage[imgidx].uCountModInfoChanged + 1;				
									ArEventLogWrite_0.ObjectID := 'brmod_bin_and_addr_change';

									brsstrcat(ADR(sLogString), ADR(' ->bin act:'));
									refModuleChangeRuntimeInfo ACCESS ADR(ModuleToCheck.Info);
									// module header data to string
									ActionGetStrModData;
									
									brsstrcat(ADR(sLogString), ADR(' last:'));
									refModuleChangeRuntimeInfo ACCESS ADR(ModuleImage[imgidx].Info);
									// module header data to string
									ActionGetStrModData;

									// copy to overview
									ModuleOverview[imgidx].changedBin := TRUE;
								END_IF

								IF ArEventLogGetIdent_0.Done = TRUE AND ArEventLogGetIdent_0.Error = FALSE THEN
									ArEventLogWrite_0.EventID := 1611595776; // custom, information, Fac = 15, Code = 0
									// write logger entry
									ActionWriteModDataToLogger;
								ELSE
									status := rtmodmon_STATUS_ERR_AREVLOGIDENT;
									statusInfo1 := ArEventLogGetIdent_0.StatusID;
									statusInfo2 := cntidx;
								END_IF
								
								// after comparison, copy actual module data
								brsmemcpy(ADR(ModuleImage[imgidx].Info), ADR(ModuleToCheck.Info), SIZEOF(ModuleImage[imgidx].Info));
							END_IF
							bFoundOrNew := TRUE;
							EXIT;
						ELSIF ModuleImage[imgidx].Info.MOList_info.name[0] = 0 THEN
							// end of list reached ... module is a new one, insert!!
							brsmemcpy(ADR(ModuleImage[imgidx]), ADR(ModuleToCheck), SIZEOF(ModuleImage[imgidx]));
							// copy to overview
							ModuleOverview[imgidx].name := sTmpModuleName;
							
							// log new ones if configured
							IF logNewModules = TRUE THEN
								// synchronous FB -> this is the reason why I can trust the FB has finished already after one call !!
								ArEventLogGetIdent_0(Execute := TRUE, Name := '$$arlogusr');
								IF ArEventLogGetIdent_0.Done = TRUE AND ArEventLogGetIdent_0.Error = FALSE THEN
									// 2022-04-20 dereference to get also here access to module data
									refModuleChangeRuntimeInfo ACCESS ADR(ModuleToCheck.Info);
									// module data to string 
									ActionGetModBaseData;
									// 2022-04-20 add module info also
									ActionGetStrModData;
									
									ArEventLogWrite_0.EventID := 537853952; // custom, success, Fac = 15, Code = 0
									ArEventLogWrite_0.ObjectID := 'brmod_add_to_monitoring';
									// write logger entry
									ActionWriteModDataToLogger;
								END_IF
							END_IF
							bFoundOrNew := TRUE;
							EXIT;
						ELSE
							// not the right one, do nothing but go on!
						END_IF
					END_FOR	
												
					// ending up here and nothing found and nothing inserted ... image array is too small!!
					IF bFoundOrNew = FALSE THEN
						// error "list full or fragmented"
						status := rtmodmon_STATUS_ERR_BUFFER_FULL;
						statusInfo1 := 0;
						statusInfo2 := cntidx;
					END_IF
				ELSE
					// error mover!
					status := rtmodmon_STATUS_ERR_MOLIST;
					statusInfo1 := ModuleToCheck.statusMOInfo;
					statusInfo2 := cntidx;
				END_IF
			END_IF
			cntidx := cntidx + 1;
		ELSE
			// if error = 3332 means "end of list"
			IF ModuleToCheck.statusMOList = 3332 THEN
				lastImageIdx := imgidx;
				cntidx := 0;
				checkComplete := TRUE; // set complete flag for one cycle to signal that all modules are checked
			ELSE
				// error molist!
				status := rtmodmon_STATUS_ERR_MOLIST;
				statusInfo1 := ModuleToCheck.statusMOList;
				statusInfo2 := cntidx;
			END_IF
		END_IF
	END_IF
	
	

END_FUNCTION_BLOCK
