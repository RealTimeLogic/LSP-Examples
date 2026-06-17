(function (window, document) {

    // we fetch the elements each time because docusaurus removes the previous
    // element references on page navigation
    function getElements() {
        return {
            layout: document.getElementById('layout'),
            menu: document.getElementById('menu'),
            menuLink: document.getElementById('menuLink')
        };
    }

    function toggleClass(element, className) {
        var classes = element.className.split(/\s+/);
        var length = classes.length;
        var i = 0;

        for (; i < length; i++) {
            if (classes[i] === className) {
                classes.splice(i, 1);
                break;
            }
        }
        // The className is not found
        if (length === classes.length) {
            classes.push(className);
        }

        element.className = classes.join(' ');
    }

    function toggleAll() {
        var active = 'active';
        var elements = getElements();

        toggleClass(elements.layout, active);
        toggleClass(elements.menu, active);
        toggleClass(elements.menuLink, active);
    }
    
    function handleEvent(e) {
        var elements = getElements();
        
        if (e.target.id === elements.menuLink.id) {
            toggleAll();
            e.preventDefault();
        } else if (elements.menu.className.indexOf('active') !== -1) {
            toggleAll();
        }
    }
    
    document.addEventListener('click', handleEvent);

    function routePath(path) {
        if (path === '/') {
          return '/index.html';
        }
        return path.match(/\/$/) ? path + 'index.html' : path;
    }

    function samePath(link) {
        var linkUrl = new URL(link.getAttribute('href'), window.location.href);
        return routePath(linkUrl.pathname) === routePath(window.location.pathname);
    }

    function setActiveLink(link) {
        document.querySelectorAll('.pure-menu-item .pure-menu-link').forEach(link => {
          link.classList.remove('pure-menu-selected');
        });
        if (link) {
          link.classList.add('pure-menu-selected');
          document.title = link.textContent.trim();
        }
    }

    function syncNavigationFromUrl() {
        var links = document.querySelectorAll('.pure-menu-item .pure-menu-link');
        var activeLink = null;

        links.forEach(link => {
          if (!activeLink && samePath(link)) {
            activeLink = link;
          }
        });

        if (activeLink) {
          setActiveLink(activeLink);
        }
    }

    document.body.addEventListener('htmx:afterRequest', function (event) {
      // Add the class to the clicked link
      const targetLink = event.target.closest('.pure-menu-link');
      if (targetLink) {
        setActiveLink(targetLink);
      }
    });

    document.body.addEventListener('htmx:historyRestore', syncNavigationFromUrl);
    window.addEventListener('popstate', function () {
      window.setTimeout(syncNavigationFromUrl, 0);
    });

}(this, this.document));
