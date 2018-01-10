import Action from '../lib/Action';

export default class FetchDocumentPage extends Action {
    execute(state, selector, params) {
        return state.resolve(selector, () => {
            let url = `${state.baseUrl}/api/documents/${selector.document.id}/${selector.version.identifier}/tree`;

            return this.get(url, { surface_number: selector.pageNumber });
        });
    }
}
