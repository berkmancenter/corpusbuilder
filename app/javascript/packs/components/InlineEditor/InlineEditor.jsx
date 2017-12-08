import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { FloatingWindow } from '../FloatingWindow';
import { Button } from '../Button';
import { Highlight } from '../Highlight';
import { BoxesEditor } from '../BoxesEditor';

import styles from './InlineEditor.scss'

@observer
export default class InlineEditor extends React.Component {

    rootElement = null;

    @observable
    editedText = "";

    @observable
    showBoxes = false;

    boxes = [ ];

    @computed
    get line() {
        return this.props.line;
    }

    @computed
    get lineY() {
        return this.line.reduce((min, grapheme) => {
            return Math.min(min, grapheme.area.uly);
        }, this.line[0].area.uly) * this.previewToSurfaceRatio;
    }

    @computed
    get lineBottomY() {
        return this.line.reduce((min, grapheme) => {
            return Math.min(min, grapheme.area.lry);
        }, this.line[0].area.lry) * this.previewToSurfaceRatio;
    }

    @computed
    get previewImageWidth() {
        return this.image.naturalWidth;
    }

    @computed
    get lineHeight() {
        return this.lineBottomY - this.lineY;
    }

    @computed
    get previewToSurfaceRatio() {
        let surface = this.props.document.surfaces[0];

        return this.previewImageWidth / (surface.area.lrx - surface.area.ulx);
    }

    @computed
    get scaledLineHeight() {
        let ratio = this.input.offsetWidth / this.image.naturalWidth;

        return this.lineHeight * ratio;
    }

    @computed
    get dir() {
        return this.props.text.codePointAt(0) === 0x200f ? "rtl" : "ltr";
    }

    @computed
    get pageImageUrl() {
        return this.props.document.surfaces[0].image_url;
    }

    get canvas() {
        if(this.rootElement === null) {
            return null;
        }
        else {
            return this.rootElement.getElementsByClassName('corpusbuilder-inline-editor-preview')[0];
        }
    }

    get canvasArea() {
        if(this.rootElement === null) {
            return null;
        }
        else {
            return this.rootElement.getElementsByClassName('corpusbuilder-inline-editor-canvas-area')[0];
        }
    }

    get image() {
        if(this.rootElement === null) {
            return null;
        }
        else {
            return this.rootElement.getElementsByClassName('corpusbuilder-inline-editor-preview-source')[0];
        }
    }

    get input() {
        if(this.rootElement === null) {
            return null;
        }
        else {
            return this.rootElement.getElementsByClassName('corpusbuilder-inline-editor-input')[0];
        }
    }

    captureRoot(div) {
        if(this.rootElement === null) {
            this.rootElement = div;

            setTimeout(() => {
                this.renderPreview();
            });
        }
    }

    onTextChanged(e) {
        this.editedText = e.target.value;
    }

    onBoxesReported(boxes) {
        this.boxes = boxes;
    }

    onEditorKeyUp(e) {
        if(e.ctrlKey && e.keyCode == 13) {
        }
    }

    onCloseRequested() {
        if(this.props.visible) {
            this.editedText = "";
            this.requestClose();
        }
    }

    componentWillMount() {
        this.editedText = this.props.text;
    }

    componentWillUpdate(props) {
        if(this.props.visible !== props.visible) {
            this.editedText = props.text;
        }

        if(this.props.visible === false) {
            this.rootElement = null;
            this.boxes =  [];
        }
    }

    requestClose() {
        if(this.props.onCloseRequested !== undefined && this.props.onCloseRequested !== null) {
            this.props.onCloseRequested();
        }
    }

    requestSave() {
        if(this.props.onSaveRequested !== undefined && this.props.onSaveRequested !== null) {
            this.props.onSaveRequested(this.props.document, this.props.line, this.editedText);
        }
    }

    resetText() {
        this.editedText = this.props.text;
    }

    onToggleBoxes(show) {
        this.showBoxes = show;
    }

    renderPreview() {
        if(this.canvas !== null) {
            let context = this.canvas.getContext('2d');

            this.canvas.width = this.input.offsetWidth;
            this.canvas.height = this.scaledLineHeight * 2;
            this.canvasArea.style.height = `${this.scaledLineHeight * 2}px`;

            context.drawImage(
                this.image,
                0,
                this.lineY - (this.lineHeight / 2),
                this.previewImageWidth,
                this.lineHeight * 2,
                0,
                0,
                this.canvas.width,
                this.scaledLineHeight * 2
            );
        }
    }

    render() {
        if(this.props.visible) {
            return (
                <div ref={ this.captureRoot.bind(this) }>
                  <FloatingWindow visible={ this.props.visible }
                                  offsetTop={ 20 }
                                  onCloseRequested={ this.onCloseRequested.bind(this) }
                                  >
                        <div className="corpusbuilder-inline-editor-preview-wrapper">
                            <img className="corpusbuilder-inline-editor-preview-source"
                                src={ this.pageImageUrl }
                                />
                            <div className="corpusbuilder-inline-editor-canvas-area">
                                <canvas className="corpusbuilder-inline-editor-preview" />
                                <BoxesEditor line={ this.props.line }
                                             visible={ this.showBoxes }
                                             document={ this.props.document }
                                             boxes={ this.boxes }
                                             onBoxesReported={ this.onBoxesReported.bind(this) }
                                             />
                            </div>
                        </div>
                        <input onChange={ this.onTextChanged.bind(this) }
                               onKeyUp={ this.onEditorKeyUp.bind(this) }
                               value={ this.editedText }
                               dir={ this.dir }
                               className="corpusbuilder-inline-editor-input"
                               />
                        <div className="corpusbuilder-inline-editor-buttons">
                            <Button onToggle={ this.onToggleBoxes.bind(this) }
                              toggles={ true }
                              toggled={ this.showBoxes }
                              >
                              Boxes
                            </Button>
                            <Button onClick={ this.resetText.bind(this) }>
                              Reset
                            </Button>
                            <Button onClick={ this.requestSave.bind(this) }>
                              Save
                            </Button>
                        </div>
                  </FloatingWindow>
                  <Highlight graphemes={ this.props.line }
                             document={ this.props.document }
                             page={ this.props.page }
                             width={ this.props.width }
                             mainPageTop={ this.props.mainPageTop }
                             />
                </div>
            );
        }
        else {
            return null;
        }
    }
}
