import React from 'react';

import { default as Dropdown } from 'react-simple-dropdown';
import { Button } from '../Button';

import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react';
import DropdownMenu, { NestedDropdownMenu } from 'react-dd-menu';
import dropdownMenuStyles from '../../external/react-dd-menu/react-dd-menu.scss';

import s from './DocumentOptions.scss';
import fontAwesome from 'font-awesome/scss/font-awesome.scss';

@observer
export default class DocumentOptions extends React.Component {
    constructor(props) {
        super(props);
    }

    @computed
    get currentBranch() {
        let version = this.props.currentVersion;

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

    @observable
    menus = {
        view: this.generateMenu('view', 'View'),
        version: this.generateMenu('version', 'Version'),
        branches: this.generateMenu('branches', (() => {
            if(this.currentBranch !== null) {
                return `Branch: ${ this.currentBranch.branchName }`;
            }
            else {
                return 'Branch';
            }
        }).bind(this))
    };

    generateMenu(name, titleFn) {
        let title = typeof titleFn == "string" ? titleFn : titleFn();

        return observable({
            isOpen: false,
            close: this.close.bind(this, name),
            toggle: <Button toggles={ true } onToggle={this.toggle.bind(this, name)}>{ title }</Button>,
            align: 'left'
        });
    }

    toggle(menuName) {
        let menu = this.menus[menuName];

        menu.isOpen = !menu.isOpen;
    }

    close(menuName) {
        this.menus[menuName].isOpen = false;
    }

    renderBranchesOptions() {
        let branchVersion = this.props.currentVersion.isBranch ?
          this.props.currentVersion : this.props.currentVersion.branchVersion;
        let currentBranchName = branchVersion.branchName;

        return this.props.branches.map(
            (branch) => {
                return (
                    <li key={ `branch-${ branch.revision_id }` }
                        >
                        <button type="button"
                                onClick={ () => this.props.onBranchSwitch(branch) }
                                >
                            { currentBranchName === branch.name ? `* ${branch.name}` : branch.name }
                        </button>
                    </li>
                );
            }
        );
    }

    renderViewMenu() {
        return (
          <DropdownMenu {...this.menus.view}>
              <li>
                  <button type="button" onClick={ this.props.onToggleBackground.bind(this, !this.props.showBackground) }>
                      { this.props.showBackground ? '✓' : '' } Background Scan
                  </button>
              </li>
              <li>
                  <button type="button" onClick={ this.props.onToggleCertainties.bind(this, !this.props.showCertainties) }>
                      { this.props.showCertainties ? '✓' : '' } Certainty Map
                  </button>
              </li>
              <li>
                  <button type="button" onClick={ this.props.onToggleAnnotations.bind(this, !this.props.showAnnotations) }>
                      { this.props.showAnnotations ? '✓' : '' } Annotations Map
                  </button>
              </li>
          </DropdownMenu>
        );
    }

    renderVersionMenu() {
        return (
          <DropdownMenu {...this.menus.version}>
              <li>
                  <button type="button" onClick={ this.props.onNewBranchRequest }>
                      New Branch
                  </button>
              </li>
              <li>
                  <button type="button" onClick={ this.props.onCommitRequest }>
                      Commit
                  </button>
              </li>
              <li>
                  <button type="button" onClick={ this.props.onResetChangesRequest }>
                      Reset Changes
                  </button>
              </li>
              <NestedDropdownMenu {...this.menus.branches}>
                  { this.renderBranchesOptions() }
              </NestedDropdownMenu>
          </DropdownMenu>
        );
    }

    render() {
        return (
            <div>
                <Button toggles={ true } onToggle={ this.props.onBranchModeToggle.bind(this) } >
                    <i className={ 'fa fa-pencil' }>&nbsp;</i>
                    Edit
                </Button>
                <div className={ 'corpusbuilder-options-separator' }>&nbsp;</div>
                { this.renderViewMenu() }
                { this.renderVersionMenu() }
            </div>
        );
    }
}
