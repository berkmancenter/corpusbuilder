import { observable, action } from 'mobx';

export default class State {
    cache = observable.map();
    baseUrl = "";

    constructor(baseUrl) {
        this.baseUrl = baseUrl;
    }

    invalidate(selector) {
        throw "unimplemented";
    }

    resolve(selector, callback) {
        let resource = this.cache.get(selector.id);

        if(resource === undefined && callback !== undefined) {
            let value = callback();

            if(typeof value.then === 'function') {
                value.then(
                    action(
                        (data) => {
                            this.cache.set(selector.id, data);
                        }
                    )
                );
            }
            else {
                action(() => {
                    this.cache.set(selector.id, value);
                })();
            }
        }

        return resource;
    }
}
