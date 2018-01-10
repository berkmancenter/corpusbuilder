import Action from '../lib/Action';

export default class ObserveMousePosition extends Action {
    execute(state, selector, params) {
        selector.tag = 'MousePosition';

        state.invalidate(selector);

        return state.resolve(selector, () => {
            return { x: params.x, y: params.y };
        });
    }
}

