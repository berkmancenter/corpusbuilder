import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import GraphemesUtils from '../../lib/GraphemesUtils';
import BoxesUtils from '../../lib/BoxesUtils';
import { interact } from 'interactjs';

import styles from './BoxesEditor.scss';

@observer
export default class BoxesEditor extends React.Component {

    interactable = null;

    @observable
    newBox = null;

    @computed
    get selectedBox() {
        if(this.props.selectedBox !== undefined && this.props.selectedBox !== null) {
            return this.scaleBoxDown(this.props.selectedBox);
        }

        return null;
    }

    @computed
    get previewToSurfaceRatio() {
        return this.props.previewToSurfaceRatio;
    }

    @computed
    get allowNewBoxes() {
        return this.props.allowNewBoxes;
    }

    @computed
    get editable() {
        return this.props.editable;
    }

    componentDidMount() {
        this.inferBoxes();

        if(!this.editable) {
            return null;
        }

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
        if(this.interactable !== null) {
            this.interactable.unset();
            delete this.interactable;
        }
    }

    componentWillUpdate(props) {
        if(!props.visible) {
            this.rootElement = null;
            this.inferBoxes();
        }
        else {
            if(this.boxes === null || this.boxes.length !== this.props.boxes.length) {
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

            if(this.selectedBox !== null) {
                let found = this.boxes.filter((b) => {
                    return b.ulx !== this.selectedBox.ulx &&
                          b.uly !== this.selectedBox.uly &&
                          b.lrx !== this.selectedBox.lrx &&
                          b.lry !== this.selectedBox.lry;
                });

                if(found === null || found === undefined) {
                    this.selectedBox = null;
                }
            }
        }
    }

    @observable
    boxes = null;

    @computed
    get allBoxes() {
        if(this.newBox !== null) {
            return this.boxes.concat([ this.newBox ]);
        }
        else {
            return this.boxes;
        }
    }

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
        if(this.props.visual !== undefined && this.props.visual !== null) {
            return (this.props.visual.y / this.props.visual.ratio) *
                1; //this.previewToSurfaceRatio;
        }

        return this.props.line.reduce((min, grapheme) => {
            return Math.min(min, grapheme.area.uly);
        }, this.props.line[0].area.uly);
    }

    @computed
    get origLineBottomY() {
        return this.props.line.reduce((max, grapheme) => {
            return Math.max(max, grapheme.area.lry);
        }, this.props.line[0].area.lry);
    }

    @computed
    get origLineHeight() {
        if(this.props.visual !== undefined && this.props.visual !== null) {
            return (this.props.visual.height / this.props.visual.ratio) *
                1; //this.previewToSurfaceRatio;
        }

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

    normalizeBox(box) {
        let overlaps = this.boxes
            .filter((b) => { return b !== box && BoxesUtils.boxesOverlap(b, box) })
            .sort((b1, b2) => { return b1.ulx - b2.ulx });

        let leftOverlaps = overlaps.filter((b) => { return b.lrx < box.lrx })
        let rightOverlaps = overlaps.filter((b) => { return b.ulx > box.ulx })

        let leftOverlap = leftOverlaps[ leftOverlaps.length - 1 ];
        let rightOverlap = rightOverlaps[0];

        if(leftOverlap !== undefined && leftOverlap === rightOverlap) {
            if(leftOverlap.ulx - box.ulx < box.lrx - rightOverlap.lrx) {
                rightOverlap = undefined;
            }
            else {
                leftOverlap = undefined;
            }
        }

        let normalizedUlx = Math.max(
            box.ulx,
            leftOverlap !== undefined ? leftOverlap.lrx + 4 : box.ulx
        );
        let normalizedLrx = Math.min(
            box.lrx,
            rightOverlap !== undefined ? rightOverlap.ulx - 4 : box.lrx
        );

        return {
            uly: box.uly,
            lry: box.lry,
            ulx: normalizedUlx,
            lrx: normalizedLrx
        };
    }

    onBoxEdited(event) {
        let target = event.target;
        let boxIndex = target.getAttribute('data-index');
        let box = this.boxes[boxIndex];

        box = this.normalizeBox(box);

        if(BoxesUtils.boxValid(box)) {
            this.boxes[boxIndex] = box;
        }

        this.broadcastBoxes();
    }

    onBoxClick(event) {
        if(!this.editable || !this.allowNewBoxes) {
            return null;
        }

        if(event.ctrlKey || event.metaKey) {
            let target = event.target;
            let boxIndex = target.getAttribute('data-index');
            let box = this.boxes[boxIndex];

            if(this.selectedBox !== box) {
                this.selectedBox = box;
                this.props.onBoxSelectionChanged(
                  this.translateBox(box)
                );
            }
            else {
                this.props.onBoxSelectionChanged(null);
            }
        }
    }

    onBoxMouseMove(event) {
        if(!this.editable) {
            return null;
        }

        let target = event.target;

        if(event.buttons === 0 && (event.ctrlKey || event.metaKey)) {
            target.style.cursor = 'pointer';
        }
        else {
            target.style.cursor = document.documentElement.style.cursor;
        }

        if ( document.selection ) {
            document.selection.empty();
        } else if ( window.getSelection ) {
            window.getSelection().removeAllRanges();
        }

        event.stopPropagation();
    }

    onEditorMouseMove(event) {
        if(!this.editable || !this.allowNewBoxes) {
            return null;
        }

        if(event.ctrlKey || event.metaKey) {
            event.target.style.cursor = 'crosshair';

            if ( document.selection ) {
                document.selection.empty();
            } else if ( window.getSelection ) {
                window.getSelection().removeAllRanges();
            }
        }
        else {
            event.target.style.cursor = 'auto';
        }

        if(event.buttons === 1 && (event.ctrlKey || event.metaKey)) {
            let rect = event.target.getBoundingClientRect();
            let x = event.clientX - rect.x;
            let y = event.clientY - rect.y;

            this.draw(x, y);
        }
        else {
            if(this.newBox !== null) {
                this.endDraw();
            }
        }
    }

    onEditorMouseUp(event) {
        if(!this.editable) {
            return null;
        }

        if(this.newBox !== null) {
            this.endDraw();
        }
    }

    draw(x, y) {
        let adjustedY = (this.origLineY - this.origLineHeight * 0.5) * this.ratio + y;

        if(this.newBox === null) {
            this.newBox = { ulx: x, uly: adjustedY, lrx: x, lry: adjustedY, startX: x, startY: adjustedY };
        }
        else {
            if(x < this.newBox.startX) {
                this.newBox.ulx = x;
            }
            else {
                this.newBox.lrx = x;
            }

            if(adjustedY < this.newBox.startY) {
                this.newBox.uly = adjustedY;
            }
            else {
                this.newBox.lry = adjustedY;
            }
        }
    }

    endDraw() {
        if(this.newBox !== null) {
            this.boxes.push(
                this.normalizeBox(this.newBox)
            );
            this.newBox = null;
            this.broadcastBoxes();
        }
    }

    broadcastBoxes() {
        this.props.onBoxesReported(
            this.boxes
                .map(this.translateBox.bind(this))
                .sort((box1, box2) => {
                    return box1.ulx - box2.ulx;
                })
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
        return (this.allBoxes || []).map(
          (box, index) => {
              let translatedUly = this.translatedUly(box);

              let boxStyles = {
                  top: translatedUly,
                  left: box.ulx,
                  width: (box.lrx - box.ulx),
                  height: (box.lry - box.uly)
              };

              return <div className={ `corpusbuilder-boxes-editor-item ${ BoxesUtils.boxesEqual(box, this.selectedBox) ? 'corpusbuilder-boxes-editor-item-selected' : '' }` }
                   data-index={ index }
                   key={ index }
                   style={ boxStyles }
                   onClick={ this.onBoxClick.bind(this) }
                   onMouseMove={ this.onBoxMouseMove.bind(this) }
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
                    onMouseMove={ this.onEditorMouseMove.bind(this) }
                    onMouseUp={ this.onEditorMouseUp.bind(this) }
                    >
                    { this.renderBoxes() }
                </div>
            );
        }

        return null;
    }
}
