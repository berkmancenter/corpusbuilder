import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import AnnotationsUtils from '../../lib/AnnotationsUtils';

import { Gravatar } from '../Gravatar';
import { Button } from '../Button';

import styles from './AnnotationView.scss'

@inject('editorEmail')
@observer
export default class AnnotationView extends React.Component {

    @computed
    get kind() {
        return AnnotationsUtils.kindOf(this.props.annotation);
    }

    onMouseEnter() {
        if(typeof this.props.onSelected === 'function') {
            this.props.onSelected();
        }
    }

    editAnnotation() {
        console.log("Edit annotation requested");
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
        if(this.props.editorEmail === this.props.annotation.editor_email) {
            return <div className="corpusbuilder-annotation-view-controls">
                <Button toggles={ false }
                        onClick={ this.editAnnotation.bind(this) }
                        >
                  Edit
                </Button>
            </div>
        }

        return null
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
                            this.kind === 'structural' ? this.renderStructural() : this.renderComment()
                        }
                    </div>
                    { this.renderControls() }
                </div>
            );
        }

        return null;
    }
}
