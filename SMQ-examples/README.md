# SMQ Examples

## Overview

Simple Message Queue (SMQ) is an IoT and machine-to-machine publish/subscribe protocol designed for easy and secure device communication. See the [online SMQ documentation](https://realtimelogic.com/ba/doc/?url=SMQ.html) for a general introduction.

This README is an index for the SMQ examples collected in this repository.

## Files

- [One-to-One communication](one2one/README.md) - Direct browser-to-server communication and the foundation for more advanced examples.
- [REST / AJAX / RPC over SMQ](RPC/README.md) - Browser-to-server method calls built on top of SMQ.
- [Light bulb app and light switch app](LightSwitch-And-LightBulb-App/README.md) - Companion code for the embedded-device tutorial.
- [Cluster example](cluster/README.md) - Local clustering and redundancy experiment.
- [IoT directory](IoT/README.md) - Chat and LED-control tutorials.
- [Using Vue.js](https://github.com/RealTimeLogic/SMQ-LED-Vue.js) - Additional external example.
- [Using Java](https://github.com/RealTimeLogic/JavaSMQ) - Additional external example.
- [Using C Code](https://github.com/RealTimeLogic/SMQ) - Additional external example.

## How to run

There is no single startup command for the whole `SMQ-examples` directory. Open the README in the specific subdirectory you want to run and use the command listed there.

## How it works

The subdirectories demonstrate different communication patterns on top of the same SMQ model. Some focus on browser-to-server request/response flows, others on browser-to-browser or browser-to-device messaging, and the cluster example expands the idea into multi-node setups.

## Notes / Troubleshooting

- If you are new to SMQ, start with `one2one/` or `IoT/` first.
- The [SMQ API documentation](https://realtimelogic.com/ba/doc/?url=SMQ.html) is the best reference for topic names, subtopics, and publish/subscribe behavior.
