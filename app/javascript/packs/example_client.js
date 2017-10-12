import mock from 'xhr-mock'

let baseUrl = 'localhost.dev';
let documentId = "61389c62-b6a6-4339-b4c2-87fae4a6c0ab";

mock.setup();

function logRequest(req) {
    console.log(`%c ${req._method} ${req._url}`, 'color: green; font-weight: bold');
}

mock.get(`${baseUrl}/corpusbuilder/documents/${documentId}/master/tree`, (req, res) => {
    logRequest(req);

    return res
        .status(200)
        .body(JSON.stringify(
          {
            id: documentId,
            surfaces: [
              {
                number: 1,
                area: {
                  ulx: 0, lrx: 400,
                  uly: 0, lry: 600
                },
                image_url: "https://images.duckduckgo.com/iu/?u=http%3A%2F%2Fsudanreeves.org%2Fwp-content%2Fuploads%2F2014%2F10%2Fpage-1.jpg&f=1",
                graphemes: []
              }
            ]
          }
        ));
});
