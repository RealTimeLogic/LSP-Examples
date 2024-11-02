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
    <input id="in" type="text" />
    <h3 id="out">JavaScript not enabled</h3>
  </body>
</html>
