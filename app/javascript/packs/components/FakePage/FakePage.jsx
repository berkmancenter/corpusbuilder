import React from 'react'
import ImageUtils from '../../lib/ImageUtils'
import styles from './FakePage.scss'

export default class FakePage extends React.Component {
    get processBackground() {
        // todo: get back to it once it's a bigger problem
        return false;
    }

    get imageSrc() {
        let value = this.props
                        .style
                        .backgroundImage;
        if(value !== null && value !== undefined) {
            return value.replace('url(', '')
                        .replace(')', '');
        }
        else {
            return '';
        }
    }

    setDiv(div) {
        if(this.processBackground === false || div === null || div === undefined || this.imageSrc === '') {
            return;
        }

        let image = new Image();
        image.crossOrigin = 'anonymous';

        image.addEventListener('load', () => {
            let canvas = document.createElement('canvas');
            let context = canvas.getContext('2d');

            context.drawImage(image, 0, 0);

            let data = context.getImageData(0, 0, image.width, image.height);
            let processed = ImageUtils.repeatTopBorder( data );

            context.putImageData(processed, image.width, image.height);

            div.style.backgroundImage = `url(${ canvas.toDataURL() })`;
        });

        image.src = this.imageSrc;
    }

    render() {
        return (
            <div className={ 'corpusbuilder-document-page simple' }
                ref={ (div) => { this.setDiv(div) } }
                style={ this.props.style }
              >
              &nbsp;
            </div>
        );
    }
}
