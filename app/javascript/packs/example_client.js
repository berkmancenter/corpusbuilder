import mock from 'xhr-mock'
import masterTreeJson from './master-tree-example.json'
import topicTreeJson from './topic-tree-example.json'

let baseUrl = 'localhost.dev';
let documentId = "43f158c6-fae8-4aef-b696-dd28024f6936";

mock.setup();

function logRequest(req) {
    console.log(`%c ${req._method} ${req._url}`, 'color: green; font-weight: bold');
}

mock.get(`${baseUrl}/corpusbuilder/documents/${documentId}/master/annotations`, (req, res) => {
    logRequest(req);
    return res
        .status(200)
        .body(JSON.stringify(
          [
          ]
        ));
});

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

mock.get(`${baseUrl}/corpusbuilder/documents/${documentId}/master/revisions`, (req, res) => {
    logRequest(req);
    return res
        .status(200)
        .body(JSON.stringify(
          [
            {
                id: '29315b8f-c6ec-496a-915e-3608ac6c374a',
                updated_at: '2017-08-29T11:58:55.153Z'
            },
            {
                id: '806f0602-49e0-46ab-87b7-1e52c5a11540',
                updated_at: '2017-08-29T11:58:55.153Z'
            },
            {
                id: '37426277-c123-4bd8-ac8d-5301be963111',
                updated_at: '2017-08-29T11:58:55.153Z'
            },
            {
                id: '8d053ff4-89ac-4403-bade-7ca22de31867',
                updated_at: '2017-08-29T11:58:55.153Z'
            },
            {
                id: '65e10407-393f-455a-8066-58b271a9e5c5',
                updated_at: '2017-08-29T11:58:55.153Z'
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
