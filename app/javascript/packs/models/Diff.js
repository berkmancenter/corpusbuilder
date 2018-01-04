import { computed } from 'mobx';
import GraphemeUtils from '../lib/GraphemesUtils';
import WordDiff from './WordDiff';

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

    words(pageNumber, graphemes, currentVersion, otherVersion) {
        if(this.isEmpty) {
            return [ ];
        }

        let currentWords = GraphemeUtils.words(graphemes);
        let currentMap = new Map();
        let otherMap = new Map();
        let wordDiffs = [ ];

        for(let grapheme of this.pages[pageNumber - 1].graphemes) {
            if(grapheme.inclusion === 'left') {
                currentMap.set(grapheme.id, grapheme);
            }
            else {
                otherMap.set(grapheme.id, grapheme);
            }
        }

        for(let word of currentWords) {
            let mode = null;
            let countMatched = 0;

            for(let grapheme of word) {
                let matched = currentMap.get(grapheme.id);

                if(matched !== undefined) {
                    countMatched++;

                    if(matched.parent_ids.length !== 0) {
                        mode = "modified";
                        break;
                    }
                    else {
                        if(mode === null) {
                            mode = "added";
                        }
                    }
                }
            }

            if(countMatched !== word.length && mode === "added") {
                mode = "modified";
            }

            if(mode !== null) {
                wordDiffs.push(new WordDiff(mode, word, currentVersion, otherVersion));
            }
        }

        for(let otherGrapheme of otherMap.values()) {
            for(let currentGrapheme of currentMap.values()) {
                if(GraphemeUtils.areRelated(otherGrapheme, currentGrapheme)) {
                    currentMap.delete(currentGrapheme.id);
                    otherMap.delete(otherGrapheme.id);
                }
            }
        }

        return wordDiffs.concat(
            GraphemeUtils.words(
                Array.from(
                    otherMap.values()
                )
            ).map((word) => {
                return new WordDiff("deleted", word, currentVersion, otherVersion);
            })
        );
    }

    static empty() {
        return new Diff([]);
    }

    constructor(rawDiff) {
        this.rawDiff = rawDiff;
    }
}
