<html>
  <body>
    <?lsp if category and color then ?>
    <ul>
      <li>Category: <?lsp=category?></li>
      <li>Color: <?lsp=color?></li>
    </ul>
    <?lsp else ?>
    <h1>Empty URL</h1>
    <p>Try this URL: <a href="/cart/flowers/blue">/cart/flowers/blue</a></p>
    <?lsp end ?>
  </body>
</html>
