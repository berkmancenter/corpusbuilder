import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import GraphemesUtils from '../../lib/GraphemesUtils';
import { interact } from 'interactjs';

import styles from './BoxesEditor.scss';

@observer
export default class BoxesEditor extends React.Component {

    interactable = null;

    componentDidMount() {
        this.inferBoxes();

        this.interactable = interact('.corpusbuilder-boxes-editor-item')
          .draggable({
              onmove: this.onBoxMove.bind(this),
              restrict: {
                  restriction: "parent",
                  endOnly: true,
                  elementRect: { top: 0, left: 0, bottom: 1, right: 1 }
              },
          })
          .resizable({
              edges: { left: true, right: true, bottom: true, top: true },
              margin: 2,
              restrictEdges: {
                  outer: 'parent',
                  endOnly: true,
              }
          })
          .on('resizemove', this.onBoxMove.bind(this))
          .on('dragend', this.onBoxEdited.bind(this))
          .on('resizeend', this.onBoxEdited.bind(this));
    }

    componentWillUnmount() {
        this.interactable.unset();
        delete this.interactable;
    }

    componentWillUpdate(props) {
        if(!props.visible) {
            this.rootElement = null;
            this.boxes = [];
        }
        else {
            if(this.boxes.length === 0) {
                this.inferBoxes();
            }
        }
    }

    scaleBoxDown(box) {
        return {
            ulx: box.ulx * this.ratio,
            uly: box.uly * this.ratio,
            lrx: box.lrx * this.ratio,
            lry: box.lry * this.ratio
        };
    }

    inferBoxes() {
        if(this.props.boxes === null || this.props.boxes === undefined ||
           this.props.boxes.length === 0) {
            this.boxes = GraphemesUtils.wordBoxes(this.props.line)
                                      .map(this.scaleBoxDown.bind(this));
            this.broadcastBoxes();
        }
        else {
            this.boxes = this.props.boxes.map(this.scaleBoxDown.bind(this));
        }
    }

    @observable
    boxes = [ ];

    setRoot(div) {
        if(this.rootElement === null && div !== null) {
            this.rootElement = div;
            this.inferBoxes();
        }
    }

    @observable
    rootElement = null;

    get surfaceWidth() {
        return this.surface.area.lrx - this.surface.area.ulx;
    }

    get surface() {
        return this.props.document.surfaces[0];
    }

    @computed
    get editorWidth() {
        if(this.rootElement !== null && this.rootElement !== undefined) {
            return this.rootElement.offsetWidth;
        }
        else {
            return 1;
        }
    }

    @computed
    get ratio() {
        return this.editorWidth / this.surfaceWidth;
    }

    @computed
    get origLineY() {
        return this.props.line.reduce((min, grapheme) => {
            return Math.min(min, grapheme.area.uly);
        }, this.props.line[0].area.uly);
    }

    @computed
    get origLineBottomY() {
        return this.props.line.reduce((min, grapheme) => {
            return Math.min(min, grapheme.area.lry);
        }, this.props.line[0].area.lry);
    }

    @computed
    get origLineHeight() {
        return this.origLineBottomY - this.origLineY;
    }

    onBoxMove(event) {
        let target = event.target;
        let boxIndex = target.getAttribute('data-index');
        let box = this.boxes[boxIndex];

        if(event.deltaRect === undefined) {
            let x = event.dx;
            let y = event.dy;

            box.ulx = box.ulx + x;
            box.uly = box.uly + y;
            box.lrx = box.lrx + x;
            box.lry = box.lry + y;
        }
        else {
            let x = event.deltaRect.left;
            let y = event.deltaRect.top;

            box.ulx = box.ulx + x;
            box.uly = box.uly + y;
            box.lrx = box.ulx + event.rect.width;
            box.lry = box.uly + event.rect.height;
        }
    }

    onBoxEdited(event) {
        let target = event.target;
        let boxIndex = target.getAttribute('data-index');
        let box = this.boxes[boxIndex];

        this.broadcastBoxes();
    }

    onMouseMove(event) {
        let target = event.target;

        target.style.cursor = document.documentElement.style.cursor;
    }

    broadcastBoxes() {
        this.props.onBoxesReported(
            this.boxes.map(this.translateBox.bind(this))
        );
    }

    translateBox(box) {
        let invRatio = 1 / this.ratio;

        return {
            ulx: box.ulx * invRatio,
            uly: box.uly * invRatio,
            lrx: box.lrx * invRatio,
            lry: box.lry * invRatio
        }
    }

    translatedUly(box) {
        return (
          this.translateBox(box).uly - this.origLineY + this.origLineHeight * 0.5
        ) * this.ratio;
    }

    renderBoxes() {
        return this.boxes.map(
          (box, index) => {
              let translatedUly = this.translatedUly(box);

              let boxStyles = {
                  transform: `translate(${ box.ulx }px, ${ translatedUly }px)`,
                  width: (box.lrx - box.ulx),
                  height: (box.lry - box.uly)
              };

              return <div className="corpusbuilder-boxes-editor-item"
                   data-index={ index }
                   key={ index }
                   style={ boxStyles }
                   onMouseMove={ this.onMouseMove.bind(this) }
                   >
                  &nbsp;
              </div>
          }
        );
    }

    render() {
        if(this.props.visible) {
            return (
                <div className="corpusbuilder-boxes-editor"
                    ref={ this.setRoot.bind(this) }
                    >
                    { this.renderBoxes() }
                </div>
            );
        }

        return null;
    }
}
