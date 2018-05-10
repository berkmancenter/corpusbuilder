import { computed, observable } from 'mobx';
import FontLoader from '../lib/FontLoader';

export default class Font {
    @observable
    isLoaded = false;

    @observable
    hasError = false;

    @observable
    applied = false;

    @observable
    font = null;

    constructor(fontName, fontUrl, baseUrl) {
        this.fontName = fontName;
        this.fontUrl = fontUrl;
        this.baseUrl = baseUrl;

        let loader = new FontLoader();

        loader.onload = (_ => {
            this.font = loader;
            document.body.appendChild(loader.toStyleNode());

            setTimeout((_ => this.applied = true), 500);
        }).bind(this);

        loader.onerror = (msg => {
            console.error(msg);
            this.hasError = true;
        }).bind(this);

        loader.fontFamily = fontName;
        loader.src = this.url;
    }

    get url() {
        if(this.fontUrl.match(/https?:\/\/.*/)) {
            return this.fontUrl;
        }
        else {
            return `${this.baseUrl}${this.baseUrl.endsWith('/') ? '' : '/'}${this.fontUrl}`;
        }
    }

    @computed
    get ready() {
        return this.applied || this.font !== null;
    }

    @computed
    get failed() {
        return this.hasError;
    }

    @computed
    get loading() {
        return !this.ready && !this.failed;
    }

    @computed
    get familyName() {
        return this.fontName;
    }

    @computed
    get unitsPerEm() {
        return this.font.metrics.quadsize;
    }

    @computed
    get ascender() {
        return this.font.metrics.ascent * this.font.metrics.quadsize;
    }

    @computed
    get descender() {
        return this.font.metrics.descent * this.font.metrics.quadsize;
    }
}
