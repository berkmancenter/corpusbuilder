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

    broadcastEvent(selector, value) {
        let list = this.eventHandlers[ selector.tag ];

        if(list !== undefined) {
            for(let handler of list) {
                handler(selector.select, value);
            }
        }
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
