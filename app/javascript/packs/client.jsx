import React from 'react'
import ReactDOM from 'react-dom'

import { WindowManager } from './components/WindowManager'
import { Uploader } from './components/Uploader'

class CorpusBuilder {
    static init(element, options) {
        ReactDOM.render(
            <WindowManager baseUrl={ options.baseUrl }
                           documentId={ options.documentId }
                           allowImages={ options.allowImages || false }
                           host={ element }
                           editorEmail={ options.editorEmail }
                           />,
            element
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

    setMetadata(metadata) {
        this.metadata = metadata;

        this.render();
    }

    render() {
        ReactDOM.render(
            <Uploader baseUrl={ this.options.baseUrl }
                      host={ this.element }
                      editorEmail={ this.options.editorEmail }
                      metadata={ this.metadata }
                      />,
            this.element
        );
    }
}

window.CorpusBuilder = CorpusBuilder;
window.CorpusBuilderUploader = CorpusBuilderUploader;
