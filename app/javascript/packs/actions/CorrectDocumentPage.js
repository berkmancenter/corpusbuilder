import { action } from 'mobx';

import Action from '../lib/Action';
import Selector from '../lib/Selector';

export default class CorrectDocumentPage extends Action {
    execute(state, selector, params) {
        let payload = {
            edit_spec: {
                grapheme_ids: params.line.map((g) => { return g.id; }),
                text: params.text,
                boxes: params.boxes.map((box) => {
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

        let branchVersion = selector.version.isRevision ? selector.version.branchVersion : version;

        return this.put(`${state.baseUrl}/api/documents/${selector.document.id}/${branchVersion.branchName}/tree`, payload)
            .then(
                action(
                    ( _ ) => {
                        state.invalidate(
                            new Selector('FetchDocumentPage', {
                                document: { id: selector.document.id },
                                pageNumber: selector.pageNumber
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




