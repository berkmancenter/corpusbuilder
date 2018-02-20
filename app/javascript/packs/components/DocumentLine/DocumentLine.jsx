import React from 'react'
import { computed, observable } from 'mobx'
import { observer } from 'mobx-react'
import GraphemesUtils from '../../lib/GraphemesUtils';
import MathUtils from '../../lib/MathUtils';
import styles from './DocumentLine.scss'

@observer
export default class DocumentLine extends React.Component {

    _spaceWidth = null;
    _measurer = null;
    _mounted = false;

    componentDidMount() {
        this._mounted = true;
    }

    componentWillUnmount() {
        this._mounted = false;
    }

    get text() {
        let state = {
            result: "",
            lastGrapheme: null
        };

        return this.props.line.reduce((state, g, index) => {
            let spaces = this.spacesBetween(state.lastGrapheme, g, index);

            state.result = `${state.result}${spaces}${g.value}`;
            state.lastGrapheme = g;

            return state;
        }, state).result;
    }

    spacesBetween(previous, current, index) {
        if(previous === null || current === null) {
            return '';
        }

        let previousWord = this.wordIndex.get(previous);
        let currentWord  = this.wordIndex.get(current);

        if(previousWord === currentWord) {
            return '';
        }
        else {
            return ''.padStart(this.spacesNumBetween(previousWord, currentWord));
        }
    }

    spacesNumBetween(word1, word2) {
        if(this.spaceWidth === null || word1 === undefined || word2 === undefined) {
            return 1;
        }

        let box1 = GraphemesUtils.wordToBox(word1);
        let box2 = GraphemesUtils.wordToBox(word2);

        let absolutePixelDiff = box1.ulx < box2.ulx ? (box2.ulx - box1.lrx) : (box1.ulx - box2.lrx);
        let gap = absolutePixelDiff * this.props.ratio;

        return Math.max(
            Math.ceil(( gap + this.letterSpacingByWord ) / ( this.spaceWidth + this.letterSpacingByWord )),
            1
        );
    }

    @computed
    get showCertainties() {
        return this.props.showCertainties;
    }

    @computed
    get fontSize() {
        return this.props.line
          .map((g) => { return g.area.lry - g.area.uly })
          .reduce((sum, height) => { return sum + height }, 0) * this.props.ratio / this.props.line.length;
    }

    @computed
    get specialCodePoints() {
        return [ 0x202c, 0x200e, 0x200f ];
    }

    @computed
    get concreteGraphemes() {
        return this.props.line.filter((grapheme) => {
            let codePoint = grapheme.value.codePointAt(0);

            return  this.specialCodePoints.indexOf(codePoint) === -1;
        });
    }

    @computed
    get left() {
        return this.concreteGraphemes
            .reduce((min, g) => { return Math.min(min, g.area.ulx) }, 1e+22) * this.props.ratio;
    }

    @computed
    get top() {
        return this.concreteGraphemes
            .reduce((min, g) => { return Math.min(min, g.area.uly) }, 1e+22) * this.props.ratio;
    }

    @computed
    get leftmostGrapheme() {
        let result = null;

        for(let element of this.props.line) {
            if(result === null || element.area.ulx < result.area.ulx) {
                result = element;
            }
        }

        return result;
    }

    @computed
    get rightmostGrapheme() {
        let result = null;

        for(let element of this.props.line) {
            if(result === null || element.area.lrx > result.area.lrx) {
                result = element;
            }
        }

        return result;
    }

    @computed
    get hasWords() {
        return this.words.length > 0;
    }

    @computed
    get visualLine() {
        return this.props.line.slice(0).sort((g1, g2) => {
            return g1.area.ulx - g2.area.ulx;
        });
    }

    @computed
    get words() {
        let results = [];
        let lastUlx = null;
        let lastLrx = null;
        let currentWordIndex = -1;

        for(let grapheme of this.visualLine) {
            let codePoint = grapheme.value.codePointAt(0);

            if([ 0x200e, 0x200f, 0x202c ].indexOf(codePoint) === -1) {
                let graphemeWidth = grapheme.area.lrx - grapheme.area.ulx;

                if(lastUlx === null || lastLrx === null || grapheme.area.ulx > lastLrx) {
                    results.push([ grapheme ]);
                    currentWordIndex++;
                }
                else {
                    results[ currentWordIndex ].push(grapheme);
                }

                lastUlx = grapheme.area.ulx;
                lastLrx = grapheme.area.lrx;
            }
        }

        return results;
    }

    @computed
    get wordIndex() {
        return this.words.reduce((index, word) => {
            for(let grapheme of word) {
                index.set(grapheme, word);
            }

            return index;
        }, new Map());
    }

    @computed
    get firstWord() {
        if(!this.hasWords) {
            return null;
        }

        let index = 0;
        let word = undefined;
        let graphemes = this.props.line;

        while(index < graphemes.length && word === undefined) {
            word = this.wordIndex.get(graphemes[index]);
            index++;
        }

        return word;
    }

    @computed
    get ratio() {
        return this.props.ratio;
    }

    percentageToHsl(percentage, hue0 = 0, hue1 = 120) {
        var hue = (percentage * (hue1 - hue0)) + hue0;
        return 'hsla(' + hue + ', 100%, 50%, .35)';
    }

    boundsFor(graphemes) {
        let minUlx = graphemes.reduce((min, g) => { return Math.min(min, g.area.ulx) }, graphemes[0].area.ulx);
        let maxLrx = graphemes.reduce((max, g) => { return Math.max(max, g.area.lrx) }, graphemes[0].area.lrx);
        let meanTop = MathUtils.mean(graphemes.map((g) => { return g.area.uly }));
        let meanBottom = MathUtils.mean(graphemes.map((g) => { return g.area.lry }));

        return {
            top: meanTop * this.ratio,
            bottom: meanBottom * this.ratio,
            left: minUlx * this.ratio,
            right: maxLrx * this.ratio
        }
    }

    @computed
    get lineBounds() {
        return this.boundsFor(this.concreteGraphemes);
    }

    @computed
    get certaintiesMapDataURL() {
        let canvas = document.createElement('canvas');
        let context = canvas.getContext('2d');

        context.canvas.width = 415;
        context.canvas.height = 20;

        for(let word of this.words) {
            let certainty = parseFloat(word[0].certainty);
            let color = this.percentageToHsl(certainty);
            let bounds = this.boundsFor(word);

            context.fillStyle = color;
            context.fillRect(
                bounds.left - this.lineBounds.left,
                0,
                bounds.right - bounds.left,
                this.lineBounds.bottom - this.lineBounds.top
            );
        }

        return canvas.toDataURL();
    }

    @computed
    get firstWordText() {
        if(!this.hasWords) {
            return null;
        }
        else {
            return GraphemesUtils.wordText(this.firstWord);
        }
    }

    get letterSpacingByWord() {
        if(this.hasWords) {
            let measuredWidth = this.measureText(this.firstWordText);
            let box = GraphemesUtils.wordToBox(this.firstWord);
            let countChars = this.firstWord.length;
            let unscaledWidth = box.lrx - box.ulx;
            let scaledWidth = unscaledWidth * this.props.ratio;

            return ( scaledWidth - measuredWidth ) / ( countChars - ( this.firstWord.length > 1 ? 1 : 0) );
        }
        return null;
    }

    get spaceWidth() {
        if(this._spaceWidth === null) {
            this._spaceWidth = this.measureText(' ');
        }

        return this._spaceWidth;
    }

    get letterSpacing() {
       if(this.hasWords) {
           let measuredWidth = this.measureText(this.text);
           let countChars = this.text.length;
           let box = GraphemesUtils.lineToBox(this.props.line);
           let unscaledWidth = box.lrx - box.ulx;
           let scaledWidth = unscaledWidth * this.props.ratio;

           let result = ( scaledWidth - measuredWidth ) / ( countChars - 1 );

           return isNaN(result) ? null : result;
       }

       return null;
    }

    measureText(text) {
        return this.props.onMeasureTextRequested(text, this.fontSize);
    }

    onClick() {
        return this.props.onClick(this.props.line, this.text, this.props.number, this.props.editing);
    }

    @computed
    get elementId() {
        return `corpusbuilder-document-line-${this.props.number}`;
    }

    render() {
        this._spaceWidth = null;

        let dynamicStyles = {
            fontSize: this.fontSize,
            height: this.fontSize,
            top: this.top,
            left: this.left,
            letterSpacing: this.letterSpacing
        };

        if(this.showCertainties) {
            dynamicStyles.backgroundImage = `url(${ this.certaintiesMapDataURL })`;
        }

        return (
            <div className={ `corpusbuilder-document-line ${ this.props.editing ? 'corpusbuilder-document-line-editing' : '' }` }
                 key={ this.text }
                 style={ dynamicStyles }
                 id={ this.elementId }
                 onClick={ this.onClick.bind(this) }
                 >
               { this.text }
            </div>
        );
    }
}
