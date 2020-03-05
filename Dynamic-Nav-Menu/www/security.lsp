<?lsp 

  if request:method() == "POST" then
     request:logout()
     response:sendredirect"" -- Does not return
  end

  title="Security"
  response:include".header.lsp" ?>

<h1>Security</h1>
<div class="center">
   <form method="POST">
      <input type="submit" value="Logout" />
    </form>
</div>
<?lsp response:include"footer.shtml" ?>
