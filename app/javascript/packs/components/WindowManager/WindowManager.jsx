import React from 'react';

import State from '../../stores/State'

import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'
import { Viewer } from '../Viewer'

import { Button } from '../Button';
import { DocumentInfo } from '../DocumentInfo'
import { DocumentRevisionsBrowser } from '../DocumentRevisionsBrowser'
import { ProgressIndicator } from '../ProgressIndicator';
import { MessagesIndicator } from '../MessagesIndicator';

import DropdownMenu, { NestedDropdownMenu } from 'react-dd-menu';
import dropdownMenuStyles from '../../external/react-dd-menu/react-dd-menu.scss';

import Font from '../../models/Font';
import Request from '../../lib/Request';
import FontUtils from '../../lib/FontUtils';
import GraphemesUtils from '../../lib/GraphemesUtils';
import BoxesUtils from '../../lib/BoxesUtils';

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
    rulerCache = new Map();
    fontCache = new Map();
    measureCache = new Map();

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

    get zoomLevel() {
        return Math.round(window.outerWidth * 100 / window.innerWidth) / 100;
    }

    get paneWidth() {
        if(this.dockMode) {
            return this.zoomLevel * (
              Math.floor(document.body.offsetWidth / this.numberOfViewers) - 40 - 20
            );
        }
        else {
            return this.zoomLevel * (
              Math.floor(this.host.offsetWidth / this.numberOfViewers) - 40
            );
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
            editorEmail: this.props.editorEmail,
            measureText: this.measureText.bind(this),
            measureFontSize: this.measureFontSize.bind(this),
            inferFont: this.inferFont.bind(this),
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

    progressEvents = [
        {
            name: 'MergeDocumentBranches',
            title: <div>
              Merging document branches.<br />
              This can take a while...
            </div>
        },
        {
            name: 'CorrectDocumentPage',
            title: 'Applying corrections.'
        }
    ];

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

    get rulerId() {
        return `corpusbuilder-page-ruler-${this.props.documentId}`;
    }

    get ruler() {
        return document.getElementById(this.rulerId);
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

    measureText(text, fontSize, font) {
        let key = `${text}-${fontSize}-${font.familyName}`;

        if(this.rulerCache.has(key)) {
            return this.rulerCache.get(key);
        }

        this.ruler.textContent = text;
        this.ruler.style.fontFamily = font.familyName;
        this.ruler.style.fontSize = fontSize + "px";

        let result = this.ruler.offsetWidth;

        if(font.ready) {
            //this.rulerCache.set(key, result);
        }

        return result;
    }

    /* Computes the correct font-size to apply to graphemes
     * given the font and ratio - to make them visually fill
     * their union bounding box */
    measureFontSize(graphemes, font, ratio, wordBoxes = null) {
        if(wordBoxes === null || wordBoxes === undefined) {
          wordBoxes = GraphemesUtils.wordBoxes(graphemes);
        }

        let ids = graphemes.map(g => g.id).join('');
        let boxesKey = wordBoxes.map((i) => `${i.lrx}-${i.lry}-${i.ulx}-${i.uly}`).join('|');
        let key = `${ids}-${font.fontName}-${ratio}-${boxesKey}`;

        if(font.ready && this.measureCache.has(key)) {
            return this.measureCache.get(key);
        }

        let lineBox = BoxesUtils.union(wordBoxes);
        let lineHeight = (lineBox.lry - lineBox.uly) * ratio;

        if(font.ready) {
            let ascender10pxSize = 10 * font.ascender / font.unitsPerEm;
            let descender10pxSize = 10 * font.descender / font.unitsPerEm;
            let height10pxSize = Math.abs(ascender10pxSize) + Math.abs(descender10pxSize);
            let scalingFactor = lineHeight / height10pxSize;
            let fontSize = 10 * scalingFactor;

            this.measureCache.set(key, fontSize);

            return fontSize;
        }

        return (lineBox.lry - lineBox.uly) * ratio;
    }

    inferFont(graphemes) {
        let meta = FontUtils.inferFontName(graphemes);
        let fontName = meta.name;
        let fontUrl = meta.url;
        let font = null;

        if(this.fontCache.has(fontName)) {
            font = this.fontCache.get(fontName);
        }

        if(font === null || font.failed) {
            font = new Font(fontName, fontUrl, this.props.directUrl);
            this.fontCache.set(fontName, font);
        }

        return font;
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
        let optionsStyles = {
            width: `${ this.zoomLevel * 100 }%`
        };

        return (
            <div className="corpusbuilder-global-options" style={ optionsStyles }>
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
                      <ProgressIndicator events={ this.progressEvents }>
                      </ProgressIndicator>
                      <MessagesIndicator>
                      </MessagesIndicator>
                      { this.renderDocumentPanes() }
                  </div>
              </Provider>
              { this.renderNavigation() }
              <div id={ this.rulerId } className={ 'corpusbuilder-ruler' }>&nbsp;</div>
          </div>
        )
    }
}
