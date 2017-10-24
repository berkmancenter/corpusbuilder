import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import { OutsideClicksHandler } from '../OutsideClicksHandler'

import styles from './PopupMenu.scss'

@inject('mouse')
@observer
export default class PopupMenu extends React.Component {

    lastPositionWhenInvisible = null;

    @computed
    get mousePosition() {
        if(this.lastPositionWhenInvisible === null) {
            this.lastPositionWhenInvisible = this.props.mouse.lastPosition();
        }

        return this.lastPositionWhenInvisible;
    }

    onOutsideClicked() {
      if(this.props.visible) {
        this.props.onClickedOutside();
      }
    }

    render() {
        if(!this.props.visible) {
            this.lastPositionWhenInvisible = null;
            return null;
        }

        let styles = {
            top: this.mousePosition.y,
            left: this.mousePosition.x
        };

        return (
          <OutsideClicksHandler onClick={ this.onOutsideClicked.bind(this) }>
            <div className="corpusbuilder-popup-menu"
                style={ styles }
                >
              { this.props.children }
            </div>
          </OutsideClicksHandler>
        );
    }
}
