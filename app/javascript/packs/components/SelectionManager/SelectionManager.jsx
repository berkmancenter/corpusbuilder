import React from 'react'
import { computed, observable } from 'mobx';
import { observer } from 'mobx-react'

export default class SelectionManager extends React.Component {

    parentOf(node, nodeName, classMatch) {
        if(node === null || node === undefined) {
            return null;
        }

        if(node.nodeName === nodeName && node.className.match(classMatch)) {
            return node;
        }
        else {
            return this.parentOf(node.parentNode, nodeName, classMatch);
        }
    }

    nodeTotalOffsetTop(n) {
        if(n === undefined || n === null) {
            return 0;
        }
        else {
            return (n.offsetTop || 0) + this.nodeTotalOffsetTop(n.parentNode);
        }
    }

    nodeTotalOffsetLeft(n) {
        if(n === undefined || n === null) {
            return 0;
        }
        else {
            return (n.offsetLeft || 0) + this.nodeTotalOffsetLeft(n.parentNode);
        }
    }

    graphemeNodeForSelected(node) {
        return this.parentOf(node, "SPAN", this.props.selector);
    };

    documentRootForSelected(node) {
        return this.parentOf(node, "DIV", /selection-root\b/);
    };

    hasSelection() {
        let selection = window.getSelection();

        return selection.type === "Range";
    }

    selectedGraphemes() {
        let selection = window.getSelection();

        if(selection.type === "Range") {
            let startGraphemeNode = this.graphemeNodeForSelected(selection.baseNode);
            let endGraphemeNode = this.graphemeNodeForSelected(selection.focusNode);

            let selectedGraphemes = [];
            let documentRoot = this.documentRootForSelected(startGraphemeNode);
            let allNodes = documentRoot.getElementsByClassName('corpusbuilder-grapheme');
            let started = false;

            for(let node of allNodes) {
                if(node === startGraphemeNode) {
                    started = true;
                }

                if(started) {
                    selectedGraphemes.push(node);
                }

                if(node === endGraphemeNode) {
                    break;
                }
            }

            return selectedGraphemes;
        }

        return [];
    }

    onMouseUp(e) {
        let root = this.documentRootForSelected(e.target);
        let hasSelection = this.hasSelection();

        if(root !== null && root !== undefined && hasSelection) {
            let offsetTop = this.nodeTotalOffsetTop(root);
            let offsetLeft = this.nodeTotalOffsetLeft(root);
            let lastMouseX = e.pageX - offsetLeft;
            let lastMouseY = e.pageY - offsetTop;

            this.props.onSelected(this.selectedGraphemes(), lastMouseX, lastMouseY);
        }
        else {
            this.props.onDeselected();
        }
    }

    render() {
        return (
            <div className="selection-root" onMouseUp={ this.onMouseUp.bind(this) }>
                { this.props.children }
            </div>
        );
    }
}
