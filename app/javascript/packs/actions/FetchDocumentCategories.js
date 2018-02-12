import Action from '../lib/Action';

export default class FetchDocumentCategories extends Action {
    execute(state, selector, params) {
        return state.resolve(selector, () => {
            let url = `${state.baseUrl}/api/documents/${selector.document.id}/annotations/categories`;

            return this.get(url);
        });
    }
}


