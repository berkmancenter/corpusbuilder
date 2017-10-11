import { action } from 'mobx';
import * as qwest from 'qwest';

export default class Documents {
    constructor(baseUrl, state) {
        this.state = state;
        this.baseUrl = baseUrl;
    }

    @action async get(documentId) {
        let doc = await qwest.get(`${this.baseUrl}/corpusbuilder/documents/${documentId}/master/tree`);

        this.state.documents.set(documentId, doc);

        return doc;
    }
}
