
/* Note: This JavaScript code uses JQuery, which is embedded in the
   wfs server, and loaded into index.lsp.
   See: http://api.jquery.com/
   P.S. $() is a valid function name in JavaScript.
   */


// Returns true if the file name extension is .zip
function checkIfZip(name) {
    var ok=false;
    try {
        var regexp=/^.*\.([^\.]*)$/m;
        var x=name.match(regexp);
        var ext=x[1].toLowerCase();
        ok = ext=="zip";
    }
    catch(e){}
    if(!ok)
        alert("Now is a good time to read the documentation and to find out what files can be uploaded!");
    return ok;
};


function refresh() {
    window.location.reload(true);
};


//Sets the progress bar width by using CSS manipulation.
function progressbar(percent) {
    $("#progressbar").css('width', Math.round(percent)+"%");
};

// Returns true if the browser supports drag and drop upload.
function canDoDragDropUpload() {
    try {
        var xhr = new XMLHttpRequest();
        xhr.upload.addEventListener("progress", function(){},false);
        return true;
    }
    catch(e) {}
    return false;
}



$(function() {

    /* Allow only zip files.
      Ref:
         http://api.jquery.com/submit/
         http://api.jquery.com/file-selector/
    */
    $("#uploadform form").submit(function() {
        return checkIfZip($("#uploadform input:file").val());
    });

    if(!canDoDragDropUpload()) {
        $("body").append("<p>P.S. Your browser stinks!</p>");
        return;
    }

    //Switch from a boring old fashioned upload form to a modern drag and drop upload manager.
    $("#uploadform").hide();
    $('#dropbox').show();

     // The drop event callback i.e. drag and drop
    function drop(e) {
        e.preventDefault();
        // Ignore new drop events
        $('body').unbind('drop').bind('drop', function() {});
        // We accept one file. Additional files are ignored.
        var file=e.originalEvent.dataTransfer.files[0];

        if( ! checkIfZip(file.name) ) {
            refresh();
            return;
        }

        //Create the upload object
        xhr = new XMLHttpRequest();

        // Attach 4 upload event listeners.
        xhr.onreadystatechange=function(){
            if (xhr.readyState == 4) { // The request and response is complete.
                // We simply dump the HTML response into the DOM, replacing the current page.
                // An alternative is to have the server send JSON respone data.
                $("html").html(xhr.responseText);
                xhr=null; /* (ref-done) */
            }
        };
        xhr.upload.addEventListener("progress", function(e) {
            if(e.loaded == file.size) { // Note, Firefox fails at sending the event when 100% completed.
                progressbar(100);
                // Give the user time to see the "upload complete" progress bar
                setTimeout(function() {
                    if(!xhr) return; /* wow, server zip processing is fast (ref-done) */
                    $('#upload').hide();
                    /* Lets reuse the original upload form.
                       The data below is displayed when upload is
                       complete and while the server unpacks the ZIP file.
                    */
                    $("#uploadform .rtltmb").html("Installing.....")
                    $("#uploadform .marg").html(
                        "<p>Please wait for the server to complete the firmware installation.</p>");
                    $("#uploadform").show();
                }, 500);
            }
            else
                if(e.lengthComputable) progressbar(e.loaded * 100 / file.size);
        }, false);
        xhr.upload.addEventListener("error", function(e) {
            setTimeout(function() {
                alert("Uploading "+file.name+" failed!");
                refresh();
            }, 100);
        }, false);  
        xhr.upload.addEventListener("abort", refresh, false);

        //Open connection to origin i.e. LSP page
        xhr.open("PUT", window.location.href);
        //We use the following on the server side to identify this as a drop event.
        xhr.setRequestHeader("x-requested-with","upload")
        xhr.send(file); // Start the upload

        //Hide the dropbox image and show the progress bar.
        $('#dropbox').clearQueue().hide();
        $('#upload').show();
    };

    // Install dragover and the drop callbacks.
    // "dragover" fires constantly while hovering thus creating a nice dim effect with the logic below.
    var dragover=false
    $('body').bind('dragover',function(e) {
        e.preventDefault();
        if(dragover) return;
        dragover=true;
        $('#dropbox').show().fadeTo(300,.5,function(){
            $('#dropbox').fadeTo(300,1, function() {dragover=false;});});
    }).bind('drop',drop);

    // If user wants to switch back to old fashioned upload form.
    $("#showform").click(function() {
        $('#dropbox').clearQueue().hide();
        // Ignore new drop events
        $('body').unbind('drop').bind('drop', function() {});
        $("#uploadform").show();
    });

});
