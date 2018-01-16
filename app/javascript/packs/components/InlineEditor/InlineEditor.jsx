import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { FloatingWindow } from '../FloatingWindow';
import { Button } from '../Button';
import { Highlight } from '../Highlight';
import { VisualPreview } from '../VisualPreview';
import GraphemeUtils from '../../lib/GraphemesUtils';

import styles from './InlineEditor.scss'

@observer
export default class InlineEditor extends React.Component {

    @observable
    editedText = "";

    @observable
    _showBoxes = false;

    @computed
    get showBoxes() {
        return this.props.showBoxes || this._showBoxes;
    }

    set showBoxes(value) {
        this._showBoxes = true;
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
    get specialKeyName() {
        if ( navigator.appVersion.indexOf("Mac") !== -1) {
            return 'Meta';
        }
        else {
            return 'Ctrl';
        }
    }

    @computed
    get dir() {
        return this.props.line[0].value.codePointAt(0) === 0x200f ? "rtl" : "ltr";
    }

    @computed
    get wordsMatchBoxes() {
        let editedWords = this.editedText.trim().split(/\s+/g).filter((word) => {
            return word.length > 1 || (word.length > 0 && !GraphemeUtils.isCharSpecial(word[0]));
        });

        return editedWords.length === this.boxes.length;
    }

    @computed
    get messages() {
        let result = [];

        if(!this.wordsMatchBoxes) {
            result.push("You must provide the same number of boxes as there are words in the provided text");
        }

        return result;
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

    onTextChanged(e) {
        this.editedText = e.target.value;
    }

    onBoxesReported(boxes) {
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

    render() {
        if(this.props.visible) {
            let boxesHelp = null;
            if(this.showBoxes && this.allowNewBoxes) {
                boxesHelp = <div className="corpusbuilder-inline-editor-help">
                  Hold { this.specialKeyName } to start drawing or select
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
                                       document={ this.props.document }
                                       editable={ true }
                                       boxes={ this.boxes }
                                       showBoxes={ this.showBoxes }
                                       allowNewBoxes={ this.allowNewBoxes }
                                       onBoxesReported={ this.onBoxesReported.bind(this) }
                                       onBoxSelectionChanged={ this.onBoxSelectionChanged.bind(this) }
                                       />
                        <input onChange={ this.onTextChanged.bind(this) }
                               value={ this.editedText }
                               dir={ this.dir }
                               className="corpusbuilder-inline-editor-input"
                               />
                        {
                            boxesHelp
                        }
                        <div className="corpusbuilder-inline-editor-buttons">
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
