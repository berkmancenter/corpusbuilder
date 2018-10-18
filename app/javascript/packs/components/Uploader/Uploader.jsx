import React from 'react';

import { observable, computed, autorun } from 'mobx';
import { Provider, observer } from 'mobx-react'
import { PageFlow } from '../PageFlow';
import { PageFlowItem } from '../PageFlowItem';
import { Button } from '../Button';
import { LanguagesInput } from '../LanguagesInput';
import { ProgressIndicator } from '../ProgressIndicator';
import { Line } from 'rc-progress';
import Spinner from 'react-spinkit';
import { SortableContainer, SortableElement, arrayMove } from 'react-sortable-hoc';
import DropdownMenu, { NestedDropdownMenu } from 'react-dd-menu';

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

    @observable
    isUploading = false;

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
    backendMenuOpen = false;

    @observable
    backend = "tesseract";

    @computed
    get chosenBackendName() {
        return this.backend === "tesseract" ? "Tesseract" : "Kraken";
    }

    @computed
    get backendMenu()  {
        return {
            isOpen: this.backendMenuOpen,
            close: (() => { this.backendMenuOpen = false }).bind(this),
            toggle: (
              <Button toggles={ true }
                      onToggle={ (() => { this.backendMenuOpen = !this.backendMenuOpen }).bind(this) }>
                  { this.chosenBackendName }
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
                    backend: this.backend,
                    languages: this.languages.map(lang => lang.code)
                  },
                  backend: this.backend,
                  languages: this.languages.map(lang => lang.code)
                }
            )
        }

        return null;
    }

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
        this.onBackendChosen("tesseract");
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
            return f.file !== file;
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
            this.props.onBackendChosen(backend);
        }
    }

    onLanguagesPicked(languages) {
        this.languages = languages;

        if(typeof this.props.onLanguagesPicked === 'function') {
            this.props.onLanguagesPicked(languages);
        }
    }

    onSortEnd({oldIndex, newIndex}) {
        this.files = arrayMove(this.files, oldIndex, newIndex);
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
                    this.similarDocuments.map((doc) => {
                        let classes = [ "corpusbuilder-uploader-similar-documents-item" ];

                        if(doc == this.pickedDocument) {
                            classes.push('picked');
                        }

                        return [
                            <div key="list" className={ classes.join(' ') }>
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
                    <div className="corpusbuilder-uploader-similar-documents-list">
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
            return (
                <div className="corpusbuilder-uploader-images-ready">
                    Your uploads are ready. Please provide the list of languages being used
                    in the uploaded scans:

                    <div className="corpusbuilder-uploader-images-ready-backend">
                        <DropdownMenu {...this.backendMenu}>
                            <li>
                                <button type="button"
                                        onClick={ this.onBackendChosen.bind(this, "tesseract") }
                                        >
                                        Tesseract
                                </button>
                            </li>
                            <li>
                                <button type="button"
                                        onClick={ this.onBackendChosen.bind(this, "kraken") }
                                        >
                                        Kraken
                                </button>
                            </li>
                        </DropdownMenu>
                        <LanguagesInput languages={ this.languages } onChange={ this.onLanguagesPicked.bind(this) } />
                    </div>
                    { this.renderModelSelection() }
                </div>
            );
        }
    }

    renderModel(model) {
        return (
            <div className="corpusbuilder-uploader-model-selection-item">
                <div className="corpusbuilder-uploader-model-selection-item-name">{ model.name }</div>
                <div className="corpusbuilder-uploader-model-selection-item-description">{ model.description }</div>
                <div className="corpusbuilder-uploader-model-selection-item-languages">{ model.languages }</div>
                <div className="corpusbuilder-uploader-model-selection-item-scripts">{ model.scripts }</div>
                <div className="corpusbuilder-uploader-model-selection-item-version-code">{ model.version_code }</div>
            </div>
        );
    }

    renderModelSelection() {
        if(this.models !== null && this.models !== undefined) {
            let modelItems = this.models.map(this.renderModel.bind(this));

            return (
                <div className="corpusbuilder-uploader-model-selection">
                    <div className="corpusbuilder-uploader-model-selection-title">OCR Models found:</div>
                    { modelItems }
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
                </div>
            </Provider>
        );
    }
}
