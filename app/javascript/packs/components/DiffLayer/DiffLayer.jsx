import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import { Highlight } from '../Highlight';
import { FloatingWindow } from '../FloatingWindow';
import { VisualPreview } from '../VisualPreview';

import styles from './DiffLayer.scss'

@observer
export default class DiffLayer extends React.Component {

    @observable
    openedDiff = null;

    @observable
    currentBoxes = [ ];

    @computed
    get hasPreviewOpened() {
        return this.openedDiff !== null;
    }

    @computed
    get afterText() {
        if(this.hasPreviewOpened) {
            return this.openedDiff.graphemes.map((g) => { return g.value }).join('');
        }
        else {
            return '';
        }
    }

    @computed
    get beforeText() {
        // todo: implement real logic:

        if(this.hasPreviewOpened) {
            return this.openedDiff.graphemes.map((g) => { return g.value }).join('');
        }
        else {
            return '';
        }
    }

    @computed
    get afterBranchName() {
        if(this.hasPreviewOpened) {
            return this.openedDiff.afterVersion.branchName;
        }

        return null;
    }

    @computed
    get beforeBranchName() {
        if(this.hasPreviewOpened) {
            return this.openedDiff.beforeVersion.branchName;
        }

        return null;
    }

    onClick(diffWord) {
        this.openedDiff = diffWord;
    }

    onPreviewCloseRequest() {
        this.openedDiff = null;
        this.currentBoxes = [ ];
    }

    onCurrentBoxesReported(boxes) {
        this.currentBoxes = boxes;
    }

    renderCurrentPreview() {
      if(this.hasPreviewOpened) {
          return (
              <VisualPreview pageImageUrl={ this.pageImageUrl }
                             line={ this.openedDiff.graphemes }
                             document={ this.props.document }
                             boxes={ this.currentBoxes }
                             showBoxes={ true }
                             editable={ false }
                             onBoxesReported={ this.onCurrentBoxesReported.bind(this) }
                             />
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
                          <div className="corpusbuilder-diff-label">
                            On { this.beforeBranchName }:
                          </div>
                          { this.renderCurrentPreview() }
                          <input disabled="disabled" value={ this.beforeText } />
                          <div className="corpusbuilder-diff-separator">
                            <i className="fa fa-hand-o-down" aria-hidden="true"></i>
                          </div>
                          <div className="corpusbuilder-diff-label">
                            On { this.afterBranchName }:
                          </div>
                          { this.renderCurrentPreview() }
                          <input disabled="disabled" value={ this.afterText } />
                      </div>
                    </FloatingWindow>
                    {
                        this.props.diffWords.map((diffWord, index) => {
                            return (
                                <Highlight key={ `diff-${index}` }
                                           onClick={ this.onClick.bind(this, diffWord) }
                                           variantClassName={ diffWord.status }
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
