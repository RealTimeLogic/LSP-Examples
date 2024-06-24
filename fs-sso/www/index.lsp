<?lsp

local sso=app.sso

------------------------------------------------------------
local function emitLogin()
?>
  <p>Login using your Microsoft Azure AD account.</p>
  <p class="lead">
    <a class="btn btn-primary btn-lg" href="?login=" role="button">Login</a>
  </p>
<?lsp
end


------------------------------------------------------------
local function emitOK(payload)
   local s = request:session()
   if not s then return emitError"Should not be possible" end
   if payload then 
      s.payload = payload
   else
      payload = s.payload
   end
?>
<div class="alert alert-primary" role="alert">
  <p>Hello <?lsp=payload.preferred_username?>
  <p>Navigate to the file server:</p>
  <p class="lead">
    <a class="btn btn-primary btn-lg" href="fs/" role="button">File Server</a>
  </p>
  <div class="alert alert-light" role="alert">
  Authenticated WebDAV Session URL: <?lsp=request:url().."fs/"..s:id(true).."/"?>
  </div>
</div>
<?lsp
end

------------------------------------------------------------
local function emitError(err)
?>
<div class="alert alert-danger" role="alert">
 <p>Login failed!</p>
 <p><?lsp=err?></p>
</div>
  <p class="lead">
    <a class="btn btn-primary btn-lg" href="?login=" role="button">Login</a>
  </p>
<?lsp
end

local action
if request:method() == "POST" then
   local header,payload = sso.loginCallback(request)
   if header then
      request:login()
      action = function() emitOK(payload) end
   else
      action = function() emitError(payload) end -- Payload is now 'err'
   end
else
   if request:user() then
      action=emitOK
   elseif request:data"login" then
      sso.sendLoginRedirect(request)
   else
      action=emitLogin
   end
end

?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>File Server</title>
    <!-- Bootstrap core CSS -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/style.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
  </head>
  <body>
    <!-- Page Content -->
    <div class="container">
      <div class="row">
        <div class="col-lg-12">
<div class="jumbotron" >
  <h1 class="display-4">File Server</h1>
   <?lsp action() ?>
</div>      

        </div>
      </div>
    </div>
    <!-- Bootstrap core JavaScript -->
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js"></script>
    <script src="assets/service.js"></script>
  </body>
</html>


