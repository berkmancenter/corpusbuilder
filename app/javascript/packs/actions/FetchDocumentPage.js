import Action from '../lib/Action';
import Selector from '../lib/Selector';

export default class FetchDocumentPage extends Action {
    execute(state, selector, params) {
        let prefetch = (doc, pageNumber) => {
            if(pageNumber > 0 && pageNumber < doc.global.surfaces_count) {
                  FetchDocumentPage.run(state, {
                      select: {
                          document: selector.document,
                          pageNumber: pageNumber,
                          version: selector.version
                      },
                      noPrefetch: true
                  });
            }
        };

        let document = state.resolve(selector, () => {
            let url = `${state.baseUrl}/api/documents/${selector.document.id}/${encodeURIComponent(selector.version.identifier)}/tree`;

            return this.get(url, { surface_number: selector.pageNumber }).then((doc) => {
                if(!params.noPrefetch) {
                    prefetch(doc, selector.pageNumber - 1);
                    prefetch(doc, selector.pageNumber + 1);
                }

                return doc;
            });
        });

        if(!params.noPrefetch && document !== undefined) {
            prefetch(document, selector.pageNumber - 1);
            prefetch(document, selector.pageNumber + 1);
        }

        return document;
    }
}
