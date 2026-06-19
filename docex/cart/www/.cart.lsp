<html>
  <head>
    <title>Shopping Cart Route</title>
    <style>
      body {
        margin: 0;
        padding: 32px;
        background: #1e1f22;
        color: #d7dbd8;
        font: 16px/1.5 system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      }
      main {
        max-width: 640px;
        margin: 0 auto;
        border: 1px solid #454856;
        border-radius: 8px;
        padding: 20px;
        background: #2d2f34;
      }
      h1 {
        color: #f2f4f3;
      }
      a {
        color: #ffd12b;
      }
    </style>
  </head>
  <body>
    <main>
    <?lsp if category and color then ?>
    <ul>
      <li>Category: <?lsp=category?></li>
      <li>Color: <?lsp=color?></li>
    </ul>
    <?lsp else ?>
    <h1>Empty URL</h1>
    <p>Try this URL: <a href="/cart/flowers/blue">/cart/flowers/blue</a></p>
    <?lsp end ?>
    </main>
  </body>
</html>
