import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import { Highlight } from '../Highlight';
import { FloatingWindow } from '../FloatingWindow';
import { Button } from '../Button';

import DropdownMenu, { NestedDropdownMenu } from 'react-dd-menu';

import dropdownMenuStyles from '../../external/react-dd-menu/react-dd-menu.scss';
import styles from './AnnotationEditor.scss'

@observer
export default class AnnotationEditor extends React.Component {

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
        category: { title: 'Category' },
        structural: {
            meta: true,
            isOpen: false,
            title: 'Structure',
            h1: { title: 'Header 1' },
            h2: { title: 'Header 2' },
            h3: { title: 'Header 3' },
            h4: { title: 'Header 4' },
            h5: { title: 'Header 5' },
            p:  { title: 'Paragraph' }
        },
        biographical: {
            meta: true,
            isOpen: false,
            title: 'Biography',
            man: { title: 'Biography of a man' },
            woman: { title: 'Biography of a woman' },
            year_birth: { title: 'Year of birth' },
            year_death: { title: 'Year of death' },
            age: { title: 'Age in years' },
            person: { title: 'Person' }
        },
        analytical: {
            meta: true,
            isOpen: false,
            title: 'Analysis',
            administrative: { title: 'Administrative division' },
            route: { title: 'Route' }
        }
    }

    @computed
    get currentMode() {
        return this.chosenMode || this.modes.comment;
    }

    requestClose() {
        if(this.props.onCloseRequested !== undefined && this.props.onCloseRequested !== null) {
            this.props.onCloseRequested();
        }
    }

    chooseMode(mode) {
        this.chosenMode = mode;
    }

    onClickedOutside() {
        if(this.props.visible) {
            this.editedAnnotation = "";
            this.requestClose();
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
        this.requestClose();

        if(this.props.onSaveRequested !== null && this.props.onSaveRequested !== undefined) {
            this.props.onSaveRequested(this.editedAnnotation);
        }

        this.editedAnnotation = "";
    }

    extractMenuItems(level) {
        return Object.keys(level)
                     .filter((key) => { return key !== 'meta' && key !== 'title' && key !== 'isOpen' })
                     .map((key) => {
                         let ret = {};

                         ret[ key ] = level[ key ];

                         return ret;
                     });
    }

    renderMenu(menu = { root: this.modes }) {
        let key = Object.keys(menu)[0];
        let level = menu[ key ];
        let toggle = ((on = false) => { level.isOpen = on }).bind(this);
        let menuSpec = {
            isOpen: level.isOpen === true,
            close: toggle.bind(this, false),
            align: 'left',
            toggle: (
              <Button toggles={ true }
                      toggled={ level.isOpen === true }
                      onToggle={ toggle.bind(this, !level.isOpen) }
                      >
                      { typeof level.title === "function" ? level.title() : level.title }
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
                            { level.title }
                        </button>
                    </li>
                );
            }
        }
    }

    render() {
        if(!this.props.visible) {
            return null;
        }

        return (
            <div>
                <FloatingWindow visible={ this.props.visible }
                                onCloseRequested={ this.onClickedOutside.bind(this) }
                                >
                  <div className="corpusbuilder-annotation-editor">
                      <div className="corpusbuilder-annotation-editor-menu">
                          { this.renderMenu() }
                          <b>CTRL-Enter to save</b>
                      </div>
                      <textarea onChange={ this.onAnnotationChanged.bind(this) }
                                onKeyUp={ this.onEditorKeyUp.bind(this) }
                                value={ this.editedAnnotation }
                                rows="5">
                      </textarea>
                      <div className="corpusbuilder-annotation-editor-buttons">
                          <Button onClick={ this.onAnnotateEditorSave.bind(this) }>
                            Save
                          </Button>
                      </div>
                  </div>
                </FloatingWindow>,
                <Highlight graphemes={ this.props.graphemes }
                            document={ this.props.document }
                            page={ this.props.page }
                            width={ this.props.width }
                            mainPageTop={ this.props.mainPageTop }
                            />
            </div>
        );
    }
}
