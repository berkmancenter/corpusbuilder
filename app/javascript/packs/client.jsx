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
        ReactDOM.render(
            <Uploader baseUrl={ options.baseUrl }
                      host={ element }
                      editorEmail={ options.editorEmail }
                      />,
            element
        );
    }
}

window.CorpusBuilder = CorpusBuilder;
window.CorpusBuilderUploader = CorpusBuilderUploader;
