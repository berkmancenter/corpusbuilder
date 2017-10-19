import { observable } from 'mobx'

class State {
    @observable
    trees = observable.map();

    @observable
    branches = observable.map();

    @observable
    infos = observable.map();

    @observable
    revisions = observable.map();
}

export default window.__CB_STATE = new State();
