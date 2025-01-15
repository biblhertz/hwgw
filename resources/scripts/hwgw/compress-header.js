// When the user scrolls down X px from the top of the document, resize the header's font size
window.onscroll = function () {
  scrollFunction();
};

function scrollFunction() {
  if (document.body.scrollTop > 60 || document.documentElement.scrollTop > 60) {
    document.getElementById("header").classList.add("narrow-header");
  } else {
    document.getElementById("header").classList.remove("narrow-header");
  }
}
