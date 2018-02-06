import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import AnnotationsUtils from '../../lib/AnnotationsUtils';

import { Gravatar } from '../Gravatar';

import styles from './AnnotationView.scss'

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
                </div>
            );
        }

        return null;
    }
}
