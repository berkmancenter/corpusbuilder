import Action from '../lib/Action';

export default class GetMousePosition extends Action {
    execute(state, selector, params) {
        selector.tag = 'MousePosition';

        return state.resolve(selector, () => {
            return { x: 0, y: 0 };
        });
    }
}


