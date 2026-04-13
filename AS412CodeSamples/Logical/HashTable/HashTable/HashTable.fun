
{REDUND_ERROR} FUNCTION InternalGenStrHash : DINT (*calculate hash from string - only needed internally*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pString : UDINT; (*pointer to string to hash*)
		hashModulo : UDINT; (*number of fields insode the  the hash table = array size*)
	END_VAR
	VAR
		pNext : UDINT;
		usChar : REFERENCE TO USINT;
		udSum : UDINT;
		usPrimeIndex : USINT;
	END_VAR
	VAR CONSTANT
		uPrimeFactor : ARRAY[0..99] OF UINT := [257,263,269,271,277,281,283,293,307,311,313,317,331,337,347,349,353,359,367,373,379,383,389,397,401,409,419,421,431,433,439,443,449,457,461,463,467,479,487,491,499,503,509,521,523,541,547,557,563,569,571,577,587,593,599,601,607,613,617,619,631,641,643,647,653,659,661,673,677,683,691,701,709,719,727,733,739,743,751,757,761,769,773,787,797,809,811,821,823,827,829,839,853,857,859,863,877,881,883,887];
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION InsertStrPToHashTab : DINT (*add a string to the hash table*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		ident : UDINT; (*ident from INIT_StrHashTab*)
		pString : UDINT; (*pointer to string to hash*)
		pData : UDINT; (*pointer to data associated with the string*)
		userTag : DINT; (*user tag (optional) - user can put in here a number, which is stored and read back. The number isn't processed by the libary function.*)
		multipleDataAllowed : BOOL; (*define if the "key" = hash string can have multiple data pointers associated to*)
	END_VAR
	VAR
		hashVal : DINT;
		bDataExit : BOOL;
		bExit : BOOL;
		AsMemPartAlloc_0 : AsMemPartAlloc;
		dEntryToInspect : REFERENCE TO HashTableFieldEntry_typ;
		dDataFieldToInspect : REFERENCE TO HashTableDataSubfield_typ;
		dTableEntryToInspect : REFERENCE TO HashTableBase_typ;
		dCollision : REFERENCE TO UINT;
		dInternal : REFERENCE TO _internalHashIdent_typ;
	END_VAR
END_FUNCTION

{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK FindStrPInHashTab (*find a string in the hash table*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		ident : {REDUND_UNREPLICABLE} UDINT; (*ident from INIT_StrHashTab*)
		pString : {REDUND_UNREPLICABLE} UDINT; (*pointer to string to find in the hash table*)
	END_VAR
	VAR_OUTPUT
		status : {REDUND_UNREPLICABLE} DINT; (*execution status, 0 = ok*)
		pData : {REDUND_UNREPLICABLE} UDINT; (*pointer to the data segment associated with the found string*)
		userTag : {REDUND_UNREPLICABLE} DINT; (*user defined DINT, optional*)
		pNextData : {REDUND_UNREPLICABLE} UDINT; (*pointer to the next dataset*)
		numberOfDatasets : {REDUND_UNREPLICABLE} UINT; (*Number of different data pointers associated with the found string*)
	END_VAR
	VAR
		hashVal : {REDUND_UNREPLICABLE} DINT;
		bExit : {REDUND_UNREPLICABLE} BOOL;
		dTableEntryToInspect : REFERENCE TO HashTableBase_typ;
		dEntryToInspect : REFERENCE TO HashTableFieldEntry_typ;
		dInternal : REFERENCE TO _internalHashIdent_typ;
	END_VAR
END_FUNCTION_BLOCK

{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK RemoveStrPFromHashTab (*remove a string from the hash table*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		ident : {REDUND_UNREPLICABLE} UDINT; (*ident from INIT_StrHashTab*)
		pString : {REDUND_UNREPLICABLE} UDINT; (*pointer to string to find in the hash table*)
	END_VAR
	VAR_OUTPUT
		status : {REDUND_UNREPLICABLE} DINT; (*execution status, 0 = ok*)
	END_VAR
	VAR
		hashVal : {REDUND_UNREPLICABLE} DINT;
		bExit : {REDUND_UNREPLICABLE} BOOL;
		dTableEntryToInspect : REFERENCE TO HashTableBase_typ;
		dEntryToInspect : REFERENCE TO HashTableFieldEntry_typ;
		dParentEntry : REFERENCE TO HashTableFieldEntry_typ;
		pParentEntry : {REDUND_UNREPLICABLE} UDINT;
		dInternal : REFERENCE TO _internalHashIdent_typ;
		pData : {REDUND_UNREPLICABLE} UDINT;
		pNextData : {REDUND_UNREPLICABLE} UDINT;
		pNext : {REDUND_UNREPLICABLE} UDINT;
		GetNextStrDataP_0 : {REDUND_UNREPLICABLE} GetNextStrDataP;
		AsMemPartFree_0 : {REDUND_UNREPLICABLE} AsMemPartFree;
		pThis : {REDUND_UNREPLICABLE} UDINT;
	END_VAR
END_FUNCTION_BLOCK

{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK INIT_StrHashTab (*ONLY FOR USE IN INIT PROGRAM: initialize functions*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		nrOfHashTableElements : {REDUND_UNREPLICABLE} UINT; (*number of elements in the hash table = number of "array elements" - should not be too small but depends on what to do, e.g. 256, 1024...*)
		collisionMemSize : {REDUND_UNREPLICABLE} UDINT; (*size of the additional memory needed (and allocated by the fb)*)
	END_VAR
	VAR_OUTPUT
		status : {REDUND_UNREPLICABLE} DINT; (*execution status, 0 = ok*)
		ident : {REDUND_UNREPLICABLE} UDINT; (*ident for all other functions*)
	END_VAR
	VAR
		internal : {REDUND_UNREPLICABLE} _internalHashIdent_typ;
		AsMemPartCreate_0 : {REDUND_UNREPLICABLE} AsMemPartCreate;
		AsMemPartAlloc_0 : {REDUND_UNREPLICABLE} AsMemPartAllocClear;
	END_VAR
END_FUNCTION_BLOCK

{REDUND_ERROR} FUNCTION EXIT_StrHashTab : DINT (*ONLY FOR USE IN EXIT PROGRAM: deinitialize functions*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		ident : UDINT; (*ident from INIT_StrHashTab*)
	END_VAR
	VAR
		dInternal : REFERENCE TO _internalHashIdent_typ;
		AsMemPartDestroy_0 : AsMemPartDestroy;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION GetHashTableInfo : DINT (*get some statistical info from the hash table*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		ident : UDINT; (*ident from INIT_StrHashTab*)
		pHashInfo : UDINT; (*pointer to a structure variable of HashTableInfo_typ*)
	END_VAR
	VAR
		dInternal : REFERENCE TO _internalHashIdent_typ;
		dHashInfo : REFERENCE TO HashTableInfo_typ;
		dTableEntryToInspect : REFERENCE TO HashTableBase_typ;
		dCollision : REFERENCE TO UINT;
		i : UDINT;
		AsMemPartInfo_0 : AsMemPartInfo;
	END_VAR
END_FUNCTION

{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK GetNextStrDataP (*access the next dataset after the actual one (only if more then one dataset was associated with a string - multipleDataAllowed = TRUE when inserting) *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		ident : {REDUND_UNREPLICABLE} UDINT; (*ident from INIT_StrHashTab*)
		pDataset : {REDUND_UNREPLICABLE} UDINT; (*address of the actual dataset (got from Find... fb or this function block)*)
	END_VAR
	VAR_OUTPUT
		status : {REDUND_UNREPLICABLE} DINT; (*execution status, 0 = ok*)
		pData : {REDUND_UNREPLICABLE} UDINT; (*pointer to the next data segment associated*)
		userTag : {REDUND_UNREPLICABLE} DINT; (*stored user defined DINT*)
		pNextData : {REDUND_UNREPLICABLE} UDINT; (*pointer to the next dataset*)
	END_VAR
	VAR
		dInternal : REFERENCE TO _internalHashIdent_typ;
		dNextDataset : REFERENCE TO HashTableDataSubfield_typ;
	END_VAR
END_FUNCTION_BLOCK
