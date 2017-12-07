import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { interact } from 'interactjs';

import styles from './BoxesEditor.scss';

@observer
export default class BoxesEditor extends React.Component {

    @observable
    boxes = [
      { ulx: 10, uly: 2, lrx: 30, lry: 22 }
    ];

    @observable
    rootElement = null;

    @computed
    get surface() {
        return this.props.document.surfaces[0];
    }

    @computed
    get surfaceWidth() {
        return this.surface.area.lrx - this.surface.area.ulx;
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

    componentDidMount() {
        interact('.corpusbuilder-boxes-editor-item')
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

        this.broadcastBoxChange(box, boxIndex);
    }

    onMouseMove(event) {
        let target = event.target;

        target.style.cursor = document.documentElement.style.cursor;
    }

    broadcastBoxChange(box, index) {
        this.props.onBoxChanged(
            this.translateBox(box)
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

    renderBoxes() {
        return this.boxes.map(
          (box, index) => {
              let boxStyles = {
                  transform: `translate(${ box.ulx }px, ${ box.uly }px)`,
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
        return (
            <div className="corpusbuilder-boxes-editor"
                 ref={ (div) => { this.rootElement = div } }
                 >
                { this.renderBoxes() }
            </div>
        );
    }
}
