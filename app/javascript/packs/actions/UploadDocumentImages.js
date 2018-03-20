import { action } from 'mobx';

import Action from '../lib/Action';
import Selector from '../lib/Selector';

export default class UploadDocumentImages extends Action {
    async execute(state, selector, params) {
        let result = [ ];

        for(let file of params.files) {
           let payload = {
               file: file.file,
               name: file.file.name
           };

            let images = await this.post(`${state.baseUrl}/api/images`, file.file, null, (xhr) => {
                xhr.upload.onprogress = action((e) => {
                    file.progress = e.loaded / e.total;
                });
            });//}).then((images) => {
            //    file.progress = 1;


            //    return images;
            //});
            for(let image of images) {
                result.push(image);
            }

        }

        return result;
    }
}


