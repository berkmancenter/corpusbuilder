import { autorun } from 'mobx';

import Action from '../lib/Action';
import Version from '../models/Version';

export default class FetchDocumentStatus extends Action {
    execute(state, selector, params) {
        return state.promise(selector, () => {
            let url = `${state.baseUrl}/api/documents/${params.document.id}/status`;

            return this.get(url).then((data) => { return data.status });
        });
    }
}


