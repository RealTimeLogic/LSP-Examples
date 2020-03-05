<?lsp 
  response:setstatus(404)
  title="Not Found"

  -- Just for fun. Professional Stand Up Paddle Boarder "Danny" (pictured) named his boards
  -- after the 404 HTTP status and message displayed on 404 pages.
  -- The following image is from the Pacific Paddle Games: https://goo.gl/maps/vHeVfyeDC42HHfMA8
extheader=[[
<style>
body{
  background: url(https://cdn.shopify.com/s/files/1/1302/0941/files/DANNY_COVER_1728x.jpg) no-repeat fixed;
  background-size: cover;
  background-position: 50%;
} 
</style>
]]


  response:include".header.lsp"
?>
<h1>404 not found</h1>

<p class="center">This message comes from the file <a href="showsource/?path=.404.lsp">.404.lsp</a>.</p>
<p>Danny Ching is paddling on his 404 paddle board at the Pacific Paddle Games Doheny State Beach.</p>

<?lsp response:include"footer.shtml" ?>
