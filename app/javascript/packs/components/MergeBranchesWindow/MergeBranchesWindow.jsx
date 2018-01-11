import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { FloatingWindow } from '../FloatingWindow';
import { Button } from '../Button';

import styles from './MergeBranchesWindow.scss';

@inject('appState')
@observer
export default class MergeBranchesWindow extends React.Component {
    requestMerge() {
        if(typeof this.props.onMergeRequested === 'function') {
            this.props.onMergeRequested();
        }
    }

    render() {
        if(this.props.currentVersion === null || this.props.currentVersion === undefined ||
           this.props.otherVersion   === null || this.props.otherVersion   === undefined ) {
            return null;
        }
        else {
            return (
                <FloatingWindow visible={ this.props.visible }
                                offsetTop={ 20 }
                                onCloseRequested={ this.props.onCloseRequested.bind(this) }
                                >
                    <div className={ 'corpusbuilder-merge-branches-window' }>
                      <div className={ 'corpusbuilder-merge-branches-window-info' }>
                        Merging <b>{ this.props.currentVersion.branchVersion.branchName }</b>
                        with the <b>{ this.props.otherVersion.branchVersion.branchName }</b>.
                        Are you sure you want to do that?
                      </div>
                      <div className={ 'corpusbuilder-merge-branches-window-buttons' }>
                          <Button onClick={ this.requestMerge.bind(this) }>
                            Merge Now
                          </Button>
                      </div>
                    </div>
                </FloatingWindow>
            );
        }
    }
}
