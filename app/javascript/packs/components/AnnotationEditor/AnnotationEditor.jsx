import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import { OutsideClicksHandler } from '../OutsideClicksHandler'
import { Highlight } from '../Highlight';

import styles from './AnnotationEditor.scss'

@inject('mouse')
@observer
export default class AnnotationEditor extends React.Component {

    lastPositionWhenInvisible = null;
    textArea = null;

    @observable
    editedAnnotation = "";

    @computed
    get mousePosition() {
        if(this.lastPositionWhenInvisible === null) {
            this.lastPositionWhenInvisible = this.props.mouse.lastPosition();
        }

        return this.lastPositionWhenInvisible;
    }

    @computed
    get adjustedTop() {
        return this.mousePosition.y;
    }

    requestClose() {
        if(this.props.onCloseRequested !== undefined && this.props.onCloseRequested !== null) {
            this.props.onCloseRequested();
        }
    }

    onClickedOutside() {
        if(this.props.visible) {
            this.editedAnnotation = "";
            this.requestClose();
        }
    }

    onAnnotationChanged(e) {
        this.editedAnnotation = e.target.value;
    }

    onEditorKeyUp(e) {
        if(e.ctrlKey && e.keyCode == 13) {
            this.onAnnotateEditorSave();
        }
    }

    onAnnotateEditorSave() {
        this.requestClose();

        if(this.props.onSaveRequested !== null && this.props.onSaveRequested !== undefined) {
            this.props.onSaveRequested(this.editedAnnotation);
        }

        this.editedAnnotation = "";
    }

    render() {
        if(!this.props.visible) {
            this.lastPositionWhenInvisible = null;
            return null;
        }

        let styles = {
          top: this.adjustedTop
        };

        setTimeout(() => {
            if(this.textArea !== null && this.textArea !== null) {
                this.textArea.focus();
            }
        }, 100)

        return (
          <OutsideClicksHandler onClick={ this.onClickedOutside.bind(this) }>
            <div className="corpusbuilder-annotation-editor"
                 style={ styles }
                 >
                <span>Annotate fragment:</span>
                <b>CTRL-Enter to save</b>
                <textarea onChange={ this.onAnnotationChanged.bind(this) }
                          onKeyUp={ this.onEditorKeyUp.bind(this) }
                          value={ this.editedAnnotation }
                          ref={ (textArea) => this.textArea = textArea  }
                          rows="5">
                </textarea>
            </div>
            <Highlight graphemes={ this.props.graphemes }
                       document={ this.props.document }
                       page={ this.props.page }
                       width={ this.props.width }
                       mainPageTop={ this.props.mainPageTop }
                       />
          </OutsideClicksHandler>
        );
    }
}
