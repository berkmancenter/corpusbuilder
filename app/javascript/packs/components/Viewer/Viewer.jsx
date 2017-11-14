import React from 'react';
import * as qwest from 'qwest';
import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'
import ContentLoader from 'react-content-loader'

import state from '../../stores/State'

import Documents from '../../stores/Documents'
import Metadata from '../../stores/Metadata'
import Mouse from '../../stores/Mouse'

import { MouseManager } from '../MouseManager'
import { PopupMenu } from '../PopupMenu'
import { AnnotationEditor } from '../AnnotationEditor'
import { Annotations } from '../Annotations'
import { DocumentPage } from '../DocumentPage'
import { DocumentInfo } from '../DocumentInfo'
import { DocumentRevisionsBrowser } from '../DocumentRevisionsBrowser'
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
    page = 1;

    @observable
    lastSelectedGraphemes = null;

    @observable
    showInfo = false;

    @observable
    showCertainties = false;

    @observable
    showRevisions = false;

    @observable
    showPopup = false;

    @observable
    showAnnotationEditor = false;

    @observable
    showAnnotations = false;

    @observable
    showTagsEditor = false;

    @computed get tree() {
        return this.data.documents.tree(
          this.documentId,
          this.currentBranch,
          this.page
        );
    }

    @computed get branches() {
        return this.data.documents.branches(this.documentId) || [];
    }

    constructor(props) {
        super(props);

        this.data = {
            documents: new Documents(props.baseUrl, state),
            metadata: new Metadata(props.baseUrl, state),
            mouse: new Mouse(state)
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
        this.showRevisions = false;
        this.showInfo = !this.showInfo;
    }

    toggleRevisions() {
        this.showInfo = false;
        this.showRevisions = !this.showRevisions;
    }

    toggleAnnotations() {
        this.showInfo = this.showCertainties = false;
        this.showAnnotations = !this.showAnnotations;
    }

    editAnnotation() {
        // make sure the mouse event bubbling comes first
        setTimeout(() => {
            this.showPopup = false;
            this.showAnnotationEditor = true;
        }, 0);
    }

    saveAnnotation(annotation) {
        this.data.metadata.saveAnnotation(
            this.documentId,
            this.currentBranch,
            annotation,
            this.lastSelectedGraphemes
        );
    }

    hideAnnotationEditor() {
        this.showAnnotationEditor = false;
    }

    editTags() {
        this.showPopup = false;
        this.showTagsEditor = true;
    }

    onSelected(graphemes) {
        // make sure the mouse event bubbling comes first
        setTimeout(() => {
            this.lastSelectedGraphemes = graphemes;
            this.showPopup = true;
        }, 0);
    }

    onPopupClickedOutside() {
        this.showPopup = false;
    }

    render() {
        let context = this.data;
        let doc = this.tree;
        let width = this.props.width;
        let branchName = this.currentBranch;
        let content;

        if(doc !== undefined && doc !== null && doc.surfaces.length > 0) {
            let page = this.page || doc.surfaces[0].number;
            let otherContent;

            if(this.showInfo) {
              otherContent = <DocumentInfo document={ doc } />;
            }

            if(this.showRevisions) {
              otherContent = <DocumentRevisionsBrowser document={ doc } branchName={ this.currentBranch } />;
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
                                   onToggleRevisions={ this.toggleRevisions.bind(this) }
                                   onToggleAnnotations={ this.toggleAnnotations.bind(this) }
                                   />
                </div>
                <div className="corpusbuilder-viewer-contents">
                  <DocumentPage document={ doc }
                                page={ page }
                                width={ width }
                                showCertainties={ this.showCertainties }
                                showImage={ this.props.showImage }
                                onSelected={ this.onSelected.bind(this) }
                                >
                  </DocumentPage>
                  { otherContent }
                </div>
                <div className="corpusbuilder-options bottom">
                  <DocumentPageSwitcher document={ doc }
                      page={ page }
                      onPageSwitch={ this.navigate.bind(this) }
                      />
                </div>
                <PopupMenu visible={ this.showPopup }
                           onClickedOutside={ this.onPopupClickedOutside.bind(this) }
                           >
                  <button onClick={ this.editAnnotation.bind(this) }>
                    { '✐' }
                  </button>
                  <button onClick={ this.editTags.bind(this) }>
                    { '#' }
                  </button>
                </PopupMenu>
                <AnnotationEditor visible={ this.showAnnotationEditor }
                                  document={ doc }
                                  page={ page }
                                  width={ width }
                                  graphemes={ this.lastSelectedGraphemes }
                                  onCloseRequested={ this.hideAnnotationEditor.bind(this) }
                                  onSaveRequested={ this.saveAnnotation.bind(this) }
                                  />
                <Annotations visible={ this.showAnnotations }
                             document={ doc }
                             branchName={ this.currentBranch }
                             page={ page }
                             width={ width }
                             />
              </div>
            );
        }
        else {
            content = <ContentLoader type="facebook" />;
        }

        let viewerStyle = {
            minWidth: `${this.props.width}px`
        };

        return (
            <div className="corpusbuilder-viewer" style={ viewerStyle }>
                <Provider {...context}>
                    <MouseManager>
                        { content }
                    </MouseManager>
                </Provider>
            </div>
        );
    }
}
