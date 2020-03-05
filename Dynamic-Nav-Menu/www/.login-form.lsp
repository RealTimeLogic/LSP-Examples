<?lsp 
  title="Login"

  extheader = [[
   <link rel="stylesheet" href="/public/login-style.css">
   <script src="/rtl/sha1.js"></script>
   <script src="/rtl/spark-md5.min.js"></script>
  ]] 

  if authinfo.username then -- Not authenticated. See login.js for effects.
     extheader = extheader..'<script src="/public/login-error.js"></script>'
  end
  response:include".header.lsp"

?>
<form class="login-form" method="post">
  <h1>Login</h1>
  <div class="form-group ">
    <input type="text" name="ba_username" class="form-control" placeholder="Username" id="UserName"/>
      <i class="fa fa-user"></i>
  </div>
  <div class="form-group log-status">
    <input type="password" name="ba_password" class="form-control" placeholder="Password" id="Passwod"/>
    <i class="fa fa-lock"></i>
  </div>
  <span class="alert">Invalid Credentials</span>
  <a class="link" href="/public/recover-password.lsp">Lost your password?</a>

  <input type="hidden" name="ba_realm" value="<?lsp= authinfo.realm?>">
  <input type="hidden" name="ba_seed" value="<?lsp= authinfo.seed?>">
  <input type="hidden" name="ba_seedkey" value="<?lsp= authinfo.seedkey?>">

  <input type="button" id="ba_loginbut" class="log-btn" value="Login">
</form>
<?lsp response:include"footer.shtml" ?>
