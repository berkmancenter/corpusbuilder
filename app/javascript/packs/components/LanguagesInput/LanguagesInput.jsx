import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import { WithContext as ReactTags } from 'react-tag-input';

import styles from './LanguagesInput.scss';
import languages from './langs.json';

@inject('appState')
@observer
export default class LanguagesInput extends React.Component {

  get suggestedLanguages() {
      return languages;
  }

  @computed
  get suggestions() {
      return this.suggestedLanguages.map(lang => lang.name);
  }

  @computed
  get languageTags() {
      return this.languages.map((lang, ix) => { return { id: ix, text: lang.name } });
  }

  @computed
  get value() {
      return this.languages.map((c) => { return c.name }).join(', ');
  }

  @observable
  languages = [];

  handleDelete(ix) {
      this.languages.splice(ix, 1);
      this.broadcastLanguages();
  }

  handleAddition(tag) {
      let addingLanguage = this.suggestedLanguages.find(sug => sug.name === tag);

      if(addingLanguage !== undefined && addingLanguage !== null) {
          this.languages.push(addingLanguage);
          this.broadcastLanguages();
      }
  }

  broadcastLanguages() {
      if(typeof this.props.onChange === 'function') {
          this.props.onChange(this.languages);
      }
  }

  componentWillMount() {
      this.languages = this.props.languages === undefined ? [ ] : this.props.languages;
  }

  componentWillUnmount() {
      this.languages = [ ];
  }

  render() {
      return (
          <div className="corpusbuilder-languages-input">
              <input type="hidden" value={ this.value } name="languages" />
              <ReactTags tags={ this.languageTags }
                              autofocus={ true }
                              placeholder="Add language"
                              suggestions={ this.suggestions }
                              handleDelete={ this.handleDelete.bind(this) }
                              handleAddition={ this.handleAddition.bind(this) }
                              />
          </div>
      );
  }
}
