import { computed } from 'mobx';

export default class Selector {
    select = {};
    tag = "";

    constructor(tag, select) {
        this.select = select;
        this.tag = tag;

        for(let key of Object.keys(select)) {
            if(key !== "id") {
                this[key] = select[key];
            }
        }
    }

    @computed
    get id() {
        return `${this.tag}:${this.objectId(this.select)}`;
    }

    objectId(object) {
        return Object.keys(object).sort().map((key) => {
            let item = object[key];

            if(typeof item !== 'object') {
                return `${key}=${item}`;
            }
            else {
                if(item === null) {
                    throw "Found null in selector!";
                }

                let id = item.identifier || item.id;

                if(id !== undefined && id !== null) {
                    return id;
                }

                return `{${this.objectId(item)}}`;
            }
        }).join('+');
    }
}
