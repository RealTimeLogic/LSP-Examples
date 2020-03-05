<?lsp

title='Info'
response:include".header.lsp"
?>

<p>This example shows how to connect to Google Cloud IoT Core's MQTT Bridge.</p>


<ol>
  <li>Follow the <a href="https://cloud.google.com/iot/docs/quickstart">Cloud IoT Core Quick Start Guide</a></li>
  <li>Do the following when you get to the section<br/>"Add a device to the registry":
  <ol>
    <li>Navigate to the <a href="regdev.lsp">Register Device tab</a></li>
    <li>Select and copy the certificate data</li>
    <li>You do not need to "Generate a device key pair" since this example does this automatically. Select RS256_X509 for the public key format and paste in the certificate copied in the previous step.</li>
    <li>Do not follow the Node.js sample instructions.</li>
  </ol>
  </li>
    <li>Navigate to the <a href="connect.lsp">Connect tab</a></li>
    <li>Fill in all fields by using the data from Google Cloud Platform</li>
    <li>Click the Connect button
    <ul>
      <li>The example should now successfully connect to the MQTT bridge</li>
      <li>Make sure to validate all fields if the connection fails!</li>
    </ul>
    </li>
    
    <li>Using the Google Cloud Platform, under IoT Core:
    <ol>
      <li>Click EDIR REGISTRY</li>
      <li>Click SHOW ADVANCED OPTIONS</li>
      <li>Select Debug under section Stackdriver Logging</li>
      <li>Click the Update button</li>
      <li>Click View logs</li>
    </ol>
    </li>
    <li>Navigate to the <a href="publish.lsp">Publish tab</a></li>
    <li>Enter any data and click the Publish button</li>
    <li>Verify that publishing to the MQTT Bridge works by inspecting the Google Cloud Platform's Logs Viewer.</li>
</ol>

<?lsp response:include"footer.shtml" ?>



