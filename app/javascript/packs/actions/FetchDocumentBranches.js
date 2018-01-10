import Action from '../lib/Action';

export default class FetchDocumentBranches extends Action {
    execute(state, selector, params) {
        return state.resolve(selector, () => {
            let url = `${state.baseUrl}/api/documents/${selector.document.id}/branches`;

            return this.get(url).then((data) => {
                return data.branches;
            });
        });
    }
}


