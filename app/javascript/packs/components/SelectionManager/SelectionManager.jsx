import React from 'react'
import { computed, observable } from 'mobx';
import { observer } from 'mobx-react'
import GraphemesUtils from '../../lib/GraphemesUtils';

export default class SelectionManager extends React.Component {

    hasSelection() {
        let selection = window.getSelection();

        return selection.type === "Range";
    }

    selectedGraphemes() {
        let selection = window.getSelection();

        if(selection.type === "Range") {
            let selectedText = selection.toString();
            let startLineIx = parseInt(selection.anchorNode.parentElement.parentElement.id.match(/\d+/)[0]);
            let endLineIx = parseInt(selection.focusNode.parentElement.parentElement.id.match(/\d+/)[0]);
            let allLines = GraphemesUtils.lines(this.props.graphemes);
            let selectionLines = allLines.slice(startLineIx - 1, endLineIx);
            let selectionGraphemes = selectionLines.reduce((ret, line) => {
                for(let g of line) {
                    ret.push(g);
                }
                return ret;
            }, []);
            let selectionLinesText = selectionLines.map((line) => {
                return line.map((g) => { return g.value }).join('')
            }).join('');
            let match = selectionLinesText.match(
                selectedText.replace(/[#-.]|[[-^]|[?|{}]/g, '\\$&')
                            .replace(/\s+/g, '\\s*')
            );
            if(match !== null) {
                let currentIndex = match.index;
                let nonSpaces = Array.from(selectedText.replace(/\s/g, ''));
                let graphemes = [];

                while(nonSpaces.length > 0) {
                    let currentGrapheme = selectionGraphemes[ currentIndex++ ];
                    graphemes.push(currentGrapheme);

                    if(currentGrapheme.value !== " ") {
                        nonSpaces.pop();
                    }
                }

                console.log(graphemes.map((g) => { return g.value }).join(''));

                return graphemes;
            }
            return [ ];
        }


        return [];
    }

    onMouseUp(e) {
        let hasSelection = this.hasSelection();

        if(hasSelection) {
            this.props.onSelected(this.selectedGraphemes());
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
