import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react';
import PagePositioningHelper from '../../lib/PagePositioningHelper';
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

        let lines = this.props.graphemes.reduce((state, grapheme) => {
            let position = PagePositioningHelper.graphemePositioning(grapheme, this.ratio);

            if(state.currentLine.top !== null && state.currentLine.top != position.top) {
                state.result.push(state.currentLine);
                state.currentLine = { left: null, top: null, right: null, bottom: null };
            }

            if(state.currentLine.left === null) {
                state.currentLine.left = position.left;
                state.currentLine.right = position.left + position.width;
                state.currentLine.top = position.top;
                state.currentLine.bottom = position.top + position.height;
            }
            else {
                state.currentLine.right = position.left + position.width;
            }

            return state
        }, { result: [], currentLine: { left: null, top: null, right: null, bottom: null } });

        if(lines.currentLine.top !== null) {
            lines.result.push(lines.currentLine);
        }

        lines = lines.result.map((lineCoords) => {
            let lineStyles = {
                top: lineCoords.top,
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
