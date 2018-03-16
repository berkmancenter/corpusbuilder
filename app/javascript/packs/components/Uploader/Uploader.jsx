import React from 'react';

import State from '../../stores/State'

import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'

import { PageFlow } from '../PageFlow';
import { PageFlowItem } from '../PageFlowItem';
import { Button } from '../Button';
import { ProgressIndicator } from '../ProgressIndicator';
import FetchSimilarDocuments from '../../actions/FetchSimilarDocuments';

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
    metadata = null;

    @observable
    pickedDocument = null;

    @computed
    get similarDocuments() {
        if(this.isMetadataReady) {
            return FetchSimilarDocuments.run(
                this.appState,
                {
                  select: {
                  },
                  metadata: this.metadata
                }
            )
        }

        return null;
    }

    @computed
    get isMetadataReady() {
        return this.metadata !== undefined &&
            this.metadata !== null &&
            this.metadata.title !== undefined &&
            this.metadata.title !== null &&
            this.metadata.title !== "";
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

    componentWillUpdate(props) {
        this.metadata = props.metadata;
    }

    onDocumentPicked(doc) {
        if(doc === this.pickedDocument) {
            this.pickedDocument = null;

            if(typeof this.props.onDocumentUnpicked === 'function') {
                this.props.onDocumentUnpicked();
            }
        }
        else {
            if(this.props.onDocumentPicked !== undefined && this.props.onDocumentPicked !== null) {
                this.props.onDocumentPicked(doc);
            }

            this.pickedDocument = doc;
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
        if(this.similarDocuments === undefined || this.similarDocuments === null) {
            items = <i>Fetching similar documents, please wait...</i>;
        }
        else if(this.similarDocuments.length > 0) {
            items = [
                <div key="explain" className="corpusbuilder-uploader-explain">
                    If any of the following documents represent the one described
                    in the metadata: please click on the "Pick" button.
                    Otherwise, please click on next to continue.
                </div>
            ];
            items = items.concat(
                this.similarDocuments.map((doc) => {
                    let classes = [ "corpusbuilder-uploader-similar-documents-item" ];

                    if(doc == this.pickedDocument) {
                        classes.push('picked');
                    }

                    return [
                        <div key="list" className={ classes.join(' ') }>
                            <div className="corpusbuilder-uploader-similar-documents-item-top-label">
                                Existing document:
                            </div>
                            <div className="corpusbuilder-uploader-similar-documents-item-body">
                                <div className="corpusbuilder-uploader-similar-documents-item-row">
                                    <div className="corpusbuilder-uploader-similar-documents-item-label">
                                        Title:
                                    </div>
                                    <div className="corpusbuilder-uploader-similar-documents-item-value">
                                        { doc.title }
                                    </div>
                                </div>
                                <div className="corpusbuilder-uploader-similar-documents-item-row">
                                    <div className="corpusbuilder-uploader-similar-documents-item-label">
                                        Date:
                                    </div>
                                    <div className="corpusbuilder-uploader-similar-documents-item-value">
                                        { doc.date }
                                    </div>
                                </div>
                                <div className="corpusbuilder-uploader-similar-documents-item-row">
                                    <div className="corpusbuilder-uploader-similar-documents-item-label">
                                        Author:
                                    </div>
                                    <div className="corpusbuilder-uploader-similar-documents-item-value">
                                        { doc.author }
                                    </div>
                                </div>
                            </div>
                            <div className="corpusbuilder-uploader-similar-documents-item-preview">
                              <img src={ doc.images_sample[0].url } />
                            </div>
                            <Button onClick={ this.onDocumentPicked.bind(this, doc) }>
                                { doc === this.pickedDocument ? 'Unpick' : 'Pick' }
                            </Button>
                        </div>
                    ];
                })
            );
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
