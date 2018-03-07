import { action } from 'mobx';

import Action from '../lib/Action';
import Selector from '../lib/Selector';

export default class CommitDocumentChanges extends Action {
    execute(state, selector, params) {
        let branchVersion = selector.version.isRevision ? selector.version.branchVersion : selector.version;

        return this.put(`${state.baseUrl}/api/documents/${selector.document.id}/${branchVersion.branchName}/commit`)
            .then(
                action(
                    ( _ ) => {
                        state.invalidate(
                            new Selector('FetchDocumentPage', {
                                document: { id: selector.document.id }
                            })
                        );
                        state.invalidate(
                            new Selector('FetchDocumentDiff', {
                                document: { id: selector.document.id }
                            })
                        );
                        state.invalidate(
                            new Selector('FetchDocumentBranch', {
                                document: { id: selector.document.id }
                            })
                        );
                        state.invalidate(
                            new Selector('FetchDocumentBranches', {
                                document: { id: selector.document.id }
                            })
                        );
                    }
                )
            );
    }
}



