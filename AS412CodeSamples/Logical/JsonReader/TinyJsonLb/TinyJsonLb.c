/*
	Copyright (c) 2025 Alexander Hefner
	Licensed under the MIT License - see LICENSE.txt file for details

	This implementation uses <https://github.com/rafagafe/tiny-json>
	Licensed under the MIT License <http://opensource.org/licenses/MIT>.
	SPDX-License-Identifier: MIT
	Copyright (c) 2016-2018 Rafa Garcia <rafagarcia77@gmail.com>.
*/

#include <bur/plctypes.h>
#include <asbrstr.h>
#include <string.h>

#ifdef __cplusplus
	extern "C"
	{
#endif
#include "TinyJsonLb.h"
#ifdef __cplusplus
	};
#endif

#include <TinyJsonLb.h>
#include "./TinyJson/tiny-json.h"

static int CheckAndCopyDestStr(UDINT pDest, UDINT sizeDest, UDINT pSrc)
{
	int result = -1;
	if (sizeDest > 2){
		if (brsstrlen(pSrc)	< sizeDest)
		{
			brsstrcpy(pDest, pSrc);
			result = 0;		
		}
		else
		{
			brsstrcpy(pDest, (UDINT)"~E");
		}
	}
	return result;
}

/*
json_t const* json			-> parsed json object from TinyJson
jsonType_t parentType		-> json element type of the parent object
UINT* jIndex				-> index of the destination data array element where results are copied to
UINT jMaxElements			-> number of destination array elements
TinyValues_typ* jOutput		-> pointer to the destination array
UINT* jOrder				-> depth of the json element
INT* jArrayIndex			-> array index of a json element (if element is array) - needed to know if an element is an array element
char* jPath					-> pointer to a temporary variable building the path - needed because of using strrchr which manipulates the source memory
BOOL* errDestIndex			-> not enough space in destination
*/
static void dump(json_t const* json, jsonType_t parentType, UINT* jIndex, UINT jMaxElements, TinyJsonLibValues_typ* jOutput, UINT* jOrder, INT* jArrayIndex, char* jPath, BOOL* errDestIndex)
{
	json_t const* child;
	TinyJsonLibValues_typ* pjData = jOutput;
	
	for( child = json_getChild( json ); child != 0; child = json_getSibling( child ) ) {

		jsonType_t propertyType = json_getType( child );

		if (*jIndex < jMaxElements)	// check array index bounds
		{
			pjData = jOutput + *jIndex;

			pjData->type = (DINT)propertyType;
			pjData->order = *jOrder;
			CheckAndCopyDestStr((UDINT)&pjData->path, sizeof pjData->path, (UDINT)jPath);
			
			char const* name = json_getName( child );
			if ( name )
			{
				// copy here to plc struct;
				CheckAndCopyDestStr((UDINT)&pjData->key, sizeof pjData->key, (UDINT)name);
			}
			else
			{
				if (*jArrayIndex > -1)
				{
					char sArrayIndex[7] = {0};
					brsitoa(*jArrayIndex, (UDINT)sArrayIndex);
					char sArrayStr[10] = {0};
					brsstrcpy((UDINT)sArrayStr, (UDINT)"~[");
					brsstrcat((UDINT)sArrayStr,(UDINT)sArrayIndex);
					brsstrcat((UDINT)sArrayStr, (UDINT)"]");
					CheckAndCopyDestStr((UDINT)&pjData->key, sizeof pjData->key, (UDINT)sArrayStr);
					(*jArrayIndex)++;
				}
			}

			if ( propertyType == JSON_OBJ || propertyType == JSON_ARRAY )
			{
				// add a type info in value field, if type is a complex one
				if ( propertyType == JSON_ARRAY)
				{
					CheckAndCopyDestStr((UDINT)&pjData->value, sizeof pjData->value, (UDINT)"~ARRAY");
					*jArrayIndex = 0;
				}
				else
				{
					CheckAndCopyDestStr((UDINT)&pjData->value, sizeof pjData->value, (UDINT)"~OBJECT");
				}
				
				(*jIndex)++;
				(*jOrder)++;
				if (brsstrlen((UDINT)jPath) > 0) { brsstrcat((UDINT)jPath, (UDINT)":"); }
				brsstrcat((UDINT)jPath, (UDINT)name);
				dump( child, propertyType, jIndex, jMaxElements, jOutput, jOrder, jArrayIndex, jPath, errDestIndex );
			}
			else
			{
				char const* value = json_getValue( child );
				if ( value ) {
					// copy here to plc struct;
					CheckAndCopyDestStr((UDINT)&pjData->value, sizeof pjData->value, (UDINT)value);
				}

				(*jIndex)++;
			}
		}
		else
		{
			// destination array too small!
			*errDestIndex = 1;
		}
	}
	
	(*jOrder)--;
	*jArrayIndex = -1;
	// manipulate path string
	char* x = strrchr(jPath, ':');
	if (x != NULL) *x = 0;
}

DINT TinyJsonDump(UDINT pJsonString, UDINT pResultArray, UDINT resultArraySize, UDINT pElementName)
{
	DINT result = -1;
	
	// error: at least one input parameter is 0
	if (pJsonString == 0 || pResultArray == 0 || resultArraySize == 0) { return tinyjsonERR_PARAMETERINVALID; }
	// error: json input string bigger then internal buffer
	if (brsstrlen(pJsonString) >= tinyjson_DATA_BUFFER_SIZE) {return tinyjsonERR_JSONINPUTTOOLARGE; }

	UINT jMaxElements = resultArraySize /sizeof(TinyJsonLibValues_typ);
	// error: something is wrong, maybe array type declaration or size?
	if (jMaxElements == 0) { return tinyjsonERR_DESTARRAYINVALID; }

	// WARNING: source memory is changed by tiny_json - so we have to copy it before to a own buffer !!
	// TODO: can this be allocated?
	static char data[tinyjson_DATA_BUFFER_SIZE]; // my test buffer to copy origin data into 
	brsmemset((UDINT)data, 0, sizeof data);
	// copy input data to internal buffer
	brsmemcpy((UDINT)data, pJsonString, brsstrlen(pJsonString));

	// clean up destination array
	brsmemset(pResultArray, 0, resultArraySize);

	// TODO: can this be allocated?
	static json_t mem[tinyjson_T_MEM_SIZE];
	brsmemset((UDINT)&mem, 0, sizeof mem);

	// parse json data
	json_t const* jsonRoot = json_create(data, mem, sizeof mem / sizeof *mem);
	if (jsonRoot)
	{
		
		json_t const* json = NULL;
		
		UINT jElementIndex = 0;
		UINT jElementOrder = 0;
		INT jElementArrayIndex = -1;
		BOOL errDestIndex = 0;
		// TODO: can this be allocated?
		static char pathStr[tinyjson_PATH_BUFFER_SIZE];
		brsmemset((UDINT)pathStr, 0, sizeof pathStr);
		
		if (pElementName != 0 && brsstrlen(pElementName) > 0)
		{
			// TODO: can this be allocated?
			static char inputPathStr[tinyjson_PATH_BUFFER_SIZE];
			brsmemset((UDINT)pathStr, 0, sizeof inputPathStr);
			
			// tokenize the elemnt input path and create the json objects needed
			if (brsstrlen(pElementName) < sizeof inputPathStr)
			{
				brsstrcpy((UDINT)inputPathStr, pElementName);
				json_t const* jsonElement = jsonRoot;				
				
				char* token = strtok(inputPathStr, ":");
				while (token != NULL)
				{
					
					jsonElement = json_getProperty(jsonElement, (char const*)token);
					token = strtok(NULL, ":");
				}
				json = jsonElement;
			}
		}
		else
		{
			// dump all
			json = jsonRoot;
		}
		
		if (json != NULL)
		{
			jsonType_t type = json_getType( json );
			if ( type == JSON_OBJ || type == JSON_ARRAY )
			{
				// read out all json (sub-)elements
				dump(json, JSON_NULL, &jElementIndex, jMaxElements, (TinyJsonLibValues_typ*)pResultArray, &jElementOrder, &jElementArrayIndex, pathStr, &errDestIndex);
				if (!errDestIndex)
				{
					result = jElementIndex;
				}
				else
				{
					// error: destination array too small
					result = tinyjsonERR_DESTARRAYTOOSMALL; 
				}
			}
			else
			{
				// is basic type, so just use element[0] of result array
				TinyJsonLibValues_typ* entry0 = (TinyJsonLibValues_typ*) pResultArray;
				entry0->type = type;
				char const* name = json_getName( json );
				if ( name )
				{
					// copy here to plc struct;
					CheckAndCopyDestStr((UDINT)&entry0->key, sizeof entry0->key, (UDINT)name);
				}
				char const* value = json_getValue( json );
				if ( value ) {
					// copy here to plc struct;
					CheckAndCopyDestStr((UDINT)&entry0->value, sizeof entry0->value, (UDINT)value);
				}
				result = 1;
			}
		}
		else
		{
			// error: json element is invalid or not found
			result = tinyjsonERR_JSONELEMENTINVALID;
		}
	}
	else
	{
		// error json input string is invalid
		result = tinyjsonERR_JSONINPUTINVALID;
	}
	
	return result;
}