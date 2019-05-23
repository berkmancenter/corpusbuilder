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
        action.state = state;

        return action.execute(state, action.selector, options);
    }

    get(url, params) {
        if(!Action.requests.has(this.selector.id)) {
            Action.requests.set(this.selector.id, [ ]);

            this.state.broadcastEvent(this.selector, null, 'start');

            Request.get(url, params)
                .then((data) => {
                    this.state.broadcastEvent(this.selector, data);

                    Action.requests.get(this.selector.id).forEach((callback) => {
                        callback(data, null);
                    });
                })
                .catch((error) => {
                    Action.requests.get(this.selector.id).forEach((callback) => {
                        callback(null, error);
                    });
                    throw error
                })
                .finally(() => {
                    Action.requests.delete(this.selector.id);
                    this.state.broadcastEvent(this.selector, null, 'end');
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

    upload(url, params, before) {
        this.state.broadcastEvent(this.selector, null, 'start');

        return Request.upload(url, params, before)
            .then((data, response) => {
                this.state.broadcastEvent(this.selector, data);
                return data;
            })
            .catch((error) => {
                this.state.broadcastEvent(this.selector, error, 'error');
                throw error
            })
            .finally(() => {
                this.state.broadcastEvent(this.selector, null, 'end');
            });
    }

    post(url, params, before) {
        this.state.broadcastEvent(this.selector, null, 'start');

        return Request.post(url, params, before)
            .then((data, response) => {
                this.state.broadcastEvent(this.selector, data);
                return data;
            })
            .catch((error) => {
                this.state.broadcastEvent(this.selector, error, 'error');
                throw error
            })
            .finally(() => {
                this.state.broadcastEvent(this.selector, null, 'end');
            });
    }

    put(url, params) {
        this.state.broadcastEvent(this.selector, null, 'start');

        return Request.put(url, params)
            .then((data, response) => {
                this.state.broadcastEvent(this.selector, data);
                return data;
            })
            .catch((error) => {
                this.state.broadcastEvent(this.selector, error, 'error');
                throw error
            })
            .finally(() => {
                this.state.broadcastEvent(this.selector, null, 'end');
            });
    }

    delete(url, params) {
        return Request['delete'](url, params)
            .then((data) => {
                this.state.broadcastEvent(this.selector, data);
                return data;
            });
    }
}
