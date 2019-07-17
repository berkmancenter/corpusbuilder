import React from 'react'
import { computed, observable } from 'mobx';
import { observer } from 'mobx-react'
import state from '../../stores/State'
import s from './DocumentPage.scss'
import { agnes } from 'ml-hclust';

import { DocumentLine } from '../DocumentLine'
import { FakePage } from '../FakePage'
import { SelectionManager } from '../SelectionManager'
import { HelpIcon } from '../HelpIcon';

import GraphemesUtils from '../../lib/GraphemesUtils';
import BoxesUtils from '../../lib/BoxesUtils';
import MathUtils from '../../lib/MathUtils';

@observer
export default class DocumentPage extends React.Component {

    pageRoot = null;

    @observable
    visualSelection = null;

    @observable
    cursor = 'auto';

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
        return GraphemesUtils.lines(this.graphemes);
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

    capturePageRoot(el) {
        this.pageRoot = el;
    }

    onLineClick(line, text, number, editing, options) {
        return this.props.onLineClick(line, text, number, editing, options);
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

    lineId(line) {
        if(line === undefined) {
            return undefined;
        }

        return `${line[0].id}=>${line[line.length - 1].id}`;
    }

    @computed
    get lineMedianHeights() {
        let lineId = this.lineId;

        return this.lines.reduce((acc, line) => {
            let words = GraphemesUtils.wordBoxes(line);

            acc[lineId(line)] = MathUtils.median(
                words.map(BoxesUtils.height)
                     .map(Math.abs)
            );

            return acc;
        }, {});
    }

    @computed
    get clusters() {
        let lineId = this.lineId;
        let heights = this.lineMedianHeights;

        let distance = function(left, right) {
            return Math.abs(heights[lineId(left)] - heights[lineId(right)]);
        };

        // let's split clusters if their height deviates by more than 2 standard deviations:
        let inClusterIndices = agnes(this.lines, { distanceFunction: distance })
            .cut(2 * MathUtils.std(Object.values(this.lineMedianHeights)))
            .map(c => c.indices());

        let clusterIndices = inClusterIndices.reduce(function(acc, ixs, ix) {
            ixs.forEach(i => acc[i] = ix); return acc;
        }, {});

        let clusters = inClusterIndices.map(ixs => {
            let lines = this.lines.filter((_, ix) => ixs.includes(ix));

            // add 10% to accomodate the fact that the lines are usually cutting the type
            // aggressively at the top and bottom:
            return {
                fontSize: MathUtils.median(
                    lines.map(line => heights[lineId(line)])
                ) * this.ratio * 1.1
            }
        });

        return this.lines.map((_, ix) => clusters[clusterIndices[ix]]);
    }

    enforcedFontSize(line, index) {
        if(this.props.fontUniformityMode) {
            return this.clusters[index].fontSize;
        }

        return null;
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
            this.cursor = 'crosshair';
        }
        else {
            this.cursor = 'auto';
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
            cursor: this.cursor,
            height: Math.floor(this.surfaceHeight * this.ratio)
        };

        if(this.props.showImage) {
            pageStyle.backgroundImage = `url(${ this.surface.image_url })`;
        }

        if(this.ruler === null) {
            setTimeout(() => {
                this.forceUpdate();
            }, 0);
        }

        let certaintyMapHelp = !this.showCertainties ? null :
            <div className="corpusbuilder-document-page-help">
                <HelpIcon message="Red means less certainty and green means more. <br /> Hover over the lines to see the assigned certainty values by the OCR backend. <br /> Note that the values do not meant the probability of the word <br />being correct or erroneous." />
            </div>;

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
                    certaintyMapHelp
                }
                {
                  this.ruler === null ? [] : this.lines.map(
                      (line, index) => {
                          return <DocumentLine key={ `document-line-${index}` }
                                               line={ line }
                                               number={ index + 1 }
                                               enforcedFontSize={ this.enforcedFontSize(line, index) }
                                               ratio={ this.ratio }
                                               editing={ this.props.editing }
                                               showCertainties={ this.showCertainties }
                                               onClick={ this.onLineClick.bind(this) }
                                               />
                      }
                  )
                }
              </SelectionManager>
              { this.renderVisualSelection() }
          </div>
            </div>
        );
    }
}
