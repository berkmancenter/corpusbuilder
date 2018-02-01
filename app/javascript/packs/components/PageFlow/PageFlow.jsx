import React from 'react'

import { computed, observable } from 'mobx';
import { observer } from 'mobx-react'

import { PageFlowItem } from '../PageFlowItem';

import s from './PageFlow.scss'

@observer
export default class PageFlow extends React.Component {

    root = null;

    @observable
    itemWidth = 0;

    @computed
    get items() {
        return this.props.children.filter((child) => {
            return child.type === PageFlowItem;
        });
    }

    @computed
    get currentItemOffset() {
        let index = 0;

        for(let item of this.items) {
            if(item.props.isActive) {
                return -1 * index * this.itemWidth;
            }
            index++;
        }

        return 0;
    }

    captureRoot(div) {
        if(div !== null) {
            this.root = div;
            this.itemWidth = div.offsetWidth;

            let domItems = div.getElementsByClassName("corpusbuilder-pageflow-item");

            for(let item of domItems) {
                item.style.width = this.itemWidth + "px";
            }
        }
    }

    render() {
        let canvasStyle = {
          width: this.items.length * this.itemWidth,
          transform: `translateX(${ this.currentItemOffset }px)`
        };

        return (
            <div ref={ this.captureRoot.bind(this) } className="corpusbuilder-pageflow">
                <div className="corpusbuilder-pageflow-canvas" style={ canvasStyle }>
                    { this.props.children }
                </div>
            </div>
        );
    }
}
