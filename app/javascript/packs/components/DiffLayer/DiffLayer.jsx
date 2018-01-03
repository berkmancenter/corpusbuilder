import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { Highlight } from '../Highlight';

import styles from './DiffLayer.scss'

export default class DiffLayer extends React.Component {
    render() {
        if(this.props.visible) {
            return (
                <div className="corpusbuilder-diff">
                    {
                        this.props.diffWords.map((diffWord, index) => {
                            return (
                                <Highlight key={ `diff-${index}` }
                                           variantClassName={ diffWord.status }
                                           graphemes={ diffWord.graphemes }
                                           document={ this.props.document }
                                           mainPageTop={ this.props.mainPageTop }
                                           page={ this.props.page }
                                           width={ this.props.width }
                                           content={ diffWord.text }
                                           />
                            );
                        })
                    }
                </div>
            )
        }
        else {
            return null;
        }
    }
}
