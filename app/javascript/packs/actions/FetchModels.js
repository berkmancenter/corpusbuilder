import Action from '../lib/Action';

export default class FetchModels extends Action {
    execute(state, selector, params) {
        return state.resolve(selector, () => {
            let url = `${state.baseUrl}/api/models`;

            return this.get(url, { languages: params.languages, backend: params.backend });
        });
    }
}


