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
            return <span>Changes between:</span>;
        }

        return [
            <span key={ 1 }>Changes:</span>,
            <Button key={ 2 } onClick={ () => this.props.onDiffSwitch(1) }
                    disabled={ this.props.page == 1 }
                    >
              { '❙◀' }
            </Button>,
            <Button key={ 3 } onClick={ () => this.props.onDiffSwitch(this.page - 1) }
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

    render() {
        return (
            <div className="corpusbuilder-document-diff-switcher">
                { this.renderPager() }
                <BranchesMenu onBranchSwitch={ this.props.onDiffBranchSwitch.bind(this) }
                              currentVersion={ this.props.currentDiffVersion }
                              branches={ this.props.branches }
                              >
                </BranchesMenu>
            </div>
      );
    }
}
