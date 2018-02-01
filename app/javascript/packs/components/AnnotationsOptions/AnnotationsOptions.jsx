import React from 'react';
import { observable, computed } from 'mobx';
import { observer } from 'mobx-react'

import { Button } from '../Button';

import styles from './AnnotationsOptions.scss'

@observer
export default class AnnotationsOptions extends React.Component {
    render() {
        return (
            <div className="corpusbuilder-annotations-options">
                <Button onToggle={ (on) => this.props.onToggleComments(on) }
                        toggles={ true }
                        toggled={ this.props.showComments }
                        >
                  Comments
                </Button>
                <Button onToggle={ (on) => this.props.onToggleCategories(on) }
                        toggles={ true }
                        toggled={ this.props.showCategories }
                        >
                  Categories
                </Button>
                <Button onToggle={ (on) => this.props.onToggleStructure(on) }
                        toggles={ true }
                        toggled={ this.props.showStructure }
                        >
                  Structure
                </Button>
                <Button onToggle={ (on) => this.props.onToggleBiography(on) }
                        toggles={ true }
                        toggled={ this.props.showBiography }
                        >
                  Biography
                </Button>
                <Button onToggle={ (on) => this.props.onToggleAnalysis(on) }
                        toggles={ true }
                        toggled={ this.props.showAnalysis }
                        >
                  Analysis
                </Button>
            </div>
      );
    }
}

