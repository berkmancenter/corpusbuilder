import React from 'react';

import { Button } from '../Button';

import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react';
import DropdownMenu, { NestedDropdownMenu } from 'react-dd-menu';
import dropdownMenuStyles from '../../external/react-dd-menu/react-dd-menu.scss';

import s from './BranchesMenu.scss';
import fontAwesome from 'font-awesome/scss/font-awesome.scss';

@observer
export default class BranchesMenu extends React.Component {

    @observable
    currentVersion = null;

    @computed
    get currentBranch() {
        let version = this.currentVersion;

        if(version === null) {
            return null;
        }

        if(version.isBranch) {
            return version;
        }
        else {
            if(version.knowsParentBranch) {
                return version.branchVersion;
            }
            else {
                return null;
            }
        }
    }

    @computed
    get label() {
        if(this.currentBranch === null) {
            return '---';
        }

        if(this.props.suffix !== undefined) {
            return `${ this.props.suffix }${ this.currentBranch.branchName }`;
        }
        else {
            return this.currentBranch.branchName;
        }
    }

    @observable
    menu = null;

    generateMenu() {
        this.menu = {
            isOpen: this.menu === null ? false : this.menu.isOpen,
            close: (() => { this.menu.isOpen = false }).bind(this),
            toggle: <Button toggles={ true }
                            onToggle={ (() => { this.menu.isOpen = !this.menu.isOpen }).bind(this) }>
                { this.label }
            </Button>,
            align: 'left'
        };
    }

    componentWillUpdate(props) {
        if(this.currentVersion !== props.currentVersion) {
            this.currentVersion = props.currentVersion;
            this.generateMenu();
        }
    }

    componentWillMount() {
        if(this.currentVersion !== this.props.currentVersion) {
            this.currentVersion = this.props.currentVersion;
            this.generateMenu();
        }
    }

    renderBranchesOptions() {
        let currentBranchName = this.currentBranch === null ? '---' : this.currentBranch.branchName;

        return (this.props.branches || []).map(
            (branch) => {
                let selectionIcon = null;

                if(currentBranchName !== branch.name) {
                    selectionIcon = <span className="corpusbuilder-document-options-selection">
                        &nbsp;
                    </span>;
                }
                else {
                    selectionIcon = <span className="corpusbuilder-document-options-selection">
                        <i className="fa fa-check" aria-hidden="true"></i>&nbsp;
                    </span>;
                }

                let editabilityIcon = branch.editable ? null :
                    <span className="corpusbuilder-document-options-editability">
                        &nbsp;<i className="fa fa-lock" aria-hidden="true"></i>
                    </span>;

                return (
                    <li key={ `branch-${ branch.revision_id }` }
                        >
                        <button type="button"
                                onClick={ () => this.props.onBranchSwitch(branch) }
                                >
                            { selectionIcon }
                            { branch.name }
                            { editabilityIcon }
                        </button>
                    </li>
                );
            }
        );
    }

    render() {
        if(this.props.nested === true) {
            return (
                <NestedDropdownMenu {...this.menu}>
                    { this.renderBranchesOptions() }
                </NestedDropdownMenu>
            );
        }
        else {
            return (
                <DropdownMenu {...this.menu}>
                    { this.renderBranchesOptions() }
                </DropdownMenu>
            );
        }
    }
}
