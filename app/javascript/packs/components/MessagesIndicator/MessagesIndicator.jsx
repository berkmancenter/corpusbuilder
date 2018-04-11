import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react';
import Spinner from 'react-spinkit';
import styles from './MessagesIndicator.scss';

@inject('appState')
@observer
export default class MessagesIndicator extends React.Component {

    processes = [];

    @computed
    get timeSpan() {
        return this.props.timeSpan || 4500;
    }

    constructor(props) {
        super(props);

        this.props.appState.on('.*:(error|info)', ((_, value, eventName) => {
            this.add(value, eventName);
        }).bind(this));
    }

    add(value, eventName) {
        let process = {
          value: value,
          eventName: eventName
        };

        this.processes.push(process);

        setTimeout(() => {
            this.processes = this.processes.filter((p) => { return p !== process });
            this.refresh();
        }, this.timeSpan);

        this.refresh();
    }

    refresh() {
        setTimeout(this.forceUpdate.bind(this));
    }

    renderProcess(eventDescriptor) {
        let message = [];
        if(typeof eventDescriptor.value === 'string') {
            message.push(
                <span>{ eventDescriptor.value }</span>
            );
        }
        else {
            for(let key of Object.keys(eventDescriptor.value)) {
                let keyString = key === 'base' || key === 'error' ? '' : `${key}: `;
                let valueString = "";

                if(typeof eventDescriptor.value[key] === 'object' && eventDescriptor.value[key].length !== undefined) {
                    valueString = eventDescriptor.value[key].join(', ')
                }
                else {
                    valueString = eventDescriptor.value[key];
                }

                message.push(
                    <span>{ keyString }{ valueString }</span>
                );
            }
        }

        return (
            <div key={ eventDescriptor.eventName } className="corpusbuilder-messages-indicator-item">
                { message }
            </div>
        );
    }

    render() {
        if(this.processes.length === 0) {
            return null;
        }

        return (
            <div className="corpusbuilder-messages-indicator">
                <div className="corpusbuilder-messages-indicator-items">
                    { this.processes.map((e) => { return this.renderProcess(e) }) }
                </div>
            </div>
        );
    }

}
