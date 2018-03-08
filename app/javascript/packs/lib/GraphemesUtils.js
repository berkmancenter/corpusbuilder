import BoxesUtils from './BoxesUtils';

export default class GraphemesUtils {
    static wordBoxes(graphemes) {
        if(graphemes === undefined || graphemes === null) {
            return [ ];
        }

        return this.words(graphemes)
                   .map(this.wordToBox);
    }

    static lines(graphemes) {
        let bag = graphemes.reduce((state, grapheme) => {
            let key = parseFloat(grapheme.zone_position_weight);

            if(state[ key ] === undefined) {
                state[ key ] = [ ];
            }
            state[ key ].push(grapheme);

            return state;
        }, {});

        let keys = Object.keys(bag).sort((a, b) => { return a - b; });

        return keys.reduce((result, key) => {
            let graphemes = bag[ key ].sort((a, b) => {
                return parseFloat(a.position_weight) - parseFloat(b.position_weight);
            });

            result.push(graphemes);

            return result;
        }, []);
    }

    static boxesOverlap = BoxesUtils.boxesOverlap;

    static wordToBox(word) {
        if(word.length === 0) {
            throw "Cannot compute the bounding box of an empty set. Zero graphemes have been given.";
        }

        let minUlx = word[0].area.ulx;
        let minUly = word[0].area.uly;
        let maxLrx = word[0].area.lrx;
        let maxLry = word[0].area.lry;

        for(let grapheme of word) {
            minUlx = Math.min(minUlx, grapheme.area.ulx);
            minUly = Math.min(minUly, grapheme.area.uly);
            maxLrx = Math.max(maxLrx, grapheme.area.lrx);
            maxLry = Math.max(maxLry, grapheme.area.lry);
        }

        return {
            ulx: minUlx,
            uly: minUly,
            lrx: maxLrx,
            lry: maxLry,
            graphemes: word
        }
    }

    static lineToBox(line) { return GraphemesUtils.wordToBox(line); }

    static words(graphemes) {
        return this.lines(graphemes).reduce((result, line) => {
            return result.concat(
                this.lineWords(line)
            );
        }, [ ]);
    }

    static lineWords(graphemes) {
        if(graphemes === undefined || graphemes === null) {
            return [ ];
        }

        let results = [];
        let lastUlx = null;
        let lastLrx = null;

        for(let grapheme of this.asReadingOrder(graphemes.filter(this.isRegular.bind(this)))) {
            if(!this.isSpecial(grapheme)) {
                let graphemeWidth = grapheme.area.lrx - grapheme.area.ulx;

                if(lastUlx === null || lastLrx === null || grapheme.area.ulx > lastLrx) {
                    results.push([ grapheme ]);
                }
                else {
                    results[ results.length - 1 ].push(grapheme);
                }

                lastUlx = grapheme.area.ulx;
                lastLrx = grapheme.area.lrx;
            }
            else {
                results.push([]);
            }
        }

        return results.filter(
            (word) => {
                return word.length > 0 && !this.isSpecial(word[0]);
            }
        );
    }

    static wordText(graphemes) {
        return graphemes.sort(
            (a, b) => {
                return a.position_weight - b.position_weight;
            }
        ).map(
            (g) => {
                return g.value;
            }
        ).join('')
    }

    static lineText(line, spaces = 2) {
        let words = GraphemesUtils.lineWords(line);
        let wordsIndex = words.reduce((index, word) => {
            for(let grapheme of word) {
                index.set(grapheme, word);
            }

            return index;
        }, new Map());

        let state = {
            result: "",
            lastGrapheme: null
        };

        let spacesBetween = (previous, current, index) => {
            if(previous === null || current === null) {
                return '';
            }

            let previousWord = wordsIndex.get(previous);
            let currentWord  = wordsIndex.get(current);

            if(previousWord === currentWord) {
                return '';
            }
            else {
                return ''.padStart(spaces);
            }
        }

        return line.reduce((state, g, index) => {
            let spaces = spacesBetween(state.lastGrapheme, g, index);

            state.result = `${state.result}${spaces}${g.value}`;
            state.lastGrapheme = g;

            return state;
        }, state).result;
    }

    static areRelated(grapheme1, grapheme2) {
        let ids1 = grapheme1.parent_ids.concat([ grapheme1.id ]);
        let ids2 = grapheme2.parent_ids.concat([ grapheme2.id ]);

        return ids1.find((id) => { return ids2.includes(id) }) !== undefined;
    }

    static asReadingOrder(graphemes) {
        return graphemes.slice(0).sort((g1, g2) => {
            return g1.area.ulx - g2.area.ulx;
        });
    }

    static asLogicalOrder(graphemes) {
        return graphemes.sort((g1, g2) => {
            return g1.position_weight - g2.position_weight;
        })
    }

    static isRegular(grapheme) {
        return !this.isSpecial(grapheme);
    }

    static isSpecial(grapheme) {
        return this.isCharSpecial(grapheme.value);
    }

    static isCharSpecial(value) {
        return this.specialCodePoints.indexOf(value.codePointAt(0)) !== -1;
    }

    static get specialCodePoints() {
        return [
            this.rtlMark,
            this.ltrMark,
            this.popDirectionalityMark
        ];
    }

    static get rtlMark() {
        return 0x200f;
    }

    static get ltrMark() {
        return 0x200e;
    }

    static get popDirectionalityMark() {
        return 0x202c;
    }
}
