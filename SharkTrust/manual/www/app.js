(() => {
  "use strict";

  const $ = id => document.getElementById(id);
  const ui = {
    badge: $("statusBadge"), label: $("statusLabel"), title: $("actionTitle"),
    message: $("actionMessage"), recordPanel: $("recordPanel"),
    recordName: $("recordName"), recordData: $("recordData"), error: $("errorBox"),
    success: $("successBox"), primary: $("primaryButton"), cancel: $("cancelButton"),
    refresh: $("refreshButton"), domain: $("domainValue"), service: $("serviceValue"),
    operation: $("operationValue"), expiry: $("expiryValue"), updated: $("lastUpdated"),
    toast: $("toast")
  };
  const steps = [...document.querySelectorAll("#progress li")];
  let state, csrf, requestPending = false, pollTimer;

  function setText(node, value, fallback = "Not available") {
    node.textContent = value == null || value === "" ? fallback : value;
  }

  function serviceName(url) {
    if (!url) return "Not available";
    if (url.includes("acme-staging")) return "Let's Encrypt staging";
    if (url.includes("letsencrypt.org")) return "Let's Encrypt production";
    try { return new URL(url).hostname; } catch (_) { return url; }
  }

  function dateTime(seconds) {
    if (!seconds) return "Not issued";
    return new Intl.DateTimeFormat(undefined, {dateStyle: "medium", timeStyle: "short"})
      .format(new Date(seconds * 1000));
  }

  function activeStep(value) {
    if (value.ready && value.phase === "idle") return 3;
    if (value.phase === "active") return 2;
    if (value.phase === "publish") return 1;
    return 0;
  }

  function drawProgress(value) {
    const current = activeStep(value);
    steps.forEach((step, index) => {
      step.classList.toggle("done", index < current || (current === 3 && index === 3));
      step.classList.toggle("current", index === current && !(current === 3 && value.ready));
    });
  }

  function setBadge(tone, label) {
    ui.badge.dataset.tone = tone;
    setText(ui.label, label);
  }

  function render(value) {
    state = value;
    if (value.csrf) csrf = value.csrf;
    ui.error.hidden = !value.error;
    setText(ui.error, value.error, "");
    ui.success.hidden = !value.ready;
    ui.recordPanel.hidden = !value.recordName;
    setText(ui.recordName, value.recordName+".", "");
    setText(ui.recordData, value.recordData, "");

    const domain = value.domains && value.domains[0];
    setText(ui.domain, domain && domain.name);
    setText(ui.service, serviceName(value.directoryUrl));
    setText(ui.operation, value.operation || (value.starting ? "Starting" : value.retryPending ? "Retry scheduled" : value.ready ? "Ready" : "Idle"));
    setText(ui.expiry, dateTime(domain && domain.expiresAt));

    let title = "Waiting for the ACME client";
    let message = "The next action will appear automatically.";
    let button = "Waiting for DNS challenge";
    let enabled = false;
    let tone = "waiting";
    let badge = "Waiting";

    if (!value.configured) {
      title = "Certificate management is not running";
      message = "Add the manual DNS-01 configuration to mako.conf and restart Mako Server.";
      button = "Configuration required";
      tone = "error";
      badge = "Not configured";
    } else if (!value.manual) {
      title = "Manual DNS-01 is not selected";
      message = "Check the manualDns settings in mako.conf, then restart Mako Server.";
      button = "Manual mode required";
      tone = "error";
      badge = "Wrong challenge mode";
    } else if (value.phase === "publish") {
      title = "Publish the TXT record";
      if (value.canManage) {
        message = "Add the exact name and value shown below at your DNS provider. Continue only after the public record resolves.";
        button = "I have published the TXT record";
        enabled = true;
        tone = "active";
        badge = "Operator action required";
      } else {
        message = "Open this application locally or sign in to confirm the DNS change.";
        button = "Local access required";
        badge = "Read-only";
      }
    } else if (value.phase === "active") {
      title = "ACME validation is running";
      message = "Mako Server is asking the ACME service to validate the published TXT record.";
      button = "Validating DNS record";
      tone = "active";
      badge = "Validation in progress";
    } else if (value.ready) {
      title = "Certificate installed";
      message = "The certificate is installed. You may request a new certificate whenever needed.";
      button = value.canManage ? "Request new certificate" : "Certificate ready";
      enabled = value.canManage;
      tone = "success";
      badge = "Certificate ready";
    } else if (value.error) {
      title = "Certificate request needs attention";
      message = "Review the reported error, correct the configuration or DNS record, and restart the test when ready.";
      button = "Waiting for restart";
      tone = "error";
      badge = "Request failed";
    } else if (value.operation || value.starting) {
      title = "Preparing the certificate order";
      message = "Mako Server is opening the ACME service and preparing the DNS-01 challenge.";
      button = "Preparing challenge";
      tone = "active";
      badge = "Working";
    }

    setText(ui.title, title);
    setText(ui.message, message);
    setText(ui.primary, button);
    ui.primary.disabled = requestPending || !enabled;
    ui.cancel.hidden = value.phase !== "publish" || !value.canManage;
    ui.cancel.disabled = requestPending;
    setBadge(tone, badge);
    drawProgress(value);
    ui.updated.textContent = `Last updated ${new Date().toLocaleTimeString()}`;
  }

  function showTransportError(message) {
    render({configured:false, manual:false, phase:"unavailable", error:message});
    setText(ui.title, "Cannot read certificate status");
    setText(ui.message, "Check that the application is running and that this browser is authorized.");
    setBadge("error", "Connection failed");
  }

  async function loadStatus() {
    try {
      const response = await fetch("status.lsp", {headers:{Accept:"application/json"}, cache:"no-store"});
      const value = await response.json();
      if (!response.ok || !value.ok) throw new Error(value.error?.message || `HTTP ${response.status}`);
      render(value);
    } catch (error) {
      showTransportError(error.message || String(error));
    } finally {
      clearTimeout(pollTimer);
      pollTimer = setTimeout(loadStatus, state && state.phase === "publish" ? 3000 : 1500);
    }
  }

  async function perform(action) {
    if (requestPending || !csrf) return;
    requestPending = true;
    let failure;
    ui.primary.classList.add("busy");
    ui.primary.disabled = ui.cancel.disabled = true;
    try {
      const body = new URLSearchParams({action, csrf});
      const response = await fetch("action.lsp", {method:"POST", body, headers:{Accept:"application/json"}});
      const value = await response.json();
      if (!response.ok || !value.ok) throw new Error(value.error?.message || `HTTP ${response.status}`);
      render(value);
    } catch (error) {
      failure = error.message || String(error);
    } finally {
      requestPending = false;
      ui.primary.classList.remove("busy");
      if (state) render(state);
      if (failure) {
        ui.error.hidden = false;
        setText(ui.error, failure);
      }
      loadStatus();
    }
  }

  async function copy(id) {
    const value = $(id).textContent;
    try {
      await navigator.clipboard.writeText(value);
      ui.toast.textContent = "Copied to clipboard";
      ui.toast.hidden = false;
      setTimeout(() => { ui.toast.hidden = true; }, 1600);
    } catch (_) {
      ui.toast.textContent = "Clipboard access is unavailable. Select and copy the value manually.";
      ui.toast.hidden = false;
    }
  }

  ui.primary.addEventListener("click", () => perform(state && state.ready ? "renew" : "continue"));
  ui.cancel.addEventListener("click", () => perform("cancel"));
  ui.refresh.addEventListener("click", loadStatus);
  document.querySelectorAll("[data-copy]").forEach(button =>
    button.addEventListener("click", () => copy(button.dataset.copy)));
  loadStatus();
})();
