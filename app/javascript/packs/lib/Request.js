import * as qwest from 'qwest';

export default class Request {
    static get(url) {
        return new Promise((resolve, reject) => {
            qwest.get(url)
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
