import React from 'react';
import { observable, computed } from 'mobx';
import { observer } from 'mobx-react'

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
                <div className="corpusbuilder-document-diff-switcher">
                    { this.renderPager() }
                    <BranchesMenu onBranchSwitch={ this.props.onDiffBranchSwitch.bind(this) }
                                  currentVersion={ this.props.currentDiffVersion }
                                  branches={ this.props.branches }
                                  >
                    </BranchesMenu>
                </div>
                <Button onClick={ () => this.props.onMergeRequested(this.currentVersion) }
                        disabled={ this.props.diff === null || this.props.diff === undefined || this.props.diff.isEmpty }
                        >
                  Merge
                </Button>
            </div>
      );
    }
}
