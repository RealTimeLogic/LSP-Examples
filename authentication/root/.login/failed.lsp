<!DOCTYPE html>
<html>
  <head>
     <link rel='shortcut icon' type='image/x-icon' href='/public/favicon.ico' />
      <style>
body{background: url("/public/access-denied.png") no-repeat fixed;background-size:80% 80%;background-position: center;}
.shade{position:absolute;top: 0;left: 0;right:0;bottom:0;background:white;opacity:0.4;z-index: -1;}
.center {position: absolute;top: 50%;left: 50%;transform: translate(-50%, -50%);text-align:center;}
h1 {font-size:42px;}
      </style>
  </head>
<body>
  <div class="center">
    <h1>Login credentails are incorrect.</h1>
    <h1>Use username and password "admin".</h1>
    <h1><a href="<?lsp=request:uri()?>">Try again</a></h1>
  </div>
  <div class="shade"><div>
</body>
</html>
