# SMQ IoT Tutorials and Examples

Source code for the [SMQ](https://realtimelogic.com/products/simplemq/) tutorials @ makoserver.net.

**The following examples are for the three SMQ tutorials:**

- [A basic chat client](https://makoserver.net/articles/Designing-a-browser-based-Chat-Client-using-SimpleMQ)
- [Improving the chat client](https://makoserver.net/articles/Improving-the-browser-based-Chat-Client)
- [Device LED control](https://makoserver.net/articles/Browser-to-Device-LED-Control-using-SimpleMQ)

Start the example bundle, using the Mako Server, as follows:

```
cd LSP-Examples/SMQ-examples
mako -l::IoT
```

After starting the example bundle, navigate to http://localhost


## A basic chat client

The basic HTML/JavaScript powered chat client that shows how to use publish and subscribe for sending messages to all connected clients and how to receive the published messages.

[Basic Chat Client](chat/BasicChat.html)

 When running the example, open multiple browser windows. Text input is at the bottom of the chat page.

## Improving the chat client

The improved chat client builds on the basic chat clients and shows how to use SMQ's one-to-one messages. Messages are still broadcasted to all connected clients, but one-to-one messages are used for building a list of all connected users. The user list is shown in the left pane and each list entry changes color when the user types.

[Improved Chat Client](chat/index.html)

When running the example, open multiple browser windows.

## Device LED control

The device LED control example show how to use the SMQ IoT Protocol for designing a web based IoT device management user interface for controlling Light Emitting Diodes (LEDS) in one or multiple devices.

[Device LED control](led-control/index.html)

The SMQ LED web interface shows no connected devices. You must connect at least one SMQ C Client to your own SMQ broker. See the [SMQ Source Code](https://realtimelogic.com/products/simplemq/src/) page for details.
