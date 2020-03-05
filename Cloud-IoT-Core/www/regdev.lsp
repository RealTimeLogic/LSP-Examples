<?lsp

title='Register Device'
response:include".header.lsp"

if app.connect() then -- if connected
   print'<h1>Device Registered</h1> <img src="https://i.pinimg.com/originals/a1/41/08/a14108b5e5cd6aaa49801f3cd726adbd.gif">'
   response:include"footer.shtml"
   return
end

-- 1: Create CSR
local keyusage = {"KEY_CERT_SIGN","CRL_SIGN"}
local certtype = {"OBJECT_SIGNING"}
local privkey=app.getkey() -- See the .preload script
local csr = ba.create.csr(privkey, {commonname="Device"}, certtype, keyusage)

-- 2: Create an X.509 ECC 256 certificate
local validFrom=os.date"*t"
local validTo=os.date"*t"
validFrom.day = validFrom.day - 1
validTo.year = validTo.year + 1
local cert = ba.create.certificate(csr, privkey, validFrom, validTo, 1)


?>
<h1>Register Device</h1>
<ul>
<li>Navigate to <a target="_blank" href="https://console.cloud.google.com/iot/">Google IoT Core</a></li>
<li>Select (navigate) to your project</li>
<li>Select <i>Devices</i></li>
<li>Click <i>+ CREATE A DEVICE</i></li>
<li>Enter a <i>Device ID</i></li>
<li>Under section <i>Public key format</i>, select <i>ES256_X509</i></li>
<li>Copy the certificate below and paste into the <i>Public key value</i> field</li>
<li>Click the <i>Create</i> button</li>
</ul>

<pre><?lsp=cert?></pre>

<?lsp response:include"footer.shtml" ?>


