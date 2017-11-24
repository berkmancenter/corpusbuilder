import React from 'react';
import { observable, computed } from 'mobx';
import { observer } from 'mobx-react';
import styles from './Button.scss';

export default class Button extends React.Component {

    @computed
    get toggles() {
        return this.props.toggles;
    }

    @observable
    toggled = false;

    onClick(e) {
        if(this.props.onClick !== undefined && this.props.onClick !== null) {
            this.props.onClick(e);
        }

        if(this.toggles) {
            this.toggled = !this.toggled;

            if(this.props.onToggle !== undefined && this.props.onToggle !== null) {
                this.props.onToggle(this.toggled);
            }
        }
    }

    render() {
        return (
            <button className={ 'corpusbuilder-button' } onClick={ this.onClick.bind(this) }>
                { this.props.children }
            </button>
        );
    }
}
