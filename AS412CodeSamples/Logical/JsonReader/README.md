# Intention
Some already existing, great solutions out there are build to deserialize (and serialize) JSON strings directly to PLC variable structures.
But in my usescase, I just needed to deserialize and to inspect and work with many different JSON responses that additionally frequently change their structure.

So I decided to write my own function to deserialize the JSON responses (based on [tiny-json](https://github.com/rafagafe/tiny-json)) into a flat array of a structure, where each element contains some basic information like...
* name of an element
* value of an element
* type of an element
* order and path information inside the JSON structure
  
... so that I can react to the informations in the code without changing variable declarations.


# Basic usage

## Example 1 - read complete JSON object
```
// deserialize the JSON content in "sTestString" into array "jValues" of TinyJsonLibValues_typ[0..255]
// result > 0 --> number of array elements containing data
// result < 0 --> error, please see description in TinyJsonLb->Constants.var

result := TinyJsonDump(ADR(sTestString), ADR(jValues), SIZEOF(jValues), 0);
```

![./UsageTJlb/SampleScreenshotTinyJsonLb.png](UsageTJlb/SampleScreenshotTinyJsonLb.png)

## Example 2: read sub-element from JSON object
```
// deserialize JSON sub-element 'StatusSTS:Wifi' content into array "jValues" of TinyJsonLibValues_typ[0..255]
// result > 0 --> number of array elements containing data
// result < 0 --> error, please see description in TinyJsonLb->Constants.var

result := TinyJsonDump(ADR(sTestString), ADR(jValues), SIZEOF(jValues), ADR('StatusSTS:Wifi'));
```
![./UsageTJlb/SampleScreenshotTinyJsonLb.png](UsageTJlb/SampleScreenshotTinyJsonLb2.png)
