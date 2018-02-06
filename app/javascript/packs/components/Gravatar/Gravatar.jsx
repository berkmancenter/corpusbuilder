import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import md5 from 'blueimp-md5';
import styles from './Gravatar.scss'

@observer
export default class Gravatar extends React.Component {

    @computed
    get src() {
       return `http://www.gravatar.com/avatar/${ md5(this.props.email) }?s=32`;
    }

    render() {
        if(this.props.visible) {
            return <img className="corpusbuilder-gravatar" src={ this.src } />
        }

        return null;
    }
}
