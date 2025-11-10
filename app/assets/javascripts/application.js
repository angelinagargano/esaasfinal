// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
document.addEventListener("turbo:load", () => {
  document.querySelectorAll(".btn-like, .btn-dislike").forEach(btn => {
    btn.addEventListener("click", e => {
      e.preventDefault();
      const icon = btn.querySelector("i");
      if (btn.classList.contains("btn-like")) {
        icon.classList.toggle("active");
      } else if (btn.classList.contains("btn-dislike")) {
        icon.classList.toggle("active");
      }

      // Send AJAX request manually if needed
      btn.closest("form").submit();
    });
  });
});
