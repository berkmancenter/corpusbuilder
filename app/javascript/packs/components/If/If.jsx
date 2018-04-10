import React from 'react';

export default class If extends React.Component {
    render() {
        if(this.props.cond) {
            return this.props.children;
        }

        return null;
    }
}
