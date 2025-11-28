
{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK ParseForNameValueTuples (*parse a content for <name>=<value> tuples, e.g. a "config file" --> see the example how the content has to look like
!!! PLEASE NOTE: the complete parsing = looping through the data is done in ONE CYCLE - could lead to cycle time violation if used in cyclic code !!!*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pContentToParse : {REDUND_UNREPLICABLE} UDINT; (*pointer to the memory, where the content to parse is stored*)
		contentLength : {REDUND_UNREPLICABLE} UDINT; (*length of the content*)
	END_VAR
	VAR_OUTPUT
		status : {REDUND_UNREPLICABLE} UINT; (*0 = success, negative value = error*)
		sOutput : {REDUND_UNREPLICABLE} ARRAY[0..99] OF sParsed_struct; (*structure of type sParsed_struct holding the <name>=<value> parse result*)
		uParseUnwantedChar : {REDUND_UNREPLICABLE} UINT; (*number of not-allowed characters found while parsing*)
	END_VAR
	VAR
		uArrayIndex : {REDUND_UNREPLICABLE} USINT;
		uCharIndex : {REDUND_UNREPLICABLE} UDINT;
		uResultCharIndex : {REDUND_UNREPLICABLE} UDINT;
		bSkipComment : {REDUND_UNREPLICABLE} BOOL;
		uMaxResultLength : {REDUND_UNREPLICABLE} UDINT;
		pResultMemory : {REDUND_UNREPLICABLE} UDINT;
		dynInputChar : REFERENCE TO USINT;
		dynOutputChar : REFERENCE TO USINT;
	END_VAR
END_FUNCTION_BLOCK
