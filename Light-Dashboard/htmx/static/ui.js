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

    var connectionWarningDismissed = false;

    function removeConnectionWarning() {
        var overlay = document.getElementById('connectionWarning');
        if (overlay) overlay.remove();
    }

    function connectionRestored() {
        connectionWarningDismissed = false;
        removeConnectionWarning();
    }

    function showConnectionWarning(title, message) {
        if (connectionWarningDismissed) return;

        var overlay = document.getElementById('connectionWarning');
        if (!overlay) {
            overlay = document.createElement('div');
            overlay.id = 'connectionWarning';
            overlay.className = 'connection-overlay';
            overlay.setAttribute('role', 'alertdialog');
            overlay.setAttribute('aria-modal', 'true');
            overlay.setAttribute('aria-labelledby', 'connectionWarningTitle');

            var panel = document.createElement('div');
            panel.className = 'connection-panel';
            var heading = document.createElement('h2');
            heading.id = 'connectionWarningTitle';
            heading.className = 'connection-title';
            var detail = document.createElement('p');
            detail.className = 'connection-message';
            var actions = document.createElement('div');
            actions.className = 'connection-actions';
            var retry = document.createElement('a');
            retry.href = window.location.href;
            retry.className = 'connection-button connection-button-primary';
            retry.textContent = 'Retry';
            var dismiss = document.createElement('button');
            dismiss.type = 'button';
            dismiss.className = 'connection-button connection-button-secondary';
            dismiss.textContent = 'Dismiss';
            dismiss.addEventListener('click', function () {
                connectionWarningDismissed = true;
                removeConnectionWarning();
            });
            actions.append(retry, dismiss);
            panel.append(heading, detail, actions);
            overlay.appendChild(panel);
            document.body.appendChild(overlay);
        }

        overlay.querySelector('.connection-title').textContent = title;
        overlay.querySelector('.connection-message').textContent = message;
    }

    function requestFailure(event, fallback) {
        var xhr = event.detail && event.detail.xhr;
        var status = xhr && xhr.status;
        return status
            ? 'The server returned HTTP ' + status + '. Retry when the service is available.'
            : fallback;
    }

    function requestSucceeded(event) {
        var xhr = event.detail && event.detail.xhr;
        return Boolean(xhr && xhr.status >= 200 && xhr.status < 400);
    }

    document.body.addEventListener('htmx:afterRequest', function (event) {
      var successful = requestSucceeded(event);
      if (successful) {
        connectionRestored();
      } else {
        showConnectionWarning(
          'Page update failed',
          requestFailure(event, 'The server could not be reached. Check the connection and try again.')
        );
      }

      // Add the class to the clicked link
      const targetLink = event.target.closest('.pure-menu-link');
      if (successful && targetLink) {
        setActiveLink(targetLink);
      }
    });

    document.addEventListener('htmx:beforeRequest', function () {
      connectionWarningDismissed = false;
    }, true);
    document.addEventListener('htmx:sendError', function (event) {
      showConnectionWarning(
        'Server unavailable',
        requestFailure(event, 'The server could not be reached. Check the connection and try again.')
      );
    }, true);
    document.addEventListener('htmx:timeout', function () {
      showConnectionWarning('Request timed out', 'The server did not respond in time. Try again.');
    }, true);
    document.addEventListener('htmx:responseError', function (event) {
      showConnectionWarning(
        'Page update failed',
        requestFailure(event, 'The server rejected the page update. Try again.')
      );
    }, true);

    document.addEventListener('cms:smq-connect', connectionRestored);
    document.addEventListener('cms:smq-close', function (event) {
      var detail = event.detail || {};
      var message = detail.canReconnect
        ? 'The real-time connection was lost. Reconnecting automatically.'
        : 'The real-time connection was closed. Reload the page to reconnect.';
      showConnectionWarning('Real-time connection lost', message);
    });
    document.addEventListener('cms:smq-subscribe-error', function () {
      showConnectionWarning(
        'Real-time subscription denied',
        'The server rejected a real-time page subscription. Reload the page or contact the administrator.'
      );
    });

    window.addEventListener('offline', function () {
      showConnectionWarning('Network unavailable', 'This device is offline. Reconnect to the network and try again.');
    });
    window.addEventListener('online', connectionRestored);

    document.body.addEventListener('htmx:historyRestore', syncNavigationFromUrl);
    window.addEventListener('popstate', function () {
      window.setTimeout(syncNavigationFromUrl, 0);
    });

}(this, this.document));
