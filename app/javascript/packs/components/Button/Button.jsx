import React from 'react';
import ReactTooltip from 'react-tooltip';

import { observable, computed } from 'mobx';
import { observer } from 'mobx-react';

import styles from './Button.scss';

export default class Button extends React.Component {

    @observable
    toggled = false;

    @computed
    get visible() {
        if(this.props.visible === undefined) {
            return true;
        }

        return this.props.visible;
    }

    componentWillMount() {
        this.initProps(this.props);

        ReactTooltip.rebuild();
    }

    componentWillUpdate(props) {
        this.initProps(props);

        ReactTooltip.rebuild();
    }

    initProps(props) {
        this.toggled = props.toggled || false;
    }

    @computed
    get toggles() {
        return this.props.toggles;
    }

    @computed
    get disabled() {
        return this.props.disabled;
    }

    @computed
    get classes() {
        let ret = [ "corpusbuilder-button" ];

        if(this.toggles && this.toggled) {
            ret.push("corpusbuilder-button-toggled");
        }

        if(this.props.classes !== undefined && this.props.classes !== null) {
            ret = ret.concat(
                this.props.classes.map(
                    (c) => {
                        return `corpusbuilder-button-${c}`;
                    }
                )
            );
        }

        return ret.join(' ');
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
        e.preventDefault()
        e.stopPropagation();
        return false;
    }

    render() {
        if(this.visible) {
            let toggledClassName = this.toggles && this.toggled ? 'corpusbuilder-button-toggled' : '';

            return (
                <button className={ this.classes }
                        onClick={ this.onClick.bind(this) }
                        data-tip={ this.props.tooltip }
                        disabled={ this.disabled ? 'disabled' : '' }
                        >
                    { this.props.children }
                </button>
            );
        }

        return null;
    }
}
