import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { FloatingWindow } from '../FloatingWindow';
import { Button } from '../Button';
import styles from './NewBranchWindow.scss';

@inject('documents')
@observer
export default class NewBranchWindow extends React.Component {
    @observable
    editedName = ""

    @computed
    get parentBranchName() {
        let version = this.props.currentVersion;
        let branch = version.isBranch ? version : version.branchVersion;

        return branch.branchName;
    }

    @computed
    get valid() {
        let branches = this.props.documents.state.branches.get(this.props.document.id);

        if(this.editedName === undefined || branches === undefined) return false;

        let branch = branches.find((b) => {
            return b.name === this.editedName;
        });

        return this.editedName !== "" && (branch === null || branch === undefined);
    }

    onCloseRequested() {
        if(this.props.visible) {
            this.requestClose();
        }
    }

    onTextChanged(e) {
        this.editedName = e.target.value;
    }

    requestClose() {
        if(this.props.onCloseRequested !== undefined && this.props.onCloseRequested !== null) {
            this.props.onCloseRequested();
        }
    }

    requestSave() {
        if(this.props.onSaveRequested !== undefined && this.props.onSaveRequested !== null) {
            this.props.onSaveRequested(this.editedName);
        }
    }

    render() {
        return (
            <FloatingWindow visible={ this.props.visible }
                            offsetTop={ 20 }
                            onCloseRequested={ this.onCloseRequested.bind(this) }
                            >
                <div className={ 'corpusbuilder-new-branch-window' }>
                  <div className={ 'corpusbuilder-new-branch-window-info' }>
                    Branching off of the <b>{ this.parentBranchName }</b> branch. Please provide the name
                    for the new branch below:
                  </div>
                  <div>
                      <input onChange={ this.onTextChanged.bind(this) }
                            value={ this.editedName }
                            />
                  </div>
                  <div className={ 'corpusbuilder-new-branch-window-buttons' }>
                      <Button onClick={ this.requestSave.bind(this) } disabled={ !this.valid }>
                        Save
                      </Button>
                  </div>
                </div>
            </FloatingWindow>
        );
    }
}
