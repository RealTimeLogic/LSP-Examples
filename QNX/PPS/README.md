#QNX PPS SMQ Bridge

Module pps extends the [QNX Persistent Publish Subscribe](http://www.qnx.com/developers/docs/7.0.0/#com.qnx.doc.pps.developer/topic/about.html) (PPS) service and enables HTML5/JavaScript powered apps to directly subscribe to and publish PPS messages.

Module pps uses the [BAS Pipe API](https://realtimelogic.com/ba/doc/?url=auxlua.html#pipe_api) for the QNX PPS integration and the [SMQ IoT protocol](https://realtimelogic.com/ba/doc/?url=SMQ.html) as a base for extending the PPS QNX service.

All PPS messages are automatically converted to/from raw PPS and are presented as Lua tables on the server side and as JavaScript objects in HTML5 apps. Since PPS messages are bi-directional, a client may both subscribe to and publish to the same topic name.

A PPS SMQ service and SMQ broker are created by loading module 'pps' and by calling create() on the returned table.

``` lua
local pps,smq = require"pps".create([op])
```

The create() function creates and returns a PPS SMQ service object and an SMQ broker. Both objects are returned. You may use the SMQ broker for its original intent in addition to using it for PPS communication. The optional op argument, if provided, must be a table and is used for optionally configuring the [SMQ server object](https://realtimelogic.com/ba/doc/?url=SMQ.html#create) .

SMQ clients, including HTML5/JavaScript powered apps, require that each PPS topic is registered on the server side by calling pps:subscribe(). Messages are not relayed to/from the QNX PPS service unless each topic is registered.

**pps:subscribe(pps_topic [, callback])**

* **String pps_topic:** - the PPS topic name e.g. "/pps/my-service"
* **Function callback(egress, tab, pps):** - optional callback function triggered on the server for all ingress/egress messages.
  - **Boolean egress:** - True for egress messages and false for ingress messages
  - **Table tab:** - The PPS message presented as a Lua table
  - **String pps:,** The PPS message presented in raw form

## Using PPS with an HTML5/JavaScript App

The following examples show how to publish and subscribe to PPS messages by using the [SMQ JavaScript client](https://realtimelogic.com/ba/doc/?url=JavaScript/SMQ.html); however, the same methods apply to any SMQ client stack, including the [SMQ Java stack](https://realtimelogic.com/ba/doc/en/java/SMQ/index.html) and the [SMQ C stack](https://realtimelogic.com/ba/doc/en/C/reference/html/group__SMQClient.html).

The client subscribes to PPS messages as follows:

```javascript
smq.subscribe("/pps/my-service", {
              datatype: "json",
              onmsg: function(obj) { /* manage obj */}
          });
```

The callback 'onmsg' will trigger for any future updates to the PPS topic after the client subscribes. Previous messages will not be received; however, the client may ask specifically for the last known message by sending the following at startup:

```javascript
smq.publish("/pps/my-service",1,"last-pps");
```

The payload must be set to the PPS topic name; the SMQ topic must be set to the number 1, which is the server's hard coded ephemeral topic ID (etid); and the sub-topic (stid) must be set to "last-pps". The server will then send the last PPS message back to the client. The client receives this message by subscribing as follows:

```javascript
smq.subscribe("self","/pps/my-service", {
              datatype: "json",
              onmsg: function(obj) { /* manage obj */}
          });
```

The topic must be set to 'self', which means subscribe to topics sent to the client's ephemeral tid, and the sub-topic must be set to the requested PPS topic name. See the [SMQ documentation: topic names](https://realtimelogic.com/ba/doc/?url=SMQ.html#TopicNames) , and sub-topic names for more information on the use of SMQ and addressing.

The SMQ client may publish QNX PPS messages to any topic registered on the server side. The client must use the [smq. pubjson()](https://realtimelogic.com/ba/doc/?url=JavaScript/SMQ.html#pubjson) function when publishing since all messages must be exchanged as JSON. The client may choose to publish a message to all SMQ clients (one-to-many message), including all other SMQ clients that may currently be subscribed; or only publish the message to the QNX PPS service (one-to-one message). Sending a one-to-many message is done by setting the topic name to the PPS topic. Sending a one-to-one message is done by setting the topic name/ID to the number one (the server's hard coded ephemeral tid) and the sub topic name to the PPS topic.

```javascript
smq.pubjson({temperature:10},"/pps/bidirect-tst"); // Send to all subscribed clients - one-to-many
smq.pubjson({temperature:10},1,"/pps/bidirect-tst"); // Send to PPS service only - one-to-one
```
