import { action, observable } from 'mobx';

export default class Mouse {
    constructor(state) {
        this.state = state;
    }

    lastPosition() {
        return this.state.mouseLastPosition;
    }

    @action
    setLastPosition(x, y) {
        if(this.state.mouseLastPosition === null || this.state.mouseLastPosition === undefined) {
            this.state.mouseLastPosition = observable({ x: x, y: y });
        }
        else {
            this.state.mouseLastPosition = { x: x, y: y };
        }
    }
}
