import React from 'react'

import { computed, observable } from 'mobx';
import { observer } from 'mobx-react'

import s from './PageFlowItem.scss'

@observer
export default class PageFlowItem extends React.Component {
    render() {
        return (
            <div className="corpusbuilder-pageflow-item">
                { this.props.children }
            </div>
        );
    }
}
