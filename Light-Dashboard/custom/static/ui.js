(function (window, document) {
  "use strict";

  function getElements() {
    return {
      layout: document.getElementById("layout"),
      menu: document.getElementById("menu"),
      menuLink: document.getElementById("menuLink")
    };
  }

  function toggleClass(element, className) {
    if (element) {
      element.classList.toggle(className);
    }
  }

  function toggleAll() {
    const elements = getElements();

    toggleClass(elements.layout, "active");
    toggleClass(elements.menu, "active");
    toggleClass(elements.menuLink, "active");
  }

  function routePath(path) {
    if (path === "/") {
      return "/index.html";
    }
    return path.endsWith("/") ? `${path}index.html` : path;
  }

  function linkMatchesLocation(link) {
    const linkUrl = new URL(link.getAttribute("href"), window.location.href);
    return routePath(linkUrl.pathname) === routePath(window.location.pathname);
  }

  function setActiveLink(activeLink) {
    document
      .querySelectorAll(".nav-link.is-active, .nav-sublink.is-active, .nav-group-title.is-active")
      .forEach((link) => {
        link.classList.remove("is-active");
        link.removeAttribute("aria-current");
      });

    document.querySelectorAll(".nav-group.is-active").forEach((group) => {
      group.classList.remove("is-active");
    });

    if (!activeLink) {
      return;
    }

    activeLink.classList.add("is-active");
    activeLink.setAttribute("aria-current", "page");
    document.title = activeLink.textContent.trim();

    const group = activeLink.closest(".nav-group");
    if (group) {
      group.classList.add("is-active");
    }
  }

  function syncNavigationFromUrl() {
    const activeLink = Array.from(document.querySelectorAll(".nav-link, .nav-sublink, .nav-group-title[href]"))
      .find(linkMatchesLocation);

    setActiveLink(activeLink);
  }

  let connectionWarningDismissed = false;

  function removeConnectionWarning() {
    const overlay = document.getElementById("connectionWarning");
    if (overlay) {
      overlay.remove();
    }
  }

  function connectionRestored() {
    connectionWarningDismissed = false;
    removeConnectionWarning();
  }

  function showConnectionWarning(title, message) {
    if (connectionWarningDismissed) {
      return;
    }

    let overlay = document.getElementById("connectionWarning");
    if (!overlay) {
      overlay = document.createElement("div");
      overlay.id = "connectionWarning";
      overlay.className = "connection-overlay";
      overlay.setAttribute("role", "alertdialog");
      overlay.setAttribute("aria-modal", "true");
      overlay.setAttribute("aria-labelledby", "connectionWarningTitle");

      const panel = document.createElement("div");
      panel.className = "connection-panel";

      const heading = document.createElement("h2");
      heading.id = "connectionWarningTitle";
      heading.className = "connection-title";

      const detail = document.createElement("p");
      detail.className = "connection-message";

      const actions = document.createElement("div");
      actions.className = "connection-actions";

      const retry = document.createElement("a");
      retry.href = window.location.href;
      retry.className = "connection-button connection-button-primary";
      retry.textContent = "Retry";

      const dismiss = document.createElement("button");
      dismiss.type = "button";
      dismiss.className = "connection-button connection-button-secondary";
      dismiss.textContent = "Dismiss";
      dismiss.addEventListener("click", () => {
        connectionWarningDismissed = true;
        removeConnectionWarning();
      });

      actions.append(retry, dismiss);
      panel.append(heading, detail, actions);
      overlay.appendChild(panel);
      document.body.appendChild(overlay);
    }

    overlay.querySelector(".connection-title").textContent = title;
    overlay.querySelector(".connection-message").textContent = message;
  }

  function requestFailure(event, fallback) {
    const xhr = event.detail && event.detail.xhr;
    const status = xhr && xhr.status;
    if (status) {
      return `The server returned HTTP ${status}. Retry when the service is available.`;
    }
    return fallback;
  }

  function requestSucceeded(event) {
    const xhr = event.detail && event.detail.xhr;
    return Boolean(xhr && xhr.status >= 200 && xhr.status < 400);
  }

  function handleEvent(event) {
    const elements = getElements();
    const { menu, menuLink } = elements;
    const target = event.target;

    if (menuLink && menuLink.contains(target)) {
      toggleAll();
      event.preventDefault();
      return;
    }

    const groupTitle = target.closest && target.closest(".nav-group-title");
    if (groupTitle && groupTitle.tagName === "SPAN") {
      const group = groupTitle.closest(".nav-group");
      if (group) {
        toggleClass(group, "is-open");
      }
      event.preventDefault();
      return;
    }

    if (menu && menu.classList.contains("active") && !menu.contains(target)) {
      toggleAll();
    }
  }

  document.addEventListener("click", handleEvent);

  document.body.addEventListener("htmx:afterRequest", (event) => {
    const successful = requestSucceeded(event);
    if (successful) {
      connectionRestored();
    } else {
      showConnectionWarning(
        "Page update failed",
        requestFailure(event, "The server could not be reached. Check the connection and try again.")
      );
    }

    const targetLink = event.target.closest(".nav-link, .nav-sublink, .nav-group-title[href]");
    if (successful && targetLink) {
      setActiveLink(targetLink);
    }
  });

  document.addEventListener("htmx:beforeRequest", () => {
    connectionWarningDismissed = false;
  }, true);
  document.addEventListener("htmx:sendError", (event) => {
    showConnectionWarning(
      "Server unavailable",
      requestFailure(event, "The server could not be reached. Check the connection and try again.")
    );
  }, true);
  document.addEventListener("htmx:timeout", () => {
    showConnectionWarning("Request timed out", "The server did not respond in time. Try again.");
  }, true);
  document.addEventListener("htmx:responseError", (event) => {
    showConnectionWarning(
      "Page update failed",
      requestFailure(event, "The server rejected the page update. Try again.")
    );
  }, true);

  document.addEventListener("cms:smq-connect", connectionRestored);
  document.addEventListener("cms:smq-close", (event) => {
    const detail = event.detail || {};
    const message = detail.canReconnect
      ? "The real-time connection was lost. Reconnecting automatically."
      : "The real-time connection was closed. Reload the page to reconnect.";
    showConnectionWarning("Real-time connection lost", message);
  });
  document.addEventListener("cms:smq-subscribe-error", () => {
    showConnectionWarning(
      "Real-time subscription denied",
      "The server rejected a real-time page subscription. Reload the page or contact the administrator."
    );
  });

  window.addEventListener("offline", () => {
    showConnectionWarning("Network unavailable", "This device is offline. Reconnect to the network and try again.");
  });
  window.addEventListener("online", connectionRestored);

  document.body.addEventListener("htmx:historyRestore", syncNavigationFromUrl);
  window.addEventListener("popstate", () => {
    window.setTimeout(syncNavigationFromUrl, 0);
  });
}(this, this.document));
