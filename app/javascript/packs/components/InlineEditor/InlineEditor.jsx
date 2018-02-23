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
@observer
export default class InlineEditor extends React.Component {

    navigating = false;
    inputNode = null;

    @observable
    editedText = "";

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
    boxes = [ ];

    @observable
    selectedBox = null;

    originalBoxes = [ ];

    @computed
    get line() {
        return this.props.line;
    }

    @computed
    get dir() {
        // todo: add ability to choose it from UI
        if(this.props.line === undefined || this.props.line === null || this.props.line.length === 0) {
            return "rtl";
        }

        return this.props.line[0].value.codePointAt(0) === 0x200f ? "rtl" : "ltr";
    }

    @computed
    get editedTextWords() {
        return this.editedText.trim().split(/\s+/g).filter((word) => {
            return word.length > 1 || (word.length > 0 && !GraphemeUtils.isCharSpecial(word[0]));
        });

    }

    @computed
    get wordsMatchBoxes() {
        return this.editedTextWords.length === this.boxes.length;
    }

    @computed
    get messages() {
        let result = [];

        if(!this.wordsMatchBoxes) {
            result.push("You must provide the same number of boxes as there are words in the provided text");
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
    get fontSize() {
        if(this.boxes === undefined || this.boxes === null || this.boxes.length === 0) {
            return 'auto';
        }
        else {
            let meanBoxHeight = MathUtils.mean(this.boxes.map((box) => { return box.lry - box.uly; }));

            return meanBoxHeight * this.ratio;
        }
    }

    @computed
    get letterSpacing() {
        if(this.boxes !== null && this.boxes !== undefined && this.boxes.length !== 0) {
            let lineBox = BoxesUtils.union(this.boxes);
            let lineWidth = lineBox.lrx - lineBox.ulx;
            let textWidth = this.props.measureText(this.editedText, this.fontSize);

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
            letterSpacing: this.letterSpacing,
            paddingLeft : this.paddingLeft,
            paddingRight: this.paddingRight
        }
    }

    deleteLine() {
        if(typeof this.props.onDeleteLineRequested === 'function') {
            this.props.onDeleteLineRequested(this.props.line);
        }
    }

    removeBox(e) {
        let items = this.boxes.filter((b) => {
            return !(
              Math.abs(b.ulx - this.selectedBox.ulx) < 1 &&
              Math.abs(b.uly - this.selectedBox.uly) < 1 &&
              Math.abs(b.lrx - this.selectedBox.lrx) < 1 &&
              Math.abs(b.lry - this.selectedBox.lry) < 1
            );
        });
        this.boxes.clear();
        this.boxes.replace(items);
        this.selectedBox = null;
        this.forceUpdate();

        e.stopPropagation();
    }

    onTextChanged(ix, e) {
        let textWords = JSON.parse(JSON.stringify(this.editedTextWords));
        textWords[ ix ] = e.target.value;

        this.editedText = textWords.join(' ');
    }

    onKeyUp(box, ix, e) {
        if(e.keyCode === 38) {
            this.onArrow(true);
        }
        else if(e.keyCode === 40) {
            this.onArrow(false);
        }
    }

    onInputFocus(box, ix, e) {
        this.selectedBox = box;
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

                this.inputNode.children[ candidateIx ].focus();
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

    onArrow(up) {
        if(typeof this.props.onArrow === 'function') {
            this.navigating = true;
            this.props.onArrow(up);
        }
    }

    onBoxesReported(boxes) {
        if(this.boxes.length === 0) {
            this.originalBoxes = boxes;
        }
        this.boxes.replace(boxes);
        console.log('Boxes have been reported');
    }

    onBoxSelectionChanged(box) {
        this.selectedBox = box;
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
        if(this.props.visible !== props.visible || this.navigating ) {
            this.editedText = props.text;
            this.navigating = false;
            this.originalBoxes = [ ];
            this.boxes = [ ];
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
            if(this.props.line === undefined || this.props.line === null || this.props.line.length === 0) {
                let start = this.dir === "rtl" ? GraphemeUtils.rtlMark : GraphemeUtils.ltrMark;
                let end   = GraphemeUtils.popDirectionalityMark;

                this.editedText = `${String.fromCharCode(start)} ${this.editedText} ${String.fromCharCode(end)}`;
            }

            this.props.onSaveRequested(this.props.document, this.props.line, this.editedText, this.boxes);
        }
    }

    resetText() {
        this.boxes.replace(this.originalBoxes);
        this.editedText = this.props.text;
    }

    onToggleBoxes(show) {
        this.showBoxes = show;
    }

    renderInput(box, ix) {
        let text = this.dir === "rtl" ? this.editedTextWords[ this.boxes.length - 1 - ix ] : this.editedTextWords[ ix ];

        text = text || " ";

        let boxWidth = (box.lrx - box.ulx) * this.ratio;
        let textWidth = this.props.measureText(text, this.fontSize);
        let letterSpacing = text.length === 0 ? 1 : ( boxWidth - textWidth ) / text.length;
        let styles = {
            left: box.ulx * this.ratio,
            width: boxWidth,
            letterSpacing: letterSpacing,
            fontSize: this.fontSize
        };

        return (
            <input onChange={ this.onTextChanged.bind(this, ix) }
                  value={ text }
                  onKeyUp={ this.onKeyUp.bind(this, box, ix) }
                  style={ styles }
                  dir={ this.dir }
                  key={ ix }
                  onFocus={ this.onInputFocus.bind(this, box, ix) }
                  className="corpusbuilder-inline-editor-input"
                  />
        );

        return null;
    }

    renderInputs() {
        let ixs = this.boxes.map((_, ix) => { return ix });

        return (
            <div className="corpusbuilder-inline-editor-shell"
                 ref={ this.captureInput.bind(this) }
                 onClick={ this.onShellClick.bind(this) }
                 >
                {
                    ixs.map((ix) => {
                        return this.renderInput(this.boxes[ ix ], ix)
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
                  Hold { PlatformUtils.specialKeyName() } to start drawing or select
                </div>
            }
            let messageBox = null;
            if(this.messages.length > 0) {
                messageBox = (
                            <div className="corpusbuilder-inline-editor-messages"
                                >
                                {
                                    this.messages.map((msg) => {
                                        return <div key={ msg }>{ msg }</div>;
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
                        {
                            boxesHelp
                        }
                        <div className="corpusbuilder-inline-editor-buttons">
                            <Button onClick={ this.deleteLine.bind(this) }
                                    >
                              Delete Line
                            </Button>
                            <Button onToggle={ this.onToggleBoxes.bind(this) }
                              toggles={ true }
                              toggled={ this.showBoxes }
                              visible={ !this.props.showBoxes }
                              >
                              Boxes
                            </Button>
                            <Button onClick={ this.removeBox.bind(this) }
                                    visible={ this.selectedBox !== null && this.selectedBox !== undefined }
                                    >
                              Remove
                            </Button>
                            <Button onClick={ this.resetText.bind(this) }>
                              Reset
                            </Button>
                            <Button onClick={ this.requestSave.bind(this) } disabled={ !this.wordsMatchBoxes }>
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
