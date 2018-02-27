import React from 'react';

import { Button } from '../Button';
import { BranchesMenu } from '../BranchesMenu';
import { SettingsMenu } from '../SettingsMenu';

import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react';
import DropdownMenu, { NestedDropdownMenu } from 'react-dd-menu';
import dropdownMenuStyles from '../../external/react-dd-menu/react-dd-menu.scss';

import s from './DocumentOptions.scss';
import fontAwesome from 'font-awesome/scss/font-awesome.scss';

@observer
export default class DocumentOptions extends React.Component {

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

    menus = { };

    componentDidMount() {
        this._mounted = true;
    }

    componentWillUnmount() {
        this._mounted = false;
    }

    componentWillMount() {
        this.generateMenus();
    }

    componentWillReceiveProps(props) {
        this.generateMenus(props);
    }

    generateMenu(name, titleFn) {
        let title = typeof titleFn == "string" ? titleFn : titleFn();
        let toggled = this.menus[name] !== undefined ? this.menus[name].isOpen : false;
        let opened = this.menus[name] !== undefined ? this.menus[name].isOpen : false;

        return {
            isOpen: opened,
            close: this.close.bind(this, name),
            toggle: <Button toggles={ true }
                            toggled={ toggled}
                            onToggle={this.toggle.bind(this, name)}
                            classes={ [ name ] }
                            >
                            { title }
                    </Button>,
            align: 'left'
        };
    }

    generateMenus(props = this.props) {
        this.menus = {
            view: this.generateMenu('view', 'View'),
            version: this.generateMenu('version', (() => {
                if(this.currentBranch !== null) {
                    let icon = null;
                    if(props.currentVersion.isWorking) {
                      icon = <i className="fa fa-pencil">&nbsp;</i>;
                    }
                    return (
                        <div>
                            <div>Version</div>
                            <span>{ icon } { this.currentBranch.branchName }</span>
                        </div>
                    );
                }
                else {
                    return 'Version';
                }
            }).bind(this)),
            branches: this.generateMenu('branches', (() => {
                if(this.currentBranch !== null) {
                    return `Branch: ${ this.currentBranch.branchName }`;
                }
                else {
                    return 'Branch';
                }
            }).bind(this))
        };
    }

    toggle(menuName) {
        let menu = this.menus[menuName];

        menu.isOpen = !menu.isOpen;

        this.generateMenus();
        this.forceUpdate();
    }

    close(menuName) {
        this.menus[menuName].isOpen = false;
        this.generateMenus();

        if(this._mounted) {
            this.forceUpdate();
        }
    }

    renderViewMenu() {
        return (
          <DropdownMenu {...this.menus.view}>
              <li>
                  <button type="button" onClick={ this.props.onToggleDiff.bind(this, !this.props.showDiff) }>
                      { this.props.showDiff ? '✓' : '' } Changes And Merging
                  </button>
              </li>
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
              <li>
                  <button type="button" onClick={ this.props.onRemoveBranchRequest }
                                        disabled={ this.props.currentVersion.branchVersion.name === 'master' || !this.props.currentVersion.editable }>
                      Remove Branch
                  </button>
              </li>
              <BranchesMenu onBranchSwitch={ this.props.onBranchSwitch.bind(this) }
                            currentVersion={ this.props.currentVersion }
                            branches={ this.props.branches }
                            suffix="Branch: "
                            nested={ true }
                            >
              </BranchesMenu>
          </DropdownMenu>
        );
    }

    renderEdit() {
        if(!this.props.currentVersion.editable) return null;

        return [
            <Button toggles={ true }
                    toggled={ this.props.editing }
                    onToggle={ this.props.onBranchModeToggle.bind(this) }
                    classes={ [ 'edit' ] }
                    key={ 'edit-button' }
                    >
                <i className={ 'fa fa-pencil' }>&nbsp;</i>
                Edit
            </Button>,
            <div key={ 'edit-separator' } className={ 'corpusbuilder-options-separator' }>&nbsp;</div>
        ];
    }

    renderSettings() {
        return <SettingsMenu visible={ false }
                             onStructuralTaggingSettingsRequested={ this.props.onStructuralTaggingSettingsRequested }
                             />;
    }

    render() {
        return (
            <div className="corpusbuilder-document-options">
                { this.renderEdit() }
                { this.renderViewMenu() }
                { this.renderVersionMenu() }

                <div className="corpusbuilder-document-options-aside">
                    { this.renderSettings() }
                </div>
            </div>
        );
    }
}
