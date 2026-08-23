"use strict";

function busy(button) {
  button.classList.add("is-busy");
  button.setAttribute("aria-disabled", "true");
  button.setAttribute("aria-busy", "true");
}

document.addEventListener("click", function(event) {
  const link = event.target.closest("a.button");
  if (link && event.button === 0 && !event.ctrlKey && !event.metaKey &&
      !event.shiftKey && !event.altKey && !link.target) busy(link);
});

document.addEventListener("submit", function(event) {
  const form = event.target;
  if (form.dataset.submitting) return event.preventDefault();
  form.dataset.submitting = "true";
  const button = form.querySelector('button[type="submit"]');
  if (button) busy(button);
});

window.addEventListener("pageshow", function() {
  document.querySelectorAll("form[data-submitting]").forEach(function(form) {
    delete form.dataset.submitting;
  });
  document.querySelectorAll(".button.is-busy").forEach(function(button) {
    button.classList.remove("is-busy");
    button.removeAttribute("aria-disabled");
    button.removeAttribute("aria-busy");
  });
});
