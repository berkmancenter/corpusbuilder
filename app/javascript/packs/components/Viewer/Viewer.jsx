import React from 'react';
import * as qwest from 'qwest';
import { Provider, observer } from 'mobx-react'
import ContentLoader from 'react-content-loader'

import state from '../../stores/State'
import Documents from '../../stores/Documents'

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
            document: null
        };
    }

    componentWillMount() {
        setTimeout(() => {
            this._context.store.documents.get("61389c62-b6a6-4339-b4c2-87fae4a6c0ab");
        }, 3000);
    }

    render() {
        let content;
        let context = this._context;
        let doc = context.state.documents.get(this.props.documentId);

        if(doc !== undefined && doc !== null) {
            content = <i>Document here!</i>;
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
