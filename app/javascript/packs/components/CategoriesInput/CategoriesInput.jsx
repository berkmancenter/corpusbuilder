import React from 'react';
import { observable, computed } from 'mobx';
import { inject, observer } from 'mobx-react'

import FetchDocumentCategories from '../../actions/FetchDocumentCategories';

import { WithContext as ReactTags } from 'react-tag-input';

import styles from './CategoriesInput.scss'

@inject('appState')
@observer
export default class CategoriesInput extends React.Component {

  @computed
  get suggestions() {
      return FetchDocumentCategories.run(
          this.props.appState,
          {
              select: {
                  document: { id: this.props.document.id }
              }
          }
      );
  }

  @computed
  get value() {
      return this.categories.map((c) => { return c.text }).join(', ');
  }

  @observable
  categories = [];

  handleDelete(ix) {
      this.categories.splice(ix, 1);
      this.broadcastCategories();
  }

  handleAddition(tag) {
      this.categories.push({id: this.categories.length + 1, text: tag});
      this.broadcastCategories();
  }

  broadcastCategories() {
      if(typeof this.props.onChange === 'function') {
          this.props.onChange(this.categories);
      }
  }

  componentWillMount() {
      this.categories = this.props.categories;
  }

  componentWillUnmount() {
      this.categories = [ ];
  }

  render() {
      return (
          <div className="corpusbuilder-categories-input">
              <input type="hidden" value={ this.value } name="categories" />
              <ReactTags tags={ this.categories }
                              autofocus={ true }
                              placeholder="Add category"
                              suggestions={ this.suggestions }
                              handleDelete={ this.handleDelete.bind(this) }
                              handleAddition={ this.handleAddition.bind(this) }
                              />
          </div>
      );
  }
}
