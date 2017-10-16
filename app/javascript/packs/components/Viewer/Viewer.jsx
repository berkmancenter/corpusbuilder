import React from 'react';
import * as qwest from 'qwest';
import { Provider, observer } from 'mobx-react'
import ContentLoader from 'react-content-loader'
import { default as Dropdown } from 'react-simple-dropdown'
import { DropdownTrigger, DropdownContent } from 'react-simple-dropdown'

import state from '../../stores/State'
import Documents from '../../stores/Documents'

import { DocumentPage } from '../DocumentPage'
import { DocumentInfo } from '../DocumentInfo'

import dropdownStyles from 'react-simple-dropdown/styles/Dropdown.css'
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
            page: 1,
            showInfo: false
        };
    }

    navigate(page) {
        this.setState({ page: page });
    }

    toggleCertainties() {
        this._context.state.showCertainties = !this._context.state.showCertainties;
    }

    toggleInfo() {
        if(!this._context.state.documentInfos.has(this.props.documentId)) {
            this._context.store.documents.info(this.props.documentId);
        }
        this._context.state.showInfo = !this._context.state.showInfo;
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
            let infoPage;

            if(state.showInfo) {
              infoPage = <DocumentInfo document={ doc } />;
            }

            let pageOptions = Array.from({ length: countPages }, (_, n) => {
                return (
                    <li key={ `page-dropdown-${ n + 1 }` } onClick={ this.navigate.bind(this, n + 1) }>
                        { n + 1 }
                    </li>
                );
            });

            content = (
              <div>
                <div className="corpusbuilder-options">
                  <button onClick={ this.navigate.bind(this, 1) } disabled={ page == 1 }>
                    { '|←' }
                  </button>
                  <button onClick={ this.navigate.bind(this, page - 1) } disabled={ page == 1 }>
                    { '←' }
                  </button>
                  <Dropdown>
                    <DropdownTrigger>Page: { page } / { doc.surfaces.length }</DropdownTrigger>
                    <DropdownContent>
                      <ul>
                        { pageOptions }
                      </ul>
                    </DropdownContent>
                  </Dropdown>
                  <button onClick={ this.navigate.bind(this, page + 1) } disabled={ page == countPages }>
                    { '→' }
                  </button>
                  <button onClick={ this.navigate.bind(this, countPages) } disabled={ page == countPages }>
                    { '→|' }
                  </button>
                  <button onClick={ this.toggleCertainties.bind(this) }>
                    { '▧' }
                  </button>
                  <button onClick={ this.toggleInfo.bind(this) }>
                    { 'ℹ' }
                  </button>
                </div>
                <DocumentPage document={ doc } page={ page }>
                </DocumentPage>
                { infoPage }
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
