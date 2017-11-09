import React from 'react'
import { computed, observable } from 'mobx'
import { observer } from 'mobx-react'
import styles from './DocumentLine.scss'

@observer
export default class DocumentLine extends React.Component {

    get div() {
        return document.getElementById(this.elementId);
    }

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

    @computed
    get leftmostGrapheme() {
        let result = null;

        for(let element of this.props.line) {
            if(result === null || element.area.ulx < result.area.ulx) {
                result = element;
            }
        }

        return result;
    }

    @computed
    get rightmostGrapheme() {
        let result = null;

        for(let element of this.props.line) {
            if(result === null || element.area.lrx > result.area.lrx) {
                result = element;
            }
        }

        return result;
    }

    get letterSpacing() {
      if(this.canvasContext !== null) {
        console.log("Computing letter spacing");
        let origWidth = this.canvasContext.measureText(this.text).width;
        let width = this.rightmostGrapheme.area.lrx - this.leftmostGrapheme.area.ulx;
        let countChars = this.text.length;
        return (width * this.props.ratio - origWidth) / countChars;
      }
      return null;
    }

    get canvasContext() {
      if(this.div !== null && this.div !== undefined) {
        let computedStyles = window.getComputedStyle(this.div);
        let font = `${computedStyles["font-size"]} ${computedStyles["font-family"]}`;
        let canvas = document.createElement("canvas");
        let context = canvas.getContext("2d");
        context.font = font;
        return context;
      }
      else {
        return null;
      }
    }

    @computed
    get elementId() {
        return `corpusbuilder-document-line-${this.props.number}`;
    }

    render() {
        let dynamicStyles = {
            fontSize: this.fontSize,
            height: this.fontSize,
            top: this.top,
            left: this.left,
            letterSpacing: this.letterSpacing
        };

        if(this.letterSpacing === null) {
            setTimeout((() => {
                this.forceUpdate();
            }).bind(this), 10);
        }

        return (
            <div className="corpusbuilder-document-line"
                 key={ this.text }
                 style={ dynamicStyles }
                 id={ this.elementId }
                 >
               { this.text }
            </div>
        );
    }
}
