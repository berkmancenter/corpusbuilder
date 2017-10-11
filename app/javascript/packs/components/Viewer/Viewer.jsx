import React from 'react';
import ContentLoader from 'react-content-loader'
import s from './Viewer.scss'

export default class Viewer extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            document: null
        };
    }

    componentWillMount() {
        setTimeout(() => {
            this.setState({
                document: { name: "Good Read" }
            });
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
                { content }
            </div>
        );
    }
}
