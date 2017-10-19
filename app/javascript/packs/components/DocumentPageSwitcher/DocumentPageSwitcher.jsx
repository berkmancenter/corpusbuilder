import React from 'react';

import { default as Dropdown } from 'react-simple-dropdown'
import { DropdownTrigger, DropdownContent } from 'react-simple-dropdown'

import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'

import s from './DocumentPageSwitcher.scss'
import dropdownStyles from 'react-simple-dropdown/styles/Dropdown.css'

@observer
export default class DocumentPageSwitcher extends React.Component {

    constructor(props) {
        super(props);
    }

    render() {
      if(this.props.document === undefined || this.props.document === null) {
          return null;
      }

      let doc = this.props.document;
      let firstSurface = this.props.document.surfaces[0];
      let page = this.props.page;
      let countPages = doc.surfaces.length;

      let pageOptions = this.props.document.surfaces.map(
          (surface) => {
              return (
                  <li key={ `page-dropdown-${ surface.id }` }
                      onClick={ this.props.onPageSwitch.bind(surface.number) }
                      >
                      { surface.number === page ? `* ${ surface.number }` : surface.number }
                  </li>
              );
          }
      );

      return (
          <div className="corpusbuilder-document-page-switcher">
            <button onClick={ () => this.props.onPageSwitch(firstSurface.number) }
                    disabled={ page == firstSurface.number }
                    >
              { '|←' }
            </button>
            <button onClick={ () => this.props.onPageSwitch(page - 1) }
                    disabled={ page == firstSurface.number }
                    >
              { '←' }
            </button>
            <Dropdown>
              <DropdownTrigger>Page: { page } / { doc.surfaces.length }</DropdownTrigger>
              <DropdownContent>
                <ul>
                  { pageOptions }
                </ul>
              </DropdownContent>
            </Dropdown>
            <button onClick={ () => this.props.onPageSwitch(page + 1) } disabled={ page == countPages }>
              { '→' }
            </button>
            <button onClick={ () => this.props.onPageSwitch(countPages) } disabled={ page == countPages }>
              { '→|' }
            </button>
          </div>
      );
    }
}
