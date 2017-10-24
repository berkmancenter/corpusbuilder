import React from 'react'
import { computed, observable } from 'mobx';
import { observer } from 'mobx-react'
import state from '../../stores/State'
import s from './DocumentPage.scss'

import PagePositioningHelper from '../../lib/PagePositioningHelper'
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
        if(this.props.onSelected !== undefined && this.props.onSelected !== null) {
            this.props.onSelected(
                // iterating forward through the ghraphemes as an optimization
                // around the property of the selection being contiguous:
                this.graphemes.reduce((state, grapheme) => {
                    if(state.sawLast) {
                        return state;
                    }

                    if(!state.sawFirst && grapheme.id === nodes[0].getAttribute('data-id')) {
                        state.sawFirst = true;
                    }

                    if(!state.sawLast && grapheme.id === nodes[nodes.length - 1].getAttribute('data-id')) {
                        state.sawLast = true;
                    }

                    if(state.sawFirst) {
                        state.result.push(grapheme);
                    }

                    return state;
                }, { result: [], sawFirst: false, sawLast: false }).result
            );
        }
    }

    onDeselected() {
        console.log("OnDeselected!");
    }

    graphemeNodes(grapheme, previous) {
        let graphemeStyles = PagePositioningHelper.graphemePositioning(grapheme, this.ratio);

        if(this.showCertainties) {
            graphemeStyles.backgroundColor = this.percentageToHsl(grapheme.certainty, 0, 120);
        }

        let spaces = PagePositioningHelper.spacePositionsBetween(grapheme, previous, this.ratio)
            .map((spacePosition) => {
                return (
                    <span className="corpusbuilder-grapheme"
                          key={ `space-${ grapheme.id }-${ spacePosition.left }-${ spacePosition.top }` }
                          style={ spacePosition }
                          >
                        { grapheme.area.uly == previous.area.uly ? ' ' : <br /> }
                    </span>
                );
            });

        let element = (
            <span className="corpusbuilder-grapheme"
                  key={ grapheme.id }
                  style={ graphemeStyles }
                  data-id={ grapheme.id }
                  >
                { grapheme.value }
            </span>
        )

        if(spaces.length > 0) {
            return (
                <span key={ `grapheme-spaces-${ grapheme.id }` }>
                  { spaces }
                  { element }
                </span>
            );
        }
        else {
            return element;
        }
    }

    render() {
        let pageStyle = {
            backgroundImage: `url(${ this.surface.image_url })`,
            width: this.width,
            height: this.surfaceHeight * this.ratio
        };

        return (
          <div>
            <div className="corpusbuilder-document-page" style={ pageStyle }>
              <SelectionManager selector="corpusbuilder-grapheme"
                                onSelected={ this.onSelected.bind(this) }
                                onDeselected={ this.onDeselected.bind(this) }
                                >
                {
                  this.graphemes.map(
                      (grapheme, index) => {
                          return this.graphemeNodes(grapheme, this.surface.graphemes[ index - 1 ])
                      }
                  )
                }
              </SelectionManager>
            </div>
          </div>
        );
    }
}
