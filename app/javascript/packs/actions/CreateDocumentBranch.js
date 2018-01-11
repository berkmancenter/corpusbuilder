import { action } from 'mobx';

import Action from '../lib/Action';
import Selector from '../lib/Selector';

export default class CreateDocumentBranch extends Action {
    execute(state, selector, params) {
        let branchVersion = selector.version.isRevision ? selector.version.branchVersion : selector.version;

        let payload = {
            revision: branchVersion.branchName,
            name: selector.name
        };

        return this.post(`${state.baseUrl}/api/documents/${selector.document.id}/branches`, payload)
            .then(
                action(
                    ( _ ) => {
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

