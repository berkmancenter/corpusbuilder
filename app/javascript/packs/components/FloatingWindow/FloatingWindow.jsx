import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { OutsideClicksHandler } from '../OutsideClicksHandler'

import styles from './FloatingWindow.scss';

@inject('mouse')
@observer
export default class FloatingWindow extends React.Component {

    lastPositionWhenInvisible = null;

    @computed
    get offsetTop() {
        return this.props.offsetTop || 0;
    }

    @computed
    get mousePosition() {
        if(this.lastPositionWhenInvisible === null) {
            this.lastPositionWhenInvisible = this.props.mouse.lastPosition();
        }

        return this.lastPositionWhenInvisible;
    }

    @computed
    get adjustedTop() {
        return this.mousePosition.y + this.offsetTop;
    }

    onClickedOutside() {
        if(this.props.visible) {
            this.requestClose();
        }
    }

    requestClose() {
        if(this.props.onCloseRequested !== undefined && this.props.onCloseRequested !== null) {
            this.props.onCloseRequested();
        }
    }

    render() {
        if(!this.props.visible) {
            this.lastPositionWhenInvisible = null;
            return null;
        }

        let styles = {
          top: this.adjustedTop - 50
        };

        return (
            <div className="corpusbuilder-floating-window-canvas">
                <OutsideClicksHandler onClick={ this.onClickedOutside.bind(this) }>
                    <div className="corpusbuilder-floating-window" style={ styles }>
                        { this.props.children }
                    </div>
                </OutsideClicksHandler>
            </div>
        );
    }
}
