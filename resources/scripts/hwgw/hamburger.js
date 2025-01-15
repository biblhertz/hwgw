document.addEventListener("DOMContentLoaded", function () {
  var dropdownToggle = document.getElementById("material-icons");
  var dropdownContent = document.querySelector(".burger-dropdown-content");

  var isTouchDevice = "ontouchstart" in window || navigator.msMaxTouchPoints;

  if (isTouchDevice) {
    dropdownToggle.addEventListener("click", function () {
      if (dropdownContent.style.display === "block") {
        dropdownContent.style.display = "none";
        dropdownContent.style.visibility = "hidden";
      } else {
        dropdownContent.style.display = "block";
        dropdownContent.style.visibility = "visible";
      }
    });
  }
});
