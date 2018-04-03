import Action from '../lib/Action';
import Diff from '../models/Diff';

export default class FetchDocumentDiff extends Action {
    execute(state, selector, params) {
        if(selector.version.identifier === selector.otherVersion.identifier) {
            return Diff.empty();
        }
        else {
            return state.resolve(selector, () => {
                let url = `${state.baseUrl}/api/documents/${selector.document.id}/${selector.version.identifier}/diff`;

                return this.get(url, { other_version: selector.otherVersion.identifier, surface_number: selector.pageNumber }).then((raw) => {
                    return new Diff(raw.diffs, raw.stats.differing_surfaces);
                });
            });
        }
    }
}

