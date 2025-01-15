window.addEventListener("load", () => {
  /* update title after switching pages or chapters */
  pbEvents.subscribe(
    "pb-update",
    "transcription",
    (ev) => {
      console.log("update");

      let elem = ev.detail.root;

      const pageTitle = elem.querySelector(".pagetitle");
      if (pageTitle) {
        document.title = pageTitle.innerText;
      }
    },
    false,
  );
});
