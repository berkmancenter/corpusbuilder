import React from 'react';

import DropdownMenu, { NestedDropdownMenu } from 'react-dd-menu';
import dropdownMenuStyles from '../../external/react-dd-menu/react-dd-menu.scss';

import { Button } from '../Button';

import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'

import s from './DocumentPageSwitcher.scss'

@observer
export default class DocumentPageSwitcher extends React.Component {

    @observable
    menuOpen = false;

    @computed
    get menu()  {
        return {
            isOpen: this.menuOpen,
            close: (() => { this.menuOpen = false }).bind(this),
            toggle: (
              <Button toggles={ true }
                      onToggle={ (() => { this.menuOpen = !this.menuOpen }).bind(this) }>
                  Page: { this.props.page } / { this.props.document.global.surfaces_count }
              </Button>
            ),
            align: 'left',
            upwards: true
        };
    };

    periods(from, to) {
        let nP10 = (n, base = 0) => {
            if(n > Math.pow(10, base)) {
                return nP10(n, base + 1);
            }
            else {
                return Math.pow(10, base);
            }
        };

        let upperBound = nP10(to - from);
        let step = upperBound / 10;
        let results = [ ];
        let lastFrom = 0;
        let lastTo = from - 1;
        let iter = 1;

        while(lastTo < to) {
            lastFrom = lastTo + 1;
            lastTo = from + iter++ * step - 1;

            results.push([ lastFrom, Math.min(lastTo, to) ]);
        }

        return results;
    }

    renderOptions(from = null, to = null) {
        from = from === null ? 1 : from;
        to   = to   === null ? this.props.document.global.surfaces_count : to;

        return this.periods(from, to).map((period, ix) => {
            let periodFrom = period[0];
            let periodTo   = period[1];
            let submenu = null;
            submenu = observable({
                isOpen: false,
                close: (() => { submenu.isOpen = false }).bind(this),
                toggle: (
                    <Button toggles={ true }
                            onToggle={ (() => { submenu.isOpen = !submenu.isOpen }).bind(this) }>
                        { periodFrom } - { periodTo }
                    </Button>
                ),
                align: 'left',
                delay: 0,
                menuAlign: 'center'
            });
            let className = ix < 5 ? "corpusbuilder-nestedmenu-downwards" : "";

            if(periodTo - periodFrom < 10) {
                let subItems = (new Array(periodTo - periodFrom + 1)).fill(0).map((_, i) => {
                    let currentNumber = periodFrom + i;

                    return (
                      <li key={ `page-dropdown-${ period.join('-') }-${ i }` }>
                          <button type="button"
                                  onClick={ () => this.props.onPageSwitch(currentNumber) }
                                  >
                              { currentNumber === this.props.page ? `➜  ${ currentNumber }` : currentNumber }
                          </button>
                      </li>
                    )
                });
                return (
                    <div className={ className } key={ `page-dropdown-${ period.join('-') }` }>
                        <NestedDropdownMenu {...submenu}>
                            { subItems }
                        </NestedDropdownMenu>
                    </div>
                );
            }
            else {
                return (
                    <div className={ className } key={ `page-dropdown-${ period.join('-') }` }>
                        <NestedDropdownMenu {...submenu}>
                            { this.renderOptions( periodFrom, periodTo ) }
                        </NestedDropdownMenu>
                    </div>
                );
            }
        });
    }

    render() {
      if(this.props.document === undefined || this.props.document === null) {
          return null;
      }

      let page = this.props.page;
      let countPages = this.props.document.global.surfaces_count;

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
            <DropdownMenu {...this.menu}>
                { this.renderOptions() }
            </DropdownMenu>
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
