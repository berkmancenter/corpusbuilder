import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import { Highlight } from '../Highlight';
import { FloatingWindow } from '../FloatingWindow';
import { Button } from '../Button';

import DropdownMenu, { NestedDropdownMenu } from 'react-dd-menu';
import GraphemesUtils from '../../lib/GraphemesUtils';

import AnnotationsUtils from '../../lib/AnnotationsUtils';

import dropdownMenuStyles from '../../external/react-dd-menu/react-dd-menu.scss';
import styles from './AnnotationEditor.scss'

@observer
export default class AnnotationEditor extends React.Component {

    root = null;

    @observable
    editedAnnotation = "";

    @observable
    isMainMenuOpened = false;

    @observable
    chosenMode = null;

    @observable
    modes = {
        meta: true,
        isOpen: false,
        title: (() => { return this.currentMode.title }),
        comment: { title: 'Comment' },
        category: {
            title: 'Category',
            render: () => { return <input placeholder="Category" name="category"></input> }
        },
        structural: {
            meta: true,
            isOpen: false,
            title: 'Structure',
            header: { render: null, lines: true},
            blockquote: { render: null },
            p:  { render: null, lines: true }
        }
    }

    @computed
    get firstLine() {
        if(this.props.graphemes !== undefined) {
            return GraphemesUtils.lines(this.props.document.surfaces[0].graphemes).find((line) => {
                return line.find((g) => { return g.id === this.props.graphemes[0].id }) !== undefined;
            });
        }

        return [ ];
    }

    @computed
    get selection() {
        if(this.props.graphemes !== undefined) {
            if(this.currentMode.lines === true) {
                return this.firstLine;
            }
            else {
                return this.props.graphemes;
            }
        }

        return [ ];
    }

    @computed
    get currentMode() {
        return this.chosenMode || this.modes.comment;
    }

    initProps(props) {
        if(props.annotation !== undefined) {
            this.editedAnnotation = props.annotation.content;
            this.chooseMode(props.annotation.mode);
        }
    }

    componentWillMount() {
        this.initProps(this.props);
    }

    requestClose() {
        if(this.props.onCloseRequested !== undefined && this.props.onCloseRequested !== null) {
            this.props.onCloseRequested();
        }
    }

    chooseMode(mode) {
        if(typeof mode === 'string') {
            let lookup = (name, object) => {
                if(typeof object !== 'object') {
                    return undefined;
                }
                else if(object[ name ] !== undefined) {
                    return object[ name ];
                }
                else {
                    return Object.keys(object).map((key) => {
                        return lookup(name, object[ key ]);
                    }).filter((o) => { return o !== undefined })[0];
                }
            };

            this.chosenMode = lookup(mode, this.modes);
        }
        else {
            this.chosenMode = mode;
        }
    }

    onClickedOutside() {
        if(this.props.visible) {
            this.editedAnnotation = "";
            this.requestClose();
        }
    }

    onCancelRequested() {
        if(typeof this.props.onCancel === 'function') {
            this.props.onCancel();
        }
    }

    onAnnotationChanged(e) {
        this.editedAnnotation = e.target.value;
    }

    onEditorKeyUp(e) {
        if(e.ctrlKey && e.keyCode == 13) {
            this.onAnnotateEditorSave();
        }
    }

    onAnnotateEditorSave() {
        let payload = {};
        let formItems = this.root.querySelectorAll("form input, form select, form textarea");

        for(let element of formItems) {
            payload[ element.name ] = element.value;
        }

        this.requestClose();

        if(this.props.onSaveRequested !== null && this.props.onSaveRequested !== undefined) {
            this.props.onSaveRequested(this.selection, this.editedAnnotation, this.currentMode.key, payload);
        }

        this.editedAnnotation = "";
    }

    captureRoot(div) {
        this.root = div;
    }

    extractMenuItems(level) {
        return Object.keys(level)
                     .filter((key) => { return key !== 'meta' && key !== 'title' && key !== 'isOpen' && key !== 'render' && key !== 'key' })
                     .map((key) => {
                         let ret = {};

                         ret[ key ] = level[ key ];

                         return ret;
                     });
    }

    title(level, key) {
        return typeof level.title === "function" ? level.title() : (level.title || AnnotationsUtils.modeTitle(level.key));
    }

    renderMenu(menu = { root: this.modes }) {
        let key = Object.keys(menu)[0];
        let level = menu[ key ];

        if(typeof level === 'object') {
            level.key = key;
        }

        let toggle = ((on = false) => { level.isOpen = on }).bind(this);
        let title = '';
        if(key === 'root') {
            title = this.title(this.currentMode);
        }
        else {
            title = this.title(level);
        }
        let menuSpec = {
            isOpen: level.isOpen === true,
            close: toggle.bind(this, false),
            align: 'left',
            toggle: (
              <Button toggles={ true }
                      toggled={ level.isOpen === true }
                      onToggle={ toggle.bind(this, !level.isOpen) }
                      >
                          { title }
              </Button>
            )
        };
        let items = this.extractMenuItems(level);

        if(level === this.modes) {
            return (
              <DropdownMenu {...menuSpec}>
                  {
                      items.map((item) => {
                          return this.renderMenu(item)
                      })
                  }
              </DropdownMenu>
            );
        }
        else {
            if(level.meta === true) {
                return (
                  <NestedDropdownMenu key={ key } {...menuSpec}>
                      {
                          items.map((item) => {
                              return this.renderMenu(item)
                          })
                      }
                  </NestedDropdownMenu>
                );
            }
            else {
                return (
                    <li key={ key }>
                        <button type="button" onClick={ this.chooseMode.bind(this, level) }>
                            { level.title || AnnotationsUtils.modeTitle(key) }
                        </button>
                    </li>
                );
            }
        }
    }

    renderModeForm() {
        if(this.currentMode.render !== undefined && this.currentMode.render !== null) {
            return (
                <form>
                    { this.currentMode.render() }
                </form>
            );
        }
        else if(this.currentMode.render !== null) {
            return (
                <textarea onChange={ this.onAnnotationChanged.bind(this) }
                          onKeyUp={ this.onEditorKeyUp.bind(this) }
                          value={ this.editedAnnotation }
                          rows="5">
                </textarea>
            );
        }
    }

    renderMain() {
        return (
          <div className="corpusbuilder-annotation-editor">
              <div className="corpusbuilder-annotation-editor-menu">
                  { this.renderMenu() }
                  { this.props.inline ? null : <b>CTRL-Enter to save</b> }
              </div>
              { this.renderModeForm() }
              <div className="corpusbuilder-annotation-editor-buttons">
                  <Button onClick={ this.onCancelRequested.bind(this) }
                          visible={ this.props.inline === true }
                          >
                    Cancel
                  </Button>
                  <Button onClick={ this.onAnnotateEditorSave.bind(this) }>
                    Save
                  </Button>
              </div>
          </div>
        );
    }

    render() {
        if(!this.props.visible) {
            return null;
        }

        if(this.props.inline === true) {
            return (
                <div ref={ this.captureRoot.bind(this) }>
                    { this.renderMain() }
                </div>
            );
        }
        else {
            return (
                <div ref={ this.captureRoot.bind(this) }>
                    <FloatingWindow visible={ this.props.visible }
                                    onCloseRequested={ this.onClickedOutside.bind(this) }
                                    >
                        { this.renderMain() }
                    </FloatingWindow>
                    <Highlight graphemes={ this.selection }
                              document={ this.props.document }
                              page={ this.props.page }
                              width={ this.props.width }
                              mainPageTop={ this.props.mainPageTop }
                              />
                </div>
            );
        }

    }
}
