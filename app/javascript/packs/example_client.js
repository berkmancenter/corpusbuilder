import mock from 'xhr-mock'

let baseUrl = 'localhost.dev';
let documentId = "61389c62-b6a6-4339-b4c2-87fae4a6c0ab";

mock.setup();

function logRequest(req) {
    console.log(`%c ${req._method} ${req._url}`, 'color: green; font-weight: bold');
}

mock.get(`${baseUrl}/corpusbuilder/documents/${documentId}/master/tree`, (req, res) => {
    logRequest(req);

    let _graphemes = (base = 0) => {
        let __graphemes = [];

        let lastX = 100;
        let lastY = 50;

        for(let i = 0; i < 1800; i++) {
          let x = lastX + 7;
          let y = lastY;

          if(Math.random() < 1/5) {
            x += 7;
          }

          if(x + 10 > 530) {
            x = 100;
            y += 10;
          }

          lastX = x;
          lastY = y;

          let _area = {
            ulx: x, lrx: (x+7),
            uly: y, lry: y + 10
          };
          __graphemes.push({
              id: i + base,
              value: (String.fromCharCode((Math.round(Math.random() * 100) % 27) + 65)),
              certainty: Math.random(),
              area: _area
          });
        }
        return __graphemes;
    };

    return res
        .status(200)
        .body(JSON.stringify(
          {
            id: documentId,
            surfaces: [
              {
                number: 1,
                area: {
                  ulx: 0, lrx: 600,
                  uly: 0, lry: 800
                },
                image_url: "/examples/scan.jpg",
                graphemes: _graphemes()
              },
              {
                number: 2,
                area: {
                  ulx: 0, lrx: 600,
                  uly: 0, lry: 800
                },
                image_url: "/examples/scan.jpg",
                graphemes: _graphemes(4000)
              },
              {
                number: 3,
                area: {
                  ulx: 0, lrx: 600,
                  uly: 0, lry: 800
                },
                image_url: "/examples/scan.jpg",
                graphemes: _graphemes(8000)
              },
            ]
          }
        ));
});
