
FUNCTION TinyJsonDump : DINT (*Dump a JSON object string into array elements*)
	VAR_INPUT
		pJsonString : UDINT; (*address of the JSON input string*)
		pResultArray : UDINT; (*address of the result array (of type TinyJsonLibValues_typ[0..xx])*)
		resultArraySize : UDINT; (*size of the result array (sizeof TinyJsonLibValues_typ[0..xx])*)
		pElementName : UDINT; (*optional: path to a sub-element to dump (path elements divied by ":", format example: "rootname:subname:elementname")*)
	END_VAR
END_FUNCTION
