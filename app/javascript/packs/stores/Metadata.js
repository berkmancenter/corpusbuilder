import { action, observable } from 'mobx';
import Request from '../lib/Request';

export default class Metadata {
    constructor(baseUrl, state) {
        this.state = state;
        this.baseUrl = baseUrl;
    }

    @action
    saveAnnotation(documentId, branchName, text, graphemes) {
        // todo: do the save here

        let storeId = `${documentId}-${branchName}`;
        let annotations = this.state.annotations.get(storeId);

        if(annotations === undefined || annotations === null) {
            annotations = observable([]);
        }

        annotations.push(
            {
                graphemeIds: graphemes.map((grapheme) => { return grapheme.id }),
                text: text
            }
        );

        this.state.annotations.set(storeId, annotations);

        console.log(this.state);
    }

    annotations(doicumentId, branchName) {
        // todo: do the fetch here

        let storeId = `${documentId}-${branchName}`;
        return this.state.annotations.get(storeId) || [];
    }
}
