//Clear the console
function conClear()
{
    document.getElementById("console").replaceChildren();
};


/* Print a message to the console. Arg 'type' is optional and must be
 * one of the CSS classes defined in the HTML console code.
 */
function conPrint(msg, type)
{
    var out=document.getElementById("console");
    if(type) {
        var span=document.createElement("span");
        span.className=type;
        span.textContent=msg;
        out.append(span);
    }
    else out.append(msg);
    window.scrollTo(0, document.body.scrollHeight);
};


function info(msg)
{
    conPrint(msg+"\n", "info");
};


function wsConnect()
{
    var ws;
    try {
        var url=window.location.href.replace(/^http(s?:\/\/.*)\/.*$/, 'ws$1/');
        ws=new WebSocket(url+"server.lsp");
        ws.onopen = function(evt) {
            conPrint("WebSocket connection established!\n\n","info");
            document.body.focus();
            document.body.addEventListener("keydown",function(ev) {
                var c=ev.key == "Enter" ? '\n' : ev.key.length == 1 ? ev.key : null;
                if(!c) return;
                ev.preventDefault();
                conPrint(c,"cli");
                ws.send(c);
            });
        };
        ws.onclose = function(evt) { conPrint("Server closed the connection!\n","info") };
        ws.onmessage = function(evt) { conPrint(evt.data) };
        ws.onerror = function(evt) { conPrint("WS error!\n","err") };

    }
    catch(e) {
        conPrint("Your browser does not support WebSockets!","err");
    }
};

addEventListener("DOMContentLoaded",function() {
    var out=document.createElement("pre");
    out.id="console";
    document.body.replaceChildren(out);
    conPrint("WebSocket Server Demo.\nConnecting to ELIZA the psychotherapist...\n", "info");
    wsConnect();
});
