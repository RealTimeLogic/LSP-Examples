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
  <p>Navigate to the <a target="_blank" href="https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_create_wfs">Web File Server</a> by clicking the button below:</p>
  <p class="lead">
    <a class="btn btn-primary btn-lg" href="fs/" role="button">File Server</a>
  </p>
  <div class="alert alert-light" role="alert">
  Authenticated Session URL: <?lsp=request:url().."fs/"..s:id(true).."/"?>
  </div>
</div>
<?lsp
end

------------------------------------------------------------
local function doIdErr(secretErr)
?>
<div class="alert alert-danger" role="alert">
   <p><p>Login failed: <?lsp=secretErr?></p>
</div>
<div class="container mt-5">
  <form method="post">
    <div class="mb-3">
      <label for="secretId" class="form-label">Enter a new Microsoft Entra secret ID</label>
      <input type="text" name="secret" class="form-control" id="secretId" placeholder="Your secret ID here" required>
    </div>
    <button type="submit" class="btn btn-primary">Submit</button>
  </form>
</div>
<?lsp
end

------------------------------------------------------------
local function emitError(err,ssoErrCodes)
   if ssoErrCodes then
      -- https://learn.microsoft.com/en-us/entra/identity-platform/reference-error-codes
      local idErrs={
	 [7000215]="The client secret key is invalid/unknown",
	 [7000222]="The client secret key has expired"
      }
      for _,code in ipairs(ssoErrCodes) do
	 secretErr=idErrs[code]
	 if secretErr then doIdErr(secretErr) return end
      end
   end
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
   local secret=request:data"secret"
   if secret then  -- If setting a new ID via POST from doIdErr()
      if sso.validate(secret) then
	 action=function() emitLogin() end
      else
	 action=function() doIdErr("Invalid secret") end
      end
   else -- 3: Login sequence
      local header,payload,ecodes = sso.login(request)
      if header then
         request:login()
         action = function() emitOK(payload) end
      else
         action = function() emitError(payload,ecodes) end -- Payload is now 'err'
      end
   end
else
   if request:user() then
      action=emitOK
   elseif request:data"login" then
      sso.sendredirect(request)  -- 2: Login button clicked
   else
      action=emitLogin -- 1: Loading page
   end
end

?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>SSO Example</title>
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
  <h1 class="display-4">SSO Example</h1>
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


