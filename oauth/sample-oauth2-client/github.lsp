<?lsp

--[[

LSP version of the PHP script: github.php
https://github.com/aaronpk/sample-oauth2-client/blob/master/github.php
Tutorial: https://www.oauth.com/oauth2-servers/accessing-data/

--]]

-- Fill these out with the values you got from Github
local githubClientID = ''
local githubClientSecret = ''


-- This is the URL we'll send the user to first to get their authorization
local authorizeURL = 'https://github.com/login/oauth/authorize'

-- This is the endpoint our server will request an access token from
local tokenURL = 'https://github.com/login/oauth/access_token'

-- This is the Github base URL we can use to make authenticated API requests
local apiURLBase = 'https://api.github.com/'

-- The URL for this script, used as the redirect URL
local baseURL = request:url()

-- Start a session so we have a place to store things between redirects
local session=request:session(true)

-- $_GET equivalent.
local get = request:data()

-- No equivalent http_build_query so let's create one
local function http_build_query(params)
   local q={}
   for k,v in pairs(params) do table.insert(q,k..'='..v) end
   return table.concat(q,'&')
end

-- No equivalent echo so let's create one
local function echo(msg) response:write(msg) end

-- This helper function will make API requests to GitHub, setting
-- the appropriate headers GitHub expects, and decoding the JSON response
local function apiRequest(url, query)
   local  headers={
      Accept='application/vnd.github.v3+json, application/json',
      ['User-Agent'] = 'https://example-app.com/'
   }
   if session.access_token then
      headers.Authorization = 'Bearer ' .. session.access_token
   end
   local http = require"httpm".create{shark=mako.sharkclient()}
   local json,err = http:json(url, query, {header=headers})
   if not json then
      trace("Failed",url,err)
      return {}
   end
   return json
end


-- Start the login process by sending the user
-- to Github's authorization page
if get.action == 'login' then
  session.access_token = nil

  -- Generate a random hash and store in the session
   session.state = ba.b64urlencode(ba.rndbs(16))

  local params = {
    response_type = 'code',
    client_id = githubClientID,
    redirect_uri = baseURL,
    scope = 'user public_repo',
    state = session.state
  }

  -- Redirect the user to Github's authorization page
  response:sendredirect(authorizeURL..'?'..http_build_query(params))
end


if get.action == 'logout' then
  session.access_token = nil
  response:sendredirect(baseURL)
end

-- When Github redirects the user back here,
-- there will be a "code" and "state" parameter in the query string
if get.code then

  -- Verify the state matches our stored state
  if not get.state or session.state ~= get.state then
     response:sendredirect(baseURL .. '?error=invalid_state')
  end

  -- Exchange the auth code for an access token
  token = apiRequest(tokenURL, {
    grant_type = 'authorization_code',
    client_id = githubClientID,
    client_secret = githubClientSecret,
    redirect_uri = baseURL,
    code = get.code
  })
  session.access_token = token.access_token

  response:sendredirect(baseURL)
end


if get.action == 'repos' then
  -- Find all repos created by the authenticated user
  repos = apiRequest(apiURLBase..'user/repos',{
    sort = 'created',
    direction = 'desc'
  })

  echo '<ul>'
  for _,repo in ipairs(repos) do
     response:write('<li><a href="',repo.html_url, '">',repo.name,'</a></li>')
  end
  echo '</ul>'
end

-- If there is an access token in the session
-- the user is already logged in
if not get.action then
  if session.access_token then
    echo '<h3>Logged In</h3>'
    echo '<p><a href="?action=repos">View Repos</a></p>'
    echo '<p><a href="?action=logout">Log Out</a></p>'
  else
    echo '<h3>Not logged in</h3>'
    echo '<p><a href="?action=login">Log In</a></p>'
  end
  response:abort()
end

?>
