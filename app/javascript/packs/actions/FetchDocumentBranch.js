import { autorun } from 'mobx';

import Action from '../lib/Action';
import FetchDocumentBranches from './FetchDocumentBranches';
import Version from '../models/Version';

export default class FetchDocumentBranch extends Action {
    execute(state, selector, params) {
        let version = Version.branch(selector.name);

        let stopObserving = autorun(() => {
            let branches = FetchDocumentBranches.run(state, {
                select: {
                    document: {
                        id: selector.document.id
                    }
                }
            });

            if(branches !== undefined) {
                let branch = branches.find((branch) => {
                    return branch.name == selector.name;
                });

                if(branch !== undefined) {
                    version.update(branch);
                }

                if(typeof stopObserving === 'function') {
                    stopObserving();
                }
            }
        });

        return version;
    }
}

