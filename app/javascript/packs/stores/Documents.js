import { action } from 'mobx';
import Request from '../lib/Request';

export default class Documents {
    constructor(baseUrl, state) {
        this.state = state;
        this.baseUrl = baseUrl;
    }

    @action async get(documentId) {
        let doc = await Request.get(`${this.baseUrl}/corpusbuilder/documents/${documentId}/master/tree`);

        this.state.documents.set(documentId, doc);

        return doc;
    }

    @action async info(documentId) {
        let data = await Request.get(`${this.baseUrl}/corpusbuilder/documents/${documentId}`);

        this.state.documentInfos.set(documentId, data);

        return data;
    }
}
