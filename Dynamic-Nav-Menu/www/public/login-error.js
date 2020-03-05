$(function(){
    setTimeout(()=>{
        $('.login-form').addClass('wrong-entry');
        $('.alert').fadeIn(500);
        setTimeout( "$('.alert').fadeOut(1500);",5000 );
    }, 250);
    $('.form-control').keypress(function(){
        $('.login-form').removeClass('wrong-entry');
    });
});


