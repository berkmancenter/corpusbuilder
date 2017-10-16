import React from 'react'
import { inject, observer } from 'mobx-react'
import state from '../../stores/State'
import s from './DocumentPage.scss'

@inject('state')
@observer
export default class DocumentPage extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            document: props.document
        };
    }

    graphemeNodes(grapheme, previous) {
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
                            <span className="corpusbuilder-grapheme" key={ `space-${ grapheme.id }-${ spaceIndex }` }
                                  style={ spaceStyle }>
                                &nbsp;
                            </span>
                        );
                    }
                }
            }
            else {
                let spaceKey = `${ grapheme.id }-crlf`;
                spaces.push(
                  <span className="corpusbuilder-grapheme" key={ `crlf-${ grapheme.id }` }>
                      <br />
                  </span>
                );
            }
        }

        let element = (
            <span className="corpusbuilder-grapheme" key={ grapheme.id } style={ graphemeStyles }>
                { grapheme.value }
            </span>
        )

        if(spaces.length > 0) {
            return (
                <span key={ Math.random() }>
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
        let doc = this.state.document;
        let surface = this.props.document.surfaces.find((surface) => {
            return surface.number == this.props.page;
        });

        let pageStyle = {
            backgroundImage: `url(${ surface.image_url })`,
            width: (surface.area.lrx - surface.area.ulx),
            height: (surface.area.lry - surface.area.uly)
        };

        return (
          <div className="corpusbuilder-document-page" style={ pageStyle }>
              {
                surface.graphemes.map((grapheme, index) => {
                    return this.graphemeNodes(grapheme, surface.graphemes[ index - 1 ])
                })
              }
          </div>
        );
    }
}
