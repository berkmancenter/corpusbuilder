import React from 'react';

import State from '../../stores/State'

import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'
import { Viewer } from '../Viewer'

import { Button } from '../Button';
import { DocumentInfo } from '../DocumentInfo'
import { DocumentRevisionsBrowser } from '../DocumentRevisionsBrowser'

import DropdownMenu, { NestedDropdownMenu } from 'react-dd-menu';
import dropdownMenuStyles from '../../external/react-dd-menu/react-dd-menu.scss';

import Request from '../../lib/Request';

import styles from './WindowManager.scss';
import fontAwesome from 'font-awesome/scss/font-awesome.scss'

@observer
export default class WindowManager extends React.Component {

    constructor(props) {
        super(props);

        Request.setBaseUrl(props.baseUrl);

        window.onresize = this.onWindowResize.bind(this);
    }

    lastCountAll = 1000;

    @observable
    dockMode = false;

    @observable
    _numberOfViewers = 2;

    get numberOfViewers() { return this._numberOfViewers; }

    set numberOfViewers(number) {
        let diff = number - this.viewers.length;

        if(diff > 0) {
            (new Array(diff)).fill(0).forEach(
                (_, i) => {
                    this.viewers.push({ page: 1 });
                }
            );
        }
        else if(diff < 0) {
            (new Array(-1 * diff)).fill(0).forEach(
                (_, i) => {
                    this.viewers.pop();
                }
            );
        }

        this._numberOfViewers = number;
    }

    @observable
    currentMode = this.modes[0];

    @observable
    viewers = [
        {
            page: 1
        },
        {
            page: 2
        }
    ]

    @observable
    maxViewerHeight = 0;

    @computed
    get hasOneViewer() { return this.numberOfViewers === 1; }

    @computed
    get hasTwoViewers() { return this.numberOfViewers === 2; }

    @computed
    get hasThreeViewers() { return this.numberOfViewers === 3; }

    @computed
    get host() {
        return this.props.host;
    }

    get paneWidth() {
        if(this.dockMode) {
            return Math.floor(document.body.offsetWidth / this.numberOfViewers) - 40 - 20;
        }
        else {
            return Math.floor(this.host.offsetWidth / this.numberOfViewers) - 40;
        }
    }

    @computed
    get appState() {
        return new State(this.props.baseUrl);
    }

    @computed
    get sharedContext() {
        return {
            appState: this.appState,
            editorEmail: this.props.editorEmail
        };
    }

    @computed
    get allowImage() {
        return this.props.allowImage;
    }

    get modes() {
        return [
            {
                name: 'follow-next',
                title: 'Follow Next',
                arrange: ((_countAll, ix = 0, _page = null) => {
                    let page = _page === null ? this.viewers[ ix ].page : _page;
                    let countAll = _countAll || this.lastCountAll;

                    this.viewers.forEach((viewer, viewerIx) => {
                        let ixDiff = ix - viewerIx;

                        viewer.page = Math.max(
                            Math.min(
                                page - ixDiff,
                                countAll
                            ),
                            1
                        );
                    });
                }).bind(this)
            },
            {
                name: 'follow-current',
                title: 'Follow Page',
                arrange: ((countAll, ix = 0, _page = null) => {
                    let page = _page === null ? this.viewers[ ix ].page : _page;

                    for(let viewer of this.viewers) {
                        viewer.page = page;
                    }
                }).bind(this)
            },
            {
                name: 'independent',
                title: 'Independent',
                arrange: () => { /* no-op */ }
            }
        ];
    }

    setViewers(number) {
        this.numberOfViewers = number;
        this.currentMode.arrange();
    }

    onModeSwitch(mode) {
        this.currentMode = mode;

        this.currentMode.arrange();
    }

    onPageSwitch(viewer, ix, countAll, page) {
       viewer.page = page;

       this.lastCountAll = countAll;
       this.currentMode.arrange(countAll, ix, page);
    }

    onWindowResize(e) {
        if(this.dockMode) {
            this.forceUpdate();
        }
    }

    onViewerRendered(el) {
        this.maxViewerHeight = Math.max(this.maxViewerHeight, el.offsetHeight);
    }

    onToggleDockMode(isOn) {
        this.dockMode = isOn;
    }

    renderDocumentPanes() {
        return this.viewers.map((viewer, ix) => {
            return (
                <Viewer width={ this.paneWidth }
                    key={ ix }
                    page={ viewer.page }
                    documentId={ this.props.documentId }
                    allowImage={ this.allowImage }
                    onRendered={ this.onViewerRendered.bind(this) }
                    onPageSwitch={ this.onPageSwitch.bind(this, viewer, ix) }
                    />
            )
        })
    }

    @observable
    menuOpen = false;

    @computed
    get menu() {
        return {
            isOpen: this.menuOpen,
            close: (() => { this.menuOpen = false }).bind(this),
            toggle: (
              <Button toggles={ true }
                      onToggle={ (() => { this.menuOpen = !this.menuOpen }).bind(this) }>
                  <i className={ 'fa fa-files-o' } aria-hidden="true"></i>
                  &nbsp;
                  Mode: <b>{ this.currentMode.title }</b>
              </Button>
            ),
            align: 'left',
            upwards: false
        };
    }

    @computed
    get mainClasses() {
        let classes = [ "corpusbuilder-window-manager" ];

        if(this.dockMode) {
            classes.push("corpusbuilder-window-manager-dockmode");
        }

        return classes.join(' ');
    }

    renderNavigation() {
        return (
            <div className="corpusbuilder-global-options">
                <div className="corpusbuilder-global-options-viewers">
                    <Button toggles={ true } toggled={ this.hasOneViewer } onClick={ this.setViewers.bind(this, 1) }>
                        <i className="fa fa-align-justify"></i>
                    </Button>
                    <Button toggles={ true } toggled={ this.hasTwoViewers } onClick={ this.setViewers.bind(this, 2) }>
                        <i className="fa fa-align-justify"></i>
                        &nbsp;
                        <i className="fa fa-align-justify"></i>
                    </Button>
                    <Button toggles={ true } toggled={ this.hasThreeViewers } onClick={ this.setViewers.bind(this, 3) }>
                        <i className="fa fa-align-justify"></i>
                        &nbsp;
                        <i className="fa fa-align-justify"></i>
                        &nbsp;
                        <i className="fa fa-align-justify"></i>
                    </Button>
                    <span className="corpusbuilder-global-options-separator"></span>
                    {
                        this.modes.map((mode, ix) => {
                            return (
                                <Button toggles={ true }
                                        toggled={ this.currentMode.name === mode.name }
                                        onToggle={ this.onModeSwitch.bind(this, mode) }
                                        key={ ix }
                                        >
                                    { mode.title }
                                </Button>
                            )
                        })
                    }
                    <span className="corpusbuilder-global-options-separator"></span>
                    <Button toggles={ true } toggled={ this.dockMode } onToggle={ this.onToggleDockMode.bind(this) }>
                        <i className="fa fa-expand"></i>
                    </Button>
                </div>
            </div>
        );
    }

    render() {
        return (
          <div className={ this.mainClasses }>
              <Provider {...this.sharedContext}>
                  <div>
                      { this.renderDocumentPanes() }
                  </div>
              </Provider>
              { this.renderNavigation() }
          </div>
        )
    }
}
