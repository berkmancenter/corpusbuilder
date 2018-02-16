import React from 'react'
import { computed, observable } from 'mobx';
import { observer } from 'mobx-react'
import state from '../../stores/State'
import s from './DocumentPage.scss'

import { DocumentLine } from '../DocumentLine'
import { FakePage } from '../FakePage'
import { SelectionManager } from '../SelectionManager'
import MathUtils from '../../lib/MathUtils'

@observer
export default class DocumentPage extends React.Component {

    rulerCache = new Map();
    pageRoot = null;

    // using @computed ensures that the values are cached and not re-computed
    // even though they are not mobx related

    @observable
    visualSelection = null;

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
            state.result[ state.result.length - 1 ].push( grapheme );

            // if we're seeing the pop-directionality grapheme then
            // it's a mark of the end of line:
            if(grapheme.value.charCodeAt(0) === 0x202c) {
                state.result.push( [ ] );
            }

            return state;
        }, initialState).result;
       return lines;
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

    capturePageRoot(el) {
        this.pageRoot = el;
    }

    onLineClick(line, text, number, editing) {
        return this.props.onLineClick(line, text, number, editing);
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

    @computed
    get page1Rotate() {
        return this.graphemes && Math.random() * (2 - -2) + -2;
    }

    @computed
    get page2Rotate() {
        return this.graphemes && Math.random() * (3 - -3) + -3;
    }

    draw(y) {
        if(this.visualSelection === null) {
            this.visualSelection = observable({ top: y, height: 1 });
        }
        else {
            if(y < this.visualSelection.top) {
                this.visualSelection.top = y;
            }
            else {
                this.visualSelection.height = y - this.visualSelection.top;
            }
        }

        if ( document.selection ) {
            document.selection.empty();
        } else if ( window.getSelection ) {
            window.getSelection().removeAllRanges();
        }
    }

    endDraw() {
        if(this.visualSelection !== null) {
            if(typeof this.props.onLineDrew === 'function') {
                this.props.onLineDrew(
                    this.visualSelection.top,
                    this.visualSelection.height,
                    this.ratio
                );
            }
        }

        this.visualSelection = null;
    }

    onPageMouseUp() {
        this.endDraw();
    }

    onPageMouseMove(event) {
        if(!this.props.editing) {
            return;
        }

        if(event.ctrlKey || event.metaKey) {
            event.target.style.cursor = 'crosshair';
        }
        else {
            event.target.style.cursor = 'auto';
        }

        if(event.buttons === 1 && (event.ctrlKey || event.metaKey)) {
            let rect = this.pageRoot.getBoundingClientRect();
            let y = event.clientY - rect.y;

            this.draw(y);
        }
        else {
            if(this.newBox !== null) {
                this.endDraw();
            }
        }
    }

    renderVisualSelection() {
        if(this.visualSelection !== null) {
            let style = {
                top: this.visualSelection.top,
                height: this.visualSelection.height
            };

            return (
                <div className="corpusbuilder-document-page-visual-selection" style={ style } />
            );
        }

        return null;
    }

    render() {
        if(!this.props.visible) {
            return null;
        }

        let page1Style = {
            width: this.width,
            height: this.documentMaxHeight,
            backgroundSize: 'cover',
            transform: `rotate(${this.page1Rotate}deg)`
        };

        let surfHeight = Math.floor(this.surfaceHeight * this.ratio);

        let page2Style = {
            width: this.width,
            top: this.props.mainPageTop / 2,
            height: this.documentMaxHeight - ((this.documentMaxHeight - surfHeight) / 2),
            transform: `rotate(${this.page2Rotate}deg)`
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
            <FakePage style={ page1Style }>
              &nbsp;
            </FakePage>
            <FakePage style={ page2Style }>
              &nbsp;
            </FakePage>
            <div className={ `corpusbuilder-document-page ${ this.props.showImage ? '' : 'simple' }` }
                 style={ pageStyle }
                 ref={ this.capturePageRoot.bind(this) }
                 onMouseMove={ this.onPageMouseMove.bind(this) }
                 onMouseUp={ this.onPageMouseUp.bind(this) }
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
                                               editing={ this.props.editing }
                                               showCertainties={ this.showCertainties }
                                               onClick={ this.onLineClick.bind(this) }
                                               onMeasureTextRequested={ this.onMeasureTextRequested.bind(this) }
                                               />
                      }
                  )
                }
              </SelectionManager>
              { this.renderVisualSelection() }
              <div id={ this.rulerId } className={ 'corpusbuilder-document-page-ruler' }>&nbsp;</div>
            </div>
          </div>
        );
    }
}
