import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import AnnotationsUtils from '../../lib/AnnotationsUtils';

import { Gravatar } from '../Gravatar';
import { Button } from '../Button';
import { AnnotationEditor } from '../AnnotationEditor';

import styles from './AnnotationView.scss'

@inject('editorEmail')
@observer
export default class AnnotationView extends React.Component {

    @observable
    editing = false;

    @computed
    get kind() {
        return AnnotationsUtils.kindOf(this.props.annotation);
    }

    onMouseEnter() {
        if(typeof this.props.onSelected === 'function') {
            this.props.onSelected();
        }
    }

    onEditorCancel() {
        this.editing = false;
    }

    onSave(selection, content, mode, payload) {
        if(typeof this.props.onSaveRequested === 'function') {
            this.props.onSaveRequested(this.props.annotation, content, mode, payload);
        }
        this.editing = false;
    }

    editAnnotation() {
        this.editing = true;
    }

    renderStructural() {
        return (
            <b>{ AnnotationsUtils.title(this.props.annotation) }</b>
        );
    }

    renderComment() {
        return [
            <span key={ 1 }>{ AnnotationsUtils.title(this.props.annotation) }:</span>,
            <div className="corpusbuilder-annotation-view-body-comment" key={ 2 }>
              { this.props.annotation.content }
            </div>
        ]
    }

    renderControls() {
        if(!this.editing && this.props.editorEmail === this.props.annotation.editor_email) {
            return (
              <div className="corpusbuilder-annotation-view-controls">
                  <Button toggles={ false }
                          onClick={ this.editAnnotation.bind(this) }
                          >
                    Edit
                  </Button>
              </div>
            );
        }

        return null;
    }

    renderBody() {
        if(this.editing) {
            return <AnnotationEditor visible={ true }
                                     inline={ true }
                                     document={ this.props.document }
                                     annotation={ this.props.annotation }
                                     onCancel={ this.onEditorCancel.bind(this) }
                                     onSaveRequested={ this.onSave.bind(this) }
                                     />;
        }
        else {
            return this.kind === 'structural' ? this.renderStructural() : this.renderComment();
        }
    }

    render() {
        if(this.props.visible) {
            return (
                <div className="corpusbuilder-annotation-view"
                     onMouseEnter={ this.onMouseEnter.bind(this) }
                     >
                    <div className="corpusbuilder-annotation-view-author">
                        <Gravatar visible={ true }
                                  email={ this.props.annotation.editor_email }
                                  />
                    </div>
                    <div className="corpusbuilder-annotation-view-body">
                        {
                            this.renderBody()
                        }
                    </div>
                    { this.renderControls() }
                </div>
            );
        }

        return null;
    }
}
