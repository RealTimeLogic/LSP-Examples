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
    const targetLink = event.target.closest(".nav-link, .nav-sublink, .nav-group-title[href]");
    if (targetLink) {
      setActiveLink(targetLink);
    }
  });

  document.body.addEventListener("htmx:historyRestore", syncNavigationFromUrl);
  window.addEventListener("popstate", () => {
    window.setTimeout(syncNavigationFromUrl, 0);
  });
}(this, this.document));
