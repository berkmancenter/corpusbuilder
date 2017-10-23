import React from 'react';
import { inject } from 'mobx-react'

@inject('mouse')
export default class MouseManager extends React.Component {
    componentDidMount() {
        this.setupMouseMovementListener();
    }

    setupMouseMovementListener() {
        document.addEventListener('mousemove', (e) => {
            this.props.mouse.setLastPosition(e.pageX, e.pageY);
        }, false);
    }

    render() {
        return (
          <div>
            { this.props.children }
          </div>
        );
    }
}
