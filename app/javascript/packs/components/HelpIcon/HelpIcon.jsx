import React from 'react'
import ReactTooltip from 'react-tooltip';

import styles from './HelpIcon.scss'

export default class HelpIcon extends React.Component {
    componentWillMount() {
        setTimeout(function() {
            ReactTooltip.rebuild();
        }, 200);
    }

    componentWillUpdate(props) {
        setTimeout(function() {
            ReactTooltip.rebuild();
        }, 200);
    }

    render() {
        return (
            <span className="corpusbuilder-help-icon"
                  data-tip={ this.props.message }
              >
              ?
            </span>
        );
    }
}
