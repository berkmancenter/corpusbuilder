import React from 'react';
import state from '../../stores/State'
import * as qwest from 'qwest';
import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'
import { Viewer } from '../Viewer'
import { default as Dropdown } from 'react-simple-dropdown'
import { DropdownTrigger, DropdownContent } from 'react-simple-dropdown'
import { Button } from '../Button';
import { DocumentInfo } from '../DocumentInfo'
import { DocumentRevisionsBrowser } from '../DocumentRevisionsBrowser'

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
    currentTab = this.tabs[0];

    @observable
    leftPage = 1;

    @observable
    rightPage = 2;

    @observable
    maxViewerHeight = 0;

    @computed
    get host() {
        return this.props.host;
    }

    @computed
    get paneWidth() {
        return Math.floor(this.host.offsetWidth / 2) - 40;
    }

    @computed
    get document() {
        return this.sharedContext.documents.tree(
          this.props.documentId,
          'master',
          1
        );
    }

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

    get tabs() {
        return [
            { name: 'pages', title: 'Pages' },
            { name: 'info', title: 'Document Info' },
            { name: 'versions', title: 'Versions' }
        ];
    }

    @computed
    get modesOptions() {
        return this.modes.map((mode) => {
            return (
              <li key={ `mode-${ mode.name }` }
                  onClick={ () => this.onModeSwitch(mode) }
                  >
                  { this.currentMode.name === mode.name ? `➜ ${mode.title}` : mode.title }
              </li>
            );
        });
    }

    navigatePages() {
        this.currentTab = this.tabs[0];
    }

    navigateInfo() {
        this.currentTab = this.tabs[1];
    }

    navigateVersions() {
        this.currentTab = this.tabs[2];
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

    onViewerRendered(el) {
        this.maxViewerHeight = Math.max(this.maxViewerHeight, el.offsetHeight);
    }

    renderNavigation() {

        return null;

        return (
            <div className="corpusbuilder-global-options">
              <div className={ 'corpusbuilder-tabs' }>
                <Button onClick={ this.navigatePages.bind(this) }>
                    <div className={ this.currentTab.name === 'pages' ? 'corpusbuilder-tabs-active' : '' }>
                        <i className={ 'fa fa-book' } aria-hidden="true"></i>
                          &nbsp;
                        Pages
                    </div>
                </Button>
                <Button onClick={ this.navigateInfo.bind(this) }>
                    <div className={ this.currentTab.name === 'info' ? 'corpusbuilder-tabs-active' : '' }>
                        <i className={ 'fa fa-info-circle' } aria-hidden="true"></i>
                          &nbsp;
                        Document Info
                    </div>
                </Button>
                <Button onClick={ this.navigateVersions.bind(this) }>
                    <div className={ this.currentTab.name === 'versions' ? 'corpusbuilder-tabs-active' : '' }>
                        <i className={ 'fa fa-code-fork' } aria-hidden="true"></i>
                          &nbsp;
                        Versions
                    </div>
                </Button>
              </div>
            </div>
        );
    }

    renderDocumentPanes() {
        return (
            [
              <Viewer width={ this.paneWidth }
                    key={ 1 }
                    page={ this.leftPage }
                    documentId={ this.props.documentId }
                    allowImage={ this.allowImage }
                    onRendered={ this.onViewerRendered.bind(this) }
                    onPageSwitch={ this.onLeftPageSwitch.bind(this) }
                    />,
              <Viewer width={ this.paneWidth }
                      key={ 2 }
                      page={ this.rightPage }
                      documentId={ this.props.documentId }
                      allowImage={ this.allowImage }
                      onRendered={ this.onViewerRendered.bind(this) }
                      onPageSwitch={ this.onRightPageSwitch.bind(this) }
                      />
            ]
        );
    }

    renderPanesOptions() {
        return (
            <div className={ 'corpusbuilder-window-manager-options' } key={ 'pane-options' }>
              <Dropdown>
                <DropdownTrigger>
                  <i className={ 'fa fa-files-o' } aria-hidden="true"></i>
                  &nbsp;
                  Mode: <b>{ this.currentMode.title }</b>
                </DropdownTrigger>
                <DropdownContent>
                  <ul>
                    { this.modesOptions }
                  </ul>
                </DropdownContent>
              </Dropdown>
            </div>
        );
    }

    renderInfo() {
        return <DocumentInfo height={ this.maxViewerHeight } document={ this.document } />;
    }

    renderVersions() {
        return <DocumentRevisionsBrowser height={ this.maxViewerHeight }
                                         document={ this.document }
                                         branchName={ 'master' } />;
    }

    renderContent() {
        if(this.currentTab.name === 'pages') {
            return [
                this.renderDocumentPanes(),
                this.renderPanesOptions()
            ];
        }
        else if(this.currentTab.name === 'info') {
            return this.renderInfo();
        }
        else {
            return this.renderVersions();
        }
    }

    render() {
        return <div className="corpusbuilder-window-manager">
            <Provider {...this.sharedContext}>
                <div>
                    { this.renderNavigation() }
                    { this.renderContent() }
                </div>
            </Provider>
        </div>
    }
}
