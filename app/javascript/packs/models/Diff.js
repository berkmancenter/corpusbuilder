import { computed } from 'mobx';
import GraphemeUtils from '../lib/GraphemesUtils';
import WordDiff from './WordDiff';

class Page {
    get surfaceNumber() {
        return this.graphemes[0].surface_number;
    }

    constructor(graphemes) {
        this.graphemes = graphemes;
    }
}

export default class Diff {
    get pageCount() {
        return this._pagesAffected.length;
    }

    get pagesAffected() {
        return this._pagesAffected || [];
    }

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
        let diffGraphemes = this.rawDiff;

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

        let wordDiffs = WordDiff.groupOverlapping(
            findWords(currentWords, currentMap),
            findWords(otherWords, otherMap)
        ).map((wordGroup) => {
            return WordDiff.merge(wordGroup);
        });

        let lines = wordDiffs.reduce(
            (state, diff) => {
                if(state[diff.graphemes[0].zone_id] === undefined) {
                    state[diff.graphemes[0].zone_id] = []
                }
                state[diff.graphemes[0].zone_id].push(diff)
                return state
            }, {}
        );

        let seenIds = new Set();
        let result = [ ];

        for(let line of Object.values(lines)) {
            for(let diff of line) {
                if(!seenIds.has(diff.graphemes[0].id)) {
                    result.push(diff);
                    seenIds.add(diff.graphemes[0].id);
                }
            }
        }

        return result;
    }

    static empty() {
        return new Diff([]);
    }

    constructor(rawDiff, pagesAffected) {
        this.rawDiff = rawDiff;
        this._pagesAffected = pagesAffected;
    }
}
