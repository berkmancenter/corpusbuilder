import React from 'react'
import { computed, observable } from 'mobx';
import { observer } from 'mobx-react'
import state from '../../stores/State'
import s from './DocumentPage.scss'

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

    editAnnotation() {
        this.showMenu = false;
        this.showAnnotationEditor = true;
    }

    editTags() {
        this.showMenu = false;
    }

    onSelected(nodes) {
        console.log("OnSelected! ", nodes);
    }

    onDeselected() {
        console.log("OnDeselected!");
    }

    graphemeNodes(grapheme, previous) {
        let graphemeHeight = grapheme.area.lry - grapheme.area.uly;
        let graphemeWidth = grapheme.area.lrx - grapheme.area.ulx;

        let boxHeight = graphemeHeight * this.ratio;
        let boxWidth = graphemeWidth * this.ratio;
        let boxLeft = grapheme.area.ulx * this.ratio;
        let boxTop = grapheme.area.uly * this.ratio;

        let graphemeStyles = {
            left: boxLeft,
            top: boxTop,
            fontSize: `${boxHeight}px`,
            height: boxHeight,
            width: boxWidth
        };

        if(this.showCertainties) {
            graphemeStyles.backgroundColor = this.percentageToHsl(grapheme.certainty, 0, 120);
        }

        let spaces = [];

        if(previous !== undefined && previous !== null) {
            if(grapheme.area.uly == previous.area.uly) {
                let distance = grapheme.area.ulx - previous.area.lrx;

                if(distance > graphemeWidth * 0.5) {
                    for(let spaceIndex = 0; spaceIndex * boxWidth < distance / graphemeWidth; spaceIndex++) {
                        let spaceStyle = {
                            left: (previous.area.ulx + boxWidth * spaceIndex) * this.ratio,
                            top: (grapheme.area.uly * this.ratio),
                            fontSize: boxHeight
                        };
                        let spaceKey = `${ grapheme.id }-after-space-${ spaceIndex }`;
                        spaces.push(
                            <span className="corpusbuilder-grapheme"
                                  key={ `space-${ grapheme.id }-${ spaceIndex }` }
                                  style={ spaceStyle }
                                  >
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

        let menu;
        if(this.showMenu) {
            let menuStyles = {
                position: 'absolute',
                top: this.lastMouseY - 50,
                left: this.lastMouseX,
                padding: '10px',
                color: 'black',
                backgroundColor: 'white',
                boxShadow: '0px 1px 1px rgba(0, 0, 0, 0.5)',
                borderRadius: 4
            };
            let menuItemStyle = {
                backgroundColor: 'rgba(255, 255, 255, 0.4)',
                boxShadow: '0px 1px 1px rgba(0, 0, 0, 0.5)',
                color: 'black',
                borderRadius: 2
            };
            menu = (
              <div style={ menuStyles }>
                <button style={ menuItemStyle } onClick={ () => this.editAnnotation() }>
                  { '✐' }
                </button>
                <button style={ menuItemStyle } onClick={ () => this.editTags() }>
                  { '#' }
                </button>
              </div>
            );
        }

        let annotationEditor;
        if(this.showAnnotationEditor) {
            let annotationEditorStyle = {
                position: 'absolute',
                top: this.lastMouseY - 200,
                left: 10,
                right: 10,
                padding: '10px',
                color: 'black',
                backgroundColor: 'white',
                boxShadow: '0px 1px 1px rgba(0, 0, 0, 0.5)',
                borderRadius: 4
            };
            let buttonStyle = {
                backgroundColor: 'rgba(255, 255, 255, 0.4)',
                boxShadow: '0px 1px 1px rgba(0, 0, 0, 0.5)',
                color: 'black',
                width: 'auto',
                height: 'auto',
                padding: '10px',
                borderRadius: 2
            };
            let editorStyle = {
              border: 'none',
              width: '100%',
              display: 'block',
              fontSize: '13px',
              marginTop: 10,
              marginBottom: 10,
              borderRadius: 2,
              backgroundColor: 'rgba(0,0,0,0.1)',
              color: 'black'
            };
            annotationEditor = (
                <div className="corpusbuilder-document-page-annotate-editor" style={ annotationEditorStyle }>
                    <span>Annotate fragment:</span>
                    <textarea onChange={ this.onAnnotationChanged.bind(this) } value={ this.editedAnnotation } rows="4" style={ editorStyle }></textarea>
                    <button onClick={ this.onAnnotateEditorCancel.bind(this) } style={ buttonStyle }>Cancel</button>
                    <button onClick={ this.onAnnotateEditorSave.bind(this) } style={ buttonStyle }>Save</button>
                </div>
            );
        }

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
