import Action from '../lib/Action';

export default class FetchSimilarDocuments extends Action {
    execute(state, selector, params) {
        return state.resolve(selector, () => {
            let url = `${state.baseUrl}/api/documents/similar`;

            return this.get(url, { metadata: params.metadata }).then((data) => {
                return data.documents;
            });
        });
    }
}

