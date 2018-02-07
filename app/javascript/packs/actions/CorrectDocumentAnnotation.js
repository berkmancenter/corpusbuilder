import { action } from 'mobx';

import Action from '../lib/Action';
import Selector from '../lib/Selector';

export default class CorrectDocumentAnnotation extends Action {
    execute(state, selector, params) {
        let payload = {
            content: params.content,
            mode: params.mode,
            payload: JSON.stringify(params.payload)
        };

        return this.put(`${state.baseUrl}/api/documents/${selector.document.id}/${selector.version.identifier}/annotations/${params.id}`, payload)
            .then(
                action(
                    ( _ ) => {
                        state.invalidate(
                            new Selector('FetchDocumentAnnotations', {
                                document: { id: selector.document.id },
                                surfaceNumber: selector.surfaceNumber
                            })
                        );
                    }
                )
            );
    }
}




