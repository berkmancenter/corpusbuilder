import React from 'react';
import { Provider, observer } from 'mobx-react'
import ContentLoader from 'react-content-loader'

import state from '../../stores/State'
import { Documents } from '../../stores/Documents'

import s from './Viewer.scss'

const context = {
    state: state,
    store: {
        documents: new Documents(state)
    }
};

@observer
export default class Viewer extends React.Component {
    constructor(props) {
        props.state = context.state;
        props.store = context.store;

        super(props);

        this.state = {
            document: null
        };
    }

    componentWillMount() {
        setTimeout(() => {
            this.props.store.documents.get("61389c62-b6a6-4339-b4c2-87fae4a6c0ab")
              .then((doc) => {
                this.setState({
                    document: doc
                });
              }
            );
        }, 3000);
    }

    render() {
        let content;

        if(this.state.document !== undefined && this.state.document !== null) {
            content = <i>Document here!</i>;
        }
        else {
            content = <ContentLoader type="facebook" />;
        }

        return (
            <div className="corpusbuilder-viewer">
                <Provider {...context}>
                    { content }
                </Provider>
            </div>
        );
    }
}
