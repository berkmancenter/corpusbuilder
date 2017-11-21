import React from 'react';
import state from '../../stores/State'
import * as qwest from 'qwest';
import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'
import { Viewer } from '../Viewer'

import Documents from '../../stores/Documents'
import Metadata from '../../stores/Metadata'
import Mouse from '../../stores/Mouse'

import styles from './WindowManager.scss';

@observer
export default class WindowManager extends React.Component {

    constructor(props) {
        super(props);

        qwest.base = props.baseUrl;
    }

    @computed
    get sharedContext() {
        return {
            documents: new Documents(this.props.baseUrl, state),
            metadata: new Metadata(this.props.baseUrl, state),
            mouse: new Mouse(state)
        };
    }

    @computed
    get allowImage() {
        return this.props.allowImage;
    }

    render() {
        return <div className="corpusbuilder-window-manager">
            <Provider {...this.sharedContext}>
                <div>
                    <div className="corpusbuilder-global-options">
                      <ul className={ 'corpusbuilder-tabs' }>
                        <li className={ 'corpusbuilder-tabs-active' }>Pages</li>
                        <li>Document Info</li>
                        <li>Revisions</li>
                      </ul>
                    </div>
                    <Viewer width={ 445 }
                            key={ 1 }
                            documentId={ this.props.documentId }
                            allowImage={ this.allowImage }
                            />
                    <Viewer width={ 445 }
                            key={ 2 }
                            documentId={ this.props.documentId }
                            allowImage={ this.allowImage }
                            />
                </div>
            </Provider>
        </div>
    }
}
