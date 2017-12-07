export default class GraphemesUtils {
    static wordBoxes(graphemes) {
        return this.words(graphemes)
                   .map(this.wordToBox);
    }

    static wordToBox(word) {
        if(word.length === 0) {
            throw "Cannot compute the bounding box of an empty word. Zero graphemes have been given.";
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
            lry: maxLry
        }
    }

    static words(graphemes) {
        let results = [];
        let lastUlx = null;
        let lastLrx = null;

        for(let grapheme of this.asReadingOrder(graphemes)) {
            if(!this.isSpecial(grapheme)) {
                let graphemeWidth = grapheme.area.lrx - grapheme.area.ulx;

                if(lastUlx === null || lastLrx === null || grapheme.area.ulx - lastLrx > 0.1 * graphemeWidth) {
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

    static asReadingOrder(graphemes) {
        return graphemes.slice(0).sort((g1, g2) => {
            return g1.area.ulx - g2.area.ulx;
        });
    }

    static isSpecial(grapheme) {
        return this.specialCodePoints.indexOf(grapheme.value.codePointAt(0)) !== -1;
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
