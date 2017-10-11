import { extendObservable } from 'mobx'

class State {
    constructor() {
        extendObservable(this, {
            documents: {  }
        });
    }
}

export default window.__CB_STATE = new State();
