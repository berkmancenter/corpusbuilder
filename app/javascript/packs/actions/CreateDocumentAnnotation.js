import { action } from 'mobx';

import Action from '../lib/Action';
import Selector from '../lib/Selector';

export default class CreateDocumentAnnotation extends Action {
    execute(state, selector, params) {
        let payload = {
            content: params.content,
            areas: params.areas,
            surface_number: selector.surfaceNumber
        };

        return this.post(`${state.baseUrl}/api/documents/${selector.document.id}/${selector.version.identifier}/annotations`, payload)
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


