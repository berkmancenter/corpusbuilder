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

    words(pageNumber, currentGraphemes, otherGraphemes, currentVersion, otherVersion) {
        if(this.isEmpty) {
            return [ ];
        }

        // the idea is to match the current words with the items
        // from this diff, and do the same with the words comming
        // from the other version.
        //
        // next, we will need to merge the ones that overlap
        // visually
        //
        // the added words are the ones having only the graphemes
        // with parent_ids empty
        //
        // the removed are the ones having no diff grapheme in the
        // list of current diff graphemes
        //
        // modified is the rest

        let currentWords = GraphemeUtils.words(currentGraphemes);
        let otherWords = GraphemeUtils.words(otherGraphemes);
        let diffGraphemes = this.pages[pageNumber - 1].graphemes;

        let currentMap = new Map();
        let otherMap = new Map();

        for(let grapheme of diffGraphemes) {
            if(grapheme.inclusion === 'left') {
                currentMap.set(grapheme.id, grapheme);
            }
            else {
                otherMap.set(grapheme.id, grapheme);
            }
        }

        let findWords = (givenWords, givenMap) => {
            let foundWords = [ ];

            for(let word of givenWords) {
                let diffWord = null;

                for(let grapheme of word) {
                    let matched = givenMap.get(grapheme.id);

                    if(matched !== undefined) {
                        if(diffWord === null) {
                            diffWord = new WordDiff(currentVersion, otherVersion, word);
                        }

                        diffWord.addDiffGrapheme(matched);
                        givenMap.delete(grapheme.id);
                    }
                }

                if(diffWord !== null) {
                    foundWords.push(diffWord);
                }
            }

            return foundWords;
        };

        return WordDiff.groupOverlapping(
            findWords(currentWords, currentMap),
            findWords(otherWords, otherMap)
        ).map((wordGroup) => {
            return WordDiff.merge(wordGroup);
        });
    }

    static empty() {
        return new Diff([]);
    }

    constructor(rawDiff) {
        this.rawDiff = rawDiff;
    }
}
