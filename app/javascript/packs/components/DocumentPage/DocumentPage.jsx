import React from 'react'
import { inject, observer } from 'mobx-react'
import state from '../../stores/State'
import s from './DocumentPage.scss'

@inject('state')
@observer
export default class DocumentPage extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            document: props.document,
            surface: props.document.surfaces.find((surface) => {
                return surface.number == props.page;
            })
        };
    }

    render() {
        let doc = this.state.document;
        let surface = this.state.surface;

        let pageStyle = {
            backgroundImage: `url(${ surface.image_url })`,
            width: (surface.area.lrx - surface.area.ulx),
            height: (surface.area.lry - surface.area.uly)
        };

        return (
          <div className="corpusbuilder-document-page" style={ pageStyle }>
          </div>
        );
    }
}
