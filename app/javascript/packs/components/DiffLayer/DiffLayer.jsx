import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { Highlight } from '../Highlight';
import { FloatingWindow } from '../FloatingWindow';
import { VisualPreview } from '../VisualPreview';
import { Button } from '../Button';

import GraphemeUtils from '../../lib/GraphemesUtils';

import styles from './DiffLayer.scss'

@observer
export default class DiffLayer extends React.Component {

    @observable
    openedDiff = null;

    @observable
    currentBoxes = [ ];

    @observable
    otherBoxes = [ ];

    @computed
    get hasPreviewOpened() {
        return this.openedDiff !== null;
    }

    @computed
    get afterBranchName() {
        if(this.hasPreviewOpened) {
            return this.openedDiff.afterVersion.name;
        }

        return null;
    }

    @computed
    get beforeDir() {
        return this.afterDir;
    }

    @computed
    get afterDir() {
        if(this.hasPreviewOpened) {
            let line = GraphemeUtils.lines(this.props.document.surfaces[0].graphemes).find((line) => {
                return line.find((g) => {
                    return g.id === this.openedDiff.afterGraphemes[0].id;
                }) !== undefined;
            });

            if(line === undefined) {
                return null;
            }

            return line[0].value.codePointAt(0) === GraphemeUtils.rtlMark ? "rtl" : "ltr";
        }

        return null;
    }

    @computed
    get beforeBranchName() {
        if(this.hasPreviewOpened) {
            return this.openedDiff.beforeVersion.name;
        }

        return null;
    }

    onClick(diffWord) {
        this.openedDiff = diffWord;
        this.props.onPreviewOpened();
    }

    onPreviewCloseRequest() {
        this.openedDiff = null;
        this.currentBoxes = [ ];
        this.otherBoxes = [ ];
        this.props.onPreviewClosed();
    }

    onEditDiffRequested() {
        this.props.onEditDiffRequested(this.openedDiff);
        this.onPreviewCloseRequest();
    }

    onCurrentBoxesReported(boxes) {
        this.currentBoxes = boxes;
    }

    onOtherBoxesReported(boxes) {
        this.otherBoxes = boxes;
    }

    renderOtherPreview() {
      if(this.hasPreviewOpened) {
          if(this.openedDiff.hasBeforeDiff) {
              return [
                  <div key={ 1 } className="corpusbuilder-diff-label">
                    On { this.beforeBranchName }:
                  </div>,
                  <VisualPreview key={ 2 } pageImageUrl={ this.pageImageUrl }
                                line={ this.openedDiff.otherGraphemes }
                                document={ this.props.document }
                                boxes={ this.otherBoxes }
                                showBoxes={ true }
                                editable={ false }
                                onBoxesReported={ this.onOtherBoxesReported.bind(this) }
                                />,
                  <input key={ 3 } disabled="disabled" dir={ this.beforeDir } value={ this.openedDiff.beforeText } />
              ];
          }
          else {
              return (
                <div className="corpusbuilder-diff-label">
                  On { this.beforeBranchName }:
                  <div className="corpusbuilder-diff-nodata">---</div>
                </div>
              );
          }
      }

      return null;
    }

    renderPreview(mode) {
        if(this.hasPreviewOpened) {
            let hasDiff = mode === "after" ? this.openedDiff.hasAfterDiff : this.openedDiff.hasBeforeDiff;
            let branchName = mode === "after" ? this.afterBranchName : this.beforeBranchName;
            let graphemes = mode === "after" ? this.openedDiff.graphemes : this.openedDiff.otherGraphemes;
            let boxes = mode === "after" ? this.currentBoxes : this.otherBoxes;
            let onReported = mode === "after" ? this.onCurrentBoxesReported.bind(this) : this.onOtherBoxesReported.bind(this);
            let dir = mode === "after" ? this.afterDir : this.beforeDir;
        }
    }

    renderCurrentPreview() {
      if(this.hasPreviewOpened) {
          if(this.openedDiff.hasAfterDiff) {
              return [
                  <div key={ 4 } className="corpusbuilder-diff-label">
                    On { this.afterBranchName }:
                  </div>,
                  <VisualPreview key={ 5 } pageImageUrl={ this.pageImageUrl }
                                line={ this.openedDiff.graphemes }
                                document={ this.props.document }
                                boxes={ this.currentBoxes }
                                showBoxes={ true }
                                editable={ false }
                                onBoxesReported={ this.onCurrentBoxesReported.bind(this) }
                                />,
                  <input key={ 6 } disabled="disabled" dir={ this.afterDir } value={ this.openedDiff.afterText } />
              ];
          }
          else {
              return (
                  <div className="corpusbuilder-diff-label">
                    On { this.afterBranchName }:
                    <div className="corpusbuilder-diff-nodata">---</div>
                  </div>
              );
          }
      }

      return null;
    }

    renderCurrentButtons() {
        if(this.hasPreviewOpened && this.openedDiff.hasAfterDiff && this.openedDiff.inConflict) {
            return (
                <div className="corpusbuilder-diff-conflict-options">
                    <Button toggles={ false }
                            onClick={ this.onEditDiffRequested.bind(this, this.openedDiff) }>
                        Edit To Resolve Conflict
                    </Button>
                </div>
            );
        }

        return null;
    }

    render() {
        if(this.props.visible) {
            return (
                <div className="corpusbuilder-diff">
                    <FloatingWindow visible={ this.hasPreviewOpened }
                                    onCloseRequested={ this.onPreviewCloseRequest.bind(this) }
                                    >
                      <div className="corpusbuilder-diff-preview">
                          { this.renderCurrentPreview() }
                          { this.renderCurrentButtons() }
                          <div className="corpusbuilder-diff-separator">
                            &nbsp;
                          </div>
                          { this.renderOtherPreview() }
                      </div>
                    </FloatingWindow>
                    {
                        this.props.diffWords.map((diffWord, index) => {
                            return (
                                <Highlight key={ `diff-${index}` }
                                           onClick={ this.onClick.bind(this, diffWord) }
                                           variantClassName={ diffWord.allStatuses }
                                           graphemes={ diffWord.graphemes }
                                           document={ this.props.document }
                                           mainPageTop={ this.props.mainPageTop }
                                           page={ this.props.page }
                                           width={ this.props.width }
                                           content={ diffWord.text }
                                           />
                            );
                        })
                    }
                </div>
            )
        }
        else {
            return null;
        }
    }
}
