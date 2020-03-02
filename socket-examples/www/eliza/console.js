//Clear the console
function conClear()
{
    $("#console").empty();
};


/* Print a message to the console. Arg 'type' is optional and must be
 * one of the CSS classes defined in the HTML console code.
 */
function conPrint(msg, type)
{
    if(type)
        msg="<span class='"+type+"'>"+msg+"</span>";
    $("#console").append(msg);
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
            $("body").focus().keypress(function(ev) {
                ev.preventDefault();
                var c = ev.which == 13 ? '\n' : String.fromCharCode(ev.which);
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

$(function() {
    $('body').empty().html("<pre id='console'></pre>");
    conPrint("WebSocket Server Demo.\nConnecting to ELIZA the psychotherapist...\n", "info");
    wsConnect();
});
