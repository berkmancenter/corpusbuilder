import React from 'react';
import  { DocumentDataProvider } from '../DocumentDataProvider'
import  { DocumentViewer } from '../DocumentViewer'
import s from './Viewer.scss'

export default class Viewer extends React.Component {
    render() {
        return (
            <div className="corpusbuilder-viewer">
                <DocumentDataProvider documentId={ this.props.documentId }>
                    <DocumentViewer />
                </DocumentDataProvider>
            </div>
        );
    }
}
