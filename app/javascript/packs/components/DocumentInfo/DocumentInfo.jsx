import React from 'react'
import { inject, observer } from 'mobx-react'
import state from '../../stores/State'
import s from './DocumentInfo.scss'

@inject('state')
@observer
export default class DocumentInfo extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            document: props.document
        };
    }

    render() {
        let content;
        let doc = this.state.document;
        let info = this.props.state.documentInfos.get(doc.id);
        let countGraphemes = doc.surfaces.reduce((sum, surface) => {
          return sum + surface.graphemes.length;
        }, 0);

        if(info !== undefined && info !== null) {
          content = (
            <div>
              <span className="label">Title:</span>
              <span className="value">{ info.title }</span>

              <span className="label">Author:</span>
              <span className="value">{ info.author }</span>

              <span className="label">Date:</span>
              <span className="value">{ info.date }</span>

              <span className="label">Total Number Of Characters:</span>
              <span className="value">{ countGraphemes }</span>
            </div>
          );
        }
        else {
        }

        return (
          <div className="corpusbuilder-document-info">
            { content }
          </div>
        );
    }
}
