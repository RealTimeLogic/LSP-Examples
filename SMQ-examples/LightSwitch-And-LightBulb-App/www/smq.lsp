
<?lsp

-- Designed for 'local server' use. See README.txt for howto.

-- Note that the following code should normally be in a .preload script.
-- The code is copied "as is" from the following tutorial:
-- https://makoserver.net/blog/2014/12/Designing-a-browser-based-Chat-Client-using-SimpleMQ

  local smq = page.smq -- fetch from 'page' table
  if not smq then -- first time accessed
     smq = require"smq.broker".create() -- Create one broker instance
     page.smq = smq -- Store (reference) broker instance
  end
  smq.connect(request) -- Upgrade HTTP(S) request to an SMQ connection

?>
