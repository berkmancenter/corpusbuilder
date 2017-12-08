import React from 'react';
import { observable, computed } from 'mobx';
import { observer } from 'mobx-react';
import styles from './Button.scss';

export default class Button extends React.Component {

    @observable
    visible = true;

    componentWillMount() {
        this.toggled = this.props.toggled || false;
        this.visible = this.props.visible === undefined ? true : this.props.visible;
    }

    componentWillUpdate(props) {
        this.toggled = props.toggled || false;
        this.visible = props.visible === undefined ? true : props.visible;
    }

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
        if(this.visible) {
            return (
                <button className={ `corpusbuilder-button ${ this.toggles && this.toggled ? 'corpusbuilder-button-toggled' : '' }` } onClick={ this.onClick.bind(this) }>
                    { this.props.children }
                </button>
            );
        }

        return null;
    }
}
