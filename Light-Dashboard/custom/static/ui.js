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
        var menu = elements.menu;
        var menuLink = elements.menuLink;
        var target = e.target;

        if (menuLink && menuLink.contains(target)) {
            toggleAll();
            e.preventDefault();
            return;
        }

        var groupTitle = target.closest && target.closest('.nav-group-title');
        if (groupTitle && groupTitle.tagName === 'SPAN') {
            var group = groupTitle.closest('.nav-group');
            if (group) {
                toggleClass(group, 'is-open');
            }
            e.preventDefault();
            return;
        }

        if (menu && menu.className.indexOf('active') !== -1 && !menu.contains(target)) {
            toggleAll();
        }
    }
    
    document.addEventListener('click', handleEvent);

    document.body.addEventListener('htmx:afterRequest', function (event) {

      // Add the class to the clicked link
      const targetLink = event.target.closest('a');
      if (targetLink) {
document.querySelectorAll('.nav-link.is-active, .nav-sublink.is-active')
  .forEach(link => link.classList.remove('is-active'));
        targetLink.classList.add('is-active');
      }
    });

}(this, this.document));
