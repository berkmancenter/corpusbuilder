import { action } from 'mobx';

import Action from '../lib/Action';
import Selector from '../lib/Selector';

export default class MergeDocumentBranches extends Action {
    execute(state, selector, params) {
        let payload = {
            other_branch: selector.otherBranch.identifier
        };

        let branchVersion = selector.branch.isRevision ? selector.branch.branchVersion : selector.branch;

        let callback = action((_) => {
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
                new Selector('FetchDocumentBranches', {
                    document: { id: selector.document.id }
                })
            );
        });

        return this.put(`${state.baseUrl}/api/documents/${selector.document.id}/${branchVersion.branchName}/merge`, payload)
            .catch(callback)
            .finally(callback);
    }
}





