<?lsp
local data = request:method() == 'POST' and request:data() or {}
local state, err = app.decodeState(data.state)
local food = app.trim(data.food)

if state and food ~= '' then
   state.food = food
else
   state = nil
   err = err or 'The submitted favorite food is missing.'
end

response:include"header.shtml"
?>

<h1>Summary</h1>

<?lsp if not state then ?>
  <div class="notice error"><strong>Cannot show summary.</strong> <?lsp=app.escapeHtml(err)?> Start again from the first page.</div>
  <p><a class="button secondary" href="/">Start over</a></p>
<?lsp else ?>
  <p class="lead">The values below were recovered from the encrypted JSON object carried by the browser.</p>

  <dl class="summary-list">
    <div>
      <dt>Started</dt>
      <dd><?lsp=app.escapeHtml(state.started)?></dd>
    </div>
    <div>
      <dt>Name</dt>
      <dd><?lsp=app.escapeHtml(state.name)?></dd>
    </div>
    <div>
      <dt>Favorite food</dt>
      <dd><?lsp=app.escapeHtml(state.food)?></dd>
    </div>
  </dl>

  <p><a class="button secondary" href="/">Run the example again</a></p>
<?lsp end ?>

<?lsp response:include"footer.shtml" ?>
