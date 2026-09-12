<?lsp
response:setheader("Content-Security-Policy","default-src 'self'; script-src 'self'; style-src 'self'; connect-src 'self'; img-src 'self' data:; base-uri 'none'; form-action 'self'; frame-ancestors 'none'")
response:setheader("Referrer-Policy","no-referrer")
response:setheader("X-Content-Type-Options","nosniff")
response:setheader("X-Frame-Options","DENY")
?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="dark">
  <title>Manual DNS-01 Certificate Test</title>
  <link rel="stylesheet" href="app.css">
  <script src="app.js" defer></script>
</head>
<body>
  <main class="shell">
    <header class="hero">
      <div>
        <p class="eyebrow"><span class="brand-mark" aria-hidden="true"></span>Real Time Logic · ACME test</p>
        <h1>Manual DNS-01 certificate test</h1>
        <p class="intro">Follow the requested DNS changes while Mako Server completes certificate validation in the background.</p>
      </div>
      <div id="statusBadge" class="status-badge" data-tone="waiting">
        <span class="status-dot" aria-hidden="true"></span>
        <span id="statusLabel">Connecting to Mako Server</span>
      </div>
    </header>

    <ol id="progress" class="progress" aria-label="Certificate workflow">
      <li data-step="request"><span>1</span><strong>Request</strong><small>Create order</small></li>
      <li data-step="publish"><span>2</span><strong>Publish</strong><small>Add TXT record</small></li>
      <li data-step="validate"><span>3</span><strong>Validate</strong><small>Confirm DNS</small></li>
      <li data-step="complete"><span>4</span><strong>Complete</strong><small>Install certificate</small></li>
    </ol>

    <section class="content-grid">
      <article class="panel workflow-panel">
        <div class="panel-heading">
          <div>
            <p class="section-label">Operator action</p>
            <h2 id="actionTitle">Waiting for the ACME client</h2>
          </div>
          <button id="refreshButton" class="icon-button" type="button" title="Refresh status" aria-label="Refresh status">
            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20 6v5h-5M4 18v-5h5M6.1 9a7 7 0 0 1 11.5-2.6L20 9M4 15l2.4 2.6A7 7 0 0 0 17.9 15"/></svg>
          </button>
        </div>

        <p id="actionMessage" class="action-message" aria-live="polite">Reading the current certificate-management state.</p>

        <div id="recordPanel" class="record-panel" hidden>
          <div class="record-row">
            <div>
              <span class="field-label">TXT record name</span>
              <code id="recordName"></code>
            </div>
            <button class="copy-button" type="button" data-copy="recordName">Copy</button>
          </div>
          <div class="record-row">
            <div>
              <span class="field-label">TXT record value</span>
              <code id="recordData"></code>
            </div>
            <button class="copy-button" type="button" data-copy="recordData">Copy</button>
          </div>
        </div>

        <div id="errorBox" class="message-box error-box" role="alert" hidden></div>
        <div id="successBox" class="message-box success-box" hidden>
          <strong>Certificate installed</strong>
          <span>The managed certificate is ready for use by Mako Server.</span>
        </div>

        <div class="actions">
          <button id="primaryButton" class="button primary" type="button" disabled>Waiting for status</button>
          <button id="cancelButton" class="button secondary" type="button" hidden>Cancel challenge</button>
        </div>
      </article>

      <aside class="panel detail-panel">
        <p class="section-label">Current configuration</p>
        <h2>Certificate details</h2>
        <dl>
          <div><dt>Domain</dt><dd id="domainValue">Not available</dd></div>
          <div><dt>ACME service</dt><dd id="serviceValue">Not available</dd></div>
          <div><dt>Operation</dt><dd id="operationValue">Waiting</dd></div>
          <div><dt>Certificate expiry</dt><dd id="expiryValue">Not issued</dd></div>
        </dl>
        <div class="note">
          <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l8 4v5c0 5-3.4 8.1-8 9-4.6-.9-8-4-8-9V7l8-4zM9 12l2 2 4-5"/></svg>
          <p>Confirm the step after the displayed TXT record has been added at your DNS provider.</p>
        </div>
      </aside>
    </section>

    <footer>
      <span id="lastUpdated">Status has not been loaded.</span>
      <span class="footer-separator" aria-hidden="true"></span>
      <span>Updates automatically while the test is active.</span>
    </footer>
  </main>
  <div id="toast" class="toast" role="status" aria-live="polite" hidden></div>
</body>
</html>
