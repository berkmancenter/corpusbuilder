import React from 'react'
import ReactDOM from 'react-dom'
import { Viewer } from './components/Viewer'

class CorpusBuilder {
    static init(element, options) {
        ReactDOM.render(
            <Viewer documentId="61389c62-b6a6-4339-b4c2-87fae4a6c0ab" />,
            element
        );
    }
}

window.CorpusBuilder = CorpusBuilder
