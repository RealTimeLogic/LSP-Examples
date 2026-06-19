<?lsp
local state = { started = ba.datetime"NOW":tostring() }
local encrypted = app.encodeState(state)
response:include"header.shtml"
?>

<h1>Anti-Session Encrypted Form State</h1>
<p class="lead">This example carries a small JSON object through several form posts without using the server-side session object.</p>
<p>The object starts with the current server time, is encrypted with <code>ba.aesencode</code>, and is stored in a hidden form field.</p>

<form method="post" action="name.lsp" class="actions">
  <input type="hidden" name="state" value="<?lsp=app.escapeHtml(encrypted)?>">
  <button type="submit">Next</button>
</form>

<?lsp response:include"footer.shtml" ?>
