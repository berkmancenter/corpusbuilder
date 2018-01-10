import React from 'react';
import { autorun, observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import ContentLoader from 'react-content-loader'

import State from '../../stores/State'

import FetchDocumentPage from '../../actions/FetchDocumentPage';
import FetchDocumentDiff from '../../actions/FetchDocumentDiff';
import FetchDocumentBranches from '../../actions/FetchDocumentBranches';
import FetchDocumentBranch from '../../actions/FetchDocumentBranch';
import CreateDocumentBranch from '../../actions/CreateDocumentBranch';
import ResetDocumentBranch from '../../actions/ResetDocumentBranch';
import CommitDocumentChanges from '../../actions/CommitDocumentChanges';

import { MouseManager } from '../MouseManager'
import { PopupMenu } from '../PopupMenu'
import { AnnotationEditor } from '../AnnotationEditor'
import { Annotations } from '../Annotations'
import { DocumentPage } from '../DocumentPage'
import { DocumentPageSwitcher } from '../DocumentPageSwitcher'
import { DocumentOptions } from '../DocumentOptions'
import { InlineEditor } from '../InlineEditor'
import { NewBranchWindow } from '../NewBranchWindow'
import { DiffOptions } from '../DiffOptions';
import { Button } from '../Button';
import { DiffLayer } from '../DiffLayer';

import s from './Viewer.scss'

@inject('appState')
@observer
export default class Viewer extends React.Component {

    div = null;

    @observable
    currentVersion = null;

    @observable
    currentDiffVersion = null;

    @observable
    diffPage = 1;

    @observable
    editing = false;

    @observable
    showImage = false;

    @observable
    showDiff = false;

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
    get document() {
        // note: checks for all nulls are to make this computed dependent on all
        // three observables - not just the version
        if(this.documentId === null ||
           this.page === null ||
           this.currentVersion === null) {
            return null;
        }
        else {
            return FetchDocumentPage.run(
              this.props.appState,
              {
                select: {
                    document: { id: this.documentId },
                    version: this.currentVersion,
                    pageNumber: this.page
                }
              }
            );
        }
    }

    @computed
    get otherDiffTree() {
        if(this.documentId === null ||
           this.page === null ||
           this.currentDiffVersion === null) {
            return null;
        }
        else {
            return FetchDocumentPage.run(
              this.props.appState,
              {
                select: {
                    document: { id: this.documentId },
                    version: this.currentDiffVersion,
                    pageNumber: this.page
                }
              }
            );
        }
    }

    @computed
    get diff() {
        if(this.documentId === null ||
           this.currentDiffVersion === null ||
           this.currentVersion === null) {
            return null;
        }
        else {
            return FetchDocumentDiff.run(
              this.props.appState,
              {
                select: {
                    document: { id: this.documentId },
                    version: this.currentVersion,
                    otherVersion: this.currentDiffVersion
                }
              }
            );
        }
    }

    @computed
    get diffWords() {
        if(this.diffPage === null || this.document === null || this.diff === null || this.otherDiffTree === null ||
           this.diffPage === undefined || this.document === undefined || this.diff === undefined ||
           this.otherDiffTree === undefined) {
            return [ ];
        }
        else {
            return this.diff.words(
                this.diffPage,
                this.document.surfaces[0].graphemes,
                this.otherDiffTree.surfaces[0].graphemes,
                this.currentVersion,
                this.currentDiffVersion
            );
        }
    }

    @computed
    get branches() {
        return FetchDocumentBranches.run(
          this.props.appState,
          {
            select: {
                document: { id: this.documentId }
            }
          }
        );
    }

    @computed
    get width() {
        return this.props.width;
    }

    @computed
    get height() {
        let width = this.document.surfaces[0].area.lrx - this.document.surfaces[0].area.ulx;
        let height = this.document.surfaces[0].area.lry - this.document.surfaces[0].area.uly;

        let ratio = this.width / width;

        return height * ratio;
    }

    @computed
    get documentMaxHeight() {
        if(this.document === null || this.document === undefined) {
            return this.width;
        }

        let ratio = this.width / this.document.global.tallest_surface.width;

        return ratio * this.document.global.tallest_surface.height;
    }

    constructor(props) {
        super(props);

        this.documentId = this.props.documentId;
        this.currentVersion = FetchDocumentBranch.run(
            this.props.appState,
            {
              select: {
                  document: { id: this.documentId },
                  name: this.props.branchName || 'master'
              }
            }
        );
        this.currentDiffVersion = this.currentVersion;
        this.showImage = this.props.showImage;

        setTimeout(() => {
            // auto-publish page switches
            autorun(() => {
                if(this.props.onPageSwitch !== null && this.props.onPageSwitch !== undefined) {
                    this.props.onPageSwitch(this.page);
                }
            });

            // auto-set the diffPage when the current page changes
            autorun(() => {
                if(this.diff !== null && this.diff !== undefined) {
                    let index = 1;

                    for(let diffPage of this.diff.pages) {
                        if(diffPage.surfaceNumber === this.page) {
                            this.diffPage = index;
                            break;
                        }

                        index++;
                    }
                }
            });
        });
    }

    navigate(page) {
        this.page = page;
    }

    reportElement(div) {
        this.div = div;

        if(div !== null && this.props.onRendered !== null && this.props.onRendered !== undefined) {
            this.props.onRendered(div);
        }
    }

    chooseBranch(branch) {
        this.currentVersion = FetchDocumentBranch.run(
            this.props.appState,
            {
              select: {
                  document: { id: this.documentId },
                  name: branch.name
              }
            }
        );
        this.editing = false;
    }

    toggleBranchMode(isOn) {
        if(this.editing == isOn) return;

        this.editing = isOn;

        if(isOn) {
            this.currentDiffVersion = this.currentVersion;
            this.currentVersion = this.currentVersion.workingVersion;
        }
        else {
            this.currentVersion = this.currentDiffVersion = this.currentVersion.branchVersion;
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

    toggleDiff(isOn) {
        this.showDiff = isOn;
    }

    resetChanges() {
        ResetDocumentBranch.run(
            this.props.appState,
            {
                select: {
                    document: { id: this.documentId },
                    version: this.currentVersion
                }
            }
        );
    }

    commitChanges() {
       CommitDocumentChanges(
           this.props.appState,
           {
               select: {
                   document: { id: this.documentId },
                   version: this.currentVersion
               }
           }
       ).then((_) => {
           this.editing = false;
           this.chooseBranch(this.currentVersion.branchVersion);
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
       //this.props.metadata.saveAnnotation(
       //    this.documentId,
       //    this.currentVersion,
       //    annotation,
       //    this.lastSelectedGraphemes
       //);
    }

    saveLine(doc, line, editedText, boxes) {
        CorrectDocumentPage.run(
            this.props.appState,
            {
                select: {
                    document: { id: this.documentId },
                    pageNumber: this.page
                },
                line: line,
                text: editedText,
                boxes: boxes
            }
        ).then((_) => {
            this.showInlineEditor = false;
        });
    }

    saveNewBranch(name) {
        CreateDocumentBranch.run(
            this.props.appState,
            {
                select: {
                    document: { id: this.documentId },
                    version: this.currentVersion,
                    name: name
                }
            }
        ).then((newBranch) => {
            this.showNewBranchWindow = false;
            this.chooseBranch(newBranch);
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

    onDiffSwitch(page) {
        this.diffPage = page;
        this.page = this.diff.pages[ page - 1 ].surfaceNumber;
    }

    onDiffBranchSwitch(branch) {
        this.currentDiffVersion = FetchDocumentBranch.run(
            this.props.appState,
            {
              select: {
                  document: { id: this.documentId },
                  name: branch.name
              }
            }
        );
        this.diffPage = 1;
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

    renderSubmenu() {
        if(this.showDiff) {
            return (
                <div className="corpusbuilder-viewer-subcontext">
                    <DiffOptions diff={ this.diff }
                                 branches={ this.branches }
                                 page={ this.diffPage }
                                 currentDiffVersion={ this.currentDiffVersion }
                                 onDiffBranchSwitch={ this.onDiffBranchSwitch.bind(this) }
                                 onDiffSwitch={ this.onDiffSwitch.bind(this) }
                                 />
                </div>
            );
        }

        return null;
    }

    render() {
        let doc = this.document;
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
                                   showDiff={ this.showDiff }
                                   onBranchSwitch={ this.chooseBranch.bind(this) }
                                   onBranchModeToggle={ this.toggleBranchMode.bind(this) }
                                   onToggleCertainties={ this.toggleCertainties.bind(this) }
                                   onToggleAnnotations={ this.toggleAnnotations.bind(this) }
                                   onToggleBackground={ this.toggleBackground.bind(this) }
                                   onToggleDiff={ this.toggleDiff.bind(this) }
                                   onResetChangesRequest={ this.resetChanges.bind(this) }
                                   onCommitRequest={ this.commitChanges.bind(this) }
                                   onNewBranchRequest={ this.onNewBranchRequested.bind(this) }
                                   />
                </div>
                { this.renderSubmenu() }
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
                                   onSaveRequested={ this.saveNewBranch.bind(this) }
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
                  <DiffLayer diffWords={ this.diffWords }
                             document={ doc }
                             page={ page }
                             visible={ this.showDiff }
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
