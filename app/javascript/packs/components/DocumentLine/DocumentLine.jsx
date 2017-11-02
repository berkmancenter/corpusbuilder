import React from 'react'
import { computed, observable } from 'mobx'
import { observer } from 'mobx-react'
import styles from './DocumentLine.scss'

@observer
export default class DocumentLine extends React.Component {

    @computed
    get text() {
        return this.props.line.reduce((sum, g) => {
            return `${sum}${g.value}`
        }, "");
    }

    @computed
    get fontSize() {
        return this.props.line
          .map((g) => { return g.area.lry - g.area.uly })
          .reduce((sum, height) => { return sum + height }, 0) * this.props.ratio / this.props.line.length;
    }

    @computed
    get left() {
        return this.props.line
            .reduce((min, g) => { return Math.min(min, g.area.ulx) }, 1e+22) * this.props.ratio;
    }

    @computed
    get top() {
        return this.props.line
            .reduce((min, g) => { return Math.min(min, g.area.uly) }, 1e+22) * this.props.ratio;
    }

    render() {
        let dynamicStyles = {
            fontSize: this.fontSize,
            height: this.fontSize,
            top: this.top,
            left: this.left
        };

        return (
            <div className="corpusbuilder-document-line"
                 key={ this.text }
                 style={ dynamicStyles }
                 >
               { this.text }
            </div>
        );
    }
}
