<?lsp
if "POST" == request:method() then
   app.addNewTrustedDomain(request)
end
?>
<!DOCTYPE html>
<html>
  <body>
    <p>Javascript must be enabled!</p>
    <script type="module">
        const response = await fetch('<?lsp=request:url()?>', {
            method:"POST",
            headers: {
                ["X-Token"]: '<?lsp=app.getCSRFToken()?>',
                ["X-Domain"]:'<?lsp=request:domain()?>'
            }
        });
        await response.text();
        window.location.href="myapp/"
    </script>
  </body>
</html>

