<?lsp

if app.SMQ.isSMQ(request) then
   app.smq.connect(request)
   return
end

?>
<!doctype html>
<html>
  <head>
    <link rel="stylesheet" href="xterm.css" />
    <style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

html,body{
    width: 100%;
    height: 100%;
    background:black;
}
    </style>
    <script type="text/javascript" src="/rtl/jquery.js"></script>
    <script type="text/javascript" src="/rtl/smq.js"></script> 
    <script src="xterm-compressed.js"></script>
  </head>
  <body>
    <div id="terminal"></div>
<script>

var term = new Terminal();
term.open(document.getElementById('#terminal'), true);
term.fit();

function r() {term.fit();}
$(function() {
    $(window).resize(r);

    var serverTid; // Server's ephemeral tid

    var smq = SMQ.Client(); // No args: connect back to 'origin'.

    function pubsize(size) {
        smq.pubjson({cols:size.cols, rows:size.rows}, serverTid, "resize");
    };

    smq.onconnect=function() {
        setTimeout(function() {
            pubsize(term);
        }, 2000);
    };

    smq.onclose=function(message,canreconnect) {
        serverTid=null;
        term.writeln(message ? message : "\r\nConnection closed!");
        if(canreconnect) return 3000; // Attempt to reconnect after 3 sec.
    };

    textDecoder = new TextDecoder();

    function onmsg(rawData, ptid) {
        serverTid = ptid;
        var d = textDecoder.decode(rawData)
        if(d) d = JSON.parse(d)
        if(d) {
            var s = d[0].replace(/\n/g, '\r\n');
            if(d[1]) // stderr
                term.write('\033[91m'+s+'\033[0m');
            else
                term.write(s);
        }
        else
            term.write("utf8 err");
    };
    smq.subscribe("self", {onmsg:onmsg});

    term.on('data', function(data) {
        if(serverTid)
            smq.publish(data, serverTid, "data");
    });

    term.on('resize',  pubsize);
});
</script>
  </body>
</html>
