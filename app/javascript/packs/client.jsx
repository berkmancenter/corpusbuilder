import React from 'react'
import ReactDOM from 'react-dom'
import { WindowManager } from './components/WindowManager'

class CorpusBuilder {
    static init(element, options) {
        ReactDOM.render(
            <WindowManager baseUrl={ options.baseUrl }
                           documentId={ options.documentId }
                           allowImages={ options.allowImages || false }
                           host={ element }
                           />,
            element
        );
    }
}

window.CorpusBuilder = CorpusBuilder
