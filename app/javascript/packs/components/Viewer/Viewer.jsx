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

    navigate(page) {
        this.setState({ page: page });
    }

    toggleCertainties() {
        this._context.state.showCertainties = !this._context.state.showCertainties;
    }

    componentWillMount() {
        this._context.store.documents.get(this.props.documentId);
    }

    render() {
        let content;
        let context = this._context;
        let state = context.state;
        let doc = state.documents.get(this.props.documentId);
        let page = this.state.page;

        if(doc !== undefined && doc !== null) {
            let countPages = doc.surfaces.length;
            content = (
              <div>
                <div className="corpusbuilder-options">
                  <span>
                    Page { page } / { doc.surfaces.length }
                  </span>
                  <button onClick={ this.navigate.bind(this, 1) } disabled={ page == 1 }>
                    { '|←' }
                  </button>
                  <button onClick={ this.navigate.bind(this, page - 1) } disabled={ page == 1 }>
                    { '←' }
                  </button>
                  <button onClick={ this.navigate.bind(this, page + 1) } disabled={ page == countPages }>
                    { '→' }
                  </button>
                  <button onClick={ this.navigate.bind(this, countPages) } disabled={ page == countPages }>
                    { '→|' }
                  </button>
                  <button onClick={ this.toggleCertainties.bind(this) }>
                    { '▧' }
                  </button>
                </div>
                <DocumentPage document={ doc } page={ page }>
                </DocumentPage>
              </div>
            );
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
