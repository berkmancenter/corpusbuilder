import React from 'react'
import ReactDOM from 'react-dom'

import { WindowManager } from './components/WindowManager'
import { Uploader } from './components/Uploader'
import { DocumentStatus } from './components/DocumentStatus'

class CorpusBuilder {
    static init(element, options) {
        ReactDOM.render(
            <WindowManager baseUrl={ options.baseUrl }
                           directUrl={ options.directUrl }
                           documentId={ options.documentId }
                           allowImages={ options.allowImages || false }
                           host={ element }
                           editorEmail={ options.editorEmail }
                           />,
            element
        );
    }
}

class CorpusBuilderDocumentStatus {
    static init(element, options) {
        let status = new CorpusBuilderDocumentStatus();

        status.element = element;
        status.options = options;

        status.render();

        return status;
    }

    options = { };
    element = null;

    render() {
        ReactDOM.render(
            <DocumentStatus baseUrl={ this.options.baseUrl }
                            host={ this.element }
                            editorEmail={ this.options.editorEmail }
                            documentId={ this.options.documentId }
                            />,
            this.element
        );
    }
}

class CorpusBuilderUploader {
    static init(element, options) {
        let uploader = new CorpusBuilderUploader();

        uploader.element = element;
        uploader.options = options;

        uploader.render();

        return uploader;
    }

    options = { };
    element = null;
    metadata = { };
    images = null;

    setMetadata(metadata) {
        this.metadata = metadata;

        this.render();
    }

    setImages(images) {
        if(images !== undefined) {
            this.images = images;

            this.render();
        }
    }

    onDocumentPicked(doc) {
        if(typeof this.options.onDocumentPicked === 'function') {
            this.options.onDocumentPicked(doc);
        }
    }

    onLanguagesPicked(languageCodes) {
        if(typeof this.options.onLanguagesPicked === 'function') {
            this.options.onLanguagesPicked(languageCodes);
        }
    }

    onDocumentUnpicked() {
        if(typeof this.options.onDocumentUnpicked === 'function') {
            this.options.onDocumentUnpicked();
        }
    }

    onImagesUploaded(images) {
        if(typeof this.options.onImagesUploaded === 'function') {
            this.options.onImagesUploaded(images);
        }
    }

    render() {
        ReactDOM.render(
            <Uploader baseUrl={ this.options.baseUrl }
                      host={ this.element }
                      editorEmail={ this.options.editorEmail }
                      metadata={ this.metadata }
                      images={ this.images }
                      onDocumentPicked={ this.onDocumentPicked.bind(this) }
                      onDocumentUnpicked={ this.onDocumentUnpicked.bind(this) }
                      onLanguagesPicked={ this.onLanguagesPicked.bind(this) }
                      onImagesUploaded={ this.onImagesUploaded.bind(this) }
                      />,
            this.element
        );
    }
}

window.CorpusBuilder = CorpusBuilder;
window.CorpusBuilderUploader = CorpusBuilderUploader;
window.CorpusBuilderDocumentStatus = CorpusBuilderDocumentStatus;
