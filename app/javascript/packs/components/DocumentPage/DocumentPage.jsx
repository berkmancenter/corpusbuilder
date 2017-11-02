import React from 'react'
import { computed, observable } from 'mobx';
import { observer } from 'mobx-react'
import state from '../../stores/State'
import s from './DocumentPage.scss'

import PagePositioningHelper from '../../lib/PagePositioningHelper'
import { DocumentLine } from '../DocumentLine'
import { SelectionManager } from '../SelectionManager'

@observer
export default class DocumentPage extends React.Component {

    // rendering all graphemes here as spans instead of using a sperate
    // component here to speed the rendering up as we have lots of graphemes
    // to render

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

        return this.graphemes.reduce((state, grapheme) => {
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
        }, initialState).result
    }

    @computed
    get surfaceWidth() {
        return this.surface.area.lrx - this.surface.area.ulx;
    }

    @computed
    get surfaceHeight() {
        return this.surface.area.lry - this.surface.area.uly;
    }

    @computed
    get ratio() {
        return this.width / this.surfaceWidth;
    }

    @computed
    get showCertainties() {
        return this.props.showCertainties;
    }

    percentageToHsl(percentage, hue0, hue1) {
        var hue = (percentage * (hue1 - hue0)) + hue0;
        return 'hsla(' + hue + ', 100%, 50%, .5)';
    }

    onSelected(nodes) {
       //if(this.props.onSelected !== undefined && this.props.onSelected !== null) {
       //    this.props.onSelected(
       //        // iterating forward through the ghraphemes as an optimization
       //        // around the property of the selection being contiguous:
       //        this.graphemes.reduce((state, grapheme) => {
       //            if(state.sawLast) {
       //                return state;
       //            }

       //            if(!state.sawFirst && grapheme.id === nodes[0].getAttribute('data-id')) {
       //                state.sawFirst = true;
       //            }

       //            if(!state.sawLast && grapheme.id === nodes[nodes.length - 1].getAttribute('data-id')) {
       //                state.sawLast = true;
       //            }

       //            if(state.sawFirst) {
       //                state.result.push(grapheme);
       //            }

       //            return state;
       //        }, { result: [], sawFirst: false, sawLast: false }).result
       //    );
       //}
    }

    onDeselected() {
        console.log("OnDeselected!");
    }

   //graphemeNodes(grapheme, previous) {
   //    let graphemeStyles = PagePositioningHelper.graphemePositioning(grapheme, this.ratio);

   //    if(this.showCertainties) {
   //        graphemeStyles.backgroundColor = this.percentageToHsl(grapheme.certainty, 0, 120);
   //    }

   //    let spaces = PagePositioningHelper.spacePositionsBetween(grapheme, previous, this.ratio)
   //        .map((spacePosition) => {
   //            return (
   //                <span className="corpusbuilder-grapheme"
   //                      key={ `space-${ grapheme.id }-${ spacePosition.left }-${ spacePosition.top }` }
   //                      style={ spacePosition }
   //                      >
   //                    { grapheme.area.uly == previous.area.uly ? ' ' : <br /> }
   //                </span>
   //            );
   //        });

   //    let element = (
   //        <span className="corpusbuilder-grapheme"
   //              key={ grapheme.id }
   //              style={ graphemeStyles }
   //              data-id={ grapheme.id }
   //              >
   //            { grapheme.value }
   //        </span>
   //    )

   //    if(spaces.length > 0) {
   //        return (
   //            <span key={ `grapheme-spaces-${ grapheme.id }` }>
   //              { spaces }
   //              { element }
   //            </span>
   //        );
   //    }
   //    else {
   //        return element;
   //    }
   //}

    render() {
        let pageStyle = {
            width: this.width,
            height: this.surfaceHeight * this.ratio
        };

        if(this.props.showImage) {
            pageStyle.backgroundImage = `url(${ this.surface.image_url })`;
        }

        return (
          <div>
            <div className={ `corpusbuilder-document-page ${ this.props.showImage ? '' : 'simple' }` }
                 style={ pageStyle }
                 >
              <SelectionManager selector="corpusbuilder-grapheme"
                                onSelected={ this.onSelected.bind(this) }
                                onDeselected={ this.onDeselected.bind(this) }
                                >
                {
                  this.lines.map(
                      (line, index) => {
                          return <DocumentLine key={ `document-line-${index}` }
                                               line={ line }
                                               ratio={ this.ratio }
                                               />
                      }
                  )
                }
              </SelectionManager>
            </div>
          </div>
        );
    }
}
