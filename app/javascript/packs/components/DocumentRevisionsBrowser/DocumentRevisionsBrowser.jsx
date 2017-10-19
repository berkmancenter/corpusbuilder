import React from 'react';

import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import s from './DocumentRevisionsBrowser.scss'

@inject('documents')
@observer
export default class DocumentRevisionsBrowser extends React.Component {

    @computed get revisions() {
        return this.props.documents.revisions(
            this.props.document.id,
            this.props.branchName
        ) || [];
    }

    render() {
        let revisionItems = this.revisions.map((revision) => {
            return (
                <div className="corpusbuilder-revision-item" key={ revision.id }>
                    <div className="corpusbuilder-revision-item-id">
                      { revision.id.slice(0, 8) }
                    </div>
                    <div className="corpusbuilder-revision-item-date">
                      { revision.updated_at.slice(0, 10) }
                    </div>
                    <div className="corpusbuilder-revision-item-actions">
                      <button>View</button>
                    </div>
                </div>
            );
        });

        return (
          <div className="corpusbuilder-revisions-browser">
            { revisionItems }
          </div>
        );
    }

}
