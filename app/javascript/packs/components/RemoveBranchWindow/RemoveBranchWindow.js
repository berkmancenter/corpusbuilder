import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { FloatingWindow } from '../FloatingWindow';
import { Button } from '../Button';

import styles from './RemoveBranchWindow.scss';

@inject('appState')
@observer
export default class RemoveBranchWindow extends React.Component {
    requestRemove() {
        if(typeof this.props.onRemoveBranchRequested === 'function') {
            this.props.onRemoveBranchRequested();
        }
    }

    render() {
        if(this.props.currentVersion === null || this.props.currentVersion === undefined) {
            return null;
        }
        else {
            return (
                <FloatingWindow visible={ this.props.visible }
                                offsetTop={ 20 }
                                onCloseRequested={ this.props.onCloseRequested.bind(this) }
                                >
                    <div className={ 'corpusbuilder-remove-branch-window' }>
                      <div className={ 'corpusbuilder-remove-branch-window-info' }>
                        Removing branch <b>{ this.props.currentVersion.branchVersion.branchName }</b>
                        Are you sure you want to do that?
                      </div>
                      <div className={ 'corpusbuilder-remove-branch-window-buttons' }>
                          <Button onClick={ this.requestRemove.bind(this) }>
                            Remove Now
                          </Button>
                      </div>
                    </div>
                </FloatingWindow>
            );
        }
    }
}

