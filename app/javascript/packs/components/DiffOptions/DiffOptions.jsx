import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import { BranchesMenu } from '../BranchesMenu';
import { Button } from '../Button';

import styles from './DiffOptions.scss'

@observer
export default class DiffOptions extends React.Component {
    @computed
    get countPages() {
        if(this.props.diff === null || this.props.diff === undefined) {
            return 0;
        }

        return this.props.diff.pages.length;
    }

    @computed
    get showsWorkingData() {
        return this.props.currentVersion.isWorking;
    }

    @computed
    get hasDifferentVersions() {
        return this.props.currentVersion !== null &&
            this.props.currentDiffVersion !== null &&
            this.props.currentVersion.branchVersion.identifier !== this.props.currentDiffVersion.branchVersion.identifier;
    }

    @computed
    get hasWorkingDiff() {
        return this.props.currentVersion !== null &&
            this.props.currentDiffVersion !== null &&
            this.props.currentVersion.identifier === this.props.currentDiffVersion.workingVersion.identifier;
    }

    renderPager() {
        if(this.props.diff === null || this.props.diff === undefined) {
            return <span>Computing the differences between the branch:</span>;
        }
        else if(this.props.diff.isEmpty) {
            return <span>No differences found between the branch:</span>
        }
        else {
            return [
                <Button key={ 2 } onClick={ () => this.props.onDiffSwitch(1) }
                        disabled={ this.props.page == 1 }
                        >
                  { '❙◀' }
                </Button>,
                <Button key={ 3 } onClick={ () => this.props.onDiffSwitch(this.props.page - 1) }
                        disabled={ this.props.page == 1 }
                        >
                  { '◀' }
                </Button>,
                <span key={ 4 }> { this.props.page } / { this.countPages } </span>,
                <Button key={ 5 } onClick={ () => this.props.onDiffSwitch(this.props.page + 1) }
                        disabled={ this.props.page == this.countPages }
                        >
                  { '▶' }
                </Button>,
                <Button key={ 6 } onClick={ () => this.props.onDiffSwitch(this.countPages) }
                        disabled={ this.props.page == this.countPages }
                        >
                  { '▶❙' }
                </Button>,
                <span key={ 7 }>between:</span>
            ]
        }
    }

    render() {
        return (
            <div className="corpusbuilder-diff-options">
                <div style={ { display: "none" } } className="corpusbuilder-diff-options-layers">
                    <span>Show differences in:&nbsp;</span>
                    <Button onClick={ () => { console.log('click!') } }
                            toggles={ true }
                            >
                        Words
                    </Button>
                    <Button onClick={ () => { console.log('click!') } }
                            toggles={ true }
                            >
                        Structure
                    </Button>
                </div>
                <div className="corpusbuilder-document-diff-switcher">
                    <div>
                        { this.renderPager() }
                    </div>
                    <div className="corpusbuilder-diff-options-branches">
                        <BranchesMenu onBranchSwitch={ this.props.onDiffBranchSwitch.bind(this) }
                                      currentVersion={ this.props.currentDiffVersion }
                                      branches={ this.props.branches }
                                      >
                        </BranchesMenu>
                    </div>
                    <div className="corpusbuilder-diff-options-buttons">
                        <Button onClick={ () => this.props.onMergeRequested(this.currentVersion) }
                                visible={ this.hasDifferentVersions && !this.showsWorkingData }
                                disabled={ this.props.diff === null || this.props.diff === undefined || this.props.diff.isEmpty || this.props.document.global.count_conflicts > 0 || !this.props.currentVersion.editable }
                                >
                          Merge
                        </Button>
                        <Button onClick={ () => this.props.onCommitRequested(this.currentVersion) }
                                visible={ this.hasWorkingDiff }
                                disabled={ this.props.diff === null || this.props.diff === undefined || this.props.diff.isEmpty || this.props.document.global.count_conflicts > 0 }
                                >
                          Commit
                        </Button>
                    </div>
                </div>
            </div>
      );
    }
}
