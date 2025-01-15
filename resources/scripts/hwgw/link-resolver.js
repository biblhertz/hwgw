window.addEventListener("load", function (event) {
  if (window.location.hash) {
    let location = window.location.hash;

    let volumePrefixes = /(#s03|#s04)/;

    if (location.match(volumePrefixes)) {
      let volume = location.match(volumePrefixes)[0].split("#")[1];

      if (location.startsWith("#" + volume + "-app")) {
        window.location.replace(volume + "/" + volume + "-app.xml" + location);
      } else if (location.startsWith("#" + volume + "-ed")) {
        window.location.replace(volume + "/" + volume + "-ed.xml" + location);
      } else if (location.startsWith("#" + volume + "-in")) {
        window.location.replace(volume + "/" + volume + "-in.xml" + location);
      } else if (location.startsWith("#" + volume + "-doc")) {
        window.location.replace(volume + "/" + volume + "-app.xml" + location);
      } else if (location.startsWith("#" + volume + "-pg")) {
        let page = Number(
          location.split("#" + volume + "-pg")[1].split("-")[0],
        );

        if (volume == "s03") {
          if (9 <= page && page <= 82) {
            window.location.replace(
              volume + "/" + volume + "-in.xml" + location,
            );
          } else if (83 <= page && page <= 224) {
            window.location.replace(
              volume + "/" + volume + "-ed.xml" + location,
            );
          } else if (227 <= page && page <= 394) {
            window.location.replace(
              volume + "/" + volume + "-app.xml" + location,
            );
          } else {
            window.location.replace(volume + "/index.html");
          }
        } else if (volume == "s04") {
          if (9 <= page && page <= 37) {
            window.location.replace(
              volume + "/" + volume + "-in.xml" + location,
            );
          } else if (39 <= page && page <= 126) {
            window.location.replace(
              volume + "/" + volume + "-ed.xml" + location,
            );
          } else if (129 <= page && page <= 244) {
            window.location.replace(
              volume + "/" + volume + "-app.xml" + location,
            );
          } else {
            window.location.replace(volume + "/index.html");
          }
        } else {
          window.location.replace(volume + "/index.html");
        }
      } else {
        window.location.replace(volume + "/index.html");
      }
    } else if (location.startsWith("#gnd")) {
      window.location.replace("register.xml" + location);
    } else if (location.startsWith("#object")) {
      window.location.replace("register.xml" + location);
    } else if (location.startsWith("#bib")) {
      window.location.replace("register.xml" + location);
    } else {
      window.location.replace("index.html");
    }

    // Fragment exists
  } else {
    window.location.replace("index.html");
  }
});
