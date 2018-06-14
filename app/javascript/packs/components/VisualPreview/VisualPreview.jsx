import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import { BoxesEditor } from '../BoxesEditor';

import styles from './VisualPreview.scss'

@observer
export default class VisualPreview extends React.Component {

    rootElement = null;

    @computed
    get showMask() {
        return this.props.showMask === true;
    }

    @computed
    get selectedBox() {
        return this.props.selectedBox;
    }

    @computed
    get allowNewBoxes() {
        return this.props.allowNewBoxes;
    }

    @computed
    get editable() {
        return this.props.editable;
    }

    @computed
    get line() {
        return this.props.line;
    }

    @computed
    get lineY() {
        if(this.props.visual !== undefined && this.props.visual !== null) {
            return (this.props.visual.y / this.props.visual.ratio) *
                this.previewToSurfaceRatio;
        }

        return this.line.reduce((min, grapheme) => {
            return Math.min(min, grapheme.area.uly);
        }, this.line[0].area.uly) * this.previewToSurfaceRatio;
    }

    @computed
    get lineBottomY() {
        return this.line.reduce((max, grapheme) => {
            return Math.max(max, grapheme.area.lry);
        }, this.line[0].area.lry) * this.previewToSurfaceRatio;
    }

    get previewImageWidth() {
        return this.image.naturalWidth;
    }

    @computed
    get lineHeight() {
        if(this.props.visual !== undefined && this.props.visual !== null) {
            return (this.props.visual.height / this.props.visual.ratio) *
                this.previewToSurfaceRatio;
        }

        return this.lineBottomY - this.lineY;
    }

    get previewToSurfaceRatio() {
        let surface = this.props.document.surfaces[0];

        return this.previewImageWidth / (surface.area.lrx - surface.area.ulx);
    }

    @computed
    get ratio() {
        if(this.canvas !== undefined && this.canvas !== null) {
            let surface = this.props.document.surfaces[0];

            return this.canvas.offsetWidth / (surface.area.lrx - surface.area.ulx);
        }

        return 1;
    }

    @computed
    get scaledLineHeight() {
        let ratio = this.canvas.offsetWidth / this.image.naturalWidth;

        return this.lineHeight * ratio;
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
            return this.rootElement.getElementsByClassName('corpusbuilder-visual-preview-preview')[0];
        }
    }

    get canvasArea() {
        if(this.rootElement === null) {
            return null;
        }
        else {
            return this.rootElement.getElementsByClassName('corpusbuilder-visual-preview-canvas-area')[0];
        }
    }

    get image() {
        if(this._image === null || this._image === undefined) {
            let image = new Image();

            image.onload = (() => {
                this.renderPreview();
            }).bind(this);

            image.src = this.pageImageUrl;

            this._image = image;
        }

        return this._image;
    }

    componentWillUpdate() {
        this._image = null;
    }

    onBoxSelectionChanged(box) {
        this.props.onBoxSelectionChanged(box);
    }

    onBoxesReported(boxes, scaled) {
        if(typeof this.props.onBoxesReported === 'function') {
            this.props.onBoxesReported(boxes, scaled);
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

    renderPreview() {
        if(this.canvas !== null) {
            let context = this.canvas.getContext('2d');

            this.canvas.width = this.canvas.parentNode.offsetWidth;
            this.canvas.height = Math.ceil(this.scaledLineHeight * 2);
            this.canvasArea.style.height = `${Math.ceil(this.scaledLineHeight * 2)}px`;

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

            if(this.canvas.height > this.canvas.parentElement.offsetHeight) {
                let delta = this.canvas.height - this.canvas.parentElement.offsetHeight;

                this.canvas.parentElement.scrollTop = delta / 2;
            }
            else {
                this.canvas.parentElement.scrollTop = 0;
            }
        }
    }

    renderMask() {
        if(this.showMask && !this.showBoxes && this.selectedBox !== null && this.selectedBox !== undefined) {
            let leftStyle = {
                left: '0px',
                right: 'auto',
                width: `${ this.selectedBox.ulx * this.ratio - 4 }px`
            };
            let rightStyle = {
                left: `${ this.selectedBox.lrx * this.ratio + 4 }px`,
                right: '0px',
                width: 'auto'
            };
            return [
                <div className="corpusbuilder-visual-preview-mask"
                     style={ leftStyle }
                     key={ 'left' }
                     >
                </div>,
                <div className="corpusbuilder-visual-preview-mask"
                     style={ rightStyle }
                     key={ 'right' }
                     >
                </div>
            ]
        }

        return null;
    }

    render() {
        return (
            <div ref={ this.captureRoot.bind(this) } className="corpusbuilder-visual-preview-preview-wrapper">
                <div className="corpusbuilder-visual-preview-canvas-area">
                    <canvas className="corpusbuilder-visual-preview-preview" />
                    { this.renderMask() }
                    <BoxesEditor line={ this.props.line }
                                 visible={ this.props.showBoxes }
                                 previewToSurfaceRatio={ this.previewToSurfaceRatio }
                                 visual={ this.props.visual }
                                 document={ this.props.document }
                                 editable={ this.editable }
                                 boxes={ this.props.boxes }
                                 selectedBox={ this.props.selectedBox }
                                 allowNewBoxes={ this.allowNewBoxes }
                                 onBoxSelectionChanged={ this.onBoxSelectionChanged.bind(this) }
                                 onBoxesReported={ this.onBoxesReported.bind(this) }
                                 />
                </div>
            </div>
        );
    }
}
