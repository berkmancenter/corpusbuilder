import { action } from 'mobx';

import Action from '../lib/Action';
import Selector from '../lib/Selector';

export default class CorrectDocumentPage extends Action {
    execute(state, selector, params) {
        let payload = {
            surface_number: params.surfaceNumber,
            words: params.words.filter(w => w['text'] !== null && w['text'] !== undefined),
            direction: params.direction
        };

        let branchVersion = selector.version.isRevision ? selector.version.branchVersion : version;

        return this.put(`${state.baseUrl}/api/documents/${selector.document.id}/${branchVersion.branchName}/tree`, payload)
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
                    }
                )
            );
    }
}




