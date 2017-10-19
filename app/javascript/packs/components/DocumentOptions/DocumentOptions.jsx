import React from 'react';

import { default as Dropdown } from 'react-simple-dropdown'
import { DropdownTrigger, DropdownContent } from 'react-simple-dropdown'

import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'

import s from './DocumentOptions.scss'
import dropdownStyles from 'react-simple-dropdown/styles/Dropdown.css'

export default class DocumentOptions extends React.Component {
    constructor(props) {
        super(props);
    }

    render() {
        let branchesOptions = this.props.branches.map(
            (branch) => {
                return (
                    <li key={ `branch-${ branch.revision_id }` }
                        onClick={ () => this.props.onBranchSwitch(branch) }
                        >
                        { this.props.currentBranch === branch.name ? `* ${branch.name}` : branch.name }
                    </li>
                );
            }
        );

        return (
          <div>
            <button onClick={ () => this.props.onToggleCertainties() }>
              { '▧' }
            </button>
            <button onClick={ () => this.props.onToggleInfo() }>
              { 'ℹ' }
            </button>
            <button onClick={ () => this.props.onToggleRevisions() }>
              { 'Ξ' }
            </button>
            <div className="side-options">
              <Dropdown>
                <DropdownTrigger>Branch: { this.props.currentBranch }</DropdownTrigger>
                <DropdownContent>
                  <ul>
                    { branchesOptions }
                  </ul>
                </DropdownContent>
              </Dropdown>
            </div>
          </div>
        );
    }
}
