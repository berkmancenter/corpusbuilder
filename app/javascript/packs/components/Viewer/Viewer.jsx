import React from 'react';
import * as qwest from 'qwest';
import { observable, computed } from 'mobx';
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

    @observable
    currentBranch = null;

    @observable
    documentId = null;

    @observable
    page = null;

    @observable
    showInfo = false;

    @observable
    showCertainties = false;

    @computed get tree() {
        return this.data.documents.tree(
          this.documentId,
          this.currentBranch
        );
    }

    @computed get branches() {
        return this.data.documents.branches(this.documentId) || [];
    }

    constructor(props) {
        super(props);

        this.data = {
            documents: new Documents(props.baseUrl, state)
        };

        qwest.base = props.baseUrl;
    }

    navigate(page) {
        this.page = page;
    }

    chooseBranch(branch) {
        this.currentBranch = branch;
    }

    toggleCertainties() {
        this.showCertainties = !this.showCertainties;
    }

    toggleInfo() {
        this.showInfo = !this.showInfo;
    }

    componentWillMount() {
        this.documentId = this.props.documentId;
        this.currentBranch = this.props.branchName || 'master';
    }

    render() {
        let context = this.data;
        let doc = this.tree;
        let width = this.props.width;
        let branchName = this.currentBranch;
        let content;

        if(doc !== undefined && doc !== null && doc.surfaces.length > 0) {
            let countPages = doc.surfaces.length;
            let firstSurface = doc.surfaces[0];
            let page = this.page || firstSurface.number;
            let infoPage;

            if(this.showInfo) {
              infoPage = <DocumentInfo document={ doc } />;
            }

            let pageOptions = doc.surfaces.map(
                (surface) => {
                    return (
                        <li key={ `page-dropdown-${ surface.id }` }
                            onClick={ this.navigate.bind(this, surface.number) }
                            >
                            { surface.number === page ? `* ${ surface.number }` : surface.number }
                        </li>
                    );
                }
            );

            let branchesOptions = this.branches.map(
                (branch) => {
                    return (
                        <li key={ `branch-${ branch.revision_id }` }
                            onClick={ this.chooseBranch.bind(this, branch) }
                            >
                            { this.currentBranch === branch.name ? `* ${branch.name}` : branch.name }
                        </li>
                    );
                }
            );

            content = (
              <div>
                <div className="corpusbuilder-options">
                  <button onClick={ this.navigate.bind(this, firstSurface.number) }
                          disabled={ page == firstSurface.number }
                          >
                    { '|←' }
                  </button>
                  <button onClick={ this.navigate.bind(this, page - 1) }
                          disabled={ page == firstSurface.number }
                          >
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
                  <div className="side-options">
                    <Dropdown>
                      <DropdownTrigger>Branch: { this.currentBranch }</DropdownTrigger>
                      <DropdownContent>
                        <ul>
                          { branchesOptions }
                        </ul>
                      </DropdownContent>
                    </Dropdown>
                  </div>
                </div>
                <DocumentPage document={ doc } page={ page } width={ width }
                              showCertainties={ this.showCertainties }
                              >
                </DocumentPage>
                { infoPage }
              </div>
            );
        }
        else {
            content = <ContentLoader type="facebook" />;
        }

        let viewerStyle = {
            minWidth: `${this.props.width}px`,
            minHeight: `${this.props.width}px`,
        };

        return (
            <div className="corpusbuilder-viewer" style={ viewerStyle }>
                <Provider {...context}>
                    { content }
                </Provider>
            </div>
        );
    }
}
