<?lsp -- LSP tag; this code runs at the server side
if "POST" == request:method() then
   local key=request:data"key"
   if key then
      local resp
      key=tonumber(key)
      if key and key >=32 and key <= 127 then
         resp=string.char(key)
      else
         resp = key and string.format(' "%d" ',key) or '?'
      end
      trace("AJAX data:", key, resp) -- Print to server's console
      response:json({char=resp}) -- Also exits LSP page
   end
end
?>
<html>
  <head>
    <title>AJAX Keypress Example</title>
    <style>
      body {
        margin: 0;
        padding: 32px;
        background: #1e1f22;
        color: #d7dbd8;
        font: 16px/1.5 system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      }
      main {
        max-width: 720px;
        margin: 0 auto;
      }
      h1 {
        color: #f2f4f3;
        font-size: 28px;
      }
      input {
        width: 100%;
        box-sizing: border-box;
        border: 1px solid #454856;
        border-radius: 6px;
        padding: 10px 12px;
        background: #2d2f34;
        color: #f2f4f3;
        font: inherit;
      }
      #out {
        min-height: 80px;
        border: 1px solid #454856;
        border-radius: 8px;
        padding: 16px;
        background: #2d2f34;
        color: #f2f4f3;
      }
    </style>
    <script>
      document.addEventListener("DOMContentLoaded", () => {
        const outputElement = document.getElementById("out");
        const inputElement = document.getElementById("in");
 
        // Initialize output display
        outputElement.innerHTML = "Enter text above.<br>";
 
        inputElement.addEventListener("keypress", async (event) => {
          // Prepare URL-encoded data
          const formData = new URLSearchParams();
          formData.append("key", event.which);
 
          try {
            // Send the key code to the server
            const response = await fetch(window.location, {
              method: "POST",
              headers: {
                "Content-Type": "application/x-www-form-urlencoded",
              },
              body: formData.toString()
            });
 
            if (!response.ok) {
              throw new Error(`Server error: ${response.statusText}`);
            }
 
            const data = await response.json(); // Wait for server response
            outputElement.innerHTML += data.char; // Add response to page data
          } catch (error) {
            console.error("Error fetching data:", error);
          }
        });
      });
    </script>
  </head>
  <body>
    <main>
      <h1>AJAX Keypress Example</h1>
      <p>Type in the field below. Each keypress is posted to this LSP page and the JSON response is appended to the output area.</p>
      <input id="in" type="text" autocomplete="off" />
      <h3 id="out">JavaScript not enabled</h3>
    </main>
  </body>
</html>
