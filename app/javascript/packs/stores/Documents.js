import { action, observable } from 'mobx';
import Request from '../lib/Request';

export default class Documents {
    constructor(baseUrl, state) {
        this.state = state;
        this.baseUrl = baseUrl;
    }

    tree(documentId, branchName = 'master') {
        if( !this.state.trees.has(branchName)) {
            Request
                .get(`${this.baseUrl}/corpusbuilder/documents/${documentId}/${branchName}/tree`)
                .then(
                    action(
                        ( tree ) => {
                            this.state.trees.set(branchName, tree);
                        }
                    )
                );
        }

        return this.state.trees.get(branchName);
    }

    info(documentId) {
        if( !this.state.infos.has(documentId)) {
            Request
                .get(`${this.baseUrl}/corpusbuilder/documents/${documentId}`)
                .then(
                    action(
                        ( info ) => {
                            this.state.infos.set( documentId, info );
                        }
                    )
                );
        }

        return this.state.infos.get(documentId);
    }

    branches(documentId) {
        if( !this.state.branches.has(documentId)) {
            Request
                .get(`${this.baseUrl}/corpusbuilder/documents/${documentId}/branches`)
                .then(
                    action(
                        ( branches ) => {
                            this.state.branches.set( documentId, branches );
                        }
                    )
                );
        }

        return this.state.branches.get(documentId);
    }

    revisions(documentId, branchName) {
        let documentRevisions = this.state.revisions.get(documentId);

        if( documentRevisions === undefined || documentRevisions === null) {
            documentRevisions = observable.map();
            this.state.revisions.set(documentId, documentRevisions);
        }

        if( !documentRevisions.has(branchName) ) {
            Request
                .get(`${this.baseUrl}/corpusbuilder/documents/${documentId}/${branchName}/revisions`)
                .then(
                    action(
                        ( revisions ) => {
                            documentRevisions.set( branchName, revisions );
                        }
                    )
                );
        }

        return documentRevisions.get(branchName)
    }
}
