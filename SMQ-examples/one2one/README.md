## One-to-One Communication

This example demonstrates one-to-one communication between a browser
and a server using the SMQ protocol. It showcases the essentials of
setting up a client in the browser to subscribe to specific
[subtopics](https://realtimelogic.com/ba/doc/?url=SMQ.html#SubTopics)
and how to publish messages to the server. Below is a breakdown of the
key components and their functionalities:

### SMQ Client Initialization

*
**Description**: The SMQ client is instantiated with a
        clean start configuration, indicating that each connection starts afresh
        without any retained subscriptions or messages.

### Subscriptions

*
**Function sSub**: Illustrates how to subscribe to messages
        targeted at the client itself, leveraging the 'self' keyword. This
        function handles one-to-one message delivery, ensuring that messages are
        directed to and processed by the only intended recipient.

### Publishing Messages

*
**Function sPub**: Outlines the process of publishing JSON
        payloads to the broker. This is done after successfully subscribing to
        the relevant subtopics, demonstrating a sequential flow of operations
        where the client first ensures it's ready to receive messages before
        initiating communication.


## Running the Example

Start the example, using the Mako Server, as follows:

```
cd LSP-Examples/SMQ-examples
mako -l::one2one 
```
