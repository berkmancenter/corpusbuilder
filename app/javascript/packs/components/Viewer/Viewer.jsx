import React from 'react';
import { autorun, observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import State from '../../stores/State'

import GraphemesUtils from '../../lib/GraphemesUtils';
import PlatformUtils from '../../lib/PlatformUtils';

import FetchDocumentPage from '../../actions/FetchDocumentPage';
import FetchDocumentDiff from '../../actions/FetchDocumentDiff';
import FetchDocumentBranches from '../../actions/FetchDocumentBranches';
import FetchDocumentBranch from '../../actions/FetchDocumentBranch';
import FetchDocumentAnnotations from '../../actions/FetchDocumentAnnotations';
import CreateDocumentBranch from '../../actions/CreateDocumentBranch';
import CreateDocumentAnnotation from '../../actions/CreateDocumentAnnotation';
import CorrectDocumentAnnotation from '../../actions/CorrectDocumentAnnotation';
import DeleteDocumentAnnotation from '../../actions/DeleteDocumentAnnotation';
import ResetDocumentBranch from '../../actions/ResetDocumentBranch';
import RemoveDocumentBranch from '../../actions/RemoveDocumentBranch';
import CommitDocumentChanges from '../../actions/CommitDocumentChanges';
import CorrectDocumentPage from '../../actions/CorrectDocumentPage';
import MergeDocumentBranches from '../../actions/MergeDocumentBranches';
import GetMousePosition from '../../actions/GetMousePosition';
import ObserveMousePosition from '../../actions/ObserveMousePosition';

import { MouseManager } from '../MouseManager'
import { PopupMenu } from '../PopupMenu'
import { AnnotationEditor } from '../AnnotationEditor'
import { Annotations } from '../Annotations'
import { DocumentPage } from '../DocumentPage'
import { DocumentPageSwitcher } from '../DocumentPageSwitcher'
import { DocumentOptions } from '../DocumentOptions'
import { AnnotationsSettings } from '../AnnotationsSettings';
import { DiffOptions } from '../DiffOptions';
import { AnnotationsOptions } from '../AnnotationsOptions';
import { InlineEditor } from '../InlineEditor'
import { NewBranchWindow } from '../NewBranchWindow'
import { MergeBranchesWindow } from '../MergeBranchesWindow';
import { RemoveBranchWindow } from '../RemoveBranchWindow';
import { Button } from '../Button';
import { DiffLayer } from '../DiffLayer';
import { Spinner } from '../Spinner';
import { If } from '../If';

import s from './Viewer.scss'

@inject('appState')
@observer
export default class Viewer extends React.Component {

    div = null;

    @observable
    showDocumentPage = true;

    @observable
    showAnnotationsSettings = false;

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
    forceEditingBoxes = null;

    @observable
    showMergeWindow = false;

    @observable
    showBranchRemoval = false;

    @observable
    documentId = null;

    @observable
    lastSelectedGraphemes = null;

    @observable
    editingLine = null;

    @observable
    editingText = null;

    @observable
    editingVisual = null;

    @observable
    editingOptions = {};

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
    showComments = false;

    @observable
    showCategories = false;

    @observable
    showStructure = false;

    @computed
    get showAnnotations() {
        return this.showComments || this.showStructure || this.showCategories;
    }

    set showAnnotations(value) {
        if(value) {
            if(!this.showAnnotations) {
                this.showComments = true;
            }
            this.showDiff = false;
        }
        else {
            this.showComments = this.showCategories = this.showStructure = false;
        }
    }

    @computed
    get hasConflict() {
        if(this.document !== null && this.document !== undefined) {
            return this.document.global.count_conflicts !== null &&
                   parseInt(this.document.global.count_conflicts, 10) > 0
        }
    }

    @computed
    get page() {
        return this.props.page;
    }

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
                    otherVersion: this.currentDiffVersion,
                    pageNumber: this.page
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
    get annotations() {
        if(this.showAnnotations) {
            return FetchDocumentAnnotations.run(
                this.props.appState,
                {
                    select: {
                        document: { id: this.documentId },
                        version: this.currentVersion,
                        surfaceNumber: this.document.surfaces[0].number
                    }
                }
            );
        }
    }

    @computed
    get width() {
        return this.props.width;
    }

    @computed
    get ratio() {
        let width = this.document.surfaces[0].area.lrx - this.document.surfaces[0].area.ulx;

        return this.width / width;
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

        return this.ratio * this.document.surfaces[0].area.lry;
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

        this.props.appState.on('RemoveDocumentBranch', (selector) => {
            if(selector.version.name === this.currentVersion.name) {
                this.chooseBranch({ name: 'master' });
            }

            if(selector.version.name === this.currentDiffVersion.name) {
                this.onDiffBranchSwitch({ name: 'master' });
            }
        });

        setTimeout(() => {
            // auto-set the diffPage when the current page changes
            autorun(() => {
                if(this.showDiff && this.diff !== null && this.diff !== undefined && this.diff.pageCount !== 0) {

                  let ix = this.diff.pagesAffected.indexOf(this.page);

                  if(ix == -1) {
                    ix = 0;
                  }

                  if(this.diffPage !== this.diff.pagesAffected[ix]) {
                      this.diffPage = this.diff.pagesAffected[ix];

                      if(this.page !== this.diffPage) {
                          this.navigate(this.diffPage);
                      }
                  }
                }
            });
        });
    }

    navigate(page) {
        if(typeof this.props.onPageSwitch === 'function') {
            let countAll = this.document !== undefined && this.document !== null ?
                this.document.global.surfaces_count : 1000;
            this.props.onPageSwitch(countAll, page);
        }
    }

    reportElement(div) {
        this.div = div;

        if(div !== null && this.props.onRendered !== null && this.props.onRendered !== undefined) {
            this.props.onRendered(div);
        }
    }

    switchToDocumentPage() {
        this.showAnnotationsSettings = false;
        this.showDocumentPage = true;
    }

    chooseBranch(branch, options = { includeDiffVersion: false }) {
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

        if(options.includeDiffVersion) {
            this.onDiffBranchSwitch(this.currentVersion);
        }
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

        if(this.showDiff) {
            this.onDiffSwitch(1);
            this.showAnnotations = false;
        }
    }

    toggleShowConflictDiff() {
        this.showDiff = !this.showDiff;
        this.toggleBranchMode(this.showDiff);

        if(this.showDiff) {
            this.showAnnotations = false;
        }
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

    askForBranchRemoval() {
        this.showBranchRemoval = true;
    }

    commitChanges() {
       CommitDocumentChanges.run(
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

    onStructuralTaggingSettingsRequested() {
        this.showDocumentPage = false;
        this.showAnnotationsSettings = true;
    }

    editAnnotation() {
        // make sure the mouse event bubbling comes first
        setTimeout(() => {
            this.showPopup = false;
            this.showAnnotationEditor = true;

            if ( document.selection ) {
                document.selection.empty();
            } else if ( window.getSelection ) {
                window.getSelection().removeAllRanges();
            }
        }, 0);
    }

    saveAnnotation(selection, content, mode, payload) {
        let boxes = GraphemesUtils.lines(selection)
            .map(GraphemesUtils.wordToBox)
            .map((b) => { b.graphemes = undefined; return b })

        CreateDocumentAnnotation.run(
            this.props.appState,
            {
                select: {
                    document: { id: this.documentId },
                    version: this.currentVersion,
                    surfaceNumber: this.document.surfaces[0].number
                },
                content: content,
                areas: boxes,
                mode: mode,
                payload: payload
            }
        ).then((_) => {
            this.showAnnotationsEditor = false;
            this.showAnnotations = true;
        });
    }

    updateAnnotation(annotation, content, mode, payload) {
        CorrectDocumentAnnotation.run(
            this.props.appState,
            {
                select: {
                    document: { id: this.documentId },
                    version: this.currentVersion,
                    surfaceNumber: this.document.surfaces[0].number
                },
                id: annotation.id,
                content: content,
                mode: mode,
                payload: payload
            }
        ).then((_) => {
            this.showAnnotationsEditor = false;
            this.showAnnotations = true;
        });
    }

    deleteAnnotation(annotation) {
        DeleteDocumentAnnotation.run(
            this.props.appState,
            {
                select: {
                    document: { id: this.documentId },
                    version: this.currentVersion,
                    surfaceNumber: this.document.surfaces[0].number
                },
                id: annotation.id
            }
        )
    }

    onEditDiffRequested(diffWord) {
        ObserveMousePosition.run(
            this.props.appState,
            {
                select: '',
                x: this.showDiffMousePosition.x,
                y: this.showDiffMousePosition.y
            }
        );

        this.showInlineEditor = true;
        this.editingLine = diffWord.graphemes;
        this.editingText = diffWord.text;
        this.forceEditingBoxes = true;
    }

    onDiffPreviewClosed() {
    }

    onDiffPreviewOpened() {
        this.showDiffMousePosition = GetMousePosition.run(this.props.appState, { select: '' });
    }

    deleteLine(line) {
        CorrectDocumentPage.run(
            this.props.appState,
            {
                select: {
                    document: { id: this.documentId },
                    version: this.currentVersion,
                    pageNumber: this.page
                },
                surfaceNumber: this.document.surfaces[0].number,
                words: [
                  {
                    text: '',
                    grapheme_ids: line.map( (g) => { return g.id } ),
                    areas: []
                  }
                ]
            }
        ).then((_) => {
            this.showInlineEditor = false;
        });
    }

    saveLine(doc, words, direction) {
        CorrectDocumentPage.run(
            this.props.appState,
            {
                select: {
                    document: { id: this.documentId },
                    version: this.currentVersion,
                    pageNumber: this.page
                },
                surfaceNumber: this.document.surfaces[0].number,
                words: words,
                direction: direction
            }
        ).then((_) => {
            this.showInlineEditor = false;
        });
    }

    mergeBranches() {
        MergeDocumentBranches.run(
            this.props.appState,
            {
                select: {
                    document: { id: this.documentId },
                    branch: this.currentVersion.branchVersion,
                    otherBranch: this.currentDiffVersion.branchVersion
                }
            }
        ).then((_) => {
            this.showMergeWindow = false;
            this.showDiff = false;
        });
    }

    removeBranch() {
        RemoveDocumentBranch.run(
            this.props.appState,
            {
                select: {
                    document: { id: this.documentId },
                    version: this.currentVersion
                }
            }
        ).then((_) => {
            // this.chooseBranch({ name: 'master' });
            this.showBranchRemoval = false;
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
        ).then((_) => {
            this.showNewBranchWindow = false;
            this.chooseBranch({ name: name });
        });
    }

    hideAnnotationEditor() {
        this.showAnnotationEditor = false;
    }

    onInlineEditorArrow(up) {
        let inferNextLine = (givenIndex = null) => {
            let graphemes = this.document.surfaces[0].graphemes;
            let lines = GraphemesUtils.lines(graphemes);

            if(givenIndex === null) {
                let index = 0;

                for(let line of lines) {
                    if(line[0].id === this.editingLine[0].id) {
                        break;
                    }
                    index++;
                }

                let nextIndex = index + (up ? -1 : 1);
                return lines[ nextIndex ];
            }
            else {
                if(givenIndex === -1) {
                    return lines[ lines.length - 1];
                }
                else {
                    return lines[ givenIndex ];
                }
            }
        }

        let setLine = (nextLine) => {
            let nextText = GraphemesUtils.lineText(nextLine);

            this.editingLine = nextLine;
            this.editingText = nextText;
            this.editingVisual = null;
            this.showInlineEditor = true;
        }

        let nextLine = inferNextLine();

        if(nextLine !== undefined) {
            setLine(nextLine);
        }
        else {
            let origPage = parseInt(this.document.surfaces[0].number);
            autorun((reaction) => {
                if(this.document.surfaces[0].number === origPage) {
                    let page = this.document.surfaces[0].number + (up ? -1 : 1);
                    let countAll = this.document !== undefined && this.document !== null ?
                        this.document.global.surfaces_count : 1000;
                    this.props.onPageSwitch(countAll, page);
                }
                else {
                    let nextLine = inferNextLine(up ? -1 : 0);
                    setLine(nextLine);
                    reaction.dispose();
                }
            });
        }
    }

    hideInlineEditor() {
        this.showInlineEditor = false;
        this.forceEditingBoxes = null;
    }

    hideBranchRemoveWindow() {
        this.showBranchRemoval = false;
    }

    hideNewBranchWindow() {
        this.showNewBranchWindow = false;
    }

    hideMergeWindow() {
        this.showMergeWindow = false;
    }

    onLineClick(line, text, number, editing, options) {
        if(editing) {
            this.editingLine = line;
            this.editingText = text;
            this.editingVisual = null;
            this.editingOptions = options;
            this.showInlineEditor = true;
        }
    }

    onLineDrew(y, height, ratio) {
        this.editingLine = [ ];
        this.editingText = "";
        this.editingVisual = { y: y, height: height, ratio: ratio };
        this.editingOptions = {};
        this.showInlineEditor = true;
    }

    onDiffSwitch(page) {
        this.diffPage = page;

        let diffPage = this.diff.pagesAffected[page - 1];

        if(diffPage !== undefined) {
            this.navigate(diffPage);
        }
    }

    onMergeRequested() {
        this.showMergeWindow = true;
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

    componentDidUpdate() {
        this.reportElement(this.div);
    }

    renderSubmenu() {
        if(this.showDiff) {
            return (
                <div className="corpusbuilder-viewer-subcontext">
                    <DiffOptions diff={ this.diff }
                                 branches={ this.branches }
                                 page={ this.diffPage }
                                 document={ this.document }
                                 currentVersion={ this.currentVersion }
                                 currentDiffVersion={ this.currentDiffVersion }
                                 onDiffBranchSwitch={ this.onDiffBranchSwitch.bind(this) }
                                 onDiffSwitch={ this.onDiffSwitch.bind(this) }
                                 onMergeRequested={ this.onMergeRequested.bind(this) }
                                 onCommitRequested={ this.commitChanges.bind(this) }
                                 />
                </div>
            );
        }
        else if(this.showAnnotations) {
            return (
                <div className="corpusbuilder-viewer-subcontext">
                    <AnnotationsOptions document={ this.document }
                                        showComments={ this.showComments }
                                        showCategories={ this.showCategories }
                                        showStructure={ this.showStructure }
                                        onToggleComments={ ((on) => { this.showComments = on }).bind(this) }
                                        onToggleCategories={ ((on) => { this.showCategories = on }).bind(this) }
                                        onToggleStructure={ ((on) => { this.showStructure = on }).bind(this) }
                                        />
                </div>
            );
        }

        return null;
    }

    renderStatus() {
        if(this.hasConflict && this.currentVersion.editable) {
            return (
                <div className="corpusbuilder-viewer-status">
                    <div className="corpusbuilder-viewer-status-conflict">
                        <div className="corpusbuilder-viewer-status-conflict-message">
                            <span className="warning">Merge Conflict!</span>
                            <Button onClick={ this.toggleShowConflictDiff.bind(this) }>
                                { this.showDiff ? 'Hide' : 'Show' } differing words
                            </Button>
                        </div>
                    </div>
                </div>
            );
        }
        else if(this.editing) {
            return (
                <div className="corpusbuilder-viewer-status">
                    <div className="corpusbuilder-viewer-status-editing">
                        <span>
                            <i className="fa fa-info-circle"></i>
                            &nbsp;
                            <b>Edit mode:</b>
                            &nbsp;
                            Hold { PlatformUtils.specialKeyName() } to draw new lines
                        </span>
                    </div>
                </div>
            );
        }
    }

    renderOptionsBottom() {
        if(this.showDocumentPage) {
            return (
                <div className="corpusbuilder-options bottom">
                  <DocumentPageSwitcher document={ this.document }
                      page={ this.page || doc.surfaces[0].number }
                      onPageSwitch={ this.navigate.bind(this) }
                      />
                </div>
            );
        }
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
                                   onRemoveBranchRequest={ this.askForBranchRemoval.bind(this) }
                                   onCommitRequest={ this.commitChanges.bind(this) }
                                   onNewBranchRequest={ this.onNewBranchRequested.bind(this) }
                                   onStructuralTaggingSettingsRequested={ this.onStructuralTaggingSettingsRequested.bind(this) }
                                   />
                </div>
                { this.renderSubmenu() }
                <div className="corpusbuilder-viewer-contents" style={ contentStyles }>
                  <div className="corpusbuilder-viewer-contents-wrapper">
                    <DocumentPage document={ doc }
                                  page={ page }
                                  visible={ this.showDocumentPage }
                                  width={ width }
                                  editing={ this.editing }
                                  mainPageTop={ mainPageTop }
                                  documentMaxHeight={ this.documentMaxHeight }
                                  showCertainties={ this.showCertainties }
                                  showImage={ this.showImage }
                                  onSelected={ this.onSelected.bind(this) }
                                  onLineClick={ this.onLineClick.bind(this) }
                                  onLineDrew={ this.onLineDrew.bind(this) }
                                  >
                    </DocumentPage>
                    <AnnotationsSettings visible={ this.showAnnotationsSettings }
                                         onBackRequest={ this.switchToDocumentPage.bind(this) }
                                         >
                    </AnnotationsSettings>
                  </div>
                  <If cond={ this.showInlineEditor }>
                      <InlineEditor document={ doc }
                                    visible={ this.showInlineEditor }
                                    line={ this.editingLine }
                                    text={ this.editingText }
                                    visual={ this.editingVisual }
                                    showBoxes={ this.forceEditingBoxes }
                                    allowNewBoxes={ !this.forceEditingBoxes }
                                    page={ page }
                                    width={ width }
                                    visualOptions={ this.editingOptions }
                                    mainPageTop={ mainPageTop }
                                    onCloseRequested={ this.hideInlineEditor.bind(this) }
                                    onSaveRequested={ this.saveLine.bind(this) }
                                    onDeleteLineRequested={ this.deleteLine.bind(this) }
                                    onArrow={ this.onInlineEditorArrow.bind(this) }
                                    />
                  </If>
                  <If cond={ this.showNewBranchWindow }>
                      <NewBranchWindow visible={ this.showNewBranchWindow }
                                      document={ doc }
                                      currentVersion={ this.currentVersion }
                                      onCloseRequested={ this.hideNewBranchWindow.bind(this) }
                                      onSaveRequested={ this.saveNewBranch.bind(this) }
                                      />
                  </If>
                  <If cond={ this.showBranchRemoval }>
                  <RemoveBranchWindow visible={ this.showBranchRemoval }
                                   document={ doc }
                                   currentVersion={ this.currentVersion }
                                   onCloseRequested={ this.hideBranchRemoveWindow.bind(this) }
                                   onRemoveBranchRequested={ this.removeBranch.bind(this) }
                                   />
                  </If>
                  <If cond={ this.showMergeWindow }>
                  <MergeBranchesWindow visible={ this.showMergeWindow }
                                   document={ doc }
                                   currentVersion={ this.currentVersion }
                                   otherVersion={ this.currentDiffVersion }
                                   onCloseRequested={ this.hideMergeWindow.bind(this) }
                                   onMergeRequested={ this.mergeBranches.bind(this) }
                                   />
                  </If>
                  <If cond={ this.showAnnotationEditor }>
                  <AnnotationEditor visible={ this.showAnnotationEditor }
                                    document={ doc }
                                    page={ page }
                                    width={ width }
                                    graphemes={ this.lastSelectedGraphemes }
                                    mainPageTop={ mainPageTop }
                                    onCloseRequested={ this.hideAnnotationEditor.bind(this) }
                                    onSaveRequested={ this.saveAnnotation.bind(this) }
                                    />
                  </If>
                  <If cond={ this.currentVersion }>
                      <Annotations visible={ this.showAnnotations }
                                  document={ doc }
                                  annotations={ this.annotations }
                                  version={ this.currentVersion }
                                  showComments={ this.showComments }
                                  showCategories={ this.showCategories }
                                  showStructure={ this.showStructure }
                                  page={ page }
                                  width={ width }
                                  mainPageTop={ mainPageTop }
                                  onSaveRequested={ this.updateAnnotation.bind(this) }
                                  onDeleteRequested={ this.deleteAnnotation.bind(this) }
                                  />
                  </If>
                  <If cond={ this.showDiff }>
                      <DiffLayer diffWords={ this.diffWords }
                                document={ doc }
                                visible={ this.showDiff }
                                page={ page }
                                width={ width }
                                mainPageTop={ mainPageTop }
                                hasConflict={ this.hasConflict }
                                onEditDiffRequested={ this.onEditDiffRequested.bind(this) }
                                onPreviewOpened={ this.onDiffPreviewOpened.bind(this) }
                                onPreviewClosed={ this.onDiffPreviewClosed.bind(this) }
                                />
                  </If>
                  { otherContent }
                </div>
                { this.renderStatus() }
                { this.renderOptionsBottom() }
                <PopupMenu visible={ this.showPopup }
                           onClickedOutside={ this.onPopupClickedOutside.bind(this) }
                           >
                  <Button onClick={ this.editAnnotation.bind(this) }>
                    { '✐ Annotate' }
                  </Button>
                </PopupMenu>
              </div>
            );
        }
        else {
            content = <Spinner />;
        }

        return (
            <div ref={ this.reportElement.bind(this) }
                 className={ `corpusbuilder-viewer ${ this.editing ? 'corpusbuilder-viewer-editing' : '' }` }
                 >
                <MouseManager>
                    { content }
                </MouseManager>
            </div>
        );
    }
}
