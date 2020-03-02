<?lsp
title="My First Page"
response:include".header.lsp"
?>


<p>This is page one</p>


<?lsp
page.counter = page.counter and page.counter + 1  or 1
curPageCounter=page.counter
trace("In page1.lsp, curPageCounter:",curPageCounter)
response:include".footer.lsp"
?>
