import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { Highlight } from '../Highlight';
import { FloatingWindow } from '../FloatingWindow';
import { VisualPreview } from '../VisualPreview';
import { Button } from '../Button';

import GraphemeUtils from '../../lib/GraphemesUtils';

import styles from './DiffLayer.scss'

@inject('measureText')
@inject('inferFont')
@observer
export default class DiffLayer extends React.Component {

    @observable
    openedDiff = null;

    @observable
    ratio = 1;

    @observable
    fontSize = 12;

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
            return this.openedDiff.word1[0].zone_direction === 1 ? "rtl" : "ltr";
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

    onCurrentBoxesReported(_, boxes) {
        this.currentBoxes = boxes;
    }

    onOtherBoxesReported(_, boxes) {
        this.otherBoxes = boxes;
    }

    @computed
    get beforeFont() {
      if(this.hasPreviewOpened && this.openedDiff !== null && this.openedDiff !== undefined) {
          return this.props.inferFont(this.openedDiff.beforeGraphemes);
      }
      return "";
    }

    @computed
    get afterFont() {
      if(this.hasPreviewOpened && this.openedDiff !== null && this.openedDiff !== undefined) {
          return this.props.inferFont(this.openedDiff.afterGraphemes);
      }
      return "";
    }

    renderPreview(mode) {
        if(this.hasPreviewOpened) {
            let hasDiff = mode === "after" ? this.openedDiff.hasAfterDiff : this.openedDiff.hasBeforeDiff;
            let branchName = mode === "after" ? this.afterBranchName : this.beforeBranchName;
            let graphemes = mode === "after" ? this.openedDiff.graphemes : this.openedDiff.otherGraphemes;
            let boxes = mode === "after" ? this.currentBoxes : this.otherBoxes;
            let onReported = mode === "after" ? this.onCurrentBoxesReported.bind(this) : this.onOtherBoxesReported.bind(this);
            let dir = mode === "after" ? this.afterDir : this.beforeDir;
            let text = mode === "after" ? this.openedDiff.afterText : this.openedDiff.beforeText;

            if(hasDiff) {
                let box = boxes[0];
                let inputStyles = {};

                if(box !== undefined) {
                    let fontSize = (box.lry - box.uly) * this.ratio;
                    let boxWidth = (box.lrx - box.ulx) * this.ratio;
                    let font = mode === "after" ? this.afterFont : this.beforeFont
                    let textWidth = this.props.measureText(text, fontSize, font);
                    let scale = textWidth > 0 ? boxWidth / textWidth : 1;

                    scale = scale > 2 ? 1 : scale;

                    inputStyles = {
                        left: box.ulx,
                        width: textWidth,
                        transform: `scaleX(${ scale })`,
                        fontSize: fontSize,
                        fontFamily: font
                    };
                }

                return [
                    <div key={ mode } className="corpusbuilder-diff-label">
                      On { branchName }:
                    </div>,
                    <VisualPreview key={ 5 } pageImageUrl={ this.pageImageUrl }
                                  line={ graphemes }
                                  document={ this.props.document }
                                  boxes={ boxes }
                                  showBoxes={ true }
                                  editable={ false }
                                  onBoxesReported={ onReported }
                                  />,
                    <div className="corpusbuilder-diff-input-wrapper" key={ mode + "input" }>
                        <input style={ inputStyles } disabled="disabled" dir={ dir } value={ text } />
                    </div>
                ];
            }
            else {
                return (
                    <div className="corpusbuilder-diff-label">
                      On { branchName }:
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
                          { this.renderPreview("after") }
                          { this.renderCurrentButtons() }
                          <div className="corpusbuilder-diff-separator">
                            &nbsp;
                          </div>
                          { this.renderPreview("before") }
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
