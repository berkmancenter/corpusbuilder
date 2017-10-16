import { observable } from 'mobx'

class State {
    @observable
    documents = observable.map();
}

export default window.__CB_STATE = new State();
