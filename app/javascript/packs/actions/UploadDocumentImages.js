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
                    name: file.name
                };

                return (() => {
                  let notifier = {};

                  let promise = new Promise((resolve, reject) => {
                    return this.post(`${state.baseUrl}/api/images`, file.file, (xhr) => {
                        xhr.upload.onprogress = action((e) => {
                            file.progress = e.loaded / e.total;

                            if(file.progress === 1.0) {
                                notifier.done();
                            }
                        });
                    }).then((images) => {
                        resolve(images);
                    }).catch((err) => {
                        notifier.done();
                        reject(err);
                    });
                  });

                  notifier.promise = promise;

                  notifier.done = () => {
                      if(typeof notifier.promise._callback === "function") {
                          notifier.promise._callback();
                      }
                  };

                  promise.onDoneSending = (callback) => {
                      promise._callback = callback;
                      return promise;
                  };

                  return promise;
                }).bind(this);
            });

            let current = null;

            let schedule = () => {
                if(uploads.length > 0) {
                    if(current === null) {
                        current = uploads.pop();

                        current().onDoneSending(() => {
                            current = null;
                        }).then((images) => {
                            for(let image of images) {
                                result.push(image);
                            }

                            if(uploads.length === 0) {
                                resolve(result);
                            }
                        })
                        .catch((err) => {
                            reject(err);
                        });
                    }
                    setTimeout(schedule, 100);
                }
                else {
                    resolve(result);
                }
            };

            setTimeout(schedule, 100);

           //uploads.reduce((state, upload) => {
           //    if(state !== 0) {
           //        if(state === null) {
           //            return upload();
           //        }
           //        else {
           //            return state.then((images) => {
           //                for(let image of images) {
           //                    result.push(image);
           //                }
           //            })
           //            .onUploaded(() => {
           //                return upload();
           //            })
           //            .catch((err) => {
           //                caughtError = err;

           //                return 0;
           //            });
           //        }
           //    }
           //}, null)
           //.then((images) => {
           //    for(let image of images) {
           //        result.push(image);
           //    }
           //    return images;
           //})
           //.finally(() => {
           //    if(caughtError !== null) {
           //        reject(caughtError);
           //    }
           //    else {
           //        resolve(result);
           //    }
           //});
        });
    }
}


