import { action } from 'mobx';

import Action from '../lib/Action';
import Selector from '../lib/Selector';

export default class DeleteDocumentAnnotation extends Action {
    execute(state, selector, params) {
        return this['delete'](`${state.baseUrl}/api/documents/${selector.document.id}/${selector.version.identifier}/annotations/${params.id}`)
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


