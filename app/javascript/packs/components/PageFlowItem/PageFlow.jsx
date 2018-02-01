import React from 'react'

import { computed, observable } from 'mobx';
import { observer } from 'mobx-react'

import s from './PageFlow.scss'

@observer
export default class PageFlow extends React.Component {
    render() {
        return (
            <div className="corpusbuilder-pageflow">
                { this.props.children }
            </div>
        );
    }
}
