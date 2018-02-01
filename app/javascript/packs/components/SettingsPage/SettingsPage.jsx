import React from 'react'

import { computed, observable } from 'mobx';
import { observer } from 'mobx-react'

import { Button } from '../Button';

import s from './SettingsPage.scss'

@observer
export default class SettingsPage extends React.Component {
    render() {
        return (
            <div className="corpusbuilder-settings-page">
                <div className="corpusbuilder-settings-page-header">
                    Settings: { this.props.title }
                    <div className="corpusbuilder-settings-page-header-controls">
                        <Button onClick={ this.props.onBackRequest }
                                >
                            <i className={ 'fa fa-window-close' }>&nbsp;</i>
                        </Button>
                    </div>
                </div>

                { this.props.children }
            </div>
        );
    }
}

