import React from 'react';

import { default as Dropdown } from 'react-simple-dropdown'
import { DropdownTrigger, DropdownContent } from 'react-simple-dropdown'
import { Button } from '../Button';

import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'

import s from './DocumentOptions.scss'
import dropdownStyles from 'react-simple-dropdown/styles/Dropdown.css'
import fontAwesome from 'font-awesome/scss/font-awesome.scss'

export default class DocumentOptions extends React.Component {
    constructor(props) {
        super(props);
    }

    @computed
    get currentBranchMode() {
        return this.props.currentBranchMode;
    }

    render() {
        let branchesOptions = this.props.branches.map(
            (branch) => {
                return (
                    <li key={ `branch-${ branch.revision_id }` }
                        onClick={ () => this.props.onBranchSwitch(branch) }
                        >
                        { this.props.currentBranch === branch.name ? `➜ ${branch.name}` : branch.name }
                    </li>
                );
            }
        );

        return (
            <div>
                <Button toggles={ true } onToggle={ this.props.onBranchModeToggle.bind(this) } >
                    <i className={ 'fa fa-pencil' }>&nbsp;</i>
                </Button>
                <div className={ 'corpusbuilder-options-separator' }>&nbsp;</div>
                <Dropdown>
                    <DropdownTrigger>
                        <i className={ 'fa fa-code-fork' } aria-hidden="true"></i>
                        &nbsp;
                        Branch: <b>{ this.props.currentBranch }</b>
                    </DropdownTrigger>
                    <DropdownContent>
                        <ul>
                          { branchesOptions }
                        </ul>
                    </DropdownContent>
                </Dropdown>
                <div className={ 'corpusbuilder-options-separator' }>&nbsp;</div>
                <Button toggles={ true } onToggle={ this.props.onToggleCertainties.bind(this) } >
                    <i className={ 'fa fa-map-o' }>&nbsp;</i>
                </Button>
                <Button toggles={ true } onToggle={ this.props.onToggleAnnotations.bind(this) } >
                    <i className={ 'fa fa-commenting' }>&nbsp;</i>
                </Button>
                <Button toggles={ true } onToggle={ this.props.onToggleBackground.bind(this) } >
                    <i className={ 'fa fa-file-image-o' }>&nbsp;</i>
                </Button>
            </div>
        );
    }
}
