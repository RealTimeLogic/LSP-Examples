<?lsp
title="My Second Page"
response:include".header.lsp"
?>


<p>This is my second page</p>


<?lsp
page.counter = page.counter and page.counter + 1  or 1
curPageCounter=page.counter
trace("In page2.lsp, curPageCounter:",curPageCounter)
response:include".footer.lsp"
?>
