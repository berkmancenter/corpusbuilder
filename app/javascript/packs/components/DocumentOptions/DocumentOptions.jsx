import React from 'react';

import { default as Dropdown } from 'react-simple-dropdown'
import { DropdownTrigger, DropdownContent } from 'react-simple-dropdown'

import { observable, computed } from 'mobx';
import { Provider, observer } from 'mobx-react'

import s from './DocumentOptions.scss'
import dropdownStyles from 'react-simple-dropdown/styles/Dropdown.css'
import fontAwesome from 'font-awesome/scss/font-awesome.scss'

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
            <button className={ 'fa fa-map-o' } onClick={ () => this.props.onToggleCertainties() } />
            <button className={ 'fa fa-commenting' } onClick={ () => this.props.onToggleAnnotations() } />
            <button className={ 'fa fa-file-image-o' } onClick={ () => this.props.onToggleBackground() } />
            <div className="side-options">
              <Dropdown>
                <DropdownTrigger>
                  <i className={ 'fa fa-code-fork' } aria-hidden="true"></i>
                  &nbsp;
                  Branch: <b>{ this.props.currentBranch }</b>
                </DropdownTrigger>
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
