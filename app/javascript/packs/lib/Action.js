import Selector from './Selector';
import Request from './Request';

export default class Action {
    static run(state, options) {
        let action = new this();
        let selector = new Selector(action.constructor.name, options.select);

        return action.execute(state, selector, options);
    }

    get = Request.get;
    post = Request.post;
    put = Request.post;
}
