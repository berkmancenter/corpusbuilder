import * as qwest from 'qwest';

export default class Request {
    static get(url, params) {
        // todo: implement smart tracking of requests not to ask for the same
        // resource twice in a very short space of time
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
        // todo: implement smart tracking of requests not to ask for the same
        // resource twice in a very short space of time
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
}
