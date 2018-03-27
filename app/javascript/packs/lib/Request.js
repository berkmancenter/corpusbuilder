import * as qwest from 'qwest';

export default class Request {

    static setBaseUrl(baseUrl) {
        qwest.base = baseUrl;
    }

    static get(url, params) {
        return new Promise((resolve, reject) => {
            qwest.get(url, params)
              .then((response) => {
                resolve(
                   JSON.parse(response.responseText)
                )
              .catch((error) => {
                reject(error);
              });
            });
        });
    }

    static resolveAsync(id, resolve = null, reject = null) {
        let executor = (resolve, reject) => {
            qwest.get(`/corpusbuilder/api/async_responses/${id}`)
                .then((response) => {
                    if(response.status === 202) {
                        setTimeout(Request.resolveAsync, 1000, id, resolve, reject);
                    }
                    else {
                        resolve(JSON.parse(response.responseText));
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
            qwest.put(url, JSON.stringify(data), { dataType: 'json' })
              .then((response) => {
                  let payload = JSON.parse(response.responseText);
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
              .catch((error) => {
                  reject(error);
              });
        });
    }

    static post(url, data, before) {
        return new Promise((resolve, reject) => {
            let payload = JSON.stringify(data);
            let options = { dataType: 'json' };

            if(data instanceof Blob) {
                payload = new FormData();
                payload.append('file', data);
                payload.append('name', data.name);

                options = null;
            }

            qwest.post(url, payload, options, before)
              .then((response) => {
                  let payload = JSON.parse(response.responseText);
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
              .catch((error) => {
                  reject(error);
              });
        });
    }

    static delete(url, data) {
        return new Promise((resolve, reject) => {
            qwest['delete'](url, JSON.stringify(data), { dataType: 'json' })
              .then((response) => {
                resolve(
                   JSON.parse(response.responseText)
                )
              .catch((error) => {
                reject(error);
              });
            });
        });
    }
}
