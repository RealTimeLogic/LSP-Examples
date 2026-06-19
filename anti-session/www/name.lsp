<?lsp
local data = request:method() == 'POST' and request:data() or {}
local state, err = app.decodeState(data.state)
response:include"header.shtml"
?>

<h1>Your Name</h1>

<?lsp if not state then ?>
  <div class="notice error"><strong>Cannot continue.</strong> <?lsp=app.escapeHtml(err)?> Start again from the first page.</div>
  <p><a class="button secondary" href="/">Start over</a></p>
<?lsp else ?>
  <p class="lead">The encrypted state was posted to this page. Add your name and continue.</p>

  <form method="post" action="food.lsp" class="stacked-form">
    <input type="hidden" name="state" value="<?lsp=app.escapeHtml(data.state)?>">

    <label for="name">Name</label>
    <input id="name" name="name" type="text" autocomplete="name" required autofocus>

    <button type="submit">Next</button>
  </form>
<?lsp end ?>

<?lsp response:include"footer.shtml" ?>
