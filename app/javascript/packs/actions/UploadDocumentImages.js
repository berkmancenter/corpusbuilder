import { action } from 'mobx';

import Action from '../lib/Action';
import Selector from '../lib/Selector';

export default class UploadDocumentImages extends Action {
    execute(state, selector, params) {
        return new Promise((resolve, reject) => {
            let result = [ ];
            let caughtError = null;

            let uploads = params.files.map((file) => {
                let payload = {
                    file: file.file,
                    name: file.file.name
                };

                return (() => {
                    return this.post(`${state.baseUrl}/api/images`, file.file, (xhr) => {
                        xhr.upload.onprogress = action((e) => {
                            file.progress = e.loaded / e.total;
                        });
                    });
                }).bind(this);
            });

            uploads.reduce((state, upload) => {
                if(state !== 0) {
                    if(state === null) {
                        return upload();
                    }
                    else {
                        return state.then((images) => {
                            for(let image of images) {
                                result.push(image);
                            }

                            return upload();
                        })
                        .catch((err) => {
                            caughtError = err;

                            return 0;
                        });
                    }
                }
            }, null)
            .then((images) => {
                for(let image of images) {
                    result.push(image);
                }
                return images;
            })
            .finally(() => {
                if(caughtError !== null) {
                    reject(caughtError);
                }
                else {
                    resolve(result);
                }
            });
        });
    }
}


