import React from 'react';

import { observable, computed, autorun } from 'mobx';
import { Provider, observer } from 'mobx-react'
import { PageFlow } from '../PageFlow';
import { PageFlowItem } from '../PageFlowItem';
import { Button } from '../Button';
import { LanguagesInput } from '../LanguagesInput';
import { ProgressIndicator } from '../ProgressIndicator';
import { HelpIcon } from '../HelpIcon';
import { Line } from 'rc-progress';
import Spinner from 'react-spinkit';
import { SortableContainer, SortableElement, arrayMove } from 'react-sortable-hoc';
import DropdownMenu, { NestedDropdownMenu } from 'react-dd-menu';
import ReactTooltip from 'react-tooltip';

import State from '../../stores/State'
import FetchSimilarDocuments from '../../actions/FetchSimilarDocuments';
import FetchModels from '../../actions/FetchModels';
import UploadDocumentImages from '../../actions/UploadDocumentImages';
import Dropzone from 'react-dropzone'
import Request from '../../lib/Request';
import styles from './Uploader.scss';
import dropdownMenuStyles from '../../external/react-dd-menu/react-dd-menu.scss';

@observer
class BaseFile extends React.Component {

    @computed
    get file() {
        return this.props.value;
    }

    @observable
    preloaded = false;

    @computed
    get index() {
        return this.props.order;
    }

    @computed
    get isUploading() {
        return this.props.isUploading;
    }

    fileSizeLabel(file) {
        if(file === null) {
            return '';
        }

        if(file.size >= 10e5) {
            return `${Math.round(file.size / 10e5)}MB`
        }
        else {
            return `${Math.round(file.size / 10e2)}KB`
        }
    }

    fileProgress(file) {
      if(file.progress === null) {
          return undefined;
      }

      if(file.progress !== 2.0) {
          if(file.progress === 1.0) {
              return <Spinner name="ball-beat" color="#777" fadeIn="none" />;
          }
          else {
              return <Line percent={ Math.round(file.progress * 100) } strokeWidth="4" />;
          }
      }
      else {
          return <i className="fa fa-thumbs-up"></i>;
      }
    }

    onFileUnpickClicked() {
        if(typeof this.props.onFileUnpickClicked === 'function') {
            this.props.onFileUnpickClicked(this.file);
        }
    }

    render() {
        let actions = null;
        let progress = null;
        let handle = null;

        if(this.props.actions !== false) {
            actions = (
                <div className="corpusbuilder-uploader-images-upload-files-item-buttons">
                    <Button onClick={ this.onFileUnpickClicked.bind(this) }
                            classes={ [ 'delete' ] }
                            disabled={ this.isUploading }>
                        <i className="fa fa-trash"></i>
                    </Button>
                </div>
            );
        }

        if(this.props.progress !== false) {
            let _class = "corpusbuilder-uploader-images-upload-files-item-progress";

            if(this.file.progress >= 1.0) {
                _class += " corpusbuilder-uploader-images-upload-files-item-progress-done"
            }

            progress = (
                <div className={ _class }>
                    { this.fileProgress(this.file) }
                </div>
            );
        }

        if(this.props.handle !== false) {
            handle = (
                <span>
                    <i className="fa fa-bars"></i>
                    &nbsp;
                </span>
            );
        }

        return (
            <div className="corpusbuilder-uploader-images-upload-files-item">
                <div className="corpusbuilder-uploader-images-upload-files-item-number">
                    { handle }
                    { this.index + 1 }
                </div>
                <div className="corpusbuilder-uploader-images-upload-files-item-name">
                    { this.file.name }
                </div>
                { progress }
                <div className="corpusbuilder-uploader-images-upload-files-item-size">
                    { this.fileSizeLabel(this.file.file) }
                </div>
                { actions }
            </div>
        );
    }
};
const SortableFile = SortableElement(BaseFile);

@observer
class BaseList extends React.Component {
    render() {
        return (
            <div className="corpusbuilder-uploader-images-upload-files">
                {
                    this.props.items.map(
                          (value, index) => (
                              <SortableFile key={ `item-${index}` }
                                            index={ index }
                                            value={ value }
                                            onFileUnpickClicked={ this.props.onFileUnpickClicked }
                                            order={ index }
                                            />
                          )
                    )
                }
            </div>
        );
    }
};
const SortableFileList = SortableContainer(BaseList);

@observer
export default class Uploader extends React.Component {

    progressEvents = [
        {
            name: 'FetchSimilarDocuments',
            title: <div>
              Searching for documents for given metadata...
            </div>
        },
        {
            name: 'FetchModels',
            title: <div>
              Searching for OCR models...
            </div>
        }
    ];

    allBackends = [
        {
            code: 'tesseract',
            label: 'Tesseract',
            description: `
              Tesseract OCR engine by Google
            `
        },
        {
            code: 'kraken',
            label: 'Kraken',
            description: `
              Kraken OCR engine by Benjamin Kiessling
            `
        }
    ];

    @observable
    isUploading = false;

    @observable
    showAllModels = false;

    @observable
    files = [ ];

    @observable
    languages = [ ];

    @observable
    preloaded = false;

    @observable
    uploadedImages = [ ];

    @observable
    metadata = null;

    @observable
    uploadNewChosen = false;

    @observable
    pickedDocument = null;

    @observable
    pickedModels = [];

    @observable
    backendMenuOpen = false;

    @computed
    get backendMenu()  {
        return {
            isOpen: this.backendMenuOpen,
            close: (() => { this.backendMenuOpen = false }).bind(this),
            toggle: (
              <Button toggles={ true }
                      onToggle={ (() => { this.backendMenuOpen = !this.backendMenuOpen }).bind(this) }>
                  { this.backend.label }
              </Button>
            ),
            align: 'left'
        };
    };

    @computed
    get similarDocuments() {
        if(this.isMetadataReady) {
            return FetchSimilarDocuments.run(
                this.appState,
                {
                  select: {
                    metadata: this.metadata
                  },
                  metadata: this.metadata
                }
            )
        }

        return null;
    }

    @computed
    get models() {
        if(this.languages !== null && this.languages !== undefined && this.languages.length > 0) {
            return FetchModels.run(
                this.appState,
                {
                  select: {
                    backend: this.backend.code,
                    languages: this.languages.map(lang => lang.code)
                  },
                  backend: this.backend.code,
                  languages: this.languages.map(lang => lang.code)
                }
            )
        }

        return null;
    }

    @computed
    get availableBackends() {
        if(this.props.backends !== undefined) {
            return this.allBackends.filter(backend => {
                return this.props.backends.includes(backend.code);
            });
        }

        return this.allBackends;
    }

    @observable
    backend = this.availableBackends[0];

    @computed
    get isMetadataReady() {
        return this.metadata !== undefined &&
            this.metadata !== null &&
            this.metadata.title !== undefined &&
            this.metadata.title !== null &&
            this.metadata.title !== "";
    }

    @computed
    get currentLevel() {
        if(this.preloaded || (this.uploadedImages.length > 0 && this.files.every(file => file.progress === 2.0))) {
            return 'images-ready';
        }
        else if(!this.isMetadataReady) {
            return 'pre-metadata';
        }
        else if(!this.uploadNewChosen) {
            return 'similar-documents';
        }
        else {
            return 'images-upload';
        }
    }

    @computed
    get sharedContext() {
        return {
            appState: this.appState,
            editorEmail: this.props.editorEmail
        };
    }

    constructor(props) {
        super(props);

        this.appState = new State(this.props.baseUrl);
        Request.setBaseUrl(props.baseUrl);
        this.onBackendChosen(this.backend);
    }

    componentWillUpdate(props) {
        if(props.metadata === null || props.metadata === undefined) {
            return;
        }

        for(let key of Object.keys(props.metadata)) {
            if(this.metadata === null || this.metadata[ key ] != props.metadata[ key ]) {
                this.metadata = props.metadata;
                return;
            }
        }

        if((this.props.images || []).length !== (props.images || []).length) {
            this.files = props.images.map(image => {
                return {
                  file: null,
                  progress: 1,
                  name: image.name,
                  id: image.id
                }
            });
            this.preloaded = true;
        }

        setTimeout(function() {
            ReactTooltip.rebuild();
        }, 200);
    }

    onDocumentPicked(doc) {
        if(doc === this.pickedDocument) {
            this.pickedDocument = null;

            if(typeof this.props.onDocumentUnpicked === 'function') {
                this.props.onDocumentUnpicked();
            }
        }
        else {
            if(this.props.onDocumentPicked !== undefined && this.props.onDocumentPicked !== null) {
                this.props.onDocumentPicked(doc);
            }

            this.pickedDocument = doc;
        }
    }

    onUploadNewChosen() {
        if(this.pickedDocument === null) {
            this.props.onDocumentUnpicked();
            this.pickedDocument = null;
        }

        this.uploadNewChosen = true;
    }

    onDrop(accepted, rejected) {
        for(let file of accepted) {
            this.files.push(observable({
                file: file,
                progress: null,
                name: file.name,
                status: 'initial'
            }));
        }
    }

    onBackToSimilarDocuments() {
        this.uploadNewChosen = false;
    }

    onFileUnpickClicked(file) {
        this.files = this.files.filter((f) => {
            return f.file.name !== file.name;
        });
    }

    onUploadClicked() {
        this.isUploading = true;

        UploadDocumentImages.run(
            this.appState,
            {
                select: {},
                files: this.files
            }
        ).then((images) => {
            this.uploadedImages = images;

            if(typeof this.props.onImagesUploaded === 'function') {
                this.props.onImagesUploaded(images);
            }
        });
    }

    onBackendChosen(backend) {
        this.backend = backend;

        if(typeof this.props.onBackendChosen === 'function') {
            this.props.onBackendChosen(backend.code);
        }
    }

    onLanguagesPicked(languages) {
        this.languages = languages;
        this.pickedModels.clear();

        if(typeof this.props.onLanguagesPicked === 'function') {
            this.props.onLanguagesPicked(languages);
        }
    }

    onModelChanged(model) {
        return (function(event) {
            if(event.target.checked) {
                this.pickedModels.push(model);
            }
            else {
                this.pickedModels = this.pickedModels.filter(_model => _model.id !== model.id);
            }

            if(typeof this.props.onModelsPicked === 'function') {
                this.props.onModelsPicked(this.pickedModels);
            }
        }).bind(this);
    }

    onSortEnd({oldIndex, newIndex}) {
        this.files = arrayMove(this.files, oldIndex, newIndex);
    }

    onAllModelsToggle(_) {
        this.showAllModels = !this.showAllModels;
    }

    renderPreMeta() {
        if(this.currentLevel === 'pre-metadata') {
            return (
                <div className="corpusbuilder-uploader-explain">
                    You must provide document metadata first. At least the document
                    title is required to send the scans to be OCR'ed.
                </div>
            );
        }
    }

    renderSimilarDocuments() {
        if(this.currentLevel === 'similar-documents') {
            let items = null;
            if(this.similarDocuments === undefined || this.similarDocuments === null) {
                items = <i>Fetching similar documents, please wait...</i>;
            }
            else if(this.similarDocuments.length > 0) {
                let docItems =
                    this.similarDocuments.map((doc, ix) => {
                        let classes = [ "corpusbuilder-uploader-similar-documents-item" ];

                        if(doc == this.pickedDocument) {
                            classes.push('picked');
                        }

                        return [
                            <div key={ `list-${ix}` } className={ classes.join(' ') }>
                                <div className="corpusbuilder-uploader-similar-documents-item-top-label">
                                    Existing document:
                                </div>
                                <div className="corpusbuilder-uploader-similar-documents-item-body">
                                    <div className="corpusbuilder-uploader-similar-documents-item-row">
                                        <div className="corpusbuilder-uploader-similar-documents-item-label">
                                            Title:
                                        </div>
                                        <div className="corpusbuilder-uploader-similar-documents-item-value">
                                            { doc.title }
                                        </div>
                                    </div>
                                    <div className="corpusbuilder-uploader-similar-documents-item-row">
                                        <div className="corpusbuilder-uploader-similar-documents-item-label">
                                            Date:
                                        </div>
                                        <div className="corpusbuilder-uploader-similar-documents-item-value">
                                            { doc.date }
                                        </div>
                                    </div>
                                    <div className="corpusbuilder-uploader-similar-documents-item-row">
                                        <div className="corpusbuilder-uploader-similar-documents-item-label">
                                            Author:
                                        </div>
                                        <div className="corpusbuilder-uploader-similar-documents-item-value">
                                            { doc.author }
                                        </div>
                                    </div>
                                </div>
                                <div className="corpusbuilder-uploader-similar-documents-item-preview">
                                  <img src={ doc.images_sample[0].url } />
                                </div>
                                <Button onClick={ this.onDocumentPicked.bind(this, doc) }>
                                    { doc === this.pickedDocument ? 'Unpick' : 'Pick' }
                                </Button>
                            </div>
                        ];
                    });
                docItems.push(
                    <div key="new-one" className="corpusbuilder-uploader-similar-documents-item clickable"
                        onClick={ this.onUploadNewChosen.bind(this) }>
                        <div className="corpusbuilder-uploader-similar-documents-item-top-label-big">
                            +
                        </div>
                        <div className="corpusbuilder-uploader-similar-documents-item-top-label">
                            Add New
                        </div>
                    </div>
                );
                items = [
                    <div key="explain" className="corpusbuilder-uploader-explain">
                        If any of the following documents represent the one described
                        in the metadata: please click on the "Pick" button.
                        Otherwise, please click on next to continue.
                    </div>,
                    <div className="corpusbuilder-uploader-similar-documents-list">
                        { docItems }
                    </div>
                ];
            }
            else {
                let docItems = (
                    <div key="new-one" className="corpusbuilder-uploader-similar-documents-item clickable"
                        onClick={ this.onUploadNewChosen.bind(this) }>
                        <div className="corpusbuilder-uploader-similar-documents-item-top-label-big">
                            +
                        </div>
                        <div className="corpusbuilder-uploader-similar-documents-item-top-label">
                            Add New
                        </div>
                    </div>
                );
                items = [
                    <div key="explain" className="corpusbuilder-uploader-explain">
                      No similar document has been found for given metadata. Please click next to continue
                    </div>,
                    <div key="docItems" className="corpusbuilder-uploader-similar-documents-list">
                        { docItems }
                    </div>
                ];
            }

            return (
                <div className="corpusbuilder-uploader-similar-documents">
                    { items }
                </div>
            );
        }
    }

    renderImagesUpload() {
        if(this.currentLevel === 'images-upload') {
            let files = <i>No files chosen yet...</i>;
            let dropzone = null;

            if(this.files.length > 0) {
                files = <SortableFileList items={ this.files }
                                          pressDelay={ 200 }
                                          onSortEnd={ this.onSortEnd.bind(this) }
                                          onFileUnpickClicked={ this.onFileUnpickClicked.bind(this) }
                                          />;
            }

            if(!this.isUploading) {
                dropzone = (
                    <div className="corpusbuilder-uploader-images-upload-dropzone">
                        <Dropzone onDrop={this.onDrop.bind(this)} disabled={ this.isUploading }>
                            Drop Files Here
                        </Dropzone>
                    </div>
                );
            }

            return (
                <div className="corpusbuilder-uploader-images-upload">
                    { dropzone }
                    { files }
                    <div className="corpusbuilder-uploader-images-upload-buttons">
                        <Button onClick={ this.onBackToSimilarDocuments.bind(this) } disabled={ this.isUploading }>
                            Back
                        </Button>
                        <Button onClick={ this.onUploadClicked.bind(this) }
                                disabled={ this.files.length === 0 || this.isUploading }>
                            Upload!
                        </Button>
                    </div>
                </div>
            );
        }
    }

    renderImagesReady() {
        if(this.currentLevel === 'images-ready') {
            let items =
                this.availableBackends.map((backend, ix) =>
                        <li key={ `backend-${ix}` }>
                            <button type="button"
                                    onClick={ this.onBackendChosen.bind(this, backend) }
                                    data-tip={ backend.description }
                                    >
                                { backend.label }
                            </button>
                        </li>
                );

            let menu = items.length < 2 ? null :
                        <span>
                            <HelpIcon message="There are many OCR engines. They can differ in the algorithmic approach they employ. <br /> They also all have their own trained 'models' for different languages. <br /> Availability of those models vary per OCR backend. <br /> The following drop-down allows you to choose one to use on this document." />
                            <DropdownMenu {...this.backendMenu}>
                                {
                                    items
                                }
                            </DropdownMenu>
                        </span>;

            return (
                <div className="corpusbuilder-uploader-images-ready">
                    Your uploads are ready. Please provide the list of languages being used
                    in the uploaded scans:

                    <div className="corpusbuilder-uploader-images-ready-backend">
                        { menu }
                        <LanguagesInput languages={ this.languages } onChange={ this.onLanguagesPicked.bind(this) } />
                    </div>
                    { this.renderModelSelection() }
                </div>
            );
        }
    }

    renderList(name, items) {
        let domItems = items.map(item => {
            return (
                <div className="corpusbuilder-uploader-model-selection-item-list-item">
                    { item.name }
                </div>
            );
        });

        return (
            <div className="corpusbuilder-uploader-model-selection-item-list">
                <span className="corpusbuilder-uploader-model-selection-item-list-label">{ domItems.length > 0 ? name : '' }:</span>
                { domItems }
            </div>
        );
    }

    renderModelSamples(model) {
        if(model.samples.length > 0) {
            return model.samples.map((sample) => {
                return (
                    <div className="corpusbuilder-uploader-model-selection-item-images-item">
                        <img src={ sample } />
                    </div>
                );
            });
        }
        else {
            return null;
        }
    }

    renderModel(model) {
        let samplesLabel = (
            <div className="corpusbuilder-uploader-model-selection-item-images-label">
                Samples of lines the model was trained on:
            </div>
        );
        return (
            <div className="corpusbuilder-uploader-model-selection-item">
                <div className="corpusbuilder-uploader-model-selection-item-actions">
                    <input type='checkbox'
                           onChange={ this.onModelChanged.bind(this, model)() }
                           defaultChecked={ this.pickedModels.includes(model) }
                           />
                </div>
                <div className="corpusbuilder-uploader-model-selection-item-info">
                    <div className="corpusbuilder-uploader-model-selection-item-name">
                        { model.name }
                        <div className="corpusbuilder-uploader-model-selection-item-version-code">
                            (ver. { model.version_code })
                        </div>
                        <div className="corpusbuilder-uploader-model-selection-item-languages">
                            { this.renderList('Languages', model.languages) }
                        </div>
                        <div className="corpusbuilder-uploader-model-selection-item-scripts">
                            { this.renderList('Scripts', model.scripts) }
                        </div>
                    </div>
                    <div className="corpusbuilder-uploader-model-selection-item-description">
                      { model.description }
                    </div>
                    <div className="corpusbuilder-uploader-model-selection-item-images">
                        { model.samples.length > 0 ? samplesLabel : null }
                        { this.renderModelSamples(model) }
                    </div>
                </div>
            </div>
        );
    }

    renderModelSelection() {
        if(this.models !== null && this.models !== undefined) {
            let models = this.showAllModels ? this.models : this.models.slice(0, 4);

            let modelItems = models.map(this.renderModel.bind(this));

            let moreModelsToggle = this.models.length <= 5 ? null :
                <span className="corpusbuilder-uploader-model-selection-toggle">
                    <Button onClick={ this.onAllModelsToggle.bind(this) }>
                        { this.showAllModels ? 'Show First 5' : 'Show All' }
                    </Button>
                </span>;

            let moreModelsInfo = this.models.length <= 5 ? null :
                <div className="corpusbuilder-uploader-model-selection-more-models-bottom">
                    <span className="corpusbuilder-uploader-model-selection-more-models">
                        { this.models.length - 5 } models were omitted
                    </span>
                    <span className="corpusbuilder-uploader-model-selection-toggle">
                        <Button onClick={ this.onAllModelsToggle.bind(this) }>
                            { this.showAllModels ? 'Show first 5 only' : 'Show All' }
                        </Button>
                    </span>
                </div>;

            return (
                <div className="corpusbuilder-uploader-model-selection">
                    <div className="corpusbuilder-uploader-model-selection-title">
                        OCR Models found: ({ this.models.length })
                        <HelpIcon message="An OCR model contains the trained-information about <br /> the text found on images and about how to turn it into a digitalized-textual form. <br /> Usually each language has its own model, with some having many." />
                        { moreModelsToggle }
                    </div>
                    { modelItems }
                    { moreModelsInfo }
                </div>
            );
        }
        else {
            return null;
        }
    }

    render() {
        return (
            <Provider {...this.sharedContext}>
                <div className="corpusbuilder-uploader">
                    <ProgressIndicator events={ this.progressEvents }>
                    </ProgressIndicator>
                    <div className="corpusbuilder-uploader-title">Scans of documents to OCR</div>
                    <PageFlow>
                        <PageFlowItem isActive={ this.currentLevel === 'pre-metadata' }>
                            { this.renderPreMeta() }
                        </PageFlowItem>
                        <PageFlowItem isActive={ this.currentLevel === 'similar-documents' }>
                            { this.renderSimilarDocuments() }
                        </PageFlowItem>
                        <PageFlowItem isActive={ this.currentLevel === 'images-upload' }>
                            { this.renderImagesUpload() }
                        </PageFlowItem>
                        <PageFlowItem isActive={ this.currentLevel === 'images-ready' }>
                            { this.renderImagesReady() }
                        </PageFlowItem>
                    </PageFlow>
                    <ReactTooltip className="corpusbuilder-tooltip" multiline={true} />
                </div>
            </Provider>
        );
    }
}
