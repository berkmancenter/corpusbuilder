import mock from 'xhr-mock'
import masterTreeJson from './master-tree-example.json'
import topicTreeJson from './topic-tree-example.json'

let baseUrl = 'localhost.dev';
let documentId = "43f158c6-fae8-4aef-b696-dd28024f6936";

mock.setup();

function logRequest(req) {
    console.log(`%c ${req._method} ${req._url}`, 'color: green; font-weight: bold');
}

mock.get(`${baseUrl}/corpusbuilder/documents/${documentId}/branches`, (req, res) => {
    logRequest(req);
    return res
        .status(200)
        .body(JSON.stringify(
          [
            {
              revision_id: 'some-revision-id-1234',
              name: 'master',
              editor: {
                id: 'some-editor-id-1234',
                email: 'author1@email.com'
              }
            },
            {
              revision_id: 'some-revision-id-23456',
              name: 'some-topic-branch',
              editor: {
                id: 'some-editor-id-23456',
                email: 'author2@email.com'
              }
            }
          ]
        ));
});

mock.get(`${baseUrl}/corpusbuilder/documents/${documentId}`, (req, res) => {
    logRequest(req);
    return res
        .status(200)
        .body(JSON.stringify(
          {
            id: documentId,
            title: "The Invincible",
            author: "Stanislaw Lem",
            date: "1964"
          }
        ));
});

mock.get(`${baseUrl}/corpusbuilder/documents/${documentId}/master/tree`, (req, res) => {
    logRequest(req);

    return res
        .status(200)
        .body(JSON.stringify(masterTreeJson));
});

mock.get(`${baseUrl}/corpusbuilder/documents/${documentId}/some-topic-branch/tree`, (req, res) => {
    logRequest(req);

    return res
        .status(200)
        .body(JSON.stringify(topicTreeJson));
});
