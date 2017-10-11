import mock from 'xhr-mock'

let baseUrl = 'localhost.dev/';
let documentId = "61389c62-b6a6-4339-b4c2-87fae4a6c0ab";

mock.setup();

mock.get(`${baseUrl}/corpusbuilder/documents/${documentId}/master/tree`, (req, res) => {
    return res
        .status(200)
        .body(JSON.stringify(
          {
            id: documentId,
            surfaces: []
          }
        ));
});
