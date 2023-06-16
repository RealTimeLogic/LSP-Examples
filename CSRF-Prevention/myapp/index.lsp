<!DOCTYPE html>
<html>
  <body>
    <?lsp
    if "POST" == request:method() then
       print("<p>Form submit", app.verifyDomain(request) and "accepted" or "denied","</p>")
       trace("Form submit", app.verifyDomain(request) and "accepted" or "denied")
    end
    ?>
    <form method="post">
      <input type="submit"/>
    </form>

<p>You should see the text accepted being printed in the console when you click the above button. You should see the text denied being printed if you run the following html on another server. Copy the HTML below and replace the first HTML example on the following page: <a href="https://tutorial.realtimelogic.com/HTML-Forms.lsp">https://tutorial.realtimelogic.com/HTML-Forms.lsp</a>.</p>

<p>Click the run button, then click the submit button. You should see denied being printed in the console if your browser allows the cross posting. Note that the Brave browser blocks this.</p>

    <pre>
       &lt;html&gt;&lt;body&gt;
           &lt;form method="post" action="<?lsp=request:url()?>"&gt;
              &lt;input type="submit"&gt;
           &lt;/form&gt;
       &lt;/body&gt;&lt;/html&gt;
    </pre>
  </body>
</html>



