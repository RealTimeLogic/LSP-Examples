# Sparkplug Client Documentation

![Sparkplug Protocol Stack](https://realtimelogic.com/GZ/images/SparkplugStack.svg)


This document details the Lua library for the Sparkplug 3.0 MQTT client.

## Overview

The Sparkplug client is a Lua library designed to facilitate communication with an MQTT Server as per the [Sparkplug 3.0 Specification](https://sparkplug.eclipse.org/specification/version/3.0/documents/sparkplug-specification-3.0.0.pdf). It primarily functions as an MQTT Edge of Network (EoN) Node.

The [Sparkplug client library's source code](https://github.com/RealTimeLogic/BAS-Resources/blob/main/src/sparkplug/SparkplugB.lua) is included in the [Mako Server](https://makoserver.net/) and [Xedge](https://realtimelogic.com/ba/doc/?url=Xedge.html)


### What is MQTT Sparkplug

The Sparkplug specification provides a detailed explanation of what Sparkplug is, but the key points to know are as follows:

The specification provides guidelines for designing a topic namespace, packaging message payloads, and managing application state in MQTT-based systems for the industrial sector. It includes a topic namespace structure, a mechanism for state management using birth and last-will messages, and a payload structure using Google Protocol Buffers. The specification does not change MQTT itself, but rather defines aspects of it that were left open for the end user to decide on. The Sparkplug infrastructure includes an MQTT broker, a management application, and MQTT Edge of Network Nodes (EoN).

The management application, called the Primary Application, is a SCADA/IIoT Host Node that receives data from Sparkplug EoN nodes and sends control information to them. The device topic addressing includes a namespace, group_id, message_type, and edge_node_id. The namespace is now 'spBv1.0', thus a complete namespace looks like the following:

`spBv1.0/group_id/message_type/edge_node_id`

The message_type can be:

- NBIRTH - Birth certificate for EoN nodes. Sent when EoN starts or when requested by Primary Application via NCMD.
- NDEATH - Death certificate for EoN nodes. Packaged as an MQTT last-will message when sending the MQTT connect message to the MQTT broker.
- NDATA - Node data message. Metrics published by EoN nodes and received by Primary Application.
- NCMD - Node command message. Primary Application sending a command to an EoN.
- DCMD - Device command message. Primary Application sending a command to a device via an EoN.
- STATE - Critical application state message. Primary Application broadcasting on/off state (off via last-will message).

The Sparkplug specification provides a clear and consistent structure for topic addressing, making it easier for developers and planners to design systems that are interoperable. The use of Google Protocol Buffers for the payload structure ensures efficient encoding and decoding of data, while the state management mechanism using birth and last-will messages allows for the tracking of nodes in the network. Additionally, the use of retained messages and last-will testament messages allows for the broker to maintain the state of the entire Sparkplug infrastructure.

#### MQTT Sparkplug State Management

State management is critical in the Industrial Internet of Things (IIoT) for ensuring seamless interaction among various devices and applications. Though MQTT provides some tools for session awareness, they often fall short in meeting the multifaceted needs of IIoT systems.

MQTT Sparkplug improves upon MQTT's native "Last Will and Testament" feature by introducing a "death certificate," a detailed account of a device's last known state before it disconnects. This richer information enables better decision-making in the event of unexpected disconnections.

Sparkplug also introduces "birth certificates," which are messages that devices send upon connecting to an MQTT network to announce their available metrics and capabilities. These certificates provide immediate context for other network entities, allowing for more efficient interactions and remote configurations.

Sparkplug uses specific types of messages for establishing and maintaining the state of edge nodes, which send "NBIRTH" messages to announce their operational status when they come online. Conversely, "NDEATH" messages indicate that a node is no longer available, often with added contextual information about their unavailability. MQTT Sparkplug includes the concept of a "rebirth" mechanism to handle network fluctuations. If a device or edge node gets disconnected and reconnects, it automatically retransmits a "BIRTH" message, providing the network with updated status and capabilities.

In addition to these life-cycle messages, Sparkplug maintains a continuous flow of operational data through "DATA" messages. These messages keep the network informed and updated, bridging the gap between the initial "BIRTH" and eventual "DEATH" messages.

## Sparkplug Client Features

- **Publish Birth Certificates (NBIRTH):** Allows the node to publish its own birth certificates.
- **Node Data Messages (NDATA):** Supports publishing of node data messages.
- **Process Node Command Messages (NCMD):** Can process command messages from Sparkplug Primary Applications.
- **API for Device Applications:** Enables MQTT device applications to publish device-specific messages such as birth (DBIRTH), data (DDATA), and death certificates (DDEATH), and to receive device command messages (DCMD).

## Usage Instructions

### Creating and Configuring a New Sparkplug Client

```lua
local SP = require"SparkplugB"
SP.create(broker, groupId, nodeName, opt)
```

- **broker: string:** The broker name .e.g "locahost"
- **groupId: string:** The Sparkplug group ID.
- **nodeName: string:** The Sparkplug node's name.
- **opt: Configuration Table:** While optional, setting MQTT options like username and password is generally necessary. You may set the following MQTT options: alpn,clientidentifier,keepalive,port,timeout,username,password,secure,nocheck

##### Example: Creating a Sparkplug Client

```lua
local broker = 'localhost'
local groupId = 'Sparkplug Devices'
local nodeName = 'Test Edge Node'
local opt = {
   username = "admin",
   password = "admin"
}
local client = SP.create(broker, groupId, nodeName, opt)
```

### Stopping the Client

- **Automatic Connection Management:** Once configured, the client automatically connects to the MQTT Server and attempts to reconnect if the connection is lost.
- **Stopping and Disconnecting:** The client provides functionality to stop its operation and disconnect from the server. To reconnect, a new client instance must be created and configured.

##### Example: Stopping the CLient

```lua
-- Stop the Sparkplug client
client:stop()
```

### Publishing Messages

The Sparkplug client offers functionalities for publishing various types of messages, including device birth certificates (DBIRTH), device data messages (DDATA), and device death certificates (DDEATH).

#### Message Payloads

While a detailed payload format description is extensive and available in the [Sparkplug specification](https://sparkplug.eclipse.org/specification/version/3.0/documents/sparkplug-specification-3.0.0.pdf), a brief overview is provided below.

#### Edge Node Birth Certificate (NBIRTH)

The NBIRTH message broadcasts all relevant data points, process variables, and metrics for the edge node.

##### Key Payload Components

1. **Metrics Array:**
   - Each metric object in this array should include:
     - `name`: The metric's name.
     - `value`: The metric's value.
     - `type`: Metric type, supporting various types like int, int8, int16, int32, int64, uint8, uint16, uint32, uint64, float, double, boolean, string, datetime, text, uuid, dataset, bytes, file, or template.
     - `timestamp` (optional): A UTC timestamp in 64-bit integer format. This is automatically set if not provided.

##### Example: Publishing an NBIRTH Message

```lua
local payload = {
   metrics = {
      {
         name = "my_int",
         value = 456,
         type = "Int32"
      },
      {
         name = "my_float",
         value = 1.23,
         type = "Float"
      }
   }
}

-- Publish node birth certificate
client:publishNodeBirth(payload)
```

#### Device Birth Certificate (DBIRTH)

A Sparkplug device birth certificate (DBIRTH) message will contain all data points, process variables, and metrics for the device. The DBIRTH payload format is the same as the NBIRTH format.

```lua
local deviceId = "testDevice"
local payload = {
   metrics = {
      {
         name = "my_int",
         value = 456,
         type = "Int32"
      },
      {
         name = "my_float",
         value = 1.23,
         type = "Float"
      }
   }
}
-- Publish device birth
client:publishDeviceBirth(deviceId, payload)
```


#### Node Data Message (NDATA)

An edge node data message (NDATA) will look similar to NBIRTH but is not required to publish all metrics. However, it must publish at least one metric.

##### Example: Publishing an NDATA Message

```lua
local payload = {
   timestamp = 1465456711580,
   metrics = {
      {
         name = "my_int",
         value = 412,
         type = "Int32"
      }
   }
}
-- Publish node data
client:publishNodeData(payload)
```


#### Device Data Message (DDATA)

A device data message (DDATA) will look similar to DBIRTH but is not required to publish all metrics. However, it must publish at least one metric.

##### Example: Publishing a DDATA Message

```lua
local deviceId = "testDevice"
local payload = {
   timestamp = 1465456711580,
   metrics = {
      {
         name = "my_int",
         value = 412,
         type = "Int32"
      }
   }
}
-- Publish device data
client:publishDeviceData(deviceId, payload)
```



#### Node Death Certificate (NDEATH)

An edge node death certificate (NDEATH) is published to indicate that the edge node has gone offline or has lost a connection. It is automatically registered as an MQTT Last Will and Testament (LWT) message by the Sparkplug client instance and published on the application's behalf.

#### Device Death Certificate (DDEATH)

A device death certificate (DDEATH) can be published to indicated that the device has gone offline or has lost a connection. It should contain only an optional timestamp.

##### Example: Publishing a DDEATH Message

```lua
local deviceId = "testDevice"
payload = {
   timestamp=1465456711580
}
--Publish device death
client:publishDeviceDeath(deviceId, payload)
```

### Receiving events

The client leverages an EventEmitter to dispatch various Sparkplug relevant events. These events include:

- A "birth" event.
- A "command" event.
- A suite of five MQTT connection-related events:
  - "connect" - signifying a successful connection.
  - "reconnect" - indicating an attempt to re-establish a connection.
  - "offline" - triggered when the connection goes offline.
  - "error" - emitted upon encountering any connection errors.
  - "close" - indicating the closure of a connection.

#### Birth Event

A "birth" event is used to signal the device application that a DBIRTH message is requested.  This event will be be emitted immediately after the client initially connects or re-connects with the MQTT Server.

##### Example: handling a "birth" event


```lua
client:on('birth', function()
    trace("received 'birth' event")
    client:publishNodeBirth(getNodeBirthPayload())
    client:publishDeviceBirth(deviceId, getDeviceBirthPayload())
 end)
```

#### Command Events

An Edge Node Command (NCMD) message enables sending command messages from a Primary Application to the Edge of Network (EoN).  An 'ncmd' event will include a payload containing a list of metrics (as described above).  Any metrics included in the payload may represent attempts to write a new value to the data points or process variables that they represent or they may represent control messages sent to the edge node such as a "rebirth" request.

##### Example: handling an "ncmd" event

```lua
client:on('ncmd', function (payload)
   for _,metric in ipairs(payload.metrics) do
      trace(ba.json.encode(metric)) -- debug info
   end
    --Process metrics and create new payload containing changed metrics
   client:publishNodeData(newPayload)
end)
```

A Device Command (DCMD) enables sending command messages from a Primary Application to a device via an EoN. A 'dcmd' event includes the device ID and a payload containing a list of metrics (as described above). Any metrics included in the payload represent attempts to write a new value to the data points or process variables that they represent. After the device application processes the request, the device application should publish a DDATA message containing any metrics that have changed.


##### Example: handling an "dcmd" event

```lua
client:on('dcmd', function (deviceId,payload)
   for _,metric in ipairs(payload.metrics) do
      trace(ba.json.encode(metric)) -- debug info
   end
    --Process metrics and create new payload containing changed metrics
   client:publishDeviceData(deviceId,newPayload)
end)
```

#### Connect Event

A "connect" event is emitted when the client has connected to the server.

##### Example: handling an "connect" event

```lua
client:on('connect', function()
   trace("received 'connect' event")
end)
```

#### Reconnect Event

A "reconnect" event is emitted when the client is attempting to reconnect to
the server.

##### Example: handling an "reconnect" event

```lua
client:on('reconnect', function()
   trace("received 'reconnect' event")
end)
```

#### Offline Event

An "offline" event is emitted when the client loses connection with the server.

##### Example: handling an "offline" event

```lua
client:on('offline', function()
   trace("received 'offline' event")
end)
});
```

#### Error Event

An "error" event is emitted when the client has experienced an error while
trying to connect to the server.

##### Example: handling an "error" event

```lua
client:on('error', function (error,status)
   trace("received 'error' event: ", error,":",status)
end)
```

#### Close Event

A "close" event is emitted when the client's connection to the server has been
closed.

##### Example: handling a "close" event

```lua
client:on('close', function()
   trace("received 'close' event")
end)
});
```

## Complete Example


```lua
local op={
   username="admin",
   password="admin",
}

local addr="localhost"
local groupId="my groupId"
local nodeName="my nodeName"

local client=require"SparkplugB".create(addr,groupId,nodeName,op)

client:on('connect', function()
   trace("received 'connect' event")
end)

client:on('reconnect', function()
   trace("received 'reconnect' event")
end)

client:on('offline', function()
   trace("received 'offline' event")
end)

client:on('error', function (error,status)
   trace("received 'error' event: ", error,":",status)
end)

client:on('close', function()
   trace("received 'close' event")
end)

local metrics={
   {
     name= "my_int",
     value= 456,
     type= "Int32"
   },
   {
     name= "my_float",
     value= 1.23,
     type= "Float"
   }
}

client:on('birth', function()
   trace("received 'birth' event")
   local payload = {metrics=metrics}
   client:publishNodeBirth(payload)
   client:publishDeviceBirth("deviceID",payload)
end)

client:on('ncmd', function (payload)
   trace("received 'ncmd' event")
   for _,mx in ipairs(payload.metrics) do
     trace(ba.json.encode(mx))
     for _,m in ipairs(metrics) do
       trace(m.name)
       if m.name == mx.name then m.value=mx.value end
     end
   end
   client:publishNodeData{metrics=metrics}
   client:publishDeviceData(deviceId,{metrics=metrics})
end)

client:on('dcmd', function (deviceId,payload)
   trace("received 'dcmd' event",ba.json.encode(payload))
   for _,mx in ipairs(payload.metrics) do
     trace(ba.json.encode(mx))
     for _,m in ipairs(metrics) do
       trace(m.name)
       if m.name == mx.name then m.value=mx.value end
     end
   end
   client:publishNodeData{metrics=metrics}
   client:publishDeviceData(deviceId,{metrics=metrics})
end)

client:on('state', function (groupId,jsonStr)
   trace("received 'state' event:", groupId,jsonStr)
end)
```


## The Sparkplug Explorer

The Sparkplug Explorer, an easy to use tool, monitors and displays incoming Sparkplug messages directly in the console. You'll find the MQTT settings at the beginning of the [.preload](SparkplugExplorer/.preload) script. Please modify these settings to suit your specific needs.

```
cd Sparkplug
mako -l::SparkplugExplorer
```

For detailed instructions on starting the Mako Server, check out our [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and review the server's [command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp) in our documentation.

