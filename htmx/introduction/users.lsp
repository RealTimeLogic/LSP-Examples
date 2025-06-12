<?lsp
local users = {
  { name = "Alice", email = "alice@example.com" },
  { name = "Bob", email = "bob@example.com" },
  { name = "Carol", email = "carol@example.com" }
}
?>

<ul>
<?lsp for _, user in ipairs(users) do ?>
  <li>
    <strong><?lsp= user.name ?></strong> - <?lsp= user.email ?>
  </li>
<?lsp end ?>
</ul>
