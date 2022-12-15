![Sparkplug Protocol Stack](https://realtimelogic.com/GZ/images/SparkplugStack.svg)

# Lua Sparkplug Library and Example

The Sparkplug specification is a set of instructions designed to standardize MQTT pub/sub interoperability in the Industrial Internet of things arena. The specification does so by specifying a unified MQTT topic name space and specifying how metrics are encoded/decoded using Google's protocol buffers. See [Steve's Sparkplug introduction](http://www.steves-internet-guide.com/introduction-to-mqtt-sparkplug-for-iiot/) for a more detailed introduction.

The following components are required in order to design a so-called Sparkplug compatible Edge of Network Node (EoN):

1. [MQTT Client library](https://realtimelogic.com/ba/doc/?url=MQTT.html)
2. [Google's protocol buffers](https://en.wikipedia.org/wiki/Protocol_Buffers) library
3. A good understanding of the    [Sparkplug specification](https://bit.ly/mqtt-sparkplug)

**However**; you will need minimal knowledge of MQTT, protocol buffers, and the Sparkplug specification when using the Sparkplug library included in this example as long as you use simple metrics. All the information you need is included in the following instructions. The Sparkplug library is designed for the Barracuda App Server and provides a [Lua](https://en.wikipedia.org/wiki/Lua_(programming_language)) API; thus basic Lua experience is required. See our [interactive Lua tutorial](https://tutorial.realtimelogic.com/Lua-Types.lsp) if you are new to Lua.

Google's Protocol Buffers (Protobuf) requires a schema that defines the message types to be encoded and decoded. The [Sparkplug Protobuf schema](EoN/.lua/sparkplug_b.proto) is included in this example. When using Protobuf from a compiled language such as C/C++, a Protobuf compiler is required. This compiler generates stub code from the schema that enables C/C++ code to encode/decode Protobuf messages using the generated C code API. You do not need to use the Protobuf compiler when using Lua since Lua represents decoded Protobuf messages as [Lua tables](https://realtimelogic.com/ba/doc/en/lua/man/manual.html#3.4.9) . When encoding a message, you simply create a Lua table conforming to the Sparkplug schema and encode the table using APIs provided by this Sparkplug Lua library.

You do not need detailed understanding of the [Sparkplug specification](https://bit.ly/mqtt-sparkplug) and the [Sparkplug Protobuf schema](EoN/.lua/sparkplug_b.proto) when using the Lua Sparkplug library as long as you create simple metrics.  You can manually create the Lua tables or you can use the provided Sparkplug library to help you create simple metrics. The following Lua example shows how to create a Sparkplug message with one metric.

``` lua
local sparkplugPayload = {
  metrics = {
    {
      boolean_value = true,
      datatype = 11,
      name = "Node Metric2",
      timestamp = 1670455103012
    }
  },
  seq = 1,
  timestamp = 1670455103012
}
```

The above Sparkplug message can be created using the Sparkplug module as follows:

``` lua
local SP=require"sparkplug" -- Load the module
local DataTypes<const> = SP.DataTypes
local sparkplugPayload=SP.payload() -- Create Lua Sparkplug payload table
-- Add metric to payload
sparkplugPayload:metric("Node Metric2", DataTypes.Boolean, true)
```

As you can see from the above two examples, manually creating Lua tables requires a detailed understanding of the Sparkplug specification; however, the provided Sparkplug API greatly simplifies creating Sparkplug messages.

A Sparkplug EoN device sends metrics via an MQTT broker to a so-called Primary Application (the SCADA/IIoT Host Node). The Primary Application can also send command messages (NCMD) to the EoN node. The Sparkplug Lua module automatically converts received Protobuf messages to Lua tables. Each metric received will have one additional table element as shown in the following example:

``` lua
local sparkplugPayload = {
  metrics = {
    {
      boolean_value = true,
      datatype = 11,
      name = "Node Metric2",
      timestamp = 1670455113012,
      value = "boolean_value"
    }
  },
  seq = 5,
  timestamp = 1670455113012
}
```

Notice the extra "value" element inserted into the metric by the Protobuf decoder. This element simplifies reading received metrics as you can access the boolean_value without needing to specify the type name. The following prints 'true' by accessing the member `metric.boolean_value` as follows: `print(metric[metric.value])`. This works since Lua table elements can be accessed as `table.membername` or as `table["membername"]` -- e.g.  `metric["boolean_value"]`.

## The Sparkplug Lua API

The Sparkplug module is loaded as follows:

``` lua
local SP=require"sparkplug" -- Load the module
local DataTypes<const> = SP.DataTypes
```

The second line above provides an easy way to access the various Sparkplug types. The most common types are Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64, Float, Double, Boolean, String, DateTime, and Text -- e.g.  DataTypes.Int8.

### Payload and Metrics API

Create a Sparkplug payload table.

`local payload=SP.payload()`

Add metrics to the payload table

`payload:metric(name, type [, value [, alias [, timestamp]]])`

Parameter name and type are required. The other are optional.
- name - the metric name
- type - the metric type e.g.DataTypes.Double
- value - the value; a Sparkplug null metric is created if this value is not set or is nil
- alias - Sparkplug includes a feature that enables you to shave off a few bytes for each metric sent
- timestamp - the time is set to the current time if not provided

Example: the following creates a null metric with a time set to zero (Jan 1, 1970)

`payload:metric("A long time ago", DataTypes.Boolean, nil, nil, 0)`

#### Add Dataset metrics to the payload table

A dataset is a matrix, with rows and columns.

`payload:dataset(name, set [,alias [,timestamp])`
- name - the metric name
- set - the columns, column name, and column type

**Example:**
``` lua
local ds=payload:dataset("My two columns",{
   {"My Int8s", DataTypes.Int8},
   {"My Int16s", DataTypes.Int16s}
})
```
The returned ds object includes one method:

`ds:row(...)`

Each row added must have the same set of columns as specified when calling `payload:dataset`

**Example:**

`ds:row(127, 32767)`

### Sparkplug API

The Sparkplug EoN stack is built on top of the [Lua MQTT Client](https://realtimelogic.com/ba/doc/?url=MQTT.html). A Sparkplug EoN instance is created as follows:

`local sp=SP:create(addr, onstatus, ondata, groupId, nodeName, nbirth [,op])`
- addr - the address is passed to the [MQTT stack](https://realtimelogic.com/ba/doc/?url=MQTT.html#create)
- onstatus - the onstatus callback is identical to the one required by the MQTT stack
- ondata - a callback that is called when the EoN receives STATE or NCMD sent by the Primary Application: `function ondata(cmd,data,topic)`
  - cmd - "STATE" or "NCMD"
  - data - Sparkplug payload presented as a Lua table
  - topic - the full MQTT topic name
- groupId - the Sparkplug group the device belongs to
- nodeName - the Sparkplug EoN node ID
- nbirth - a Lua Sparkplug payload table with all metrics the EoN can publish
- op - the MQTT stack's option table

#### Sparkplug instance methods:

Publish NDATA to the Primary Application

`sp:ndata(payload)`
- payload - a Sparkplug table that is either manually crafted or created using the metrics API.

Resend the NBIRTH message.

`sp:nodebirth()`

The Sparkplug stack automatically sends the NBIRTH message when connecting to the MQTT broker. However, the NBIRTH message must be resent if the EoN node receives an NCMD with the metric name "Node Control/Rebirth". See the provided example for details.

## Running the Provided Example "as is" using the Mako Server

The included EoN example can be run "as is" using the [pre-compiled Mako Server](https://makoserver.net/download/overview/) , which includes all components required by the Sparkplug module.

### To run this example as is:
1. Download the [pre-compiled Mako Server](https://makoserver.net/download/overview/) for your platform and unpack the archive (Windows: self-extracting archive).
2. Run the example, using the Mako Server, as follows:

``` console
cd Sparkplug
mako -l::EoN
```

See the [Mako Server command line video tutorial](https://youtu.be/vwQ52ZC5RRg) for more information on how to start the Mako Server.

The example will attempt to connect to an MQTT broker at "localhost". You can edit the example file EoN/.preload and change the URL to a public test broker, but we recommend that you use a local broker such as [Mosquitto](http://www.steves-internet-guide.com/install-mosquitto-linux/) or sign up for a free trial broker such as [HiveMQ Cloud](https://www.hivemq.com/mqtt-cloud-broker/). You also need a Sparkplug Primary Application; however, explaining this is beyond the scope of this tutorial. As a first step, connect the SparkplugSniffer to the same broker.

#### The Sparkplug Sniffer

The Sparkplug Sniffer is a simple example that listens for Sparkplug messages and prints all messages received to the console. Run the Sparkplug Sniffer as follows (run another Mako Server instance).

``` console
cd Sparkplug
mako -l::SparkplugSniffer
```

## Adding the Sparkplug module to the Mako Server's resource file

The example code EoN/.preload includes the following code at the top of the file: [mako.createloader](https://realtimelogic.com/ba/doc/?url=Mako.html#mako_createloader)(io)

The above code makes it possible to load the Sparkplug module
EoN/.lua/sparkplug.lua from the application. However, for a more permanent
solution, copy the files to the Mako Server's resource file mako.zip as
follows:

``` console
mkdir .lua
cp EoN/.lua/sparkplug.lua .lua/
cp EoN/.lua/sparkplug_b.proto .lua/
zip -r -u path/2/mako.zip .lua
```


The above commands copy the sparkplug.lua module and the Sparkplug Protobuf schema to mako.zip/.lua/, which is where all pre-integrated modules are stored.

## Compiling your own Sparkplug enables BAS server

The example can be run on a server that has been assembled by using the [Barracuda App Server Source Code Library](https://github.com/RealTimeLogic/BAS) (BAS) such as the [LSP Application Manager](https://realtimelogic.com/ba/doc/?url=lspappmgr/readme.html) designed for RTOS and the [Mako Server](https://realtimelogic.com/ba/doc/?url=Mako.html) designed for HLOS. However, the Sparkplug module requires a [Lua Protobuf module](https://github.com/starwing/lua-protobuf) not included in the BAS library. This library includes both C code and Lua code that must be integrated into the build. The following example shows how to include the Protobuf module when compiling the Mako Server included in the BAS repo:

``` console
cd /mnt/a
git clone https://github.com/RealTimeLogic/BAS.git
cd BAS/src/
git clone https://github.com/starwing/lua-protobuf.git
cd ..
make -f mako.mk
```

The makefile detects that we have the Protobuf module and includes the C file src/lua-protobuf/pb.c in the build. The makefile also adds the compile flag -DUSE_PROTOBUF=1, which enables the following code in examples/MakoServer/src/MakoMain.c:

``` lua
#if USE_PROTOBUF
luaL_requiref(L, "pb", luaopen_pb, FALSE);
lua_pop(L,1); /* Pop pb obj: statically loaded, not dynamically. */
#endif
```

The above C code pre-loads the Lua C Protobuf module at startup, which is
required when statically linking a module with the server.

The Lua Protobuf module also includes two Lua modules that must be found by
the Lua "require" function. The easiest way to deal with this is to add the
Lua code to the Mako Server's resource file mako.zip as follows:

``` console
mkdir .lua
cp src/lua-protobuf/protoc.lua .lua/
cp src/lua-protobuf/serpent.lua .lua/
cp ../Sparkplug/EoN/.lua/sparkplug.lua .lua/
cp ../Sparkplug/EoN/.lua/sparkplug_b.proto .lua/
zip -r -u mako.zip .lua
```

The above commands also copy the sparkplug.lua module and the Sparkplug Protobuf schema to mako.zip/.lua/

If you are building the LSP Application Manager for a monolithic RTOS system, follow the same copy commands as above, but copy the files to the examples/lspappmgr/obj/lsp.zip ZIP file. After copying the files, convert lsp.zip to C code using [bin2c](https://realtimelogic.com/downloads/bin2c/) as follows:

``` console
bin2c -z getLspZipReader lsp.zip LspZip.c
```

