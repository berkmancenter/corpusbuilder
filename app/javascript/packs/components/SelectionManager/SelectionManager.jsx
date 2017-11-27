import React from 'react'
import { computed, observable } from 'mobx';
import { observer } from 'mobx-react'

export default class SelectionManager extends React.Component {

    hasSelection() {
        let selection = window.getSelection();

        return selection.type === "Range";
    }

    selectedGraphemes() {
        let selection = window.getSelection();

        if(selection.type === "Range") {
            let selectedText = selection.toString();
            console.log(`Simplified selection contains ${selectedText.length} characters`);
            let match = this.props.graphemes.map((g) => {
                    return g.value;
                })
                .join('')
                .match(
                    selectedText.replace(/[#-.]|[[-^]|[?|{}]/g, '\\$&')
                                .replace(/\s+/g, '\\s*')
                );

            if(match !== null) {
                let currentIndex = match.index;
                let nonSpaces = Array.from(selectedText.replace(/\s/g, ''));
                let graphemes = [];

                while(nonSpaces.length > 0) {
                    let currentGrapheme = this.props.graphemes[ currentIndex++ ];
                    graphemes.push(currentGrapheme);

                    if(currentGrapheme.value !== " ") {
                        nonSpaces.pop();
                    }
                }

                console.log(graphemes.map((g) => { return g.value }).join(''));

                return graphemes;
            }
            else {
                return [];
            }
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
