# BnRCommunitySamples

This repository is intended to make some of my functions / samples already published in the [B&R Community](https://community.br-automation.com/), but also some new stuff, easier accessible and maintainable.

To quote Forrest Gump: "Life is like a box of chocolates - you never know what you're gonna get." :-)

By now, the repository "BnRCommunitySamples" contains a B&R Automation Studio 4.12 project named "AS412CodeSamples", which bundles some **assorted libraries and sample tasks**.
All content was developed for my private projects or educational reasons.

## Getting Started

* The Automation Studio project itself serves just for code administration and has no overarching functionality
* The Logical View of the "AS412CodeSamples" project is organized in packages
  * each package contains the library / function implementation and/or a sample task + some additional information / documentation (if available)
  * each package should therefore be usable independently of the "AS412CodeSamples" project (B&R standard libraries used by the libraries / tasks have to be added in your own project).

## Description

Here's a very short description abount the content of each package:
* "XTEA" - a lean symmetric block cipher encryption / decryption (how to use: see code comments in [sample task](AS412CodeSamples/Logical/XTEA/UsageXTea/Main.st) )
* "SHA256" - hash algorithm  (how to use: see [PDF](AS412CodeSamples/Logical/SHA256/Sha256lib%20en.pdf) ) 
* "TBSWAstro" - calculation of sunrise / sunset at a specific date (how to use: see [PDF](AS412CodeSamples/Logical/TBSWAstro/Library%20TBSWAstro%20en.pdf) ) 
* "WebPing" - Web frontend to ping from plc (how to use: see [Community post](https://community.br-automation.com/t/ping-from-a-plc-webservice-frontend/1063) )
* "Pushover" - send pushmessages via pushover.net (how to use: see code comments in sample task and [Community post](https://community.br-automation.com/t/push-notifications/8874/6?u=alexander.hefner) )
*  "ModuleMonitoring" - log BR module changes in logger (how to use: see [PDF](AS412CodeSamples/Logical/ModuleMonitoring/RtModMon.pdf) )
*  "PCLTCP" - Raw ASCII printing via network (how to use: see [PDF](AS412CodeSamples/Logical/PCLTCP/PCLTCP.pdf) and [Community post](https://community.br-automation.com/t/pcltcp-print-ascii-texts-directly-on-a-network-printer-that-supports-raw-printing-by-pcl-commands/9058) )
*  "TasmotaWebservice" - A simple webservice library to communicate with [Tasmota devices](https://tasmota.github.io/docs/) (how to use: see code comments in [sample task](AS412CodeSamples/Logical/TasmotaWebservice/UsageTasmo/Main.st) and [PDF](AS412CodeSamples/Logical/TasmotaWebservice/tasmotapi%20doc.pdf) )
*  "ProfilerConfig" - configure the AR profiler by code at startup using an external configuration file (how to use: see [sample configuration file](AS412CodeSamples/Logical/ProfilerConfig/profconf.setup) and [AS Library help](https://help.br-automation.com/#/en/6/libraries/asarprof/datatypes/constants_asarprof.html) )
*  "LoggerDataReading" - read entries from loggers to a own variable structure, including some filter possiblities (how to use: see code comments in [sample task](AS412CodeSamples/Logical/LoggerDataReading/UsagRdEvLg/Main.st) )
* "LoggerDataReading" --> "WebserviceUsingReadEvLog" - a webservice that uses ReadEvLog library to provide a webbased access for the logger modules (how to use: see [PDF](AS412CodeSamples/Logical/LoggerDataReading/WebserviceUsingReadEvLog/wsLogger%20informations.pdf) )
*  "_UNDER_CONSTRUCTION" - just a conatiner for programs and packages not finished yet
* "_UNDER_CONSTRUCTION" --> "Simple_MQTTV3_QoS0only_Client" - a basic mqtt V3 client implementation - by now, only QoS 0 is possible, no retaining, no TLS security (how to use: see code comments in [sample task](AS412CodeSamples/Logical/_UNDER_CONSTRUCTION/Simple_MQTTV3_QoS0only_Client/UsagRWPaho/Main.st) )

## Authors

* Alexander Hefner  
* Steffen Herderich (providing the first version of RWPahoMqtt)

## Version History

* 2025-12-14: Initial Release

## License
* All parts of this project, unless explicitly stated otherwise, are licensed under the MIT License - see the LICENSE file for details.
* The "MQTTpacket" package code (part of "RWPahoMqtt" library) and the accompanying materials are made available under the terms of the Eclipse Public License v1.0
and Eclipse Distribution License v1.0 which accompany this distribution.

## Acknowledgments

* [B&R Community](https://community.br-automation.com/)
* ["xtea" uses Wikipedia - XTEA reference algorithm](https://de.wikipedia.org/wiki/Extended_Tiny_Encryption_Algorithm)
* ["RWPahoMqtt" uses Ian Craggs - paho.mqtt.embedded-c](https://github.com/eclipse-paho/paho.mqtt.embedded-c/tree/master/MQTTPacket/src)
* ["SHA256lib" uses Brad Conte - Crypto algorithms](https://github.com/B-Con/crypto-algorithms)
* "TBSWAstro" uses SUNRISET.C released to the public domain by Paul Schlyter, December 1992
