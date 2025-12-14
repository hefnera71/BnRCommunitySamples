# BnRCommunitySamples

This repository is intended to make some of my functions / samples already published in the [B&R Community](https://community.br-automation.com/), but also some new stuff, easier accessible and maintainable. 

By now, the repository "BnRCommunitySamples" contains a B&R Automation Studio 4.12 project named "AS412CodeSamples", which bundles some assorted libraries and sample tasks.

## Getting Started

* The Automation Studio project itself serves only for code administration and has no overarching functionality
* The Logical View of the "AS412CodeSamples" project is organized in packages
  * each package contains the library / function implementation and/or a sample task + some additional information / documentation (if available)
  * each package should therefore be usable independently of the "AS412CodeSamples" project (B&R standard libraries used by the libraries / tasks have to be added in your own project).

## Description

Here's a very short description abount the content of each package:
* "XTEA" - a lean symmetric block cipher encryption / decryption
* "SHA256" - hash algorithm
* "TBSWAstro" - calculation of sunrise / sunset at a specific date
* "WebPing" - Web frontend to ping from plc
* "Pushover" - send pushmessages via pushover.net
* "ModuleMonitoring" - log BR module changes in logger
* "PCLTCP" - Raw ASCII printing via network
* "TasmotaWebservice" - A simple webservice library to communicate with [Tasmota devices](https://tasmota.github.io/docs/)
* "ProfilerConfig" - configure the AR profiler by code at startup using an external configuration file
* "LoggerDataReading" - read entries from loggers to a own variable structure, including some filter possiblities
  * "WebserviceUsingReadEvLog" - a webservice that uses ReadEvLog library to provide a webbased access for the logger modules
* "_UNDER_CONSTRUCTION" - Programs and packages not finished yet
  * "Simple_MQTTV3_QoS0only_Client" - a basic mqtt V3 client implementation - by now, only QoS 0 is possible, no retaining, no TLS security

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
