<?lsp

title='Publish'
response:include".header.lsp"
local mqtt, err = app.connect()
-- If not connected.
if not mqtt then response:sendredirect"./" end

-- Fetch the device info table and use deviceId when assembling the MQTT topic name
local topicName=string.format("/devices/%s/events",app.devinfo().deviceId)

local data,published
if mqtt and request:method() == "POST" then
   data=request:data()
   -- https://realtimelogic.com/ba/doc/?url=MQTT.html#publish
   --mqtt:publish(data.topic, data.pubdata)
   mqtt:publish(topicName, data.pubdata)
   published=true
else
   data={topic=''}
end


?>
<h1>Publish Data</h1>

<?lsp if published then ?>
<div class="alert alert-success"><strong>Published!</strong></div>
<?lsp end ?>

<form method="POST">
  <div class="form-group">
    <label>Topic: <?lsp=topicName?></label>
  </div>
  <div class="form-group">
    <label for="pubdata">Data:</label>
    <textarea class="form-control" id="pubdata" placeholder="Enter data to publish" name="pubdata" /></textarea>
  </div>
<?lsp if mqtt then ?>
  <button class="btn btn-lg btn-primary btn-block" type="submit">Publish</button>
<?lsp else ?>
<div class="alert alert-danger"><strong>Not Connected!</strong></div>
<?lsp end ?>
</form>
<?lsp response:include"footer.shtml" ?>
