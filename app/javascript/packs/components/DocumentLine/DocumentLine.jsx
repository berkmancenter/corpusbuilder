import React from 'react'
import { computed, observable } from 'mobx'
import { inject, observer } from 'mobx-react'
import { flatten } from 'lodash';

import GraphemesUtils from '../../lib/GraphemesUtils';
import MathUtils from '../../lib/MathUtils';
import BoxesUtils from '../../lib/BoxesUtils';

import { memoized } from '../../lib/Decorators';
import styles from './DocumentLine.scss'

@inject('measureText')
@inject('measureFontSize')
@inject('inferFont')
@observer
export default class DocumentLine extends React.Component {

    _spaceWidth = null;
    _mounted = false;

    componentDidMount() {
        this._mounted = true;
    }

    componentWillUnmount() {
        this._mounted = false;
    }

    @observable
    hovered = false;

    get text() {
        let state = {
            result: "",
            lastGrapheme: null
        };

        return this.props.line.reduce((state, g, index) => {
            let spaces = ' ';

            state.result = `${state.result}${spaces}${g.value}`;
            state.lastGrapheme = g;

            return state;
        }, state).result;
    }

    @computed
    get showCertainties() {
        return this.props.showCertainties;
    }

    @computed
    get font() {
        return this.props.inferFont(this.props.line);
    }

    @computed
    get fontFamily() {
        return this.font.ready ? this.font.familyName : 'sans-serif';
    }

    @computed
    get fontSize() {
        return this.props.enforcedFontSize ||
            this.props.measureFontSize(this.props.line, this.font, this.ratio);
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
    get top() {
        return this.concreteGraphemes
            .reduce((min, g) => { return Math.min(min, g.area.uly) }, 1e+22) * this.props.ratio;
    }

    @computed
    get hasWords() {
        return this.words.length > 0;
    }

    @computed
    get lineBox() {
        if(this.props.line === undefined || this.props.line === null) {
            return BoxesUtils.empty();
        }

        return GraphemesUtils.lineToBox(this.props.line);
    }

    @computed
    get lineLeft() {
        return this.lineBox.ulx;
    }

    @computed
    get lineWidth() {
        return this.lineBox.lrx - this.lineBox.ulx;
    }

    @computed
    get words() {
        return GraphemesUtils.lineWords(this.props.line)
            .sort((word1, word2) => {
                let maxPos1 = Math.max(...word1.map((g) => { return parseFloat(g.position_weight) } ));
                let maxPos2 = Math.max(...word2.map((g) => { return parseFloat(g.position_weight) } ));

                return maxPos1 - maxPos2;
            });
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

    get spaceWidth() {
        if(this._spaceWidth === null) {
            this._spaceWidth = this.measureText(' ');
        }

        return this._spaceWidth;
    }

    measureText(text) {
        return this.props.measureText(text, this.fontSize, this.font);
    }

    onClick() {
        if(typeof this.props.onClick === 'function') {
            return this.props.onClick(
                this.props.line,
                this.text,
                this.props.number,
                this.props.editing,
                {
                    fontSize: this.fontSize,
                    ratio: this.ration,
                    letterSpacing: this.letterSpacing
                }
            );
        }
    }

    onWordMouseEnter() {
        this.hovered = true;
    }

    onWordMouseLeave() {
        this.hovered = false;
    }

    @computed
    get elementId() {
        return `corpusbuilder-document-line-${this.props.number}`;
    }

    @computed
    get className() {
        let classes = [ 'corpusbuilder-document-line' ];

        if(this.props.editing) {
            classes.push('corpusbuilder-document-line-editing');
        }

        if(this.hovered && this.props.editing) {
            classes.push('corpusbuilder-document-line-editing-hover');
        }

        return classes.join(' ');
    }

    @computed
    get dir() {
        if(this.props.line === undefined || this.props.line === null || this.props.line.length === 0) {
            return "ltr";
        }

        return this.props.line[0].zone_direction === 1 ? "rtl" : "ltr";
    }

    wordRender(word, ix, last) {
        let text = GraphemesUtils.wordText(word);
        let box = GraphemesUtils.wordToBox(word);
        let boxWidth = (box.lrx - box.ulx) * this.ratio;
        let textWidth = this.measureText(text, this.fontSize);
        let scale = textWidth > 0 ? boxWidth / textWidth : 1;

        let styles = {
            fontSize: this.fontSize,
            fontFamily: this.fontFamily,
            opacity: this.font.applied ? 1 : 0,
            width: textWidth,
            transform: `scaleX(${ scale })`,
            left: (box.ulx - this.lineLeft) * this.ratio
        };

        if(this.showCertainties) {
            styles.backgroundColor = this.percentageToHsl(word[0].certainty);
        }

        let result = [];

        if(last !== null) {
            let textWidth = this.measureText(' ', this.fontSize);
            let boxWidth = (box.ulx < last.box.ulx ? box.lrx - last.box.ulx : box.ulx - last.box.lrx) * this.ratio;
            let scale = textWidth > 0 ? boxWidth / textWidth : 1;
            let left = 0;

            if(box.ulx < last.box.ulx) {
                left = ((box.lrx - boxWidth / this.ratio) - this.lineLeft) * this.ratio;
            }
            else {
                left = (last.box.lrx - this.lineLeft) * this.ratio;
            }

            let spaceStyles = {
                fontSize: this.fontSize,
                fontFamily: this.fontFamily,
                width: this.measureText(' ', this.fontSize),
                transform: `scaleX(${ scale })`,
                left: left
            };

            result.push(
                <span style={ spaceStyles }
                      className="corpusbuilder-document-line-word"
                      key={ `${ix-1}-${ix}` }
                      >
                    &nbsp;
                </span>
            );
        }

        result.push(
            <span style={ styles }
                  className="corpusbuilder-document-line-word"
                  data-tip={ this.showCertainties ? `Certainty assigned by the algorithm: <br />${parseFloat(word[0].certainty).toFixed(2)}%` : undefined }
                  key={ ix }
                  >
                { text }
            </span>
        );

        return {
            ui: result,
            box: box
        };
    }

    render() {
        this._spaceWidth = null;

        let dynamicStyles = {
            height: this.fontSize,
            top: this.top,
            left: this.lineLeft * this.ratio,
            width: this.lineWidth * this.ratio
        };

        return (
            <div className={ this.className }
                 dir={ this.dir }
                 key={ this.text }
                 style={ dynamicStyles }
                 id={ this.elementId }
                 onClick={ this.onClick.bind(this) }
                 onMouseEnter={ this.onWordMouseEnter.bind(this) }
                 onMouseLeave={ this.onWordMouseLeave.bind(this) }
                 >
               {
                   flatten(
                       this.words.reduce((acc, word, ix) => {
                           let render = this.wordRender(word, ix, acc.last);

                           acc.result.push(render.ui);
                           acc.last = render;

                           return acc;
                       }, { result: [], last: null }).result
                   )
               }
            </div>
        );
    }
}
