import Selector from './Selector';
import Request from './Request';

export default class Action {
    static get requests() {
        if(Action._requests === undefined) {
            Action._requests = new Map();
        }

        return Action._requests;
    }

    static run(state, options) {
        let action = new this();
        action.selector = new Selector(action.constructor.name, options.select);

        return action.execute(state, action.selector, options);
    }

    get(url, params) {
        if(!Action.requests.has(this.selector.id)) {
            Action.requests.set(this.selector.id, [ ]);

            Request.get(url, params)
                .then((data) => {
                    Action.requests.get(this.selector.id).forEach((callback) => {
                        callback(data, null);
                    });
                })
                .catch((error) => {
                    Action.requests.get(this.selector.id).forEach((callback) => {
                        callback(null, error);
                    });
                })
                .finally(() => {
                    Action.requests.delete(this.selector.id);
                });
        }

        return new Promise((resolve, reject) => {
            let callbacks = Action.requests.get(this.selector.id);

            callbacks.push((data, error) => {
                if(data === null) {
                    reject(error);
                }
                else {
                    resolve(data);
                }
            });
        });
    }

    post = Request.post;
    put = Request.put;
    delete = Request['delete'];
}
