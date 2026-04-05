Unlike some existing, great solutions to deserialize and serialize JSON strings directly to PLC variable structures,
in my usescase I needed to inspect and work with many different JSON responses, that additionally frequently change their structure.

So I decided to deserialize the JSON responses into a flat array of a structure, where each element contains some basic information like...
* name of an element
* value of an element
* type of an element
* order and path information inside the JSON structure
... so that I can react to the informations in the code without changing variable declarations.

Basic usage:
		// deserialize the JSON content in "sTestString" into array "jValues" of TinyJsonLibValues_typ[0..255]
		// result > 0 --> number of array elements containing data
		// result < 0 --> error, please see description in TinyJsonLb->Constants.var
		result := TinyJsonDump(ADR(sTestString), ADR(jValues), SIZEOF(jValues), 0);
		// --> see SampleScreenshotTinyJsonLb
		
		// deserialize JSON sub-element 'StatusSTS:Wifi' content into array "jValues" of TinyJsonLibValues_typ[0..255]
		// result > 0 --> number of array elements containing data
		// result < 0 --> error, please see description in TinyJsonLb->Constants.var
		result := TinyJsonDump(ADR(sTestString), ADR(jValues), SIZEOF(jValues), ADR('StatusSTS:Wifi'));
		// --> see SampleScreenshotTinyJsonLb2