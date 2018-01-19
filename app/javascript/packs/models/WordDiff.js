import { computed } from 'mobx';
import GraphemeUtils from '../lib/GraphemesUtils';

export default class WordDiff {
    @computed
    get status() {
        if(this.hasAfterDiff) {
            if(this.hasBeforeDiff) {
                return "modified";
            }

            return "added";
        }
        else {
            return "deleted";
        }
    }

    @computed
    get allStatuses() {
        if(this.inConflict) {
            return [ this.status, "conflict" ];
        }

        return [ this.status ];
    }

    @computed
    get inConflict() {
        for(let grapheme of this.graphemes) {
            if(grapheme.status === "conflict") {
                return true;
            }
        }

        return false;
    }

    @computed
    get beforeGraphemes() {
        return (this.hasAfterDiff ? this.word2 : this.word1).sort((a, b) => {
            if(a.position_weight < b.position_weight) {
                return -1;
            }
            else if(a.position_weight > b.position_weight) {
                return 1;
            }
            else {
                return 0;
            }
          });
    }

    @computed
    get beforeText() {
       return this.beforeGraphemes.map((g) => {
           return g.value;
       }).join('');
    }

    @computed
    get afterGraphemes() {
        return this.word1.sort((a, b) => {
                if(a.position_weight < b.position_weight) {
                    return -1;
                }
                else if(a.position_weight > b.position_weight) {
                    return 1;
                }
                else {
                    return 0;
                }
            })
    }

    @computed
    get afterText() {
        return this.afterGraphemes.map((g) => { return g.value }).join('');
    }

    @computed
    get area() {
        return GraphemeUtils.wordToBox(this.graphemes);
    }

    @computed
    get hasAfterDiff() {
        return this.diffGraphemes.find((diffGrapheme) => {
            return diffGrapheme.inclusion === "left";
        }) !== undefined;
    }

    @computed
    get hasBeforeDiff() {
        return this.diffGraphemes.find((diffGrapheme) => {
            return diffGrapheme.inclusion === "right";
        }) !== undefined;
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

    @computed
    get graphemes() {
        return this.word1;
    }

    @computed
    get otherGraphemes() {
        return this.wasDeleted ? this.word1 : this.word2;
    }

    addDiffGrapheme(diffGrapheme) {
        this.diffGraphemes.push(diffGrapheme);
    }

    /*
     * Groups the words that have any overlaps in terms of the
     * area they take. Returns array of array with items being
     * arrays of 1 or 2 words.
     */
    static groupOverlapping(words1, words2) {
        let set1 = new Set(words1);
        let set2 = new Set(words2);

        let results = [ ];

        for(let word1 of set1) {
            for(let word2 of set2) {
                if(GraphemeUtils.boxesOverlap(word1.area, word2.area)) {
                    results.push(
                        [ word1, word2 ]
                    );
                    set1.delete(word1);
                    set2.delete(word2);
                }
            }
        }

        return results
            .concat(Array.from(set1).map((s) => { return [ s ] }))
            .concat(Array.from(set2).map((s) => { return [ s ] }));
    }

    static merge(diffWords) {
        if(diffWords.length === 0) {
            throw "Cannot merge zero length list of diff words";
        }
        else if(diffWords.length < 2) {
            return diffWords[0];
        }
        else {
            let words = diffWords.sort((a, b) => { return a.hasAfterDiff ? -1 : 0 })
                                 .map( (a   ) => { return a.graphemes });
            let result = new WordDiff(diffWords[0].afterVersion, diffWords[0].beforeVersion, words[0], words[1]);

            let diffGraphemes = diffWords.reduce((state, diffWord) => {
                return state.concat( diffWord.diffGraphemes );
            }, [ ]);

            for(let diffGrapheme of diffGraphemes) {
                result.addDiffGrapheme( diffGrapheme );
            }

            return result;
        }
    }

    constructor(afterVersion, beforeVersion, word1, word2 = undefined) {
        if(word1 === undefined || word1 === null) {
            throw "Null or undefined word given to diff";
        }

        this.afterVersion = afterVersion;
        this.beforeVersion = beforeVersion;
        this.word1 = word1;
        this.word2 = word2;
        this.diffGraphemes = [ ];
    }
}
