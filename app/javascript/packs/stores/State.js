import { observable } from 'mobx'

class State {
    @observable
    documents = observable.map();

    @observable
    showCertainties = false;
}

export default window.__CB_STATE = new State();
