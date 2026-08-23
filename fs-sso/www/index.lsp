<?lsp
response:setheader("Cache-Control","no-store")
response:setheader("Pragma","no-cache")
response:setheader("Referrer-Policy","no-referrer")
response:setheader("X-Content-Type-Options","nosniff")
response:setheader("Content-Security-Policy","default-src 'self'; base-uri 'none'; frame-ancestors 'none'; form-action 'self' https://login.microsoftonline.com")

local sso,base=app.sso,assert(app.ssoBase,"SSO base URI is unavailable")
local function esc(value)
   return tostring(value or ""):gsub("[&<>\"']",{
      ["&"]="&amp;",["<"]="&lt;",[">"]="&gt;",["\""]="&quot;",["'"]="&#39;"
   })
end

local emitError

local function emitLogin()
?>
<section class="panel-copy">
  <p class="eyebrow">OpenID Connect</p>
  <h2>Sign in to the file server</h2>
  <p>Use your organization&apos;s Microsoft Entra ID account.</p>
  <a class="button primary" href="<?lsp=esc(base)?>?login=1">Sign in with Microsoft</a>
</section>
<?lsp
end

local function emitOK(user)
   local session=request:session()
   user=user or (session and session.msSsoUser)
   if not user then return emitError"The local login session is incomplete" end
   local showUrl=request:data"sessionurl"
   local sessionUrl
   if showUrl then
      local origin=request:url():match"^https?://[^/]+"
      sessionUrl=origin and origin..base.."fs/"..session:id(true).."/"
   end
?>
<section class="panel-copy">
  <p class="eyebrow success">Authenticated</p>
  <h2>Hello, <?lsp=esc(user.name)?></h2>
  <p>Your Microsoft identity is verified. File permissions are controlled by this application.</p>
  <div class="actions">
    <a class="button primary" href="<?lsp=esc(base)?>fs/">Open file server</a>
    <a class="button secondary" href="<?lsp=esc(base)?>logout.lsp">Local logout</a>
  </div>
  <div class="credential-box">
<?lsp if showUrl then ?>
    <h3>WebDAV session URL</h3>
    <code><?lsp=esc(sessionUrl or "Unable to create an absolute session URL")?></code>
    <p class="hint">This URL is a bearer credential with the same file access and two-hour lifetime as this session. Keep it private.</p>
<?lsp else ?>
    <h3>Need a WebDAV session URL?</h3>
    <p class="hint">Generate it only when a client cannot use browser sign-in.</p>
    <a href="<?lsp=esc(base)?>?sessionurl=1">Show session URL</a>
<?lsp end ?>
  </div>
  <div class="wfm-help">
    <h3>Session URLs from Web File Manager</h3>
    <p>Select any directory, open its context menu, and choose <strong>Copy Session URL</strong>. The copied WebDAV URL starts at that directory and uses the same two-hour authenticated session.</p>
    <p class="hint">A session URL is a bearer credential. Share it only with the WebDAV client that needs it.</p>
    <figure>
      <img src="<?lsp=esc(base)?>assets/session-url.jpg" width="258" height="181" loading="lazy" alt="Web File Manager context menu with Copy Session URL highlighted">
      <figcaption>Right-click a directory to open this menu.</figcaption>
    </figure>
  </div>
</section>
<?lsp
end

local function emitRecovery(message,token)
?>
<section class="panel-copy">
  <p class="eyebrow warning">Credential rotation required</p>
  <h2>Microsoft Entra rejected the server credential</h2>
  <p><?lsp=esc(message)?></p>
  <p class="hint">Create a new client secret in the configured app registration, then enter its <strong>Value</strong> and expiration date. The new value is tested by repeating this sign-in.</p>
  <form method="post" class="rotation-form" autocomplete="off">
    <input type="hidden" name="recovery" value="<?lsp=esc(token)?>">
    <label for="client-secret">Client secret Value</label>
    <input id="client-secret" name="secret" type="password" maxlength="512" required autocomplete="new-password">
    <label for="secret-expires">Expiration date</label>
    <input id="secret-expires" name="expires" type="date" required>
    <button class="button primary" type="submit">Test and activate secret</button>
  </form>
</section>
<?lsp
end

emitError=function(message,codes,recovery)
   local labels={
      [7000215]="The configured client secret is invalid.",
      [7000222]="The configured client secret has expired."
   }
   if recovery then
      for _,code in ipairs(type(codes) == "table" and codes or {}) do
         if labels[tonumber(code)] then return emitRecovery(labels[tonumber(code)],recovery) end
      end
   end
?>
<section class="panel-copy">
  <p class="eyebrow error">Sign-in failed</p>
  <h2>We could not complete the login</h2>
  <p><?lsp=esc(message or "Please try again.")?></p>
  <a class="button primary" href="<?lsp=esc(base)?>?login=1">Try again</a>
</section>
<?lsp
end

local action
local session=request:session()
if request:method() == "POST" then
   local ok,err,recovery=sso.rotate(request,request:data"secret",request:data"expires",
                                    request:data"recovery")
   if ok then action=function() end
   elseif recovery then action=function() emitRecovery(err,recovery) end
   else action=function() emitError(err) end end
elseif request:data"code" or request:data"error" then
   local header,payload,codes,recovery=sso.login(request)
   session=session or request:session(true)
   if header then
      local user={id=payload.tid..":"..payload.oid,
                  name=payload.name or payload.preferred_username or "Microsoft Entra user"}
      request:login(user.id)
      session.msSsoUser=user
   else
      session.msSsoResult={message=payload,codes=codes,recovery=recovery}
   end
   response:sendredirect(base)
   action=function() end
elseif session and session.msSsoResult then
   local result=session.msSsoResult
   session.msSsoResult=nil
   action=function() emitError(result.message,result.codes,result.recovery) end
elseif request:user() then action=emitOK
elseif request:data"login" then
   local ok,err=sso.sendredirect(request)
   action=ok and function() end or function() emitError(err) end
else
   action=emitLogin
end
?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Microsoft Entra ID SSO</title>
  <link rel="stylesheet" href="<?lsp=esc(base)?>assets/style.css?v=3">
  <script src="<?lsp=esc(base)?>assets/busy.js?v=5" defer></script>
</head>
<body>
  <main class="shell">
    <header class="masthead">
      <span class="brand-mark" aria-hidden="true"></span>
      <div>
        <p class="product">Real Time Logic example</p>
        <h1>Microsoft Entra ID SSO</h1>
      </div>
    </header>
    <div class="panel"><?lsp action() ?></div>
    <footer>Authentication example for BAS, Mako Server, and Xedge</footer>
  </main>
</body>
</html>
