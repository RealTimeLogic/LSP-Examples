<?lsp

-- This page, which is executed when the user has no access, must have
-- the .lsp extension. This page is not part of the CMS and must
-- include all HTML components. This page is registered in cms.lua by
-- calling authDir:p403("/.lua/www/no-access.lsp")

-- Unauthorized: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
-- The AJAX call requires this status
response:setstatus(401)

?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Unauthorized</title>
    <link rel="stylesheet" href="/static/pure-min.css">
    <link rel="stylesheet" href="/static/styles.css">
</head>
<body>
<div id="layout">
    <div id="main">
        <div class="header">
            <h1>Unauthorized</h1>
            <p>You are authenticated as: <?lsp=request:user()?></p>
            <h2>Click the back button to continue</h2>
        </div>
    </div>
</div>
</body>
</html>
