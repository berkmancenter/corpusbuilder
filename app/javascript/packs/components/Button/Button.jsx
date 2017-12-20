import React from 'react';
import { observable, computed } from 'mobx';
import { observer } from 'mobx-react';
import styles from './Button.scss';

export default class Button extends React.Component {

    @observable
    visible = true;

    @observable
    toggled = false;

    componentWillMount() {
        this.initProps(this.props);
    }

    componentWillUpdate(props) {
        this.initProps(props);
    }

    initProps(props) {
        this.toggled = this.toggled || props.toggled || false;
        this.visible = props.visible === undefined ? true : props.visible;
    }

    @computed
    get toggles() {
        return this.props.toggles;
    }

    @computed
    get disabled() {
        return this.props.disabled;
    }

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
        if(this.visible) {
            let toggledClassName = this.toggles && this.toggled ? 'corpusbuilder-button-toggled' : '';
            let className = `corpusbuilder-button ${ toggledClassName }`;

            return (
                <button className={ className }
                        onClick={ this.onClick.bind(this) }
                        disabled={ this.disabled ? 'disabled' : '' }
                        >
                    { this.props.children }
                </button>
            );
        }

        return null;
    }
}
