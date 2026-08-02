// Returns true if the file name extension is .zip.
function checkIfZip(name) {
    var ok=/\.zip$/i.test(name);
    if(!ok)
        alert("Now is a good time to read the documentation and to find out what files can be uploaded!");
    return ok;
}

function refresh() {
    window.location.reload();
}

function progressbar(percent) {
    document.getElementById("progressbar").style.width=Math.round(percent)+"%";
}

function canDoDragDropUpload() {
    try {
        var xhr=new XMLHttpRequest();
        xhr.upload.addEventListener("progress",function(){},false);
        return true;
    }
    catch(e) {}
    return false;
}

addEventListener("DOMContentLoaded",function() {
    var body=document.body;
    var formbox=document.getElementById("uploadform");
    var form=formbox.querySelector("form");
    var fileinput=formbox.querySelector("input[type=file]");
    var dropbox=document.getElementById("dropbox");
    var upload=document.getElementById("upload");
    var accepting=true;
    var dragover=false;
    var xhr;

    form.addEventListener("submit",function(e) {
        if(!checkIfZip(fileinput.value)) e.preventDefault();
    });

    if(!canDoDragDropUpload()) {
        body.insertAdjacentHTML("beforeend","<p>P.S. Your browser stinks!</p>");
        return;
    }

    formbox.style.display="none";
    dropbox.style.display="block";

    function drop(e) {
        e.preventDefault();
        if(!accepting) return;
        accepting=false;
        var file=e.dataTransfer.files[0];
        if(!file || !checkIfZip(file.name)) {
            refresh();
            return;
        }

        xhr=new XMLHttpRequest();
        xhr.onreadystatechange=function() {
            if(xhr && xhr.readyState == 4) {
                var html=xhr.responseText;
                xhr=null;
                document.open();
                document.write(html);
                document.close();
            }
        };
        xhr.upload.addEventListener("progress",function(e) {
            if(e.loaded == file.size) {
                progressbar(100);
                setTimeout(function() {
                    if(!xhr) return;
                    upload.style.display="none";
                    formbox.querySelector(".rtltmb").textContent="Installing.....";
                    formbox.querySelector(".marg").innerHTML=
                        "<p>Please wait for the server to complete the firmware installation.</p>";
                    formbox.style.display="block";
                },500);
            }
            else if(e.lengthComputable) progressbar(e.loaded*100/file.size);
        },false);
        xhr.upload.addEventListener("error",function() {
            setTimeout(function() {
                alert("Uploading "+file.name+" failed!");
                refresh();
            },100);
        },false);
        xhr.upload.addEventListener("abort",refresh,false);
        xhr.open("PUT",window.location.href);
        xhr.setRequestHeader("x-requested-with","upload");
        xhr.send(file);

        document.getElementById("uploading").textContent=file.name;
        dropbox.style.display="none";
        upload.style.display="block";
    }

    body.addEventListener("dragover",function(e) {
        e.preventDefault();
        if(!accepting || dragover) return;
        dragover=true;
        dropbox.style.opacity=.5;
        setTimeout(function() {
            dropbox.style.opacity=1;
            dragover=false;
        },300);
    });
    body.addEventListener("drop",drop);

    document.getElementById("showform").addEventListener("click",function() {
        accepting=false;
        dropbox.style.display="none";
        formbox.style.display="block";
    });
});
