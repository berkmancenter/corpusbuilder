import React from 'react'
import { observer } from 'mobx-react'
import state from '../../stores/State'
import s from './DocumentPage.scss'

@observer
export default class DocumentPage extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            document: props.document
        };
    }

    percentageToHsl(percentage, hue0, hue1) {
        var hue = (percentage * (hue1 - hue0)) + hue0;
        return 'hsla(' + hue + ', 100%, 50%, .5)';
    }

    graphemeNodes(grapheme, previous, ratio) {
        let graphemeHeight = grapheme.area.lry - grapheme.area.uly;
        let graphemeWidth = grapheme.area.lrx - grapheme.area.ulx;

        let boxHeight = graphemeHeight * ratio;
        let boxWidth = graphemeWidth * ratio;
        let boxLeft = grapheme.area.ulx * ratio;
        let boxTop = grapheme.area.uly * ratio;

        let graphemeStyles = {
          left: boxLeft,
          top: boxTop,
          fontSize: `${boxHeight}px`,
          height: boxHeight,
          width: boxWidth
        };

        if(this.props.showCertainties) {
          graphemeStyles.backgroundColor = this.percentageToHsl(grapheme.certainty, 0, 120);
        }

        let spaces = [];

        if(previous !== undefined && previous !== null) {
            if(grapheme.area.uly == previous.area.uly) {
                let distance = grapheme.area.ulx - previous.area.lrx;

                if(distance > graphemeWidth * 0.5) {
                    for(let spaceIndex = 0; spaceIndex * boxWidth < distance / graphemeWidth; spaceIndex++) {
                        let spaceStyle = {
                            left: (previous.area.ulx + boxWidth * spaceIndex) * ratio,
                            top: (grapheme.area.uly * ratio),
                            fontSize: boxHeight
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
        let surfaceWidth = surface.area.lrx - surface.area.ulx;
        let surfaceHeight = surface.area.lry - surface.area.uly;
        let ratio = this.props.width / surfaceWidth;

        let pageStyle = {
            backgroundImage: `url(${ surface.image_url })`,
            width: this.props.width,
            height: surfaceHeight * ratio
        };

        return (
          <div className="corpusbuilder-document-page" style={ pageStyle }>
              {
                surface.graphemes.map((grapheme, index) => {
                    return this.graphemeNodes(grapheme, surface.graphemes[ index - 1 ], ratio)
                })
              }
          </div>
        );
    }
}
