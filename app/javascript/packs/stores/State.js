import { observable, action } from 'mobx';

export default class State {
    cache = observable.map();
    eventHandlers = {};
    baseUrl = "";

    constructor(baseUrl) {
        this.baseUrl = baseUrl;
    }

    invalidate(selector) {
        this.cache.keys().filter((k) => {
            return selector.belongsToString(k);
        }).forEach((key) => {
            this.cache.delete(key);
        });
    }

    on(name, callback) {
        let list = this.eventHandlers[ name ];

        if(list === undefined) {
            list = [ callback ];
        }
        else {
            list.push( callback );
        }

        this.eventHandlers[ name ] = list;
    }

    broadcastEvent(selector, value, subname = null) {
        let eventName = subname === null ? selector.tag : `${selector.tag}:${subname}`;
        let list = this.eventHandlers[ eventName ];

        if(list !== undefined) {
            for(let handler of list) {
                handler(selector.select, value);
            }
        }
    }

    promise(selector, callback) {
        return new Promise((resolve, reject) => {
            let resource = selector.cacheable ? this.cache.get(selector.id) : undefined;

            if(resource === undefined && callback !== undefined) {
                let value = callback();

                if(typeof value.then === 'function') {
                    value.then(
                        action(
                            (data) => {
                                if(selector.cacheable) {
                                    this.cache.set(selector.id, data);
                                }
                                resolve(data)
                            }
                        )
                    )
                    .catch((err) => {
                        reject(err);
                    });
                }
                else {
                    action(() => {
                        if(selector.cacheable) {
                            this.cache.set(selector.id, value);
                        }
                        resolve(value);
                    })();
                }
            }
        });
    };

    resolve(selector, callback) {
        let resource = selector.cacheable ? this.cache.get(selector.id) : undefined;

        if(resource === undefined && callback !== undefined) {
            let value = callback();

            if(typeof value.then === 'function') {
                value.then(
                    action(
                        (data) => {
                            if(selector.cacheable) {
                                this.cache.set(selector.id, data);
                            }
                        }
                    )
                );
            }
            else {
                action(() => {
                    resource = value;
                    if(selector.cacheable) {
                        this.cache.set(selector.id, value);
                    }
                })();
            }
        }

        return resource;
    }
}
