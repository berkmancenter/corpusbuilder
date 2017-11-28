import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { Highlight } from '../Highlight';

import styles from './Annotations.scss'

@inject('metadata')
@observer
export default class Annotations extends React.Component {

    @computed
    get document() {
        return this.props.document;
    }

    @computed
    get annotations() {
        return this.props.metadata.annotations(
            this.props.document.id,
            this.props.branchName
        );
    }

    @computed
    get page() {
        return this.props.page;
    }

    @computed
    get surface() {
        return this.document.surfaces.find(
            (surface) => {
                return surface.number == this.page;
            }
        );
    }

    @computed
    get graphemes() {
        return this.surface.graphemes;
    }

    annotationGraphemes(ids) {
        let firstId = ids[0];
        let lastId  = ids[ids.length - 1];
        let sawFirst = false;
        let sawLast = false;

        return this.graphemes.filter((grapheme) => {
            if(sawLast) {
                return false;
            }

            if(grapheme.id === firstId) {
                sawFirst = true;
            }

            if(grapheme.id === lastId) {
                sawLast = true;
            }

            if(sawFirst) {
                return true;
            }
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
                                       graphemes={ this.annotationGraphemes(annotation.graphemeIds) }
                                       document={ this.props.document }
                                       mainPageTop={ this.props.mainPageTop }
                                       page={ this.props.page }
                                       width={ this.props.width }
                                       content={ annotation.text }
                                       />
                        );
                    })
                }
            </div>
        );
    }
}
