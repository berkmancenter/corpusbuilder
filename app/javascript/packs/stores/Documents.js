import { action, autorun, observable } from 'mobx';
import Request from '../lib/Request';
import Version from '../models/Version';

export default class Documents {
    constructor(baseUrl, state) {
        this.state = state;
        this.baseUrl = baseUrl;
    }

    tree(documentId, version, page = 1, preloadNext = 1, preloadPrev = 1, force = false) {
        let key = `${version.identifier}-${page}`

        if( force || !this.state.trees.has(key)) {
            console.log(`Fetching for ${key}`);
            Request
                .get(
                  `${this.baseUrl}/api/documents/${documentId}/${version.identifier}/tree`,
                  {
                      surface_number: page
                  }
                )
                .then(
                    action(
                        ( tree ) => {
                            this.state.surfaceCounts.set(`${documentId}-${version.identifier}`, tree.global.surfaces_count);
                            this.state.trees.set(key, tree);
                        }
                    )
                );
        }

        if(preloadNext > 0 || preloadPrev > 0) {
            let count = this.state.surfaceCounts.get(`${documentId}-${version.identifier}`);

            if(count !== null && count !== undefined) {
                if(preloadNext > 0 && page + 1 <= count) {
                    this.tree(documentId, version, page + 1, preloadNext - 1, 0);
                }
                if(preloadPrev > 0 && page > 1) {
                    this.tree(documentId, version, page - 1, 0, preloadPrev - 1);
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

    getVersion(options) {
        if(options.name !== undefined) {
            return this.getBranch(options.name, options.documentId);
        }
        else {
            return this.getRevision(options.revisionId, options.documentId);
        }
    }

    getBranch(name, documentId) {
        if( !this.state.branches.has(documentId)) {
            let version = Version.branch(name);

            let stopObserving = autorun(() => {
                if(this.state.branches.has(documentId)) {
                    let branches = this.state.branches.get(documentId);

                    let branch = branches.find((branch) => {
                        return branch.name == name;
                    });

                    version.update(branch);
                    stopObserving();
                }
            });
            this.branches( documentId );

            return version;
        }
        else {
            let branches = this.state.branches.get(documentId);

            let branch = branches.find((branch) => {
                return branch.name == name;
            });

            return Version.branch(branch);
        }
    }

    getRevision(id, documentId) {
    }

    createBranch(documentId, parentVersion) {
       //let payload = {
       //    edit_spec: {
       //        grapheme_ids: line.map((g) => { return g.id; }),
       //        text: text,
       //        boxes: boxes.map((box) => {
       //              return {
       //                  ulx: box.ulx,
       //                  uly: box.uly,
       //                  lrx: box.lrx,
       //                  lry: box.lry
       //              }
       //          }
       //        )
       //    }
       //};

       //Request
       //    .put(`${this.baseUrl}/api/documents/${doc.id}/${branchName}/tree`, payload)
       //    .then(
       //        action(
       //            ( _ ) => {
       //                this.tree(doc.id, branchName, page);
       //            }
       //        )
       //    );
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

    reset(documentId, version) {
        let branch = version.isBranch ? version : version.branchVersion;

        return Request
            .put(`${ this.baseUrl }/api/documents/${ documentId }/${ branch.branchName }/reset`)
            .then(
                action(
                    ( _ ) => {
                        this.state.trees.clear();
                    }
                )
            );
    }

    correct(doc, page, line, version, text, boxes) {
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

        let branchVersion = version.isRevision ? version.branchVersion : version;;

        return Request
            .put(`${this.baseUrl}/api/documents/${doc.id}/${branchVersion.branchName}/tree`, payload)
            .then(
                action(
                    ( _ ) => {
                        this.tree(doc.id, version, page, 0, 0, true);
                    }
                )
            );
    }
}
