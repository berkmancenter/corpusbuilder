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

    static put(url, data) {
        return new Promise((resolve, reject) => {
            qwest.put(url, JSON.stringify(data), { dataType: 'json' })
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

    static post(url, data) {
        return new Promise((resolve, reject) => {
            qwest.post(url, JSON.stringify(data), { dataType: 'json' })
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
