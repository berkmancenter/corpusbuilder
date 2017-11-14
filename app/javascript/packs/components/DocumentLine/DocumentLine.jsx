import React from 'react'
import { computed, observable } from 'mobx'
import { observer } from 'mobx-react'
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

    get div() {
        return document.getElementById(this.elementId);
    }

    // @computed
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
        if(this.spaceWidth === null) {
            return 1;
        }

        let left = word1[0].area.ulx < word2[0].area.ulx ? word1[ word1.length - 1 ] : word2[ word2.length - 1 ];
        let right = left === word1[ word1.length - 1 ] ? word2[ 0 ] : word1[ 0 ];

        let absolutePixelDiff = right.area.ulx - left.area.lrx;
        let gap = absolutePixelDiff * this.props.ratio;

        return ( gap + this.letterSpacingByWord ) / ( this.spaceWidth + this.letterSpacingByWord );
    }

    @computed
    get fontSize() {
        return this.props.line
          .map((g) => { return g.area.lry - g.area.uly })
          .reduce((sum, height) => { return sum + height }, 0) * this.props.ratio / this.props.line.length;
    }

    @computed
    get left() {
        return this.props.line
            .reduce((min, g) => { return Math.min(min, g.area.ulx) }, 1e+22) * this.props.ratio;
    }

    @computed
    get top() {
        return this.props.line
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
        return this.props.line.length > 0;
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
            let graphemeWidth = grapheme.area.lrx - grapheme.area.ulx;

            if(lastUlx === null || lastLrx === null || grapheme.area.ulx - lastLrx > 0.1 * graphemeWidth) {
                results.push([ grapheme ]);
                currentWordIndex++;
            }
            else {
                results[ currentWordIndex ].push(grapheme);
            }

            lastUlx = grapheme.area.ulx;
            lastLrx = grapheme.area.lrx;
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

        return this.wordIndex.get(this.props.line[0]);
    }

    @computed
    get firstWordText() {
        if(!this.hasWords) {
            return null;
        }
        else {
           let graphemes = [];

           for(let grapheme of this.props.line) {
               let currentWord = this.wordIndex.get(grapheme);

               if(currentWord !== this.firstWord) {
                   break;
               }

               graphemes.push(grapheme);
           }

           return graphemes.reduce((sum, g) => {
               return `${sum}${g.value}`;
           }, "");
        }
    }

    get letterSpacingByWord() {
        if(this.div !== null && this.hasWords) {
            let measuredWidth = this.measureText(this.firstWordText);
            let countChars = this.firstWord.length;
            let unscaledWidth = this.firstWord[ countChars - 1 ].area.lrx - this.firstWord[ 0 ].area.ulx;
            let scaledWidth = unscaledWidth * this.props.ratio;

            return ( scaledWidth - measuredWidth ) / ( countChars - 1 );
        }
        return null;
    }

    get spaceWidth() {
        if(this._spaceWidth === null && this.div !== null) {
            let context = document.createElement('canvas').getContext('2d');
            let styles = window.getComputedStyle(this.div);
            context.font = `${Math.round(styles.fontSize)}px ${styles.fontFamily}`;

            this._spaceWidth = context.measureText(' ').width;
        }

        return this._spaceWidth;
    }

    get letterSpacing() {
       if(this.div !== null && this.hasWords) {
           let measuredWidth = this.measureText(this.text);
           let countChars = this.text.length;
           let lastWord = this.words[ this.words.length - 1];
           let firstWord = this.words[ 0 ];
           let unscaledWidth = lastWord[ lastWord.length - 1 ].area.lrx - firstWord[ 0 ].area.ulx;
           let scaledWidth = unscaledWidth * this.props.ratio;

           let result = ( scaledWidth - measuredWidth ) / ( countChars - 1 );

           return isNaN(result) ? null : result;
       }

       return null;
    }

    measureText(text) {
        if(this._measurer === null) {
            let _div = this.div;
            let styles = window.getComputedStyle(_div);
            let measurer = document.createElement('div');

            measurer.style.position = "absolute";
            measurer.style.fontFamily = styles.fontFamily;
            measurer.style.fontSize = styles.fontSize;
            measurer.style.whiteSpace = 'pre';
            measurer.style.display = 'none';

            _div.append(measurer);
            this._measurer = measurer;
        }

        this._measurer.style.display = 'block';
        this._measurer.textContent = text;
        let result = this._measurer.offsetWidth;
        this._measurer.style.display = 'none';

        return result;
    }

    @computed
    get elementId() {
        return `corpusbuilder-document-line-${this.props.number}`;
    }

    render() {
        let dynamicStyles = {
            fontSize: this.fontSize,
            height: this.fontSize,
            top: this.top,
            left: this.left,
            letterSpacing: this.letterSpacing,
            color: (this.letterSpacing === null ? 'transparent' : null)
        };

        if(this.letterSpacing === null) {
            setTimeout((() => {
                if(this._mounted) {
                    this.forceUpdate();
                }
            }).bind(this), 0);
        }

        return (
            <div className="corpusbuilder-document-line"
                 key={ this.text }
                 style={ dynamicStyles }
                 id={ this.elementId }
                 >
               { this.text }
            </div>
        );
    }
}
