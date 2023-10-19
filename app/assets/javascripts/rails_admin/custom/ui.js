// This js code will disable the toggling for the "Drive Size" in Rails Admin for Drive.
$(document).on('rails_admin.dom_ready', function() {
  var chevronDownElements = document.querySelectorAll(".icon-chevron-down");
  chevronDownElements.forEach(function(element) {
    element.remove();
  });
});
