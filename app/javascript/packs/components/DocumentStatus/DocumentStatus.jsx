import React from 'react';

import { action, observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'

import State from '../../stores/State'
import Request from '../../lib/Request';
import Spinner from 'react-spinkit';

import FetchDocumentStatus from '../../actions/FetchDocumentStatus';

import styles from './DocumentStatus.scss';

@observer
export default class DocumentStatus extends React.Component {

    @observable
    state = null;

    constructor(props) {
        super(props);

        this.appState = new State(this.props.baseUrl);
        Request.setBaseUrl(props.baseUrl);

        this.fetchStatus();
    }

    fetchStatus() {
        FetchDocumentStatus.run(
            this.appState,
            {
                select: { },
                document: {
                    id: this.props.documentId
                }
            }
        ).then(action((state) => {
            this.state = state;

            if(state === 'initial' || state === 'processing') {
                setTimeout(this.fetchStatus.bind(this), 2000);
            }
        }));
    }

    renderInit() {
        return (
          <span>Querying for the document state...</span>
        )
    }

    renderQueued() {
        return (
          <span>Document has been queued to be processed. It's not ready yet.</span>
        )
    }

    renderProcessing() {
        return (
            <div>
              <div className="corpusbuilder-document-status-spinner">
                <Spinner name="ball-grid-pulse" color="#777" fadeIn="none" />
              </div>
              <div className="corpusbuilder-document-status-row">
                  <span>The document is being processed</span>
              </div>
              <div className="corpusbuilder-document-status-row">
                  <span>This can take a while...</span>
              </div>
            </div>
        )
    }

    renderError() {
        return (
          <div>
              <i className="fa fa-thumbs-down"></i>
              &nbsp;
              <span className="corpusbuilder-error">An error occured and the document has not been correctly processed.</span>
          </div>
        )
    }

    renderReady() {
        return (
          <div>
              <i className="fa fa-thumbs-up"></i>
              &nbsp;
              <span className="corpusbuilder-success">Document has been successfully processed</span>
          </div>
        )
    }

    render() {
        let stage = null;

        if(this.state === null) {
            stage = this.renderInit();
        }
        else if(this.state === 'initial') {
            stage = this.renderQueued();
        }
        else if(this.state === 'processing') {
            stage = this.renderProcessing();
        }
        else if(this.state === 'error') {
            stage = this.renderError();
        }
        else if(this.state === 'ready') {
            stage = this.renderReady();
        }
        return (
            <Provider {...this.sharedContext}>
                <div className="corpusbuilder-document-status">
                  {
                      stage
                  }
                </div>
            </Provider>
        );
    }
}
