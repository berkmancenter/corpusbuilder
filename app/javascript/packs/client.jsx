import React from 'react'
import ReactDOM from 'react-dom'
import { Viewer } from './components/Viewer'

class CorpusBuilder {
    static init(element, options) {
        ReactDOM.render(
            <Viewer baseUrl={ options.baseUrl }
                    documentId={ options.documentId }
                    width={ options.width || 600 }
                    showImage={ options.showImage || false }
                    />,
            element
        );
    }
}

window.CorpusBuilder = CorpusBuilder
