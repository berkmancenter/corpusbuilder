import { action, observable } from 'mobx';
import Request from '../lib/Request';

export default class Documents {
    constructor(baseUrl, state) {
        this.state = state;
        this.baseUrl = baseUrl;
    }

    tree(documentId, branchName = 'master', page = 1, preloadNext = 1, preloadPrev = 1, force = false) {
        branchName = 'f8b4334f-82d0-4a7b-a481-c4fd82457f60';
        let key = `${branchName}-${page}`
        if( !this.state.trees.has(key)) {
            Request
                .get(
                  `${this.baseUrl}/api/documents/${documentId}/${branchName}/tree`,
                  {
                      surface_number: page
                  }
                )
                .then(
                    action(
                        ( tree ) => {
                            this.state.surfaceCounts.set(`${documentId}-${branchName}`, tree.global.surfaces_count);
                            this.state.trees.set(key, tree);
                        }
                    )
                );
        }

        if(preloadNext > 0 || preloadPrev > 0) {
            let count = this.state.surfaceCounts.get(`${documentId}-${branchName}`);

            if(count !== null && count !== undefined) {
                if(preloadNext > 0 && page + 1 <= count) {
                    this.tree(documentId, branchName, page + 1, preloadNext - 1, 0);
                }
                if(preloadPrev > 0 && page > 1) {
                    this.tree(documentId, branchName, page - 1, 0, preloadPrev - 1);
                }
            }
        }

        return this.state.trees.get(key);
    }

    info(documentId) {
        if( !this.state.infos.has(documentId)) {
            Request
                .get(`${this.baseUrl}/api/documents/${documentId}`)
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
                .get(`${this.baseUrl}/api/documents/${documentId}/branches`)
                .then(
                    action(
                        ( branches ) => {
                            this.state.branches.set( documentId, branches.branches );
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
                .get(`${this.baseUrl}/api/documents/${documentId}/${branchName}/revisions`)
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

    correct(doc, page, line, branchName, text, boxes) {
        let payload = {
            edit_spec: {
                grapheme_ids: line.map((g) => { return g.id; }),
                text: text,
                boxes: boxes.map((box) => {
                      return {
                          ulx: box.ulx,
                          uly: box.uly,
                          lrx: box.lrx,
                          lry: box.lry
                      }
                  }
                )
            }
        };

        Request
            .put(`${this.baseUrl}/api/documents/${doc.id}/${branchName}/tree`, payload)
            .then(
                action(
                    ( _ ) => {
                        this.tree(doc.id, branchName, page);
                    }
                )
            );
    }
}
