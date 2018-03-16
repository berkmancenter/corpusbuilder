import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react';
import Spinner from 'react-spinkit';
import styles from './ProgressIndicator.scss';

@inject('appState')
@observer
export default class ProgressIndicator extends React.Component {

    processes = [];

    constructor(props) {
        super(props);

        for(let eventDescriptor of props.events) {
            this.props.appState.on(eventDescriptor.name + ':start', ((_) => {
                this.processes.push(eventDescriptor);
                this.refresh();
            }).bind(this));

            this.props.appState.on(eventDescriptor.name + ':end', ((_) => {
               this.processes = this.processes.filter((e) => {
                   return e.name !== eventDescriptor.name;
               });
               this.refresh();
            }).bind(this));
        }
    }

    refresh() {
        setTimeout(this.forceUpdate.bind(this));
    }

    renderProcess(eventDescriptor) {
        return (
            <div key={ eventDescriptor.name } className="corpusbuilder-progress-indicator-item">
                { eventDescriptor.title }
            </div>
        );
    }

    render() {
        if(this.processes.length === 0) {
            return null;
        }

        return (
            <div className="corpusbuilder-progress-indicator">
                <div className="corpusbuilder-progress-indicator-items">
                    <div className="corpusbuilder-progress-indicator-spinner">
                      <Spinner name="cube-grid" color="white" />
                    </div>
                    { this.processes.map((e) => { return this.renderProcess(e) }) }
                </div>
            </div>
        );
    }

}
