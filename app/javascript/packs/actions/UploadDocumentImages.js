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
                    return this.upload(`${state.baseUrl}/api/images`, file.file, (e) => {
                        file.progress = e.loaded / e.total;

                        if(file.progress === 1.0) {
                            notifier.done();
                        }
                    }).then((images) => {
                        file.progress = 2.0;
                        console.log(file);
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

            uploads = uploads.reverse();

            let current = null;
            let resolved = 0;

            let schedule = () => {
                if(uploads.length > 0) {
                    if(current === null) {
                        current = uploads.pop();

                        current().onDoneSending(() => {
                            current = null;
                        }).then((images) => {
                            console.log("Got processed images:", images);
                            if(Array.isArray(images)) {
                                for(let image of images) {
                                    result.push(image);
                                }
                            }
                            else {
                                result.push(images);
                            }
                            resolved += 1;
                        })
                        .catch((err) => {
                            reject(err);
                        });
                    }
                    setTimeout(schedule, 100);
                }
                else {
                    if(current !== null || resolved < params.files.length) {
                        setTimeout(schedule, 100);
                    }
                    else {
                        console.log("Resolving images:", result);
                        resolve(result);
                    }
                }
            };

            setTimeout(schedule, 100);
        });
    }
}


