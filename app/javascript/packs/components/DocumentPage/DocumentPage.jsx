import React from 'react'
import { computed, observable } from 'mobx';
import { observer } from 'mobx-react'
import state from '../../stores/State'
import s from './DocumentPage.scss'

import PagePositioningHelper from '../../lib/PagePositioningHelper'
import { DocumentLine } from '../DocumentLine'
import { SelectionManager } from '../SelectionManager'
import MathUtils from '../../lib/MathUtils'

@observer
export default class DocumentPage extends React.Component {

    rulerCache = new Map();

    // using @computed ensures that the values are cached and not re-computed
    // even though they are not mobx related

    @computed
    get document() {
        return this.props.document;
    }

    @computed
    get width() {
        return this.props.width;
    }

    @computed
    get documentMaxHeight() {
        return this.props.documentMaxHeight;
    }

    @computed
    get page() {
        return this.props.page;
    }

    @computed
    get surface() {
        return this.document.surfaces.find(
            (surface) => {
                return surface.number == this.page;
            }
        );
    }

    @computed
    get graphemes() {
        // todo: remove the following:
        if(this.surface === null || this.surface === undefined) {
            return [];
        }
        return this.surface.graphemes;
    }

    @computed
    get lines() {
        let initialState = {
            result: [ [] ],
            lineYSum: 0,
            lineHeightSum: 0,
            currentColumn: 1,
            currentRow: 1
        };

        let lines = this.graphemes.reduce((state, grapheme) => {
            let runningYAvg = state.lineYSum / ( state.currentColumn - 1 );
            let runningHeightAvg = state.lineHeightSum / ( state.currentColumn - 1 );

            if(grapheme.area.uly - runningYAvg > 0.8 * runningHeightAvg) {
                state.result.push([]);
                state.lineYSum = 0;
                state.lineHeightSum = 0;
                state.currentColumn = 1;
                state.currentRow += 1;
            }

            state.result[ state.currentRow - 1 ].push(grapheme);

            state.currentColumn++;
            state.lineYSum += grapheme.area.uly;
            state.lineHeightSum += grapheme.area.lry - grapheme.area.uly;

            return state;
        }, initialState).result;

        return lines.reduce((state, line) => {
            let heights = line.map((grapheme) => {
                return grapheme.area.lry - grapheme.area.uly;
            });

            let stdHeight = MathUtils.std(heights);
            let meanHeight = MathUtils.mean(heights);

            let sublines = line.reduce((substate, grapheme) => {
                let localDiffFromMean = Math.abs(grapheme.area.lry - grapheme.area.uly - meanHeight);
                let localLevel = localDiffFromMean / stdHeight;

                // if the levels differ by more than 2 standard deviations then we split:
                if(substate.lastLevel !== null && Math.abs(substate.lastLevel - localLevel) > 2) {
                    substate.result.push([]);
                }

                substate.result[ substate.result.length - 1 ].push( grapheme );
                substate.lastLevel = localLevel;

                return substate;
            }, { result: [ [] ], lastLevel: null }).result;

            for(let subline of sublines) {
               state.push(subline);
            }

            return state;
        }, []);
    }

    @computed
    get surfaceWidth() {
        if(this.surface === null || this.surface === undefined) {
            return this.document.global.right_max - this.document.global.left_min;
        }
        else {
            return this.surface.area.lrx - this.surface.area.ulx;
        }
    }

    @computed
    get surfaceHeight() {
        if(this.surface === null || this.surface === undefined) {
            return this.document.global.bottom_max - this.document.global.top_min;
        }
        else {
            return this.surface.area.lry - this.surface.area.uly;
        }
    }

    @computed
    get ratio() {
        return this.width / this.surfaceWidth;
    }

    @computed
    get showCertainties() {
        return this.props.showCertainties;
    }

    get rulerId() {
        return `corpusbuilder-page-ruler-${this.document.global.id}`;
    }

    get ruler() {
        return document.getElementById(this.rulerId);
    }

    percentageToHsl(percentage, hue0, hue1) {
        var hue = (percentage * (hue1 - hue0)) + hue0;
        return 'hsla(' + hue + ', 100%, 50%, .5)';
    }

    onMeasureTextRequested(text, fontSize) {
        if(window._count === undefined) {
            window._count = 1;
        }
        else {
            window._count += 1;
        }

        if(text === " ") {
            if(this.rulerCache.has(Math.round(fontSize))) {
                return this.rulerCache.get(Math.round(fontSize));
            }
        }

        this.ruler.textContent = text;
        this.ruler.style.fontSize = fontSize + "px";

        let result = this.ruler.offsetWidth;

        return result;
    }

    onSelected(graphemes) {
       console.log(`Selected ${graphemes.length} graphemes`);

       if(this.props.onSelected !== undefined && this.props.onSelected !== null) {
           this.props.onSelected(graphemes);
       }
    }

    onDeselected() {
        console.log("OnDeselected!");
    }

    render() {
        let page1Style = {
            width: this.width,
            height: this.documentMaxHeight,
            backgroundSize: 'cover',
            transform: `rotate(${Math.random() * (2 - -2) + -2}deg)`
        };

        let page2Style = {
            width: this.width,
            top: this.props.mainPageTop,
            height: Math.floor(this.surfaceHeight * this.ratio),
            transform: `rotate(${Math.random() * (3 - -3) + -3}deg)`
        };

        let pageStyle = {
            width: this.width,
            top: this.props.mainPageTop,
            height: Math.floor(this.surfaceHeight * this.ratio)
        };

        if(this.props.showImage) {
            page1Style.backgroundImage = `url(${ this.surface.image_url })`;
            page2Style.backgroundImage = `url(${ this.surface.image_url })`;
            pageStyle.backgroundImage = `url(${ this.surface.image_url })`;
        }

        if(this.ruler === null) {
            setTimeout(() => {
                this.forceUpdate();
            }, 0);
        }

        return (
          <div>
            <div className={ 'corpusbuilder-document-page simple' }
                 style={ page1Style }
              >
              &nbsp;
            </div>
            <div className={ 'corpusbuilder-document-page simple' }
                 style={ page2Style }
              >
              &nbsp;
            </div>
            <div className={ `corpusbuilder-document-page ${ this.props.showImage ? '' : 'simple' }` }
                 style={ pageStyle }
                 >
              <SelectionManager graphemes={ this.graphemes }
                                onSelected={ this.onSelected.bind(this) }
                                onDeselected={ this.onDeselected.bind(this) }
                                >
                {
                  this.ruler === null ? [] : this.lines.map(
                      (line, index) => {
                          return <DocumentLine key={ `document-line-${index}` }
                                               line={ line }
                                               number={ index + 1 }
                                               ratio={ this.ratio }
                                               onMeasureTextRequested={ this.onMeasureTextRequested.bind(this) }
                                               />
                      }
                  )
                }
              </SelectionManager>
              <div id={ this.rulerId } className={ 'corpusbuilder-document-page-ruler' }>&nbsp;</div>
            </div>
          </div>
        );
    }
}
