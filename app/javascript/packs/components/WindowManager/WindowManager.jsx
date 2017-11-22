import React from 'react';
import state from '../../stores/State'
import * as qwest from 'qwest';
import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'
import { Viewer } from '../Viewer'
import { default as Dropdown } from 'react-simple-dropdown'
import { DropdownTrigger, DropdownContent } from 'react-simple-dropdown'

import Documents from '../../stores/Documents'
import Metadata from '../../stores/Metadata'
import Mouse from '../../stores/Mouse'

import styles from './WindowManager.scss';
import fontAwesome from 'font-awesome/scss/font-awesome.scss'
import dropdownStyles from 'react-simple-dropdown/styles/Dropdown.css'

@observer
export default class WindowManager extends React.Component {

    constructor(props) {
        super(props);

        qwest.base = props.baseUrl;
    }

    @observable
    currentMode = this.modes[0];

    @observable
    leftPage = 1;

    @observable
    rightPage = 2;

    @computed
    get sharedContext() {
        return {
            documents: new Documents(this.props.baseUrl, state),
            metadata: new Metadata(this.props.baseUrl, state),
            mouse: new Mouse(state)
        };
    }

    @computed
    get allowImage() {
        return this.props.allowImage;
    }

    get modes() {
        return [
            { name: 'follow-next', title: 'Follow Next' },
            { name: 'follow-current', title: 'Follow Current' },
            { name: 'independent', title: 'Independent Panes' }
        ];
    }

    onModeSwitch(mode) {
        this.currentMode = mode;

        if(this.currentMode.name === 'follow-next') {
            this.rightPage = this.leftPage + 1;
        }
        else if(this.currentMode.name === 'follow-current') {
            this.rightPage = this.leftPage;
        }
    }

    onLeftPageSwitch(page) {
        this.leftPage = page;

        if(this.currentMode.name === 'follow-next') {
            this.rightPage = page + 1;
        }
        else if(this.currentMode.name === 'follow-current') {
            this.rightPage = page;
        }
    }

    onRightPageSwitch(page) {
        this.rightPage = page;

        if(this.currentMode.name === 'follow-next') {
            this.leftPage = page - 1;
        }
        else if(this.currentMode.name === 'follow-current') {
            this.leftPage = page;
        }
    }

    render() {
        let modesOptions = this.modes.map((mode) => {
            return (
              <li key={ `mode-${ mode.name }` }
                  onClick={ () => this.onModeSwitch(mode) }
                  >
                  { this.currentMode.name === mode.name ? `* ${mode.title}` : mode.title }
              </li>
            );
        });

        return <div className="corpusbuilder-window-manager">
            <Provider {...this.sharedContext}>
                <div>
                    <div className="corpusbuilder-global-options">
                      <ul className={ 'corpusbuilder-tabs' }>
                        <li className={ 'corpusbuilder-tabs-active' }>
                          <i className={ 'fa fa-book' } aria-hidden="true"></i>
                            &nbsp;
                          Pages
                        </li>
                        <li>
                          <i className={ 'fa fa-info-circle' } aria-hidden="true"></i>
                            &nbsp;
                          Document Info
                        </li>
                        <li>
                          <i className={ 'fa fa-code-fork' } aria-hidden="true"></i>
                            &nbsp;
                          Versions
                        </li>
                      </ul>
                    </div>
                    <Viewer width={ 445 }
                            key={ 1 }
                            page={ this.leftPage }
                            documentId={ this.props.documentId }
                            allowImage={ this.allowImage }
                            onPageSwitch={ this.onLeftPageSwitch.bind(this) }
                            />
                    <Viewer width={ 445 }
                            key={ 2 }
                            page={ this.rightPage }
                            documentId={ this.props.documentId }
                            allowImage={ this.allowImage }
                            onPageSwitch={ this.onRightPageSwitch.bind(this) }
                            />
                    <div className={ 'corpusbuilder-window-manager-options' }>
                      <Dropdown>
                        <DropdownTrigger>
                          <i className={ 'fa fa-files-o' } aria-hidden="true"></i>
                          &nbsp;
                          Mode: <b>{ this.currentMode.title }</b>
                        </DropdownTrigger>
                        <DropdownContent>
                          <ul>
                            { modesOptions }
                          </ul>
                        </DropdownContent>
                      </Dropdown>
                    </div>
                </div>
            </Provider>
        </div>
    }
}
