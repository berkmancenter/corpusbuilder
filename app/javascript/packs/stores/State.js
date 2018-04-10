import { observable, action } from 'mobx';

export default class State {
    cache = observable.map();
    eventHandlers = {};
    baseUrl = "";
    cacheFor = 120*1000; // 2 minutes

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
        let eventNames = Object.keys(this.eventHandlers).filter((name) => {
            return eventName.match(name) !== null;
        });
        let list = eventNames.reduce((state, name) => {
            for(let handler of this.eventHandlers[ name ]) {
                state.push(handler)
            }

            return state;
        }, []);

        if(list !== undefined) {
            for(let handler of list) {
                handler(selector.select, value, eventName);
            }
        }
    }

    promise(selector, callback) {
        return new Promise((resolve, reject) => {
            let resource = selector.cacheable && !this.expired(selector.id) ? this.cache.get(selector.id) : undefined;

            if(resource === undefined && callback !== undefined) {
                let value = callback();

                if(typeof value.then === 'function') {
                    value.then(
                        action(
                            (data) => {
                                if(selector.cacheable) {
                                    this.set(selector.id, data);
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
                            this.set(selector.id, value);
                        }
                        resolve(value);
                    })();
                }
            }
        });
    };

    cacheStampId(id) {
        return `{"timestamp":${id}}`;
    }

    expired(id) {
        let cacheId = this.cacheStampId(id);

        if(!this.cache.has(cacheId)) {
            return false;
        }
        else {
            let ms = this.cache.get(cacheId);

            return this.cacheFor < (this.now() - ms);
        }
    }

    set(id, data) {
        let cacheId = this.cacheStampId(id);
        this.cache.set(id, data);
        this.cache.set(cacheId, this.now());
    }

    now() {
        return (+ new Date());
    }

    resolve(selector, callback) {
        let resource = selector.cacheable && !this.expired(selector.id) ? this.cache.get(selector.id) : undefined;

        if(resource === undefined && callback !== undefined) {
            let value = callback();

            if(typeof value.then === 'function') {
                value.then(
                    action(
                        (data) => {
                            if(selector.cacheable) {
                                this.set(selector.id, data);
                            }
                        }
                    )
                );
            }
            else {
                action(() => {
                    resource = value;
                    if(selector.cacheable) {
                        this.set(selector.id, resource);
                    }
                })();
            }
        }

        return resource;
    }
}
