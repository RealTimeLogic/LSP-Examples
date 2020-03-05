<?lsp

title='Connect'
response:include".header.lsp"
local data, connected, err
if request:method() == "POST" then
   data=request:data()
   connected, err = app.connect(data)
else
   data = app.devinfo() or {region='', projectId='', registryId='', deviceId=''}
   connected, err = app.connect() -- Just get status
end

?>
<h1>Connect to mqtt.googleapis.com</h1>

<?lsp if not connected and err then ?>
<div class="alert alert-danger"><strong>Connection failed: <?lsp=err?></strong></div>
<?lsp end ?>

<form method="POST">
  <div class="form-group">
    <label for="projectId">Project Id:</label>
    <input type="text" class="form-control" id="projectId" placeholder="Enter Project Id" name="projectId" value='<?lsp=data.projectId?>'/>
  </div>
  <div class="form-group">
    <label for="region">Region:</label>
    <input type="text" class="form-control" id="region" placeholder="Enter Region" name="region" value='<?lsp=data.region?>'/>
  </div>
  <div class="form-group">
    <label for="registryId">Registry Id:</label>
    <input type="text" class="form-control" id="registryId" placeholder="Enter Registry Id" name="registryId" value='<?lsp=data.registryId?>'/>
  </div>
  <div class="form-group">
    <label for="deviceId">Device Id:</label>
    <input type="text" class="form-control" id="deviceId" placeholder="Enter Device Id" name="deviceId" value='<?lsp=data.deviceId?>'/>
  </div>
<?lsp if connected then ?>
<div class="alert alert-success"><strong>Connected!</strong></div>
<?lsp else ?>
  <button class="btn btn-lg btn-primary btn-block" type="submit">Connect</button>
   <?lsp end ?>
</form>

<?lsp response:include"footer.shtml" ?>
