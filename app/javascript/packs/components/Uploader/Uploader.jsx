import React from 'react';

import State from '../../stores/State'

import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'

import { PageFlow } from '../PageFlow';
import { PageFlowItem } from '../PageFlowItem';
import { Button } from '../Button';
import { ProgressIndicator } from '../ProgressIndicator';

import Request from '../../lib/Request';

import styles from './Uploader.scss';

@observer
export default class Uploader extends React.Component {

    constructor(props) {
        super(props);

        this.appState = new State(this.props.baseUrl);
        Request.setBaseUrl(props.baseUrl);
    }

    progressEvents = [
        {
            name: 'FetchSimilarDocuments',
            title: <div>
              Searching for documents for given metadata...
            </div>
        }
    ];

    @observable
    similarDocuments = [ ];

    @computed
    get isMetadataReady() {
        return this.props.metadata !== undefined &&
            this.props.metadata !== null &&
            this.props.metadata.title !== undefined &&
            this.props.metadata.title !== null &&
            this.props.metadata.title !== "";
    }

    @computed
    get currentLevel() {
        if(!this.isMetadataReady) {
            return 'pre-metadata';
        }
        else {
            return 'similar-documents';
        }
    }

    @computed
    get sharedContext() {
        return {
            appState: this.appState,
            editorEmail: this.props.editorEmail
        };
    }

    onDocumentPicked(doc) {
        if(this.props.onDocumentPicked !== undefined && this.props.onDocumentPicked !== null) {
            this.props.onDocumentPicked(doc);
        }
    }

    renderPreMeta() {
        return (
            <div className="corpusbuilder-uploader-explain">
                You must provide document metadata first. At least the document
                title is required to send the scans to be OCR'ed.
            </div>
        );
    }

    renderSimilarDocuments() {
        let items = null;
        if(this.similarDocuments.length > 0) {
            items = this.similarDocuments.map((doc) => {
                return [
                    <div key="explain" className="corpusbuilder-uploader-explain">
                        If any of the following documents represent the one described
                        in the metadata: please click on the "Pick" button.
                        Otherwise, please click on next to continue.
                    </div>,
                    <div key="list" className="corpusbuilder-uploader-similar-documents-item">
                        { doc.title }
                        <Button onClick={ this.onDocumentPicked.bind(this, doc) }>Pick</Button>
                    </div>
                ];
            });
        }
        else {
            items = <i>No similar document has been found for given metadata. Please click next to continue</i>;
        }

        return (
            <div className="corpusbuilder-uploader-similar-documents">
                { items }
            </div>
        );
    }

    renderImagesUpload() {
        return <i>TODO: render the images uploader</i>;
    }

    renderImagesReady() {
        return <i>TODO: show the info that the images are ready</i>;
    }

    render() {
        console.log("Uploader render with metadata:", this.props.metadata);

        return (
            <Provider {...this.sharedContext}>
                <div className="corpusbuilder-uploader">
                    <ProgressIndicator events={ this.progressEvents }>
                    </ProgressIndicator>
                    <div className="corpusbuilder-uploader-title">Scans of documents to OCR</div>
                    <PageFlow>
                        <PageFlowItem isActive={ this.currentLevel === 'pre-metadata' }>
                            { this.renderPreMeta() }
                        </PageFlowItem>
                        <PageFlowItem isActive={ this.currentLevel === 'similar-documents' }>
                            { this.renderSimilarDocuments() }
                        </PageFlowItem>
                        <PageFlowItem isActive={ this.currentLevel === 'images-upload' }>
                            { this.renderImagesUpload() }
                        </PageFlowItem>
                        <PageFlowItem isActive={ this.currentLevel === 'images-ready' }>
                            { this.renderImagesReady() }
                        </PageFlowItem>
                    </PageFlow>
                </div>
            </Provider>
        );
    }
}
