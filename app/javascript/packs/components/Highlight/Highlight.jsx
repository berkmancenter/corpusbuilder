import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react';
import PagePositioningHelper from '../../lib/PagePositioningHelper';
import MathUtils from '../../lib/MathUtils';
import s from './Highlight.scss'

@observer
export default class Highlight extends React.Component {

    @computed
    get surface() {
        return this.props.document.surfaces.find(
            (surface) => {
                return surface.number == this.props.page;
            }
        );
    }

    @computed
    get lines() {
        let initialState = {
            result: [ [] ],
        };

        let lines = this.props.graphemes.reduce((state, grapheme) => {
            state.result[ state.result.length - 1 ].push( grapheme );

            if(grapheme.value.charCodeAt(0) === 0x202c) {
                state.result.push( [ ] );
            }

            return state;
        }, initialState).result;
       return lines;
    }

    @computed
    get lineCoords() {
        let special = [ 0x202c, 0x200e, 0x200f ];

        return this.lines.map((graphemes) => {
            let concrete = graphemes.filter((grapheme) => {
                return special.indexOf(grapheme.value.codePointAt(0)) === -1;
            });

            let minUlx = graphemes.reduce((min, grapheme) => {
                return Math.min(min, grapheme.area.ulx);
            }, graphemes[0].area.ulx);

            let maxLrx = graphemes.reduce((max, grapheme) => {
                return Math.max(max, grapheme.area.lrx);
            }, graphemes[0].area.lrx);

            let meanTop = MathUtils.mean(
                graphemes.map((g) => { return g.area.uly })
            );

            let meanBottom = MathUtils.mean(
                graphemes.map((g) => { return g.area.lry })
            );

            return {
                top: meanTop * this.ratio,
                left: minUlx * this.ratio,
                right: maxLrx * this.ratio,
                bottom: meanBottom * this.ratio
            }
        });
    }

    @computed
    get surfaceWidth() {
        return this.surface.area.lrx - this.surface.area.ulx;
    }

    @computed
    get ratio() {
        return this.props.width / this.surfaceWidth;
    }

    render() {
        if(this.props.graphemes === null || this.props.graphemes === undefined ||
           this.props.graphemes.length === 0) {
            return null;
        }

        let lines = this.lineCoords.map((lineCoords) => {
            let lineStyles = {
                top: lineCoords.top + this.props.mainPageTop,
                left: lineCoords.left,
                height: lineCoords.bottom - lineCoords.top,
                width: lineCoords.right - lineCoords.left
            };

            return (
                <div className="corpusbuilder-highlight-line"
                      style={ lineStyles }
                      key={ `highlight-line-${ lineStyles.left }-${ lineStyles.top }` }
                      >
                  &nbsp;
                </div>
            );
        });

        return (
            <div className="corpusbuilder-highlight" title={ this.props.content }>
              { lines }
            </div>
        );
    }
}
