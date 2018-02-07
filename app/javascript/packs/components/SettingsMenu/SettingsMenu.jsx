import React from 'react';

import { Button } from '../Button';

import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react';

import DropdownMenu, { NestedDropdownMenu } from 'react-dd-menu';
import dropdownMenuStyles from '../../external/react-dd-menu/react-dd-menu.scss';

import s from './SettingsMenu.scss';
import fontAwesome from 'font-awesome/scss/font-awesome.scss';

@observer
export default class SettingsMenu extends React.Component {

    @observable
    menu = {
        isOpen: false,
        close: (() => { this.menu.isOpen = false }).bind(this),
        toggle: <Button toggles={ true }
                        onToggle={ (() => { this.menu.isOpen = !this.menu.isOpen }).bind(this) }>
            <i className="fa fa-cog"></i>
        </Button>,
        align: 'left'
    };

    renderOptions() {
        return [
            <li key={ 1 }>
                <button type="button"
                        onClick={ this.props.onStructuralTaggingSettingsRequested }
                        >
                    Structural Tagging
                </button>
            </li>
        ];
    }

    render() {
        if(this.props.nested === true) {
            return (
                <NestedDropdownMenu {...this.menu}>
                    { this.renderOptions() }
                </NestedDropdownMenu>
            );
        }
        else {
            return (
                <DropdownMenu {...this.menu}>
                    { this.renderOptions() }
                </DropdownMenu>
            );
        }
    }
}
