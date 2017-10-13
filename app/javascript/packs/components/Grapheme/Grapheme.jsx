import React from 'react'
import s from './Grapheme.scss'

export default class Grapheme extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            grapheme: props.grapheme,
            previous: props.previous
        };
    }

    render() {
        let grapheme = this.state.grapheme;
        let previous = this.state.previous;
        let graphemeHeight = grapheme.area.lry - grapheme.area.uly;

        let graphemeStyles = {
          left: grapheme.area.ulx,
          top: grapheme.area.uly,
          fontSize: graphemeHeight
        };

        let spaces = [];

        if(previous !== undefined && previous !== null) {
            if(grapheme.area.uly == previous.area.uly) {
                let distance = grapheme.area.ulx - previous.area.lrx;
                let graphemeWidth = grapheme.area.lrx - grapheme.area.ulx;

                if(distance > graphemeWidth * 0.5) {
                    for(let spaceIndex = 0; spaceIndex < distance / graphemeWidth; spaceIndex++) {
                        let spaceStyle = {
                            left: previous.area.lrx + spaceIndex * graphemeWidth,
                            top: grapheme.area.uly,
                            fontSize: graphemeHeight
                        };
                        let spaceKey = `${ grapheme.id }-after-space-${ spaceIndex }`;
                        spaces.push(
                            <span className="corpusbuilder-grapheme" key={ spaceKey } style={ spaceStyle }>
                                &nbsp;
                            </span>
                        );
                    }
                }
            }
            else {
                let spaceKey = `${ grapheme.id }-crlf`;
                spaces.push(
                  <span className="corpusbuilder-grapheme" key={ spaceKey }>
                      <br />
                  </span>
                );
            }
        }

        let element = (
            <span className="corpusbuilder-grapheme" style={ graphemeStyles }>
                { grapheme.value }
            </span>
        )

        if(spaces.length > 0) {
            return (
                <span>
                  { spaces }
                  { element }
                </span>
            );
        }
        else {
            return element;
        }
    }
}
