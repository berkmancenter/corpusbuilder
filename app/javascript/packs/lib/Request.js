import * as axios from 'axios';

let retry = function(fn, retriesLeft = 24, interval = 1000) {
    return new Promise((resolve, reject) => {
        fn()
            .then(resolve)
            .catch((error) => {
                setTimeout(() => {
                    if (retriesLeft === 1) {
                        reject(error);
                        return;
                    }

                    retry(fn, interval, retriesLeft - 1).then(resolve, reject);
                }, interval);
            });
    });
};

export default class Request {

    static backend = axios;

    static setBaseUrl(baseUrl) {
        Request.backend = axios.create({
          baseURL: baseUrl,
          headers: { 'Content-Type': 'application/json;charset=UTF-8' }
        });
    }

    static get(url, params) {
        return retry(function() {
            return new Promise((resolve, reject) => {
                Request.backend.get(url, { params: params })
                  .then((response) => {
                    resolve(response.data)
                  })
                  .catch((error) => {
                    reject(error);
                  });
            });
        });
    }

    static resolveAsync(id, resolve = null, reject = null) {
        let executor = (resolve, reject) => {
            Request.backend.get(`/api/async_responses/${id}`)
                .then((response) => {
                    if(response.status === 202) {
                        setTimeout(Request.resolveAsync, 1000, id, resolve, reject);
                    }
                    else {
                        resolve(response.data);
                    }
                })
                .catch((error) => {
                    reject(error);
                });
        };

        if(resolve === null) {
            return new Promise(executor);
        }
        else {
            executor(resolve, reject);
        }
    }

    static put(url, data) {
        return new Promise((resolve, reject) => {
            Request.backend.put(url, JSON.stringify(data), { dataType: 'json' })
              .then((response) => {
                  let payload = response.data;

                  if(response.status === 202) {
                      // we now need to periodically ask for the async
                      // response
                      Request.resolveAsync(payload.id)
                          .then((data) => {
                              resolve(data);
                          })
                          .catch((error) => {
                              reject(error);
                          });
                  }
                  else {
                      resolve(payload)
                  }
              })
              .catch((error, xhr, body) => {
                  reject(body);
              });
        });
    }

    static post(url, data) {
        return new Promise((resolve, reject) => {
            let payload = data;
            let options = { dataType: 'json' };

            Request.backend.post(url, payload, options)
              .then((response) => {
                  let payload = response.data;

                  if(response.status === 202) {
                      // we now need to periodically ask for the async
                      // response
                      Request.resolveAsync(payload.id)
                          .then((data) => {
                              resolve(data);
                          })
                          .catch((error) => {
                              reject(error);
                          });
                  }
                  else {
                      resolve(payload)
                  }
              })
              .catch((error, xhr, body) => {
                  reject(body);
              });
        });
    }

    static upload(url, data, onUploadProgress) {
        return new Promise((resolve, reject) => {
            let payload = data;
            let options = { dataType: 'json' };

            if(data instanceof Blob) {
                payload = new FormData();
                payload.append('file', data);
                payload.append('name', data.name);

                options = { timeout: 1000*3*60*60 };
            }

            Request.backend.request({
              url: url,
              method: 'post',
              data: payload,
              onUploadProgress: onUploadProgress
            }).then((response) => {
                let payload = response.data;

                if(response.status === 202) {
                    // we now need to periodically ask for the async
                    // response
                    Request.resolveAsync(payload.id)
                        .then((data) => {
                            resolve(data);
                        })
                        .catch((error) => {
                            reject(error);
                        });
                }
                else {
                    resolve(payload)
                }
            })
            .catch((error, xhr, body) => {
                reject(body);
            });
        });
    }

    static delete(url, data) {
        return new Promise((resolve, reject) => {
            Request.backend['delete'](url, JSON.stringify(data), { dataType: 'json' })
              .then((response) => {
                resolve(response.data);
              })
              .catch((error) => {
                reject(error);
              });
        });
    }
}
