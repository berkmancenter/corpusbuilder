import React from 'react';
import * as qwest from 'qwest';
import { Provider, observer } from 'mobx-react'
import ContentLoader from 'react-content-loader'

import state from '../../stores/State'
import Documents from '../../stores/Documents'

import { DocumentPage } from '../DocumentPage'

import s from './Viewer.scss'

@observer
export default class Viewer extends React.Component {
    constructor(props) {
        super(props);

        this._context = {
            state: state,
            store: {
                documents: new Documents(props.baseUrl, state)
            }
        };

        qwest.base = props.baseUrl;

        this.state = {
            document: null,
            page: 1
        };
    }

    componentWillMount() {
        this._context.store.documents.get(this.props.documentId);
    }

    render() {
        let content;
        let context = this._context;
        let doc = context.state.documents.get(this.props.documentId);
        let page = this.state.page;

        if(doc !== undefined && doc !== null) {
            content = <div>
                <DocumentPage document={ doc } page={ page }>
                </DocumentPage>
              </div>
        }
        else {
            content = <ContentLoader type="facebook" />;
        }

        return (
            <div className="corpusbuilder-viewer">
                <Provider {...context}>
                    { content }
                </Provider>
            </div>
        );
    }
}
