import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
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
import { DocumentPageSwitcher } from '../DocumentPageSwitcher'
import { DocumentOptions } from '../DocumentOptions'
import { InlineEditor } from '../InlineEditor'
import { NewBranchWindow } from '../NewBranchWindow'
import { Button } from '../Button';

import s from './Viewer.scss'

@inject('documents')
@inject('metadata')
@observer
export default class Viewer extends React.Component {

    div = null;

    @observable
    currentVersion = null;

    @observable
    editing = false;

    @observable
    showImage = false;

    @observable
    documentId = null;

    @observable
    page = 1;

    @observable
    lastSelectedGraphemes = null;

    @observable
    editingLine = null;

    @observable
    editingText = null;

    @observable
    showCertainties = false;

    @observable
    showPopup = false;

    @observable
    showAnnotationEditor = false;

    @observable
    showInlineEditor = false;

    @observable
    showNewBranchWindow = false;

    @observable
    showAnnotations = false;

    @observable
    showTagsEditor = false;

    @computed
    get tree() {
        // note: checks for all nulls are to make this computed dependent on all
        // three observables - not just the version
        if(this.documentId === null ||
           this.page === null ||
           this.currentVersion === null) {
            return null;
        }
        else {
            return this.props.documents.tree(
              this.documentId,
              this.currentVersion,
              this.page
            );
        }
    }

    @computed
    get branches() {
        return this.props.documents.branches(this.documentId) || [];
    }

    @computed
    get width() {
        return this.props.width;
    }

    @computed
    get height() {
        let width = this.tree.surfaces[0].area.lrx - this.tree.surfaces[0].area.ulx;
        let height = this.tree.surfaces[0].area.lry - this.tree.surfaces[0].area.uly;

        let ratio = this.width / width;

        return height * ratio;
    }

    @computed
    get documentMaxHeight() {
        if(this.tree === null || this.tree === undefined) {
            return this.width;
        }

        let ratio = this.width / this.tree.global.tallest_surface.width;

        return ratio * this.tree.global.tallest_surface.height;
    }

    constructor(props) {
        super(props);

        this.documentId = this.props.documentId;
        this.currentVersion = this.props.documents.getVersion({
            documentId: this.documentId,
            name: this.props.branchName || 'master'
        });
        this.showImage = this.props.showImage;
    }

    navigate(page) {
        this.page = page;

        if(this.props.onPageSwitch !== null && this.props.onPageSwitch !== undefined) {
            this.props.onPageSwitch(page);
        }
    }

    reportElement(div) {
        this.div = div;

        if(div !== null && this.props.onRendered !== null && this.props.onRendered !== undefined) {
            this.props.onRendered(div);
        }
    }

    chooseBranch(branch) {
        this.currentVersion = this.props.documents.getVersion({
            documentId: this.documentId,
            branchName: branch.name
        });
    }

    toggleBranchMode(isOn) {
        if(this.editing == isOn) return;

        this.editing = isOn;

        if(isOn) {
            this.currentVersion = this.currentVersion.workingVersion;
        }
        else {
            this.currentVersion = this.currentVersion.branchVersion;
        }
    }

    toggleCertainties(isOn) {
        this.showCertainties = isOn;
    }

    toggleAnnotations(isOn) {
        this.showAnnotations = isOn;
    }

    toggleBackground(isOn) {
        this.showImage = isOn;
    }

    resetChanges() {
        this.props.documents.reset(this.documentId, this.currentVersion);
    }

    commitChanges() {
        this.props.documents.commit(this.documentId, this.currentVersion)
            .then((_) => {
                this.editing = false;
                this.currentVersion = this.props.documents.getBranch(
                  this.currentVersion.branchVersion.branchName,
                  this.documentId
                );
            });
    }

    onNewBranchRequested() {
        this.showNewBranchWindow = true;
    }

    editAnnotation() {
        // make sure the mouse event bubbling comes first
        setTimeout(() => {
            this.showPopup = false;
            this.showAnnotationEditor = true;
        }, 0);
    }

    saveAnnotation(annotation) {
        this.props.metadata.saveAnnotation(
            this.documentId,
            this.currentVersion,
            annotation,
            this.lastSelectedGraphemes
        );
    }

    saveLine(doc, line, editedText, boxes) {
      this.props.documents.correct(doc, this.page, line, this.currentVersion, editedText, boxes)
          .finally((_) => {
              this.showInlineEditor = false;
          });
    }

    hideAnnotationEditor() {
        this.showAnnotationEditor = false;
    }

    hideInlineEditor() {
        this.showInlineEditor = false;
    }

    hideNewBranchWindow() {
        this.showNewBranchWindow = false;
    }

    editTags() {
        this.showPopup = false;
        this.showTagsEditor = true;
    }

    onLineClick(line, text, number, editing) {
        if(editing) {
            this.showInlineEditor = true;
            this.editingLine = line;
            this.editingText = text;
        }
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

    componentWillMount() {
        this.page = this.props.page || 1;
    }

    componentDidUpdate() {
        this.reportElement(this.div);
    }

    componentWillReceiveProps(props) {
        this.page = props.page || 1;
    }

    render() {
        let doc = this.tree;
        let width = this.width;
        let content;

        if(doc !== undefined && doc !== null && doc.surfaces.length > 0) {
            let page = this.page || doc.surfaces[0].number;
            let otherContent;

            let contentStyles = {
                height: this.documentMaxHeight + 20
            };

            let mainPageTop = (this.documentMaxHeight + 20 - this.height) / 2;

            content = (
              <div>
                <div className="corpusbuilder-options top">
                  <DocumentOptions document={ doc }
                                   branches={ this.branches }
                                   currentVersion={ this.currentVersion }
                                   editing={ this.editing }
                                   showCertainties={ this.showCertainties }
                                   showAnnotations={ this.showAnnotations }
                                   showBackground={ this.showImage }
                                   onBranchSwitch={ this.chooseBranch.bind(this) }
                                   onBranchModeToggle={ this.toggleBranchMode.bind(this) }
                                   onToggleCertainties={ this.toggleCertainties.bind(this) }
                                   onToggleAnnotations={ this.toggleAnnotations.bind(this) }
                                   onToggleBackground={ this.toggleBackground.bind(this) }
                                   onResetChangesRequest={ this.resetChanges.bind(this) }
                                   onCommitRequest={ this.commitChanges.bind(this) }
                                   onNewBranchRequest={ this.onNewBranchRequested.bind(this) }
                                   />
                </div>
                <div className="corpusbuilder-viewer-contents" style={ contentStyles }>
                  <div className="corpusbuilder-viewer-contents-wrapper">
                    <DocumentPage document={ doc }
                                  page={ page }
                                  width={ width }
                                  editing={ this.editing }
                                  mainPageTop={ mainPageTop }
                                  documentMaxHeight={ this.documentMaxHeight }
                                  showCertainties={ this.showCertainties }
                                  showImage={ this.showImage }
                                  onSelected={ this.onSelected.bind(this) }
                                  onLineClick={ this.onLineClick.bind(this) }
                                  >
                    </DocumentPage>
                  </div>
                  <InlineEditor visible={ this.showInlineEditor }
                                document={ doc }
                                line={ this.editingLine }
                                text={ this.editingText }
                                page={ page }
                                width={ width }
                                mainPageTop={ mainPageTop }
                                onCloseRequested={ this.hideInlineEditor.bind(this) }
                                onSaveRequested={ this.saveLine.bind(this) }
                                />
                  <NewBranchWindow visible={ this.showNewBranchWindow }
                                   document={ doc }
                                   currentVersion={ this.currentVersion }
                                   onCloseRequested={ this.hideNewBranchWindow.bind(this) }
                                   />
                  <AnnotationEditor visible={ this.showAnnotationEditor }
                                    document={ doc }
                                    page={ page }
                                    width={ width }
                                    graphemes={ this.lastSelectedGraphemes }
                                    mainPageTop={ mainPageTop }
                                    onCloseRequested={ this.hideAnnotationEditor.bind(this) }
                                    onSaveRequested={ this.saveAnnotation.bind(this) }
                                    />
                  <Annotations visible={ this.showAnnotations }
                              document={ doc }
                              version={ this.currentVersion }
                              page={ page }
                              width={ width }
                              mainPageTop={ mainPageTop }
                              />
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
                  <Button onClick={ this.editAnnotation.bind(this) }>
                    { '✐' }
                  </Button>
                  <Button onClick={ this.editTags.bind(this) }>
                    { '#' }
                  </Button>
                </PopupMenu>
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
            <div ref={ this.reportElement.bind(this) }
                 className={ `corpusbuilder-viewer ${ this.editing ? 'corpusbuilder-viewer-editing' : '' }` }
                 style={ viewerStyle }>
                <MouseManager>
                    { content }
                </MouseManager>
            </div>
        );
    }
}
