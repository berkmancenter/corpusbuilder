import { action } from 'mobx';
import * as qwest from 'qwest';

export default class Documents {
    constructor(state) {
        this.state = state;
    }

    async get(documentId) {
        return this.state = await qwest.get(`/corpusbuilder/documents/${documentId}/master/tree`);
    }
}
