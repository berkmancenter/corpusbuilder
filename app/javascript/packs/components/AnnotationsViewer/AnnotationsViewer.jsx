import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import { FloatingWindow } from '../FloatingWindow';
import { AnnotationView } from '../AnnotationView';
import { Highlight } from '../Highlight';

import styles from './AnnotationsViewer.scss'

@observer
export default class AnnotationsViewer extends React.Component {

    onClickedOutside() {
        if(this.props.visible) {
            if(typeof this.props.onCloseRequested === 'function') {
                this.props.onCloseRequested();
            }
        }
    }

    onAnnotationSelected(annotation) {
        if(typeof this.props.onAnnotationSelected === 'function') {
            this.props.onAnnotationSelected(annotation);
        }
    }

    deselectAnnotation() {
        if(typeof this.props.onAnnotationDeselected === 'function') {
            this.props.onAnnotationDeselected();
        }
    }

    coordsFor(annotation) {
        if(this.selectedAnnotation === null) {
            return [ ];
        }

        return this.selectedAnnotation.areas.map((area) => {
            return {
                top: area.uly * this.props.ratio,
                bottom: area.lry * this.props.ratio,
                left: area.ulx * this.props.ratio,
                right: area.lrx * this.props.ratio
            };
        });
    }

    render() {
        if(this.props.visible) {
            return (
                <div className="corpusbuilder-annotations-viewer">
                    <FloatingWindow visible={ this.props.visible }
                                    onCloseRequested={ this.onClickedOutside.bind(this) }
                                    >
                        <div className="corpusbuilder-annotations-viewer-window"
                             onMouseLeave={ this.deselectAnnotation.bind(this) }
                             >
                            {
                                this.props.annotations.map((annotation, index) => {
                                    return <AnnotationView visible={ true }
                                                           annotation={ annotation }
                                                           onSelected={ this.onAnnotationSelected.bind(this, annotation) }
                                                           key={ index }
                                                           />
                                })
                            }
                        </div>
                    </FloatingWindow>
                </div>
            );
        }

        return null;
    }
}
