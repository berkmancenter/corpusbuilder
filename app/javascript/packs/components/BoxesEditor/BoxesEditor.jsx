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

    componentDidMount() {
        interact('.corpusbuilder-boxes-editor-item')
          .draggable({
              restrict: {
                  restriction: "parent",
                  endOnly: true,
                  elementRect: { top: 0, left: 0, bottom: 1, right: 1 }
              },
              onmove: this.onBoxMove.bind(this)
          })
    }

    onBoxMove(event) {
        let target = event.target;
        let x = event.dx;
        let y = event.dy;

        let boxIndex = target.getAttribute('data-index');
        let box = this.boxes[boxIndex];

        box.ulx = box.ulx + x;
        box.uly = box.uly + y;

        // target.style.transform = this.compileTransform(box);
    }

    compileTransform(box) {
        return `translate(${ box.ulx }px, ${ box.uly }px)`;
    }

    renderBoxes() {
        return this.boxes.map(
          (box, index) => {
              let boxStyles = {
                  transform: this.compileTransform(box)
              };

              return <div className="corpusbuilder-boxes-editor-item"
                   data-index={ index }
                   key={ index }
                   style={ boxStyles }
                   >
                  <div className="corpusbuilder-boxes-editor-item-move-handle">
                      &nbsp;
                  </div>
              </div>
          }
        );
    }

    render() {
        return (
            <div className="corpusbuilder-boxes-editor">
                { this.renderBoxes() }
            </div>
        );
    }
}
