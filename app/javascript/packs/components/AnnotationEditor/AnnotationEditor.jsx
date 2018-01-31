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

    form = null;

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
            render: () => { return <input placeholder="Category" name="category"></input> },
        },
        structural: {
            meta: true,
            isOpen: false,
            title: 'Structure',
            h1: { title: 'Header 1', render: null},
            h2: { title: 'Header 2', render: null},
            h3: { title: 'Header 3', render: null},
            h4: { title: 'Header 4', render: null},
            h5: { title: 'Header 5', render: null},
            p:  { title: 'Paragraph', render: null }
        },
        biographical: {
            meta: true,
            isOpen: false,
            title: 'Biography',
            biography: {
                title: 'Biography',
                render: () => {
                    return (
                        <select name="sex">
                            <option value="female">Female</option>
                            <option value="male">Male</option>
                        </select>
                    )
                }
            },
            year_birth: {
                title: 'Year of birth',
                render: () => {
                    return <input placeholder="Year of birth" type="number" name="year" />
                }
            },
            year_death: {
                title: 'Year of death',
                render: () => {
                    return <input placeholder="Year of death" type="number" name="year" />
                }
            },
            age: {
                title: 'Age in years',
                render: () => {
                    return <input placeholder="Age" type="number" name="age" />
                }
            },
            person: {
                title: 'Person',
                render: () => {
                    return (
                        <select name="sex">
                            <option value="female">Female</option>
                            <option value="male">Male</option>
                        </select>
                    )
                }
            }
        },
        analytical: {
            meta: true,
            isOpen: false,
            title: 'Analysis',
            administrative: {
                title: 'Administrative division',
                render: () => {
                    return (
                        <div>
                            <div>
                                <input placeholder="Province" name="province"></input>
                            </div>
                            <div>
                                <input placeholder="Region" name="region"></input>
                            </div>
                            <div>
                                <input placeholder="Settlement" name="settlement"></input>
                            </div>
                        </div>
                    );
                }
            },
            route: {
                title: 'Route',
                render: () => {
                    return (
                        <div>
                            <div>
                                <input placeholder="From" name="from"></input>
                            </div>
                            <div>
                                <input placeholder="Towards" name="towards"></input>
                            </div>
                            <div>
                                <input placeholder="Distance" name="distance"></input>
                            </div>
                        </div>
                    )
                }
            }
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
        let payload = {};
        let formItems = this.form.querySelectorAll("input, select, textarea");

        for(let element of formItems) {
            payload[ element.name ] = element.value;
        }

        this.requestClose();

        if(this.props.onSaveRequested !== null && this.props.onSaveRequested !== undefined) {
            this.props.onSaveRequested(this.editedAnnotation, this.currentMode.key, payload);
        }

        this.editedAnnotation = "";
    }

    captureForm(form) {
        this.form = form;
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

        if(typeof level === 'object') {
            level.key = key;
        }

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

    renderModeForm() {
        if(this.currentMode.render !== undefined && this.currentMode.render !== null) {
            return (
                <form ref={ this.captureForm.bind(this) }>
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
                      { this.renderModeForm() }
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
