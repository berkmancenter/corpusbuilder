import React from 'react'
import { computed } from 'mobx';
import { inject, observer } from 'mobx-react'
import state from '../../stores/State'
import s from './DocumentInfo.scss'

@inject('appState')
@observer
export default class DocumentInfo extends React.Component {

    @computed get info() {
        return null; // todo: implement me: this.props.documents.info(this.props.document.id);
    }

    render() {
        let content;

        let doc = this.props.document;
        let info = this.info;

        let countGraphemes = doc.surfaces.reduce((sum, surface) => {
          return sum + surface.graphemes.length;
        }, 0);

        let dynamicStyles = {
            height: this.props.height
        };

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
          <div style={ dynamicStyles } className="corpusbuilder-document-info">
            { content }
          </div>
        );
    }
}
