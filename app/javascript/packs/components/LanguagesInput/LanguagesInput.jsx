import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import { WithContext as ReactTags } from 'react-tag-input';

import styles from './LanguagesInput.scss'

@inject('appState')
@observer
export default class LanguagesInput extends React.Component {

  @computed
  get suggestedLanguages() {
      return [
          { name: "Arabic", code: "ara", type: "living" },
          { name: "English", code: "eng", type: "living" },
          { name: "Syriac", code: "syr", type: "living" }
      ];
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
      this.languages.push(this.suggestedLanguages.find(sug => sug.name === tag));
      this.broadcastLanguages();
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
                              placeholder="Add language used in the scans"
                              suggestions={ this.suggestions }
                              handleDelete={ this.handleDelete.bind(this) }
                              handleAddition={ this.handleAddition.bind(this) }
                              />
          </div>
      );
  }
}
