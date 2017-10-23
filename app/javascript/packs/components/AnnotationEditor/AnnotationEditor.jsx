import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import styles from './AnnotationEditor.scss'

@inject('mouse')
@observer
export default class AnnotationEditor extends React.Component {

    lastPositionWhenInvisible = null;

    @computed
    get mousePosition() {
        if(this.lastPositionWhenInvisible === null) {
            this.lastPositionWhenInvisible = this.props.mouse.lastPosition();
        }

        return this.lastPositionWhenInvisible;
    }

    requestClose() {
        if(this.props.onCloseRequested !== undefined && this.props.onCloseRequested !== null) {
            this.props.onCloseRequested();
        }
    }

    onAnnotationChanged(value) {
    }

    onAnnotateEditorCancel() {
    }

    onAnnotateEditorSave() {
    }

    render() {
        if(!this.props.visible) {
            return null;
        }

        let styles = {
          top: this.mousePosition.y
        };

        return (
            <div className="corpusbuilder-annotation-editor"
                 style={ styles }
                 >
                <span>Annotate fragment:</span>
                <b>CTRL-Enter to save</b>
                <textarea onChange={ this.onAnnotationChanged.bind(this) }
                          value={ this.editedAnnotation }
                          rows="5">
                </textarea>
            </div>
        );
    }
}
