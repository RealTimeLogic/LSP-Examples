<?lsp
request:logout()
response:sendredirect(request:header"referer" or "./")
?>
