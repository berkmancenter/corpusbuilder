import React from 'react'
import ReactDOM from 'react-dom'
import { Viewer } from './components/Viewer'

class CorpusBuilder {
    static init(element, options) {
        ReactDOM.render(
            <Viewer baseUrl={ options.baseUrl } documentId={ options.documentId } />,
            element
        );
    }
}

window.CorpusBuilder = CorpusBuilder
