import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { Highlight } from '../Highlight';

import styles from './Annotations.scss'

@inject('appState')
@observer
export default class Annotations extends React.Component {

    @computed
    get document() {
        return this.props.document;
    }

    @computed
    get annotations() {
        return this.props.annotations;
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

    render() {
        if(!this.props.visible || this.annotations === null || this.annotations === undefined) {
            return null;
        }

        return (
            <div className="corpusbuilder-annotations">
                {
                    this.annotations.map((annotation, index) => {
                        return (
                            <Highlight key={ `annotation-${index}` }
                                       lineCoords={ this.coordsFor(annotation) }
                                       document={ this.props.document }
                                       mainPageTop={ this.props.mainPageTop }
                                       page={ this.props.page }
                                       width={ this.props.width }
                                       content={ annotation.content }
                                       />
                        );
                    })
                }
            </div>
        );
    }
}
