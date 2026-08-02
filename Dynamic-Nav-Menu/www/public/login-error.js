addEventListener("DOMContentLoaded", function() {
    var form=document.querySelector(".login-form");
    var msg=document.querySelector(".alert");
    setTimeout(function() {
        form.classList.add("wrong-entry");
        msg.classList.add("visible");
        setTimeout(function() {msg.classList.remove("visible");},5000);
    },250);
    document.querySelectorAll(".form-control").forEach(function(e) {
        e.addEventListener("input",function() {
            form.classList.remove("wrong-entry");
        });
    });
});
