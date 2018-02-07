import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import { Highlight } from '../Highlight';
import { AnnotationsViewer } from '../AnnotationsViewer';

import BoxesUtils from '../../lib/BoxesUtils';

import styles from './Annotations.scss'

@inject('appState')
@observer
export default class Annotations extends React.Component {

    @observable
    highlightedAnnotations = [ ];

    @observable
    selectedAnnotation = null;

    @observable
    chosenAnnotations = [ ];

    @computed
    get document() {
        return this.props.document;
    }

    @computed
    get annotations() {
        return this.props.annotations;
    }

    @computed
    get activeAnnotations() {
        if(this.selectedAnnotation !== null) {
            return [ this.selectedAnnotation ];
        }
        else {
            return this.props.annotations.filter((annotation) => {
                return this.allowedModes.indexOf(annotation.mode) !== -1;
            })
            .sort((a1, a2) => {
                let area1 = a1.areas[0];
                let area2 = a2.areas[0];

                if(area1.uly < area2.uly || ( area1.uly === area2.uly && area1.ulx < area2.ulx)) {
                    return -1;
                }
                else if(area2.uly < area1.uly || ( area2.uly === area1.uly && area2.ulx < area1.ulx)) {
                    return 1;
                }
                else {
                    return 0;
                }
            });
        }
    }

    @computed
    get allowedModes() {
        let modes = [ ];

        if(this.props.showComments) {
            modes.push("comment");
        }

        if(this.props.showCategories) {
            modes.push("category");
        }

        if(this.props.showStructure) {
            modes = modes.concat(["h1", "h2", "h3", "h4", "h5", "p"]);
        }

        return modes;
    }

    @computed
    get surface() {
        return this.document.surfaces.find(
            (surface) => {
                return surface.number == this.props.page;
            }
        );
    }

    @computed
    get surfaceWidth() {
        return this.surface.area.lrx - this.surface.area.ulx;
    }

    @computed
    get ratio() {
        return this.props.width / this.surfaceWidth;
    }

    coordsFor(annotation) {
        return annotation.areas.map((area) => {
            return {
                top: area.uly * this.ratio,
                bottom: area.lry * this.ratio,
                left: area.ulx * this.ratio,
                right: area.lrx * this.ratio
            };
        });
    }

    statusesFor(annotation) {
        let statuses = [ annotation.mode ];

        if(annotation.status === 'conflict') {
            statuses.push('conflict');
        }

        if(this.highlightedAnnotations.indexOf(annotation) !== -1) {
            statuses.push('highlighted');
        }

        if(this.selectedAnnotation === annotation) {
            statuses.push('selected');
        }

        return statuses;
    }

    crossSelectionBy(annotation) {
        return this.activeAnnotations.filter((ann) => {
            if(annotation.surface_number === ann.surface_number) {
                for(let box1 of annotation.areas) {
                    for(let box2 of ann.areas) {
                        if(BoxesUtils.boxesOverlap(box1, box2)) {
                            return true;
                        }
                    }
                }
            }
            return false;
        });
    }

    onHighlightMouseEnter(annotation) {
        this.highlightedAnnotations = this.crossSelectionBy(annotation);
    }

    onHighlightMouseLeave(annotation) {
        this.highlightedAnnotations = [ ];
    }

    onHighlightClick(annotation) {
        this.chosenAnnotations = this.crossSelectionBy(annotation);
    }

    onAnnotationSelected(annotation) {
        this.selectedAnnotation = annotation;
    }

    onAnnotationDeselected() {
        this.selectedAnnotation = null;
    }

    onSaveRequested(annotation, content, mode, payload) {
        if(typeof this.props.onSaveRequested === 'function') {
            this.props.onSaveRequested(annotation, content, mode, payload);
        }
        this.chosenAnnotations = [ ];
        this.selectedAnnotation = null;
    }

    hideAnnotationViewer() {
        this.chosenAnnotations = [ ];
    }

    render() {
        if(!this.props.visible || this.annotations === null || this.annotations === undefined) {
            return null;
        }

        return (
            <div className="corpusbuilder-annotations">
                {
                    this.activeAnnotations.map((annotation, index) => {
                        return (
                            <Highlight key={ `annotation-${index}` }
                                       lineCoords={ this.coordsFor(annotation) }
                                       variantClassName={ this.statusesFor(annotation) }
                                       document={ this.props.document }
                                       mainPageTop={ this.props.mainPageTop }
                                       page={ this.props.page }
                                       width={ this.props.width }
                                       content={ annotation.content }
                                       onMouseEnter={ this.onHighlightMouseEnter.bind(this, annotation) }
                                       onMouseLeave={ this.onHighlightMouseLeave.bind(this, annotation) }
                                       onHighlightClick={ this.onHighlightClick.bind(this, annotation) }
                                       />
                        );
                    })
                }
                <AnnotationsViewer visible={ this.chosenAnnotations.length > 0 }
                                   document={ this.props.document }
                                   annotations={ this.chosenAnnotations }
                                   ratio={ this.ratio }
                                   onAnnotationSelected={ this.onAnnotationSelected.bind(this) }
                                   onAnnotationDeselected={ this.onAnnotationDeselected.bind(this) }
                                   onCloseRequested={ this.hideAnnotationViewer.bind(this) }
                                   onSaveRequested={ this.onSaveRequested.bind(this) }
                                   />
            </div>
        );
    }
}
