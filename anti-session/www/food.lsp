<?lsp
local data = request:method() == 'POST' and request:data() or {}
local state, err = app.decodeState(data.state)
local name = app.trim(data.name)

if state and name ~= '' then
   state.name = name
else
   state = nil
   err = err or 'The submitted name is missing.'
end

local encrypted = state and app.encodeState(state) or nil
response:include"header.shtml"
?>

<h1>Favorite Food</h1>

<?lsp if not state then ?>
  <div class="notice error"><strong>Cannot continue.</strong> <?lsp=app.escapeHtml(err)?> Start again from the first page.</div>
  <p><a class="button secondary" href="/">Start over</a></p>
<?lsp else ?>
  <p class="lead">Your name has now been saved inside the encrypted JSON object.</p>

  <form method="post" action="summary.lsp" class="stacked-form">
    <input type="hidden" name="state" value="<?lsp=app.escapeHtml(encrypted)?>">

    <label for="food">What is your favorite food?</label>
    <input id="food" name="food" type="text" required autofocus>

    <button type="submit">Show Summary</button>
  </form>
<?lsp end ?>

<?lsp response:include"footer.shtml" ?>
