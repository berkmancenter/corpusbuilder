import React from 'react';
import ContentLoader from 'react-content-loader'
import s from './DocumentViewer.scss'

export default class DocumentViewer extends React.Component {
    render() {
        let content;

        if(this.props.document !== undefined && this.props.document !== null) {
            content = <i>Document here!</i>;
        }
        else {
            content = <ContentLoader type="facebook" />;
        }

        return (
            <div className="corpusbuilder-document-viewer">
                { content }
            </div>
        );
    }
}

