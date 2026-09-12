# Sparkplug Examples

These applications demonstrate publishing node and device metrics and monitoring Sparkplug traffic with Mako Server or Xedge. They use the optional `SparkplugB` Lua plugin.

The [Sparkplug API reference](https://realtimelogic.com/ba/doc/en/lua/Sparkplug.html) documents the functions, input/output types, errors, events, payload formats and current limitations. Review those limitations before integrating the plugin.

The canonical [plugin source](https://github.com/RealTimeLogic/BAS-Resources/blob/main/src/sparkplug/SparkplugB.lua) and [protobuf schema](https://github.com/RealTimeLogic/BAS-Resources/blob/main/src/sparkplug/sparkplug_b.proto) remain in BAS-Resources. This directory contains the example applications.

## Files and prerequisites

- [EoN/.preload](EoN/.preload): example node that publishes metrics and receives commands.
- [SparkplugExplorer/.preload](SparkplugExplorer/.preload): console monitor for Sparkplug traffic.
- [doc/wfm-sparkplug-modules.png](doc/wfm-sparkplug-modules.png): historical resource-directory illustration; use the module names below for the current plugin.

The runtime must include the native `pb` module and the Lua modules `protoc`, `SparkplugB`, `EventEmitter` and MQTT clients. The resource file `.lua/sparkplug_b.proto` must be available through `ba.openio"vm"`. The Explorer also needs `serpent`. Availability depends on how Mako or Xedge was built and packaged; loading `SparkplugB` throws if its protobuf dependencies or schema are unavailable.

Use an MQTT broker accessible from the runtime. Configure the broker address and credentials in the selected example's `.preload` before starting it. The supplied public-broker settings are demonstration settings.

## How to run

Run one application from the `Sparkplug` directory:

```bash
# Monitor the configured broker; decoded messages appear in the console.
mako -l::SparkplugExplorer
```

```bash
# Run the example Edge of Network node against its configured broker.
mako -l::EoN
```

The Explorer prints incoming topics and decoded payloads, or a decode error. No traffic in the Explorer can simply mean no matching messages were published. See [Mako's application-loading options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp) for command-line details.

## Configuring the examples

Edit the selected application's `.preload` before starting it. Use the same broker for both applications so the Explorer can see the node's messages.

| Application | Settings in `.preload` |
| --- | --- |
| EoN | **string addr** is the broker address; **string groupId** and **string nodeName** identify this node; **string deviceId** identifies its one device. **table op** contains connection options, including the example's **string username** and **string password**. Replace the sample metrics and command handlers for your application. |
| SparkplugExplorer | **string mqttServer** is the broker address. **string mqttVer** selects `mqttc` (MQTT 5) or `mqtt3c` (MQTT 3.1.1). **string username** and **string password** are the example credentials. The Explorer subscribes to `spBv1.0/#`. |

Connection options and event behavior are described in the [API reference](https://realtimelogic.com/ba/doc/en/lua/Sparkplug.html#function-reference). The node example supplies its birth messages in its `birth` handler. The Explorer displays traffic; it does not create a node or publish birth messages.

The node shares its two sample metric values with its device. Accepted NCMD/DCMD updates publish both node and device data. Commands must match a known metric name and datatype and provide a numeric value; commands for other devices are ignored. Adapt this shared-state example when your node and devices have independent values. Both applications stop their clients from `onunload()`.

## Validation

Tested with native Windows Mako Server and a local Mosquitto 2.0.11 broker, using the current BAS-Resources plugin. Both Explorer modes (`mqttc` and `mqtt3c`) received and decoded node/device messages. Tests covered commands, ignored device/type mismatches, rebirth, STATE text, malformed payload reporting, broker restart recovery and repeated cleanup. Deferred Explorer startup and cleanup also passed normal and Lua32 tests.

The live tests used loopback broker settings in temporary copies. They did not exercise the supplied public broker, TLS, Xedge package installation or ESP32 hardware.

## Packaging for Xedge

Package the selected application directory, not the parent `Sparkplug` directory. See [Xedge App Deployment](../Xedge-App-Deployment/README.md) for the full workflow.

```bash
# From Sparkplug/EoN, package this app root with .preload at the ZIP root.
zip -D -q -u -r -9 ../sparkplug-eon.zip .
```

```bash
# From Sparkplug/SparkplugExplorer, package the console-monitor app root.
zip -D -q -u -r -9 ../sparkplug-explorer.zip .
```

Upload the selected ZIP with Xedge's App Upload tool. The target runtime still needs the native protobuf module and plugin resources listed under prerequisites.
