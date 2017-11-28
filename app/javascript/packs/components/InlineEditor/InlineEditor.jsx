import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { FloatingWindow } from '../FloatingWindow';
import { Button } from '../Button';

import styles from './InlineEditor.scss'

export default class InlineEditor extends React.Component {

    input = null;

    @observable
    editedText = "";

    onTextChanged(e) {
        this.editedText = e.target.value;
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
        this.editedText = props.text;
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

    render() {
        if(this.props.visible) {
            let previewStyles = {
                height: 30,
                width: '100%',
                backgroundImage: 'url(http://46.shariasource.berkman.temphost.net:7946/uploads/web_dewarped-bf6942db-336f-417c-b590-c24731f21519)',
                backgroundSize: 'cover',
                backgroundPositionY: -25
            };

            return (
              <FloatingWindow visible={ this.props.visible }
                              offsetTop={ 20 }
                              onCloseRequested={ this.onCloseRequested.bind(this) }
                              >
                    <div className="corpusbuilder-inline-editor-preview"
                         style={ previewStyles }
                         />
                    <input onChange={ this.onTextChanged.bind(this) }
                           onKeyUp={ this.onEditorKeyUp.bind(this) }
                           value={ this.editedText }
                           ref={ (input) => this.input = input  }
                           />
                    <Button onClick={ this.resetText.bind(this) }>
                      Reset
                    </Button>
                    <Button onClick={ this.requestSave.bind(this) }>
                      Save
                    </Button>
              </FloatingWindow>
            );
        }
        else {
            return null;
        }
    }
}
