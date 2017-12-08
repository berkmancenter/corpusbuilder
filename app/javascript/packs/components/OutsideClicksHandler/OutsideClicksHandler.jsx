import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

export default class OutsideClicksHandler extends React.Component {

    rootNode = null;

    componentDidMount() {
        this.setupOutsideClickListener();
    }

    nodeWithin(node) {
        if(node === undefined || node === null) {
            return false;
        }
        else if(node === this.rootNode) {
            return true;
        }
        else {
            return this.nodeWithin(node.parentNode);
        }
    }

    setupOutsideClickListener() {
        if(!this.props.onClick) {
            return;
        }

        document.addEventListener('click', (e) => {
            if(this.rootNode !== null && e.target.parentNode !== null && !this.nodeWithin(e.target)) {
                this.props.onClick();
            }
        }, false);
    }

    render() {
        return (
          <div ref={ (div) => this.rootNode = div }>
            { this.props.children }
          </div>
        );
    }
}
