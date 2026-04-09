# Intention
Some already existing, great solutions out there are build to deserialize (and serialize) JSON strings directly to PLC variable structures.
But in my usescase, I just needed to deserialize and to inspect and work with many different JSON responses that additionally frequently change their structure.

So I decided to write my own function to deserialize the JSON responses (based on [tiny-json](https://github.com/rafagafe/tiny-json)) into a flat array of a structure, where each element contains some basic information like...
* name of an element
* value of an element
* type of an element
* order and path information inside the JSON structure
  
... so that I can react to the informations in the JSON object without changing PLC variable declarations.

# Content of the AS package "JsonReader"
* the AS library "TinyJsonLb" exporting the function "TinyJsonDump()", which deserializes a JSON string
* the AS task "UsageTJlb", which just contains some basic test calls

# Version history

V1.00.2
* introduced "$ROOT" object, when root node is of complex type
  * if existing (root node != simple element), then always in result array at index [0])
  * helpful if you need to know the root object type (tjJSON_ARRAY or tjJSON_OBJECT)
* FIX: pagefault caused by NULL pointer
* FIX: right handling of JSON structures like "array of objects" and similar
* CHANGE: removed JSON array index number (as it's not working under all conditions, I'm sorry)
* CHANGE: all internal generated entries in the result array, which are not directly derived from the JSON input data, are starting with "~"
  * ~$ROOT (entered in "key" and/or "value" element = token is the root node)
  * ~[..] (entered in "key" element = token is an array element)
  * ~ARRAY (entered in "value" element = token is start of an array) 
  * ~OBJECT (entered in "value" element = token is start of an object)

V1.00.0
* initial release

# Known limitations
* path information and / or key cannot resolve array index 
* direct reading of sub-elements of type or containing "array element" using "< optional: path of JSON sub-element >" parameter is not possible
* maximum size of JSON input string is 8192 byte (to adapt, change "tinyjson_DATA_BUFFER_SIZE" value and recompile)
* maximum number of tokens in JSON is 256 (to adapt, change "tinyjson_T_MEM_SIZE" value and recompile)

# How to use
* import the library "TinyJsonLn"
* declare an array of structure of type "TinyJsonLibValues_typ" (which is defined by "TinyJsonLb") as result memory
* call the function
> TinyJsonDump( < address of string containing the JSON data > , < address of result array > , < sizeof result array > , < optional: path of JSON sub-element > );

## Example 1 - read complete JSON object
```
VAR
	jValues : {REDUND_UNREPLICABLE} ARRAY[0..255] OF TinyJsonLibValues_typ;
	result : DINT;
END_VAR
```

```
// deserialize the JSON content in "sTestString" into array "jValues" of TinyJsonLibValues_typ[0..255]
// result > 0 --> number of array elements containing data
// result < 0 --> error, please see description in TinyJsonLb->Constants.var

result := TinyJsonDump(ADR(sTestString), ADR(jValues), SIZEOF(jValues), 0);
```

![./UsageTJlb/SampleScreenshotTinyJsonLb.png](UsageTJlb/SampleScreenshotTinyJsonLb.png)

## Example 2: read sub-element from JSON object
```
VAR
	jValues : {REDUND_UNREPLICABLE} ARRAY[0..255] OF TinyJsonLibValues_typ;
	result : DINT;
END_VAR
```

```
// deserialize JSON sub-element 'StatusSTS:Wifi' content into array "jValues" of TinyJsonLibValues_typ[0..255]
// result > 0 --> number of array elements containing data
// result < 0 --> error, please see description in TinyJsonLb->Constants.var

result := TinyJsonDump(ADR(sTestString), ADR(jValues), SIZEOF(jValues), ADR('StatusSNS:ENERGY'));
```
![./UsageTJlb/SampleScreenshotTinyJsonLb.png](UsageTJlb/SampleScreenshotTinyJsonLb2.png)


