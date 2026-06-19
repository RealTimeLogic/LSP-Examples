<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Email Logging Test</title>
  <style>
    body {
      margin: 0;
      padding: 32px;
      background: #1e1f22;
      color: #d7dbd8;
      font: 16px/1.5 system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }
    main {
      max-width: 860px;
      margin: 0 auto;
    }
    h1 {
      color: #f2f4f3;
    }
    pre {
      overflow-x: auto;
      border: 1px solid #454856;
      border-radius: 8px;
      padding: 16px;
      background: #2d2f34;
      color: #f2f4f3;
    }
  </style>
</head>
<body>
<main>
<h1>Email Logging Test</h1>
<p>This page intentionally raises an error only when Mako runs in background mode, so the logging system can email the stack trace.</p>
<pre>
<?lsp

local function a()
   if mako.daemon then
      error"This code is designed to crash. You should receive an email with the stack trace."
   else
      print(debug.traceback"The server is not running in the background")
   end
end

local function b()
   a()
end

b()

?>
</pre>
</main>
</body>
</html>
