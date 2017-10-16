import { observable } from 'mobx'

class State {
    @observable
    documents = observable.map();

    @observable
    documentInfos = observable.map();

    @observable
    showCertainties = false;

    @observable
    showInfo = false;
}

export default window.__CB_STATE = new State();
