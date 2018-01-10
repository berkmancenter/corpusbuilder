import { action } from 'mobx';

import Action from '../lib/Action';
import Selector from '../lib/Selector';

export default class ResetDocumentBranch extends Action {
    execute(state, selector, params) {
        let branchVersion = selector.version.isRevision ? selector.version.branchVersion : version;

        return this.put(`${state.baseUrl}/api/documents/${selector.document.id}/${branchVersion.branchName}/reset`)
            .then(
                action(
                    ( _ ) => {
                        this.state.invalidate(
                            new Selector('FetchDocumentPage', {
                                document: { id: selector.document.id }
                            })
                        );
                    }
                )
            );
    }
}


