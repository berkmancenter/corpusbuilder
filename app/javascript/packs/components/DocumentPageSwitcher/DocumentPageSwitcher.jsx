import React from 'react';

import { default as Dropdown } from 'react-simple-dropdown'
import { DropdownTrigger, DropdownContent } from 'react-simple-dropdown'
import { Button } from '../Button';

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
      let countPages = doc.global.surfaces_count;

      let pageOptions = (new Array(this.props.document.global.surfaces_count - 1)).fill(0).map(
          (_, surface) => {
              return (
                  <li key={ `page-dropdown-${ surface }` }
                      onClick={ () => this.props.onPageSwitch(surface + 1) }
                      >
                      { surface.number === page ? `* ${ surface + 1 }` : (surface + 1) }
                  </li>
              );
          }
      );

      return (
          <div className="corpusbuilder-document-page-switcher">
            <Button onClick={ () => this.props.onPageSwitch(1) }
                    disabled={ page == 1 }
                    >
              { '❙◀' }
            </Button>
            <Button onClick={ () => this.props.onPageSwitch(page - 1) }
                    disabled={ page == 1 }
                    >
              { '◀' }
            </Button>
            <Dropdown>
              <DropdownTrigger>Page: { page } / { doc.global.surfaces_count }</DropdownTrigger>
              <DropdownContent>
                <ul>
                  { pageOptions }
                </ul>
              </DropdownContent>
            </Dropdown>
            <Button onClick={ () => this.props.onPageSwitch(page + 1) } disabled={ page == countPages }>
              { '▶' }
            </Button>
            <Button onClick={ () => this.props.onPageSwitch(countPages) } disabled={ page == countPages }>
              { '▶❙' }
            </Button>
          </div>
      );
    }
}
