<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
    <link rel="icon" href="https://realtimelogic.com/favicon.ico"/>
    <title>Google IoT Core Bridge</title>
    <!-- Bootstrap core CSS -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" rel="stylesheet"/>
<style>
body {
  padding-top: 5rem;
}
.starter-template {
   max-width:650px;
   margin:auto;
   padding: 3rem;
}

h1,h2{
  text-align: center;
}

</style>
  </head>
  <body>
    <nav class="navbar navbar-expand-md navbar-dark bg-dark fixed-top">
      <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarsExampleDefault" aria-controls="navbarsExampleDefault" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarsExampleDefault">
        <ul class="navbar-nav mr-auto">
<?lsp
  local links={
     {'./', 'Info'},
     {'regdev.lsp', 'Register Device'},
     {'connect.lsp', 'Connect'},
     {'publish.lsp', 'Publish'},
  }
  for index,link in ipairs(links) do
     local isactive = title == link[2]
     response:write('<li class="nav-item',
                    isactive and ' active' or '',
                    '"><a class="nav-link" href="',link[1],'">',
                    link[2],isactive and ' <span class="sr-only">(current)</span>' or '',
                    '</a></li>')
  end
?>
        </ul>
      </div>
    </nav>
    <main role="main" class="container">
      <div class="starter-template">
