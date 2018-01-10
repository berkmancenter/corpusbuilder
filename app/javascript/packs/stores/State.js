import { observable, action } from 'mobx';

export default class State {
    cache = observable.map();
    baseUrl = "";

    constructor(baseUrl) {
        this.baseUrl = baseUrl;
    }

    invalidate(selector) {
        this.cache.keys().filter((k) => {
            return k.indexOf(selector.id) !== -1;
        }).forEach((key) => {
            this.cache.delete(key);
        });
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
                    resource = value;
                    this.cache.set(selector.id, value);
                })();
            }
        }

        return resource;
    }
}
