import React from 'react'

export default class DocumentDataProvider extends React.Component {
    getChildContext() {
      const { documentId } = this.props
      return { documentId }
    }

    static childContextTypes = {
      documentId: React.PropTypes.string.isRequired
    }

    render() {
        return React.Children.only(this.props.children);
    }
}
