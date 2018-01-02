import { computed } from 'mobx';

class Page {
    @computed
    get surfaceNumber() {
        return this.graphemes[0].surface_number;
    }

    constructor(graphemes) {
        this.graphemes = graphemes;
    }
}

export default class Diff {
    @computed
    get pages() {
        let initialState = {
            result: [ ],
            lastPage: null
        };

        return this.rawDiff.reduce((state, grapheme) => {
            if(state.lastPage !== grapheme.surface_number) {
                state.result.push([]);
            }

            state.result[ state.result.length - 1 ].push(grapheme)
            state.lastPage = grapheme.surface_number;

            return state;
        }, initialState).result.map((graphemes) => {
            return new Page(graphemes);
        });
    }

    @computed
    get isEmpty() {
        return this.rawDiff.length === 0;
    }

    static empty() {
        return new Diff([]);
    }

    constructor(rawDiff) {
        this.rawDiff = rawDiff;
    }
}
