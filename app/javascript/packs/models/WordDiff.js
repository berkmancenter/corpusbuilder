import { computed } from 'mobx';
import GraphemeUtils from '../lib/GraphemesUtils';

export default class WordDiff {
    get status() {
        return this._status;
    }

    set status(value) {
        if(WordDiff.statuses.indexOf(value) === -1) {
            throw `Unknown word diff status: ${ value }. Please provide one of: ${ WordDiff.statuses.join(', ') }`;
        }

        this._status = value;
    }

    get wasAdded() {
        return this.status === "added";
    }

    get wasDeleted() {
        return this.status === "deleted";
    }

    get wasModified() {
        return this.status === "modified";
    }

    @computed
    get text() {
        return this.graphemes.map((g) => { return g.value }).join('');
    }

    static get statuses() {
        return [
            "added",
            "modified",
            "deleted"
        ];
    }

    constructor(status, graphemes, afterVersion, beforeVersion) {
        this.status = status;
        this.graphemes = graphemes;
        this.afterVersion = afterVersion;
        this.beforeVersion = beforeVersion;
    }
}
