import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import styles from './PopupMenu.scss'

@inject('mouse')
@observer
export default class PopupMenu extends React.Component {

    menuDomNode = null;
    lastPositionWhenInvisible = null;

    @computed
    get mousePosition() {
        if(this.lastPositionWhenInvisible === null) {
            this.lastPositionWhenInvisible = this.props.mouse.lastPosition();
        }

        return this.lastPositionWhenInvisible;
    }

    componentDidMount() {
        this.setupOutsideClickListener();
    }

    nodeWithinMenu(node) {
        if(node === undefined || node === null) {
            return false;
        }
        else if(node === this.menuDomNode) {
            return true;
        }
        else {
            return this.nodeWithinMenu(node.parentNode);
        }
    }

    setupOutsideClickListener() {
        if(!this.props.onClickedOutside) {
            return;
        }

        document.addEventListener('click', (e) => {
            if(this.props.visible && !this.nodeWithinMenu(e.target)) {
                this.props.onClickedOutside();
            }
        }, true);
    }

    render() {
        if(!this.props.visible) {
            this.lastPositionWhenInvisible = null;
            return null;
        }

        let styles = {
            top: this.mousePosition.y - 50,
            left: this.mousePosition.x - 50
        };

        return (
          <div className="corpusbuilder-popup-menu"
               style={ styles }
               ref={ (div) => this.menuDomNode = div }
               >
            { this.props.children }
          </div>
        );
    }
}
