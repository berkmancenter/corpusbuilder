import React from 'react'

import { computed, observable } from 'mobx';
import { observer } from 'mobx-react'

import { Button } from '../Button';
import { SettingsPage } from '../SettingsPage';
import { PageFlow } from '../PageFlow';
import { PageFlowItem } from '../PageFlowItem';

import s from './AnnotationsSettings.scss'

@observer
export default class AnnotationsSettings extends React.Component {

    @observable
    types = {
    };

    @observable
    currentLevel = 1;

    @computed
    get levels() {
        return [ 1, 2, 3];
    }

    renderLevel(level) {
        return (
            <span onClick={ ( () => { this.currentLevel = this.currentLevel + 1 } ).bind(this) }>Todo: level here</span>
        );
    }

    renderPages() {
        return this.levels.map((level) => {
            return (
                <PageFlowItem isActive={ this.currentLevel === level }>
                    { this.renderLevel(level) }
                </PageFlowItem>
            )
        });
    }

    render() {
        if(!this.props.visible) {
            return null;
        }

        return (
            <SettingsPage title="Annotations" onBackRequest={ this.props.onBackRequest }>
                <PageFlow>
                    { this.renderPages() }
                </PageFlow>
            </SettingsPage>
        );
    }
}
