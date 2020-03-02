<?lsp
page.counter = page.counter and page.counter + 1  or 1
trace("In .footer.lsp, curPageCounter:",curPageCounter)
?>
<p>Our site has been accessed <?lsp=page.counter?> times</p>
<p>The current page has been accessed <?lsp=curPageCounter?> times</p>
</body>
</html>
