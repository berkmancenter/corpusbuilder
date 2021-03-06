import { memoized } from './Decorators';

export default class Selector {
    select = {};
    tag = "";

    constructor(tag, select) {
        this.select = select || {};
        this.tag = tag;
        this._id = Math.round(Math.random() * 10e10).toString();

        for(let key of Object.keys(select || {})) {
            if(key !== "id") {
                this[key] = select[key];
            }
        }

        this._cacheable = this.id !== this._id;
    }

    set cacheable(val) {
        this._cacheable = val;
    }

    get cacheable() {
        return this._cacheable;
    }

    get id() {
        if(Object.keys(this.select).length === 0 && !this.cacheable) {
            return this._id;
        }
        else {
            return this.toString();
        }
    }

    toString() {
        return JSON.stringify({
            tag: this.tag,
            select: this.toSimple(this.select)
        });
    }

    static fromString(string) {
        let object = JSON.parse(string);

        return new Selector(object.tag, object.select);
    }

    belongsToString(string) {
        return this.belongsTo(
            Selector.fromString(string)
        );
    }

    belongsTo(otherSelector) {
        return this.tag === otherSelector.tag &&
            Selector.simpleBelongsTo(this.select, otherSelector.select);
    }

    static simpleBelongsTo(thisSelector, otherSelector) {
        let keys = Object.keys(thisSelector);

        for(let key of keys) {
            let thisItem = thisSelector[key];
            let otherItem = otherSelector[key];

            if(otherItem !== undefined && thisItem !== undefined) {
                if(typeof thisItem === 'object') {
                    if(typeof otherItem !== 'object') {
                        return false;
                    }

                    let thisId = thisItem.identity || thisItem.id;
                    let otherId = otherItem.identity || otherItem.id;

                    if(thisId !== undefined && otherId !== undefined) {
                        if(thisId !== otherId) {
                            return false;
                        }
                    }
                    else if(thisId === undefined && otherId !== undefined) {
                        return false;
                    }
                    else if(thisId === undefined && otherId === undefined) {
                        if(!Selector.simpleBelongsTo(thisItem, otherItem)) {
                            return false;
                        }
                    }
                }
                else {
                    if(typeof otherItem !== typeof thisItem) {
                        return false;
                    }
                    else {
                        if(thisItem !== otherItem) {
                            return false;
                        }
                    }
                }
            }
            else if(otherItem === undefined && thisItem !== undefined) {
                return false;
            }
        }

        return true;
    }

    toSimple(object) {
        return Object.keys(object).sort().reduce((state, key) => {
            let item = object[key];

            if(typeof item !== 'object') {
                state[key] = item;
            }
            else {
                if(item === null) {
                    state[ key ] = null;
                }
                else {
                    let id = item.identifier || item.id;

                    if(id !== undefined && id !== null) {
                        state[key] = { id: id };
                    }
                    else {
                        state[key] = this.toSimple(item);
                    }
                }
            }

            return state;
        }, {});
    }
}
