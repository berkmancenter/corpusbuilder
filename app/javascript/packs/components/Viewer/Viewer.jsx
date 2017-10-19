import React from 'react';
import * as qwest from 'qwest';
import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'
import ContentLoader from 'react-content-loader'

import state from '../../stores/State'
import Documents from '../../stores/Documents'

import { DocumentPage } from '../DocumentPage'
import { DocumentInfo } from '../DocumentInfo'
import { DocumentPageSwitcher } from '../DocumentPageSwitcher'
import { DocumentOptions } from '../DocumentOptions'

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

        this.documentId = this.props.documentId;
        this.currentBranch = this.props.branchName || 'master';
    }

    navigate(page) {
        this.page = page;
    }

    chooseBranch(branch) {
        this.currentBranch = branch.name;
    }

    toggleCertainties() {
        this.showCertainties = !this.showCertainties;
    }

    toggleInfo() {
        this.showInfo = !this.showInfo;
    }

    render() {
        let context = this.data;
        let doc = this.tree;
        let width = this.props.width;
        let branchName = this.currentBranch;
        let content;

        if(doc !== undefined && doc !== null && doc.surfaces.length > 0) {
            let page = this.page || doc.surfaces[0].number;
            let infoPage;

            if(this.showInfo) {
              infoPage = <DocumentInfo document={ doc } />;
            }

            content = (
              <div>
                <div className="corpusbuilder-options top">
                  <DocumentOptions document={ doc }
                      branches={ this.branches }
                      currentBranch={ this.currentBranch }
                      onBranchSwitch={ this.chooseBranch.bind(this) }
                      onToggleInfo={ this.toggleInfo.bind(this) }
                      onToggleCertainties={ this.toggleCertainties.bind(this) }
                      />
                </div>
                <div className="corpusbuilder-viewer-contents">
                  <DocumentPage document={ doc } page={ page } width={ width }
                                showCertainties={ this.showCertainties }
                                >
                  </DocumentPage>
                  { infoPage }
                </div>
                <div className="corpusbuilder-options bottom">
                  <DocumentPageSwitcher document={ doc }
                      page={ page }
                      onPageSwitch={ this.navigate.bind(this) }
                      />
                </div>
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
