import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { FloatingWindow } from '../FloatingWindow';
import { Button } from '../Button';
import { Highlight } from '../Highlight';
import { VisualPreview } from '../VisualPreview';

import GraphemeUtils from '../../lib/GraphemesUtils';
import PlatformUtils from '../../lib/PlatformUtils';
import MathUtils from '../../lib/MathUtils';
import BoxesUtils from '../../lib/BoxesUtils';
import DomUtils from '../../lib/DomUtils';

import styles from './InlineEditor.scss'

@inject('measureText')
@inject('measureFontSize')
@inject('inferFont')
@observer
export default class InlineEditor extends React.Component {

    navigating = false;
    inputNode = null;

    @observable
    deleteClickedOnce = false;

    @computed
    get editedText() {
        return this.editedTextWords === null ? "" : this.editedTextWords.join(' ');
    }

    @observable
    _showBoxes = false;

    @computed
    get showBoxes() {
        return this.props.showBoxes || this._showBoxes;
    }

    set showBoxes(value) {
        this._showBoxes = value;
    }

    @computed
    get allowNewBoxes() {
        return this.props.allowNewBoxes === true;
    }

    @observable
    graphemeWords = [ ];

    removedWords = [ ];
    removedBoxes = [ ];

    @observable
    boxes = [ ];

    @observable
    editedTextWords = null;

    @observable
    dir = "ltr";

    @observable
    selectedBox = null;

    selectionProcessing = false;

    originalBoxes = null;

    @computed
    get line() {
        return this.props.line;
    }

    @computed
    get deleteButtonClasses() {
        return this.deleteClickedOnce ? [ "final-delete" ] : [ ];
    }

    @computed
    get deleteButtonTitle() {
        if(this.deleteClickedOnce) {
            return (
                <div>
                  <i className="fa fa-trash"></i>
                  &nbsp;
                  Delete Line
                </div>
            );
        }

        return "Delete Line";
    }

    @computed
    get wordsMatchBoxes() {
        return this.editedTextWords.length === this.boxes.length;
    }

    @computed
    get dataValid() {
        return this.wordsMatchBoxes && !this.boxesOverlap;
    }

    @computed
    get overlappingBoxes() {
        let overlaps = [];

        for(let b1 of this.boxes) {
            for(let b2 of this.boxes) {
                    if(b1 !== b2 && BoxesUtils.boxesOverlap(b1, b2)) {
                        overlaps.push(b2);
                    }
            }
        }

        return overlaps.sort(function(b1, b2) {
            let area1 = BoxesUtils.area(b1);
            let area2 = BoxesUtils.area(b2);

            return area1 < area2 ? 1 : (area1 > area2 ? -1 : 0);
        });
    }

    @computed
    get boxesOverlap() {
        return this.overlappingBoxes.length > 0;
    }

    @computed
    get messages() {
        let result = [];

        if(!this.wordsMatchBoxes) {
            result.push("You must provide the same number of boxes as there are words in the provided text");
        }

        if(this.boxesOverlap) {
            result.push("Boxes cannot overlap");
        }

        return result;
    }

    @computed
    get ratio() {
        if(this.inputNode !== null && this.inputNode !== undefined) {
            let inputWidth = this.inputNode.offsetWidth;
            let surfaceWidth = this.props.document.surfaces[0].area.lrx - this.props.document.surfaces[0].area.ulx;

            return inputWidth / surfaceWidth;
        }
        else {
            return 1;
        }
    }

    @computed
    get font() {
        return this.props.inferFont(this.props.line);
    }

    @computed
    get fontFamily() {
        return this.font.ready ? this.font.familyName : 'sans-serif';
    }

    @computed
    get fontSize() {
        if(this.boxes === undefined || this.boxes === null || this.boxes.length === 0) {
            return 'auto';
        }
        else {
            let size = this.props.measureFontSize(this.props.line, this.font, this.ratio, this.boxes);

            return size === 0 ? 12 : size;
        }
    }

    @computed
    get letterSpacing() {
        if(this.boxes !== null && this.boxes !== undefined && this.boxes.length !== 0) {
            let lineBox = BoxesUtils.union(this.boxes);
            let lineWidth = lineBox.lrx - lineBox.ulx;
            let textWidth = this.props.measureText(this.editedText, this.fontSize, this.font);

            return (this.ratio * lineWidth - textWidth) / ( this.editedText.length - 1);
        }

        return 1;
    }

    @computed
    get paddingLeft() {
        if(this.dir === "rtl" || this.boxes === null || this.boxes === undefined || this.boxes.length === 0) {
            return "0px";
        }
        else {
            let lineBox = BoxesUtils.union(this.boxes);

            return this.ratio * lineBox.ulx;
        }
    }

    @computed
    get paddingRight() {
        if(this.dir === "ltr" || this.boxes === null || this.boxes === undefined || this.boxes.length === 0) {
            return "0px";
        }
        else {
            let lineBox = BoxesUtils.union(this.boxes);
            let surfaceWidth = this.props.document.surfaces[0].area.lrx - this.props.document.surfaces[0].area.ulx;

            return this.ratio * (surfaceWidth - lineBox.lrx);
        }
    }

    @computed
    get inputStyles() {
        return {
            fontSize: this.fontSize,
            fontFamily: this.fontFamily,
            opacity: this.font.applied ? 1 : 0,
            letterSpacing: this.letterSpacing,
            paddingLeft : this.paddingLeft,
            paddingRight: this.paddingRight
        }
    }

    clearLine() {
        this.editedTextWords = this.editedTextWords.map(_ => "");
    }

    deleteLine() {
        if(this.deleteClickedOnce) {
            if(typeof this.props.onDeleteLineRequested === 'function') {
                this.props.onDeleteLineRequested(this.props.line);
            }
        }

        this.deleteClickedOnce = true;
    }

    removeBox(e) {
        this.selectionProcessing = true;

        let ix = this.boxes.findIndex((b) => {
            return BoxesUtils.boxesEqual(b, this.selectedBox);
        });
        this.editedTextWords.splice(ix, 1);
        this.removedWords.push(this.graphemeWords[ix]);
        this.removedBoxes.push(this.boxes[ix]);
        this.graphemeWords.splice(ix, 1);
        this.boxes.splice(ix, 1);
        this.selectedBox = null;

        this.selectionProcessing = false;
    }

    lineDir(props) {
        if(props.line === undefined || props.line === null || props.line.length === 0) {
            return "ltr";
        }

        return props.line[0].zone_direction === 1 ? "rtl" : "ltr";
    }

    onTextChanged(ix, e) {
        this.editedTextWords[ ix ] = e.target.value.replace(/\s+/, '');
    }

    onKeyUp(box, ix, e) {
        if(e.keyCode === 38) {
            this.onArrow(true);
        }
        else if(e.keyCode === 40) {
            this.onArrow(false);
        }
    }

    onPaste(box, ix, e) {
        let isClear = this.editedTextWords.every(str => str.trim().length === 0);

        for(var ix = 0; ix < e.clipboardData.items.length; ix++) {
            if(e.clipboardData.types[ ix ] === 'text/plain') {
                e.clipboardData.items[ ix ].getAsString(str => {
                    if(isClear) {
                        this.onWholeLinePaste(str);
                    }
                });
            }
        }

        if(isClear) {
            e.stopPropagation();
        }
    }

    onWholeLinePaste(str) {
        let words = str.split(/\s+/);

        if(this.dir === "rtl") {
            words.reverse();
        }

        if(words.length > 1) {
            for(var ix = 0; ix < this.editedTextWords.length; ix++) {
                this.editedTextWords[ ix ] = words[ ix ] || "";
            }
        }
    }

    onKeyDown(box, ix, e) {
        if(e.metaKey || e.ctrlKey) {
            if(e.keyCode === 37) {
                this.focusWord(
                    this.dir === "rtl" ? 0 : this.boxes.length - 1,
                    this.dir === "rtl" ? "end" : "start"
                );
            }
            else if(e.keyCode === 39) {
                this.focusWord(
                    this.dir === "rtl" ? this.boxes.length - 1 : 0,
                    this.dir === "rtl" ? "start" : "end"
                );
            }
        }
        else if(e.altKey) {
            if(e.keyCode === 37) {
                this.focusWord(
                    ix - 1,
                    this.dir === "rtl" ? "start" : "end"
                );
            }
            else if(e.keyCode === 39) {
                this.focusWord(
                    ix + 1,
                    this.dir === "rtl" ? "end" : "start"
                );
            }
        }
        else if(e.keyCode === 37) {
            this.onInputArrowSide('left', e.target, ix);
        }
        else if(e.keyCode === 39) {
            this.onInputArrowSide('right', e.target, ix);
        }
        else if(e.keyCode === 32) {
            if(e.target.selectionStart === e.target.value.length) {
                this.onInputArrowSide(
                    this.dir === "rtl" ? 'left' : 'right',
                    e.target,
                    ix
                );
            }
        }
    }

    onInputFocus(box, ix, e) {
        this.selectedBox = box;
    }

    onInputBlur() {
      if(!this.selectionProcessing) {
        setTimeout(_ => {
            this.selectedBox = null;
        }, 300);
      }
    }

    onShellClick(e) {
        if(e.target === this.inputNode) {
            if(this.boxes !== null && this.boxes !== undefined && this.boxes.length !== 0) {
                let x = e.screenX - DomUtils.absoluteOffsetLeft(e.target);
                let candidateIx = 0;

                this.boxes.forEach((box, ix) => {
                    if(box.lrx * this.ratio < x) {
                        candidateIx = ix;
                    }
                });

                this.focusWord(candidateIx);

                let text = this.editedTextWords[ candidateIx ];

                if(this.boxes[ candidateIx ].ulx * this.ratio > x) {
                    let tix = this.dir === "rtl" ? text.length : 0;

                    this.inputNode.children[ candidateIx ].setSelectionRange(
                        tix,
                        tix
                    );
                }
                else {
                    let tix = this.dir === "rtl" ? 0 : text.length

                    this.inputNode.children[ candidateIx ].setSelectionRange(
                        tix,
                        tix
                    );
                }
            }
        }
    }

    focusWord(ix, caretMode = null) {
        pre: {
            typeof ix === 'number';
            [ null, 'start', 'end' ].includes(caretMode);
        }

        ix = Math.max(
            Math.min(
                ix,
                this.boxes.length - 1
            ),
            0
        );

        let input = this.inputNode.children[ ix ];

        if(input !== undefined) {
            input.focus();

            setTimeout(() => {
                if(caretMode === 'start') {
                    input.setSelectionRange(
                        0,
                        0
                    );
                }
                else if(caretMode === 'end') {
                    let end = input.value.length;

                    input.setSelectionRange(
                        end,
                        end
                    );
                }
            });
        }
    }

    onInputArrowSide(side, inputNode, ix) {
        pre: {
            ['left', 'right'].includes(side);
            inputNode.constructor.name === "HTMLInputElement";
            this.boxes[ ix ] !== undefined;
        }

        if(side === 'left') {
            if(this.dir === 'rtl') {
                if(inputNode.selectionStart === inputNode.value.length) {
                    this.focusWord(ix - 1, 'start');
                }
            }
            else {
                if(inputNode.selectionStart === 0) {
                    this.focusWord(ix - 1, 'end');
                }
            }
        }
        else {
            if(this.dir === 'rtl') {
                if(inputNode.selectionStart === 0) {
                    this.focusWord(ix + 1, 'end');
                }
            }
            else {
                if(inputNode.selectionStart === inputNode.value.length) {
                    this.focusWord(ix + 1, 'start');
                }
            }
        }
    }

    onArrow(up) {
        pre: typeof up === 'boolean';

        if(typeof this.props.onArrow === 'function') {
            this.navigating = true;
            this.props.onArrow(up);
        }
    }

    onBoxesReported(boxes) {
        if(this.originalBoxes !== null) {
            let diff = boxes.length - this.boxes.length;

            if(diff === 1) {
              // box has been added
              let ix = boxes.findIndex((box, i) => {
                  return !BoxesUtils.boxesEqual(box, this.boxes[ i ]);
              });
              this.editedTextWords.splice(ix, 0, "");
              this.graphemeWords.splice(ix, 0, []);
            }
            else if(diff === -1) {
              // box has been removed
              let ix = boxes.findIndex((box, ix) => {
                  return !BoxesUtils.boxesEqual(box, this.boxes[ ix ]);
              });
              this.editedTextWords.splice(ix, 1);
              this.graphemeWords.splice(ix, 1);
            }
        }

        if(this.boxes.length === 0) {
            this.originalBoxes = boxes;
        }

        this.boxes.replace(boxes);
    }

    onBoxSelectionChanged(box) {
        this.selectedBox = box;
    }

    onCloseRequested() {
        if(this.props.visible) {
            this.editedTextWords = [];
            this.requestClose();
        }
    }

    onResolveOverlap() {
        this.selectedBox = this.overlappingBoxes[0];
        this.removeBox();
    }

    initText(props) {
        this.dir = this.lineDir(props);
        this.graphemeWords = GraphemeUtils.lineWords(props.line);
        this.removedWords = [ ];
        this.removedBoxes = [ ];
        this.editedTextWords = this.graphemeWords
            .map((word) => {
                return word.sort((g1, g2) => { return parseFloat(g1.position_weight) - parseFloat(g2.position_weight) })
                           .map((g) =>  { return g.value })
                           .join('')
            })
    }

    componentWillMount() {
        this.initText(this.props);
    }

    componentWillUpdate(props) {
        if(this.editedTextWords === null || this.props.visible !== props.visible || this.navigating ) {
            if(this.navigating) {
                setTimeout(() => {
                    this.focusWord(this.dir === "rtl" ? this.boxes.length - 1 : 0, "start");
                });
            }
            this.initText(props);
            this.navigating = false;
            this.originalBoxes = null;
            this.boxes = [ ];
            this.deleteClickedOnce = false;
        }

        if(this.props.visible === false) {
            this.rootElement = null;
            this.boxes =  [];
        }
    }

    captureInput(el) {
        this.inputNode = el;
    }

    requestClose() {
        if(this.props.onCloseRequested !== undefined && this.props.onCloseRequested !== null) {
            this.props.onCloseRequested();
        }
    }

    requestSave() {
        if(this.props.onSaveRequested !== undefined && this.props.onSaveRequested !== null) {
            let textWords = this.dir === 'rtl' ? this.editedTextWords.reverse() : this.editedTextWords;
            let graphemeWords = this.dir === 'rtl' ? this.graphemeWords.reverse() : this.graphemeWords;
            let boxes = this.dir === 'rtl' ? this.boxes.reverse() : this.boxes;

            let removed = this.removedWords.map(
                (word, ix) => {
                    return {
                        text: '',
                        area: this.removedBoxes[ix],
                        grapheme_ids: word.map((g) => { return g.id })
                    }
                }
            );

            let words = graphemeWords.map(
                (word, ix) => {
                    return {
                        text: textWords[ix],
                        area: boxes[ix],
                        grapheme_ids: word.map((g) => { return g.id })
                    }
                }
            ).concat(removed);

            this.props.onSaveRequested(this.props.document, words, this.dir);
        }
    }

    resetText() {
        this.boxes.replace(this.originalBoxes || [ ]);
        this.initText(this.props);
    }

    onToggleBoxes(show) {
        this.showBoxes = show;
    }

    onToggleDir(dir, toggled) {
        let _toggled = dir === "ltr" ? toggled : !toggled;
        this.dir = _toggled ? "ltr" : "rtl";
    }

    renderInput(box, ix, offset) {
        let text = this.editedTextWords[ ix ];

        if(text !== undefined && text !== null) {
            let boxWidth = (box.lrx - box.ulx) * this.ratio;
            let textWidth = this.props.measureText(text, this.fontSize, this.font);
            let scale = textWidth > 0 ? boxWidth / textWidth : 1;

            if(this.selectedBox === box) {
                if(scale > 1.25) {
                    scale = 1;
                    textWidth = boxWidth;
                }
            }

            if(textWidth === 0) {
                textWidth = boxWidth;
            }

            let styles = {
                left: box.ulx * this.ratio - offset,
                width: textWidth,
                transform: `scaleX(${ scale })`,
                fontSize: this.fontSize,
                fontFamily: this.fontFamily,
                opacity: this.font.applied ? 1 : 0
            };

            return (
                <input onChange={ this.onTextChanged.bind(this, ix) }
                      value={ text }
                      onKeyUp={ this.onKeyUp.bind(this, box, ix) }
                      onKeyDown={ this.onKeyDown.bind(this, box, ix) }
                      onPaste={ this.onPaste.bind(this, box, ix) }
                      style={ styles }
                      dir={ this.dir }
                      key={ ix }
                      onFocus={ this.onInputFocus.bind(this, box, ix) }
                      onBlur={ this.onInputBlur.bind(this) }
                      className="corpusbuilder-inline-editor-input"
                      />
            );
        }

        return null;
    }

    renderInputs() {
        let ixs = this.boxes.map((_, ix) => { return ix });
        let offset = 0;

        return (
            <div className="corpusbuilder-inline-editor-shell"
                 ref={ this.captureInput.bind(this) }
                 onClick={ this.onShellClick.bind(this) }
                 >
                {
                    ixs.map((ix) => {
                        let input = this.renderInput(this.boxes[ ix ], ix, offset);
                        if(input !== null) {
                            offset = offset + input.props.style.width;
                        }
                        else {
                            offset = 0;
                        }
                        return input;
                    })
                }
            </div>
        );
    }

    render() {
        if(this.props.visible) {
            let boxesHelp = null;
            if(this.showBoxes && this.allowNewBoxes) {
                boxesHelp = <div className="corpusbuilder-inline-editor-help">
                  <i className="fa fa-info-circle"></i>
                  &nbsp;
                  Hold { PlatformUtils.specialKeyName() } to start drawing or select
                </div>
            }
            let messageBox = null;
            if(this.messages.length > 0) {
                let overlapButton = null;

                if(this.boxesOverlap) {
                    overlapButton = (
                        <Button onClick={ this.onResolveOverlap.bind(this) }
                          >
                          Remove biggest
                        </Button>
                    );
                }

                messageBox = (
                            <div className="corpusbuilder-inline-editor-messages"
                                >
                                {
                                    this.messages.map((msg) => {
                                        return <div key={ msg }><span>{ msg }</span>{ overlapButton }</div>;
                                    })
                                }
                            </div>
                );
            }
            return (
                <div>
                  <FloatingWindow visible={ this.props.visible }
                                  offsetTop={ 20 }
                                  onCloseRequested={ this.onCloseRequested.bind(this) }
                                  >
                        { messageBox }
                        <VisualPreview pageImageUrl={ this.pageImageUrl }
                                       line={ this.props.line }
                                       visual={ this.props.visual }
                                       document={ this.props.document }
                                       editable={ true }
                                       boxes={ this.boxes }
                                       selectedBox={ this.selectedBox }
                                       showBoxes={ this.showBoxes }
                                       allowNewBoxes={ this.allowNewBoxes }
                                       onBoxesReported={ this.onBoxesReported.bind(this) }
                                       onBoxSelectionChanged={ this.onBoxSelectionChanged.bind(this) }
                                       />
                        {
                            this.renderInputs()
                        }
                        <div className="corpusbuilder-inline-editor-dir">
                            <span>Text Direction:</span>
                            <Button
                              tooltip="Select to choose the left-to-right direction of the text"
                              onToggle={ this.onToggleDir.bind(this, "ltr") }
                              toggles={ true }
                              toggled={ this.dir === "ltr" }
                              >
                              ⇢
                            </Button>
                            <Button onToggle={ this.onToggleDir.bind(this, "rtl") }
                              tooltip="Select to choose the right-to-left direction of the text"
                              toggles={ true }
                              toggled={ this.dir === "rtl" }
                              >
                              ⇠
                            </Button>
                        </div>
                        <div className="corpusbuilder-inline-editor-buttons">
                            <Button onToggle={ this.onToggleBoxes.bind(this) }
                              toggles={ true }
                              toggled={ this.showBoxes }
                              visible={ !this.props.showBoxes }
                              >
                              Show Boxes
                            </Button>
                            <Button onClick={ this.removeBox.bind(this) }
                                    visible={ this.selectedBox !== null && this.selectedBox !== undefined }
                                    >
                              Remove Word
                            </Button>
                            {
                                boxesHelp
                            }
                        </div>
                        <div className="corpusbuilder-inline-editor-buttons">
                            <Button onClick={ this.deleteLine.bind(this) }
                                    tooltip="Deletes the whole line along with all boxes and text."
                                    classes={ this.deleteButtonClasses }
                                    >
                              { this.deleteButtonTitle }
                            </Button>
                            <Button
                              tooltip="Clears the boxes from the OCR version. <br /> New boxes can then be drawn to capture the text as the user sees fit"
                              onClick={ this.clearLine.bind(this) }
                              >
                              Clear Line
                            </Button>
                            <div className="corpusbuilder-inline-editor-buttons-aside">
                                <Button onClick={ this.resetText.bind(this) }>
                                  Undo
                                </Button>
                                <Button onClick={ this.requestSave.bind(this) } disabled={ !this.dataValid }>
                                  Save
                                </Button>
                            </div>
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
